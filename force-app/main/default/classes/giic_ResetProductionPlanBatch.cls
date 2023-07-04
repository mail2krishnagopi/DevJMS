/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 03/12/2021
Function :The Purpose of this class is to Reset Production Plan Maximum capacity and weekly capacity for same supply plan cycle
*************************************************************************************/
global class giic_ResetProductionPlanBatch implements Database.Batchable<sObject>, Database.Stateful{
   /** Variable Declaration */
   global id supplyPlanCycleId;
   global Integer count = 0;
   global String regionVal ='';
   
     //Constructor
     public giic_ResetProductionPlanBatch(id suppPlanCycleId,String region){
        this.supplyPlanCycleId=suppPlanCycleId;
        this.regionVal = region;
    }

    /*
    * Description : Start method which returns all Production Plan for same cycle
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        //get all Production Plan. //TODO Filter
        return Database.getQueryLocator([select id,giic_ExternalID__c,giic_SupplyPlanNettingLine__r.giic_DemandForecastSetup__c,giic_SupplyPlanNettingLine__r.giic_DemandForecastSetup__r.giic_ApprovalStatus__c,giic_MaximumProductionCapacity__c,giic_Supplier__c,giic_SupplyPlanCycle__c,giic_Week__c,giic_GloviaPriceBook__r.giic_Contract__c,giic_GloviaPriceBook__r.giic_Contract__r.giic_BudgetConsumption__c, giic_OrderPrice__c 
        from gii__WorkOrderIssueStaging__c where giic_SupplyPlanCycle__c =:supplyPlanCycleId AND giic_SupplyPlanNettingLine__r.giic_DemandForecastSetup__r.giic_ApprovalStatus__c =:giic_Constants.APPROVED]); //and  giic_Region__c= :regionVal
    }
    
    /* Method name : execute
    * Description : execute method will Reset Maximum Capacity and weekly capacity
    * Return Type : void
    * Parameter : List<gii__ProductionPlan__c>
    */
    global void execute(Database.BatchableContext bc, List<gii__WorkOrderIssueStaging__c > scope){
        //Reset Maximum Capacity and weekly capacity
        Map<id,Decimal> budgetConsumptionMap=new Map<id,Decimal>();
        Map<id,Contract> budgetConsumptionMaptoUpdate=new Map<id,Contract>();
        set<id> contractId=new Set<id>();
        for(gii__WorkOrderIssueStaging__c pplan:scope){
            contractId.add(pplan.giic_GloviaPriceBook__r.giic_Contract__c);
        }
        List<Contract> contractList=[select id,giic_BudgetConsumption__c from contract where id in:contractId];
        for(Contract con:contractList){
            budgetConsumptionMap.put(con.id,con.giic_BudgetConsumption__c);
        }
        system.debug('@@scope size--'+scope.size());
        for(gii__WorkOrderIssueStaging__c pp:scope){
            if(pp.giic_GloviaPriceBook__r.giic_Contract__c!=null){
                if(!budgetConsumptionMaptoUpdate.containskey(pp.giic_GloviaPriceBook__r.giic_Contract__c)){
                    Decimal remainingBudget=budgetConsumptionMap.get(pp.giic_GloviaPriceBook__r.giic_Contract__c)-pp.giic_OrderPrice__c;
                    budgetConsumptionMaptoUpdate.put(pp.giic_GloviaPriceBook__r.giic_Contract__c,new contract(id=pp.giic_GloviaPriceBook__r.giic_Contract__c,giic_BudgetConsumption__c=remainingBudget));
                    
                }
                else{
                    Contract cObj = budgetConsumptionMaptoUpdate.get(pp.giic_GloviaPriceBook__r.giic_Contract__c);
                    cObj.giic_BudgetConsumption__c = cObj.giic_BudgetConsumption__c - pp.giic_OrderPrice__c;
                    budgetConsumptionMaptoUpdate.put(pp.giic_GloviaPriceBook__r.giic_Contract__c,cObj);
                }
            }
            pp.giic_MaximumProductionCapacity__c=0;
            //pp.giic_WeeklyUnitsToBeProduced__c=0;
            //pp.giic_TotalOrderPrice__c=0;
            
        }
        
       try{
        if(!budgetConsumptionMaptoUpdate.isEmpty())
           {update budgetConsumptionMaptoUpdate.values();}
         if(scope.size()>0){
            update scope;
            count++;
          } 
       }catch(Exception e){
           List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
            giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'Reset Production Plan ',supplyPlanCycleId,false);
            insert errorLogs;
           system.debug('Exception Occured--'+e.getMessage());
        }    
    }

    /* Method name : finish
    * Description : finish method will update the demand forecast setup record and call giic_GenerateProductionPlanBatch batch
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    global void finish(Database.BatchableContext bc){ 
        List<gii__DemandForecastSetup__c> dFSList=[select id,giic_BatchStatus__c from gii__DemandForecastSetup__c where giic_Supply_Plan_Cycle__c=:supplyPlanCycleId and giic_RelatedTo__c=:giic_Constants.SUPPLYPLAN AND giic_ApprovalStatus__c=:giic_Constants.APPROVED];   
        List<gii__DemandForecastSetup__c> updateDFSList=new List<gii__DemandForecastSetup__c>();

        if(dFSList.size()>0 ){ //&& count == 0
           for(gii__DemandForecastSetup__c dfs : dFSList){
                gii__DemandForecastSetup__c updateDFS=new gii__DemandForecastSetup__c();
                updateDFS.id=dfs.id;
                updateDFS.giic_BatchStatus__c='';
                updateDFSList.add(updateDFS);
         }
         if(updateDFSList.size()>0){
             update updateDFSList;
         }
        }
        if(supplyPlanCycleId!=null){
            Id batchJobId = DataBase.ExecuteBatch(new giic_supplierBudgetConsumptionBatch(supplyPlanCycleId,regionVal));
            giic_BatchProgress__c jobstatus = new giic_BatchProgress__c();
            jobstatus.Name = batchJobId; 
            jobstatus.giic_JobId__c = batchJobId;
            jobstatus.giic_Status__c=giic_Constants.PRODUCTIONPLANBATCHSTATUS;
            insert jobstatus;
        }
        /*
        //call another batch to update Maximum capacity on production plan
        List<gii__DemandForecastSetup__c> dFSList=[select id,giic_BatchStatus__c from gii__DemandForecastSetup__c where giic_Supply_Plan_Cycle__c=:supplyPlanCycleId and giic_RelatedTo__c=:giic_Constants.SUPPLYPLAN AND giic_Region__c=:regionVal limit 1];
        if(count == 0){
            gii__DemandForecastSetup__c updateDFS=new gii__DemandForecastSetup__c();
            if(dFSList.size()>0){
             updateDFS.id=dFSList[0].id;
             updateDFS.giic_BatchStatus__c='';
             update updateDFS;
            }
        }
             
           Id batchJobId = DataBase.ExecuteBatch(new giic_GenerateMaximumCapacityPPBatch(supplierIds,productLineIds,supplyPlanCycleID,regionVal));
           giic_BatchProgress__c jobstatus = new giic_BatchProgress__c();
           jobstatus.Name = batchJobId; 
           jobstatus.giic_JobId__c = batchJobId;
           jobstatus.giic_Status__c=giic_Constants.PRODUCTIONPLANBATCHSTATUS;
           insert jobstatus;
        */ 
        
    }
}