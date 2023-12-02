public with sharing class AccountHandler {
    private static AccountHandler instance;
    private AccountHandler() {}


    public static AccountHandler getInstance(){
        if(instance == null){
            instance = new AccountHandler();
        }

        return instance;
    }

    public void validarConta(List<account> accounts){
        List<account> accToUpsert = new List<account>();

        for(account acc : accounts){
            Boolean isCpfCnpjType = isCpfCnpjType(acc.type);
            Boolean hasAValidCpfCnpj = Utils.getInstance().isCPFCNPJValid(acc.AccountNumber);

            if(isCpfCnpjType && !hasAValidCpfCnpj){
                AccountErrorHandler.getInstance().isNotValidCPFCNPJ(acc);
                continue;
            }

            accToUpsert.add(acc);
        }
    }


    public boolean isCpfCnpjType(String type){
        return AccountConstants.getInstance().getCpfCnpj().contains(type);
    }

    public void isParceiroConsumidor(List<account> accList){
        List<Opportunity> oppToInsert = new list<Opportunity>();
        List<task> tasksToInsert = new List<task>();

        for(Account acc : accList){
 
            String recordTypeAcc = Utils.getInstance().getRecordTypeNameById(acc.recordtypeid);
            switch on (recordTypeAcc) {
                /*Possibilidade de passar isso para metadados e usar global describe do recordtype para não chumbar o valor*/
                when 'Parceiro'{
                    Opportunity opp = new Opportunity(
                        Name = Acc.name + ' - Opp Parceiro',
                        CloseDate = Date.today().addDays(30),
                        stageName = 'Qualification',
                        AccountId = acc.id
                    );

                    oppToInsert.add(opp);

                }
                when 'Consumidor final'{
                    Task opp = new Task(
                        Subject = 'Consumidor Final',
                        WhatId = acc.id,
                        status = 'Not Started',
                        Priority = 'Normal'

                    );

                    tasksToInsert.add(opp);
                }
            }
        }

        if(oppToInsert.size() > 0) {
            insert oppToInsert;
        }

        if(tasksToInsert.size() > 0) {
            insert tasksToInsert;
        }

    }
}