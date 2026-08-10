public with sharing class WealthAIPortfolioUseCaseService {
  public class PortfolioSnapshot {
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Decimal healthScore;
    @AuraEnabled
    public Integer openAlerts;
    @AuraEnabled
    public Integer openRiskSignals;
  }

  public class PortfolioItem {
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
    public PortfolioItem(
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

  public class PortfolioActionResult {
    @AuraEnabled
    public Id runId;
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String detail;
    @AuraEnabled
    public String severity;
  }

  @AuraEnabled(cacheable=true)
  public static PortfolioSnapshot getPortfolioSnapshot(Id accountId) {
    Account acct = validateAccount(accountId);
    PortfolioSnapshot snapshot = new PortfolioSnapshot();
    snapshot.accountId = acct.Id;
    snapshot.accountName = acct.Name;
    snapshot.openAlerts = [
      SELECT COUNT()
      FROM Portfolio_Alert__c
      WHERE Account__c = :acct.Id
    ];
    snapshot.openRiskSignals = [
      SELECT COUNT()
      FROM Risk_Signal__c
      WHERE Account__c = :acct.Id
    ];
    List<Client_Health_Score__c> healthRows = [
      SELECT Score__c
      FROM Client_Health_Score__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    snapshot.healthScore = healthRows.isEmpty() ? null : healthRows[0].Score__c;
    return snapshot;
  }

  @AuraEnabled(cacheable=true)
  public static List<PortfolioItem> getLatestPortfolioAlerts(Id accountId) {
    Account acct = validateAccount(accountId);
    List<PortfolioItem> items = new List<PortfolioItem>();
    for (Portfolio_Alert__c alert : [
      SELECT Id, Alert_Type__c, Severity__c
      FROM Portfolio_Alert__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      PortfolioItem item = new PortfolioItem(
        String.valueOf(alert.Id),
        alert.Alert_Type__c + ' alert',
        'Severity: ' + alert.Severity__c,
        toTone(alert.Severity__c)
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled(cacheable=true)
  public static List<PortfolioItem> getLatestRiskSignals(Id accountId) {
    Account acct = validateAccount(accountId);
    List<PortfolioItem> items = new List<PortfolioItem>();
    for (Risk_Signal__c signal : [
      SELECT Id, Signal_Type__c, Severity__c, Summary__c
      FROM Risk_Signal__c
      WHERE Account__c = :acct.Id
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      PortfolioItem item = new PortfolioItem(
        String.valueOf(signal.Id),
        signal.Signal_Type__c + ' signal',
        String.isBlank(signal.Summary__c)
          ? 'No additional context.'
          : abbreviate(signal.Summary__c, 100),
        toTone(signal.Severity__c)
      );
      item.accountId = acct.Id;
      items.add(item);
    }
    return items;
  }

  @AuraEnabled
  public static PortfolioActionResult runPortfolioHealthAnalyzer(Id accountId) {
    Account acct = validateAccount(accountId);
    PortfolioSnapshot snapshot = getPortfolioSnapshot(acct.Id);
    String severity = snapshot.healthScore != null &&
      snapshot.healthScore < 55
      ? 'Critical'
      : snapshot.healthScore != null &&
          snapshot.healthScore < 70
          ? 'High'
          : 'Medium';

    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Portfolio Agent',
      'Portfolio',
      acct.Id
    );
    Portfolio_Alert__c alert = new Portfolio_Alert__c(
      Account__c = acct.Id,
      Alert_Type__c = 'Drift',
      Severity__c = severity
    );
    insert alert;
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    PortfolioActionResult result = new PortfolioActionResult();
    result.runId = runRecord.Id;
    result.recordId = alert.Id;
    result.title = 'Portfolio health analyzed';
    result.detail =
      'Created drift alert for ' +
      acct.Name +
      ' with severity ' +
      severity +
      '.';
    result.severity = severity;
    return result;
  }

  @AuraEnabled
  public static PortfolioActionResult runPortfolioReviewCopilot(Id accountId) {
    Account acct = validateAccount(accountId);
    PortfolioSnapshot snapshot = getPortfolioSnapshot(acct.Id);
    String reviewSummary =
      'Portfolio review for ' +
      acct.Name +
      ': open alerts=' +
      snapshot.openAlerts +
      ', open risk signals=' +
      snapshot.openRiskSignals +
      ', client health=' +
      (snapshot.healthScore == null
        ? '-'
        : String.valueOf(snapshot.healthScore.setScale(0))) +
      '.';

    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Portfolio Agent',
      'Portfolio',
      acct.Id
    );
    AI_Insight__c insight = WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Portfolio',
      reviewSummary,
      86
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    PortfolioActionResult result = new PortfolioActionResult();
    result.runId = runRecord.Id;
    result.recordId = insight.Id;
    result.title = 'Portfolio review generated';
    result.detail = reviewSummary;
    result.severity = 'Medium';
    return result;
  }

  @AuraEnabled
  public static PortfolioActionResult runPortfolioCommentaryGenerator(
    Id accountId
  ) {
    Account acct = validateAccount(accountId);
    PortfolioSnapshot snapshot = getPortfolioSnapshot(acct.Id);
    String commentary =
      'Commentary: portfolio posture remains ' +
      (snapshot.openAlerts > 1 ? 'elevated' : 'stable') +
      ', with ' +
      snapshot.openAlerts +
      ' active alert(s) and ' +
      snapshot.openRiskSignals +
      ' risk signal(s).';

    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Portfolio Agent',
      'Portfolio',
      acct.Id
    );
    AI_Insight__c insight = WealthAIStudioService.logInsight(
      runRecord.Id,
      acct.Id,
      'Portfolio',
      commentary,
      84
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    PortfolioActionResult result = new PortfolioActionResult();
    result.runId = runRecord.Id;
    result.recordId = insight.Id;
    result.title = 'Portfolio commentary generated';
    result.detail = commentary;
    result.severity = 'Low';
    return result;
  }

  @AuraEnabled
  public static PortfolioActionResult runRiskExposureDetection(Id accountId) {
    Account acct = validateAccount(accountId);
    PortfolioSnapshot snapshot = getPortfolioSnapshot(acct.Id);
    String severity = snapshot.openAlerts >= 2 ? 'Critical' : 'High';
    String signalType = snapshot.openAlerts >= 2
      ? 'Concentration'
      : 'Volatility';
    String summary =
      'Exposure signal raised from portfolio analyzer. Open alerts=' +
      snapshot.openAlerts +
      '.';

    AI_Agent_Run__c runRecord = WealthAIStudioService.startRun(
      'Portfolio Agent',
      'Portfolio',
      acct.Id
    );
    Risk_Signal__c signal = new Risk_Signal__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runRecord.Id,
      Signal_Type__c = signalType,
      Severity__c = severity,
      Summary__c = summary
    );
    insert signal;
    insert new Portfolio_Alert__c(
      Account__c = acct.Id,
      Alert_Type__c = 'Risk',
      Severity__c = severity
    );
    WealthAIStudioService.completeRun(runRecord.Id, 'Success');

    PortfolioActionResult result = new PortfolioActionResult();
    result.runId = runRecord.Id;
    result.recordId = signal.Id;
    result.title = 'Risk exposure detected';
    result.detail = summary;
    result.severity = severity;
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

  private static String toTone(String severity) {
    if (severity == 'Critical' || severity == 'High') {
      return 'critical';
    }
    if (severity == 'Medium') {
      return 'warning';
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
