class DemoSeedHelper {
  public String titleForUc(Integer uc) {
    Map<Integer, String> titles = new Map<Integer, String>{
      1 => 'AI Advisor Briefing',
      2 => 'Meeting Preparation Copilot',
      3 => 'AI Follow-up Generator',
      4 => 'Relationship Intelligence',
      5 => 'Next Best Action Engine',
      6 => 'Portfolio Health Analyzer',
      7 => 'Portfolio Review Copilot',
      8 => 'Portfolio Commentary Generator',
      9 => 'Risk Exposure Detection',
      10 => 'Client 360 Intelligence',
      11 => 'Engagement Scoring',
      12 => 'Client Health Score',
      13 => 'Lead Scoring',
      14 => 'Lead Prioritization',
      15 => 'Prospect Research Agent',
      16 => 'KYC Copilot',
      17 => 'AML Screening Assistant',
      18 => 'Regulatory Monitoring Agent',
      19 => 'Onboarding Assistant',
      20 => 'Document Extraction Agent',
      21 => 'Workflow Automation Agent',
      22 => 'Advisor Productivity Dashboard',
      23 => 'Revenue Intelligence Dashboard',
      24 => 'Proposal Copilot',
      25 => 'Referral Intelligence',
      26 => 'Cross-Sell Intelligence',
      27 => 'Scenario Analysis Agent',
      28 => 'Service Resolution Copilot',
      29 => 'Predictive Attrition',
      30 => 'Compliance Surveillance',
      31 => 'Reconciliation Assistant',
      32 => 'Cash Movement Intelligence',
      33 => 'Autonomous Advisor Agent',
      34 => 'Autonomous Service Agent',
      35 => 'Autonomous Operations Agent',
      36 => 'Autonomous Compliance Agent',
      37 => 'Autonomous Prospecting Agent',
      38 => 'AI Branch Manager',
      39 => 'Autonomous Portfolio Monitoring',
      40 => 'Hyper-Personalized Client Engagement'
    };
    return titles.get(uc);
  }

  public String personaForUc(Integer uc) {
    if (uc <= 5) {
      return 'Advisor';
    }
    if (uc <= 9) {
      return 'Portfolio';
    }
    if (uc <= 12) {
      return 'Advisor';
    }
    if (uc <= 15) {
      return 'Distribution';
    }
    if (uc <= 18) {
      return 'Compliance';
    }
    if (uc <= 21) {
      return 'Operations';
    }
    if (uc <= 23) {
      return 'Executive';
    }
    if (uc == 24 || uc == 26 || uc == 29 || uc == 40) {
      return 'Advisor';
    }
    if (uc == 25 || uc == 37) {
      return 'Distribution';
    }
    if (uc == 27 || uc == 39) {
      return 'Portfolio';
    }
    if (uc == 28 || uc == 34) {
      return 'Service';
    }
    if (uc == 30 || uc == 36) {
      return 'Compliance';
    }
    if (uc == 31 || uc == 32 || uc == 35) {
      return 'Operations';
    }
    if (uc == 38) {
      return 'Executive';
    }
    return 'Advisor';
  }

  public Boolean isAutonomous(Integer uc) {
    return uc >= 33;
  }

  public String hitlStatusForUc(Integer uc) {
    Set<Integer> pending = new Set<Integer>{ 33, 36, 37, 40 };
    if (!isAutonomous(uc)) {
      return 'Not Required';
    }
    return pending.contains(uc) ? 'Pending' : 'Not Required';
  }

  public String runStatusForUc(Integer uc) {
    Set<Integer> escalated = new Set<Integer>{ 33, 36, 37, 40 };
    return escalated.contains(uc) ? 'Escalated' : 'Success';
  }
}

List<String> accountNames = new List<String>{
  'Sharma Family Office',
  'Patel Legacy Partners',
  'Rao Global Family Trust',
  'Singh Multigenerational Wealth',
  'Mehta Strategic Holdings',
  'Kapoor Capital Advisory',
  'Iyer Horizon Family Desk',
  'Verma Private Wealth',
  'Nair Evergreen Portfolio',
  'Desai Premier Advisory'
};

Map<String, Account> accountsByName = new Map<String, Account>();
for (Account row : [
  SELECT Id, Name
  FROM Account
  WHERE Name IN :accountNames
]) {
  accountsByName.put(row.Name, row);
}

