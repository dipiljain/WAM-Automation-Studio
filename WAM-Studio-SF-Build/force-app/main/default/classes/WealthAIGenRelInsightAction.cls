public with sharing class WealthAIGenRelInsightAction {
  public class Request {
    @InvocableVariable(required=true label='Client Name')
    public String Client_Name;
  }

  public class Result {
    @InvocableVariable(label='Run Id')
    public Id runId;
    @InvocableVariable(label='Insight Id')
    public Id insightId;
    @InvocableVariable(label='Detail')
    public String detail;
    @InvocableVariable(label='Error Message')
    public String errorMessage;
  }

  @InvocableMethod(
    label='Generate Relationship Insight'
    description='Resolves the client by name and generates a grounded relationship insight, returning the created insight.'
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
      WealthAIAdvisorUseCaseService.ActionResult serviceResult = WealthAIAdvisorUseCaseService.generateRelationshipInsight(
        accountId
      );
      out.runId = serviceResult.runId;
      out.insightId = serviceResult.recordId;
      out.detail = serviceResult.detail;
      outputs.add(out);
    }
    return outputs;
  }
}
