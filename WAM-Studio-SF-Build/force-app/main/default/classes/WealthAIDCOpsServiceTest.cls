@isTest
private class WealthAIDCOpsServiceTest {
  @testSetup
  static void setupData() {
    Account acct = WamTestDataFactory.createHousehold('M3 Ops Household');
    insert new Referral_Prediction__c(
      Account__c = acct.Id,
      Score__c = 72,
      Priority__c = 'Medium',
      Status__c = 'New',
      Notes__c = 'Initial prediction.'
    );
  }

  @isTest
  static void snapshotAndListsReturnData() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M3 Ops Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIDistributionComplianceOpsService.WorkbenchSnapshot snapshot = WealthAIDistributionComplianceOpsService.getWorkbenchSnapshot(
      acct.Id
    );
    List<WealthAIDistributionComplianceOpsService.WorkbenchItem> dist = WealthAIDistributionComplianceOpsService.getDistributionItems(
      acct.Id
    );
    Test.stopTest();

    System.assertEquals(
      acct.Id,
      snapshot.accountId,
      'Snapshot must include account.'
    );
    System.assert(dist.size() > 0, 'Distribution items should be returned.');
  }

  @isTest
  static void allM3ActionsCreateRecords() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M3 Ops Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIDistributionComplianceOpsService.runLeadScoring(acct.Id);
    WealthAIDistributionComplianceOpsService.runLeadPrioritization(acct.Id);
    WealthAIDistributionComplianceOpsService.runProspectResearch(acct.Id);
    WealthAIDistributionComplianceOpsService.runKYCCopilot(acct.Id);
    WealthAIDistributionComplianceOpsService.runAMLScreening(acct.Id);
    WealthAIDistributionComplianceOpsService.runRegulatoryMonitoring(acct.Id);
    WealthAIDistributionComplianceOpsService.runOnboardingAssistant(acct.Id);
    WealthAIDistributionComplianceOpsService.runDocumentExtraction(acct.Id);
    WealthAIDistributionComplianceOpsService.runWorkflowAutomation(acct.Id);
    Test.stopTest();

    System.assert(
      [SELECT COUNT() FROM Compliance_Finding__c WHERE Account__c = :acct.Id] >=
      3,
      'Compliance findings should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM Workflow_Execution__c WHERE Account__c = :acct.Id] >=
      3,
      'Workflow executions should be created.'
    );
  }
}
