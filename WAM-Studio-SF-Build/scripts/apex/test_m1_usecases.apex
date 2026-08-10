Account acct;
List<Account> rows = [SELECT Id, Name FROM Account WHERE Name = 'Sharma Family Office' LIMIT 1];
if (rows.isEmpty()) {
    acct = new Account(Name = 'Sharma Family Office');
    insert acct;
} else {
    acct = rows[0];
}

WealthAIAdvisorUseCaseService.ScoreResult scoreResult = WealthAIAdvisorUseCaseService.refreshScores(acct.Id);
System.debug('M1 SCORE RESULT: engagement=' + scoreResult.engagementScore + ' health=' + scoreResult.healthScore);

WealthAIAdvisorUseCaseService.ActionResult briefing = WealthAIAdvisorUseCaseService.generateAdvisorBriefing(acct.Id);
System.debug('M1 BRIEFING: ' + briefing.recordId + ' priority=' + briefing.priority);

WealthAIAdvisorUseCaseService.ActionResult relationship = WealthAIAdvisorUseCaseService.generateRelationshipInsight(acct.Id);
System.debug('M1 REL INSIGHT: ' + relationship.recordId);

WealthAIAdvisorUseCaseService.ActionResult nba = WealthAIAdvisorUseCaseService.generateNextBestAction(acct.Id);
System.debug('M1 NBA: ' + nba.recordId + ' priority=' + nba.priority);

System.debug('M1 COUNTS: briefings=' + [SELECT COUNT() FROM Advisor_Briefing__c WHERE Account__c = :acct.Id] +
    ', recommendations=' + [SELECT COUNT() FROM AI_Recommendation__c WHERE Account__c = :acct.Id] +
    ', insights=' + [SELECT COUNT() FROM AI_Insight__c WHERE Account__c = :acct.Id]);
