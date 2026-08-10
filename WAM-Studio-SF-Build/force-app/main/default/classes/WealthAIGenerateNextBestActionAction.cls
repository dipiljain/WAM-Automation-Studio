public with sharing class WealthAIGenerateNextBestActionAction {
  public class Request {
    @InvocableVariable(required=true label='Client Name')
    public String Client_Name;
  }

  public class Result {
    @InvocableVariable(label='Run Id')
    public Id runId;
    @InvocableVariable(label='Recommendation Id')
    public Id recommendationId;
    @InvocableVariable(label='Priority')
    public String priority;
    @InvocableVariable(label='Detail')
    public String detail;
    @InvocableVariable(label='Error Message')
    public String errorMessage;
  }

  @InvocableMethod(
    label='Generate Next Best Action'
    description='Resolves the client by name and runs the Advisor next-best-action engine, returning the created recommendation.'
  )
  public static List<Result> run(List<Request> requests) {
    List<Result> outputs = new List<Result>();
    for (Request req : requests) {
      Result out = new Result();
      Id accountId = WealthAIClient360DataProvider.resolveAccountId(
        req.Client_Name
      );
      if (accountId == null) {
        out.errorMessage =
          'No matching client/household found for "' +
          req.Client_Name +
          '".';
        outputs.add(out);
        continue;
      }
      WealthAIAdvisorUseCaseService.ActionResult serviceResult = WealthAIAdvisorUseCaseService.generateNextBestAction(
        accountId
      );
      out.runId = serviceResult.runId;
      out.recommendationId = serviceResult.recordId;
      out.priority = serviceResult.priority;
      out.detail = serviceResult.detail;
      outputs.add(out);
    }
    return outputs;
  }
}
