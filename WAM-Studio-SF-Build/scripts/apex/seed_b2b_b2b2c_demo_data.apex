// Additive demo data seed for UC41-48 (Institutional / B2B) and UC49-56 (Partner / B2B2C).
// Safe to re-run: all inserts are gated on name-based existence checks.
Id businessRecordTypeId = [
  SELECT Id
  FROM RecordType
  WHERE SObjectType = 'Account' AND DeveloperName = 'Business'
  LIMIT 1
].Id;

DateTime nowTs = System.now();

// ---------------------------------------------------------------------------
// Institutional (B2B) accounts: standalone Business accounts, no children.
// ---------------------------------------------------------------------------
List<String> institutionalNames = new List<String>{
  'Meridian Pension Trust',
  'Alpine Endowment Foundation'
};

Map<String, Account> institutionalByName = new Map<String, Account>();
for (Account row : [
  SELECT Id, Name
  FROM Account
  WHERE Name IN :institutionalNames
]) {
  institutionalByName.put(row.Name, row);
}

List<Account> institutionalToInsert = new List<Account>();
for (String nameValue : institutionalNames) {
  if (!institutionalByName.containsKey(nameValue)) {
    institutionalToInsert.add(
      new Account(Name = nameValue, RecordTypeId = businessRecordTypeId)
    );
  }
}
if (!institutionalToInsert.isEmpty()) {
  insert institutionalToInsert;
  for (Account insertedRow : institutionalToInsert) {
    institutionalByName.put(insertedRow.Name, insertedRow);
  }
}

List<Account> orderedInstitutional = new List<Account>();
for (String nameValue : institutionalNames) {
  orderedInstitutional.add(institutionalByName.get(nameValue));
}

// ---------------------------------------------------------------------------
// Partner (B2B2C) accounts: Business accounts with Household participant
// children.
// ---------------------------------------------------------------------------
Map<String, List<String>> partnerToParticipants = new Map<String, List<String>>{
  'Horizon Retirement Platform' => new List<String>{
    'Chen Retirement Participant',
    'Okafor Retirement Participant',
    'Bianchi Retirement Participant'
  },
  'Summit Advisory Network' => new List<String>{
    'Alvarez Advisory Client',
    'Nakamura Advisory Client',
    'Dubois Advisory Client'
  }
};
List<String> partnerNames = new List<String>(partnerToParticipants.keySet());
partnerNames.sort();

Map<String, Account> partnerByName = new Map<String, Account>();
for (Account row : [SELECT Id, Name FROM Account WHERE Name IN :partnerNames]) {
  partnerByName.put(row.Name, row);
}

List<Account> partnerToInsert = new List<Account>();
for (String nameValue : partnerNames) {
  if (!partnerByName.containsKey(nameValue)) {
    partnerToInsert.add(
      new Account(Name = nameValue, RecordTypeId = businessRecordTypeId)
    );
  }
}
if (!partnerToInsert.isEmpty()) {
  insert partnerToInsert;
  for (Account insertedRow : partnerToInsert) {
    partnerByName.put(insertedRow.Name, insertedRow);
  }
}

List<Account> orderedPartners = new List<Account>();
for (String nameValue : partnerNames) {
  orderedPartners.add(partnerByName.get(nameValue));
}

List<String> allParticipantNames = new List<String>();
for (List<String> names : partnerToParticipants.values()) {
  allParticipantNames.addAll(names);
}

Map<String, Account> participantByName = new Map<String, Account>();
for (Account row : [
  SELECT Id, Name, ParentId
  FROM Account
  WHERE Name IN :allParticipantNames
]) {
  participantByName.put(row.Name, row);
}

List<Account> participantsToInsert = new List<Account>();
for (String partnerName : partnerNames) {
  Id parentId = partnerByName.get(partnerName).Id;
  for (String participantName : partnerToParticipants.get(partnerName)) {
    if (!participantByName.containsKey(participantName)) {
      participantsToInsert.add(
        new Account(Name = participantName, ParentId = parentId)
      );
    }
  }
}
if (!participantsToInsert.isEmpty()) {
  insert participantsToInsert;
  for (Account insertedRow : participantsToInsert) {
    participantByName.put(insertedRow.Name, insertedRow);
  }
}

