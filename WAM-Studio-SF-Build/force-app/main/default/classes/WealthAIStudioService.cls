public with sharing class WealthAIStudioService {
    public static AI_Agent_Run__c startRun(String agentName, String persona, Id relatedRecordId) {
        AI_Agent_Run__c run = new AI_Agent_Run__c(
            Agent_Name__c = agentName,
            Persona__c = persona,
            Status__c = 'Running',
            Started__c = System.now(),
            Run_User__c = UserInfo.getUserId(),
            Related_Record_Id__c = relatedRecordId == null ? null : String.valueOf(relatedRecordId)
        );
        insert run;
        return run;
    }

    public static void completeRun(Id runId, String status) {
        update new AI_Agent_Run__c(Id = runId, Status__c = status, Completed__c = System.now());
    }

    public static AI_Insight__c logInsight(Id runId, Id accountId, String insightType, String summary, Decimal confidence) {
        AI_Insight__c insight = new AI_Insight__c(
            AI_Agent_Run__c = runId,
            Account__c = accountId,
            Insight_Type__c = insightType,
            Summary__c = summary,
            Confidence__c = confidence,
            Status__c = 'New'
        );
        insert insight;
        return insight;
    }

    public static AI_Recommendation__c logRecommendation(Id runId, Id accountId, String recType, String action, String priority, Decimal expectedValue) {
        AI_Recommendation__c rec = new AI_Recommendation__c(
            AI_Agent_Run__c = runId,
            Account__c = accountId,
            Recommendation_Type__c = recType,
            Recommended_Action__c = action,
            Priority__c = priority,
            Expected_Value__c = expectedValue,
            Status__c = 'New'
        );
        insert rec;
        return rec;
    }

    public static String computePriority(Decimal confidence, Decimal expectedValue) {
        Decimal c = confidence == null ? 0 : confidence;
        Decimal v = expectedValue == null ? 0 : expectedValue;
        if (c >= 80 && v >= 500000) {
            return 'High';
        }
        if (c >= 60 || v >= 100000) {
            return 'Medium';
        }
        return 'Low';
    }
}
