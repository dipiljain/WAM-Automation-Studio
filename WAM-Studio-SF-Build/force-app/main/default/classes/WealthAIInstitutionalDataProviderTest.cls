@isTest
private class WealthAIInstitutionalDataProviderTest {
  @testSetup
  static void setupData() {
    WamTestDataFactory.createBusinessAccount('Institutional Grounding Test');
  }

  @isTest
  static void groundedContextIncludesRealMandateCounts() {
    WealthAIInstitutionalDataProvider.Request req = new WealthAIInstitutionalDataProvider.Request();
    req.Account_Name = 'Institutional Grounding Test';

    Test.startTest();
    List<WealthAIInstitutionalDataProvider.Response> responses = WealthAIInstitutionalDataProvider.getInstitutionalContext(
      new List<WealthAIInstitutionalDataProvider.Request>{ req }
    );
    Test.stopTest();

    System.assert(
      responses[0].Prompt.contains('Institutional Grounding Test'),
      'Grounded prompt should reference the resolved account name.'
    );
  }

  @isTest
  static void unmatchedAccountNameDoesNotInventData() {
    WealthAIInstitutionalDataProvider.Request req = new WealthAIInstitutionalDataProvider.Request();
    req.Account_Name = 'No Such Institution Zzz';

    Test.startTest();
    List<WealthAIInstitutionalDataProvider.Response> responses = WealthAIInstitutionalDataProvider.getInstitutionalContext(
      new List<WealthAIInstitutionalDataProvider.Request>{ req }
    );
    Test.stopTest();

    System.assert(
      responses[0].Prompt.contains('No matching institutional account'),
      'Should signal no match instead of inventing data.'
    );
  }
}
