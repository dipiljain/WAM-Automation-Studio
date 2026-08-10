public with sharing class WealthAIPartnerUseCaseService {
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

  public class PartnerBookSnapshot {
    @AuraEnabled
    public Integer partnerProgramCount;
    @AuraEnabled
    public Integer participantCount;
    @AuraEnabled
    public Integer atRiskParticipants;
    @AuraEnabled
    public Integer openReferrals;
    @AuraEnabled
    public Integer activeWorkflows;
  }

  private class ParticipantRank implements Comparable {
    Id accountId;
    Decimal score;
    ParticipantRank(Id accountId, Decimal score) {
      this.accountId = accountId;
      this.score = score;
    }
    public Integer compareTo(Object other) {
      Decimal otherScore = ((ParticipantRank) other).score;
      if (this.score == otherScore) {
        return 0;
      }
      return this.score < otherScore ? -1 : 1;
    }
  }

  public class PartnerRollupSnapshot {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Integer participantCount;
    @AuraEnabled
    public Integer atRiskParticipants;
    @AuraEnabled
    public Integer openReferrals;
    @AuraEnabled
    public Integer activeWorkflows;
    @AuraEnabled
    public Integer complianceFindings;
  }

  public class ParticipantItem {
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
    @AuraEnabled
    public String explanation;
    public ParticipantItem(
      String key,
      String title,
      String subtitle,
      String tone
    ) {
      this.key = key;
      this.title = title;
      this.subtitle = subtitle;
      this.tone = tone;
    }
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
    public String tone;
  }

  @AuraEnabled(cacheable=true)
  public static List<AccountOption> getPartnerAccountOptions() {
    Set<Id> parentIds = getAllParentAccountIds();
    List<AccountOption> options = new List<AccountOption>();
    for (Account acct : [
      SELECT Id, Name
      FROM Account
      WHERE RecordType.DeveloperName = 'Business' AND Id IN :parentIds
      ORDER BY Name
      LIMIT 100
    ]) {
      options.add(new AccountOption(acct.Id, acct.Name));
    }
    return options;
  }

  @AuraEnabled(cacheable=true)
  public static PartnerBookSnapshot getPartnerBookSnapshot() {
    Set<Id> partnerIds = getAllParentAccountIds();
    PartnerBookSnapshot snapshot = new PartnerBookSnapshot();
    snapshot.partnerProgramCount = partnerIds.size();

    Set<Id> participantIds = new Set<Id>();
    if (!partnerIds.isEmpty()) {
      for (Account child : [
        SELECT Id
        FROM Account
        WHERE ParentId IN :partnerIds
      ]) {
        participantIds.add(child.Id);
      }
    }
    snapshot.participantCount = participantIds.size();
    snapshot.atRiskParticipants = countAtRiskParticipants(participantIds);
    snapshot.openReferrals = participantIds.isEmpty()
      ? 0
      : [
          SELECT COUNT()
          FROM Referral_Prediction__c
          WHERE Account__c IN :participantIds AND Status__c IN ('New', 'Queued')
        ];
    snapshot.activeWorkflows = partnerIds.isEmpty()
      ? 0
      : [
          SELECT COUNT()
          FROM Workflow_Execution__c
          WHERE Account__c IN :partnerIds AND Status__c IN ('Queued', 'Running')
        ];
    return snapshot;
  }

  @AuraEnabled(cacheable=true)
  public static List<ParticipantItem> getPartnerPriorityQueue() {
    Set<Id> partnerIds = getAllParentAccountIds();
    List<ParticipantItem> results = new List<ParticipantItem>();
    if (partnerIds.isEmpty()) {
      return results;
    }

    Map<Id, Id> participantToPartner = new Map<Id, Id>();
    Map<Id, String> participantName = new Map<Id, String>();
    Map<Id, String> partnerName = new Map<Id, String>();
    for (Account child : [
      SELECT Id, Name, ParentId, Parent.Name
      FROM Account
      WHERE ParentId IN :partnerIds
    ]) {
      participantToPartner.put(child.Id, child.ParentId);
      participantName.put(child.Id, child.Name);
      partnerName.put(child.ParentId, child.Parent.Name);
    }

    Set<Id> participantIds = participantToPartner.keySet();
    Map<Id, Decimal> latestScoreByAccount = new Map<Id, Decimal>();
    if (!participantIds.isEmpty()) {
      for (Client_Health_Score__c row : [
        SELECT Account__c, Score__c
        FROM Client_Health_Score__c
        WHERE Account__c IN :participantIds
        ORDER BY Account__c, CreatedDate DESC
      ]) {
        if (!latestScoreByAccount.containsKey(row.Account__c)) {
          latestScoreByAccount.put(row.Account__c, row.Score__c);
        }
      }
    }

    List<ParticipantRank> ranks = new List<ParticipantRank>();
    for (Id pid : latestScoreByAccount.keySet()) {
      Decimal score = latestScoreByAccount.get(pid);
      if (score != null && score < 60) {
        ranks.add(new ParticipantRank(pid, score));
      }
    }
    ranks.sort();

    Integer limitCount = Math.min(6, ranks.size());
    for (Integer i = 0; i < limitCount; i++) {
      Id pid = ranks[i].accountId;
      Decimal score = ranks[i].score;
      String tone = score < 45 ? 'critical' : 'warning';
      ParticipantItem item = new ParticipantItem(
        String.valueOf(pid),
        participantName.get(pid) +
          ' (' +
          partnerName.get(participantToPartner.get(pid)) +
          ')',
        'Health score ' +
          score.setScale(0) +
          ' — flag to the partner relationship manager.',
        tone
      );
      item.accountId = pid;
      item.explanation = 'Health score of ' +
        score.setScale(0) +
        ' ranks in the bottom tier of this partner program, below the 60-point healthy threshold.';
      results.add(item);
    }
    return results;
  }

  @AuraEnabled(cacheable=true)
  public static PartnerRollupSnapshot getPartnerRollupSnapshot(Id accountId) {
    Account acct = validatePartnerAccount(accountId);
    Set<Id> participantIds = getParticipantIds(acct.Id);

    PartnerRollupSnapshot snapshot = new PartnerRollupSnapshot();
    snapshot.accountId = acct.Id;
    snapshot.accountName = acct.Name;
    snapshot.participantCount = participantIds.size();
    snapshot.atRiskParticipants = countAtRiskParticipants(participantIds);
    snapshot.openReferrals = participantIds.isEmpty()
      ? 0
      : [
          SELECT COUNT()
          FROM Referral_Prediction__c
          WHERE Account__c IN :participantIds AND Status__c IN ('New', 'Queued')
        ];
    snapshot.activeWorkflows = [
      SELECT COUNT()
      FROM Workflow_Execution__c
      WHERE Account__c = :acct.Id AND Status__c IN ('Queued', 'Running')
    ];
    snapshot.complianceFindings = participantIds.isEmpty()
      ? 0
      : [
          SELECT COUNT()
          FROM Compliance_Finding__c
          WHERE
            Account__c IN :participantIds
            AND Status__c IN ('Open', 'Escalated', 'Under Review')
        ];
    return snapshot;
  }

  @AuraEnabled(cacheable=true)
  public static List<ParticipantItem> getAtRiskParticipants(Id accountId) {
    Account acct = validatePartnerAccount(accountId);
    List<ParticipantItem> items = new List<ParticipantItem>();
    for (Account child : [
      SELECT
        Id,
        Name,
        (
          SELECT Score__c
          FROM Client_Health_Scores__r
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM Account
      WHERE ParentId = :acct.Id
      ORDER BY Name
      LIMIT 25
    ]) {
      Decimal latestScore = child.Client_Health_Scores__r.isEmpty()
        ? null
        : child.Client_Health_Scores__r[0].Score__c;
      if (latestScore != null && latestScore < 60) {
        ParticipantItem item = new ParticipantItem(
          String.valueOf(child.Id),
          child.Name,
          'Health score: ' + latestScore.setScale(0),
          latestScore < 45 ? 'critical' : 'warning'
        );
        item.accountId = child.Id;
        items.add(item);
      }
    }
    return items;
  }

  @AuraEnabled
  public static ActionResult runWhiteLabelAdvisorAction(
    Id partnerAccountId,
    Id participantAccountId
  ) {
    Account partner = validatePartnerAccount(partnerAccountId);
    if (participantAccountId == null) {
      throw new AuraHandledException('Select a participant to continue.');
    }
    List<Account> participantRows = [
      SELECT Id, Name, ParentId
      FROM Account
      WHERE Id = :participantAccountId
      LIMIT 1
    ];
    if (
      participantRows.isEmpty() || participantRows[0].ParentId != partner.Id
    ) {
      throw new AuraHandledException(
        'The selected participant does not belong to this partner program.'
      );
    }

    WealthAIAdvisorUseCaseService.ActionResult delegated = WealthAIAdvisorUseCaseService.generateNextBestAction(
      participantRows[0].Id
    );

    ActionResult result = new ActionResult();
    result.runId = delegated.runId;
    result.recordId = delegated.recordId;
    result.title =
      'White-label advisor action generated for ' + participantRows[0].Name;
    result.detail = delegated.detail;
    result.tone = delegated.priority == 'High' ? 'critical' : 'warning';
    return result;
  }

  @AuraEnabled
  public static ActionResult runPartnerOnboardingBatch(Id accountId) {
    Account acct = validatePartnerAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Partner Program Agent',
      'Partner',
      acct.Id
    );
    Automation_Template__c template = ensureTemplate('Onboarding');
    Workflow_Execution__c execution = new Workflow_Execution__c(
      Account__c = acct.Id,
      Automation_Template__c = template.Id,
      Status__c = 'Running',
      Details__c = 'Partner program batch onboarding launched for new participant accounts.'
    );
    insert execution;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = execution.Id;
    result.title = 'Partner onboarding batch started';
    result.detail = execution.Details__c;
    result.tone = 'success';
    return result;
  }

  @AuraEnabled
  public static ActionResult runCrossProgramReferral(Id accountId) {
    Account acct = validatePartnerAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Partner Program Agent',
      'Partner',
      acct.Id
    );
    Decimal score = WamScoreEngine.clamp(
      60 + Math.mod(DateTime.now().millisecond(), 35),
      0,
      100
    );
    String priority = WamScoreEngine.toPriority(score);
    Referral_Prediction__c prediction = new Referral_Prediction__c(
      Account__c = acct.Id,
      Score__c = score,
      Priority__c = priority,
      Status__c = 'New',
      Notes__c = 'Cross-program referral opportunity identified across partner participant base.'
    );
    insert prediction;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = prediction.Id;
    result.title = 'Cross-program referral identified';
    result.detail = 'Score: ' + score.setScale(0) + ', Priority: ' + priority;
    result.tone = priority == 'High' ? 'critical' : 'warning';
    return result;
  }

  @AuraEnabled
  public static ActionResult runParticipantEngagementCampaign(Id accountId) {
    Account acct = validatePartnerAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Partner Program Agent',
      'Partner',
      acct.Id
    );
    List<ParticipantItem> atRisk = getAtRiskParticipants(acct.Id);
    String detail =
      'Hyper-personalized engagement campaign queued for ' +
      atRisk.size() +
      ' at-risk participant(s) in this partner program.';
    AI_Recommendation__c rec = WealthAIStudioService.logRecommendation(
      runRecord.Id,
      acct.Id,
      'Outreach',
      detail,
      atRisk.isEmpty() ? 'Low' : 'Medium',
      0
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = rec.Id;
    result.title = 'Participant engagement campaign queued';
    result.detail = detail;
    result.tone = atRisk.isEmpty() ? 'success' : 'warning';
    return result;
  }

  @AuraEnabled(cacheable=true)
  public static List<ParticipantItem> getPartnerComplianceRollup(Id accountId) {
    Account acct = validatePartnerAccount(accountId);
    Set<Id> participantIds = getParticipantIds(acct.Id);
    List<ParticipantItem> items = new List<ParticipantItem>();
    if (participantIds.isEmpty()) {
      return items;
    }
    for (Compliance_Finding__c row : [
      SELECT Id, Account__c, Account__r.Name, Finding_Type__c, Status__c
      FROM Compliance_Finding__c
      WHERE Account__c IN :participantIds
      ORDER BY CreatedDate DESC
      LIMIT 10
    ]) {
      ParticipantItem item = new ParticipantItem(
        String.valueOf(row.Id),
        row.Account__r.Name + ': ' + row.Finding_Type__c + ' finding',
        'Status: ' + row.Status__c,
        row.Status__c == 'Escalated'
          ? 'critical'
          : row.Status__c == 'Open' ? 'warning' : 'neutral'
      );
      item.accountId = row.Account__c;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled
  public static ActionResult runAutonomousPartnerGrowthAgent(Id accountId) {
    Account acct = validatePartnerAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Autonomous Partner Growth Agent',
      'Partner',
      acct.Id
    );
    update new AI_Agent_Run__c(
      Id = runRecord.Id,
      Autonomous_Mode__c = true,
      HITL_Status__c = 'Pending',
      Plan_Summary__c = 'Identify participant growth opportunities and draft outreach for partner program manager approval.'
    );
    Decimal score = WamScoreEngine.clamp(
      65 + Math.mod(DateTime.now().millisecond(), 30),
      0,
      100
    );
    Referral_Prediction__c prediction = new Referral_Prediction__c(
      Account__c = acct.Id,
      Score__c = score,
      Priority__c = WamScoreEngine.toPriority(score),
      Status__c = 'New',
      Notes__c = 'Autonomous partner growth agent identified a program-level referral opportunity.'
    );
    insert prediction;
    WealthAIStudioService.completeRun(runRecord.Id, 'Escalated');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = prediction.Id;
    result.title = 'Autonomous partner growth run completed';
    result.detail = 'Referral opportunity created and awaiting partner program manager approval.';
    result.tone = 'warning';
    return result;
  }

  public static Id resolvePartnerAccountId(String accountName) {
    if (String.isBlank(accountName)) {
      return null;
    }
    Set<Id> parentIds = getAllParentAccountIds();
    List<Account> matches = [
      SELECT Id
      FROM Account
      WHERE
        Name LIKE :('%' + accountName + '%')
        AND RecordType.DeveloperName = 'Business'
        AND Id IN :parentIds
      ORDER BY Name
      LIMIT 1
    ];
    return matches.isEmpty() ? null : matches[0].Id;
  }

  private static Set<Id> getAllParentAccountIds() {
    Set<Id> parentIds = new Set<Id>();
    for (Account child : [
      SELECT ParentId
      FROM Account
      WHERE ParentId != NULL
    ]) {
      parentIds.add(child.ParentId);
    }
    return parentIds;
  }

  private static Set<Id> getParticipantIds(Id partnerAccountId) {
    Set<Id> ids = new Set<Id>();
    for (Account child : [
      SELECT Id
      FROM Account
      WHERE ParentId = :partnerAccountId
    ]) {
      ids.add(child.Id);
    }
    return ids;
  }

  private static Integer countAtRiskParticipants(Set<Id> participantIds) {
    if (participantIds.isEmpty()) {
      return 0;
    }
    Integer atRisk = 0;
    Map<Id, Decimal> latestScoreByAccount = new Map<Id, Decimal>();
    for (Client_Health_Score__c row : [
      SELECT Account__c, Score__c
      FROM Client_Health_Score__c
      WHERE Account__c IN :participantIds
      ORDER BY Account__c, CreatedDate DESC
    ]) {
      if (!latestScoreByAccount.containsKey(row.Account__c)) {
        latestScoreByAccount.put(row.Account__c, row.Score__c);
      }
    }
    for (Decimal score : latestScoreByAccount.values()) {
      if (score != null && score < 60) {
        atRisk++;
      }
    }
    return atRisk;
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
      Instructions__c = 'Auto-generated template for partner ' +
        category +
        ' automation.'
    );
    insert template;
    return template;
  }

  private static Account validatePartnerAccount(Id accountId) {
    if (accountId == null) {
      throw new AuraHandledException('Select a partner account to continue.');
    }
    List<Account> rows = [
      SELECT Id, Name
      FROM Account
      WHERE Id = :accountId AND RecordType.DeveloperName = 'Business'
      LIMIT 1
    ];
    if (rows.isEmpty()) {
      throw new AuraHandledException('Partner (Business) account not found.');
    }
    return rows[0];
  }
}
