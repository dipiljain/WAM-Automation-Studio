public with sharing class WealthAIRunLeadScoringAction {
  public class Request {
    @InvocableVariable(required=true label='Account Id')
    public Id accountId;
  }

  public class Result {
    @InvocableVariable(label='Run Id')
    public Id runId;
    @InvocableVariable(label='Prediction Id')
    public Id predictionId;
    @InvocableVariable(label='Tone')
    public String tone;
  }

  @InvocableMethod(
    label='Run Lead Scoring'
    description='Runs lead scoring and returns a referral prediction.'
  )
  public static List<Result> run(List<Request> requests) {
    List<Result> outputs = new List<Result>();
    for (Request req : requests) {
      WealthAIDistributionComplianceOpsService.WorkbenchActionResult actionResult = WealthAIDistributionComplianceOpsService.runLeadScoring(
        req.accountId
      );
      Result out = new Result();
      out.runId = actionResult.runId;
      out.predictionId = actionResult.recordId;
      out.tone = actionResult.tone;
      outputs.add(out);
    }
    return outputs;
  }
}
