@isTest
private class WealthAIRunPartnerGrowthActionTest {
  @isTest
  static void invocableCreatesReferralForMatchedProgram() {
    Account partner = WamTestDataFactory.createBusinessAccount(
      'Growth Action Test Program'
    );
    WamTestDataFactory.createChildHousehold(
      'Growth Action Test Child',
      partner.Id
    );

    WealthAIRunPartnerGrowthAction.Request req = new WealthAIRunPartnerGrowthAction.Request();
    req.Account_Name = 'Growth Action Test Program';

    Test.startTest();
    List<WealthAIRunPartnerGrowthAction.Result> results = WealthAIRunPartnerGrowthAction.run(
      new List<WealthAIRunPartnerGrowthAction.Request>{ req }
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      results[0].referralId,
      'Referral should be created for a matched program.'
    );
    System.assertEquals(
      null,
      results[0].errorMessage,
      'No error expected on a match.'
    );
  }

  @isTest
  static void invocableReturnsErrorForUnmatchedProgram() {
    WealthAIRunPartnerGrowthAction.Request req = new WealthAIRunPartnerGrowthAction.Request();
    req.Account_Name = 'Totally Unknown Program Zzz';

    Test.startTest();
    List<WealthAIRunPartnerGrowthAction.Result> results = WealthAIRunPartnerGrowthAction.run(
      new List<WealthAIRunPartnerGrowthAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(
      null,
      results[0].referralId,
      'No referral without a match.'
    );
    System.assertNotEquals(
      null,
      results[0].errorMessage,
      'Error message should explain the miss.'
    );
  }
}
