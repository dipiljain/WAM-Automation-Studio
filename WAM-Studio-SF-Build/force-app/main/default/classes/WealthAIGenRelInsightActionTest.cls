@isTest
private class WealthAIGenRelInsightActionTest {
  @isTest
  static void invocableGeneratesInsightForMatchedClient() {
    Account acct = WamTestDataFactory.createHousehold(
      'Insight Action Test Household'
    );

    WealthAIGenRelInsightAction.Request req = new WealthAIGenRelInsightAction.Request();
    req.Client_Name = 'Insight Action Test';

    Test.startTest();
    List<WealthAIGenRelInsightAction.Result> results = WealthAIGenRelInsightAction.run(
      new List<WealthAIGenRelInsightAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected one result row.');
    System.assertNotEquals(
      null,
      results[0].insightId,
      'Insight should be created for a matched client.'
    );
    System.assertEquals(
      null,
      results[0].errorMessage,
      'No error expected on a match.'
    );
  }

  @isTest
  static void invocableReturnsErrorForUnmatchedClient() {
    WealthAIGenRelInsightAction.Request req = new WealthAIGenRelInsightAction.Request();
    req.Client_Name = 'Totally Unknown Household Zzz';

    Test.startTest();
    List<WealthAIGenRelInsightAction.Result> results = WealthAIGenRelInsightAction.run(
      new List<WealthAIGenRelInsightAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(
      null,
      results[0].insightId,
      'No insight without a match.'
    );
    System.assertNotEquals(
      null,
      results[0].errorMessage,
      'Error message should explain the miss.'
    );
  }
}
