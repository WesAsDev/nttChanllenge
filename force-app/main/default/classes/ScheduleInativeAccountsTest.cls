@isTest
public with sharing class ScheduleInativeAccountsTest {
    @TestSetup
    static void makeData(){
    
        // Account accToInsert2 = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        // Account accToInsert3 = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        // Account accToInsert4 = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        // Account accToInsert5 = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');

        // List<account> accsToInsert = new List<account>{accToInsert1, accToInsert2, accToInsert3, accToInsert4, accToInsert5};

        // insert accsToInsert;




        // Opportunity opp3 = new Opportunity(
        //     Name = 'TESTEdsf - Opp Parceiro',
        //     CloseDate = Date.today().addDays(-121),
        //     stageName = 'Closed Won',
        //     AccountId = accToInsert.id);
    
        // Database.SaveResult sResult = database.insert(accToInsert);
    }

    @isTest
    public static void testInativateAccountByOpportunityClosedPast120days(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');


        insert accToInsert;


        Opportunity opp = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-121),
            stageName = 'Closed Won',
            AccountId = accToInsert.id);

        insert opp;
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();

        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
       
        Date oppLastDate = Date.today().addDays(-121);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(Opportunity opportuni :acc.opportunities){
                if((opportuni.closeDate > oppLastDate || oppLastDate == null) && opportuni.stageName == 'Closed Won'){
                    oppLastDate = opportuni.CloseDate;
                }
            }
        }


        System.assert(acclist[0].inativa__c == true, 'Conta deveria estar inativa');
        System.assert(oppLastDate < Date.today().addDays(-120) || acclist[0].opportunities.size() == 0, 'Oportunidade tem que ter menos de 120 dias OU não deve existir nenhuma');
        
        
    }

    

    @isTest
    public static void testCantInativateAccountIfHasOpportunityClosedLessThan120Days(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        insert accToInsert;


        Opportunity opp = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-121),
            stageName = 'Closed Won',
            AccountId = accToInsert.id);

        Opportunity opp2 = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-80),
            stageName = 'Closed Won',
            AccountId = accToInsert.id);
        
    
        List<Opportunity> lstOpp = new List<opportunity>{opp, opp2};
        insert lstOpp;
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();

        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
        Date oppLastDate = Date.today().addDays(-121);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(Opportunity opportuni :acc.opportunities){
                if((opportuni.closeDate > oppLastDate || oppLastDate == null) && opportuni.stageName == 'Closed Won'){
                    oppLastDate = opportuni.CloseDate;
                }
            }
        }

        System.assert(acclist[0].inativa__c == false, 'Conta deveria estar ativa');
        System.assert(oppLastDate > Date.today().addDays(-120) && acclist[0].opportunities.size() >= 1, 'Tem que ter pelo menos uma oportunidade ganha e ela tem que estar dentro dos 120 dias');
        
        
    }


    @isTest
    public static void testCantInativateAccountByOpportunityPast120daysNegotiation(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        insert accToInsert;


        Opportunity opp = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-121),
            stageName = 'Closed Won',
            AccountId = accToInsert.id);

        Opportunity opp2 = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-200),
            stageName = 'Negotiation/Review',
            AccountId = accToInsert.id);

        List<Opportunity> lstOpp = new List<opportunity>{opp, opp2};
        insert lstOpp;
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();


        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
        Date oppLastDate = Date.today().addDays(-121);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(Opportunity opportuni :acc.opportunities){
                if((opportuni.closeDate > oppLastDate || oppLastDate == null) && opportuni.stageName == 'Closed Won'){
                    oppLastDate = opportuni.CloseDate;
                }
            }
        }

        System.assert(acclist[0].inativa__c == false, 'Conta deveria estar ativa por conta do Negotiation/review independentemente se tiver um closed won mais antigo');   
    }

    @isTest
    public static void testInativateAccountByTasksPast90days(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        insert accToInsert;


        Task tsk = new Task(
            Subject = 'Consumidor Final',
            WhatId = accToInsert.id,
            status = 'Not Started',
            Priority = 'Normal'

        );

        insert tsk;

        test.setCreatedDate(tsk.id, Datetime.now().addDays(-92));
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();


        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
        Datetime tskLastDate = Datetime.now().addDays(-91);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(task ts :acc.tasks){

                if((ts.CreatedDate > tskLastDate || tskLastDate == null)){
                    tskLastDate = ts.CreatedDate;
                }
            }
        }

        System.assert(acclist[0].inativa__c == true, 'Conta deveria estar ativa por conta da task ser atual');
        System.assert(tskLastDate <= datetime.now().addDays(-91), 'Task deveria estar em uma data dentro ou acima dos ultimos 90 dias');
    }


    @isTest
    public static void testCantInativateAccountByTasksIn90days(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        insert accToInsert;


        Task tsk = new Task(
            Subject = 'Consumidor Final',
            WhatId = accToInsert.id,
            status = 'Not Started',
            Priority = 'Normal'

        );

        insert tsk;

        test.setCreatedDate(tsk.id, Datetime.now().addDays(-10));
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();


        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
        Datetime tskLastDate = Datetime.now().addDays(-91);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(task ts :acc.tasks){

                if((ts.CreatedDate > tskLastDate || tskLastDate == null)){
                    tskLastDate = ts.CreatedDate;
                }
            }
        }

        System.assert(acclist[0].inativa__c == false, 'Conta deveria estar ativa por conta da task ser atual');
        System.assert(tskLastDate > datetime.now().addDays(-91), 'Task deveria estar em uma data dentro ou acima dos ultimos 90 dias');
    }

    @isTest
    public static void testCantInativateAccountByTasksIn90daysWithClosedWonPast120(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        insert accToInsert;


        Task tsk = new Task(
            Subject = 'Consumidor Final',
            WhatId = accToInsert.id,
            status = 'Not Started',
            Priority = 'Normal'

        );

        insert tsk;

        Opportunity opp = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-121),
            stageName = 'Closed Won',
            AccountId = accToInsert.id);

        insert opp;

        test.setCreatedDate(tsk.id, Datetime.now().addDays(-10));
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();


        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
        Datetime tskLastDate = Datetime.now().addDays(-91);
        Datetime oppLastDate = Datetime.now().addDays(-121);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(task ts :acc.tasks){

                if((ts.CreatedDate > tskLastDate || tskLastDate == null)){
                    tskLastDate = ts.CreatedDate;
                }

                for(Opportunity opportuni :acc.opportunities){
                    if((opportuni.closeDate > oppLastDate || oppLastDate == null) && opportuni.stageName == 'Closed Won'){
                        oppLastDate = opportuni.CloseDate;
                    }
                }
            }
        }

        System.assert(acclist[0].inativa__c == false, 'Conta deveria estar ativa por conta da task ser atual');
        System.assert(tskLastDate > datetime.now().addDays(-91), 'Task deveria estar em uma data dentro ou acima dos ultimos 90 dias');
    }

    @isTest
    public static void testCantInativateAccountByTasksPast90daysWithClosedWonIn120days(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        insert accToInsert;


        Task tsk = new Task(
            Subject = 'Consumidor Final',
            WhatId = accToInsert.id,
            status = 'Not Started',
            Priority = 'Normal'

        );

        insert tsk;

        Opportunity opp = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-50),
            stageName = 'Closed Won',
            AccountId = accToInsert.id);

        insert opp;

        test.setCreatedDate(tsk.id, Datetime.now().addDays(-90));
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();


        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
        Datetime tskLastDate = Datetime.now().addDays(-91);
        Datetime oppLastDate = Datetime.now().addDays(-121);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(task ts :acc.tasks){

                if((ts.CreatedDate > tskLastDate || tskLastDate == null)){
                    tskLastDate = ts.CreatedDate;
                }

                for(Opportunity opportuni :acc.opportunities){
                    if((opportuni.closeDate > oppLastDate || oppLastDate == null) && opportuni.stageName == 'Closed Won'){
                        oppLastDate = opportuni.CloseDate;
                    }
                }
            }
        }

        System.assert(acclist[0].inativa__c == false, 'Conta deveria estar ativa por conta da task ser atual');
        System.assert(oppLastDate > datetime.now().addDays(-121), 'Opp deveria estar em uma data dentro ou acima dos ultimos 120 dias');
        System.assert(tskLastDate <= datetime.now().addDays(-90), 'Conta deve permanecer ativa mesmo que não haja task no periodo de 90 dias');
    }

    @isTest
    public static void testCantInativateAccountByTasksIfHasOppNegotiation(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        insert accToInsert;


        Task tsk = new Task(
            Subject = 'Consumidor Final',
            WhatId = accToInsert.id,
            status = 'Not Started',
            Priority = 'Normal'

        );

        insert tsk;

        Opportunity opp = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-200),
            stageName = 'Negotiation/Review',
            AccountId = accToInsert.id);

        insert opp;

        test.setCreatedDate(tsk.id, Datetime.now().addDays(-200));
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();


        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
        Datetime tskLastDate = Datetime.now().addDays(-91);
        Datetime oppLastDate = Datetime.now().addDays(-121);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(task ts :acc.tasks){

                if((ts.CreatedDate > tskLastDate || tskLastDate == null)){
                    tskLastDate = ts.CreatedDate;
                }

                for(Opportunity opportuni :acc.opportunities){
                    if((opportuni.closeDate > oppLastDate || oppLastDate == null) && opportuni.stageName == 'Closed Won'){
                        oppLastDate = opportuni.CloseDate;
                    }
                }
            }
        }

        System.assert(acclist[0].inativa__c == false && tskLastDate <= datetime.now().addDays(-90), 'Conta deve permanecer ativa em negotiation mesmo que a task esteja tenha saido do intervalo de 90 dias');
    }

    @isTest
    public static void testCantInativateAccountByOppIfHasTask(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        insert accToInsert;


        Task tsk = new Task(
            Subject = 'Consumidor Final',
            WhatId = accToInsert.id,
            status = 'Not Started',
            Priority = 'Normal'

        );

        insert tsk;

        Opportunity opp = new Opportunity(
            Name = 'TESTEdsf - Opp Parceiro',
            CloseDate = Date.today().addDays(-200),
            stageName = 'Closed Won',
            AccountId = accToInsert.id);

        insert opp;

        test.setCreatedDate(tsk.id, Datetime.now().addDays(-10));
        Test.startTest();
        new ScheduleInativeAccounts().execute(null);
        Test.stopTest();


        List<account> acclist = new List<account>();

        acclist = [select Id, name,inativa__c, (SELECT id, CloseDate, StageName FROM opportunities WHERE closedate <= TODAY ORDER BY CloseDate desc), (SELECT id,subject, CreatedDate FROM Tasks WHERE CreatedDate <= TODAY ORDER BY CreatedDate DESC) FROM Account];
        
        Datetime tskLastDate = Datetime.now().addDays(-91);
        Datetime oppLastDate = Datetime.now().addDays(-121);

        for(account acc: acclist){
            system.debug(acc.name); 
            system.debug(acc.inativa__c); 
            system.debug(acc.opportunities); 
            system.debug(acc.tasks); 

            for(task ts :acc.tasks){

                if((ts.CreatedDate > tskLastDate || tskLastDate == null)){
                    tskLastDate = ts.CreatedDate;
                }

                for(Opportunity opportuni :acc.opportunities){
                    if((opportuni.closeDate > oppLastDate || oppLastDate == null) && opportuni.stageName == 'Closed Won'){
                        oppLastDate = opportuni.CloseDate;
                    }
                }
            }
        }

        System.assert(acclist[0].inativa__c == false && tskLastDate >= datetime.now().addDays(-91), 'Conta deve permanecer ativa em negotiation mesmo que a task esteja tenha saido do intervalo de 90 dias');
    }
}