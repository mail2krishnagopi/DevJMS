/**********************************************************************************************
* @description: Trigger on Account Object, calls the trigger dispatcher framework with case trigger handler as Param
* @author     : Sachin Awati
* @date       : 18/02/2022
**********************************************************************************************/
trigger JMS_AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    JMS_AccountTriggerHandler accountTriggerObj = new JMS_AccountTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(accountTriggerObj);// run the trigger dispatcher
}