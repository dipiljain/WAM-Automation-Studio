public with sharing class WealthAIRunPartnerGrowthAction {
  public class Request {
    @InvocableVariable(required=true label='Account Name')
    public String Account_Name;
  }

  public class Result {
    @InvocableVariable(label='Run Id')
    public Id runId;
    @InvocableVariable(label='Referral Id')
    public Id referralId;
    @InvocableVariable(label='Detail')
    public String detail;
    @InvocableVariable(label='Error Message')
    public String errorMessage;
  }

  @InvocableMethod(
    label='Run Autonomous Partner Growth Agent'
    description='Resolves the partner program by name and runs the autonomous partner growth agent, returning the created referral opportunity pending approval.'
  )
  public static List<Result> run(List<Request> requests) {
    List<Result> outputs = new List<Result>();
    for (Request req : requests) {
      Result out = new Result();
      Id accountId = WealthAIPartnerUseCaseService.resolvePartnerAccountId(
        req.Account_Name
      );
      if (accountId == null) {
        out.errorMessage =
          'No matching partner program found for "' +
          req.Account_Name +
          '".';
        outputs.add(out);
        continue;
      }
      WealthAIPartnerUseCaseService.ActionResult serviceResult = WealthAIPartnerUseCaseService.runAutonomousPartnerGrowthAgent(
        accountId
      );
      out.runId = serviceResult.runId;
      out.referralId = serviceResult.recordId;
      out.detail = serviceResult.detail;
      outputs.add(out);
    }
    return outputs;
  }
}