List<Account> accountsToInsert = new List<Account>();
for (String nameValue : accountNames) {
  if (!accountsByName.containsKey(nameValue)) {
    accountsToInsert.add(new Account(Name = nameValue));
  }
}
if (!accountsToInsert.isEmpty()) {
  insert accountsToInsert;
  for (Account insertedRow : accountsToInsert) {
    accountsByName.put(insertedRow.Name, insertedRow);
  }
}

List<Account> orderedAccounts = new List<Account>();
for (String nameValue : accountNames) {
  orderedAccounts.add(accountsByName.get(nameValue));
}

Id primaryAccountId = orderedAccounts[0].Id;
DateTime nowTs = System.now();
DemoSeedHelper helper = new DemoSeedHelper();

Set<String> templateCategories = new Set<String>{
  'Onboarding',
  'Document',
  'Workflow',
  'Service',
  'Reconciliation'
};
Map<String, Automation_Template__c> templateByCategory = new Map<String, Automation_Template__c>();
for (Automation_Template__c row : [
  SELECT Id, Name, Category__c
  FROM Automation_Template__c
  WHERE Category__c IN :templateCategories
]) {
  templateByCategory.put(row.Category__c, row);
}

List<Automation_Template__c> templatesToInsert = new List<Automation_Template__c>();
for (String category : templateCategories) {
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

List<AI_Agent_Run__c> baselineRuns = new List<AI_Agent_Run__c>();
for (Integer i = 0; i < orderedAccounts.size(); i++) {
  Account acct = orderedAccounts[i];
  String baselinePersona = Math.mod(i, 3) == 0
    ? 'Advisor'
    : Math.mod(i, 3) == 1 ? 'Compliance' : 'Executive';
  baselineRuns.add(
    new AI_Agent_Run__c(
      Agent_Name__c = 'DEMO Baseline Agent',
      Persona__c = baselinePersona,
      Status__c = 'Success',
      Started__c = nowTs.addMinutes(-(300 + i)),
      Completed__c = nowTs.addMinutes(-(295 + i)),
      Run_User__c = UserInfo.getUserId(),
      Related_Record_Id__c = String.valueOf(acct.Id),
      Autonomous_Mode__c = false,
      HITL_Status__c = 'Not Required',
      Plan_Summary__c = 'Baseline hydration run for persona and widget metrics.'
    )
  );
}
insert baselineRuns;

Map<Id, Id> baselineRunByAccount = new Map<Id, Id>();
for (Integer i = 0; i < orderedAccounts.size(); i++) {
  baselineRunByAccount.put(orderedAccounts[i].Id, baselineRuns[i].Id);
}

List<Engagement_Score__c> engagementScores = new List<Engagement_Score__c>();
List<Client_Health_Score__c> healthScores = new List<Client_Health_Score__c>();
for (Integer i = 0; i < orderedAccounts.size(); i++) {
  Account acct = orderedAccounts[i];
  Decimal engagement = Math.min(96, 48 + (i * 5));
  Decimal health = Math.min(94, 42 + (i * 5));
  engagementScores.add(
    new Engagement_Score__c(Account__c = acct.Id, Score__c = engagement)
  );
  healthScores.add(
    new Client_Health_Score__c(Account__c = acct.Id, Score__c = health)
  );
}
insert engagementScores;
insert healthScores;

List<AI_Agent_Run__c> ucRuns = new List<AI_Agent_Run__c>();
for (Integer uc = 1; uc <= 40; uc++) {
  String ucLabel = uc < 10 ? '0' + String.valueOf(uc) : String.valueOf(uc);
  ucRuns.add(
    new AI_Agent_Run__c(
      Agent_Name__c = 'DEMO-UC' + ucLabel + ' ' + helper.titleForUc(uc),
      Persona__c = helper.personaForUc(uc),
      Status__c = helper.runStatusForUc(uc),
      Started__c = nowTs.addMinutes(-(220 - uc)),
      Completed__c = nowTs.addMinutes(-(219 - uc)),
      Run_User__c = UserInfo.getUserId(),
      Related_Record_Id__c = String.valueOf(primaryAccountId),
      Autonomous_Mode__c = helper.isAutonomous(uc),
      HITL_Status__c = helper.hitlStatusForUc(uc),
      Plan_Summary__c = 'UC-' +
        uc +
        ' storyline: ' +
        helper.titleForUc(uc) +
        '.'
    )
  );
}
insert ucRuns;

Map<Integer, Id> ucRunIdByNumber = new Map<Integer, Id>();
for (Integer i = 0; i < ucRuns.size(); i++) {
  ucRunIdByNumber.put(i + 1, ucRuns[i].Id);
}

List<Advisor_Briefing__c> briefings = new List<Advisor_Briefing__c>{
  new Advisor_Briefing__c(
    Account__c = primaryAccountId,
    AI_Agent_Run__c = ucRunIdByNumber.get(1),
    Briefing_Date__c = Date.today(),
    Briefing_Summary__c = 'Daily AI briefing with goals, risk posture, and open opportunities.',
    Priority__c = 'High'
  )
};

List<Meeting_Summary__c> meetingSummaries = new List<Meeting_Summary__c>{
  new Meeting_Summary__c(
    Account__c = primaryAccountId,
    Summary__c = 'Meeting prep generated agenda with portfolio, compliance, and growth talking points.',
    Action_Items__c = '1) Review drift alerts, 2) discuss referral plan, 3) confirm onboarding tasks.'
  )
};

List<AI_Conversation__c> conversations = new List<AI_Conversation__c>{
  new AI_Conversation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(2),
    Role__c = 'user',
    Message__c = 'Prepare me for tomorrow’s client meeting.'
  ),
  new AI_Conversation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(2),
    Role__c = 'assistant',
    Message__c = 'Agenda, talking points, and action plan generated.'
  ),
  new AI_Conversation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(3),
    Role__c = 'user',
    Message__c = 'Draft a follow-up email with personalized next steps.'
  ),
  new AI_Conversation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(3),
    Role__c = 'assistant',
    Message__c = 'Follow-up draft ready with compliance-safe phrasing.'
  )
};

