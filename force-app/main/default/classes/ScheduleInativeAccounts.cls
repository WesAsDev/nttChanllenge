public with sharing class ScheduleInativeAccounts implements schedulable{
    public void execute(SchedulableContext SC) {
        List<account> acclist = new List<account>();
        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= today ORDER BY CreatedDate DESC) FROM Account WHERE inativa__c != true];
        
        InativeAccountBatchable inativeAccountBatch = new InativeAccountBatchable();
        inativeAccountBatch.accList = accList;
        Database.executeBatch(inativeAccountBatch);
     }
}