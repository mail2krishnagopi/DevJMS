public class giic_ServiceTicketLineTriggerHandler {
     public void onAfterInsert(List<gii__ServiceTicketLine__c> newlstSTL){
        system.debug('onAfterInsert');
        
    }
    
     public void onAfterUpdate(List<gii__ServiceTicketLine__c> oldlstSTL,List<gii__ServiceTicketLine__c> newlstSTL,Map<id,Object> newSTLMap){
        system.debug('onAfterUpdate');
    }
    
    public static void assignFSEBasedOnCertification(List<gii__ServiceTicketLine__c> newlstSTL) {
        List<gii__ServiceTicketLine__c> linesToUpdate = new List<gii__ServiceTicketLine__c>();
        for (gii__ServiceTicketLine__c serviceLine :[SELECT gii__FieldServiceEngineer__c,gii__Product__c,gii__Product__r.giic_Certification__c,
                                                    gii__Product__r.giic_New_Certification_Training_Required__c,
                                                    gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c,
                                                    gii__FieldServiceEngineer__r.gii__Certification__c FROM gii__ServiceTicketLine__c
                                                    WHERE Id IN:newlstSTL]) {
		if ((serviceLine.gii__Product__r.giic_New_Certification_Training_Required__c == serviceLine.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c ||
            serviceLine.gii__Product__r.giic_New_Certification_Training_Required__c != serviceLine.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c) &&
                (serviceLine.gii__FieldServiceEngineer__r.gii__Certification__c == null || serviceLine.gii__Product__r.giic_Certification__c == null ||
                !serviceLine.gii__FieldServiceEngineer__r.gii__Certification__c.contains(serviceLine.gii__Product__r.giic_Certification__c))
           || (serviceLine.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c == false && serviceLine.gii__Product__r.giic_New_Certification_Training_Required__c == true
&&( serviceLine.gii__FieldServiceEngineer__r.gii__Certification__c.contains(serviceLine.gii__Product__r.giic_Certification__c)))
           ) {
                    serviceLine.gii__FieldServiceEngineer__c =  null;
                    linesToUpdate.add(serviceLine);
            }
            
        }
        if (linesToUpdate.size() > 0) {
            update linesToUpdate;
        }
    
    }
}