List<AI_Insight__c> insights = new List<AI_Insight__c>{
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(4),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Relationship',
    Summary__c = 'Relationship graph detected a warm referral channel through a COI.',
    Confidence__c = 86,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(7),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Portfolio',
    Summary__c = 'Portfolio review highlights moderate concentration and tax-loss opportunities.',
    Confidence__c = 84,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(8),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Portfolio',
    Summary__c = 'Portfolio commentary generated in client-friendly language.',
    Confidence__c = 82,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(10),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Relationship',
    Summary__c = 'Client 360 intelligence unified interactions, holdings, and service history.',
    Confidence__c = 88,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(15),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Opportunity',
    Summary__c = 'Prospect research found two aligned opportunities for immediate outreach.',
    Confidence__c = 79,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(22),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Opportunity',
    Summary__c = 'Advisor productivity dashboard surfaced top actions by expected value.',
    Confidence__c = 83,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(23),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Opportunity',
    Summary__c = 'Revenue dashboard identified cross-sell pipeline worth prioritizing this week.',
    Confidence__c = 81,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(27),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Portfolio',
    Summary__c = 'Scenario analysis compared base, stress, and upside outcomes.',
    Confidence__c = 80,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(38),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Opportunity',
    Summary__c = 'AI branch manager highlighted coaching opportunities by team segment.',
    Confidence__c = 77,
    Status__c = 'New'
  ),
  new AI_Insight__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(40),
    Account__c = primaryAccountId,
    Insight_Type__c = 'Relationship',
    Summary__c = 'Hyper-personalization engine selected best channel and messaging moment.',
    Confidence__c = 85,
    Status__c = 'New'
  )
};

