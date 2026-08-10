@isTest
private class WealthAIRunAutonomyCycleActionTest {
  @isTest
  static void invocableRunsAutonomyCycle() {
    Account acct = WamTestDataFactory.createHousehold('M5 Invocable Household');

    WealthAIRunAutonomyCycleAction.Request req = new WealthAIRunAutonomyCycleAction.Request();
    req.accountId = acct.Id;

    Test.startTest();
    List<WealthAIRunAutonomyCycleAction.Result> outputs = WealthAIRunAutonomyCycleAction.run(
      new List<WealthAIRunAutonomyCycleAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, outputs.size(), 'Expected one output.');
    System.assertNotEquals(null, outputs[0].runId, 'Run should be created.');
    System.assertNotEquals(
      null,
      outputs[0].recordId,
      'Record should be created.'
    );
  }
}
