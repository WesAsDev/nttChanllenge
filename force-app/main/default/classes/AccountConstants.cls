public with sharing class AccountConstants {
    private static AccountConstants instance;
    private final list<string> CPFCNPJ = new List<string>{'CPF', 'CNPJ'};
    private AccountConstants() {}
    public static AccountConstants getInstance(){
        if(instance == null){
            instance = new AccountConstants();
        }

        return instance;
    }

    public list<string> getCpfCnpj(){
        return  CPFCNPJ;
    }
}