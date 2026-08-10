@isTest
private class WealthAIRunLeadScoringActionTest {
  @isTest
  static void invocableCreatesPrediction() {
    Account acct = WamTestDataFactory.createHousehold('M3 Invocable Household');

    WealthAIRunLeadScoringAction.Request req = new WealthAIRunLeadScoringAction.Request();
    req.accountId = acct.Id;

    Test.startTest();
    List<WealthAIRunLeadScoringAction.Result> outputs = WealthAIRunLeadScoringAction.run(
      new List<WealthAIRunLeadScoringAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, outputs.size(), 'Expected one output.');
    System.assertNotEquals(
      null,
      outputs[0].predictionId,
      'Prediction should be created.'
    );
  }
}
