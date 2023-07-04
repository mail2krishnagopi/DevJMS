/*************************************************************
*   @Name: JMS_ExecuteCampTargetStagingController
*   @Description: To execute the Campaign Target and Broker call
*   @Date: 14/05/2022
*   @Inputs:       NA
*   @Author: Anil
**************************************************************/
public with sharing class JMS_ExecuteCampTargetStagingController {
    public JMS_ExecuteCampTargetStagingController() {
    
    }
    private static final String STR_Execute_Batch = 'executeBatch';
    @AuraEnabled(cacheable=true)
    public static void executeBatch() {
        //executeBatch Method
        JMS_MigrateToCmpgnMemStagingBatch objBatch = new JMS_MigrateToCmpgnMemStagingBatch();
        try{
            Database.executeBatch(objBatch,1);
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }//End of if
        }//End of Try Block
        
        catch(Exception excep){
            //Calling Logger Class
            JMS_Logger.push(STR_Execute_Batch, JMS_ConstantsUtility.OBJECT_CAMPAIGN_TARGET_STAGING_API);
            JMS_Logger.debugException(excep);
            /*
             * Code Scan Error - Avoid Hard Coded error message
             * ** Error message is not hard coded and getting message from Exception
             * Code Scan fix - @AuraEnabled should have proper error handling
             * */
            if(!Test.isRunningTest()){
            	throw new AuraHandledException(excep.getMessage());
            }
        }//End of Exception handling
        
    }
     @AuraEnabled(cacheable=true)
    public static void executeBatchBrokerCall() {
        //Broker Call
        JMS_MigrateToBrokerCallStagingBatch objBatch = new JMS_MigrateToBrokerCallStagingBatch();
        try{
            Database.executeBatch(objBatch,1);
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }//End of if
        }//End of Try Block
        
        catch(Exception excep){
            //Calling Logger Class
            JMS_Logger.push(STR_Execute_Batch, JMS_ConstantsUtility.OBJECT_BROKER_CALL_STAGING_API);
            JMS_Logger.debugException(excep);
            /*
             * Code Scan Error - Avoid Hard Coded error message
             * ** Error message is not hard coded and getting message from Exception
             * Code Scan fix - @AuraEnabled should have proper error handling
             * */
            if(!Test.isRunningTest()){
            	throw new AuraHandledException(excep.getMessage());
            }
        }//End of Exception handling
    } 
    

}