// ---------------------------------------------------------------------------
// Institutional stakeholder contacts (drives getInstitutionalStakeholders).
// ---------------------------------------------------------------------------
Map<Id, List<String>> stakeholderLastNamesByAccount = new Map<Id, List<String>>{
  institutionalByName.get('Meridian Pension Trust')
    .Id => new List<String>{ 'Whitfield', 'Osei' },
  institutionalByName.get('Alpine Endowment Foundation')
    .Id => new List<String>{ 'Laurent' }
};
List<Contact> stakeholderContactsToInsert = new List<Contact>();
for (Id acctId : stakeholderLastNamesByAccount.keySet()) {
  Integer existingCount = [
    SELECT COUNT()
    FROM Contact
    WHERE AccountId = :acctId
  ];
  if (existingCount == 0) {
    for (String lastName : stakeholderLastNamesByAccount.get(acctId)) {
      stakeholderContactsToInsert.add(
        new Contact(AccountId = acctId, LastName = lastName)
      );
    }
  }
}
if (!stakeholderContactsToInsert.isEmpty()) {
  insert stakeholderContactsToInsert;
}

// ---------------------------------------------------------------------------
// Baseline AI_Agent_Run__c hydration for the new personas.
// ---------------------------------------------------------------------------
List<AI_Agent_Run__c> baselineRuns = new List<AI_Agent_Run__c>();
for (Integer i = 0; i < orderedInstitutional.size(); i++) {
  Account acct = orderedInstitutional[i];
  baselineRuns.add(
    new AI_Agent_Run__c(
      Agent_Name__c = 'DEMO Baseline Agent',
      Persona__c = 'Institutional',
      Status__c = 'Success',
      Started__c = nowTs.addMinutes(-(200 + i)),
      Completed__c = nowTs.addMinutes(-(195 + i)),
      Run_User__c = UserInfo.getUserId(),
      Related_Record_Id__c = String.valueOf(acct.Id),
      Autonomous_Mode__c = false,
      HITL_Status__c = 'Not Required',
      Plan_Summary__c = 'Baseline hydration run for institutional relationship metrics.'
    )
  );
}
for (Integer i = 0; i < orderedPartners.size(); i++) {
  Account acct = orderedPartners[i];
  baselineRuns.add(
    new AI_Agent_Run__c(
      Agent_Name__c = 'DEMO Baseline Agent',
      Persona__c = 'Partner',
      Status__c = 'Success',
      Started__c = nowTs.addMinutes(-(220 + i)),
      Completed__c = nowTs.addMinutes(-(215 + i)),
      Run_User__c = UserInfo.getUserId(),
      Related_Record_Id__c = String.valueOf(acct.Id),
      Autonomous_Mode__c = false,
      HITL_Status__c = 'Not Required',
      Plan_Summary__c = 'Baseline hydration run for partner rollup metrics.'
    )
  );
}
insert baselineRuns;

Map<Id, Id> baselineRunByAccount = new Map<Id, Id>();
for (AI_Agent_Run__c run : baselineRuns) {
  baselineRunByAccount.put(
    (Id) String.valueOf(run.Related_Record_Id__c),
    run.Id
  );
}

// ---------------------------------------------------------------------------
// Institutional data: mandates, risk signals, findings, proposals, workflows.
// ---------------------------------------------------------------------------
Account meridian = institutionalByName.get('Meridian Pension Trust');
Account alpine = institutionalByName.get('Alpine Endowment Foundation');

List<Institutional_Mandate__c> mandatesToInsert = new List<Institutional_Mandate__c>();
if (
  [SELECT COUNT() FROM Institutional_Mandate__c WHERE Account__c = :meridian.Id] ==
  0
) {
  mandatesToInsert.add(
    new Institutional_Mandate__c(
      Account__c = meridian.Id,
      AI_Agent_Run__c = baselineRunByAccount.get(meridian.Id),
      Mandate_Type__c = 'Investment Policy Statement',
      Allocation_Constraint__c = 'Public equity exposure capped at 55%; alternatives capped at 20%.',
      Compliance_Status__c = 'Compliant',
      Last_Reviewed__c = nowTs.addDays(-14)
    )
  );
}
if (
  [SELECT COUNT() FROM Institutional_Mandate__c WHERE Account__c = :alpine.Id] ==
  0
) {
  mandatesToInsert.add(
    new Institutional_Mandate__c(
      Account__c = alpine.Id,
      AI_Agent_Run__c = baselineRunByAccount.get(alpine.Id),
      Mandate_Type__c = 'Spending Policy Agreement',
      Allocation_Constraint__c = 'Illiquid alternatives capped at 25% of endowment corpus.',
      Compliance_Status__c = 'Breach',
      Breach_Detail__c = '1 open high-severity concentration signal exceeds IPS tolerance.',
      Last_Reviewed__c = nowTs.addDays(-2)
    )
  );
}
if (!mandatesToInsert.isEmpty()) {
  insert mandatesToInsert;
}

