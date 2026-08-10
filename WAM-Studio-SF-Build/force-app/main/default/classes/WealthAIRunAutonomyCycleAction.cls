public with sharing class WealthAIRunAutonomyCycleAction {
  public class Request {
    @InvocableVariable(required=true label='Account Id')
    public Id accountId;
  }

  public class Result {
    @InvocableVariable(label='Run Id')
    public Id runId;
    @InvocableVariable(label='Record Id')
    public Id recordId;
    @InvocableVariable(label='Tone')
    public String tone;
  }

  @InvocableMethod(
    label='Run Autonomy Advisor Cycle'
    description='Runs the autonomous advisor cycle and returns run details.'
  )
  public static List<Result> run(List<Request> requests) {
    List<Result> outputs = new List<Result>();
    for (Request req : requests) {
      WealthAIAutonomyUseCaseService.AutonomyActionResult serviceResult = WealthAIAutonomyUseCaseService.runAutonomousAdvisorAgent(
        req.accountId
      );
      Result out = new Result();
      out.runId = serviceResult.runId;
      out.recordId = serviceResult.recordId;
      out.tone = serviceResult.tone;
      outputs.add(out);
    }
    return outputs;
  }
}
