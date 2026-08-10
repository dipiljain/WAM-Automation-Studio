@isTest
public class WamTestDataFactory {
  public static Account createHousehold(String name) {
    Account household = new Account(Name = name);
    insert household;
    return household;
  }

  public static Account createBusinessAccount(String name) {
    Account business = new Account(
      Name = name,
      RecordTypeId = businessRecordTypeId()
    );
    insert business;
    return business;
  }

  public static Account createChildHousehold(String name, Id parentId) {
    Account child = new Account(Name = name, ParentId = parentId);
    insert child;
    return child;
  }

  private static Id businessRecordTypeId() {
    return [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Account' AND DeveloperName = 'Business'
      LIMIT 1
    ]
    .Id;
  }

  public static AI_Agent_Run__c createAgentRun(String statusValue) {
    AI_Agent_Run__c runRecord = new AI_Agent_Run__c(
      Agent_Name__c = 'Test Agent',
      Persona__c = 'Advisor',
      Status__c = statusValue
    );
    insert runRecord;
    return runRecord;
  }

  public static AI_Recommendation__c createRecommendation(
    Id accountId,
    String priority
  ) {
    AI_Recommendation__c rec = new AI_Recommendation__c(
      Account__c = accountId,
      Recommendation_Type__c = 'Rebalance',
      Recommended_Action__c = 'Schedule a rebalance review.',
      Priority__c = priority,
      Status__c = 'New'
    );
    insert rec;
    return rec;
  }
}
