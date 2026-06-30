// Wealth AI Studio - demo seed data (idempotent)
List<String> hhNames = new List<String>{'Sharma Family Office','Chen Household','Okafor Family Trust','Liang Prospect'};
Map<String, Account> byName = new Map<String, Account>();
for (Account a : [SELECT Id, Name FROM Account WHERE Name IN :hhNames]) {
    byName.put(a.Name, a);
}
List<Account> toInsert = new List<Account>();
for (String n : hhNames) {
    if (!byName.containsKey(n)) { toInsert.add(new Account(Name = n)); }
}
if (!toInsert.isEmpty()) {
    insert toInsert;
    for (Account a : toInsert) { byName.put(a.Name, a); }
}

Boolean seedAI = [SELECT COUNT() FROM AI_Recommendation__c] == 0;
if (!seedAI) {
    System.debug('AI demo data already present; only ensured Accounts.');
} else {
    Id me = UserInfo.getUserId();
    Account sharma = byName.get('Sharma Family Office');
    Account chen = byName.get('Chen Household');
    Account okafor = byName.get('Okafor Family Trust');
    Account liang = byName.get('Liang Prospect');

    AI_Agent_Run__c run = new AI_Agent_Run__c(
        Agent_Name__c = 'Wealth Advisor Agent', Persona__c = 'Advisor', Status__c = 'Success',
        Started__c = System.now().addMinutes(-5), Completed__c = System.now(), Run_User__c = me);
    insert run;

    insert new List<Client_Health_Score__c>{
        new Client_Health_Score__c(Account__c = sharma.Id, Score__c = 82),
        new Client_Health_Score__c(Account__c = chen.Id, Score__c = 64),
        new Client_Health_Score__c(Account__c = okafor.Id, Score__c = 91),
        new Client_Health_Score__c(Account__c = liang.Id, Score__c = 48)
    };

    insert new List<AI_Insight__c>{
        new AI_Insight__c(AI_Agent_Run__c = run.Id, Account__c = sharma.Id, Insight_Type__c = 'Portfolio', Summary__c = 'Equity allocation drifted 6% above target after the Q2 rally.', Confidence__c = 88, Status__c = 'New'),
        new AI_Insight__c(AI_Agent_Run__c = run.Id, Account__c = chen.Id, Insight_Type__c = 'Relationship', Summary__c = 'Client mentioned a liquidity event (business sale) in last interaction.', Confidence__c = 76, Status__c = 'New'),
        new AI_Insight__c(AI_Agent_Run__c = run.Id, Account__c = okafor.Id, Insight_Type__c = 'Opportunity', Summary__c = 'Held-away 401k rollover opportunity identified (about $640k).', Confidence__c = 81, Status__c = 'New'),
        new AI_Insight__c(AI_Agent_Run__c = run.Id, Account__c = chen.Id, Insight_Type__c = 'Risk', Summary__c = 'Engagement down: no advisor contact in 142 days.', Confidence__c = 70, Status__c = 'New')
    };

    insert new List<AI_Recommendation__c>{
        new AI_Recommendation__c(AI_Agent_Run__c = run.Id, Account__c = sharma.Id, Recommendation_Type__c = 'Rebalance', Recommended_Action__c = 'Schedule a rebalance review to bring equity back to the target band.', Priority__c = 'High', Expected_Value__c = 1200000, Status__c = 'New'),
        new AI_Recommendation__c(AI_Agent_Run__c = run.Id, Account__c = okafor.Id, Recommendation_Type__c = 'Cross-Sell', Recommended_Action__c = 'Propose held-away asset consolidation / rollover.', Priority__c = 'High', Expected_Value__c = 640000, Status__c = 'New'),
        new AI_Recommendation__c(AI_Agent_Run__c = run.Id, Account__c = chen.Id, Recommendation_Type__c = 'Retention', Recommended_Action__c = 'Proactive outreach; relationship is at risk.', Priority__c = 'Medium', Expected_Value__c = 300000, Status__c = 'New')
    };

    insert new List<Portfolio_Alert__c>{
        new Portfolio_Alert__c(Account__c = sharma.Id, Alert_Type__c = 'Drift', Severity__c = 'High'),
        new Portfolio_Alert__c(Account__c = chen.Id, Alert_Type__c = 'Cash', Severity__c = 'Medium')
    };

    insert new List<Advisor_Briefing__c>{ new Advisor_Briefing__c(), new Advisor_Briefing__c() };

    System.debug('Seed complete for households: ' + byName.keySet());
}
