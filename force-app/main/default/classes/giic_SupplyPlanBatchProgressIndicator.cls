/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 23 Mar 2022
Function : Class to process activities related to Supply Plan Progress Bar
Reviewer : Akash Garg
*************************************************************************************/

public with sharing class giic_SupplyPlanBatchProgressIndicator {
    
    /* Method name : getSPCData
    * Description : This method return boolean
    * Return Type : Boolean
    * Parameter : Supply Plan Cycle Record ID
    */
    @AuraEnabled
    public static Boolean getSPCData(String recId){
        return [select id, giic_SetupSupplyPlanReady__c from gii__SupplyPlanCycle__c where id =:recId].giic_SetupSupplyPlanReady__c; 
    }
    
    
    @AuraEnabled
    public static Id executeBatchjob(string recId){
        Id batchJobId = Database.executeBatch(new giic_roundOffOrderQuantityBatch(recId),100);
        giic_BatchProgress__c jobstatus = new giic_BatchProgress__c();
        jobstatus.Name = batchJobId; 
        jobstatus.giic_JobId__c = batchJobId;
        jobstatus.giic_Status__c=giic_Constants.RESETWEEKBATCHSTATUS;
        insert jobstatus;
        return batchJobId;
    }
    
    @AuraEnabled
    public static Map<String,Object> getBatchJobStatus(String recId){
        Map<String,Object> mp = new Map<String,Object>();
        List<String> batchStatusLst = new List<String>();
        List<giic_BatchProgress__c> batchStatusLstUpdated = new List<giic_BatchProgress__c>();
        List<giic_BatchProgress__c> batchStatusLstOld = new List<giic_BatchProgress__c>();
        List<AsyncApexJob> jobInfo = new List<AsyncApexJob>();
        for(giic_BatchProgress__c batchStatus :[Select giic_JobId__c from giic_BatchProgress__c where giic_Status__c=:giic_Constants.RESETWEEKBATCHSTATUS]){
            batchStatusLst.add(batchStatus.giic_JobId__c);
            batchStatusLstOld.add(batchStatus);
        }
        
        jobInfo = [SELECT Id,Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id IN : batchStatusLst];
        for(AsyncApexJob asynJob : jobInfo){
            for(giic_BatchProgress__c batchSt : batchStatusLstOld){
                if(batchSt.giic_JobId__c == asynJob.Id && asynJob.Status==giic_Constants.COMPLETED){
                    giic_BatchProgress__c batchJob = new giic_BatchProgress__c();
                    batchJob.Id = batchSt.Id;
                    batchStatusLstUpdated.add(batchJob);
                }
            }
        }
        if(batchStatusLstUpdated.size()>0){
            
            delete batchStatusLstUpdated;
        }
        Boolean isTrue =  [select id, giic_SetupSupplyPlanReady__c from gii__SupplyPlanCycle__c where id =:recId].giic_SetupSupplyPlanReady__c;
       	mp.put('SPC',isTrue);
        mp.put('jobInfo',jobInfo);
        return mp;
    }
}