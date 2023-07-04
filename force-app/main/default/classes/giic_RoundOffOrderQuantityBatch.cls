/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 29/11/2021
Function :The Purpose of this class is to update create the Production Plan as per Production Line,week number and Supplier
*************************************************************************************/

global class giic_RoundOffOrderQuantityBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String spcId;

    global giic_RoundOffOrderQuantityBatch(String recordId) {
        this.spcId = recordId;
    }

    /*
    * Description : Start method which returns all Supply plan netting lines for same cycle
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        //get all Production Plan.
        return Database.getQueryLocator([select id,gii__OrderQuantity__c,gii__SupplyPlanNetting__c,gii__SupplyPlanCycle__c from gii__SupplyPlanNettingLine__c where gii__SupplyPlanCycle__c =:spcId and gii__OrderType__c =: giic_Constants.CPO]);
    }
    
    /* Method name : execute
    * Description : execute method will update the Supply plan netting record
    * Return Type : void
    * Parameter : List<gii__ProductionPlan__c>
    */
    global void execute(Database.BatchableContext bc,List<gii__SupplyPlanNettingLine__c> scope){
        if(!scope.isEmpty()){
            for(gii__SupplyPlanNettingLine__c objspnl : scope){
                if(objspnl.gii__OrderQuantity__c!= null && objspnl.gii__OrderQuantity__c > 0){
                    objspnl.gii__OrderQuantity__c = objspnl.gii__OrderQuantity__c.setScale(0,RoundingMode.HALF_UP);
                }
            }
        }
        try{
            if(!scope.isEmpty()){
                update scope;
            }
        }catch(Exception e){
            System.debug('Execption occured ---' +e.getMessage());
            List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
            giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'Round Off Order Quantity on Supply Plan',spcId,true);
            insert errorLogs;
        }
        

    }

    /* Method name : finish
    * Description : finish method will update the supply plan cycle record
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    global void finish(Database.BatchableContext bc){
        List<gii__DemandForecastSetup__c> dFSList=[select id from gii__DemandForecastSetup__c where giic_Supply_Plan_Cycle__c=:spcId and giic_RelatedTo__c=:giic_Constants.SUPPLYPLAN]; 
        if(!dFSList.isEmpty()){
            delete dFSList;
        } 
        if(!Test.isRunningTest()){
            Database.executeBatch(new giic_DeleteDeliveryPlanBatch(spcId));
        } 
    }
}