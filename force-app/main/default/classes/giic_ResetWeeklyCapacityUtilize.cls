/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 03/23/2022
Function :The Purpose of this class is to update gii__PaymentStaging__c  for same supply plan cycle
*************************************************************************************/
public class giic_ResetWeeklyCapacityUtilize implements Database.Batchable<sObject>, Database.Stateful{
    
    String supplyPlanCycleId;
    public giic_ResetWeeklyCapacityUtilize(string supplyPlanCycleId){
     this.supplyPlanCycleId = supplyPlanCycleId;
    }
    
     public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select id,giic_SupplyPlanCycle__c from gii__PaymentStaging__c where giic_SupplyPlanCycle__c =: supplyPlanCycleId]);
    }
    
    public void execute(Database.BatchableContext bc,List<gii__PaymentStaging__c> scope){
        List<gii__PaymentStaging__c> psList = new List<gii__PaymentStaging__c>();
        for(gii__PaymentStaging__c payStagObj : scope){
            gii__PaymentStaging__c psObj = new gii__PaymentStaging__c();
            psObj.Id = payStagObj.Id;
            psObj.giic_UsedCapacityProductCategory__c = 0;
            psObj.giic_UsedCapacityProductionLine__c = 0;
            psList.add(psObj);
        }
        try{
        if(psList.size()>0){
            update psList;
         }
        }catch(Exception e){
            List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
             giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),' Reset Weekly Capacity Utilize',supplyPlanCycleId,false);
            insert errorLogs;
           system.debug('Exception Occured--'+e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext bc){
        //move the finish code here
       Id apexJobId = Database.executeBatch(new giic_WeeklyCapacityUtilizedQtyBatch(supplyPlanCycleId));
       giic_BatchProgress__c jobstatus = new giic_BatchProgress__c();
                jobstatus.Name = apexJobId; 
                jobstatus.giic_JobId__c = apexJobId;
                jobstatus.giic_Status__c=giic_Constants.RESETWEEKBATCHSTATUS;
                insert jobstatus;
    }

}