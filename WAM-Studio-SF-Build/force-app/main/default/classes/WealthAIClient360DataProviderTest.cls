@isTest
private class WealthAIClient360DataProviderTest {
  @testSetup
  static void setupData() {
    Account acct = WamTestDataFactory.createHousehold(
      'Grounding Test Household'
    );
    insert new AI_Recommendation__c(
      Account__c = acct.Id,
      Recommendation_Type__c = 'Outreach',
      Recommended_Action__c = 'Schedule check-in',
      Priority__c = 'High',
      Status__c = 'New'
    );
  }

  @isTest
  static void groundedContextIncludesRealAccountFacts() {
    WealthAIClient360DataProvider.Request req = new WealthAIClient360DataProvider.Request();
    req.Client_Name = 'Grounding Test';

    Test.startTest();
    List<WealthAIClient360DataProvider.Response> responses = WealthAIClient360DataProvider.getClientContext(
      new List<WealthAIClient360DataProvider.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(
      1,
      responses.size(),
      'Expected one grounding response.'
    );
    System.assert(
      responses[0].Prompt.contains('Grounding Test Household'),
      'Grounded prompt should reference the resolved account name.'
    );
    System.assert(
      responses[0].Prompt.contains('Open Recommendations: 1'),
      'Grounded prompt should reflect real recommendation counts.'
    );
  }

  @isTest
  static void unmatchedClientNameDoesNotInventData() {
    WealthAIClient360DataProvider.Request req = new WealthAIClient360DataProvider.Request();
    req.Client_Name = 'Nonexistent Household Zzz';

    Test.startTest();
    List<WealthAIClient360DataProvider.Response> responses = WealthAIClient360DataProvider.getClientContext(
      new List<WealthAIClient360DataProvider.Request>{ req }
    );
    Test.stopTest();

    System.assert(
      responses[0].Prompt.contains('No matching client'),
      'Should signal no match instead of inventing data.'
    );
  }

  @isTest
  static void blankClientNameAsksForClarification() {
    WealthAIClient360DataProvider.Request req = new WealthAIClient360DataProvider.Request();
    req.Client_Name = '';

    Test.startTest();
    List<WealthAIClient360DataProvider.Response> responses = WealthAIClient360DataProvider.getClientContext(
      new List<WealthAIClient360DataProvider.Request>{ req }
    );
    Test.stopTest();

    System.assert(
      responses[0].Prompt.contains('No client selected'),
      'Should ask for clarification instead of guessing.'
    );
  }
}
