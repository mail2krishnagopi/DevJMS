/**********************************************************************************************
* @description: Trigger on Product2 Object, calls the trigger dispatcher framework with trigger handler as Param
* @author     : Sumit
* @date       : 09/03/2022
**********************************************************************************************/
trigger JMS_Product2Trigger on Product2 (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	JMS_Product2TriggerHandler product2TriggerObj = new JMS_Product2TriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(product2TriggerObj);// run the trigger dispatcher
}