/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 03/12/2021
Function :The Purpose of this class is to Delete Delivery Plan for same supply plan cycle
*************************************************************************************/
global with sharing class giic_DeleteDeliveryPlanBatch implements Database.Batchable<sObject>, Database.Stateful{
    global String supplyPlanCycleId;
    global giic_DeleteDeliveryPlanBatch(String supplyPlanCycleId) {
        this.supplyPlanCycleId = supplyPlanCycleId;
    }

    /*
    * Description : Start method which returns all Delivery Plan for same cycle
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        //get all Delivery Plan. 
        return Database.getQueryLocator([select id from gii__DeliveryPlan__c where giic_SupplyPlanCycle__c =:supplyPlanCycleId]);
    }

     /* Method name : execute
    * Description : execute method will delete Delivery Plan for supply plan cycle
    * Return Type : void
    * Parameter : List<gii__DeliveryPlan__c>
    */

    global void execute(Database.BatchableContext bc, List<gii__DeliveryPlan__c> scope){
        if(scope.size()>0){
            delete scope;
        }
    }

    /* Method name : finish
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    global void finish(Database.BatchableContext bc){ 

        if(!Test.isRunningTest()){

            Database.executeBatch(new giic_DeleteWorkOrderIssueStagingBatch(supplyPlanCycleId));

        }
    }
    
}