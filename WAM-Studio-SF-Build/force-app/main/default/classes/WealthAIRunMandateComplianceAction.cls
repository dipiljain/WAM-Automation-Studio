public with sharing class WealthAIRunMandateComplianceAction {
  public class Request {
    @InvocableVariable(required=true label='Account Name')
    public String Account_Name;
  }

  public class Result {
    @InvocableVariable(label='Run Id')
    public Id runId;
    @InvocableVariable(label='Mandate Id')
    public Id mandateId;
    @InvocableVariable(label='Detail')
    public String detail;
    @InvocableVariable(label='Error Message')
    public String errorMessage;
  }

  @InvocableMethod(
    label='Run Mandate Compliance Check'
    description='Resolves the institutional account by name and runs a mandate/IPS compliance check, returning the created mandate record.'
  )
  public static List<Result> run(List<Request> requests) {
    List<Result> outputs = new List<Result>();
    for (Request req : requests) {
      Result out = new Result();
      Id accountId = WealthAIInstitutionalUseCaseService.resolveInstitutionalAccountId(
        req.Account_Name
      );
      if (accountId == null) {
        out.errorMessage =
          'No matching institutional account found for "' +
          req.Account_Name +
          '".';
        outputs.add(out);
        continue;
      }
      WealthAIInstitutionalUseCaseService.ActionResult serviceResult = WealthAIInstitutionalUseCaseService.runMandateComplianceCheck(
        accountId
      );
      out.runId = serviceResult.runId;
      out.mandateId = serviceResult.recordId;
      out.detail = serviceResult.detail;
      outputs.add(out);
    }
    return outputs;
  }
}
