public with sharing class WealthAIInstitutionalDataProvider {
  public class Request {
    @InvocableVariable(required=true label='Account Name')
    public String Account_Name;
  }

  public class Response {
    @InvocableVariable(label='Prompt')
    public String Prompt;
  }

  @InvocableMethod(
    label='Get Institutional Context'
    description='Resolves an institutional (Business, no parent) account by name and returns grounded mandate/risk facts for prompt grounding.'
  )
  public static List<Response> getInstitutionalContext(List<Request> requests) {
    List<Response> responses = new List<Response>();
    for (Request req : requests) {
      Response res = new Response();
      res.Prompt = buildContext(req.Account_Name);
      responses.add(res);
    }
    return responses;
  }

  private static String buildContext(String accountName) {
    if (String.isBlank(accountName)) {
      return 'No institutional account selected. Ask the relationship manager which account to summarize. Do not invent details.';
    }
    Id accountId = WealthAIInstitutionalUseCaseService.resolveInstitutionalAccountId(
      accountName
    );
    if (accountId == null) {
      return 'No matching institutional account found for "' +
        accountName +
        '". Do not invent details; ask for confirmation of the account name.';
    }
    Account acct = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
    WealthAIInstitutionalUseCaseService.InstitutionalSnapshot snapshot = WealthAIInstitutionalUseCaseService.getInstitutionalSnapshot(
      accountId
    );
    return 'Institutional account: ' +
      acct.Name +
      '. Mandates tracked: ' +
      snapshot.mandateCount +
      '. Mandate breaches: ' +
      snapshot.mandateBreaches +
      '. Open proposals: ' +
      snapshot.openProposals +
      '. Open compliance findings: ' +
      snapshot.openFindings +
      '. Open risk signals: ' +
      snapshot.openRiskSignals +
      '. Active workflows: ' +
      snapshot.activeWorkflows +
      '.';
  }
}
