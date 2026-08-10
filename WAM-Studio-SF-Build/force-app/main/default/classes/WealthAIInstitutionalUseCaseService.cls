public with sharing class WealthAIInstitutionalUseCaseService {
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

  public class InstitutionalBookSnapshot {
    @AuraEnabled
    public Integer institutionCount;
    @AuraEnabled
    public Integer mandateBreaches;
    @AuraEnabled
    public Integer openFindings;
    @AuraEnabled
    public Integer activeWorkflows;
  }

  public class InstitutionalSnapshot {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Integer mandateCount;
    @AuraEnabled
    public Integer mandateBreaches;
    @AuraEnabled
    public Integer openProposals;
    @AuraEnabled
    public Integer openFindings;
    @AuraEnabled
    public Integer openRiskSignals;
    @AuraEnabled
    public Integer activeWorkflows;
  }

  public class StakeholderItem {
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
    public StakeholderItem(
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
  public static List<AccountOption> getInstitutionalAccountOptions() {
    Set<Id> parentIds = getAllParentAccountIds();
    List<AccountOption> options = new List<AccountOption>();
    for (Account acct : [
      SELECT Id, Name
      FROM Account
      WHERE RecordType.DeveloperName = 'Business' AND Id NOT IN :parentIds
      ORDER BY Name
      LIMIT 100
    ]) {
      options.add(new AccountOption(acct.Id, acct.Name));
    }
    return options;
  }

  @AuraEnabled(cacheable=true)
  public static InstitutionalBookSnapshot getInstitutionalBookSnapshot() {
    Set<Id> parentIds = getAllParentAccountIds();
    Set<Id> institutionIds = new Set<Id>();
    for (Account acct : [
      SELECT Id
      FROM Account
      WHERE RecordType.DeveloperName = 'Business' AND Id NOT IN :parentIds
    ]) {
      institutionIds.add(acct.Id);
    }

    InstitutionalBookSnapshot snapshot = new InstitutionalBookSnapshot();
    snapshot.institutionCount = institutionIds.size();
    snapshot.mandateBreaches = institutionIds.isEmpty()
      ? 0
      : [
          SELECT COUNT()
          FROM Institutional_Mandate__c
          WHERE Account__c IN :institutionIds AND Compliance_Status__c = 'Breach'
        ];
    snapshot.openFindings = institutionIds.isEmpty()
      ? 0
      : [
          SELECT COUNT()
          FROM Compliance_Finding__c
          WHERE Account__c IN :institutionIds AND Status__c IN ('Open', 'Escalated')
        ];
    snapshot.activeWorkflows = institutionIds.isEmpty()
      ? 0
      : [
          SELECT COUNT()
          FROM Workflow_Execution__c
          WHERE Account__c IN :institutionIds AND Status__c IN ('Queued', 'Running')
        ];
    return snapshot;
  }

  @AuraEnabled(cacheable=true)
  public static List<StakeholderItem> getInstitutionalPriorityQueue() {
    Set<Id> parentIds = getAllParentAccountIds();
    List<StakeholderItem> results = new List<StakeholderItem>();
    for (Institutional_Mandate__c row : [
      SELECT Id, Account__c, Account__r.Name, Mandate_Type__c, Breach_Detail__c
      FROM Institutional_Mandate__c
      WHERE Compliance_Status__c = 'Breach' AND Account__c NOT IN :parentIds
      ORDER BY Last_Reviewed__c DESC NULLS LAST
      LIMIT 6
    ]) {
      String acctName = row.Account__r == null
        ? 'Unknown institution'
        : row.Account__r.Name;
      String detail = String.isBlank(row.Breach_Detail__c)
        ? 'Escalate to the investment committee today.'
        : row.Breach_Detail__c;
      StakeholderItem item = new StakeholderItem(
        String.valueOf(row.Id),
        acctName + ': ' + row.Mandate_Type__c + ' mandate breach',
        detail,
        'critical'
      );
      item.accountId = row.Account__c;
      item.explanation = 'Mandate type "' +
        row.Mandate_Type__c +
        '" breached its compliance constraint: ' +
        detail;
      results.add(item);
    }
    return results;
  }

  @AuraEnabled(cacheable=true)
  public static InstitutionalSnapshot getInstitutionalSnapshot(Id accountId) {
    Account acct = validateInstitutionalAccount(accountId);
    InstitutionalSnapshot snapshot = new InstitutionalSnapshot();
    snapshot.accountId = acct.Id;
    snapshot.accountName = acct.Name;
    snapshot.mandateCount = [
      SELECT COUNT()
      FROM Institutional_Mandate__c
      WHERE Account__c = :acct.Id
    ];
    snapshot.mandateBreaches = [
      SELECT COUNT()
      FROM Institutional_Mandate__c
      WHERE Account__c = :acct.Id AND Compliance_Status__c = 'Breach'
    ];
    snapshot.openProposals = [
      SELECT COUNT()
      FROM AI_Recommendation__c
      WHERE
        Account__c = :acct.Id
        AND Recommendation_Type__c = 'Proposal'
        AND Status__c = 'New'
    ];
    snapshot.openFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE
        Account__c = :acct.Id
        AND Status__c IN ('Open', 'Escalated', 'Under Review')
    ];
    snapshot.openRiskSignals = [
      SELECT COUNT()
      FROM Risk_Signal__c
      WHERE
        Account__c = :acct.Id
        AND Severity__c IN ('Critical', 'High', 'Medium')
    ];
    snapshot.activeWorkflows = [
      SELECT COUNT()
      FROM Workflow_Execution__c
      WHERE Account__c = :acct.Id AND Status__c IN ('Queued', 'Running')
    ];
    return snapshot;
  }

  @AuraEnabled(cacheable=true)
  public static List<StakeholderItem> getInstitutionalStakeholders(
    Id accountId
  ) {
    Account acct = validateInstitutionalAccount(accountId);
    List<StakeholderItem> items = new List<StakeholderItem>();
    for (AccountContactRelation row : [
      SELECT ContactId, Contact.Name, Roles, IsActive
      FROM AccountContactRelation
      WHERE AccountId = :acct.Id
      ORDER BY Contact.Name
      LIMIT 10
    ]) {
      StakeholderItem item = new StakeholderItem(
        String.valueOf(row.ContactId),
        row.Contact.Name,
        'Role: ' +
          (String.isBlank(row.Roles) ? 'Stakeholder' : row.Roles) +
          (row.IsActive ? '' : ' (Inactive)'),
        row.IsActive ? 'success' : 'neutral'
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled
  public static ActionResult runMandateComplianceCheck(Id accountId) {
    Account acct = validateInstitutionalAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Institutional Relationship Agent',
      'Institutional',
      acct.Id
    );
    Integer breachSignals = [
      SELECT COUNT()
      FROM Risk_Signal__c
      WHERE Account__c = :acct.Id AND Severity__c IN ('Critical', 'High')
    ];
    String complianceStatus = breachSignals > 0 ? 'Breach' : 'Compliant';

    Institutional_Mandate__c mandate = new Institutional_Mandate__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Mandate_Type__c = 'Investment Policy Statement',
      Compliance_Status__c = complianceStatus,
      Breach_Detail__c = complianceStatus == 'Breach'
        ? breachSignals +
          ' open high/critical risk signal(s) exceed IPS tolerance.'
        : null,
      Last_Reviewed__c = DateTime.now()
    );
    insert mandate;
    WealthAIStudioService.completeRun(
      runRecord.Id,
      complianceStatus == 'Breach' ? 'Escalated' : 'Success'
    );

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = mandate.Id;
    result.title = 'Mandate compliance check completed';
    result.detail = 'Compliance status: ' + complianceStatus;
    result.tone = complianceStatus == 'Breach' ? 'critical' : 'success';
    return result;
  }

  @AuraEnabled
  public static ActionResult runInstitutionalProposalCopilot(Id accountId) {
    Account acct = validateInstitutionalAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Institutional Relationship Agent',
      'Institutional',
      acct.Id
    );
    String detail = 'Draft institutional proposal generated with mandate-aligned allocation and fee structure.';
    AI_Recommendation__c rec = WealthAIStudioService.logRecommendation(
      runRecord.Id,
      acct.Id,
      'Proposal',
      detail,
      'High',
      1500000
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = rec.Id;
    result.title = 'Institutional proposal drafted';
    result.detail = detail;
    result.tone = 'success';
    return result;
  }

  @AuraEnabled
  public static ActionResult generateCommitteeReport(Id accountId) {
    Account acct = validateInstitutionalAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Institutional Relationship Agent',
      'Institutional',
      acct.Id
    );
    InstitutionalSnapshot snapshot = getInstitutionalSnapshot(acct.Id);
    String summary =
      'Committee report for ' +
      acct.Name +
      ': ' +
      snapshot.mandateCount +
      ' mandate(s) tracked, ' +
      snapshot.mandateBreaches +
      ' breach(es), ' +
      snapshot.openProposals +
      ' open proposal(s), ' +
      snapshot.openFindings +
      ' open finding(s).';

    Advisor_Briefing__c briefing = new Advisor_Briefing__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Briefing_Date__c = Date.today(),
      Briefing_Summary__c = summary,
      Priority__c = snapshot.mandateBreaches > 0 ? 'High' : 'Medium'
    );
    insert briefing;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = briefing.Id;
    result.title = 'Committee report generated';
    result.detail = summary;
    result.tone = snapshot.mandateBreaches > 0 ? 'warning' : 'success';
    return result;
  }

  @AuraEnabled
  public static ActionResult runInstitutionalKYBOnboarding(Id accountId) {
    Account acct = validateInstitutionalAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Institutional Relationship Agent',
      'Institutional',
      acct.Id
    );
    Compliance_Finding__c finding = new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = 'KYC',
      Status__c = 'Open'
    );
    insert finding;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = finding.Id;
    result.title = 'Institutional KYB onboarding checklist created';
    result.detail = 'Know-Your-Business documentation review opened for onboarding.';
    result.tone = 'warning';
    return result;
  }

  @AuraEnabled
  public static ActionResult runInstitutionalRiskSurveillance(Id accountId) {
    Account acct = validateInstitutionalAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Institutional Relationship Agent',
      'Institutional',
      acct.Id
    );
    Risk_Signal__c signal = new Risk_Signal__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Signal_Type__c = 'Concentration',
      Severity__c = 'Medium',
      Summary__c = 'Institutional concentration surveillance flagged a sector exposure above policy threshold.'
    );
    insert signal;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = signal.Id;
    result.title = 'Institutional risk surveillance completed';
    result.detail = signal.Summary__c;
    result.tone = 'warning';
    return result;
  }

  @AuraEnabled
  public static ActionResult runInstitutionalLiquidityForecast(Id accountId) {
    Account acct = validateInstitutionalAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Institutional Relationship Agent',
      'Institutional',
      acct.Id
    );
    Risk_Signal__c signal = new Risk_Signal__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Signal_Type__c = 'Cash Movement',
      Severity__c = 'Low',
      Summary__c = 'Liquidity forecast projects cash flow needs are within mandate tolerance for the next quarter.'
    );
    insert signal;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = signal.Id;
    result.title = 'Liquidity forecast completed';
    result.detail = signal.Summary__c;
    result.tone = 'success';
    return result;
  }

  @AuraEnabled
  public static ActionResult runAutonomousInstitutionalMonitoring(
    Id accountId
  ) {
    Account acct = validateInstitutionalAccount(accountId);
    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Autonomous Institutional Monitor',
      'Institutional',
      acct.Id
    );
    update new AI_Agent_Run__c(
      Id = runRecord.Id,
      Autonomous_Mode__c = true,
      HITL_Status__c = 'Pending',
      Plan_Summary__c = 'Continuously monitor mandate compliance and portfolio risk; escalate breaches for RM approval.'
    );
    Risk_Signal__c signal = new Risk_Signal__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Signal_Type__c = 'Concentration',
      Severity__c = 'High',
      Summary__c = 'Autonomous monitor detected a concentration signal requiring relationship manager sign-off.'
    );
    insert signal;
    WealthAIStudioService.completeRun(runRecord.Id, 'Escalated');

    ActionResult result = new ActionResult();
    result.runId = runRecord.Id;
    result.recordId = signal.Id;
    result.title = 'Autonomous institutional monitoring run completed';
    result.detail = 'Risk signal created and awaiting relationship manager approval.';
    result.tone = 'warning';
    return result;
  }

  public static Id resolveInstitutionalAccountId(String accountName) {
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
        AND Id NOT IN :parentIds
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

  private static Account validateInstitutionalAccount(Id accountId) {
    if (accountId == null) {
      throw new AuraHandledException(
        'Select an institutional account to continue.'
      );
    }
    List<Account> rows = [
      SELECT Id, Name
      FROM Account
      WHERE Id = :accountId AND RecordType.DeveloperName = 'Business'
      LIMIT 1
    ];
    if (rows.isEmpty()) {
      throw new AuraHandledException(
        'Institutional (Business) account not found.'
      );
    }
    return rows[0];
  }
}
