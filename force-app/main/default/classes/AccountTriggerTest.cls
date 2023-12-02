@isTest
public with sharing class AccountTriggerTest {

    @isTest
    public static void testInsertAccountCPFWithValidNumber(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CPF');
        
        Database.SaveResult sResult = database.insert(accToInsert);
        

        System.assert(sResult.isSuccess(), 'A conta com CPF foi inserida com sucesso');
    }

    @isTest
    public static void testInsertAccountCNPJWithValidNumber(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
        
        Database.SaveResult sResult = database.insert(accToInsert);
        

        System.assert(sResult.isSuccess(), 'A conta com CNPJ foi inserida com sucesso');
    }

    @isTest
    public static void testInsertAccountCPFWithoutValidNumber(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','00000000000', 'CPF');
        try{
            Database.SaveResult sResult = database.insert(accToInsert);
            throw new AssertException('Um erro deveria ser desparado pela trigger');
        }catch(Exception e){
            Boolean expectedErrorMessage =  (e.getMessage().contains('Número do cliente é inválido'))? true : false;
            System.AssertEquals(expectedErrorMessage, true, 'A Mensagem de erro foi disparada como esperado');

        } 

    }

    @isTest
    public static void testInsertAccountCNPJWithoutValidNumber(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','00000000000', 'CNPJ');
        try{
            Database.SaveResult sResult = database.insert(accToInsert);
            throw new AssertException('Um erro deveria ser desparado pela trigger');
        }catch(Exception e){
            Boolean expectedErrorMessage =  (e.getMessage().contains('Número do cliente é inválido'))? true : false;
            System.AssertEquals(expectedErrorMessage, true, 'A Mensagem de erro foi disparada como esperado');

        } 

    }


    @isTest
    public static void testConsumidorFinalHasAssignedTasks(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Consumidor final','111', 'CNPJ');
     
        Database.SaveResult sResult = database.insert(accToInsert);

        list<task> tasks = [SELECT id FROM task WHERE Whatid = :sResult.getId()];

        System.assert(sResult.isSuccess(), 'A conta foi inserida com sucesso');
        System.assert(tasks.size() == 1, 'A task foi criada com sucesso');
    }

    @isTest
    public static void testConsumidorFinalHasAnAssignedOpportunity(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
     
        Database.SaveResult sResult = database.insert(accToInsert);

        list<Opportunity> opp = [SELECT id FROM Opportunity WHERE AccountId = :sResult.getId()];

        System.assert(sResult.isSuccess(), 'A conta foi inserida com sucesso');
        System.assert(opp.size() == 1, 'A Opp foi criada com sucesso');
    }

    @isTest
    public static void testConsumidorFinalDontCreateNewTasksWhenUpdate(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Consumidor final','111', 'CNPJ');
     
        Database.SaveResult sResult = database.insert(accToInsert);

        Account acc = [SELECT id, name FROM account WHERE id = :sResult.getId()][0];

        acc.name = 'Outro nome';

        update acc;

        list<task> tasks = [SELECT id FROM task WHERE Whatid = :sResult.getId()];

        System.assert(sResult.isSuccess(), 'A conta foi inserida com sucesso');
        System.assert(!(tasks.size() != 1), 'Foi criada apenas uma task');

    }

    @isTest
    public static void testParceiroDontCreateNewOpportunityWhenUpdate(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
     
        Database.SaveResult sResult = database.insert(accToInsert);

        Account acc = [SELECT id, name FROM account WHERE id = :sResult.getId()][0];

        acc.name = 'Outro nome';

        update acc;

        list<Opportunity> opp = [SELECT id FROM Opportunity WHERE AccountId = :sResult.getId()];

        System.assert(sResult.isSuccess(), 'A conta foi inserida com sucesso');
        System.assert(!(opp.size() != 1), 'Foi criada apenas uma opp');

    }

    


    @isTest
    public static void testOpportunityHasCorrectFieldValues(){
        Account accToInsert = TestDataFactory.getInstance().insertNewAccount('Parceiro','111', 'CNPJ');
     
        Database.SaveResult sResult = database.insert(accToInsert);

        Opportunity opp = [SELECT id,name, closeDate FROM Opportunity WHERE AccountId = :sResult.getId()][0];

        System.assert(sResult.isSuccess(), 'A conta foi inserida com sucesso');
        System.assert(opp.closeDate == Date.today().addDays(30), 'A Opp foi criada na data correta');
        System.assert(opp.name == accToInsert.name + ' - Opp Parceiro', 'A Opp foi criada com o nome correto');
    }


    @isTest
    public static void testBatchInsertWithCorrectCPFCNPJNumber(){
        List<account> accListToInsert = TestDataFactory.getInstance().getInsertAccountList(100,false);
        InsertAccountBatch batchAcc = new InsertAccountBatch();
        batchAcc.accList = accListToInsert;

        Test.startTest();
        Database.executeBatch(batchAcc, 100);
        Test.stopTEst();

        System.AssertEquals(database.countquery('SELECT COUNT() FROM Account WHERE Name like \'Teste%\''),100);  
    }

    @isTest
    public static void testBatchWithIncorrectCPFCNPJNumber(){
        List<account> accListToInsert = TestDataFactory.getInstance().getInsertAccountList(100,true);
        InsertAccountBatch batchAcc = new InsertAccountBatch();
        batchAcc.accList = accListToInsert;

        try{
            Test.startTest();
            Database.executeBatch(batchAcc, 100);
            Test.stopTest();
            throw new AssertException('Um erro deveria ser desparado pela trigger');
        }catch(Exception e){
            Boolean expectedErrorMessage =  (e.getMessage().contains('Número do cliente é inválido'))? true : false;
            System.AssertEquals(expectedErrorMessage, true, 'A Mensagem de erro foi disparada como esperado');

        } 

    }

  
}