List<AI_Recommendation__c> recommendations = new List<AI_Recommendation__c>{
  new AI_Recommendation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(3),
    Account__c = primaryAccountId,
    Recommendation_Type__c = 'Outreach',
    Recommended_Action__c = 'Send a same-day follow-up with summarized commitments and next steps.',
    Priority__c = 'Medium',
    Expected_Value__c = 90000,
    Status__c = 'New'
  ),
  new AI_Recommendation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(5),
    Account__c = primaryAccountId,
    Recommendation_Type__c = 'Retention',
    Recommended_Action__c = 'Schedule strategic review and retention play this week.',
    Priority__c = 'High',
    Expected_Value__c = 480000,
    Status__c = 'New'
  ),
  new AI_Recommendation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(24),
    Account__c = primaryAccountId,
    Recommendation_Type__c = 'Proposal',
    Recommended_Action__c = 'Draft proposal with goals, model allocation, and fee narrative.',
    Priority__c = 'High',
    Expected_Value__c = 320000,
    Status__c = 'New'
  ),
  new AI_Recommendation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(26),
    Account__c = primaryAccountId,
    Recommendation_Type__c = 'Cross-Sell',
    Recommended_Action__c = 'Propose retirement income sleeve and lending cross-sell package.',
    Priority__c = 'Medium',
    Expected_Value__c = 210000,
    Status__c = 'New'
  ),
  new AI_Recommendation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(29),
    Account__c = primaryAccountId,
    Recommendation_Type__c = 'Retention',
    Recommended_Action__c = 'Initiate retention outreach with personalized service touchpoint.',
    Priority__c = 'High',
    Expected_Value__c = 410000,
    Status__c = 'New'
  ),
  new AI_Recommendation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(33),
    Account__c = primaryAccountId,
    Recommendation_Type__c = 'Outreach',
    Recommended_Action__c = 'Autonomous advisor drafted proactive outreach, pending human approval.',
    Priority__c = 'High',
    Expected_Value__c = 250000,
    Status__c = 'New'
  ),
  new AI_Recommendation__c(
    AI_Agent_Run__c = ucRunIdByNumber.get(40),
    Account__c = primaryAccountId,
    Recommendation_Type__c = 'Outreach',
    Recommended_Action__c = 'Send personalized market pulse and suggest strategy check-in.',
    Priority__c = 'Medium',
    Expected_Value__c = 180000,
    Status__c = 'New'
  )
};

List<Portfolio_Alert__c> portfolioAlerts = new List<Portfolio_Alert__c>{
  new Portfolio_Alert__c(
    Account__c = primaryAccountId,
    Alert_Type__c = 'Drift',
    Severity__c = 'High'
  ),
  new Portfolio_Alert__c(
    Account__c = primaryAccountId,
    Alert_Type__c = 'Risk',
    Severity__c = 'Critical'
  ),
  new Portfolio_Alert__c(
    Account__c = primaryAccountId,
    Alert_Type__c = 'Drift',
    Severity__c = 'High'
  )
};

List<Risk_Signal__c> riskSignals = new List<Risk_Signal__c>{
  new Risk_Signal__c(
    Account__c = primaryAccountId,
    AI_Agent_Run__c = ucRunIdByNumber.get(9),
    Signal_Type__c = 'Concentration',
    Severity__c = 'High',
    Summary__c = 'Risk exposure detection identified concentration beyond target band.'
  ),
  new Risk_Signal__c(
    Account__c = primaryAccountId,
    AI_Agent_Run__c = ucRunIdByNumber.get(29),
    Signal_Type__c = 'Attrition',
    Severity__c = 'High',
    Summary__c = 'Predictive attrition model indicates elevated churn probability.'
  ),
  new Risk_Signal__c(
    Account__c = primaryAccountId,
    AI_Agent_Run__c = ucRunIdByNumber.get(32),
    Signal_Type__c = 'Cash Movement',
    Severity__c = 'High',
    Summary__c = 'Cash movement anomaly detected compared with historical activity.'
  ),
  new Risk_Signal__c(
    Account__c = primaryAccountId,
    AI_Agent_Run__c = ucRunIdByNumber.get(39),
    Signal_Type__c = 'Drift',
    Severity__c = 'Critical',
    Summary__c = 'Autonomous monitor triggered critical drift alert and escalation.'
  )
};

List<Compliance_Finding__c> findings = new List<Compliance_Finding__c>{
  new Compliance_Finding__c(
    Account__c = primaryAccountId,
    Finding_Type__c = 'KYC',
    Status__c = 'Open'
  ),
  new Compliance_Finding__c(
    Account__c = primaryAccountId,
    Finding_Type__c = 'AML',
    Status__c = 'Under Review'
  ),
  new Compliance_Finding__c(
    Account__c = primaryAccountId,
    Finding_Type__c = 'Regulatory',
    Status__c = 'Open'
  ),
  new Compliance_Finding__c(
    Account__c = primaryAccountId,
    Finding_Type__c = 'Surveillance',
    Status__c = 'Under Review'
  ),
  new Compliance_Finding__c(
    Account__c = primaryAccountId,
    Finding_Type__c = 'Surveillance',
    Status__c = 'Escalated'
  )
};

