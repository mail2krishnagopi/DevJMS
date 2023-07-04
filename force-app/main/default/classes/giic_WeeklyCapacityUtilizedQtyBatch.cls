public class giic_WeeklyCapacityUtilizedQtyBatch implements Database.Batchable<sObject>, Database.Stateful{

    public string supplyPlanCycleId;
    public giic_WeeklyCapacityUtilizedQtyBatch(string cycleId){
        this.supplyPlanCycleId=cycleId;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select id,gii__Account__c,gii__CapacityPerWeek__c,gii__DemandForecastLine__c,gii__DemandOrder__c,gii__OrderQuantity__c,gii__OrderType__c,gii__Product__c,gii__ProductCategory__c,gii__ProductionLine__c,giic_ProductionLine__c,gii__ProductionRateHour__c,gii__Sequence__c,gii__Supplier__c,gii__SupplierList__c,giic_SupplierName__c,gii__SupplyPlanCycle__c,giic_UsedCapacityHour__c,giic_WeekCapacityCategoryKey__c,giic_WeekCapacityProductionLineKey__c,gii__WeeklyCapacity__c,giic_WeekNumber__c from gii__SupplyPlanNettingLine__c where gii__OrderType__c ='CPO' and gii__ProductionLine__c!=null and gii__SupplyPlanCycle__c =: supplyPlanCycleId]);
    }
    
    public void execute(Database.BatchableContext bc,List<gii__SupplyPlanNettingLine__c> listSPNLine){
        try{
            giic_SupplyPlanController.createDOUsedQtyRecord(listSPNLine);   
        }catch(Exception e){
            system.debug('Error Occured in batch --'+e.getMessage());
            List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
            giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'Weekly Capacity Consume on Supply Plan',supplyPlanCycleId,true);
            insert errorLogs;
        }        
    }
        
    
    public void finish(Database.BatchableContext bc){
        //move the finish code here
         List<gii__SupplyPlanCycle__c> lstSPC = [select id,giic_SetupSupplyPlanReady__c from gii__SupplyPlanCycle__c where id =:supplyPlanCycleId];
        for(gii__SupplyPlanCycle__c objspc : lstSPC){
            objspc.giic_SetupSupplyPlanReady__c = true;
        }
       if(!lstSPC.isEmpty()){
              update lstSPC;
            } 
     }
}