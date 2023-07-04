//This the test class for JMS_MigrBrkCallStgnToSObjectHelper class.
@Istest
//The test data setup for this test class.
private class JMS_MigrBrkCallStgnToSObjectHelperTest {
    @testSetup static void setup(){
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        Opportunity opp = JMS_TestDataFactory.createOpportunity('Test Opportunity',acc.ID);
        opp.Description = 'Test opp';
        
    }
    //This is first test method in the JMS_MigrBrkCallStgnToSObjectHelperTest class.
    @IsTest
    private static void checkBrokerCallValidationsTest(){
        Account acc = [SELECT Id, Name From Account WHERE Name = 'Test Account' LIMIT 1];
        acc.JMS_Plan_to_Code__c = '12323';
        Campaign camp = JMS_TestDataFactory.createCampaign('New Campaign');
        camp.Description = 'Test camp 001';
        Product2 prd = JMS_TestDataFactory.createProduct();
        prd.Description = 'Test Prod';
        JMS_Broker_Call_Landing__c brkCall = JMS_TestDataFactory.createBrokerCallStaging();
        List<JMS_Broker_Call_Landing__c> brkCallList = new List<JMS_Broker_Call_Landing__c>();
        brkCallList.add(brkCall);
        //List of Broker Call Landing Object
        //The test starts from here.
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObjectHelper.validateBrokerCall(brkCall);
        System.assert(brkCallList.size()>0,'List is not Null');
        Test.stopTest();
        //The test ends here.
    }
    //This is second test method in the JMS_MigrBrkCallStgnToSObjectHelperTest class.
    @IsTest
    private static void checkBrokerCallValidationsTest1(){
        JMS_Broker_Call_Landing__c brkCall = JMS_TestDataFactory.createBrokerCallStaging();
        brkCall.JMS_Broker_Name__c = 'IA';
        List<JMS_Broker_Call_Landing__c> brkCallList = new List<JMS_Broker_Call_Landing__c>();
        brkCallList.add(brkCall);
        //List of Broker Call Landing Object
        //The test starts from here.
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObjectHelper.validateAccount(brkCall);
        System.assert(brkCallList.size()>0,'List is not Null');
        Test.stopTest();
        //The test ends here.
    }
}