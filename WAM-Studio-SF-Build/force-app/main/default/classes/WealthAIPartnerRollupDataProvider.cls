public with sharing class WealthAIPartnerRollupDataProvider {
  public class Request {
    @InvocableVariable(required=true label='Account Name')
    public String Account_Name;
  }

  public class Response {
    @InvocableVariable(label='Prompt')
    public String Prompt;
  }

  @InvocableMethod(
    label='Get Partner Rollup Context'
    description='Resolves a partner program (Business account with participant households) by name and returns grounded rollup facts for prompt grounding.'
  )
  public static List<Response> getPartnerContext(List<Request> requests) {
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
      return 'No partner program selected. Ask the program manager which partner to summarize. Do not invent details.';
    }
    Id accountId = WealthAIPartnerUseCaseService.resolvePartnerAccountId(
      accountName
    );
    if (accountId == null) {
      return 'No matching partner program found for "' +
        accountName +
        '". Do not invent details; ask for confirmation of the program name.';
    }
    Account acct = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
    WealthAIPartnerUseCaseService.PartnerRollupSnapshot snapshot = WealthAIPartnerUseCaseService.getPartnerRollupSnapshot(
      accountId
    );
    return 'Partner program: ' +
      acct.Name +
      '. Participant households: ' +
      snapshot.participantCount +
      '. At-risk participants: ' +
      snapshot.atRiskParticipants +
      '. Open referrals: ' +
      snapshot.openReferrals +
      '. Active workflows: ' +
      snapshot.activeWorkflows +
      '. Open compliance findings across participants: ' +
      snapshot.complianceFindings +
      '.';
  }
}
