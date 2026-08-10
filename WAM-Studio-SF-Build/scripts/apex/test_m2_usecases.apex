Account acct;
List<Account> rows = [SELECT Id, Name FROM Account WHERE Name = 'Sharma Family Office' LIMIT 1];
if (rows.isEmpty()) {
    acct = new Account(Name = 'Sharma Family Office');
    insert acct;
} else {
    acct = rows[0];
}

WealthAIPortfolioUseCaseService.PortfolioActionResult health = WealthAIPortfolioUseCaseService.runPortfolioHealthAnalyzer(acct.Id);
System.debug('M2 HEALTH ALERT: ' + health.recordId + ' severity=' + health.severity);

WealthAIPortfolioUseCaseService.PortfolioActionResult review = WealthAIPortfolioUseCaseService.runPortfolioReviewCopilot(acct.Id);
System.debug('M2 REVIEW INSIGHT: ' + review.recordId);

WealthAIPortfolioUseCaseService.PortfolioActionResult commentary = WealthAIPortfolioUseCaseService.runPortfolioCommentaryGenerator(acct.Id);
System.debug('M2 COMMENTARY INSIGHT: ' + commentary.recordId);

WealthAIPortfolioUseCaseService.PortfolioActionResult risk = WealthAIPortfolioUseCaseService.runRiskExposureDetection(acct.Id);
System.debug('M2 RISK SIGNAL: ' + risk.recordId + ' severity=' + risk.severity);

System.debug('M2 COUNTS: alerts=' + [SELECT COUNT() FROM Portfolio_Alert__c WHERE Account__c = :acct.Id] +
    ', riskSignals=' + [SELECT COUNT() FROM Risk_Signal__c WHERE Account__c = :acct.Id] +
    ', portfolioInsights=' + [SELECT COUNT() FROM AI_Insight__c WHERE Account__c = :acct.Id AND Insight_Type__c = 'Portfolio']);
