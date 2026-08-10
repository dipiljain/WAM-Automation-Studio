@isTest
private class WealthAIHomeControllerTest {
  @testSetup
  static void setup() {
    Account acct = WamTestDataFactory.createHousehold('Test Household');

    AI_Recommendation__c rec = WamTestDataFactory.createRecommendation(
      acct.Id,
      'High'
    );
    rec.Recommendation_Type__c = 'Compliance';
    rec.Expected_Value__c = 750000;
    update rec;

    insert new AI_Insight__c(
      Account__c = acct.Id,
      Insight_Type__c = 'Opportunity',
      Summary__c = 'Test',
      Confidence__c = 90,
      Status__c = 'New'
    );
    insert new Advisor_Briefing__c();
    insert new Client_Health_Score__c(Account__c = acct.Id, Score__c = 40);
    insert new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = 'KYC',
      Status__c = 'Open'
    );
    insert new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = 'AML',
      Status__c = 'Escalated'
    );
    insert new Portfolio_Alert__c(
      Account__c = acct.Id,
      Alert_Type__c = 'Drift',
      Severity__c = 'Critical'
    );
    insert new Risk_Signal__c(Account__c = acct.Id);
    WamTestDataFactory.createAgentRun('Success');
  }

  @isTest
  static void advisorMetrics() {
    Test.startTest();
    List<WealthAIHomeController.Metric> m = WealthAIHomeController.getAdvisorMetrics();
    Test.stopTest();
    System.assertEquals(4, m.size(), 'Expected four advisor metrics');
  }

  @isTest
  static void complianceMetrics() {
    Test.startTest();
    List<WealthAIHomeController.Metric> m = WealthAIHomeController.getComplianceMetrics();
    Test.stopTest();
    System.assertEquals(4, m.size(), 'Expected four compliance metrics');
  }

  @isTest
  static void executiveMetrics() {
    Test.startTest();
    List<WealthAIHomeController.Metric> m = WealthAIHomeController.getExecutiveMetrics();
    Test.stopTest();
    System.assertEquals(4, m.size(), 'Expected four executive metrics');
    System.assertEquals(
      'Agent Runs (Success)',
      m[1].label,
      'Should use valid run status label.'
    );
  }

  @isTest
  static void advisorInsightsFeed() {
    Test.startTest();
    List<WealthAIHomeController.FeedItem> items = WealthAIHomeController.getAdvisorInsights();
    Test.stopTest();
    System.assert(items.size() > 0, 'Expected at least one insight item');
    System.assertEquals(
      'warning',
      items[0].tone,
      'New insight should be warning tone'
    );
    System.assert(
      String.isNotBlank(items[0].explanation),
      'Insight should include an explanation.'
    );
  }

  @isTest
  static void advisorRecommendationsFeed() {
    Test.startTest();
    List<WealthAIHomeController.FeedItem> items = WealthAIHomeController.getAdvisorRecommendations();
    Test.stopTest();
    System.assert(
      items.size() > 0,
      'Expected at least one recommendation item'
    );
    System.assertEquals(
      'critical',
      items[0].tone,
      'High-priority recommendation should be critical tone'
    );
    System.assert(
      String.isNotBlank(items[0].explanation),
      'Recommendation should include an explanation.'
    );
  }

  @isTest
  static void advisorPriorityQueueRanksWorstHealthFirst() {
    Test.startTest();
    List<WealthAIHomeController.FeedItem> items = WealthAIHomeController.getAdvisorPriorityQueue();
    Test.stopTest();
    System.assert(items.size() > 0, 'Expected at least one at-risk client');
    System.assertEquals(
      'warning',
      items[0].tone,
      'A health score of 40 should be warning tone'
    );
    System.assert(
      String.isNotBlank(items[0].explanation),
      'Priority queue item should include an explanation.'
    );
  }

  @isTest
  static void complianceQueueSurfacesEscalatedFirst() {
    Test.startTest();
    List<WealthAIHomeController.FeedItem> items = WealthAIHomeController.getComplianceQueue();
    Test.stopTest();
    System.assert(items.size() > 0, 'Expected at least one finding');
    System.assertEquals(
      'critical',
      items[0].tone,
      'Escalated findings should surface first with critical tone'
    );
    System.assert(
      String.isNotBlank(items[0].explanation),
      'Compliance queue item should include an explanation.'
    );
  }

  @isTest
  static void executiveApprovalQueueReturnsPendingRuns() {
    AI_Agent_Run__c pending = WamTestDataFactory.createAgentRun('Success');
    pending.HITL_Status__c = 'Pending';
    update pending;

    Test.startTest();
    List<WealthAIHomeController.FeedItem> items = WealthAIHomeController.getExecutiveApprovalQueue();
    Test.stopTest();
    System.assert(
      items.size() > 0,
      'Expected at least one pending approval'
    );
    System.assertEquals(
      'warning',
      items[0].tone,
      'Pending approvals should be warning tone'
    );
    System.assert(
      String.isNotBlank(items[0].explanation),
      'Approval queue item should include an explanation.'
    );
  }
}
