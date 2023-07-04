/**********************************************************************************************
* @description: Trigger on OpportunityLineItem Object, calls the trigger dispatcher framework 
*				with OpportunityLineItem trigger handler as Param
* @author     : Sumit
* @date       : 22/06/2022
**********************************************************************************************/
trigger JMS_OpportunityProductTrigger on OpportunityLineItem (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    JMS_OpportunityProductTriggerHandler oppLineItemTriggerObj = new JMS_OpportunityProductTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(oppLineItemTriggerObj);// run the trigger dispatcher
}