List<Referral_Prediction__c> referrals = new List<Referral_Prediction__c>{
  new Referral_Prediction__c(
    Account__c = primaryAccountId,
    Score__c = 74,
    Priority__c = 'Medium',
    Status__c = 'New',
    Notes__c = 'Lead scoring generated from engagement and relationship context.'
  ),
  new Referral_Prediction__c(
    Account__c = primaryAccountId,
    Score__c = 81,
    Priority__c = 'High',
    Status__c = 'Queued',
    Notes__c = 'Lead prioritization queued for distribution specialist review.'
  ),
  new Referral_Prediction__c(
    Account__c = primaryAccountId,
    Score__c = 77,
    Priority__c = 'High',
    Status__c = 'Queued',
    Notes__c = 'Referral intelligence identified warm path to new household.'
  ),
  new Referral_Prediction__c(
    Account__c = primaryAccountId,
    Score__c = 69,
    Priority__c = 'Medium',
    Status__c = 'New',
    Notes__c = 'Autonomous prospecting generated a new lead with next action.'
  )
};

List<Workflow_Execution__c> workflows = new List<Workflow_Execution__c>{
  new Workflow_Execution__c(
    Account__c = primaryAccountId,
    Automation_Template__c = templateByCategory.get('Onboarding').Id,
    Status__c = 'Completed',
    Details__c = 'Onboarding assistant prepared checklist and assigned owners.'
  ),
  new Workflow_Execution__c(
    Account__c = primaryAccountId,
    Automation_Template__c = templateByCategory.get('Document').Id,
    Status__c = 'Completed',
    Details__c = 'Document extraction completed with confidence scoring.'
  ),
  new Workflow_Execution__c(
    Account__c = primaryAccountId,
    Automation_Template__c = templateByCategory.get('Workflow').Id,
    Status__c = 'Running',
    Details__c = 'Workflow automation agent orchestrating downstream steps.'
  ),
  new Workflow_Execution__c(
    Account__c = primaryAccountId,
    Automation_Template__c = templateByCategory.get('Service').Id,
    Status__c = 'Completed',
    Details__c = 'Service resolution copilot generated client-ready response.'
  ),
  new Workflow_Execution__c(
    Account__c = primaryAccountId,
    Automation_Template__c = templateByCategory.get('Reconciliation').Id,
    Status__c = 'Completed',
    Details__c = 'Reconciliation assistant matched records and queued exceptions.'
  ),
  new Workflow_Execution__c(
    Account__c = primaryAccountId,
    Automation_Template__c = templateByCategory.get('Service').Id,
    Status__c = 'Running',
    Details__c = 'Autonomous service cycle processing entitlement checks.'
  ),
  new Workflow_Execution__c(
    Account__c = primaryAccountId,
    Automation_Template__c = templateByCategory.get('Workflow').Id,
    Status__c = 'Running',
    Details__c = 'Autonomous operations cycle running exception routing flow.'
  )
};

List<String> secondaryRecTypes = new List<String>{
  'Cross-Sell',
  'Retention',
  'Outreach',
  'Proposal'
};
List<String> secondaryInsightTypes = new List<String>{
  'Relationship',
  'Portfolio',
  'Service',
  'Opportunity'
};
List<String> secondaryFindingTypes = new List<String>{
  'KYC',
  'AML',
  'Suitability',
  'Surveillance'
};
List<String> secondaryFindingStatuses = new List<String>{
  'Open',
  'Under Review',
  'Cleared',
  'Open'
};
List<String> secondarySignalTypes = new List<String>{
  'Volatility',
  'Suitability',
  'Drift',
  'Cash Movement'
};
List<String> secondarySignalSeverities = new List<String>{
  'Medium',
  'High',
  'Low',
  'High'
};
List<String> secondaryCategories = new List<String>{
  'Onboarding',
  'Document',
  'Workflow',
  'Service',
  'Reconciliation'
};

