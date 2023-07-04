/**********************************************************************************************
* @description: Trigger on JMS_Broker_Call_Staging__c Object, calls the trigger dispatcher framework 
* @author     : Vasudha Tandon
* @date       : 15/06/2021
**********************************************************************************************/
trigger JMS_Broker_Call_Staging_Trigger on JMS_Broker_Call_Staging__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    JMS_BrokerCallStagingTriggerHandler brokerTriggerObj = new JMS_BrokerCallStagingTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(brokerTriggerObj);// run the trigger dispatcher
}