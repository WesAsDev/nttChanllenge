public with sharing class InsertAccountBatch implements Database.Batchable<Account> {

    public List<account> accList = new List<account>();
    
    public List<account> start(Database.BatchableContext BC){
        return accList;
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){

        insert scope;
    }

    public void finish(Database.BatchableContext BC){

    }
}