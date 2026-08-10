@isTest
private class WealthAIRunMandateComplianceActionTest {
  @isTest
  static void invocableCreatesMandateForMatchedAccount() {
    WamTestDataFactory.createBusinessAccount('Mandate Action Test Institution');

    WealthAIRunMandateComplianceAction.Request req = new WealthAIRunMandateComplianceAction.Request();
    req.Account_Name = 'Mandate Action Test Institution';

    Test.startTest();
    List<WealthAIRunMandateComplianceAction.Result> results = WealthAIRunMandateComplianceAction.run(
      new List<WealthAIRunMandateComplianceAction.Request>{ req }
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      results[0].mandateId,
      'Mandate should be created for a matched account.'
    );
    System.assertEquals(
      null,
      results[0].errorMessage,
      'No error expected on a match.'
    );
  }

  @isTest
  static void invocableReturnsErrorForUnmatchedAccount() {
    WealthAIRunMandateComplianceAction.Request req = new WealthAIRunMandateComplianceAction.Request();
    req.Account_Name = 'Totally Unknown Institution Zzz';

    Test.startTest();
    List<WealthAIRunMandateComplianceAction.Result> results = WealthAIRunMandateComplianceAction.run(
      new List<WealthAIRunMandateComplianceAction.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(
      null,
      results[0].mandateId,
      'No mandate without a match.'
    );
    System.assertNotEquals(
      null,
      results[0].errorMessage,
      'Error message should explain the miss.'
    );
  }
}
