public with sharing class WealthAIDashboardResetService {
  private static final Integer BASELINE_CAP = 6;

  public class ResetResult {
    @AuraEnabled
    public Integer clearedCount;
    @AuraEnabled
    public Integer reseededCount;
    @AuraEnabled
    public String detail;
  }

  @AuraEnabled
  public static ResetResult resetAdvisorData() {
    List<AI_Insight__c> insights = [
      SELECT Id, Account__c
      FROM AI_Insight__c
      WHERE Status__c = 'New'
    ];
    List<AI_Recommendation__c> recs = [
      SELECT Id, Account__c
      FROM AI_Recommendation__c
      WHERE Status__c = 'New'
    ];
    List<Client_Health_Score__c> scores = [
      SELECT Id, Account__c
      FROM Client_Health_Score__c
      WHERE Score__c < 60
    ];

    Set<Id> accountIds = new Set<Id>();
    for (AI_Insight__c row : insights) {
      if (row.Account__c != null) {
        accountIds.add(row.Account__c);
      }
    }
    for (AI_Recommendation__c row : recs) {
      if (row.Account__c != null) {
        accountIds.add(row.Account__c);
      }
    }
    for (Client_Health_Score__c row : scores) {
      if (row.Account__c != null) {
        accountIds.add(row.Account__c);
      }
    }

    Integer clearedCount = insights.size() + recs.size() + scores.size();
    delete insights;
    delete recs;
    delete scores;

    List<Id> baselineAccounts = resolveBaselineAccounts(accountIds, null);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Dashboard Reset Agent',
      'Advisor',
      null
    );
    List<String> insightTypes = new List<String>{
      'Portfolio',
      'Relationship',
      'Opportunity'
    };
    List<String> recTypes = new List<String>{
      'Cross-Sell',
      'Retention',
      'Outreach'
    };
    Integer reseeded = 0;
    for (Integer i = 0; i < baselineAccounts.size(); i++) {
      Id acctId = baselineAccounts[i];
      WealthAIStudioService.logInsight(
        runRecord.Id,
        acctId,
        insightTypes[Math.mod(i, insightTypes.size())],
        'Baseline insight restored after dashboard reset.',
        75
      );
      WealthAIStudioService.logRecommendation(
        runRecord.Id,
        acctId,
        recTypes[Math.mod(i, recTypes.size())],
        'Baseline recommendation restored after dashboard reset.',
        'Low',
        25000
      );
      insert new Client_Health_Score__c(
        Account__c = acctId,
        Score__c = 70 + Math.mod(i * 7, 20)
      );
      reseeded++;
    }
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    return buildResult(clearedCount, reseeded);
  }

  @AuraEnabled
  public static ResetResult resetComplianceData() {
    List<Compliance_Finding__c> findings = [
      SELECT Id, Account__c, Finding_Type__c
      FROM Compliance_Finding__c
      WHERE Status__c IN ('Open', 'Escalated')
    ];

    Set<Id> accountIds = new Set<Id>();
    List<String> findingTypes = new List<String>();
    for (Compliance_Finding__c row : findings) {
      if (row.Account__c != null) {
        accountIds.add(row.Account__c);
      }
      if (String.isNotBlank(row.Finding_Type__c)) {
        findingTypes.add(row.Finding_Type__c);
      }
    }
    if (findingTypes.isEmpty()) {
      findingTypes.add('KYC');
    }

    Integer clearedCount = findings.size();
    delete findings;

    List<Id> baselineAccounts = resolveBaselineAccounts(accountIds, null);
    List<Compliance_Finding__c> reseeded = new List<Compliance_Finding__c>();
    for (Integer i = 0; i < baselineAccounts.size(); i++) {
      reseeded.add(
        new Compliance_Finding__c(
          Account__c = baselineAccounts[i],
          Finding_Type__c = findingTypes[Math.mod(i, findingTypes.size())],
          Status__c = 'Cleared'
        )
      );
    }
    if (!reseeded.isEmpty()) {
      insert reseeded;
    }

    return buildResult(clearedCount, reseeded.size());
  }

  @AuraEnabled
  public static ResetResult resetExecutiveData() {
    List<AI_Agent_Run__c> pendingRuns = [
      SELECT Id, Agent_Name__c, Persona__c, Related_Record_Id__c
      FROM AI_Agent_Run__c
      WHERE HITL_Status__c = 'Pending'
    ];

    Integer clearedCount = pendingRuns.size();
    List<String> agentNames = new List<String>();
    List<String> personas = new List<String>();
    for (AI_Agent_Run__c row : pendingRuns) {
      agentNames.add(
        String.isBlank(row.Agent_Name__c) ? 'Advisor Agent' : row.Agent_Name__c
      );
      personas.add(String.isBlank(row.Persona__c) ? 'Advisor' : row.Persona__c);
    }
    delete pendingRuns;

    if (agentNames.isEmpty()) {
      agentNames.add('Advisor Agent');
      personas.add('Advisor');
    }

    Integer cap = Math.min(BASELINE_CAP, agentNames.size());
    List<AI_Agent_Run__c> reseeded = new List<AI_Agent_Run__c>();
    for (Integer i = 0; i < cap; i++) {
      reseeded.add(
        new AI_Agent_Run__c(
          Agent_Name__c = agentNames[i],
          Persona__c = personas[i],
          Status__c = 'Success',
          HITL_Status__c = 'Approved',
          Started__c = System.now(),
          Completed__c = System.now(),
          Run_User__c = UserInfo.getUserId(),
          Plan_Summary__c = 'Baseline run restored after dashboard reset; previously pending action approved.'
        )
      );
    }
    if (!reseeded.isEmpty()) {
      insert reseeded;
    }

    return buildResult(clearedCount, reseeded.size());
  }

  @AuraEnabled
  public static ResetResult resetInstitutionalData() {
    Set<Id> parentIds = getAllParentAccountIds();
    List<Institutional_Mandate__c> breaches = [
      SELECT Id, Account__c, Mandate_Type__c
      FROM Institutional_Mandate__c
      WHERE Compliance_Status__c = 'Breach' AND Account__c NOT IN :parentIds
    ];

    Set<Id> accountIds = new Set<Id>();
    List<String> mandateTypes = new List<String>();
    for (Institutional_Mandate__c row : breaches) {
      if (row.Account__c != null) {
        accountIds.add(row.Account__c);
      }
      if (String.isNotBlank(row.Mandate_Type__c)) {
        mandateTypes.add(row.Mandate_Type__c);
      }
    }
    if (mandateTypes.isEmpty()) {
      mandateTypes.add('Investment Policy Statement');
    }

    Integer clearedCount = breaches.size();
    delete breaches;

    List<Id> baselineAccounts = resolveBaselineAccounts(
      accountIds,
      'RecordType.DeveloperName = \'Business\' AND Id NOT IN :parentIds'
    );
    List<Institutional_Mandate__c> reseeded = new List<Institutional_Mandate__c>();
    for (Integer i = 0; i < baselineAccounts.size(); i++) {
      reseeded.add(
        new Institutional_Mandate__c(
          Account__c = baselineAccounts[i],
          Mandate_Type__c = mandateTypes[Math.mod(i, mandateTypes.size())],
          Compliance_Status__c = 'Compliant',
          Last_Reviewed__c = DateTime.now()
        )
      );
    }
    if (!reseeded.isEmpty()) {
      insert reseeded;
    }

    return buildResult(clearedCount, reseeded.size());
  }

  @AuraEnabled
  public static ResetResult resetPartnerData() {
    Set<Id> partnerIds = getAllParentAccountIds();
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

    List<Client_Health_Score__c> scores = participantIds.isEmpty()
      ? new List<Client_Health_Score__c>()
      : [
          SELECT Id, Account__c
          FROM Client_Health_Score__c
          WHERE Account__c IN :participantIds AND Score__c < 60
        ];

    Set<Id> accountIds = new Set<Id>();
    for (Client_Health_Score__c row : scores) {
      if (row.Account__c != null) {
        accountIds.add(row.Account__c);
      }
    }

    Integer clearedCount = scores.size();
    delete scores;

    List<Id> baselineAccounts = new List<Id>(accountIds);
    if (baselineAccounts.isEmpty() && !participantIds.isEmpty()) {
      Integer cap = Math.min(BASELINE_CAP, participantIds.size());
      Integer taken = 0;
      for (Id pid : participantIds) {
        if (taken >= cap) {
          break;
        }
        baselineAccounts.add(pid);
        taken++;
      }
    }
    if (baselineAccounts.size() > BASELINE_CAP) {
      baselineAccounts = new List<Id>(
        new Set<Id>(baselineAccounts)
      );
      while (baselineAccounts.size() > BASELINE_CAP) {
        baselineAccounts.remove(baselineAccounts.size() - 1);
      }
    }

    List<Client_Health_Score__c> reseeded = new List<Client_Health_Score__c>();
    for (Integer i = 0; i < baselineAccounts.size(); i++) {
      reseeded.add(
        new Client_Health_Score__c(
          Account__c = baselineAccounts[i],
          Score__c = 70 + Math.mod(i * 7, 20)
        )
      );
    }
    if (!reseeded.isEmpty()) {
      insert reseeded;
    }

    return buildResult(clearedCount, reseeded.size());
  }

  private static List<Id> resolveBaselineAccounts(
    Set<Id> capturedAccountIds,
    String fallbackWhereClause
  ) {
    List<Id> baseline = new List<Id>(capturedAccountIds);
    if (baseline.size() > BASELINE_CAP) {
      while (baseline.size() > BASELINE_CAP) {
        baseline.remove(baseline.size() - 1);
      }
    }
    if (!baseline.isEmpty()) {
      return baseline;
    }
    Set<Id> parentIds = getAllParentAccountIds();
    String query = 'SELECT Id FROM Account';
    if (String.isNotBlank(fallbackWhereClause)) {
      query += ' WHERE ' + fallbackWhereClause;
    }
    query += ' LIMIT ' + BASELINE_CAP;
    for (Account acct : Database.query(query)) {
      baseline.add(acct.Id);
    }
    return baseline;
  }

  private static Set<Id> getAllParentAccountIds() {
    Set<Id> parentIds = new Set<Id>();
    for (Account child : [SELECT ParentId FROM Account WHERE ParentId != NULL]) {
      parentIds.add(child.ParentId);
    }
    return parentIds;
  }

  private static ResetResult buildResult(Integer clearedCount, Integer reseededCount) {
    ResetResult result = new ResetResult();
    result.clearedCount = clearedCount;
    result.reseededCount = reseededCount;
    result.detail = 'Cleared ' +
      clearedCount +
      ' flagged record(s) and restored ' +
      reseededCount +
      ' healthy baseline record(s).';
    return result;
  }
}
