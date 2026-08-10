@isTest
private class WealthAIAdvisorUseCaseServiceTest {
  @testSetup
  static void setupData() {
    Account acct = WamTestDataFactory.createHousehold('M1 Test Household');
    insert new AI_Insight__c(
      Account__c = acct.Id,
      Insight_Type__c = 'Relationship',
      Summary__c = 'Recent life event noted.',
      Confidence__c = 88,
      Status__c = 'New'
    );
    insert new AI_Recommendation__c(
      Account__c = acct.Id,
      Recommendation_Type__c = 'Outreach',
      Recommended_Action__c = 'Schedule check-in',
      Priority__c = 'High',
      Status__c = 'New'
    );
    insert new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = 'KYC',
      Status__c = 'Open'
    );
    insert new Portfolio_Alert__c(
      Account__c = acct.Id,
      Alert_Type__c = 'Drift',
      Severity__c = 'High'
    );
  }

  @isTest
  static void scoreRefreshAndClient360Work() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M1 Test Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIAdvisorUseCaseService.ScoreResult scores = WealthAIAdvisorUseCaseService.refreshScores(
      acct.Id
    );
    WealthAIAdvisorUseCaseService.Client360Snapshot snapshot = WealthAIAdvisorUseCaseService.getClient360(
      acct.Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      scores.engagementScore,
      'Engagement score should be computed.'
    );
    System.assertNotEquals(
      null,
      scores.healthScore,
      'Health score should be computed.'
    );
    System.assertEquals(
      acct.Id,
      snapshot.accountId,
      'Client360 should reference account.'
    );
    System.assert(
      snapshot.openRecommendations > 0,
      'Should surface open recommendations.'
    );
  }

  @isTest
  static void advisorBriefingAndActionsCreateRecords() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M1 Test Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIAdvisorUseCaseService.ActionResult briefing = WealthAIAdvisorUseCaseService.generateAdvisorBriefing(
      acct.Id
    );
    WealthAIAdvisorUseCaseService.ActionResult relationship = WealthAIAdvisorUseCaseService.generateRelationshipInsight(
      acct.Id
    );
    WealthAIAdvisorUseCaseService.ActionResult nba = WealthAIAdvisorUseCaseService.generateNextBestAction(
      acct.Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      briefing.recordId,
      'Briefing should be created.'
    );
    System.assertNotEquals(
      null,
      relationship.recordId,
      'Relationship insight should be created.'
    );
    System.assertNotEquals(
      null,
      nba.recordId,
      'Recommendation should be created.'
    );
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Advisor_Briefing__c WHERE Id = :briefing.recordId]
    );
  }

  @isTest
  static void accountOptionsAndValidation() {
    Test.startTest();
    List<WealthAIAdvisorUseCaseService.AccountOption> options = WealthAIAdvisorUseCaseService.getAccountOptions();
    Test.stopTest();
    System.assert(options.size() > 0, 'Account options should be returned.');
  }

  @isTest
  static void accountOptionsExcludeBusinessRecordType() {
    Id businessRecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Account' AND DeveloperName = 'Business'
      LIMIT 1
    ]
    .Id;
    insert new Account(
      Name = 'B2B Institutional Test Account',
      RecordTypeId = businessRecordTypeId
    );

    Test.startTest();
    List<WealthAIAdvisorUseCaseService.AccountOption> options = WealthAIAdvisorUseCaseService.getAccountOptions();
    Test.stopTest();

    for (WealthAIAdvisorUseCaseService.AccountOption option : options) {
      System.assertNotEquals(
        'B2B Institutional Test Account',
        option.label,
        'Business record type accounts should not appear in the B2C account picker.'
      );
    }
  }
}
