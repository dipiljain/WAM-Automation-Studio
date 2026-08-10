public with sharing class WealthAIHomeController {
  public class Metric {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String display;
    @AuraEnabled
    public String tone;
    public Metric(String label, String display, String tone) {
      this.label = label;
      this.display = display;
      this.tone = tone;
    }
  }

  public class FeedItem {
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
    public FeedItem(String key, String title, String subtitle, String tone) {
      this.key = key;
      this.title = title;
      this.subtitle = subtitle;
      this.tone = tone;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Metric> getAdvisorMetrics() {
    Integer highRecs = [
      SELECT COUNT()
      FROM AI_Recommendation__c
      WHERE Priority__c = 'High' AND Status__c = 'New'
    ];
    Integer newInsights = [
      SELECT COUNT()
      FROM AI_Insight__c
      WHERE Status__c = 'New'
    ];
    Integer briefingsToday = [
      SELECT COUNT()
      FROM Advisor_Briefing__c
      WHERE CreatedDate = TODAY
    ];
    Integer atRisk = [
      SELECT COUNT()
      FROM Client_Health_Score__c
      WHERE Score__c < 50
    ];
    return new List<Metric>{
      new Metric(
        'High-Priority Recommendations',
        String.valueOf(highRecs),
        highRecs > 0 ? 'warning' : 'neutral'
      ),
      new Metric('New AI Insights', String.valueOf(newInsights), 'neutral'),
      new Metric('Briefings Today', String.valueOf(briefingsToday), 'neutral'),
      new Metric(
        'At-Risk Clients',
        String.valueOf(atRisk),
        atRisk > 0 ? 'critical' : 'success'
      )
    };
  }

  @AuraEnabled(cacheable=true)
  public static List<Metric> getComplianceMetrics() {
    Integer openFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE Status__c = 'Open'
    ];
    Integer escalated = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE Status__c = 'Escalated'
    ];
    Integer criticalAlerts = [
      SELECT COUNT()
      FROM Portfolio_Alert__c
      WHERE Severity__c IN ('Critical', 'High')
    ];
    Integer riskSignals = [SELECT COUNT() FROM Risk_Signal__c];
    return new List<Metric>{
      new Metric(
        'Open Findings',
        String.valueOf(openFindings),
        openFindings > 0 ? 'warning' : 'success'
      ),
      new Metric(
        'Escalated Findings',
        String.valueOf(escalated),
        escalated > 0 ? 'critical' : 'success'
      ),
      new Metric(
        'Critical / High Alerts',
        String.valueOf(criticalAlerts),
        criticalAlerts > 0 ? 'critical' : 'success'
      ),
      new Metric('Open Risk Signals', String.valueOf(riskSignals), 'neutral')
    };
  }

  @AuraEnabled(cacheable=true)
  public static List<Metric> getExecutiveMetrics() {
    Integer totalRuns = [SELECT COUNT() FROM AI_Agent_Run__c];
    Integer completedRuns = [
      SELECT COUNT()
      FROM AI_Agent_Run__c
      WHERE Status__c = 'Success'
    ];
    AggregateResult pipelineAgg = [
      SELECT SUM(Expected_Value__c) total
      FROM AI_Recommendation__c
      WHERE Status__c = 'New'
    ];
    Decimal pipeline = (Decimal) pipelineAgg.get('total');
    AggregateResult healthAgg = [
      SELECT AVG(Score__c) avgScore
      FROM Client_Health_Score__c
    ];
    Decimal avgHealth = (Decimal) healthAgg.get('avgScore');
    Integer openFindings = [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE Status__c IN ('Open', 'Escalated')
    ];
    return new List<Metric>{
      new Metric('AI Pipeline Value', formatCurrency(pipeline), 'success'),
      new Metric(
        'Agent Runs (Success)',
        completedRuns + ' / ' + totalRuns,
        'neutral'
      ),
      new Metric(
        'Avg Client Health',
        avgHealth == null ? '-' : String.valueOf(avgHealth.setScale(0)),
        avgHealth != null && avgHealth < 60 ? 'warning' : 'success'
      ),
      new Metric(
        'Open Compliance Findings',
        String.valueOf(openFindings),
        openFindings > 0 ? 'warning' : 'success'
      )
    };
  }

  @AuraEnabled(cacheable=true)
  public static List<FeedItem> getAdvisorInsights() {
    List<FeedItem> results = new List<FeedItem>();
    for (AI_Insight__c insight : [
      SELECT Id, Account__c, Insight_Type__c, Summary__c, Status__c, Confidence__c
      FROM AI_Insight__c
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      String title = String.isBlank(insight.Insight_Type__c)
        ? 'Insight'
        : insight.Insight_Type__c + ' insight';
      FeedItem item = new FeedItem(
        String.valueOf(insight.Id),
        title,
        abbreviate(insight.Summary__c, 110),
        insight.Status__c == 'New' ? 'warning' : 'neutral'
      );
      item.accountId = insight.Account__c;
      item.explanation = 'Confidence ' +
        (insight.Confidence__c == null
          ? '—'
          : insight.Confidence__c.setScale(0) + '%') +
        ' based on patterns detected in recent account activity and portfolio data.';
      results.add(item);
    }
    return results;
  }

  @AuraEnabled(cacheable=true)
  public static List<FeedItem> getAdvisorRecommendations() {
    List<FeedItem> results = new List<FeedItem>();
    for (AI_Recommendation__c rec : [
      SELECT
        Id,
        Recommendation_Type__c,
        Recommended_Action__c,
        Priority__c,
        Expected_Value__c,
        Account__c,
        Account__r.Name
      FROM AI_Recommendation__c
      WHERE Status__c = 'New'
      ORDER BY CreatedDate DESC
      LIMIT 5
    ]) {
      String title = String.isBlank(rec.Recommendation_Type__c)
        ? 'Recommendation'
        : rec.Recommendation_Type__c + ' recommendation';
      String context = String.isBlank(
          rec.Account__r == null ? null : rec.Account__r.Name
        )
        ? ''
        : rec.Account__r.Name + ': ';
      String tone = rec.Priority__c == 'High'
        ? 'critical'
        : rec.Priority__c == 'Medium' ? 'warning' : 'neutral';
      FeedItem item = new FeedItem(
        String.valueOf(rec.Id),
        title,
        context + abbreviate(rec.Recommended_Action__c, 110),
        tone
      );
      item.accountId = rec.Account__c;
      item.explanation = 'Priority set to ' +
        (String.isBlank(rec.Priority__c) ? 'Low' : rec.Priority__c) +
        ' based on an expected value of ' +
        formatCurrency(rec.Expected_Value__c) +
        ' and current account engagement signals.';
      results.add(item);
    }
    return results;
  }

  @AuraEnabled(cacheable=true)
  public static List<FeedItem> getAdvisorPriorityQueue() {
    List<FeedItem> results = new List<FeedItem>();
    for (Client_Health_Score__c row : [
      SELECT Account__c, Account__r.Name, Score__c
      FROM Client_Health_Score__c
      WHERE Score__c < 60
      ORDER BY Score__c ASC
      LIMIT 6
    ]) {
      String tone = row.Score__c < 40 ? 'critical' : 'warning';
      String acctName = row.Account__r == null
        ? 'Unknown client'
        : row.Account__r.Name;
      FeedItem item = new FeedItem(
        String.valueOf(row.Account__c),
        acctName,
        'Health score ' +
          row.Score__c.setScale(0) +
          ' — prioritize outreach today.',
        tone
      );
      item.accountId = row.Account__c;
      item.explanation = 'Health score of ' +
        row.Score__c.setScale(0) +
        ' is below the 60-point healthy threshold, driven by declining engagement or portfolio signals for this client.';
      results.add(item);
    }
    return results;
  }

  @AuraEnabled(cacheable=true)
  public static List<FeedItem> getComplianceQueue() {
    List<Compliance_Finding__c> rows = new List<Compliance_Finding__c>(
      [
        SELECT Id, Account__c, Account__r.Name, Finding_Type__c, Status__c
        FROM Compliance_Finding__c
        WHERE Status__c = 'Escalated'
        ORDER BY CreatedDate DESC
        LIMIT 6
      ]
    );
    if (rows.size() < 6) {
      rows.addAll(
        [
          SELECT Id, Account__c, Account__r.Name, Finding_Type__c, Status__c
          FROM Compliance_Finding__c
          WHERE Status__c = 'Open'
          ORDER BY CreatedDate DESC
          LIMIT :(6 - rows.size())
        ]
      );
    }
    List<FeedItem> results = new List<FeedItem>();
    for (Compliance_Finding__c row : rows) {
      String acctName = row.Account__r == null
        ? 'Unknown client'
        : row.Account__r.Name;
      String tone = row.Status__c == 'Escalated' ? 'critical' : 'warning';
      FeedItem item = new FeedItem(
        String.valueOf(row.Id),
        acctName + ': ' + row.Finding_Type__c,
        'Status: ' +
          row.Status__c +
          ' — review and action before end of day.',
        tone
      );
      item.accountId = row.Account__c;
      item.explanation = row.Status__c == 'Escalated'
        ? 'This finding remains escalated until compliance formally signs off on remediation.'
        : 'Findings of this type are auto-flagged when opened and unresolved past the policy SLA.';
      results.add(item);
    }
    return results;
  }

  @AuraEnabled(cacheable=true)
  public static List<FeedItem> getExecutiveApprovalQueue() {
    List<FeedItem> results = new List<FeedItem>();
    for (AI_Agent_Run__c row : [
      SELECT Id, Agent_Name__c, Persona__c, Plan_Summary__c, Related_Record_Id__c
      FROM AI_Agent_Run__c
      WHERE HITL_Status__c = 'Pending'
      ORDER BY CreatedDate DESC
      LIMIT 6
    ]) {
      FeedItem item = new FeedItem(
        String.valueOf(row.Id),
        (String.isBlank(row.Agent_Name__c) ? 'Agent' : row.Agent_Name__c) +
          ' awaiting approval',
        abbreviate(row.Plan_Summary__c, 110),
        'warning'
      );
      item.explanation = 'This ' +
        (String.isBlank(row.Persona__c) ? 'agent' : row.Persona__c) +
        ' run requires human approval because its recommended action exceeds the autonomy threshold configured for this persona.';
      if (String.isNotBlank(row.Related_Record_Id__c)) {
        try {
          item.accountId = Id.valueOf(row.Related_Record_Id__c);
        } catch (Exception ex) {
          item.accountId = null;
        }
      }
      results.add(item);
    }
    return results;
  }

  private static String formatCurrency(Decimal value) {
    Decimal v = value == null ? 0 : value;
    return '$' + v.setScale(0).format();
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