List<Risk_Signal__c> institutionalSignalsToInsert = new List<Risk_Signal__c>();
if (
  [SELECT COUNT() FROM Risk_Signal__c WHERE Account__c = :alpine.Id AND Signal_Type__c = 'Concentration'] ==
  0
) {
  institutionalSignalsToInsert.add(
    new Risk_Signal__c(
      Account__c = alpine.Id,
      AI_Agent_Run__c = baselineRunByAccount.get(alpine.Id),
      Signal_Type__c = 'Concentration',
      Severity__c = 'High',
      Summary__c = 'Endowment alternatives allocation exceeds mandate ceiling by 4 points.'
    )
  );
}
if (
  [SELECT COUNT() FROM Risk_Signal__c WHERE Account__c = :meridian.Id AND Signal_Type__c = 'Cash Movement'] ==
  0
) {
  institutionalSignalsToInsert.add(
    new Risk_Signal__c(
      Account__c = meridian.Id,
      AI_Agent_Run__c = baselineRunByAccount.get(meridian.Id),
      Signal_Type__c = 'Cash Movement',
      Severity__c = 'Low',
      Summary__c = 'Pension contribution inflows tracking within seasonal norms.'
    )
  );
}
if (!institutionalSignalsToInsert.isEmpty()) {
  insert institutionalSignalsToInsert;
}

List<Compliance_Finding__c> institutionalFindingsToInsert = new List<Compliance_Finding__c>();
for (Account acct : orderedInstitutional) {
  if (
    [SELECT COUNT() FROM Compliance_Finding__c WHERE Account__c = :acct.Id] ==
    0
  ) {
    institutionalFindingsToInsert.add(
      new Compliance_Finding__c(
        Account__c = acct.Id,
        Finding_Type__c = 'KYC',
        Status__c = 'Open'
      )
    );
  }
}
if (!institutionalFindingsToInsert.isEmpty()) {
  insert institutionalFindingsToInsert;
}

List<AI_Recommendation__c> institutionalProposalsToInsert = new List<AI_Recommendation__c>();
if (
  [SELECT COUNT() FROM AI_Recommendation__c WHERE Account__c = :meridian.Id AND Recommendation_Type__c = 'Proposal'] ==
  0
) {
  institutionalProposalsToInsert.add(
    new AI_Recommendation__c(
      AI_Agent_Run__c = baselineRunByAccount.get(meridian.Id),
      Account__c = meridian.Id,
      Recommendation_Type__c = 'Proposal',
      Recommended_Action__c = 'Draft institutional proposal for a liability-driven investment overlay.',
      Priority__c = 'High',
      Expected_Value__c = 2500000,
      Status__c = 'New'
    )
  );
}
if (!institutionalProposalsToInsert.isEmpty()) {
  insert institutionalProposalsToInsert;
}

Set<String> workflowCategories = new Set<String>{ 'Onboarding' };
Map<String, Automation_Template__c> templateByCategory = new Map<String, Automation_Template__c>();
for (Automation_Template__c row : [
  SELECT Id, Name, Category__c
  FROM Automation_Template__c
  WHERE Category__c IN :workflowCategories
]) {
  templateByCategory.put(row.Category__c, row);
}
List<Automation_Template__c> templatesToInsert = new List<Automation_Template__c>();
for (String category : workflowCategories) {
  if (!templateByCategory.containsKey(category)) {
    templatesToInsert.add(
      new Automation_Template__c(
        Name = 'WAM ' + category + ' Template',
        Category__c = category,
        Instructions__c = 'Demo template for ' + category + ' automation paths.'
      )
    );
  }
}
if (!templatesToInsert.isEmpty()) {
  insert templatesToInsert;
  for (Automation_Template__c insertedTemplate : templatesToInsert) {
    templateByCategory.put(insertedTemplate.Category__c, insertedTemplate);
  }
}

