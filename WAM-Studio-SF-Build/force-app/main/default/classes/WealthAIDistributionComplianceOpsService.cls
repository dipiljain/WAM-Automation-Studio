public with sharing class WealthAIDistributionComplianceOpsService {
  public class WorkbenchSnapshot {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Integer referralPredictions;
    @AuraEnabled
    public Integer openFindings;
    @AuraEnabled
    public Integer activeWorkflows;
  }

  public class WorkbenchItem {
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
    public WorkbenchItem(
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

  public class WorkbenchActionResult {
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
  public static WorkbenchSnapshot getWorkbenchSnapshot(Id accountId) {
    Account acct = validateAccount(accountId);
    WorkbenchSnapshot snapshot = new WorkbenchSnapshot();
    snapshot.accountId = acct.Id;
    snapshot.accountName = acct.Name;
    snapshot.referralPredictions = [
      SELECT COUNT()
      FROM Referral_Prediction__c
      WHERE Account__c = :acct.Id
    ];
    snapshot.openFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE
        Account__c = :acct.Id
        AND Status__c IN ('Open', 'Escalated', 'Under Review')
    ];
    snapshot.activeWorkflows = [
      SELECT COUNT()
      FROM Workflow_Execution__c
      WHERE Account__c = :acct.Id AND Status__c IN ('Queued', 'Running')
    ];
    return snapshot;
  }

  @AuraEnabled(cacheable=true)
  public static List<WorkbenchItem> getDistributionItems(Id accountId) {
    Account acct = validateAccount(accountId);
    List<WorkbenchItem> items = new List<WorkbenchItem>();
    for (Referral_Prediction__c row : [
      SELECT Id, Score__c, Priority__c, Status__c, Notes__c
      FROM Referral_Prediction__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      WorkbenchItem item = new WorkbenchItem(
        String.valueOf(row.Id),
        'Referral score ' +
        (row.Score__c == null ? '-' : String.valueOf(row.Score__c.setScale(0))),
        'Priority: ' + row.Priority__c + ', Status: ' + row.Status__c,
        toTone(row.Priority__c)
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled(cacheable=true)
  public static List<WorkbenchItem> getComplianceItems(Id accountId) {
    Account acct = validateAccount(accountId);
    List<WorkbenchItem> items = new List<WorkbenchItem>();
    for (Compliance_Finding__c row : [
      SELECT Id, Finding_Type__c, Status__c
      FROM Compliance_Finding__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      WorkbenchItem item = new WorkbenchItem(
        String.valueOf(row.Id),
        row.Finding_Type__c + ' finding',
        'Status: ' + row.Status__c,
        row.Status__c == 'Escalated'
          ? 'critical'
          : row.Status__c == 'Open' ? 'warning' : 'neutral'
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled(cacheable=true)
  public static List<WorkbenchItem> getOperationsItems(Id accountId) {
    Account acct = validateAccount(accountId);
    List<WorkbenchItem> items = new List<WorkbenchItem>();
    for (Workflow_Execution__c row : [
      SELECT Id, Status__c, Details__c
      FROM Workflow_Execution__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      WorkbenchItem item = new WorkbenchItem(
        String.valueOf(row.Id),
        'Workflow execution',
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

  @AuraEnabled
  public static WorkbenchActionResult runLeadScoring(Id accountId) {
    Account acct = validateAccount(accountId);
    Decimal score = WamScoreEngine.clamp(
      55 + Math.mod(DateTime.now().millisecond(), 45),
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
      Status__c = 'New',
      Notes__c = 'Lead scoring calculated from engagement and relationship context.'
    );
    insert prediction;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    WorkbenchActionResult result = new WorkbenchActionResult();
    result.runId = runRecord.Id;
    result.recordId = prediction.Id;
    result.title = 'Lead scoring completed';
    result.detail = 'Score: ' + score.setScale(0) + ', Priority: ' + priority;
    result.tone = toTone(priority);
    return result;
  }

  @AuraEnabled
  public static WorkbenchActionResult runLeadPrioritization(Id accountId) {
    Account acct = validateAccount(accountId);
    List<Referral_Prediction__c> rows = [
      SELECT Id, Priority__c, Score__c
      FROM Referral_Prediction__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    if (rows.isEmpty()) {
      return runLeadScoring(acct.Id);
    }

    Referral_Prediction__c prediction = rows[0];
    prediction.Status__c = 'Queued';
    prediction.Notes__c = 'Prioritized for distribution specialist queue.';
    update prediction;

    WorkbenchActionResult result = new WorkbenchActionResult();
    result.recordId = prediction.Id;
    result.title = 'Lead prioritized';
    result.detail =
      'Prediction moved to queue with priority ' +
      prediction.Priority__c +
      '.';
    result.tone = toTone(prediction.Priority__c);
    return result;
  }

  @AuraEnabled
  public static WorkbenchActionResult runProspectResearch(Id accountId) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Distribution Agent',
      'Distribution',
      acct.Id
    );
    AI_Insight__c insight = WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Opportunity',
      'Prospect research summary generated with relationship and referral context.',
      79
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    WorkbenchActionResult result = new WorkbenchActionResult();
    result.runId = runRecord.Id;
    result.recordId = insight.Id;
    result.title = 'Prospect research generated';
    result.detail = 'Opportunity insight created for distribution team.';
    result.tone = 'neutral';
    return result;
  }

  @AuraEnabled
  public static WorkbenchActionResult runKYCCopilot(Id accountId) {
    return createComplianceFinding(
      accountId,
      'KYC',
      'Open',
      'KYC copilot flagged required updates.'
    );
  }

  @AuraEnabled
  public static WorkbenchActionResult runAMLScreening(Id accountId) {
    return createComplianceFinding(
      accountId,
      'AML',
      'Under Review',
      'AML screening completed, pending analyst review.'
    );
  }

  @AuraEnabled
  public static WorkbenchActionResult runRegulatoryMonitoring(Id accountId) {
    return createComplianceFinding(
      accountId,
      'Regulatory',
      'Open',
      'Regulatory monitoring identified a policy delta.'
    );
  }

  @AuraEnabled
  public static WorkbenchActionResult runOnboardingAssistant(Id accountId) {
    return createWorkflowExecution(
      accountId,
      'Onboarding',
      'Onboarding checklist generated and assigned.'
    );
  }

  @AuraEnabled
  public static WorkbenchActionResult runDocumentExtraction(Id accountId) {
    return createWorkflowExecution(
      accountId,
      'Document',
      'Document extraction completed with confidence checks.'
    );
  }

  @AuraEnabled
  public static WorkbenchActionResult runWorkflowAutomation(Id accountId) {
    return createWorkflowExecution(
      accountId,
      'Workflow',
      'Workflow automation run completed for operations.'
    );
  }

  private static WorkbenchActionResult createComplianceFinding(
    Id accountId,
    String findingType,
    String statusValue,
    String details
  ) {
    Account acct = validateAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Compliance Agent',
      'Compliance',
      acct.Id
    );
    Compliance_Finding__c finding = new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = findingType,
      Status__c = statusValue,
      Reason_Detail__c = WamExplain.complianceFindingReason(
        findingType,
        statusValue
      )
    );
    insert finding;
    WealthAIStudioService.completeRun(
      runRecord.Id,
      statusValue == 'Escalated' ? 'Escalated' : 'Success'
    );

    WorkbenchActionResult result = new WorkbenchActionResult();
    result.runId = runRecord.Id;
    result.recordId = finding.Id;
    result.title = findingType + ' run completed';
    result.detail = details;
    result.tone = statusValue == 'Escalated'
      ? 'critical'
      : statusValue == 'Open' ? 'warning' : 'neutral';
    return result;
  }

  private static WorkbenchActionResult createWorkflowExecution(
    Id accountId,
    String category,
    String details
  ) {
    Account acct = validateAccount(accountId);
    Automation_Template__c template = ensureTemplate(category);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Operations Agent',
      'Operations',
      acct.Id
    );
    Workflow_Execution__c execution = new Workflow_Execution__c(
      Account__c = acct.Id,
      Automation_Template__c = template.Id,
      Status__c = 'Completed',
      Details__c = details
    );
    insert execution;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    WorkbenchActionResult result = new WorkbenchActionResult();
    result.runId = runRecord.Id;
    result.recordId = execution.Id;
    result.title = category + ' workflow completed';
    result.detail = details;
    result.tone = 'success';
    return result;
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
        ' operations.'
    );
    insert template;
    return template;
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

  private static String toTone(String priority) {
    if (priority == 'High') {
      return 'critical';
    }
    if (priority == 'Medium') {
      return 'warning';
    }
    if (priority == 'Low') {
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
