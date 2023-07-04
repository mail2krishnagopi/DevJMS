/**********************************************************************************************
* @description: Trigger on Lead Object, calls the trigger dispatcher framework with Lead trigger handler as Param
* @author     : Sumit
* @date       : 14/04/2022
**********************************************************************************************/
trigger JMS_LeadTrigger on Lead (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	JMS_LeadTriggerHandler leadTriggerObj = new JMS_LeadTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(leadTriggerObj);// run the trigger dispatcher
}