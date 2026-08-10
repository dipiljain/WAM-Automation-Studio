public with sharing class WealthAIRefreshClientScoresAction {
  public class Request {
    @InvocableVariable(required=true label='Account Id')
    public Id accountId;
  }

  public class Result {
    @InvocableVariable(label='Account Id')
    public Id accountId;
    @InvocableVariable(label='Engagement Score')
    public Decimal engagementScore;
    @InvocableVariable(label='Health Score')
    public Decimal healthScore;
  }

  @InvocableMethod(
    label='Refresh Client Scores'
    description='Refreshes engagement and client health scores for selected accounts.'
  )
  public static List<Result> run(List<Request> requests) {
    List<Result> results = new List<Result>();
    for (Request req : requests) {
      WealthAIAdvisorUseCaseService.ScoreResult scoreResult = WealthAIAdvisorUseCaseService.refreshScores(
        req.accountId
      );
      Result out = new Result();
      out.accountId = scoreResult.accountId;
      out.engagementScore = scoreResult.engagementScore;
      out.healthScore = scoreResult.healthScore;
      results.add(out);
    }
    return results;
  }
}
