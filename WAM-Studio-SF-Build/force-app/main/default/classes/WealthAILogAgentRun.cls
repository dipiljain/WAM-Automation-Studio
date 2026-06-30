public with sharing class WealthAILogAgentRun {
    public class Request {
        @InvocableVariable(required=true label='Agent Name')
        public String agentName;
        @InvocableVariable(label='Persona')
        public String persona;
        @InvocableVariable(label='Account Id')
        public Id accountId;
        @InvocableVariable(label='Insight Type')
        public String insightType;
        @InvocableVariable(label='Summary')
        public String summary;
        @InvocableVariable(label='Confidence')
        public Decimal confidence;
    }

    public class Result {
        @InvocableVariable(label='Agent Run Id')
        public Id agentRunId;
        @InvocableVariable(label='Insight Id')
        public Id insightId;
    }

    @InvocableMethod(label='Log AI Agent Run' description='Creates an AI Agent Run and optional insight for the Wealth AI Studio.')
    public static List<Result> run(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            AI_Agent_Run__c agentRun = WealthAIStudioService.startRun(req.agentName, req.persona, req.accountId);
            Result res = new Result();
            res.agentRunId = agentRun.Id;
            if (String.isNotBlank(req.summary)) {
                String type = String.isBlank(req.insightType) ? 'Relationship' : req.insightType;
                Decimal conf = req.confidence == null ? 75 : req.confidence;
                AI_Insight__c insight = WealthAIStudioService.logInsight(agentRun.Id, req.accountId, type, req.summary, conf);
                res.insightId = insight.Id;
            }
            WealthAIStudioService.completeRun(agentRun.Id, 'Success');
            results.add(res);
        }
        return results;
    }
}
