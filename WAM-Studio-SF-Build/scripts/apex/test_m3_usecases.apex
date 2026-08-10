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

Integer startingPredictions = [
  SELECT COUNT()
  FROM Referral_Prediction__c
  WHERE Account__c = :acct.Id
];
Integer startingFindings = [
  SELECT COUNT()
  FROM Compliance_Finding__c
  WHERE Account__c = :acct.Id
];
Integer startingWorkflows = [
  SELECT COUNT()
  FROM Workflow_Execution__c
  WHERE Account__c = :acct.Id
];

WealthAIDistributionComplianceOpsService.WorkbenchActionResult scoring = WealthAIDistributionComplianceOpsService.runLeadScoring(
  acct.Id
);
System.debug(
  'M3 LEAD SCORING: ' + scoring.recordId + ' detail=' + scoring.detail
);
WealthAIDistributionComplianceOpsService.WorkbenchActionResult prioritization = WealthAIDistributionComplianceOpsService.runLeadPrioritization(
  acct.Id
);
System.debug(
  'M3 LEAD PRIORITIZATION: ' +
    prioritization.recordId +
    ' detail=' +
    prioritization.detail
);
WealthAIDistributionComplianceOpsService.WorkbenchActionResult research = WealthAIDistributionComplianceOpsService.runProspectResearch(
  acct.Id
);
System.debug(
  'M3 PROSPECT RESEARCH: ' + research.recordId + ' detail=' + research.detail
);

WealthAIDistributionComplianceOpsService.WorkbenchActionResult kyc = WealthAIDistributionComplianceOpsService.runKYCCopilot(
  acct.Id
);
System.debug('M3 KYC: ' + kyc.recordId + ' detail=' + kyc.detail);
WealthAIDistributionComplianceOpsService.WorkbenchActionResult aml = WealthAIDistributionComplianceOpsService.runAMLScreening(
  acct.Id
);
System.debug('M3 AML: ' + aml.recordId + ' detail=' + aml.detail);
WealthAIDistributionComplianceOpsService.WorkbenchActionResult regulatory = WealthAIDistributionComplianceOpsService.runRegulatoryMonitoring(
  acct.Id
);
System.debug(
  'M3 REGULATORY: ' + regulatory.recordId + ' detail=' + regulatory.detail
);

WealthAIDistributionComplianceOpsService.WorkbenchActionResult onboarding = WealthAIDistributionComplianceOpsService.runOnboardingAssistant(
  acct.Id
);
System.debug(
  'M3 ONBOARDING: ' + onboarding.recordId + ' detail=' + onboarding.detail
);
WealthAIDistributionComplianceOpsService.WorkbenchActionResult extraction = WealthAIDistributionComplianceOpsService.runDocumentExtraction(
  acct.Id
);
System.debug(
  'M3 DOCUMENT EXTRACTION: ' +
    extraction.recordId +
    ' detail=' +
    extraction.detail
);
WealthAIDistributionComplianceOpsService.WorkbenchActionResult workflow = WealthAIDistributionComplianceOpsService.runWorkflowAutomation(
  acct.Id
);
System.debug(
  'M3 WORKFLOW AUTOMATION: ' + workflow.recordId + ' detail=' + workflow.detail
);

Integer endingPredictions = [
  SELECT COUNT()
  FROM Referral_Prediction__c
  WHERE Account__c = :acct.Id
];
Integer endingFindings = [
  SELECT COUNT()
  FROM Compliance_Finding__c
  WHERE Account__c = :acct.Id
];
Integer endingWorkflows = [
  SELECT COUNT()
  FROM Workflow_Execution__c
  WHERE Account__c = :acct.Id
];

System.debug(
  'M3 COUNTS: predictions=' +
    endingPredictions +
    ' (+' +
    (endingPredictions - startingPredictions) +
    '), findings=' +
    endingFindings +
    ' (+' +
    (endingFindings - startingFindings) +
    '), workflows=' +
    endingWorkflows +
    ' (+' +
    (endingWorkflows - startingWorkflows) +
    ')'
);
