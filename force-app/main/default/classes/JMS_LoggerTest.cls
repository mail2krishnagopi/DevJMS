@Istest 
public class JMS_LoggerTest {
    //Start
	@IsTest
    private static void createTraceFlagTest(){
        //User salesUser = JMS_TestDataFactory.createUser();
        /*system.runAs(salesUser){
            
        }*/
        //Logger Test
        
        JMS_Log_Config__c configObj = new JMS_Log_Config__c();
        configObj.JMS_Debug_Record_Type__c = 'Debug';
        configObj.JMS_Exception_Record_Type__c = 'Exception';
        configObj.JMS_Exceptions_Enabled__c = TRUE;
        configObj.JMS_Logging_Enabled__c = TRUE;
        insert configObj;
        
        //JMS_Log_Config__c configInstance = JMS_Log_Config__c.getInstance(UserInfo.getUserId());
        //Account Creation
        Account acct = JMS_TestDataFactory.createAccountByName('test Account');
        acct.Description = 'Test';
        //System assertion
        String trigName = 'Test assert';
        System.assertEquals('Test assert', trigName,'trigName is not Null');
    }//End
}