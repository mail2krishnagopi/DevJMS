/**********************************************************************************************
* @description: Trigger on ContentDocument Object, calls the trigger dispatcher framework with case trigger handler as Param
* @author     : Offshore(PWC)
* @date       : 21/03/2022
**********************************************************************************************/
trigger JMS_ContentDocumentTrigger on ContentDocument (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //JMS_ContentDocumentTriggerHandler contentDocumentTriggerObj = new JMS_ContentDocumentTriggerHandler();//call the handler class
    //JMS_TriggerDispatcher.run(contentDocumentTriggerObj);// run the trigger dispatcher
    
    //This trigger is not following the Trigger Framework as not all contexts are valid
    if(trigger.isUpdate && trigger.isBefore){
        JMS_ContentDocumentTriggerHelper.restrictToRenameFiles(trigger.new,trigger.oldMap);
    }else if(trigger.isDelete && trigger.isBefore){
        JMS_ContentDocumentTriggerHelper.beforeDelete(trigger.oldMap,FALSE);
    }else if(trigger.isUndelete && trigger.isAfter){
        JMS_ContentDocumentTriggerHelper.beforeDelete(trigger.oldMap,FALSE);
    }
}