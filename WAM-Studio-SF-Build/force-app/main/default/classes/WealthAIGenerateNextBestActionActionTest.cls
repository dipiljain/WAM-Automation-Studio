@isTest
private class WealthAIGenerateNextBestActionActionTest {
  @isTest
  static void invocableGeneratesRecommendationForMatchedClient() {
    Account acct = WamTestDataFactory.createHousehold(
      'NBA Action Test Household'
    );

    WealthAIGenerateNextBestActionAction.Request req = new WealthAIGenerateNextBestActionAction.Request();
    req.Client_Name = 'NBA Action Test';

    Test.startTest();
    List<WealthAIGenerateNextBestActionAction.Result> results = WealthAIGenerateNextBestActionAction.run(
      new List<WealthAIGenerateNextBestActionAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected one result row.');
    System.assertNotEquals(
      null,
      results[0].recommendationId,
      'Recommendation should be created for a matched client.'
    );
    System.assertEquals(
      null,
      results[0].errorMessage,
      'No error expected on a match.'
    );
  }

  @isTest
  static void invocableReturnsErrorForUnmatchedClient() {
    WealthAIGenerateNextBestActionAction.Request req = new WealthAIGenerateNextBestActionAction.Request();
    req.Client_Name = 'Totally Unknown Household Zzz';

    Test.startTest();
    List<WealthAIGenerateNextBestActionAction.Result> results = WealthAIGenerateNextBestActionAction.run(
      new List<WealthAIGenerateNextBestActionAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(
      null,
      results[0].recommendationId,
      'No recommendation without a match.'
    );
    System.assertNotEquals(
      null,
      results[0].errorMessage,
      'Error message should explain the miss.'
    );
  }
}
