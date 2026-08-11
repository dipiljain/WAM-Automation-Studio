public with sharing class WealthAIAutonomyUseCaseService {
  public class AutonomySnapshot {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Integer autonomousRuns;
    @AuraEnabled
    public Integer pendingApprovals;
    @AuraEnabled
    public Integer escalatedRuns;
    @AuraEnabled
    public Integer openRiskSignals;
    @AuraEnabled
    public Integer openFindings;
    @AuraEnabled
    public Integer activeWorkflows;
  }

  public class AutonomyItem {
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
    public AutonomyItem(
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

  public class AutonomyActionResult {
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
  public static AutonomySnapshot getAutonomySnapshot(Id accountId) {
    Account acct = validateAccount(accountId);
    AutonomySnapshot snapshot = new AutonomySnapshot();
    snapshot.accountId = acct.Id;
    snapshot.accountName = acct.Name;
    snapshot.autonomousRuns = [
      SELECT COUNT()
      FROM AI_Agent_Run__c
      WHERE Related_Record_Id__c = :acct.Id AND Autonomous_Mode__c = TRUE
    ];
    snapshot.pendingApprovals = [
      SELECT COUNT()
      FROM AI_Agent_Run__c
      WHERE
        Related_Record_Id__c = :acct.Id
        AND Autonomous_Mode__c = TRUE
        AND HITL_Status__c = 'Pending'
    ];
    snapshot.escalatedRuns = [
      SELECT COUNT()
      FROM AI_Agent_Run__c
      WHERE
        Related_Record_Id__c = :acct.Id
        AND Autonomous_Mode__c = TRUE
        AND Status__c = 'Escalated'
    ];
    snapshot.openRiskSignals = [
      SELECT COUNT()
      FROM Risk_Signal__c
      WHERE
        Account__c = :acct.Id
        AND Severity__c IN ('Critical', 'High', 'Medium')
    ];
    snapshot.openFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE
        Account__c = :acct.Id
        AND Status__c IN ('Open', 'Under Review', 'Escalated')
    ];
    snapshot.activeWorkflows = [
      SELECT COUNT()
      FROM Workflow_Execution__c
      WHERE Account__c = :acct.Id AND Status__c IN ('Queued', 'Running')
    ];
    return snapshot;
  }

  @AuraEnabled(cacheable=true)
  public static List<AutonomyItem> getRunQueue(Id accountId) {
    Account acct = validateAccount(accountId);
    List<AutonomyItem> items = new List<AutonomyItem>();
    for (AI_Agent_Run__c row : [
      SELECT Id, Agent_Name__c, Persona__c, Status__c, HITL_Status__c
      FROM AI_Agent_Run__c
      WHERE Related_Record_Id__c = :acct.Id AND Autonomous_Mode__c = TRUE
      ORDER BY CreatedDate DESC
      LIMIT 6
    ]) {
      AutonomyItem item = new AutonomyItem(
        String.valueOf(row.Id),
        row.Agent_Name__c + ' run',
        'Persona: ' +
          row.Persona__c +
          ', Status: ' +
          row.Status__c +
          ', HITL: ' +
          row.HITL_Status__c,
        row.HITL_Status__c == 'Pending'
          ? 'warning'
          : row.Status__c == 'Escalated' ? 'critical' : 'success'
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled(cacheable=true)
  public static List<AutonomyItem> getAutonomySignals(Id accountId) {
    Account acct = validateAccount(accountId);
    List<AutonomyItem> items = new List<AutonomyItem>();
    for (Risk_Signal__c row : [
      SELECT Id, Signal_Type__c, Severity__c, Summary__c
      FROM Risk_Signal__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 6
    ]) {
      AutonomyItem item = new AutonomyItem(
        String.valueOf(row.Id),
        row.Signal_Type__c + ' signal',
        abbreviate(row.Summary__c, 95),
        toTone(row.Severity__c)
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled
  public static AutonomyActionResult runAutonomousAdvisorAgent(Id accountId) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = startAutonomousRun(
      'Autonomous Advisor Agent',
      'Advisor',
      acct.Id,
      'Review household context, draft outreach, and queue recommendation.',
      true
    );
    AI_Recommendation__c rec = WealthAIStudioService.logRecommendation(
      runRecord.Id,
      acct.Id,
      'Outreach',
      'Autonomous advisor drafted proactive outreach for financial goal alignment.',
      'High',
      300000
    );
    finalizeRun(runRecord.Id, true);
    return actionResult(
      runRecord.Id,
      rec.Id,
      'Autonomous advisor run completed',
      'Outreach recommendation created and awaiting human approval.',
      'warning'
    );
  }

  @AuraEnabled
  public static AutonomyActionResult runAutonomousServiceAgent(Id accountId) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = startAutonomousRun(
      'Autonomous Service Agent',
      'Service',
      acct.Id,
      'Resolve routine request, draft response, and escalate exceptions.',
      false
    );
    Automation_Template__c template = ensureTemplate('Service');
    Workflow_Execution__c execution = new Workflow_Execution__c(
      Account__c = acct.Id,
      Automation_Template__c = template.Id,
      Status__c = 'Running',
      Details__c = 'Autonomous service flow is executing resolution steps.'
    );
    insert execution;
    WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Service',
      'Service agent autonomously resolved a routine client request.',
      81
    );
    finalizeRun(runRecord.Id, false);
    return actionResult(
      runRecord.Id,
      execution.Id,
      'Autonomous service run completed',
      'Service workflow executed without escalation.',
      'success'
    );
  }

  @AuraEnabled
  public static AutonomyActionResult runAutonomousOperationsAgent(
    Id accountId
  ) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = startAutonomousRun(
      'Autonomous Operations Agent',
      'Operations',
      acct.Id,
      'Orchestrate operational workflow and route exceptions.',
      false
    );
    Automation_Template__c template = ensureTemplate('Workflow');
    Workflow_Execution__c execution = new Workflow_Execution__c(
      Account__c = acct.Id,
      Automation_Template__c = template.Id,
      Status__c = 'Running',
      Details__c = 'Autonomous operations workflow launched with exception branch checks.'
    );
    insert execution;
    finalizeRun(runRecord.Id, false);
    return actionResult(
      runRecord.Id,
      execution.Id,
      'Autonomous operations run completed',
      'Operations workflow orchestration started.',
      'success'
    );
  }

  @AuraEnabled
  public static AutonomyActionResult runAutonomousComplianceAgent(
    Id accountId
  ) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = startAutonomousRun(
      'Autonomous Compliance Agent',
      'Compliance',
      acct.Id,
      'Monitor policy signals and produce audit-ready surveillance finding.',
      true
    );
    Compliance_Finding__c finding = new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = 'Surveillance',
      Status__c = 'Escalated',
      Reason_Detail__c = WamExplain.complianceFindingReason(
        'Surveillance',
        'Escalated'
      )
    );
    insert finding;
    finalizeRun(runRecord.Id, true);
    return actionResult(
      runRecord.Id,
      finding.Id,
      'Autonomous compliance run completed',
      'Escalated surveillance finding requires compliance officer approval.',
      'critical'
    );
  }

  @AuraEnabled
  public static AutonomyActionResult runAutonomousProspectingAgent(
    Id accountId
  ) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = startAutonomousRun(
      'Autonomous Prospecting Agent',
      'Distribution',
      acct.Id,
      'Research prospecting opportunities and score referral potential.',
      true
    );
    Decimal score = WamScoreEngine.clamp(
      62 + Math.mod(DateTime.now().millisecond(), 30),
      0,
      100
    );
    String priority = WamScoreEngine.toPriority(score);
    Referral_Prediction__c prediction = new Referral_Prediction__c(
      Account__c = acct.Id,
      Score__c = score,
      Priority__c = priority,
      Status__c = 'New',
      Notes__c = 'Autonomous prospecting generated a new outreach lead.'
    );
    insert prediction;
    finalizeRun(runRecord.Id, true);
    return actionResult(
      runRecord.Id,
      prediction.Id,
      'Autonomous prospecting run completed',
      'Prospecting lead created and queued for supervisor approval.',
      'warning'
    );
  }

  @AuraEnabled
  public static AutonomyActionResult runAIBranchManager(Id accountId) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = startAutonomousRun(
      'AI Branch Manager',
      'Executive',
      acct.Id,
      'Assess branch productivity and publish coaching priorities.',
      false
    );
    AI_Insight__c insight = WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Opportunity',
      'Branch manager insight published targeted coaching priorities for the team.',
      78
    );
    finalizeRun(runRecord.Id, false);
    return actionResult(
      runRecord.Id,
      insight.Id,
      'AI branch manager run completed',
      'Coaching insight delivered to leadership queue.',
      'neutral'
    );
  }

  @AuraEnabled
  public static AutonomyActionResult runAutonomousPortfolioMonitoring(
    Id accountId
  ) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = startAutonomousRun(
      'Autonomous Portfolio Monitor',
      'Portfolio',
      acct.Id,
      'Monitor portfolio drift and create proactive alerts.',
      false
    );
    Portfolio_Alert__c alert = new Portfolio_Alert__c(
      Account__c = acct.Id,
      Alert_Type__c = 'Drift',
      Severity__c = 'High',
      Reason_Detail__c = WamExplain.portfolioAlertReason('Drift', 'High', null)
    );
    insert alert;
    Risk_Signal__c signal = new Risk_Signal__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Signal_Type__c = 'Drift',
      Severity__c = 'High',
      Summary__c = 'Autonomous monitor detected drift beyond configured threshold.'
    );
    insert signal;
    finalizeRun(runRecord.Id, false);
    return actionResult(
      runRecord.Id,
      signal.Id,
      'Autonomous portfolio monitor completed',
      'Portfolio alert and risk signal generated for review.',
      'critical'
    );
  }

  @AuraEnabled
  public static AutonomyActionResult runHyperPersonalizedEngagement(
    Id accountId
  ) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = startAutonomousRun(
      'Hyper-Personalized Engagement Agent',
      'Advisor',
      acct.Id,
      'Generate personalized outreach moment and best-channel recommendation.',
      true
    );
    AI_Recommendation__c rec = WealthAIStudioService.logRecommendation(
      runRecord.Id,
      acct.Id,
      'Outreach',
      'Send personalized market update via preferred channel and schedule follow-up call.',
      'Medium',
      220000
    );
    WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Relationship',
      'Personalization engine aligned message tone with client preference profile.',
      82
    );
    finalizeRun(runRecord.Id, true);
    return actionResult(
      runRecord.Id,
      rec.Id,
      'Hyper-personalized engagement run completed',
      'Engagement recommendation queued for advisor approval.',
      'warning'
    );
  }

  private static AI_Agent_Run__c startAutonomousRun(
    String agentName,
    String persona,
    Id accountId,
    String planSummary,
    Boolean requiresApproval
  ) {
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      agentName,
      persona,
      accountId
    );
    update new AI_Agent_Run__c(
      Id = runRecord.Id,
      Autonomous_Mode__c = true,
      HITL_Status__c = requiresApproval ? 'Pending' : 'Not Required',
      Plan_Summary__c = planSummary
    );
    return runRecord;
  }

  private static void finalizeRun(Id runId, Boolean requiresApproval) {
    WealthAIStudioService.completeRun(
      runId,
      requiresApproval ? 'Escalated' : 'Success'
    );
  }

  private static AutonomyActionResult actionResult(
    Id runId,
    Id recordId,
    String title,
    String detail,
    String tone
  ) {
    AutonomyActionResult result = new AutonomyActionResult();
    result.runId = runId;
    result.recordId = recordId;
    result.title = title;
    result.detail = detail;
    result.tone = tone;
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

  private static Automation_Template__c ensureTemplate(String category) {
    String templateName = 'WAM ' + category + ' Template';
    List<Automation_Template__c> rows = [
      SELECT Id
      FROM Automation_Template__c
      WHERE Name = :templateName
      LIMIT 1
    ];
    if (!rows.isEmpty()) {
      return rows[0];
    }
    Automation_Template__c template = new Automation_Template__c(
      Name = templateName,
      Category__c = category,
      Instructions__c = 'Auto-generated template for autonomous ' +
        category +
        ' orchestration.'
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
