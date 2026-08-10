@isTest
private class WealthAIRefreshClientScoresActionTest {
  @isTest
  static void invocableRefreshesScores() {
    Account acct = WamTestDataFactory.createHousehold(
      'Invocable Test Household'
    );

    WealthAIRefreshClientScoresAction.Request req = new WealthAIRefreshClientScoresAction.Request();
    req.accountId = acct.Id;

    Test.startTest();
    List<WealthAIRefreshClientScoresAction.Result> results = WealthAIRefreshClientScoresAction.run(
      new List<WealthAIRefreshClientScoresAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected one result row.');
    System.assertEquals(
      acct.Id,
      results[0].accountId,
      'Account id should match request.'
    );
    System.assertNotEquals(
      null,
      results[0].engagementScore,
      'Engagement score should be set.'
    );
    System.assertNotEquals(
      null,
      results[0].healthScore,
      'Health score should be set.'
    );
  }
}
