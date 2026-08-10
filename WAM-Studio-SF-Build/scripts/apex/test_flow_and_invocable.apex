// STEP 3: record-triggered Flow (High priority recommendation -> Task)
Integer taskBefore = [SELECT COUNT() FROM Task WHERE Subject = 'Act on AI recommendation'];
AI_Agent_Run__c r = new AI_Agent_Run__c(Agent_Name__c = 'Flow Test', Persona__c = 'Advisor', Status__c = 'Success', Started__c = System.now());
insert r;
insert new AI_Recommendation__c(AI_Agent_Run__c = r.Id, Recommendation_Type__c = 'Rebalance', Recommended_Action__c = 'Flow test - High', Priority__c = 'High', Status__c = 'New');
insert new AI_Recommendation__c(AI_Agent_Run__c = r.Id, Recommendation_Type__c = 'Outreach', Recommended_Action__c = 'Flow test - Low', Priority__c = 'Low', Status__c = 'New');
Integer taskAfter = [SELECT COUNT() FROM Task WHERE Subject = 'Act on AI recommendation'];
System.debug('FLOW RESULT: tasks before=' + taskBefore + ' after=' + taskAfter + ' (expected +1 from the High rec only)');

// STEP 4: invocable action used by Flow/Agent
WealthAILogAgentRun.Request q = new WealthAILogAgentRun.Request();
q.agentName = 'Advisor Agent';
q.persona = 'Advisor';
q.summary = 'Client planning a liquidity event next quarter.';
q.confidence = 85;
List<WealthAILogAgentRun.Result> res = WealthAILogAgentRun.run(new List<WealthAILogAgentRun.Request>{ q });
System.debug('INVOCABLE RESULT: agentRunId=' + res[0].agentRunId + ' insightId=' + res[0].insightId);
AI_Agent_Run__c chk = [SELECT Status__c, Completed__c FROM AI_Agent_Run__c WHERE Id = :res[0].agentRunId];
System.debug('INVOCABLE RUN STATUS: ' + chk.Status__c + ' completed=' + (chk.Completed__c != null));
