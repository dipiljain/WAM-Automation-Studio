Account acct;
List<Account> rows = [
  SELECT Id, Name
  FROM Account
  WHERE Name = 'Sharma Family Office'
  LIMIT 1
];
if (rows.isEmpty()) {
  acct = new Account(Name = 'Sharma Family Office');
  insert acct;
} else {
  acct = rows[0];
}

Integer startRecommendations = [
  SELECT COUNT()
  FROM AI_Recommendation__c
  WHERE Account__c = :acct.Id
];
Integer startReferrals = [
  SELECT COUNT()
  FROM Referral_Prediction__c
  WHERE Account__c = :acct.Id
];
Integer startInsights = [
  SELECT COUNT()
  FROM AI_Insight__c
  WHERE Account__c = :acct.Id
];
Integer startFindings = [
  SELECT COUNT()
  FROM Compliance_Finding__c
  WHERE Account__c = :acct.Id
];
Integer startWorkflows = [
  SELECT COUNT()
  FROM Workflow_Execution__c
  WHERE Account__c = :acct.Id
];
Integer startSignals = [
  SELECT COUNT()
  FROM Risk_Signal__c
  WHERE Account__c = :acct.Id
];

System.debug(
  'M4 PROPOSAL: ' +
  WealthAIGrowthScaleService.runProposalCopilot(acct.Id).recordId
);
System.debug(
  'M4 REFERRAL: ' +
  WealthAIGrowthScaleService.runReferralIntelligence(acct.Id).recordId
);
System.debug(
  'M4 CROSS-SELL: ' +
  WealthAIGrowthScaleService.runCrossSellIntelligence(acct.Id).recordId
);
System.debug(
  'M4 SCENARIO: ' +
  WealthAIGrowthScaleService.runScenarioAnalysis(acct.Id).recordId
);
System.debug(
  'M4 SERVICE: ' +
  WealthAIGrowthScaleService.runServiceResolutionCopilot(acct.Id).recordId
);
System.debug(
  'M4 ATTRITION: ' +
  WealthAIGrowthScaleService.runPredictiveAttrition(acct.Id).recordId
);
System.debug(
  'M4 SURVEILLANCE: ' +
  WealthAIGrowthScaleService.runComplianceSurveillance(acct.Id).recordId
);
System.debug(
  'M4 RECONCILIATION: ' +
  WealthAIGrowthScaleService.runReconciliationAssistant(acct.Id).recordId
);
System.debug(
  'M4 CASH-MOVEMENT: ' +
  WealthAIGrowthScaleService.runCashMovementIntelligence(acct.Id).recordId
);

Integer endRecommendations = [
  SELECT COUNT()
  FROM AI_Recommendation__c
  WHERE Account__c = :acct.Id
];
Integer endReferrals = [
  SELECT COUNT()
  FROM Referral_Prediction__c
  WHERE Account__c = :acct.Id
];
Integer endInsights = [
  SELECT COUNT()
  FROM AI_Insight__c
  WHERE Account__c = :acct.Id
];
Integer endFindings = [
  SELECT COUNT()
  FROM Compliance_Finding__c
  WHERE Account__c = :acct.Id
];
Integer endWorkflows = [
  SELECT COUNT()
  FROM Workflow_Execution__c
  WHERE Account__c = :acct.Id
];
Integer endSignals = [
  SELECT COUNT()
  FROM Risk_Signal__c
  WHERE Account__c = :acct.Id
];

System.debug(
  'M4 COUNTS: recommendations=' +
    endRecommendations +
    ' (+' +
    (endRecommendations - startRecommendations) +
    '), referrals=' +
    endReferrals +
    ' (+' +
    (endReferrals - startReferrals) +
    '), insights=' +
    endInsights +
    ' (+' +
    (endInsights - startInsights) +
    '), findings=' +
    endFindings +
    ' (+' +
    (endFindings - startFindings) +
    '), workflows=' +
    endWorkflows +
    ' (+' +
    (endWorkflows - startWorkflows) +
    '), signals=' +
    endSignals +
    ' (+' +
    (endSignals - startSignals) +
    ')'
);
