public with sharing class WealthAIRunProposalCopilotAction {
  public class Request {
    @InvocableVariable(required=true label='Account Id')
    public Id accountId;
  }

  public class Result {
    @InvocableVariable(label='Run Id')
    public Id runId;
    @InvocableVariable(label='Recommendation Id')
    public Id recommendationId;
    @InvocableVariable(label='Tone')
    public String tone;
  }

  @InvocableMethod(
    label='Run Proposal Copilot'
    description='Runs the proposal copilot and returns recommendation details.'
  )
  public static List<Result> run(List<Request> requests) {
    List<Result> outputs = new List<Result>();
    for (Request req : requests) {
      WealthAIGrowthScaleService.ScaleActionResult serviceResult = WealthAIGrowthScaleService.runProposalCopilot(
        req.accountId
      );
      Result out = new Result();
      out.runId = serviceResult.runId;
      out.recommendationId = serviceResult.recordId;
      out.tone = serviceResult.tone;
      outputs.add(out);
    }
    return outputs;
  }
}
