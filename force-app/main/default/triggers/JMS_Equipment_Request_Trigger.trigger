/**********************************************************************************************
* @description: Trigger on JMS_Equipment_Request__c Object, calls the trigger dispatcher framework with case trigger handler as Param
* @author     : Offshore(PWC)
* @date       : 18/02/2022
**********************************************************************************************/
trigger JMS_Equipment_Request_Trigger on JMS_Equipment_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    JMS_EquipmentRequestTriggerHandler objTriggerEquipmentReq = new JMS_EquipmentRequestTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(objTriggerEquipmentReq);// run the trigger dispatcher
}