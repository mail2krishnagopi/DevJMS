trigger JMS_OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    JMS_OpportunityTriggerHandler opportunityTriggerObj = new JMS_OpportunityTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(opportunityTriggerObj);// run the trigger dispatcher
}