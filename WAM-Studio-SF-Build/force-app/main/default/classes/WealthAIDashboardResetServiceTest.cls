@isTest
private class WealthAIDashboardResetServiceTest {
  @isTest
  static void resetAdvisorDataClearsAndReseedsBaseline() {
    Account acct = WamTestDataFactory.createHousehold('Reset Advisor Household');
    insert new AI_Insight__c(
      Account__c = acct.Id,
      Insight_Type__c = 'Risk',
      Summary__c = 'Flagged insight.',
      Confidence__c = 90,
      Status__c = 'New'
    );
    WamTestDataFactory.createRecommendation(acct.Id, 'High');
    insert new Client_Health_Score__c(Account__c = acct.Id, Score__c = 30);

    Test.startTest();
    WealthAIDashboardResetService.ResetResult result = WealthAIDashboardResetService.resetAdvisorData();
    Test.stopTest();

    System.assertEquals(3, result.clearedCount, 'Should clear the flagged insight, recommendation, and at-risk score.');
    System.assert(result.reseededCount > 0, 'Should reseed at least one baseline record.');
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Client_Health_Score__c WHERE Account__c = :acct.Id AND Score__c < 60],
      'At-risk score should be cleared for this account.'
    );
    System.assertEquals(
      1,
      [SELECT COUNT() FROM AI_Insight__c WHERE Account__c = :acct.Id AND Status__c = 'New'],
      'A single healthy baseline insight should remain for this account.'
    );
  }

  @isTest
  static void resetComplianceDataClearsAndReseedsBaseline() {
    Account acct = WamTestDataFactory.createHousehold('Reset Compliance Household');
    insert new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = 'AML',
      Status__c = 'Escalated'
    );

    Test.startTest();
    WealthAIDashboardResetService.ResetResult result = WealthAIDashboardResetService.resetComplianceData();
    Test.stopTest();

    System.assertEquals(1, result.clearedCount, 'Should clear the escalated finding.');
    System.assertEquals(1, result.reseededCount, 'Should reseed one baseline finding.');
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Compliance_Finding__c WHERE Account__c = :acct.Id AND Status__c IN ('Open', 'Escalated')],
      'No open or escalated findings should remain for this account.'
    );
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Compliance_Finding__c WHERE Account__c = :acct.Id AND Status__c = 'Cleared'],
      'A cleared baseline finding should be restored for this account.'
    );
  }

  @isTest
  static void resetExecutiveDataClearsAndReseedsBaseline() {
    AI_Agent_Run__c pending = WamTestDataFactory.createAgentRun('Success');
    pending.HITL_Status__c = 'Pending';
    update pending;

    Test.startTest();
    WealthAIDashboardResetService.ResetResult result = WealthAIDashboardResetService.resetExecutiveData();
    Test.stopTest();

    System.assertEquals(1, result.clearedCount, 'Should clear the pending run.');
    System.assertEquals(1, result.reseededCount, 'Should reseed one baseline run.');
    System.assertEquals(
      0,
      [SELECT COUNT() FROM AI_Agent_Run__c WHERE HITL_Status__c = 'Pending'],
      'No pending approvals should remain.'
    );
  }

  @isTest
  static void resetInstitutionalDataClearsAndReseedsBaseline() {
    Account institution = WamTestDataFactory.createBusinessAccount('Reset Institutional Account');
    insert new Institutional_Mandate__c(
      Account__c = institution.Id,
      Mandate_Type__c = 'Concentration Limit',
      Compliance_Status__c = 'Breach'
    );

    Test.startTest();
    WealthAIDashboardResetService.ResetResult result = WealthAIDashboardResetService.resetInstitutionalData();
    Test.stopTest();

    System.assertEquals(1, result.clearedCount, 'Should clear the breached mandate.');
    System.assertEquals(1, result.reseededCount, 'Should reseed one compliant mandate.');
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Institutional_Mandate__c WHERE Account__c = :institution.Id AND Compliance_Status__c = 'Breach'],
      'No breaches should remain for this institution.'
    );
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Institutional_Mandate__c WHERE Account__c = :institution.Id AND Compliance_Status__c = 'Compliant'],
      'A compliant baseline mandate should be restored.'
    );
  }

  @isTest
  static void resetPartnerDataClearsAndReseedsBaseline() {
    Account partner = WamTestDataFactory.createBusinessAccount('Reset Partner Program');
    Account participant = WamTestDataFactory.createChildHousehold(
      'Reset At-Risk Participant',
      partner.Id
    );
    insert new Client_Health_Score__c(Account__c = participant.Id, Score__c = 35);

    Test.startTest();
    WealthAIDashboardResetService.ResetResult result = WealthAIDashboardResetService.resetPartnerData();
    Test.stopTest();

    System.assertEquals(1, result.clearedCount, 'Should clear the at-risk participant score.');
    System.assertEquals(1, result.reseededCount, 'Should reseed one healthy baseline score.');
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Client_Health_Score__c WHERE Account__c = :participant.Id AND Score__c < 60],
      'No at-risk participant scores should remain.'
    );
  }
}
