@isTest
private class WealthAIInstitutionalUseCaseServiceTest {
  @testSetup
  static void setupData() {
    WamTestDataFactory.createBusinessAccount('Institutional Test Account');
  }

  private static Id institutionalAccountId() {
    return [
      SELECT Id
      FROM Account
      WHERE Name = 'Institutional Test Account'
      LIMIT 1
    ]
    .Id;
  }

  @isTest
  static void accountOptionsIncludeOnlyStandaloneBusinessAccounts() {
    Test.startTest();
    List<WealthAIInstitutionalUseCaseService.AccountOption> options = WealthAIInstitutionalUseCaseService.getInstitutionalAccountOptions();
    Test.stopTest();

    Boolean found = false;
    for (WealthAIInstitutionalUseCaseService.AccountOption option : options) {
      if (option.label == 'Institutional Test Account') {
        found = true;
      }
    }
    System.assert(found, 'Institutional account should appear in the picker.');
  }

  @isTest
  static void mandateComplianceCheckCreatesMandateRecord() {
    Id acctId = institutionalAccountId();

    Test.startTest();
    WealthAIInstitutionalUseCaseService.ActionResult result = WealthAIInstitutionalUseCaseService.runMandateComplianceCheck(
      acctId
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result.recordId,
      'Mandate record should be created.'
    );
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Institutional_Mandate__c WHERE Id = :result.recordId]
    );
  }

  @isTest
  static void proposalCopilotAndKYBOnboardingCreateRecords() {
    Id acctId = institutionalAccountId();

    Test.startTest();
    WealthAIInstitutionalUseCaseService.ActionResult proposal = WealthAIInstitutionalUseCaseService.runInstitutionalProposalCopilot(
      acctId
    );
    WealthAIInstitutionalUseCaseService.ActionResult kyb = WealthAIInstitutionalUseCaseService.runInstitutionalKYBOnboarding(
      acctId
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      proposal.recordId,
      'Proposal recommendation should be created.'
    );
    System.assertNotEquals(
      null,
      kyb.recordId,
      'KYB finding should be created.'
    );
  }

  @isTest
  static void snapshotAndCommitteeReportReflectRealCounts() {
    Id acctId = institutionalAccountId();
    WealthAIInstitutionalUseCaseService.runInstitutionalProposalCopilot(acctId);

    Test.startTest();
    WealthAIInstitutionalUseCaseService.InstitutionalSnapshot snapshot = WealthAIInstitutionalUseCaseService.getInstitutionalSnapshot(
      acctId
    );
    WealthAIInstitutionalUseCaseService.ActionResult report = WealthAIInstitutionalUseCaseService.generateCommitteeReport(
      acctId
    );
    Test.stopTest();

    System.assert(
      snapshot.openProposals > 0,
      'Snapshot should reflect the created proposal.'
    );
    System.assertNotEquals(
      null,
      report.recordId,
      'Committee report briefing should be created.'
    );
  }

  @isTest
  static void riskSurveillanceAndLiquidityForecastCreateSignals() {
    Id acctId = institutionalAccountId();

    Test.startTest();
    WealthAIInstitutionalUseCaseService.ActionResult risk = WealthAIInstitutionalUseCaseService.runInstitutionalRiskSurveillance(
      acctId
    );
    WealthAIInstitutionalUseCaseService.ActionResult liquidity = WealthAIInstitutionalUseCaseService.runInstitutionalLiquidityForecast(
      acctId
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      risk.recordId,
      'Risk signal should be created.'
    );
    System.assertNotEquals(
      null,
      liquidity.recordId,
      'Liquidity risk signal should be created.'
    );
  }

  @isTest
  static void autonomousMonitoringEscalatesForApproval() {
    Id acctId = institutionalAccountId();

    Test.startTest();
    WealthAIInstitutionalUseCaseService.ActionResult result = WealthAIInstitutionalUseCaseService.runAutonomousInstitutionalMonitoring(
      acctId
    );
    Test.stopTest();

    AI_Agent_Run__c runRecord = [
      SELECT HITL_Status__c, Autonomous_Mode__c, Status__c
      FROM AI_Agent_Run__c
      WHERE Id = :result.runId
    ];
    System.assertEquals(
      true,
      runRecord.Autonomous_Mode__c,
      'Run should be autonomous.'
    );
    System.assertEquals(
      'Escalated',
      runRecord.Status__c,
      'Run should be escalated for approval.'
    );
  }

  @isTest
  static void bookSnapshotAndPriorityQueueReflectBreach() {
    Id acctId = institutionalAccountId();
    WealthAIInstitutionalUseCaseService.runMandateComplianceCheck(acctId);
    Institutional_Mandate__c mandate = [
      SELECT Id
      FROM Institutional_Mandate__c
      WHERE Account__c = :acctId
      LIMIT 1
    ];
    mandate.Compliance_Status__c = 'Breach';
    update mandate;

    Test.startTest();
    WealthAIInstitutionalUseCaseService.InstitutionalBookSnapshot snapshot = WealthAIInstitutionalUseCaseService.getInstitutionalBookSnapshot();
    List<WealthAIInstitutionalUseCaseService.StakeholderItem> queue = WealthAIInstitutionalUseCaseService.getInstitutionalPriorityQueue();
    Test.stopTest();

    System.assert(
      snapshot.institutionCount > 0,
      'Book snapshot should count standalone institutional accounts.'
    );
    System.assert(
      snapshot.mandateBreaches > 0,
      'Book snapshot should reflect the mandate breach.'
    );
    System.assert(
      queue.size() > 0,
      'Priority queue should surface the breached mandate.'
    );
    System.assertEquals(
      'critical',
      queue[0].tone,
      'Mandate breaches should be critical tone'
    );
    System.assert(
      String.isNotBlank(queue[0].explanation),
      'Priority queue item should include an explanation.'
    );
  }

  @isTest
  static void invalidAccountThrows() {
    Account household = WamTestDataFactory.createHousehold(
      'Not Institutional Household'
    );
    Boolean threw = false;
    try {
      WealthAIInstitutionalUseCaseService.getInstitutionalSnapshot(
        household.Id
      );
    } catch (AuraHandledException e) {
      threw = true;
    }
    System.assert(
      threw,
      'Household accounts should not be treated as institutional.'
    );
  }
}
