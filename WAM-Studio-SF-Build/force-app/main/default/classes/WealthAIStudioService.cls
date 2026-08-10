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

    public class FixResult {
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public String detail;
        @AuraEnabled
        public String nextStep;
    }

    @AuraEnabled
    public static FixResult generateActionableFix(Id accountId, String issueTitle, String issueDetail) {
        if (accountId == null) {
            throw new AuraHandledException('An account is required to generate a fix.');
        }
        Automation_Template__c template = ensureRemediationTemplate();
        String details = 'Remediation for "' +
            (String.isBlank(issueTitle) ? 'flagged item' : issueTitle) +
            '": ' +
            (String.isBlank(issueDetail) ? 'Review the flagged item and take corrective action.' : issueDetail);
        Workflow_Execution__c execution = new Workflow_Execution__c(
            Account__c = accountId,
            Automation_Template__c = template.Id,
            Status__c = 'Queued',
            Details__c = details
        );
        insert execution;

        FixResult result = new FixResult();
        result.recordId = execution.Id;
        result.detail = details;
        result.nextStep = 'Review and execute the queued remediation workflow.';
        return result;
    }

    private static Automation_Template__c ensureRemediationTemplate() {
        String templateName = 'WAM Remediation Template';
        List<Automation_Template__c> existing = [
            SELECT Id
            FROM Automation_Template__c
            WHERE Name = :templateName
            LIMIT 1
        ];
        if (!existing.isEmpty()) {
            return existing[0];
        }
        Automation_Template__c template = new Automation_Template__c(
            Name = templateName,
            Category__c = 'Remediation',
            Instructions__c = 'Auto-generated template for actionable-fix remediation workflows.'
        );
        insert template;
        return template;
    }
}
