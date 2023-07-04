/**********************************************************************************************
* @description: Trigger on ContentDocumentLink Object, calls the trigger dispatcher framework with case trigger handler as Param
* @author     : Sachin Awati
* @date       : 18/02/2022
**********************************************************************************************/
trigger JMS_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    JMS_ContentDocumentLinkTriggerHandler contentDocumentLinkTriggerObj = new JMS_ContentDocumentLinkTriggerHandler();//call the handler class
    JMS_TriggerDispatcher.run(contentDocumentLinkTriggerObj);// run the trigger dispatcher
}