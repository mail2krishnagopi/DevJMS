trigger gii_PickListTrigger on gii__PickList__c (before insert) {
    if(trigger.isInsert){
        Decimal maxsequencenumber = 0;
        List<gii__PickList__c> expicklist = [SELECT gii__PicklistSequence__c FROM gii__PickList__c where gii__PicklistStatus__c='Created' AND gii__PicklistSequence__c!=null ORDER By gii__PicklistSequence__c DESC LIMIT 1];
        if(expicklist.size() > 0){
            maxsequencenumber =  expicklist[0].gii__PicklistSequence__c;
        }
        
        for(gii__PickList__c pk:trigger.new){
            if(pk.gii__PicklistStatus__c == 'Created'){
                pk.gii__PicklistSequence__c = maxsequencenumber+1;
                maxsequencenumber++;
            }
        }
    }
   
}