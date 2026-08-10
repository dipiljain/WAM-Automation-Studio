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

Integer startRuns = [
  SELECT COUNT()
  FROM AI_Agent_Run__c
  WHERE Related_Record_Id__c = :acct.Id AND Autonomous_Mode__c = TRUE
];
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
Integer startAlerts = [
  SELECT COUNT()
  FROM Portfolio_Alert__c
  WHERE Account__c = :acct.Id
];
Integer startSignals = [
  SELECT COUNT()
  FROM Risk_Signal__c
  WHERE Account__c = :acct.Id
];

System.debug(
  'M5 UC33 ADVISOR: ' +
  WealthAIAutonomyUseCaseService.runAutonomousAdvisorAgent(acct.Id).recordId
);
System.debug(
  'M5 UC34 SERVICE: ' +
  WealthAIAutonomyUseCaseService.runAutonomousServiceAgent(acct.Id).recordId
);
System.debug(
  'M5 UC35 OPERATIONS: ' +
  WealthAIAutonomyUseCaseService.runAutonomousOperationsAgent(acct.Id).recordId
);
System.debug(
  'M5 UC36 COMPLIANCE: ' +
  WealthAIAutonomyUseCaseService.runAutonomousComplianceAgent(acct.Id).recordId
);
System.debug(
  'M5 UC37 PROSPECTING: ' +
  WealthAIAutonomyUseCaseService.runAutonomousProspectingAgent(acct.Id).recordId
);
System.debug(
  'M5 UC38 BRANCH-MANAGER: ' +
  WealthAIAutonomyUseCaseService.runAIBranchManager(acct.Id).recordId
);
System.debug(
  'M5 UC39 PORTFOLIO-MONITOR: ' +
  WealthAIAutonomyUseCaseService.runAutonomousPortfolioMonitoring(acct.Id)
    .recordId
);
System.debug(
  'M5 UC40 PERSONALIZATION: ' +
  WealthAIAutonomyUseCaseService.runHyperPersonalizedEngagement(acct.Id)
    .recordId
);

Integer endRuns = [
  SELECT COUNT()
  FROM AI_Agent_Run__c
  WHERE Related_Record_Id__c = :acct.Id AND Autonomous_Mode__c = TRUE
];
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
Integer endAlerts = [
  SELECT COUNT()
  FROM Portfolio_Alert__c
  WHERE Account__c = :acct.Id
];
Integer endSignals = [
  SELECT COUNT()
  FROM Risk_Signal__c
  WHERE Account__c = :acct.Id
];

System.debug(
  'M5 COUNTS: autonomousRuns=' +
    endRuns +
    ' (+' +
    (endRuns - startRuns) +
    '), recommendations=' +
    endRecommendations +
    ' (+' +
    (endRecommendations - startRecommendations) +
    '), referrals=' +
    endReferrals +
    ' (+' +
    (endReferrals - startReferrals) +
    '), findings=' +
    endFindings +
    ' (+' +
    (endFindings - startFindings) +
    '), workflows=' +
    endWorkflows +
    ' (+' +
    (endWorkflows - startWorkflows) +
    '), alerts=' +
    endAlerts +
    ' (+' +
    (endAlerts - startAlerts) +
    '), signals=' +
    endSignals +
    ' (+' +
    (endSignals - startSignals) +
    ')'
);
