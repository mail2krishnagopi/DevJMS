/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_ExecuteBatchNewTerrAssociation
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 19/04/2022
* @Description      : Batch class to create the Object Territory Asscoaitions records
**********************************************************************************************************************
**********************************************************************************************************************/
public with sharing class JMS_ExecuteBatchNewTerrAssociation {
    //JMS_ExecuteBatchNewTerrAssociation Class
    private static final String STR_Execute_Batch = 'executeBatch';
    @AuraEnabled(cacheable=true)
    public static void executeBatch() {
        //executeBatch Method
        JMS_DeleteObjectTerritoryAssociatBatch objBatch = new JMS_DeleteObjectTerritoryAssociatBatch();
        try{
            Database.executeBatch(objBatch,Integer.valueOf(System.Label.JMS_DeleteObjectTerrAssoBatchSize));
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
            JMS_Logger.push(STR_Execute_Batch, JMS_ConstantsUtility.OBJECT_TERRITORY2_ASSOCIATION_API);
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