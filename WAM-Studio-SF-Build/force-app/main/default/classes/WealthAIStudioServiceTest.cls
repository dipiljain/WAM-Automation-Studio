@isTest
private class WealthAIStudioServiceTest {
    @isTest
    static void testRunLifecycle() {
        Test.startTest();
        AI_Agent_Run__c agentRun = WealthAIStudioService.startRun('Advisor Agent', 'Advisor', null);
        AI_Insight__c insight = WealthAIStudioService.logInsight(agentRun.Id, null, 'Portfolio', 'Allocation drift detected.', 90);
        AI_Recommendation__c rec = WealthAIStudioService.logRecommendation(agentRun.Id, null, 'Rebalance', 'Propose a rebalance.', 'High', 1200000);
        WealthAIStudioService.completeRun(agentRun.Id, 'Success');
        Test.stopTest();

        AI_Agent_Run__c reloaded = [SELECT Status__c, Completed__c FROM AI_Agent_Run__c WHERE Id = :agentRun.Id];
        System.assertEquals('Success', reloaded.Status__c, 'Run should be completed.');
        System.assertNotEquals(null, reloaded.Completed__c, 'Completed timestamp should be set.');
        System.assertEquals(1, [SELECT COUNT() FROM AI_Insight__c WHERE Id = :insight.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM AI_Recommendation__c WHERE Id = :rec.Id]);
    }

    @isTest
    static void testComputePriority() {
        System.assertEquals('High', WealthAIStudioService.computePriority(90, 600000));
        System.assertEquals('Medium', WealthAIStudioService.computePriority(70, 0));
        System.assertEquals('Medium', WealthAIStudioService.computePriority(0, 150000));
        System.assertEquals('Low', WealthAIStudioService.computePriority(10, 100));
        System.assertEquals('Low', WealthAIStudioService.computePriority(null, null));
    }

    @isTest
    static void testInvocable() {
        WealthAILogAgentRun.Request req = new WealthAILogAgentRun.Request();
        req.agentName = 'Advisor Agent';
        req.persona = 'Advisor';
        req.accountId = null;
        req.summary = 'Client mentioned an upcoming liquidity event.';
        req.confidence = 85;

        Test.startTest();
        List<WealthAILogAgentRun.Result> results = WealthAILogAgentRun.run(new List<WealthAILogAgentRun.Request>{ req });
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One result expected.');
        System.assertNotEquals(null, results[0].agentRunId, 'Agent run id should be returned.');
        System.assertNotEquals(null, results[0].insightId, 'Insight id should be returned.');
    }
}
