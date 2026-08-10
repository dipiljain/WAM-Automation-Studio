@isTest
private class WealthAIRunProposalCopilotActionTest {
  @isTest
  static void invocableCreatesProposalRecommendation() {
    Account acct = WamTestDataFactory.createHousehold('M4 Invocable Household');

    WealthAIRunProposalCopilotAction.Request req = new WealthAIRunProposalCopilotAction.Request();
    req.accountId = acct.Id;

    Test.startTest();
    List<WealthAIRunProposalCopilotAction.Result> outputs = WealthAIRunProposalCopilotAction.run(
      new List<WealthAIRunProposalCopilotAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, outputs.size(), 'Expected one output.');
    System.assertNotEquals(
      null,
      outputs[0].recommendationId,
      'Recommendation should be created.'
    );
  }
}
