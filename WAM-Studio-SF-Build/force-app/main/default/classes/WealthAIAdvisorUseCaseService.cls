public with sharing class WealthAIAdvisorUseCaseService {
  public class AccountOption {
    @AuraEnabled
    public Id value;
    @AuraEnabled
    public String label;
    public AccountOption(Id value, String label) {
      this.value = value;
      this.label = label;
    }
  }

  public class Client360Snapshot {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Decimal engagementScore;
    @AuraEnabled
    public Decimal healthScore;
    @AuraEnabled
    public Integer openRecommendations;
    @AuraEnabled
    public Integer newInsights;
    @AuraEnabled
    public Integer openFindings;
    @AuraEnabled
    public Integer criticalAlerts;
    @AuraEnabled
    public String healthDrivers;
  }

  public class ActionResult {
    @AuraEnabled
    public Id runId;
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String detail;
    @AuraEnabled
    public String priority;
  }

  public class ScoreResult {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public Decimal engagementScore;
    @AuraEnabled
    public Decimal healthScore;
  }

  @AuraEnabled(cacheable=true)
  public static List<AccountOption> getAccountOptions() {
    List<AccountOption> options = new List<AccountOption>();
    for (Account acct : [
      SELECT Id, Name
      FROM Account
      WHERE RecordType.DeveloperName IN ('Household', 'PersonAccount')
      ORDER BY Name
      LIMIT 100
    ]) {
      options.add(new AccountOption(acct.Id, acct.Name));
    }
    return options;
  }

  @AuraEnabled
  public static Client360Snapshot getClient360(Id accountId) {
    Account acct = validateAccount(accountId);
    Client360Snapshot snapshot = new Client360Snapshot();
    snapshot.accountId = acct.Id;
    snapshot.accountName = acct.Name;
    snapshot.openRecommendations = [
      SELECT COUNT()
      FROM AI_Recommendation__c
      WHERE Account__c = :acct.Id AND Status__c = 'New'
    ];
    snapshot.newInsights = [
      SELECT COUNT()
      FROM AI_Insight__c
      WHERE Account__c = :acct.Id AND Status__c = 'New'
    ];
    snapshot.openFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE Account__c = :acct.Id AND Status__c IN ('Open', 'Escalated')
    ];
    snapshot.criticalAlerts = [
      SELECT COUNT()
      FROM Portfolio_Alert__c
      WHERE Account__c = :acct.Id AND Severity__c IN ('Critical', 'High')
    ];

    List<Engagement_Score__c> engagementRows = [
      SELECT Score__c
      FROM Engagement_Score__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    List<Client_Health_Score__c> healthRows = [
      SELECT Score__c, Score_Drivers__c
      FROM Client_Health_Score__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    snapshot.engagementScore = engagementRows.isEmpty()
      ? null
      : engagementRows[0].Score__c;
    snapshot.healthScore = healthRows.isEmpty() ? null : healthRows[0].Score__c;
    snapshot.healthDrivers = healthRows.isEmpty()
      ? null
      : healthRows[0].Score_Drivers__c;
    return snapshot;
  }

  @AuraEnabled
  public static ScoreResult refreshScores(Id accountId) {
    Account acct = validateAccount(accountId);
    Integer openFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE Account__c = :acct.Id AND Status__c IN ('Open', 'Escalated')
    ];
    Integer criticalAlerts = [
      SELECT COUNT()
      FROM Portfolio_Alert__c
      WHERE Account__c = :acct.Id AND Severity__c IN ('Critical', 'High')
    ];
    // Exclude 'Relationship' insights: those are self-logged by
    // generateAdvisorBriefing/generateRelationshipInsight, and counting them
    // here would let clicking those actions inflate their own next score.
    Integer newInsights = [
      SELECT COUNT()
      FROM AI_Insight__c
      WHERE
        Account__c = :acct.Id
        AND Status__c = 'New'
        AND Insight_Type__c != 'Relationship'
    ];
    Integer newRecommendations = [
      SELECT COUNT()
      FROM AI_Recommendation__c
      WHERE Account__c = :acct.Id AND Status__c = 'New'
    ];

    Decimal engagementScore = WamScoreEngine.clamp(
      75 + (newInsights * 3) - (openFindings * 8) - (criticalAlerts * 6),
      0,
      100
    );
    Decimal complianceComponent = WamScoreEngine.clamp(
      100 - (openFindings * 10) - (criticalAlerts * 8),
      0,
      100
    );
    Decimal recommendationsPenalty = Math.min(newRecommendations, 10) * 1;
    Decimal healthScore = WamScoreEngine.clamp(
      (engagementScore * 0.6) +
        (complianceComponent * 0.4) -
        recommendationsPenalty,
      0,
      100
    );

    String drivers = WamExplain.healthDrivers(
      healthScore,
      engagementScore,
      openFindings,
      criticalAlerts,
      newRecommendations
    );
    upsertScore(acct.Id, engagementScore, healthScore, drivers);

    ScoreResult result = new ScoreResult();
    result.accountId = acct.Id;
    result.engagementScore = engagementScore;
    result.healthScore = healthScore;
    return result;
  }

  @AuraEnabled
  public static ActionResult generateRelationshipInsight(Id accountId) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Wealth Advisor Agent',
      'Advisor',
      acct.Id
    );
    Client360Snapshot snapshot = getClient360(acct.Id);

    String summary =
      'Relationship signal for ' +
      acct.Name +
      ': ' +
      snapshot.newInsights +
      ' new insights, ' +
      snapshot.openRecommendations +
      ' open recommendations, ' +
      snapshot.openFindings +
      ' open findings.';
    AI_Insight__c insight = WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Relationship',
      summary,
      82
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = insight.Id;
    result.title = 'Relationship intelligence generated';
    result.detail = summary;
    result.priority = 'Medium';
    return result;
  }

  @AuraEnabled
  public static ActionResult generateNextBestAction(Id accountId) {
    Account acct = validateAccount(accountId);
    ScoreResult scores = refreshScores(acct.Id);
    Decimal actionScore = WamScoreEngine.clamp(
      (100 - scores.healthScore) + scores.engagementScore,
      0,
      100
    );
    String priority = WamScoreEngine.toPriority(actionScore);
    String recType = priority == 'High' ? 'Retention' : 'Cross-Sell';
    String actionText = priority == 'High'
      ? 'Prioritize outreach this week and schedule a strategy call.'
      : priority == 'Medium'
          ? 'Schedule follow-up and review uncovered needs.'
          : 'Continue nurture cadence and monitor account signals.';

    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Wealth Advisor Agent',
      'Advisor',
      acct.Id
    );
    AI_Recommendation__c recommendation = WealthAIStudioService.logRecommendation(
      runRecord.Id,
      acct.Id,
      recType,
      actionText,
      priority,
      priority == 'High' ? 450000 : priority == 'Medium' ? 200000 : 50000
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = recommendation.Id;
    result.title = 'Next best action generated';
    result.detail = actionText;
    result.priority = priority;
    return result;
  }

  @AuraEnabled
  public static ActionResult generateAdvisorBriefing(Id accountId) {
    Account acct = validateAccount(accountId);
    ScoreResult scores = refreshScores(acct.Id);
    Client360Snapshot snapshot = getClient360(acct.Id);
    String priority = WamScoreEngine.toPriority(
      (scores.healthScore + scores.engagementScore) / 2
    );

    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Wealth Advisor Agent',
      'Advisor',
      acct.Id
    );

    Set<String> findingTypes = new Set<String>();
    for (Compliance_Finding__c cf : [
      SELECT Finding_Type__c
      FROM Compliance_Finding__c
      WHERE Account__c = :acct.Id AND Status__c IN ('Open', 'Escalated')
    ]) {
      if (String.isNotBlank(cf.Finding_Type__c)) {
        findingTypes.add(cf.Finding_Type__c);
      }
    }

    List<String> alertLines = new List<String>();
    for (Portfolio_Alert__c pa : [
      SELECT Alert_Type__c, Severity__c
      FROM Portfolio_Alert__c
      WHERE Account__c = :acct.Id AND Severity__c IN ('Critical', 'High')
      ORDER BY Severity__c
      LIMIT 5
    ]) {
      alertLines.add(pa.Alert_Type__c + ' (' + pa.Severity__c + ')');
    }

    List<String> actionLines = new List<String>();
    for (AI_Recommendation__c rec : [
      SELECT Recommended_Action__c, Priority__c
      FROM AI_Recommendation__c
      WHERE Account__c = :acct.Id AND Status__c = 'New'
      ORDER BY CreatedDate DESC
      LIMIT 3
    ]) {
      if (String.isNotBlank(rec.Recommended_Action__c)) {
        actionLines.add(
          rec.Recommended_Action__c + ' (' + rec.Priority__c + ' priority)'
        );
      }
    }

    List<String> sections = new List<String>();
    sections.add(
      acct.Name +
        ' is ' +
        priority +
        ' priority this cycle (Engagement ' +
        scores.engagementScore.setScale(0) +
        ', Health ' +
        scores.healthScore.setScale(0) +
        ').'
    );
    sections.add(
      findingTypes.isEmpty()
        ? 'No open compliance findings.'
        : 'Open compliance findings: ' +
            String.join(new List<String>(findingTypes), ', ') +
            ' (' +
            snapshot.openFindings +
            ' total).'
    );
    if (!alertLines.isEmpty()) {
      sections.add(
        'Critical/high portfolio alerts: ' +
          String.join(alertLines, ', ') +
          '.'
      );
    }
    sections.add(
      actionLines.isEmpty()
        ? snapshot.openRecommendations > 0
          ? snapshot.openRecommendations + ' open recommendation(s) pending review.'
          : 'No open recommendations.'
        : 'Top recommendations: ' + String.join(actionLines, '; ') + '.'
    );

    String summary = String.join(sections, ' ');

    Advisor_Briefing__c briefing = new Advisor_Briefing__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Briefing_Date__c = Date.today(),
      Briefing_Summary__c = summary,
      Priority__c = priority
    );
    insert briefing;

    WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Relationship',
      summary,
      80
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = briefing.Id;
    result.title = 'Advisor briefing generated';
    result.detail = summary;
    result.priority = priority;
    return result;
  }

  private static Account validateAccount(Id accountId) {
    if (accountId == null) {
      throw new AuraHandledException('Select an account to continue.');
    }
    List<Account> rows = [
      SELECT Id, Name
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
    if (rows.isEmpty()) {
      throw new AuraHandledException('Account not found.');
    }
    return rows[0];
  }

  private static void upsertScore(
    Id accountId,
    Decimal engagement,
    Decimal health,
    String healthDrivers
  ) {
    List<Engagement_Score__c> engagementRows = [
      SELECT Id
      FROM Engagement_Score__c
      WHERE Account__c = :accountId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    if (engagementRows.isEmpty()) {
      insert new Engagement_Score__c(
        Account__c = accountId,
        Score__c = engagement
      );
    } else {
      update new Engagement_Score__c(
        Id = engagementRows[0].Id,
        Score__c = engagement
      );
    }

    List<Client_Health_Score__c> healthRows = [
      SELECT Id
      FROM Client_Health_Score__c
      WHERE Account__c = :accountId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    if (healthRows.isEmpty()) {
      insert new Client_Health_Score__c(
        Account__c = accountId,
        Score__c = health,
        Score_Drivers__c = healthDrivers
      );
    } else {
      update new Client_Health_Score__c(
        Id = healthRows[0].Id,
        Score__c = health,
        Score_Drivers__c = healthDrivers
      );
    }
  }
}
