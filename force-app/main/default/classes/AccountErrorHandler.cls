public with sharing class AccountErrorHandler {
    private AccountErrorHandler() { }

    private static AccountErrorHandler instance;

    public static AccountErrorHandler getInstance(){
        if(instance == null){
            instance = new AccountErrorHandler();
        }

        return instance;
    }

    public void isNotValidCPFCNPJ(Account acc){
        acc.addError('Número do cliente é inválido');
    }
    
}