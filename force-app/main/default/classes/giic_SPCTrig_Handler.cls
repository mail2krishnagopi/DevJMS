/**
* @author vidya Chirlanchi - vidya.chirlanchi@fujitsu.com
* @date Creation 03/01/2022
* @description giic_SPCTrig_Handler Handler for giic_TR_SupplyPlanCycleValidation Trigger
* function - check if default sales year is active for multiple record then display error
*/

public with sharing class giic_SPCTrig_Handler {
    
    /**
    * @author vidya Chirlanchi - vidya.chirlanchi@fujitsu.com
    * @description Method to be executed on before insert
    * @param listNew - list of new values of records
    */
    public void onAfterInsert(List<gii__SupplyPlanCycle__c> listNew){
        Integer recordsCount = 0;
        //gettind SPC record 
        List<gii__SupplyPlanCycle__c> lstSPC = [select id from gii__SupplyPlanCycle__c where giic_Active__c = true];
        system.debug('lstSPC'+lstSPC);
        for(gii__SupplyPlanCycle__c spc : listNew){
            if(spc.giic_Active__c){
                if(lstSPC.size()>1){
                    spc.addError('Only one Supply Plan cycle can be active at a time');
                }
            }
        }
    }
    
     public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        Map<Id, gii__SupplyPlanCycle__c> mapOld = (Map<Id, gii__SupplyPlanCycle__c>) mapOldS; 
        Map<Id, gii__SupplyPlanCycle__c> mapNew = (Map<Id, gii__SupplyPlanCycle__c>) mapNewS;
        List<gii__SupplyPlanCycle__c> listNew = mapNew.values();
        List<gii__SupplyPlanCycle__c> lstSPC = [select id from gii__SupplyPlanCycle__c where giic_Active__c = true];
        
        for(gii__SupplyPlanCycle__c spc : listNew){
            if(spc.giic_Active__c){
                if(lstSPC.size()>1){
                    spc.addError('Only one Supply Plan cycle can be active at a time');
                }
            }
        }
     }

}