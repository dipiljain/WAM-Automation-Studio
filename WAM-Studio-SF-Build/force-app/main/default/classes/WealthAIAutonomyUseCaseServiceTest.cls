@isTest
private class WealthAIAutonomyUseCaseServiceTest {
  @testSetup
  static void setupData() {
    Account acct = WamTestDataFactory.createHousehold('M5 Autonomy Household');
    insert new Client_Health_Score__c(Account__c = acct.Id, Score__c = 58);
  }

  @isTest
  static void snapshotAndQueuesReturnData() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M5 Autonomy Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIAutonomyUseCaseService.runAutonomousAdvisorAgent(acct.Id);
    WealthAIAutonomyUseCaseService.runAutonomousServiceAgent(acct.Id);
    WealthAIAutonomyUseCaseService.runAutonomousComplianceAgent(acct.Id);
    WealthAIAutonomyUseCaseService.AutonomySnapshot snapshot = WealthAIAutonomyUseCaseService.getAutonomySnapshot(
      acct.Id
    );
    List<WealthAIAutonomyUseCaseService.AutonomyItem> runs = WealthAIAutonomyUseCaseService.getRunQueue(
      acct.Id
    );
    List<WealthAIAutonomyUseCaseService.AutonomyItem> signals = WealthAIAutonomyUseCaseService.getAutonomySignals(
      acct.Id
    );
    Test.stopTest();

    System.assertEquals(
      acct.Id,
      snapshot.accountId,
      'Snapshot must include account.'
    );
    System.assert(runs.size() > 0, 'Run queue should return data.');
    System.assertNotEquals(null, signals, 'Signal queue should be queryable.');
  }

  @isTest
  static void allM5ActionsCreateArtifacts() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M5 Autonomy Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIAutonomyUseCaseService.runAutonomousAdvisorAgent(acct.Id);
    WealthAIAutonomyUseCaseService.runAutonomousServiceAgent(acct.Id);
    WealthAIAutonomyUseCaseService.runAutonomousOperationsAgent(acct.Id);
    WealthAIAutonomyUseCaseService.runAutonomousComplianceAgent(acct.Id);
    WealthAIAutonomyUseCaseService.runAutonomousProspectingAgent(acct.Id);
    WealthAIAutonomyUseCaseService.runAIBranchManager(acct.Id);
    WealthAIAutonomyUseCaseService.runAutonomousPortfolioMonitoring(acct.Id);
    WealthAIAutonomyUseCaseService.runHyperPersonalizedEngagement(acct.Id);
    Test.stopTest();

    System.assert(
      [
        SELECT COUNT()
        FROM AI_Agent_Run__c
        WHERE Related_Record_Id__c = :acct.Id AND Autonomous_Mode__c = TRUE
      ] >= 8,
      'Autonomous runs should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM AI_Recommendation__c WHERE Account__c = :acct.Id] >=
      2,
      'Recommendations should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM Workflow_Execution__c WHERE Account__c = :acct.Id] >=
      2,
      'Workflows should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM Compliance_Finding__c WHERE Account__c = :acct.Id] >=
      1,
      'Findings should be created.'
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
      [SELECT COUNT() FROM Portfolio_Alert__c WHERE Account__c = :acct.Id] >= 1,
      'Portfolio alerts should be created.'
    );
    System.assert(
      [SELECT COUNT() FROM Risk_Signal__c WHERE Account__c = :acct.Id] >= 1,
      'Risk signals should be created.'
    );
  }
}
