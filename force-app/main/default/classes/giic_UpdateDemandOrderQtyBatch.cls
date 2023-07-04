/* Akash Garg    13/12/2021   Batch Class to update the Demand Order Quantity on Demand forecast line
* ----------------------------------------------------------------------------
*************************************************************************************/

public class giic_UpdateDemandOrderQtyBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    //Variable definiation
    public date startDate;
    public date endDate;
    set<id> forecastSetupId=new Set<id>();
    public integer count = 0;
    public string region;
    public string demandForecastCycleId;
    
    //Constructor 
    public giic_UpdateDemandOrderQtyBatch(Date startDate, Date endDate,string region,String dfcID){
        this.startDate=startDate;
        this.endDate=endDate;
        system.debug('inside constructor'+this.region);
        this.region=region.replace('(','').replace(')','').replaceAll('\'','');
        this.demandForecastCycleId = dfcID;
    }
    
    /* Method name : start
    * Description : Start method which will get all Demand forecast line line which is Approved and in between date range from Constructor
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
    system.debug('regionregion'+region);
        //get all Demand forecast line line which is Approved and in between date range from Constructor.
        return Database.getQueryLocator([select id,giic_ProductReference__c,giic_Status__c,gii__PriorAmount__c,gii__PriorQuantity__c,
        giic_OpportunityProduct__c,giic_DemandForecastSetup__c,giic_DemandForecastSetup__r.giic_DemandForecastCycle__c,
        giic_DemandPlanCurrentQuantity__c,giic_DemandPlanPriorQuantity__c,gii__DemandForecast__c,gii__DemandForecast__r.gii__ProductInventory__c,
        gii__DemandForecast__r.gii__Warehouse__c,gii__DemandForecast__r.gii__ProductReference__c,gii__CurrentQuantity__c 
        from gii__DemandForecastLine__c where giic_DemandForecastSetup__r.giic_ApprovalStatus__c='Approved' /*and 
        giic_DemandForecastSetup__r.giic_DemandForecastCycle__r.gii__Active__c=true*/ and 
        giic_DemandForecastSetup__r.giic_Region__c =: region and giic_DemandForecastSetup__r.giic_DemandForecastCycle__c =:demandForecastCycleId and giic_Station__c=null
        /*and giic_DemandForecastSetup__r.giic_DemandForecastCycle__r.gii__StartDate__c >= :startDate and giic_DemandForecastSetup__r.giic_DemandForecastCycle__r.gii__EndDate__c <= :endDate*/ order by gii__Date__c]);
    }
    
    
    /* Method name : execute
    * Description : execute method will create and update the demand forecast lines
    * Return Type : void
    * Parameter : List<gii__DemandForecastLine__c>
    */
    public void execute(Database.BatchableContext bc, List<gii__DemandForecastLine__c> scope){
        //varaible declaration
        system.debug('scopescope' +scope);
        Map<string,gii__ProductInventory__c> prodInventoryMap=new Map<string,gii__ProductInventory__c>();
        List<id> dflProduct=new List<id>();
        List<id> dflWarehouse=new List<id>();
        Map<string,Decimal> prodInventryAvailable=new Map<string,Decimal>();
        Map<string,Decimal> prodInventrySafety=new Map<string,Decimal>();
        Map<string,Decimal> prodInventryInHand=new Map<string,Decimal>();
        List<gii__DemandForecastLine__c> listtoupdateDFL=new List<gii__DemandForecastLine__c>();
        //loop over data return from start method to get unique product and warehouse
        for(gii__DemandForecastLine__c dfline:scope){
            dflProduct.add(dfline.gii__DemandForecast__r.gii__ProductReference__c);
            dflWarehouse.add(dfline.gii__DemandForecast__r.gii__Warehouse__c);
        }
        //SOQL on product inventory to get data by passing unique product and warehouse
        List<gii__ProductInventory__c> productInventorylist=[select id,gii__AvailableQuantity__c,gii__InTransitQuantity__c,gii__Warehouse__c,gii__OrderPointQuantity__c,gii__Product__c,giic_ProductCode__c,gii__SafetyStockQuantity__c from gii__ProductInventory__c where gii__Product__c in:dflProduct and gii__Warehouse__c in:dflWarehouse];
        system.debug('productInventorylist'+productInventorylist.size());
        system.debug('productInventorylist gii__InTransitQuantity__c'+productInventorylist[0].gii__InTransitQuantity__c);
        //loop over on product inventory
        for(gii__ProductInventory__c pi:productInventorylist){
            prodInventoryMap.put(pi.gii__Product__c+''+pi.gii__Warehouse__c,pi);
            //getting the value from product inventory and putting in map.
            prodInventryAvailable.put(pi.gii__Product__c+''+pi.gii__Warehouse__c,(pi.gii__AvailableQuantity__c==null?0:pi.gii__AvailableQuantity__c)+(pi.gii__InTransitQuantity__c==null?0:pi.gii__InTransitQuantity__c));
            prodInventrySafety.put(pi.gii__Product__c+''+pi.gii__Warehouse__c,(pi.gii__OrderPointQuantity__c==null?0:pi.gii__OrderPointQuantity__c)+(pi.gii__SafetyStockQuantity__c==null?0:pi.gii__SafetyStockQuantity__c));
            prodInventryInHand.put(pi.gii__Product__c+''+pi.gii__Warehouse__c,(pi.gii__AvailableQuantity__c==null?0:pi.gii__AvailableQuantity__c)+(pi.gii__InTransitQuantity__c==null?0:pi.gii__InTransitQuantity__c)-(pi.gii__OrderPointQuantity__c==null?0:pi.gii__OrderPointQuantity__c)-(pi.gii__SafetyStockQuantity__c==null?0:pi.gii__SafetyStockQuantity__c));
        }
        system.debug('prodInventryInHand ---'+prodInventryInHand);
        //loop on data return from start method to set available qty, safety qty and total available qty on demand forecat line.
        for(gii__DemandForecastLine__c dfl:scope){
            forecastSetupId.add(DFL.giic_DemandForecastSetup__c);
            gii__DemandForecastLine__c updateDFL=new gii__DemandForecastLine__c();
            updateDFL.id=dfl.id;
            system.debug('key is'+dfl.gii__DemandForecast__r.gii__ProductReference__c+ 'ware' +dfl.gii__DemandForecast__r.gii__Warehouse__c);
            //checking in inhand qty is greater than 0.
            if(prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)>0){
                if(prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)>dfl.gii__CurrentQuantity__c){
                    //getting the value from product inventory map and setting in demand forecast line
                    updateDFL.giic_DemandPlanCurrentQuantity__c=0;
                    updateDFL.giic_PIAvailableforDemandOrder__c=prodInventryAvailable.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                    updateDFL.giic_PISafetyStockQuantity__c=prodInventrySafety.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                    updateDFL.giic_PITotalAvailableQuantity__c=prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                    //putting the value in map by substracting the used qty for demand order.
                    prodInventryAvailable.put(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c,(prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)-dfl.gii__CurrentQuantity__c)+prodInventrySafety.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c));
                    prodInventryInHand.put(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c,prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)-dfl.gii__CurrentQuantity__c);
                }
                else {
                     //getting the value from product inventory map and setting in demand forecast line
                    updateDFL.giic_DemandPlanCurrentQuantity__c=(prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)-dfl.gii__CurrentQuantity__c)*(-1);
                    updateDFL.giic_PIAvailableforDemandOrder__c=prodInventryAvailable.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                    updateDFL.giic_PISafetyStockQuantity__c=prodInventrySafety.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                    updateDFL.giic_PITotalAvailableQuantity__c=prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                    //putting the value in map by substracting the used qty for demand order.
                    prodInventryAvailable.put(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c, 0);
                    prodInventryInHand.put(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c, 0);
                    /*
                    prodInventryAvailable.put(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c,(prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)-dfl.gii__CurrentQuantity__c)+prodInventrySafety.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c));
                    
                    prodInventryInHand.put(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c,prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)-dfl.gii__CurrentQuantity__c);
                    */
                }
            }
            else {
                //checking if inhand qty is 0, if yes then set the same value for demand order current qty.
                if(prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)==0){
                    updateDFL.giic_DemandPlanCurrentQuantity__c=dfl.gii__CurrentQuantity__c;
                }
                else{
                    //multiplying by -1 in case of inhand qty is negative
                    updateDFL.giic_DemandPlanCurrentQuantity__c=dfl.gii__CurrentQuantity__c+(prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c)*(-1));
                }
                
                updateDFL.giic_PIAvailableforDemandOrder__c=prodInventryAvailable.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                updateDFL.giic_PISafetyStockQuantity__c=prodInventrySafety.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                updateDFL.giic_PITotalAvailableQuantity__c=prodInventryInHand.get(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c);
                prodInventryAvailable.put(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c,0);
                prodInventryInHand.put(dfl.gii__DemandForecast__r.gii__ProductReference__c+''+dfl.gii__DemandForecast__r.gii__Warehouse__c,0);
            }
            listtoupdateDFL.add(updateDFL);
        }
        
        //SOQL on demand forecast setup and updating the batch status to completed
        List<gii__DemandForecastSetup__c> listtoUpdateDFS=[select id,giic_BatchStatus__c from gii__DemandForecastSetup__c where id in:forecastSetupId and giic_BatchStatus__c=:giic_Constants.INPROGRESS and giic_RelatedTo__c =: giic_Constants.FORECASTPLAN];
        
        try{
            //updating the list of demand forecast line.
            if(listtoupdateDFL.size()>0)
                {update listtoupdateDFL;}
                count++;
        }
        catch(Exception e){
            List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
             giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'Update Demand Order Qty',demandForecastCycleId,true);
            insert errorLogs;
            for(gii__DemandForecastSetup__c dfs:listtoUpdateDFS){
                dfs.giic_BatchStatus__c=giic_Constants.FAILED;
            }
            if(listtoUpdateDFS.size()>0){
                update listtoUpdateDFS;
            }
            System.debug('Exception while updating Demand Order Qty'+e);
        }
    }
    
    /* Method name : finish
    * Description : finish method will update the demand forecast setup record
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){ 
        List<gii__DemandForecastSetup__c> listtoUpdateDFS=[select id,giic_BatchStatus__c from gii__DemandForecastSetup__c where id in:forecastSetupId and giic_BatchStatus__c=:giic_Constants.INPROGRESS and giic_RelatedTo__c =: giic_Constants.FORECASTPLAN and giic_Region__c =:region];

        for(gii__DemandForecastSetup__c dfs:listtoUpdateDFS){
            //if(count > 0){
                dfs.giic_BatchStatus__c = giic_Constants.COMPLETED;
            //}else{
              //  dfs.giic_BatchStatus__c = '';   
            //}   
        }
        try{
            if(listtoUpdateDFS.size()>0)
                {update listtoUpdateDFS;}
        }
        catch(Exception e){
            List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
            errorLogs = giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'Update DemandOrder Qty',demandForecastCycleId,true);
            insert errorLogs;
            system.debug('Unable to update the demand forecast setup'+e);
        }
    }
}