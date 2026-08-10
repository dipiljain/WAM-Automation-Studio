public with sharing class WealthAIRunPortfolioHealthAction {
  public class Request {
    @InvocableVariable(required=true label='Account Id')
    public Id accountId;
  }

  public class Result {
    @InvocableVariable(label='Run Id')
    public Id runId;
    @InvocableVariable(label='Alert Id')
    public Id alertId;
    @InvocableVariable(label='Severity')
    public String severity;
  }

  @InvocableMethod(
    label='Run Portfolio Health Analyzer'
    description='Runs portfolio health analysis and creates alert records.'
  )
  public static List<Result> run(List<Request> requests) {
    List<Result> outputs = new List<Result>();
    for (Request requestItem : requests) {
      WealthAIPortfolioUseCaseService.PortfolioActionResult result = WealthAIPortfolioUseCaseService.runPortfolioHealthAnalyzer(
        requestItem.accountId
      );
      Result output = new Result();
      output.runId = result.runId;
      output.alertId = result.recordId;
      output.severity = result.severity;
      outputs.add(output);
    }
    return outputs;
  }
}