List<Workflow_Execution__c> institutionalWorkflowsToInsert = new List<Workflow_Execution__c>();
if (
  [SELECT COUNT() FROM Workflow_Execution__c WHERE Account__c = :alpine.Id] ==
  0
) {
  institutionalWorkflowsToInsert.add(
    new Workflow_Execution__c(
      Account__c = alpine.Id,
      Automation_Template__c = templateByCategory.get('Onboarding').Id,
      Status__c = 'Running',
      Details__c = 'Institutional KYB documentation workflow in progress.'
    )
  );
}
if (!institutionalWorkflowsToInsert.isEmpty()) {
  insert institutionalWorkflowsToInsert;
}

// ---------------------------------------------------------------------------
// Partner data: participant health scores, referrals, compliance findings,
// active workflows.
// ---------------------------------------------------------------------------
List<Client_Health_Score__c> participantHealthScoresToInsert = new List<Client_Health_Score__c>();
Map<String, Decimal> healthScoreByParticipant = new Map<String, Decimal>{
  'Chen Retirement Participant' => 42,
  'Okafor Retirement Participant' => 78,
  'Bianchi Retirement Participant' => 55,
  'Alvarez Advisory Client' => 38,
  'Nakamura Advisory Client' => 82,
  'Dubois Advisory Client' => 91
};
for (String participantName : allParticipantNames) {
  Account participant = participantByName.get(participantName);
  if (
    [SELECT COUNT() FROM Client_Health_Score__c WHERE Account__c = :participant.Id] ==
    0
  ) {
    participantHealthScoresToInsert.add(
      new Client_Health_Score__c(
        Account__c = participant.Id,
        Score__c = healthScoreByParticipant.get(participantName)
      )
    );
  }
}
if (!participantHealthScoresToInsert.isEmpty()) {
  insert participantHealthScoresToInsert;
}

List<Referral_Prediction__c> partnerReferralsToInsert = new List<Referral_Prediction__c>();
Account horizon = partnerByName.get('Horizon Retirement Platform');
Account summit = partnerByName.get('Summit Advisory Network');
if (
  [SELECT COUNT() FROM Referral_Prediction__c WHERE Account__c = :participantByName.get('Okafor Retirement Participant').Id] ==
  0
) {
  partnerReferralsToInsert.add(
    new Referral_Prediction__c(
      Account__c = participantByName.get('Okafor Retirement Participant').Id,
      Score__c = 79,
      Priority__c = 'High',
      Status__c = 'New',
      Notes__c = 'Cross-program referral opportunity identified for retirement plan rollover.'
    )
  );
}
if (
  [SELECT COUNT() FROM Referral_Prediction__c WHERE Account__c = :participantByName.get('Nakamura Advisory Client').Id] ==
  0
) {
  partnerReferralsToInsert.add(
    new Referral_Prediction__c(
      Account__c = participantByName.get('Nakamura Advisory Client').Id,
      Score__c = 71,
      Priority__c = 'Medium',
      Status__c = 'Queued',
      Notes__c = 'Cross-program referral opportunity identified for wealth advisory upgrade.'
    )
  );
}
if (!partnerReferralsToInsert.isEmpty()) {
  insert partnerReferralsToInsert;
}

List<Compliance_Finding__c> partnerFindingsToInsert = new List<Compliance_Finding__c>();
if (
  [SELECT COUNT() FROM Compliance_Finding__c WHERE Account__c = :participantByName.get('Alvarez Advisory Client').Id] ==
  0
) {
  partnerFindingsToInsert.add(
    new Compliance_Finding__c(
      Account__c = participantByName.get('Alvarez Advisory Client').Id,
      Finding_Type__c = 'KYC',
      Status__c = 'Escalated'
    )
  );
}
if (!partnerFindingsToInsert.isEmpty()) {
  insert partnerFindingsToInsert;
}

List<Workflow_Execution__c> partnerWorkflowsToInsert = new List<Workflow_Execution__c>();
if (
  [SELECT COUNT() FROM Workflow_Execution__c WHERE Account__c = :horizon.Id] ==
  0
) {
  partnerWorkflowsToInsert.add(
    new Workflow_Execution__c(
      Account__c = horizon.Id,
      Automation_Template__c = templateByCategory.get('Onboarding').Id,
      Status__c = 'Running',
      Details__c = 'Partner program batch onboarding in progress for new participant cohort.'
    )
  );
}
if (!partnerWorkflowsToInsert.isEmpty()) {
  insert partnerWorkflowsToInsert;
}

System.debug(
  'B2B/B2B2C demo data seed complete. Institutional accounts: ' +
    orderedInstitutional.size() +
    ', Partner accounts: ' +
    orderedPartners.size() +
    ', Participants: ' +
    allParticipantNames.size()
);
