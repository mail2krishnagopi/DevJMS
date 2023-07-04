trigger giic_SaleQuoteTrigger on gii__SalesQuote__c (before insert , before update , after update) {
    
    public static Boolean isRun = true;
    
                system.debug('yes fire -->>> ');

    
    // @description before insert trigger event
        if (Trigger.isInsert) {
        if (Trigger.isBefore) {
             system.debug('yes before insert -->>> ');
           // giic_SaleQuoteTriggerHelper.checkEIUserUpdateForgeId(trigger.new,null);
             giic_SaleQuoteTriggerHelper.updateApprovedFieldsFOrApproval(trigger.new);
                system.debug('trigger.new -->>> '+trigger.new);
        }
    }
    
    // @description after insert trigger event
        if (Trigger.isInsert) {
        if (Trigger.isafter) {
             system.debug('yes after insert -->>> ');
           
          //   giic_SaleQuoteTriggerHelper.updateApprovedFieldsFOrApproval(trigger.new);
                system.debug('trigger.new -->>> '+trigger.new);
        }
    }
    
     // To invoke before update trigger logic 
    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
             system.debug('yes before update -->>> ');
            giic_SaleQuoteTriggerHelper.resetApprovedFieldsByApprovers(trigger.new, trigger.oldMap);
         //   giic_SaleQuoteTriggerHelper.checkEIUserUpdateForgeId(trigger.new,  trigger.oldMap);
            
        }
    }
    
   //To invoke after update trigger logic
    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            if(isRun == true){
                 system.debug('yes after update -->>> ');
                giic_SaleQuoteTriggerHelper.initiateApprovalProcess(trigger.new, trigger.oldMap);
                giic_SaleQuoteTriggerHelper.initiateEmailNotificationRequest(trigger.new, trigger.oldMap);
                giic_SaleQuoteTriggerHelper.customNotificationToOwner(trigger.new, trigger.oldMap);
                isRun =  false;
            }
            
        }
    }
    
    
}