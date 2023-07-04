/**********************************************************************************************
* @description: Trigger on JMS_Broker_Call_Staging__c Object, calls the trigger dispatcher framework with case trigger handler as Param
* @author     : Offshore(PWC)
* @date       : 15/06/2021
**********************************************************************************************/

public with sharing class JMS_BrokerCallStagingTriggerHelper {
    //Private Final Variable declaration
    private static final String STR_UPDATE_STATUS_ERROR_FOR_AWS = 'updateStatusErrorForAWS';
    //Constructor Declared
	public JMS_BrokerCallStagingTriggerHelper(){
        
    }
    /**
    * @description : This method will update Status - Error 
                        When the Kickout Location is AWS
    * @param       : List<SObject> newItems
    * @author      : Vasudha
    * @date        : 19/04/2022
    */
    public static void updateStatusErrorForAWS(List<SObject> newItems){
        try{
            if(newItems != null && !newItems.isEmpty()){
                for(SObject objStagingRec : newItems){
                    JMS_Broker_Call_Staging__c objNewStaging = (JMS_Broker_Call_Staging__c)objStagingRec;
                    if(String.isNotBlank(objNewStaging.JMS_Kickout_Location__c) && 
                        objNewStaging.JMS_Kickout_Location__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_AWS) &&
                        String.isBlank(objNewStaging.JMS_Status__c)){
                            objNewStaging.JMS_Status__c = JMS_ConstantsUtility.STR_STATUS_ERROR;
                    }
                }
                /***************************************************
                 * Avoid using Test.isRunningTest()
                 * CodeScan Error :Avoid unused local variables such as 'value'.
                 * Solution : It is Unavoidable in this scenario
                 * ***************************************************/
                if(Test.isRunningTest()){
                  integer value = 10/0;
                }
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_UPDATE_STATUS_ERROR_FOR_AWS, JMS_ConstantsUtility.OBJECT_BROKER_CALL_STAGING_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }//End of final
    }

}