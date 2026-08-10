@isTest
private class WealthAIPortfolioUseCaseServiceTest {
  @testSetup
  static void setupData() {
    Account acct = WamTestDataFactory.createHousehold('M2 Portfolio Household');
    insert new Client_Health_Score__c(Account__c = acct.Id, Score__c = 62);
    insert new Portfolio_Alert__c(
      Account__c = acct.Id,
      Alert_Type__c = 'Drift',
      Severity__c = 'High'
    );
    insert new Risk_Signal__c(
      Account__c = acct.Id,
      Signal_Type__c = 'Drift',
      Severity__c = 'Medium',
      Summary__c = 'Initial signal'
    );
  }

  @isTest
  static void snapshotAndListsWork() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M2 Portfolio Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIPortfolioUseCaseService.PortfolioSnapshot snapshot = WealthAIPortfolioUseCaseService.getPortfolioSnapshot(
      acct.Id
    );
    List<WealthAIPortfolioUseCaseService.PortfolioItem> alerts = WealthAIPortfolioUseCaseService.getLatestPortfolioAlerts(
      acct.Id
    );
    List<WealthAIPortfolioUseCaseService.PortfolioItem> signals = WealthAIPortfolioUseCaseService.getLatestRiskSignals(
      acct.Id
    );
    Test.stopTest();

    System.assertEquals(
      acct.Id,
      snapshot.accountId,
      'Snapshot should target account.'
    );
    System.assert(snapshot.openAlerts > 0, 'Expected open alerts.');
    System.assert(alerts.size() > 0, 'Expected alert list items.');
    System.assert(signals.size() > 0, 'Expected signal list items.');
  }

  @isTest
  static void portfolioActionsCreateRecords() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name = 'M2 Portfolio Household'
      LIMIT 1
    ];

    Test.startTest();
    WealthAIPortfolioUseCaseService.PortfolioActionResult health = WealthAIPortfolioUseCaseService.runPortfolioHealthAnalyzer(
      acct.Id
    );
    WealthAIPortfolioUseCaseService.PortfolioActionResult review = WealthAIPortfolioUseCaseService.runPortfolioReviewCopilot(
      acct.Id
    );
    WealthAIPortfolioUseCaseService.PortfolioActionResult commentary = WealthAIPortfolioUseCaseService.runPortfolioCommentaryGenerator(
      acct.Id
    );
    WealthAIPortfolioUseCaseService.PortfolioActionResult risk = WealthAIPortfolioUseCaseService.runRiskExposureDetection(
      acct.Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      health.recordId,
      'Health analyzer should create alert.'
    );
    System.assertNotEquals(
      null,
      review.recordId,
      'Review copilot should create insight.'
    );
    System.assertNotEquals(
      null,
      commentary.recordId,
      'Commentary generator should create insight.'
    );
    System.assertNotEquals(
      null,
      risk.recordId,
      'Risk detector should create risk signal.'
    );
  }
}
