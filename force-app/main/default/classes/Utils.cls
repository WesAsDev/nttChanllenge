public with sharing class Utils {
    private Utils(){}
    private static Utils instance;

    public static Utils getInstance(){
        if(instance == null){
            instance = new Utils();
        }
        return instance;
    }

    public boolean isCPFCNPJValid(String cpfCnpj){
        if(cpfCnpj == '00000000000'){
            return false;
        }
        
        return true;
    }

    public string getRecordTypeNameById(String recordTypeId){
        return [Select Name from RecordType where ID = :recordTypeId][0].name;
    }

    public string getRecordTypeIdByName(String name){
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get(name).getRecordTypeId();
    }
    
}