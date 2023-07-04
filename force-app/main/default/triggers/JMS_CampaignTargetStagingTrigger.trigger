/**********************************************************************************************
* @description: Trigger on JMS_Campaign_Target_Staging__c Object, calls the trigger dispatcher framework with case trigger handler as Param
* @author     : Vasudha Tandon
* @date       : 16/06/2022
**********************************************************************************************/
trigger JMS_CampaignTargetStagingTrigger on JMS_Campaign_Target_Staging__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    JMS_CampaignTargetStagingTriggerHandler campTriggerObj = new JMS_CampaignTargetStagingTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(campTriggerObj);// run the trigger dispatcher
}