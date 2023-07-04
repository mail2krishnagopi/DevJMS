/**********************************************************************************************
* @description: Trigger on User Object, calls the trigger dispatcher framework with User trigger handler as Param
* @author     : Sumit
* @date       : 20/04/2022
**********************************************************************************************/
trigger JMS_UserTrigger on User (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	//JMS_UserTriggerHandler userTriggerObj = new JMS_UserTriggerHandler();//call the handler class
    //JMS_TriggerDispatcher.run(userTriggerObj);// run the trigger dispatcher
    
    //This trigger is not following the Trigger Framework as not all contexts are valid
    if(trigger.isInsert){
        if(trigger.isBefore){
        	JMS_UserTriggerHelper.updateUserAsDelegatedApprover(trigger.new, NULL, NULL);
        }
        if(trigger.isAfter){
        	JMS_UserTriggerHelper.assignPermissionSetToUsers(trigger.new, NULL, NULL);    
        }
    }else if(trigger.isUpdate){
        if(trigger.isBefore){
        	JMS_UserTriggerHelper.updateUserAsDelegatedApprover(trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
}