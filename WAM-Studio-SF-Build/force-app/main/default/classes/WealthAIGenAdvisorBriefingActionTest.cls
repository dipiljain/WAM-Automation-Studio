@isTest
private class WealthAIGenAdvisorBriefingActionTest {
  @isTest
  static void invocableGeneratesBriefingForMatchedClient() {
    Account acct = WamTestDataFactory.createHousehold(
      'Briefing Action Test Household'
    );

    WealthAIGenAdvisorBriefingAction.Request req = new WealthAIGenAdvisorBriefingAction.Request();
    req.Client_Name = 'Briefing Action Test';

    Test.startTest();
    List<WealthAIGenAdvisorBriefingAction.Result> results = WealthAIGenAdvisorBriefingAction.run(
      new List<WealthAIGenAdvisorBriefingAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected one result row.');
    System.assertNotEquals(
      null,
      results[0].briefingId,
      'Briefing should be created for a matched client.'
    );
    System.assertEquals(
      null,
      results[0].errorMessage,
      'No error expected on a match.'
    );
  }

  @isTest
  static void invocableReturnsErrorForUnmatchedClient() {
    WealthAIGenAdvisorBriefingAction.Request req = new WealthAIGenAdvisorBriefingAction.Request();
    req.Client_Name = 'Totally Unknown Household Zzz';

    Test.startTest();
    List<WealthAIGenAdvisorBriefingAction.Result> results = WealthAIGenAdvisorBriefingAction.run(
      new List<WealthAIGenAdvisorBriefingAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(
      null,
      results[0].briefingId,
      'No briefing without a match.'
    );
    System.assertNotEquals(
      null,
      results[0].errorMessage,
      'Error message should explain the miss.'
    );
  }
}
