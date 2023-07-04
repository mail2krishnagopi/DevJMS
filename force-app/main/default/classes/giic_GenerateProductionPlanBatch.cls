/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 29/11/2021
Function :The Purpose of this class is to update create the Production Plan as per Production Line,week number and Supplier
*************************************************************************************/
global class giic_GenerateProductionPlanBatch implements Database.Batchable<sObject>, Database.Stateful{
    //Variable defined
    global set<id> supplierIds=new set<id>();
    global set<id> productLineIds=new set<id>();
    global Id supplyPlanCycleID;
    global Integer count = 0;
    global String regionVal ='';

    //Constructor
    public giic_GenerateProductionPlanBatch(Id supplanCycleId,String region){
        this.supplyPlanCycleID=supplanCycleId;
        this.regionVal = region;
    }

     /*
    * Description : Start method which will return all approved Supply plan netting line for same cycle
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        //get all Supply Plan Netting line. // TODO Filter
        return Database.getQueryLocator([select id,gii__DemandOrder__c,gii__OrderQuantity__c,gii__Product__c,gii__Product__r.gii__ProductGroup__c, 
        gii__WeeklyCapacity__c,gii__WeeklyCapacity__r.gii__WeekStartDate__c,gii__WeeklyCapacity__r.gii__WeekEndDate__c,giic_WeekNumber__c,gii__WeeklyCapacity__r.gii__ProductionLine__r.Name, 
        gii__WeeklyCapacity__r.gii__CapacityperWeek__c,gii__WeeklyCapacity__r.gii__ActualCapacityWeekUnits__c,gii__WeeklyCapacity__r.gii__ActualCapacity__c,
        gii__PurchaseOrder__r.gii__Approved__c,gii__SupplyPlanCycle__c,gii__WeeklyCapacity__r.gii__ProductionLine__c, giic_GloviaPriceBookEntry__c, 
        gii__ProductCategory__c, giic_ProductionLine__c,giic_ProductionLine__r.Name, gii__PurchaseOrderCreatedforCPO__c,gii__ProductionRateHour__c,
        gii__SupplyPlanNetting__r.gii__ProductReference__c,gii__SupplyPlanNetting__r.gii__ProductReference__r.gii__SKUCode__c, gii__PurchaseOrder__c,gii__PurchaseOrder__r.gii__RequiredDate__c, gii__PurchaseOrderLine__c, giic_Region__c, gii__SubCategory1__c, gii__SubCategory2__c,
        gii__SuggestedDueDate__c, gii__Supplier__c, gii__SupplyPlanNetting__c, gii__SupplyPlanNetting__r.Name, Name, gii__OrderType__c, gii__ExpectedEndofProductionDate__c,
        gii__NewQuantity__c, gii__DemandOrderPriority__c ,gii__SuggestedStartDate__c, gii__InTransitLeadTime__c, giic_PriorOrderQuantity__c, gii__TransferToWarehouse__c,giic_DemandForecastSetup__r.giic_ApprovalStatus__c 
        , giic_UnitPrice__c, giic_GloviaPriceBook__c 
        from gii__SupplyPlanNettingLine__c where gii__SupplyPlanCycle__c=:supplyPlanCycleID and gii__OrderType__c=:giic_Constants.CPO and gii__DemandOrder__c!=null and gii__FromWarehouse__c=null AND giic_DemandForecastSetup__r.giic_ApprovalStatus__c=:giic_Constants.APPROVED]); //and giic_Region__c= :regionVal
    }

    /* Method name : execute
    * Description : execute method will create Production Plans
    * Return Type : void
    * Parameter : List<gii__SupplyPlanNettingLine__c>
    */
    global void execute(Database.BatchableContext bc, List<gii__SupplyPlanNettingLine__c> scope){
        //Step#-1: 
        //Veriable defined
        Set<String> ppMapSet =new Set<String>();
        //looping over record returned from start method
        for(gii__SupplyPlanNettingLine__c snl:scope){
            String ppKey = snl.Id;//snl.gii__SupplyPlanCycle__c+''+snl.gii__WeeklyCapacity__r.gii__ProductionLine__c+''+snl.gii__WeeklyCapacity__c+''+snl.gii__Supplier__c;
            ppMapSet.add(ppkey);
           
        }
        //Step# 2: SOQL on PP where External Id in ppkey  --> Map --> key = External Id , value = PP record
        Map<String, gii__WorkOrderIssueStaging__c> ppMap = new Map<String, gii__WorkOrderIssueStaging__c>();
        for(gii__WorkOrderIssueStaging__c pp :[Select Id, giic_ExternalID__c from gii__WorkOrderIssueStaging__c 
                                        where giic_ExternalID__c in :ppMapSet])
        {
          ppMap.put(pp.giic_ExternalID__c, pp);    
        }
        
        //Step# 3
        //creating Production Plan
        List<gii__SupplyPlanNettingLine__c> updateNettingLine=new List<gii__SupplyPlanNettingLine__c>();
        List<gii__WorkOrderIssueStaging__c> upsertPPRecords = new List<gii__WorkOrderIssueStaging__c>();
        Decimal weekOfFilling = [Select id,gii__WeekNumber__c from gii__WeeklyCapacity__c where gii__WeekStartDate__c <=: system.today() 
                                 and gii__WeekEndDate__c >=: system.today() and gii__WeekNumber__c !=null limit 1].gii__WeekNumber__c;
        
        for(gii__SupplyPlanNettingLine__c snline :scope){
            String ppKey = snline.Id;//snline.gii__SupplyPlanCycle__c+''+snline.gii__WeeklyCapacity__r.gii__ProductionLine__c+''+snline.gii__WeeklyCapacity__c+''+snline.gii__Supplier__c;
            gii__WorkOrderIssueStaging__c prodPlan =new gii__WorkOrderIssueStaging__c(); 
            if(!ppMap.containsKey(ppKey)){
                prodPlan=new gii__WorkOrderIssueStaging__c();   
                ppMap.put(ppKey, prodPlan);
            }else{
              prodPlan=  ppMap.get(ppKey);
            }
            
            prodPlan.giic_ProductionLine__c=snline.gii__WeeklyCapacity__r.gii__ProductionLine__c;
            prodPlan.giic_Week__c=snline.giic_WeekNumber__c;
            prodPlan.giic_WeekStartDate__c=snline.gii__WeeklyCapacity__r.gii__WeekStartDate__c;
            prodPlan.giic_WeekEndDate__c=snline.gii__WeeklyCapacity__r.gii__WeekEndDate__c;
            prodPlan.giic_MaximumProductionCapacity__c=snline.gii__WeeklyCapacity__r.gii__ActualCapacity__c;
            prodPlan.giic_SupplyPlanCycle__c=snline.gii__SupplyPlanCycle__c;
            prodPlan.giic_ExternalID__c=ppKey;
            prodPlan.giic_TransferToWarehouse__c = snline.gii__TransferToWarehouse__c;
            prodPlan.giic_DemandOrder__c               = snline.gii__DemandOrder__c;
            prodPlan.giic_GloviaPriceBookEntry__c      = snline.giic_GloviaPriceBookEntry__c;
            prodPlan.giic_UnitPrice__c                 = snline.giic_UnitPrice__c;
            prodPlan.giic_GloviaPriceBook__c           = snline.giic_GloviaPriceBook__c;
            //prodPlan.giic_OpenQuantity__c              = snline.gii__OrderQuantity__c;
            prodPlan.giic_ProductCategory__c           = snline.gii__ProductCategory__c;
            //prodPlan.giic_ProductionLine__c            = snline.giic_ProductionLine__c;
            prodPlan.giic_ProductReference__c          = snline.gii__SupplyPlanNetting__r.gii__ProductReference__c;
            prodPlan.giic_PurchaseOrder__c             = snline.gii__PurchaseOrderCreatedforCPO__c;
            prodPlan.giic_PurchaseOrderLine__c         = snline.gii__PurchaseOrderLine__c;
            prodPlan.giic_SubCategory1__c              = snline.gii__SubCategory1__c;
            prodPlan.giic_SubCategory2__c              = snline.gii__SubCategory2__c;
            prodPlan.giic_SuggestedDueDate__c          = snline.gii__SuggestedDueDate__c;
            prodPlan.giic_Supplier__c                  = snline.gii__Supplier__c;
            prodPlan.giic_SupplyPlanNetting__c         = snline.gii__SupplyPlanNetting__c;
            prodPlan.giic_SupplyPlanNettingLine__c     = snline.Id;
            prodPlan.giic_SupplyPlanNettingLineName__c = snline.Name;
            prodPlan.giic_SupplyPlanNettingName__c     = snline.gii__SupplyPlanNetting__r.Name;
            prodPlan.giic_WeeklyCapacity__c            = snline.gii__WeeklyCapacity__c;
            prodPlan.giic_SupplyPlanCycle__c           = snline.gii__SupplyPlanCycle__c ;
            prodPlan.giic_OrderType__c                 = snline.gii__OrderType__c ;
            prodPlan.giic_ProductionRateHour__c        = snline.gii__ProductionRateHour__c ;
            prodPlan.giic_DemandOrderPriority__c       = snline.gii__DemandOrderPriority__c;
            prodPlan.giic_OrderQuantity__c             = 0 ;
            prodPlan.giic_UnitsPlanned__c              =  snline.gii__OrderQuantity__c ;
            prodPlan.giic_UnitsToBeDelivered__c =  snline.gii__OrderQuantity__c ;
            prodPlan.giic_ExpectedEndofProductionDate__c    =snline.gii__ExpectedEndofProductionDate__c;
            prodPlan.giic_DateOfFilling__c   = System.today();
            prodPlan.giic_ProductionLineName__c = snline.gii__WeeklyCapacity__r.gii__ProductionLine__r.Name;
            prodPlan.giic_SKUCode__c = snline.gii__SupplyPlanNetting__r.gii__ProductReference__r.gii__SKUCode__c;
           // prodPlan.giic_WeekOfFilling__c = Integer.valueOf(getWeekNumber(System.today()));
            prodPlan.giic_WeekOfFilling__c = weekOfFilling;
            prodPlan.giic_NewQuantity__c = 0;
            prodPlan.giic_ActualCapacityhrs__c = snline.gii__WeeklyCapacity__r.gii__ActualCapacity__c;
            prodPlan.giic_SuggestedStartDate__c =snline.gii__SuggestedStartDate__c;
            if(snline.gii__PurchaseOrder__c!=null){
                prodPlan.giic_ExpectedDueDate__c = snline.gii__PurchaseOrder__r.gii__RequiredDate__c;
            }else{
                prodPlan.giic_ExpectedDueDate__c =snline.gii__SuggestedDueDate__c;
            }
            prodPlan.giic_PublishDueDate__c =snline.gii__SuggestedDueDate__c;
            prodPlan.giic_StandardTransitTime__c =snline.gii__InTransitLeadTime__c;
             if(snline.gii__SuggestedDueDate__c !=null){
               Integer stdime = Integer.ValueOf(snline.gii__InTransitLeadTime__c)!=null?Integer.ValueOf(snline.gii__InTransitLeadTime__c):0;
               prodPlan.giic_PublishEndOfProductionDate__c = snline.gii__SuggestedDueDate__c.addDays(-stdime);
               prodPlan.giic_ProposedEndofProductionDate__c = snline.gii__SuggestedDueDate__c.addDays(-stdime);
               prodPlan.giic_PublishEndOfProductionWeek__c  = Integer.valueOf(getWeekNumber(prodPlan.giic_ProposedEndofProductionDate__c));
            }
            upsertPPRecords.add(prodPlan);
                
            supplierIds.add(snline.gii__Supplier__c);
            productLineIds.add(snline.gii__WeeklyCapacity__r.gii__ProductionLine__c);
        }
        system.debug('upsertPPRecords'+upsertPPRecords);
        try{
            if(upsertPPRecords.size()>0){
                upsert upsertPPRecords;
                //Update Approve flag on associated purchase order for supply plan netting line
                List<gii__PurchaseOrder__c> purchaseOrderList=new List<gii__PurchaseOrder__c>();
                for(gii__SupplyPlanNettingLine__c snline:scope){
                    String ppKey = snline.Id;//snline.gii__SupplyPlanCycle__c+''+snline.gii__WeeklyCapacity__r.gii__ProductionLine__c+''+snline.gii__WeeklyCapacity__c+''+snline.gii__Supplier__c;
                    snline.giic_WorkOrderIssueStaging__c = ppMap.get(ppKey).Id;
                    
                    gii__PurchaseOrder__c po = new gii__PurchaseOrder__c(Id= snline.gii__PurchaseOrder__c, gii__Approved__c=true);
                    purchaseOrderList.add(po);
                }
                
                update scope;
                count++;
                
                //if(purchaseOrderList.size()>0)
               //  update purchaseOrderList;
            }
        }
        catch(Exception e){
            List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
            giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'Generate Production Plan',supplyPlanCycleID,false);
            insert errorLogs;
            system.debug('Exception while inserting the Production Plan'+e); 
        }
    }

    /* Method name : finish
    * Description : finish method will update the demand forecast setup record and call call another batch to update Maximum capacity on production plan
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    global void finish(Database.BatchableContext bc){ 
            
        List<gii__DemandForecastSetup__c> updateDFSList=new List<gii__DemandForecastSetup__c>();
        List<gii__DemandForecastSetup__c> dFSList  =[select id,giic_BatchStatus__c from gii__DemandForecastSetup__c where giic_Supply_Plan_Cycle__c=:supplyPlanCycleId and giic_RelatedTo__c=:giic_Constants.SUPPLYPLAN AND giic_ApprovalStatus__c=:giic_Constants.APPROVED];
        if(dFSList !=null && dFSList.size()>0){ //&& count >0
            for(gii__DemandForecastSetup__c dfs : dFSList){
                gii__DemandForecastSetup__c updateDFS=new gii__DemandForecastSetup__c();
                updateDFS.id=dfs.id;
                updateDFS.giic_BatchStatus__c=giic_Constants.COMPLETED;
                updateDFSList.add(updateDFS);
         }
         if(updateDFSList.size()>0){
             update updateDFSList;
         }
        }
        /*else if(dFSList.size()>0 && count==0){
            for(gii__DemandForecastSetup__c dfs : dFSList){
                gii__DemandForecastSetup__c updateDFS=new gii__DemandForecastSetup__c();
                updateDFS.id=dfs.id;
                updateDFS.giic_BatchStatus__c='';
                updateDFSList.add(updateDFS);
         }
         if(updateDFSList.size()>0){
             update updateDFSList;
         }
        }*/
    }

    public static String getWeekNumber(Date dt) { 
        Datetime weekFormat = datetime.newInstance(dt.year(), dt.month(), dt.day());
        return weekFormat.format('w');
    }
}