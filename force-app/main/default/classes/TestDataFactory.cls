public with sharing class TestDataFactory {
    private static integer counter = 0;
    private static TestDataFactory instance;
    private TestDataFactory() {}

    public static TestDataFactory getInstance() {
        if(instance == null){
            instance = new TestDataFactory();
        }

        return instance;
    }

    public account insertNewAccount(String recordType, String accNumber, String accType){
        String accRecordTypeId = Utils.getInstance().getRecordTypeIdByName(recordType);
        counter++;
        Account acc = new Account(name='Teste '+counter, AccountNumber = accNumber, recordtypeId=accRecordTypeId, Type=accType);

        return acc;
    }

    
    public List<account> getInsertAccountList(Integer quantity, boolean hasError){
        String recordTypeIdParceiro = Utils.getInstance().getRecordTypeIdByName('Parceiro');
        String recordTypeIdConsumidorFinal = Utils.getInstance().getRecordTypeIdByName('Consumidor final');
        String accRecordTypeId;
        List<account> accList = new List<account>();
        for(integer count = 0; count < quantity; count++){

            if(math.mod(count,2) == 0){
                accRecordTypeId = recordTypeIdParceiro;
            }else{
                accRecordTypeId = recordTypeIdConsumidorFinal;
            }
            Account acc = new Account(name='Teste '+count, AccountNumber = String.valueOf(count), recordtypeId=accRecordTypeId, Type='CNPJ');
            if(hasError && count == 2){
                acc.AccountNumber = '00000000000';
            }

            accList.add(acc);
        }

   
        return accList;
    }

    
}