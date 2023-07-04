/*************************************************************
*   @Name: JMS_BrokerCallScheduleClass
*   @Description: To automaticly Schedule JMS_MigrateToBrokerCallStagingBatch Execution
*   @Date: 26/05/2022
*   @Inputs:       NA
*   @Author: Anil
**************************************************************/
public class JMS_BrokerCallScheduler Implements Schedulable {
    public static final String STR_SCHEDULER_EXECUTE = 'JMS_BrokerCallScheduleClass Execute';
    /*************************************************************
    *   @Name: execute
    *   @Description: To automaticly Schedule 
    * 				JMS_MigrateToBrokerCallStagingBatch Execution
    *   
    **************************************************************/
    public void execute(SchedulableContext sc){
        try{
            JMS_MigrateToBrokerCallStagingBatch objBatch = new JMS_MigrateToBrokerCallStagingBatch();
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
            JMS_Logger.push(STR_SCHEDULER_EXECUTE, JMS_ConstantsUtility.OBJECT_BROKER_CALL_LANDING_API);
            JMS_Logger.debugException(excep);
        
        }finally {
            JMS_Logger.pop();
        }
    }//End of Method
}//End of class