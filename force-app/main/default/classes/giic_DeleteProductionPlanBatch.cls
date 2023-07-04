/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 01 Apr 2022
Function : batch Class to delete production plan records based on SPC id
Reviewer - Soni Jagdale
*************************************************************************************/

public class giic_DeleteProductionPlanBatch implements Database.Batchable<sObject>, Database.Stateful {

    public string spcId;

    public giic_DeleteProductionPlanBatch(String supplyPlanCycleId) {
        this.spcId = supplyPlanCycleId;
    }

    /* Method name : start
    * Description : Start method which will get all production plan records as per ID received in constructor
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
    
        //get all production plan. // TODO Filter
        return Database.getQueryLocator([select id from gii__ProductionPlan__c where giic_SupplyPlanCycle__c=:spcId]); //and giic_Region__c= :regionVal
    }
    
    
    /* Method name : execute
    * Description : execute method will delete all production plan records
    * Return Type : void
    * Parameter : List<gii__DemandForecastLine__c>
    */
    public void execute(Database.BatchableContext bc, List<gii__ProductionPlan__c> scope){

        if(!scope.isEmpty()){
            delete scope;
        }
    }

    /* Method name : finish
    * Description : finish method will call giic_DeleteWorkOrderCompletionStagingBatch 
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){ 
        if(!Test.isRunningTest()){
            Database.executeBatch(new giic_DeleteWOCompletionStagingBatch(spcId));
        } 
    }   
}