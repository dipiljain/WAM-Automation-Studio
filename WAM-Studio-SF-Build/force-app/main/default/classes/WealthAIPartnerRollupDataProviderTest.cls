@isTest
private class WealthAIPartnerRollupDataProviderTest {
  @testSetup
  static void setupData() {
    Account partner = WamTestDataFactory.createBusinessAccount(
      'Partner Grounding Test'
    );
    WamTestDataFactory.createChildHousehold(
      'Partner Grounding Child',
      partner.Id
    );
  }

  @isTest
  static void groundedContextIncludesRealParticipantCounts() {
    WealthAIPartnerRollupDataProvider.Request req = new WealthAIPartnerRollupDataProvider.Request();
    req.Account_Name = 'Partner Grounding Test';

    Test.startTest();
    List<WealthAIPartnerRollupDataProvider.Response> responses = WealthAIPartnerRollupDataProvider.getPartnerContext(
      new List<WealthAIPartnerRollupDataProvider.Request>{ req }
    );
    Test.stopTest();

    System.assert(
      responses[0].Prompt.contains('Participant households: 1'),
      'Grounded prompt should reflect the real participant count.'
    );
  }

  @isTest
  static void unmatchedAccountNameDoesNotInventData() {
    WealthAIPartnerRollupDataProvider.Request req = new WealthAIPartnerRollupDataProvider.Request();
    req.Account_Name = 'No Such Partner Zzz';

    Test.startTest();
    List<WealthAIPartnerRollupDataProvider.Response> responses = WealthAIPartnerRollupDataProvider.getPartnerContext(
      new List<WealthAIPartnerRollupDataProvider.Request>{ req }
    );
    Test.stopTest();

    System.assert(
      responses[0].Prompt.contains('No matching partner program'),
      'Should signal no match instead of inventing data.'
    );
  }
}
