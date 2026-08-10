public with sharing class WealthAIClient360DataProvider {
  public class Request {
    @InvocableVariable(required=true label='Client Name')
    public String Client_Name;
  }

  public class Response {
    @InvocableVariable(label='Prompt')
    public String Prompt;
  }

  @InvocableMethod(
    label='Get Client 360 Context'
    description='Resolves a client/household name to an account and returns grounded Client 360 facts for prompt grounding.'
  )
  public static List<Response> getClientContext(List<Request> requests) {
    List<Response> responses = new List<Response>();
    for (Request req : requests) {
      Response res = new Response();
      res.Prompt = buildContext(req.Client_Name);
      responses.add(res);
    }
    return responses;
  }

  public static Id resolveAccountId(String clientName) {
    if (String.isBlank(clientName)) {
      return null;
    }
    List<Account> matches = [
      SELECT Id
      FROM Account
      WHERE Name LIKE :('%' + clientName + '%')
      ORDER BY Name
      LIMIT 1
    ];
    return matches.isEmpty() ? null : matches[0].Id;
  }

  private static String buildContext(String clientName) {
    if (String.isBlank(clientName)) {
      return 'No client selected. Ask the advisor which client or household to prepare for. Do not invent details.';
    }
    Id accountId = resolveAccountId(clientName);
    if (accountId == null) {
      return 'No matching client/household found for "' +
        clientName +
        '". Do not invent details; ask the advisor to confirm the client name.';
    }
    Account acct = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
    WealthAIAdvisorUseCaseService.Client360Snapshot snapshot = WealthAIAdvisorUseCaseService.getClient360(
      accountId
    );
    return 'Client: ' +
      acct.Name +
      '. Engagement Score: ' +
      formatScore(snapshot.engagementScore) +
      '. Client Health Score: ' +
      formatScore(snapshot.healthScore) +
      '. Open Recommendations: ' +
      snapshot.openRecommendations +
      '. New Insights: ' +
      snapshot.newInsights +
      '. Open Compliance Findings: ' +
      snapshot.openFindings +
      '. Critical/High Portfolio Alerts: ' +
      snapshot.criticalAlerts +
      '.';
  }

  private static String formatScore(Decimal score) {
    return score == null
      ? 'not yet computed'
      : String.valueOf(score.setScale(0));
  }
}
