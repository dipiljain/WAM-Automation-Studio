@isTest
private class WealthAIRunPortfolioHealthActionTest {
  @isTest
  static void invocableCreatesPortfolioAlert() {
    Account acct = WamTestDataFactory.createHousehold('M2 Invocable Household');
    insert new Client_Health_Score__c(Account__c = acct.Id, Score__c = 58);

    WealthAIRunPortfolioHealthAction.Request req = new WealthAIRunPortfolioHealthAction.Request();
    req.accountId = acct.Id;

    Test.startTest();
    List<WealthAIRunPortfolioHealthAction.Result> outputs = WealthAIRunPortfolioHealthAction.run(
      new List<WealthAIRunPortfolioHealthAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, outputs.size(), 'Expected one result row.');
    System.assertNotEquals(
      null,
      outputs[0].alertId,
      'Alert should be created.'
    );
  }
}
