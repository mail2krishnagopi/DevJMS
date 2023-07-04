trigger TriggerForvalidation on gii__ServiceTicketLine__c (Before Update) {
     /*  private static boolean run = true;
   
    if (Trigger.isUpdate) {
        if (Trigger.isBefore) { //isBefore
            
            Id profileId=userinfo.getProfileId();
            system.debug('profileId>>'+profileId);
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            system.debug('ProfileName>>'+profileName);
            system.debug('run>>'+run);
            if( profileName != 'System Administrator'  && run == true){
                    run=false;
                for(gii__ServiceTicketLine__c stlRecord : Trigger.new){
                    system.debug('stlRecord.id>>'+stlRecord.id);
                    system.debug('stlRecord.gii__ServiceTicketLineStatus__c>>'+stlRecord.gii__ServiceTicketLineStatus__c);
                    system.debug('old status>>'+Trigger.oldMap.get(stlRecord.id).gii__ServiceTicketLineStatus__c);
                    system.debug('cond>>'+(Trigger.oldMap.get(stlRecord.id).gii__ServiceTicketLineStatus__c == 'Closed'));
                     system.debug('run>>'+run);
                    if(Trigger.oldMap.get(stlRecord.id).gii__ServiceTicketLineStatus__c == 'Closed'){
                        system.debug('stlRecord.id>>if');
                        stlRecord.addError('You can not modify closed Service ticket line');
                    }
                     
                    // system.debug('run>>'+run);
                }
               
            }
        }
    }
*/
    
}