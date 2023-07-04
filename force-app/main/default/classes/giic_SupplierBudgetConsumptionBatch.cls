/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 14 Dec 2021
Function : Batch Class to update supply plan netting lines ,production plan and supplier 
Review By : Vidya Chirlanchi
*************************************************************************************/
public class giic_SupplierBudgetConsumptionBatch implements Database.Batchable<sObject>,Database.Stateful {

    public Id supplyPlanCycleID;
    public Integer count = 0;
    public String regionVal ='';
    //Constructor
    public giic_SupplierBudgetConsumptionBatch(Id supplanCycleId,String region) {
        this.supplyPlanCycleID = supplanCycleId;
        this.regionVal = region;
    }
   
    /*
    * Description : Start method which will Query SPNL records where Order type='CPO' and demand order is not null
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Query SPNL records where Order type='CPO' and demand order is not null //TODO Filter
        return Database.getQueryLocator([select id, gii__OrderType__c, giic_OrderPrice__c, gii__DemandOrder__c, gii__OrderQuantity__c,
            giic_UnitPrice__c, gii__SupplyPlanNetting__r.gii__ProductReference__c, giic_Production_Plan__c, giic_Production_Plan__r.giic_GloviaPriceBook__c, giic_GloviaPriceBookEntry__c,
            gii__Supplier__c, gii__SupplyPlanCycle__c,giic_DemandForecastSetup__r.giic_ApprovalStatus__c from gii__SupplyPlanNettingLine__c where gii__SupplyPlanCycle__c =: supplyPlanCycleID AND gii__OrderType__c =: giic_Constants.CPO
            AND gii__DemandOrder__c != null and gii__FromWarehouse__c=null AND giic_DemandForecastSetup__r.giic_ApprovalStatus__c=:giic_Constants.APPROVED]); // and giic_Region__c= :regionVal
    }
    //Execute method

    /* Method name : execute
    * Description : execute method will update Production Plans with PricebookEntry,TotalPrice and Update Budget Comsumption as per supplier on Contract
    * Return Type : void
    * Parameter : List<gii__SupplyPlanNettingLine__c>
    */
    public void execute(Database.BatchableContext bc, List<gii__SupplyPlanNettingLine__c > scope) {
        //Step#-1:
        //Variables declared
        List<gii__PriceBookEntry__c > gpblist = new List<gii__PriceBookEntry__c > ();
        Set<String> supplierIds = new Set<String> ();
        Set<String> productIds = new Set<String> ();
        Set<String> ppIds = new Set<String> ();
        Set<String> ppSupplierIds = new Set<String> ();
        Map<String, gii__PriceBookEntry__c > spnlPricebookMap = new Map<String, gii__PriceBookEntry__c > ();
        Map<String, gii__PriceBook__c > ppPricebookMap = new Map<String, gii__PriceBook__c > ();
        Map<String, List<gii__SupplyPlanNettingLine__c >> ppSPNLMap = new Map<String, List<gii__SupplyPlanNettingLine__c >> ();
        //Map<String, List<gii__WorkOrderIssueStaging__c >> contractPPMap = new Map<String, List<gii__WorkOrderIssueStaging__c >> ();
        List<Contract> contractsLst = new List<Contract> ();
        Map<String, Decimal> ppTotalPrice = new Map<String, Decimal> ();
        Set<Id> spnlIds = new Set<Id> ();
        //List<gii__WorkOrderIssueStaging__c > ppList = new List<gii__WorkOrderIssueStaging__c >();
        
        try {
            // Looping over SPNL records returned from start method
            for (gii__SupplyPlanNettingLine__c spnl: scope) {
                supplierIds.add(spnl.gii__Supplier__c);
                productIds.add(spnl.gii__SupplyPlanNetting__r.gii__ProductReference__c);
                //ppIds.add(spnl.giic_Production_Plan__c);
                spnlIds.add(spnl.Id);
            }
            // querying pricebookEntry records  by supplierid and product
            for (gii__PriceBookEntry__c gpbe: [Select Id, gii__UnitPrice__c, gii__Product__c, gii__PriceBook__r.giic_Contract__r.AccountId from gii__PriceBookEntry__c where gii__PriceBook__r.giic_Contract__r.AccountId IN: supplierIds AND gii__Product__c IN: productIds]) {
                spnlPricebookMap.put(gpbe.gii__PriceBook__r.giic_Contract__r.AccountId + ':' + gpbe.gii__Product__c, gpbe);
            }
            // update SPNL's pricebook entry and unit price
            for (gii__SupplyPlanNettingLine__c spnl: scope) {
                gii__PriceBookEntry__c gpeRec = new gii__PriceBookEntry__c();
                gpeRec = (gii__PriceBookEntry__c) spnlPricebookMap.get(spnl.gii__Supplier__c + ':' + spnl.gii__SupplyPlanNetting__r.gii__ProductReference__c);
                if (gpeRec != null) {
                    spnl.giic_GloviaPriceBookEntry__c = gpeRec.Id;
                    spnl.giic_UnitPrice__c = gpeRec.gii__UnitPrice__c;
                    spnl.giic_GloviaPriceBook__c = gpeRec.gii__PriceBook__c;
                    
                    /*ppList.add(new gii__WorkOrderIssueStaging__c (Id=spnl.giic_Production_Plan__c, giic_GloviaPriceBookEntry__c=gpeRec.Id,
                    giic_UnitPrice__c = gpeRec.gii__UnitPrice__c, giic_GloviaPriceBook__c = gpeRec.gii__PriceBook__c));*/
                    
                }

            }
            //updating SPNL
            update scope;
            //update ppList;
            
            //Step 2: -         
            List<gii__SupplyPlanNettingLine__c > spnlList = [select id, giic_OrderPrice__c,gii__Supplier__c, giic_Production_Plan__c, gii__OrderQuantity__c,
            giic_UnitPrice__c from gii__SupplyPlanNettingLine__c where Id IN: spnlIds];
            for (gii__SupplyPlanNettingLine__c spnl: spnlList){
                if (!ppTotalPrice.containsKey(spnl.gii__Supplier__c)) {
                     ppTotalPrice.put(spnl.gii__Supplier__c, spnl.giic_OrderPrice__c);
                } else {
                    Decimal ppTotalOrderPrice = 0.0;
                    ppTotalOrderPrice = ppTotalPrice.get(spnl.gii__Supplier__c) + spnl.giic_OrderPrice__c;
                    ppTotalPrice.put(spnl.gii__Supplier__c, ppTotalOrderPrice);
                }
            }
            /*
            //Looping over SPNL
            for (gii__SupplyPlanNettingLine__c spnl: spnlList){
                if (ppSPNLMap.containsKey(spnl.giic_Production_Plan__c)) {
                    ppSPNLMap.get(spnl.giic_Production_Plan__c).add(spnl);
                } else {
                    ppSPNLMap.put(spnl.giic_Production_Plan__c, new List<gii__SupplyPlanNettingLine__c > {
                        spnl
                    }); //key - Production plan
                }
            }
            List<gii__ProductionPlan__c > pplst = [Select Id, giic_Supplier__c, giic_TotalOrderPrice__c, giic_GloviaPriceBook__c from gii__ProductionPlan__c where Id IN: ppIds];
            for (gii__ProductionPlan__c ppRec: pplst) {
                ppSupplierIds.add(ppRec.giic_Supplier__c);
            }
            //get Price book records
            for (gii__PriceBook__c gpbRec: [Select Id, giic_Contract__r.AccountId from gii__PriceBook__c where giic_Contract__r.AccountId IN: ppSupplierIds]) {
                ppPricebookMap.put(gpbRec.giic_Contract__r.AccountId, gpbRec); // key - supplier related pricebook's contract
            }
            //Calculating total price from all SPNL of production plans and updating on PP
            for (gii__ProductionPlan__c ppRec: pplst) {
                Decimal totalOrderPrice = 0.0;
                gii__PriceBook__c priceBookRec ;
                if(ppPricebookMap.containsKey(ppRec.giic_Supplier__c)){
                  priceBookRec = (gii__PriceBook__c) ppPricebookMap.get(ppRec.giic_Supplier__c);
                }
                List<gii__SupplyPlanNettingLine__c> spnlLst = new List<gii__SupplyPlanNettingLine__c > ();
                if (ppSPNLMap != null && ppSPNLMap.size() > 0) {
                    spnlLst.addAll(ppSPNLMap.get(ppRec.Id));
                }
                if (spnlLst.size() > 0) {
                    for (gii__SupplyPlanNettingLine__c spnl: spnlLst) {
                        totalOrderPrice = (spnl.giic_OrderPrice__c != null) ? (totalOrderPrice + spnl.giic_OrderPrice__c) : totalOrderPrice;
                    }
                }
                if (priceBookRec != null) {
                    ppRec.giic_GloviaPriceBook__c = priceBookRec.Id; //TODO
                    ppRec.giic_TotalOrderPrice__c = totalOrderPrice;
                    if (!ppTotalPrice.containsKey(ppRec.giic_Supplier__c)) {
                        ppTotalPrice.put(ppRec.giic_Supplier__c, ppRec.giic_TotalOrderPrice__c);
                    } else {
                        Decimal ppTotalOrderPrice = 0.0;
                        ppTotalOrderPrice = ppTotalPrice.get(ppRec.giic_Supplier__c) + ppRec.giic_TotalOrderPrice__c;
                        ppTotalPrice.put(ppRec.giic_Supplier__c, ppTotalOrderPrice);
                    }
                }
            }
            if(pplst.size()>0){
               update pplst;
            }
            */
            //Step 3: -
            // Update Budget Comsumption as per supplier on Contract
            for (Contract contr: [Select Id, AccountId, giic_BudgetConsumption__c from Contract where AccountId IN: supplierIds]) {
                if (ppTotalPrice.containsKey(contr.AccountId)) {
                    contr.giic_BudgetConsumption__c = (contr.giic_BudgetConsumption__c != null) ? (contr.giic_BudgetConsumption__c + ppTotalPrice.get(contr.AccountId)) : ppTotalPrice.get(contr.AccountId);
                    contractsLst.add(contr);
                }
            }
            if(contractsLst.size() > 0){
               update contractsLst;
               count++;
            }

        } catch (Exception e) {
            List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
             giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'Supplier Budget Consumption',supplyPlanCycleID,false);
            insert errorLogs;
            System.debug('Exception-' + e);
        }
    }

    /* Method name : finish
    * Description : finish method will update the demand forecast setup record
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc) {
        //Call another batch to generate Production Plan 
           
         //get the demand forecast setup record
        List<gii__DemandForecastSetup__c> dFSList=[select id,giic_BatchStatus__c from gii__DemandForecastSetup__c where giic_Supply_Plan_Cycle__c=:supplyPlanCycleId and giic_RelatedTo__c=:giic_Constants.SUPPLYPLAN AND giic_ApprovalStatus__c=:giic_Constants.APPROVED];   
        List<gii__DemandForecastSetup__c> updateDFSList=new List<gii__DemandForecastSetup__c>();

        if(dFSList.size()>0){
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
           Id batchJobId = DataBase.ExecuteBatch(new giic_GenerateProductionPlanBatch(supplyPlanCycleID,regionVal));
            giic_BatchProgress__c jobstatus = new giic_BatchProgress__c();
            jobstatus.Name = batchJobId; 
            jobstatus.giic_JobId__c = batchJobId;
            jobstatus.giic_Status__c=giic_Constants.PRODUCTIONPLANBATCHSTATUS;
            insert jobstatus;
        
    }
}