trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
        AccountHandler.getInstance().validarConta(Trigger.new);
    }

    if(Trigger.isInsert && Trigger.isAfter){
        AccountHandler.getInstance().isParceiroConsumidor(Trigger.new);
    }
}