for (Integer i = 1; i < orderedAccounts.size(); i++) {
  Account acct = orderedAccounts[i];
  Id runId = baselineRunByAccount.get(acct.Id);
  recommendations.add(
    new AI_Recommendation__c(
      AI_Agent_Run__c = runId,
      Account__c = acct.Id,
      Recommendation_Type__c = secondaryRecTypes[
        Math.mod(i, secondaryRecTypes.size())
      ],
      Recommended_Action__c = 'Persona-tailored action for ' + acct.Name + '.',
      Priority__c = Math.mod(i, 3) == 0
        ? 'High'
        : Math.mod(i, 3) == 1 ? 'Medium' : 'Low',
      Expected_Value__c = 85000 + (i * 15000),
      Status__c = 'New'
    )
  );

  insights.add(
    new AI_Insight__c(
      AI_Agent_Run__c = runId,
      Account__c = acct.Id,
      Insight_Type__c = secondaryInsightTypes[
        Math.mod(i, secondaryInsightTypes.size())
      ],
      Summary__c = 'Widget support insight for ' + acct.Name + '.',
      Confidence__c = 72 + i,
      Status__c = 'New'
    )
  );

  findings.add(
    new Compliance_Finding__c(
      Account__c = acct.Id,
      Finding_Type__c = secondaryFindingTypes[
        Math.mod(i, secondaryFindingTypes.size())
      ],
      Status__c = secondaryFindingStatuses[
        Math.mod(i, secondaryFindingStatuses.size())
      ]
    )
  );

  portfolioAlerts.add(
    new Portfolio_Alert__c(
      Account__c = acct.Id,
      Alert_Type__c = Math.mod(i, 2) == 0 ? 'Risk' : 'Drift',
      Severity__c = Math.mod(i, 2) == 0 ? 'High' : 'Medium'
    )
  );

  riskSignals.add(
    new Risk_Signal__c(
      Account__c = acct.Id,
      AI_Agent_Run__c = runId,
      Signal_Type__c = secondarySignalTypes[
        Math.mod(i, secondarySignalTypes.size())
      ],
      Severity__c = secondarySignalSeverities[
        Math.mod(i, secondarySignalSeverities.size())
      ],
      Summary__c = 'Signal support for dashboard and panel validation on ' +
        acct.Name +
        '.'
    )
  );

  referrals.add(
    new Referral_Prediction__c(
      Account__c = acct.Id,
      Score__c = 58 + (i * 3),
      Priority__c = Math.mod(i, 3) == 0
        ? 'High'
        : Math.mod(i, 3) == 1 ? 'Medium' : 'Low',
      Status__c = Math.mod(i, 2) == 0 ? 'Queued' : 'New',
      Notes__c = 'Referral prediction generated for demo walkthrough.'
    )
  );

  String category = secondaryCategories[
    Math.mod(i, secondaryCategories.size())
  ];
  workflows.add(
    new Workflow_Execution__c(
      Account__c = acct.Id,
      Automation_Template__c = templateByCategory.get(category).Id,
      Status__c = Math.mod(i, 2) == 0 ? 'Running' : 'Completed',
      Details__c = category + ' workflow generated for cross-persona demo.'
    )
  );
}

insert briefings;
insert meetingSummaries;
insert conversations;
insert insights;
insert recommendations;
insert portfolioAlerts;
insert riskSignals;
insert findings;
insert referrals;
insert workflows;

Integer accountCount = [
  SELECT COUNT()
  FROM Account
  WHERE Name IN :accountNames
];
Integer ucRunCount = [
  SELECT COUNT()
  FROM AI_Agent_Run__c
  WHERE
    Related_Record_Id__c = :String.valueOf(primaryAccountId)
    AND Agent_Name__c LIKE 'DEMO-UC%'
];
Integer autonomousPending = [
  SELECT COUNT()
  FROM AI_Agent_Run__c
  WHERE
    Related_Record_Id__c = :String.valueOf(primaryAccountId)
    AND Autonomous_Mode__c = TRUE
    AND HITL_Status__c = 'Pending'
];

System.debug('DEMO DATA READY: accounts=' + accountCount);
System.debug(
  'DEMO DATA READY: ucRunCount=' +
    ucRunCount +
    ', autonomousPending=' +
    autonomousPending
);
System.debug(
  'DEMO DATA READY: recommendations=' +
    [
      SELECT COUNT()
      FROM AI_Recommendation__c
      WHERE Account__c = :primaryAccountId
    ] +
    ', insights=' +
    [SELECT COUNT() FROM AI_Insight__c WHERE Account__c = :primaryAccountId] +
    ', findings=' +
    [
      SELECT COUNT()
      FROM Compliance_Finding__c
      WHERE Account__c = :primaryAccountId
    ] +
    ', workflows=' +
    [
      SELECT COUNT()
      FROM Workflow_Execution__c
      WHERE Account__c = :primaryAccountId
    ]
);
