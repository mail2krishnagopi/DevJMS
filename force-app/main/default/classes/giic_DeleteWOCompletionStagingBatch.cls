/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 19 Apr 2022
Function : batch Class to delete Work Order Completion Staging Records based on SPC id
Reviewer - Vidya Chirlanchi
*************************************************************************************/

public class giic_DeleteWOCompletionStagingBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public String spcId;
    public giic_DeleteWOCompletionStagingBatch(String supplyPlanCycleId) {
        this.spcId = supplyPlanCycleId;

    }

    /* Method name : start
    * Description : Start method which will get all Work Order Completion Staging Records  as per ID received in constructor
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
    
        //get all Work Order Completion Staging Records. // TODO Filter
        return Database.getQueryLocator([select id from gii__WorkOrderCompletionStaging__c where giic_SupplyPlanCycle__c =:spcId]); //and giic_Region__c= :regionVal
    }
    
    
    /* Method name : execute
    * Description : execute method will delete all Work Order Completion Staging Records 
    * Return Type : void
    * Parameter : List<gii__WorkOrderCompletionStaging__c>
    */
    public void execute(Database.BatchableContext bc, List<gii__WorkOrderCompletionStaging__c> scope){

        if(!scope.isEmpty()){
            delete scope;
        }
    }

    /* Method name : finish
    * Description : finish method will call giic_ResetWeeklyCapacityUtilize batch
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){ 
        if(!Test.isRunningTest()){
            Database.executeBatch(new giic_ResetWeeklyCapacityUtilize(spcId));
        } 
    }   
}