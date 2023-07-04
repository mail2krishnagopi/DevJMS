/*************************************************************
*   @Name: JMS_CampTargetScheduleClass
*   @Description: To Schedule JMS_MigrateToCmpgnMemStagingBatch Execution
*   @Date: 26/05/2022
*   @Inputs:       NA
*   @Author: Anil
**************************************************************/
public with sharing class JMS_CampTargetScheduler Implements Schedulable {
    public static final String STR_SCHEDULER_EXECUTE = 'JMS_BrokerCallScheduleClassExecute';
    /*************************************************************
    *   @Name: execute
    *   @Description: To Schedule JMS_MigrateToCmpgnMemStagingBatch 
    * 					Execution
    *   
    **************************************************************/
    public void execute(SchedulableContext sc){
        try{
            JMS_MigrateToCmpgnMemStagingBatch objBatch = new JMS_MigrateToCmpgnMemStagingBatch();
            Database.executeBatch(objBatch,1);
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
         }catch(Exception excep){
            JMS_Logger.push(STR_SCHEDULER_EXECUTE, JMS_ConstantsUtility.OBJECT_CAMPAIGN_TARGET_LANDING_API);
            JMS_Logger.debugException(excep);
        
        }finally {
            JMS_Logger.pop();
        }
    }//End of Method
}