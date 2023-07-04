trigger giic_ServiceTicketLineTrigger on gii__ServiceTicketLine__c (after insert,after update) {
    giic_ServiceTicketLineTriggerHandler objHandler = new giic_ServiceTicketLineTriggerHandler();
    If(Trigger.isInsert && Trigger.isAfter) 
    {
        objHandler.onAfterInsert(Trigger.New);
    }
    If(Trigger.isUpdate && Trigger.isAfter) 
    {
        objHandler.onAfterInsert(Trigger.New);
    }
    
   
}