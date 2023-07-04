/**********************************************************************************************
* @description: Trigger on ContentVersion Object, calls the trigger dispatcher framework with case trigger handler as Param
* @author     : Offshore(PWC)
* @date       : 21/03/2022
**********************************************************************************************/
trigger JMS_ContentVersionTrigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //JMS_ContentVersionTriggerHandler contentVersionTriggerObj = new JMS_ContentVersionTriggerHandler();//call the handler class
    //JMS_TriggerDispatcher.run(contentVersionTriggerObj);// run the trigger dispatcher
    
    //This trigger is not following the Trigger Framework as not all contexts are valid
    if (Trigger.isUpdate && Trigger.isBefore){
        JMS_ContentVersionTriggerHelper.restrictToRenameFiles(Trigger.new,Trigger.oldMap);
    }
}