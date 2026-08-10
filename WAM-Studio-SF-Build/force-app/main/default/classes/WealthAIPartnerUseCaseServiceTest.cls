@isTest
private class WealthAIPartnerUseCaseServiceTest {
  @testSetup
  static void setupData() {
    Account partner = WamTestDataFactory.createBusinessAccount(
      'Partner Test Program'
    );
    Account atRiskChild = WamTestDataFactory.createChildHousehold(
      'At-Risk Participant Household',
      partner.Id
    );
    Account healthyChild = WamTestDataFactory.createChildHousehold(
      'Healthy Participant Household',
      partner.Id
    );
    insert new Client_Health_Score__c(
      Account__c = atRiskChild.Id,
      Score__c = 42
    );
    insert new Client_Health_Score__c(
      Account__c = healthyChild.Id,
      Score__c = 88
    );
  }

  private static Id partnerAccountId() {
    return [SELECT Id FROM Account WHERE Name = 'Partner Test Program' LIMIT 1]
    .Id;
  }

  private static Id atRiskParticipantId() {
    return [
      SELECT Id
      FROM Account
      WHERE Name = 'At-Risk Participant Household'
      LIMIT 1
    ]
    .Id;
  }

  @isTest
  static void accountOptionsIncludeOnlyBusinessAccountsWithChildren() {
    Test.startTest();
    List<WealthAIPartnerUseCaseService.AccountOption> options = WealthAIPartnerUseCaseService.getPartnerAccountOptions();
    Test.stopTest();

    Boolean found = false;
    for (WealthAIPartnerUseCaseService.AccountOption option : options) {
      if (option.label == 'Partner Test Program') {
        found = true;
      }
    }
    System.assert(
      found,
      'Partner account with children should appear in the picker.'
    );
  }

  @isTest
  static void rollupSnapshotReflectsParticipantCounts() {
    Test.startTest();
    WealthAIPartnerUseCaseService.PartnerRollupSnapshot snapshot = WealthAIPartnerUseCaseService.getPartnerRollupSnapshot(
      partnerAccountId()
    );
    Test.stopTest();

    System.assertEquals(
      2,
      snapshot.participantCount,
      'Two participants should be counted.'
    );
    System.assertEquals(
      1,
      snapshot.atRiskParticipants,
      'One participant should be at risk.'
    );
  }

  @isTest
  static void getAtRiskParticipantsReturnsOnlyLowScoreAccounts() {
    Test.startTest();
    List<WealthAIPartnerUseCaseService.ParticipantItem> atRisk = WealthAIPartnerUseCaseService.getAtRiskParticipants(
      partnerAccountId()
    );
    Test.stopTest();

    System.assertEquals(
      1,
      atRisk.size(),
      'Only the at-risk household should be returned.'
    );
    System.assertEquals(
      atRiskParticipantId(),
      atRisk[0].accountId,
      'At-risk participant should match the low-score household.'
    );
  }

  @isTest
  static void bookSnapshotAndPriorityQueueReflectAtRiskParticipant() {
    Test.startTest();
    WealthAIPartnerUseCaseService.PartnerBookSnapshot snapshot = WealthAIPartnerUseCaseService.getPartnerBookSnapshot();
    List<WealthAIPartnerUseCaseService.ParticipantItem> queue = WealthAIPartnerUseCaseService.getPartnerPriorityQueue();
    Test.stopTest();

    System.assertEquals(
      1,
      snapshot.partnerProgramCount,
      'One partner program should be counted.'
    );
    System.assertEquals(
      2,
      snapshot.participantCount,
      'Two participants should be counted across the book.'
    );
    System.assertEquals(
      1,
      snapshot.atRiskParticipants,
      'One participant should be at risk across the book.'
    );
    System.assertEquals(
      1,
      queue.size(),
      'Priority queue should surface exactly the at-risk participant.'
    );
    System.assertEquals(
      atRiskParticipantId(),
      queue[0].accountId,
      'Priority queue should reference the at-risk household.'
    );
    System.assert(
      String.isNotBlank(queue[0].explanation),
      'Priority queue item should include an explanation.'
    );
  }

  @isTest
  static void whiteLabelAdvisorActionDelegatesToAdvisorService() {
    Test.startTest();
    WealthAIPartnerUseCaseService.ActionResult result = WealthAIPartnerUseCaseService.runWhiteLabelAdvisorAction(
      partnerAccountId(),
      atRiskParticipantId()
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result.recordId,
      'Delegated recommendation should be created.'
    );
    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM AI_Recommendation__c
        WHERE Id = :result.recordId AND Account__c = :atRiskParticipantId()
      ]
    );
  }

  @isTest
  static void whiteLabelAdvisorActionRejectsUnrelatedParticipant() {
    Account unrelated = WamTestDataFactory.createHousehold(
      'Unrelated Household'
    );
    Boolean threw = false;
    try {
      WealthAIPartnerUseCaseService.runWhiteLabelAdvisorAction(
        partnerAccountId(),
        unrelated.Id
      );
    } catch (AuraHandledException e) {
      threw = true;
    }
    System.assert(
      threw,
      'Should reject participants that do not belong to this partner.'
    );
  }

  @isTest
  static void onboardingAndReferralActionsCreateRecords() {
    Id acctId = partnerAccountId();

    Test.startTest();
    WealthAIPartnerUseCaseService.ActionResult onboarding = WealthAIPartnerUseCaseService.runPartnerOnboardingBatch(
      acctId
    );
    WealthAIPartnerUseCaseService.ActionResult referral = WealthAIPartnerUseCaseService.runCrossProgramReferral(
      acctId
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      onboarding.recordId,
      'Onboarding workflow should be created.'
    );
    System.assertNotEquals(
      null,
      referral.recordId,
      'Referral prediction should be created.'
    );
  }

  @isTest
  static void engagementCampaignAndComplianceRollupWork() {
    Id acctId = partnerAccountId();
    insert new Compliance_Finding__c(
      Account__c = atRiskParticipantId(),
      Finding_Type__c = 'KYC',
      Status__c = 'Open'
    );

    Test.startTest();
    WealthAIPartnerUseCaseService.ActionResult campaign = WealthAIPartnerUseCaseService.runParticipantEngagementCampaign(
      acctId
    );
    List<WealthAIPartnerUseCaseService.ParticipantItem> compliance = WealthAIPartnerUseCaseService.getPartnerComplianceRollup(
      acctId
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      campaign.recordId,
      'Engagement campaign recommendation should be created.'
    );
    System.assertEquals(
      1,
      compliance.size(),
      'Compliance rollup should include the participant finding.'
    );
  }

  @isTest
  static void autonomousGrowthAgentEscalatesForApproval() {
    Test.startTest();
    WealthAIPartnerUseCaseService.ActionResult result = WealthAIPartnerUseCaseService.runAutonomousPartnerGrowthAgent(
      partnerAccountId()
    );
    Test.stopTest();

    AI_Agent_Run__c runRecord = [
      SELECT Status__c, Autonomous_Mode__c
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
  static void invalidAccountThrows() {
    Account household = WamTestDataFactory.createHousehold(
      'Not Partner Household'
    );
    Boolean threw = false;
    try {
      WealthAIPartnerUseCaseService.getPartnerRollupSnapshot(household.Id);
    } catch (AuraHandledException e) {
      threw = true;
    }
    System.assert(
      threw,
      'Household accounts should not be treated as partner accounts.'
    );
  }
}
