/**********************************************************************************************
* @description: Trigger on Contact Object, calls the trigger dispatcher framework with trigger handler as Param
* @author     : Sumit
* @date       : 09/03/2022
**********************************************************************************************/
trigger JMS_ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	JMS_ContactTriggerHandler contactTriggerObj = new JMS_ContactTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(contactTriggerObj);// run the trigger dispatcher
}