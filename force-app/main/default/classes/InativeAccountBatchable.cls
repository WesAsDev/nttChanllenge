public with sharing class InativeAccountBatchable implements Database.Batchable<Account> {

    public List<account> accList = new List<account>();
    
    public List<account> start(Database.BatchableContext BC){
        return accList;
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){

        for(account acc: scope){
            system.debug(acc.opportunities);
            system.debug(acc.tasks);
            if(acc.opportunities.size() == 0 && acc.tasks.size() == 0 ){
               acc.inativa__c = true;
               continue;
            }


            if(acc.opportunities.size() >= 1){

                Date last120Days = Date.today().addDays(-120);
                for(Opportunity opportuni :acc.opportunities){
                    acc.inativa__c = false;

                    if(opportuni.stagename == 'Negotiation/Review'){
                        break;
                    }

                    if(opportuni.stagename == 'Closed Won' && opportuni.CloseDate > last120Days){
                        break;
                    }

                    
                    acc.inativa__c = true;
                    
                }
    
            }

            if(acc.tasks.size() >= 1 && ((acc.opportunities.size() >= 1 && acc.inativa__c == true) || acc.opportunities.size() == 0)){
                DateTime last90Days = DateTime.now().addDays(-90);
                for(Task tsk :acc.tasks){
                    acc.inativa__c = false;

                    if(tsk.CreatedDate > last90Days){
                        break;
                    }
       
                    acc.inativa__c = true;
                    
                }
    
            }


        }
        
        upsert scope;
    }

    public void finish(Database.BatchableContext BC){

    }
}