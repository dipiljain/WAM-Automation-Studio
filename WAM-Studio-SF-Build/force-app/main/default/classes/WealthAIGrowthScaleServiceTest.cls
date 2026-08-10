@isTest
private class WealthAIGrowthScaleServiceTest {
  @testSetup
  static void setupData() {
    Account acct = WamTestDataFactory.createHousehold('M4 Growth Household');
    insert new Client_Health_Score__c(Account__c = acct.Id, Score__c = 62);
  }

  @isTest
  static void snapshotAndQueuesReturnData() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M4 Growth Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIGrowthScaleService.runProposalCopilot(acct.Id);
    WealthAIGrowthScaleService.runServiceResolutionCopilot(acct.Id);
    WealthAIGrowthScaleService.runComplianceSurveillance(acct.Id);
    WealthAIGrowthScaleService.ScaleSnapshot snapshot = WealthAIGrowthScaleService.getScaleSnapshot(
      acct.Id
    );
    List<WealthAIGrowthScaleService.ScaleItem> growth = WealthAIGrowthScaleService.getGrowthItems(
      acct.Id
    );
    List<WealthAIGrowthScaleService.ScaleItem> service = WealthAIGrowthScaleService.getServiceItems(
      acct.Id
    );
    Test.stopTest();

    System.assertEquals(
      acct.Id,
      snapshot.accountId,
      'Snapshot must include account.'
    );
    System.assert(growth.size() > 0, 'Growth queue should have items.');
    System.assert(service.size() > 0, 'Service queue should have items.');
  }

  @isTest
  static void allM4ActionsCreateRecords() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M4 Growth Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIGrowthScaleService.runProposalCopilot(acct.Id);
    WealthAIGrowthScaleService.runReferralIntelligence(acct.Id);
    WealthAIGrowthScaleService.runCrossSellIntelligence(acct.Id);
    WealthAIGrowthScaleService.runScenarioAnalysis(acct.Id);
    WealthAIGrowthScaleService.runServiceResolutionCopilot(acct.Id);
    WealthAIGrowthScaleService.runPredictiveAttrition(acct.Id);
    WealthAIGrowthScaleService.runComplianceSurveillance(acct.Id);
    WealthAIGrowthScaleService.runReconciliationAssistant(acct.Id);
    WealthAIGrowthScaleService.runCashMovementIntelligence(acct.Id);
    Test.stopTest();

    System.assert(
      [SELECT COUNT() FROM AI_Recommendation__c WHERE Account__c = :acct.Id] >=
      3,
      'Recommendations should be created.'
    );
    System.assert(
      [
        SELECT COUNT()
        FROM Referral_Prediction__c
        WHERE Account__c = :acct.Id
      ] >= 1,
      'Referral predictions should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM AI_Insight__c WHERE Account__c = :acct.Id] >= 2,
      'Insights should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM Compliance_Finding__c WHERE Account__c = :acct.Id] >=
      1,
      'Compliance findings should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM Workflow_Execution__c WHERE Account__c = :acct.Id] >=
      2,
      'Workflow executions should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM Risk_Signal__c WHERE Account__c = :acct.Id] >= 2,
      'Risk signals should be created.'
    );
  }
}
