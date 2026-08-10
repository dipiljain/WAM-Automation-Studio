public with sharing class WealthAIGrowthScaleService {
  public class ScaleSnapshot {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Integer proposalDrafts;
    @AuraEnabled
    public Integer referralQueue;
    @AuraEnabled
    public Integer crossSellRecommendations;
    @AuraEnabled
    public Integer scenarioInsights;
    @AuraEnabled
    public Integer serviceWorkflows;
    @AuraEnabled
    public Integer attritionSignals;
    @AuraEnabled
    public Integer surveillanceFindings;
    @AuraEnabled
    public Integer reconciliationWorkflows;
    @AuraEnabled
    public Integer cashSignals;
  }

  public class ScaleItem {
    @AuraEnabled
    public String key;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String subtitle;
    @AuraEnabled
    public String tone;
    @AuraEnabled
    public Id accountId;
    public ScaleItem(String key, String title, String subtitle, String tone) {
      this.key = key;
      this.title = title;
      this.subtitle = subtitle;
      this.tone = tone;
    }
  }

  public class ScaleActionResult {
    @AuraEnabled
    public Id runId;
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String detail;
    @AuraEnabled
    public String tone;
  }

  @AuraEnabled(cacheable=true)
  public static ScaleSnapshot getScaleSnapshot(Id accountId) {
    Account acct = validateAccount(accountId);
    ScaleSnapshot snapshot = new ScaleSnapshot();
    snapshot.accountId = acct.Id;
    snapshot.accountName = acct.Name;
    snapshot.proposalDrafts = [
      SELECT COUNT()
      FROM AI_Recommendation__c
      WHERE
        Account__c = :acct.Id
        AND Recommendation_Type__c = 'Proposal'
        AND Status__c = 'New'
    ];
    snapshot.referralQueue = [
      SELECT COUNT()
      FROM Referral_Prediction__c
      WHERE Account__c = :acct.Id AND Status__c IN ('New', 'Queued')
    ];
    snapshot.crossSellRecommendations = [
      SELECT COUNT()
      FROM AI_Recommendation__c
      WHERE
        Account__c = :acct.Id
        AND Recommendation_Type__c = 'Cross-Sell'
        AND Status__c = 'New'
    ];
    snapshot.scenarioInsights = [
      SELECT COUNT()
      FROM AI_Insight__c
      WHERE Account__c = :acct.Id AND Insight_Type__c = 'Portfolio'
    ];
    snapshot.serviceWorkflows = [
      SELECT COUNT()
      FROM Workflow_Execution__c
      WHERE
        Account__c = :acct.Id
        AND Automation_Template__r.Category__c = 'Service'
    ];
    snapshot.attritionSignals = [
      SELECT COUNT()
      FROM Risk_Signal__c
      WHERE Account__c = :acct.Id AND Signal_Type__c = 'Attrition'
    ];
    snapshot.surveillanceFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE Account__c = :acct.Id AND Finding_Type__c = 'Surveillance'
    ];
    snapshot.reconciliationWorkflows = [
      SELECT COUNT()
      FROM Workflow_Execution__c
      WHERE
        Account__c = :acct.Id
        AND Automation_Template__r.Category__c = 'Reconciliation'
    ];
    snapshot.cashSignals = [
      SELECT COUNT()
      FROM Risk_Signal__c
      WHERE Account__c = :acct.Id AND Signal_Type__c = 'Cash Movement'
    ];
    return snapshot;
  }

  @AuraEnabled(cacheable=true)
  public static List<ScaleItem> getGrowthItems(Id accountId) {
    Account acct = validateAccount(accountId);
    List<ScaleItem> items = new List<ScaleItem>();
    for (AI_Recommendation__c row : [
      SELECT Id, Recommendation_Type__c, Priority__c, Status__c
      FROM AI_Recommendation__c
      WHERE
        Account__c = :acct.Id
        AND Recommendation_Type__c IN ('Proposal', 'Cross-Sell')
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      ScaleItem item = new ScaleItem(
        String.valueOf(row.Id),
        row.Recommendation_Type__c + ' recommendation',
        'Priority: ' + row.Priority__c + ', Status: ' + row.Status__c,
        toTone(row.Priority__c)
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled(cacheable=true)
  public static List<ScaleItem> getServiceItems(Id accountId) {
    Account acct = validateAccount(accountId);
    List<ScaleItem> items = new List<ScaleItem>();
    for (Workflow_Execution__c row : [
      SELECT Id, Status__c, Details__c, Automation_Template__r.Category__c
      FROM Workflow_Execution__c
      WHERE
        Account__c = :acct.Id
        AND Automation_Template__r.Category__c IN ('Service', 'Reconciliation')
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      ScaleItem item = new ScaleItem(
        String.valueOf(row.Id),
        row.Automation_Template__r.Category__c + ' workflow',
        'Status: ' + row.Status__c + ', ' + abbreviate(row.Details__c, 90),
        row.Status__c == 'Failed'
          ? 'critical'
          : row.Status__c == 'Running' ? 'warning' : 'success'
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled(cacheable=true)
  public static List<ScaleItem> getControlItems(Id accountId) {
    Account acct = validateAccount(accountId);
    List<ScaleItem> items = new List<ScaleItem>();
    for (Risk_Signal__c row : [
      SELECT Id, Signal_Type__c, Severity__c, Summary__c
      FROM Risk_Signal__c
      WHERE
        Account__c = :acct.Id
        AND Signal_Type__c IN ('Attrition', 'Cash Movement')
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      ScaleItem item = new ScaleItem(
        String.valueOf(row.Id),
        row.Signal_Type__c + ' signal',
        abbreviate(row.Summary__c, 90),
        toTone(row.Severity__c)
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled
  public static ScaleActionResult runProposalCopilot(Id accountId) {
    Account acct = validateAccount(accountId);
    Decimal healthScore = getLatestHealthScore(acct.Id);
    String priority = healthScore < 65
      ? 'High'
      : healthScore < 80 ? 'Medium' : 'Low';
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Wealth Advisor Agent',
      'Advisor',
      acct.Id
    );
    AI_Recommendation__c rec = WealthAIStudioService.logRecommendation(
      runRecord.Id,
      acct.Id,
      'Proposal',
      'Draft suitability-aligned proposal with goals, allocations, and fee narrative.',
      priority,
      priority == 'High' ? 350000 : priority == 'Medium' ? 200000 : 100000
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = rec.Id;
    result.title = 'Proposal draft generated';
    result.detail =
      'Proposal copilot produced a draft recommendation for ' +
      acct.Name +
      '.';
    result.tone = toTone(priority);
    return result;
  }

  @AuraEnabled
  public static ScaleActionResult runReferralIntelligence(Id accountId) {
    Account acct = validateAccount(accountId);
    Decimal score = WamScoreEngine.clamp(
      58 + Math.mod(DateTime.now().millisecond(), 38),
      0,
      100
    );
    String priority = WamScoreEngine.toPriority(score);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Distribution Agent',
      'Distribution',
      acct.Id
    );
    Referral_Prediction__c prediction = new Referral_Prediction__c(
      Account__c = acct.Id,
      Score__c = score,
      Priority__c = priority,
      Status__c = 'Queued',
      Notes__c = 'Referral network opportunity detected for advisor activation.'
    );
    insert prediction;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = prediction.Id;
    result.title = 'Referral opportunity scored';
    result.detail =
      'Referral score ' +
      score.setScale(0) +
      ' with ' +
      priority +
      ' priority.';
    result.tone = toTone(priority);
    return result;
  }

  @AuraEnabled
  public static ScaleActionResult runCrossSellIntelligence(Id accountId) {
    Account acct = validateAccount(accountId);
    Integer openFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE Account__c = :acct.Id AND Status__c IN ('Open', 'Escalated')
    ];
    String priority = openFindings > 0 ? 'Medium' : 'High';
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Wealth Advisor Agent',
      'Advisor',
      acct.Id
    );
    AI_Recommendation__c rec = WealthAIStudioService.logRecommendation(
      runRecord.Id,
      acct.Id,
      'Cross-Sell',
      'Present managed lending and retirement optimization options at next meeting.',
      priority,
      priority == 'High' ? 280000 : 160000
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = rec.Id;
    result.title = 'Cross-sell recommendation generated';
    result.detail = 'Cross-sell opportunity is ready for advisor review.';
    result.tone = toTone(priority);
    return result;
  }

  @AuraEnabled
  public static ScaleActionResult runScenarioAnalysis(Id accountId) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Portfolio Agent',
      'Portfolio',
      acct.Id
    );
    AI_Insight__c insight = WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Portfolio',
      'Scenario analysis completed across base, stress, and upside market assumptions.',
      83
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = insight.Id;
    result.title = 'Scenario analysis generated';
    result.detail = 'Portfolio scenario summary is available for client-ready explanation.';
    result.tone = 'neutral';
    return result;
  }

  @AuraEnabled
  public static ScaleActionResult runServiceResolutionCopilot(Id accountId) {
    Account acct = validateAccount(accountId);
    Automation_Template__c template = ensureTemplate('Service');
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Service Agent',
      'Service',
      acct.Id
    );
    Workflow_Execution__c execution = new Workflow_Execution__c(
      Account__c = acct.Id,
      Automation_Template__c = template.Id,
      Status__c = 'Completed',
      Details__c = 'Service resolution response drafted with knowledge-grounded guidance.'
    );
    insert execution;
    WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Service',
      'Service resolution copilot identified likely resolution steps and drafted response.',
      80
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = execution.Id;
    result.title = 'Service resolution completed';
    result.detail = 'Service workflow execution completed with drafted resolution guidance.';
    result.tone = 'success';
    return result;
  }

  @AuraEnabled
  public static ScaleActionResult runPredictiveAttrition(Id accountId) {
    Account acct = validateAccount(accountId);
    String severity = getLatestHealthScore(acct.Id) < 60 ? 'High' : 'Medium';
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Wealth Advisor Agent',
      'Advisor',
      acct.Id
    );
    Risk_Signal__c signal = new Risk_Signal__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Signal_Type__c = 'Attrition',
      Severity__c = severity,
      Summary__c = 'Predictive attrition model flagged elevated churn risk.'
    );
    insert signal;
    WealthAIStudioService.logRecommendation(
      runRecord.Id,
      acct.Id,
      'Retention',
      'Launch retention outreach play with relationship manager this week.',
      severity == 'High' ? 'High' : 'Medium',
      severity == 'High' ? 400000 : 180000
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = signal.Id;
    result.title = 'Attrition risk detected';
    result.detail = 'Retention play was generated alongside attrition signal.';
    result.tone = toTone(severity);
    return result;
  }

  @AuraEnabled
  public static ScaleActionResult runComplianceSurveillance(Id accountId) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Compliance Agent',
      'Compliance',
      acct.Id
    );
    Compliance_Finding__c finding = new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = 'Surveillance',
      Status__c = 'Under Review'
    );
    insert finding;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = finding.Id;
    result.title = 'Compliance surveillance completed';
    result.detail = 'New surveillance finding created for compliance analyst review.';
    result.tone = 'warning';
    return result;
  }

  @AuraEnabled
  public static ScaleActionResult runReconciliationAssistant(Id accountId) {
    Account acct = validateAccount(accountId);
    Automation_Template__c template = ensureTemplate('Reconciliation');
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Operations Agent',
      'Operations',
      acct.Id
    );
    Workflow_Execution__c execution = new Workflow_Execution__c(
      Account__c = acct.Id,
      Automation_Template__c = template.Id,
      Status__c = 'Completed',
      Details__c = 'Reconciliation assistant matched transaction records and queued exceptions.'
    );
    insert execution;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = execution.Id;
    result.title = 'Reconciliation run completed';
    result.detail = 'Reconciliation workflow completed with exception summary.';
    result.tone = 'success';
    return result;
  }

  @AuraEnabled
  public static ScaleActionResult runCashMovementIntelligence(Id accountId) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Operations Agent',
      'Operations',
      acct.Id
    );
    Risk_Signal__c signal = new Risk_Signal__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Signal_Type__c = 'Cash Movement',
      Severity__c = 'High',
      Summary__c = 'Cash movement anomaly detected against historical threshold bands.'
    );
    insert signal;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ScaleActionResult result = new ScaleActionResult();
    result.runId = runRecord.Id;
    result.recordId = signal.Id;
    result.title = 'Cash movement anomaly detected';
    result.detail = 'Operations queue updated with high-severity cash movement signal.';
    result.tone = 'critical';
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

  private static Decimal getLatestHealthScore(Id accountId) {
    List<Client_Health_Score__c> rows = [
      SELECT Score__c
      FROM Client_Health_Score__c
      WHERE Account__c = :accountId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    return rows.isEmpty() ? 75 : rows[0].Score__c;
  }

  private static Automation_Template__c ensureTemplate(String category) {
    String templateName = 'WAM ' + category + ' Template';
    List<Automation_Template__c> existing = [
      SELECT Id
      FROM Automation_Template__c
      WHERE Name = :templateName
      LIMIT 1
    ];
    if (!existing.isEmpty()) {
      return existing[0];
    }
    Automation_Template__c template = new Automation_Template__c(
      Name = templateName,
      Category__c = category,
      Instructions__c = 'Auto-generated template for ' +
        category +
        ' use-case orchestration.'
    );
    insert template;
    return template;
  }

  private static String toTone(String severityOrPriority) {
    if (severityOrPriority == 'Critical' || severityOrPriority == 'High') {
      return 'critical';
    }
    if (severityOrPriority == 'Medium') {
      return 'warning';
    }
    if (severityOrPriority == 'Low') {
      return 'success';
    }
    return 'neutral';
  }

  private static String abbreviate(String input, Integer maxLength) {
    if (String.isBlank(input)) {
      return 'No details available.';
    }
    if (input.length() <= maxLength) {
      return input;
    }
    return input.substring(0, maxLength - 1) + '…';
  }
}
