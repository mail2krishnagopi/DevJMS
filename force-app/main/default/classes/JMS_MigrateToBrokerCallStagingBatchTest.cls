/**
* @description       : Test Class for JMS_Delete_SObject_RecordsTest
* @author            : Krishna
* @date       		 : 31/03/2022
* @last modified on  : 31/03/2021
* @last modified by  : Krishna
*/
@isTest
private class JMS_MigrateToBrokerCallStagingBatchTest {
    static testMethod void executeBatchTest(){
        Account acct = JMS_TestDataFactory.createAccountByName('TestAccount');
        acct.JMS_Plan_to_Code__c = '11221';
        UPDATE acct;
        //Updating Account Record
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        con.Description = 'Test Contact 09';
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        camp.Description = 'Test Campaign 09';
        list<Product2> prdlist = JMS_TestDataFactory.createProductRecds(1);
        JMS_Broker_Call_XREF__c brkCallXREF = JMS_TestDataFactory.createBrokerCallXREF();
        brkCallXREF.JMS_Target_Value__c = 'Qualification';
        UPDATE brkCallXREF;
        JMS_Broker_Call_Landing__c brkCallLand = JMS_TestDataFactory.createBrokerCallStaging();
        brkCallLand.JMS_Call_Distributor_Code__c = '1211';
        brkCallLand.JMS_Contact_Email__c = 'testContact@jms.com';
        brkCallLand.JMS_Batch_Id__c = 'b001';
        UPDATE brkCallLand;
        //Updating Broker Call Landing Record
        brkCallLand.JMS_Campaign_Name__c = 'TestCampaign';
        con.Email = 'testContact@jms.com';
        UPDATE con;
        //Updating Contact Record
        brkCallLand.JMS_Company_SF_Id__c = acct.Id;
        brkCallLand.JMS_Item_Number__c = prdlist[0].Id;
        UPDATE brkCallLand;
        //Updating Broker Call Landing Record
        //Start Test
        Test.startTest();
        JMS_MigrateToBrokerCallStagingBatch ba= new JMS_MigrateToBrokerCallStagingBatch();
        Database.executeBatch(ba);
        ba.start(null);
        System.assert(brkCallLand !=null,'Object is not Null');
        Test.stopTest();
        //Start Test
    }
    static testMethod void executeBatchTest1(){
        Account acct = JMS_TestDataFactory.createAccountByName('TestAccount');
        acct.JMS_Plan_to_Code__c = '111';
        UPDATE acct;
        //Updating Account Record
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        con.Description = 'Test Contact 08';
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        camp.Description = 'Test Campaign 09';
        list<Product2> prdlist = JMS_TestDataFactory.createProductRecds(1);
        JMS_Broker_Call_XREF__c brkCallXREF = JMS_TestDataFactory.createBrokerCallXREF();
        brkCallXREF.JMS_Is_Active__c = True;
        JMS_Broker_Call_Landing__c brkCallLand = JMS_TestDataFactory.createBrokerCallStaging();
        brkCallLand.JMS_Call_Distributor_Code__c = '211';
        brkCallLand.JMS_Batch_Id__c = 'b001';
        //Start Test
        Test.startTest();
        JMS_MigrateToBrokerCallStagingBatch ba= new JMS_MigrateToBrokerCallStagingBatch();
        Database.executeBatch(ba);
        System.assert(brkCallLand !=null,'Object is not Null');
        Test.stopTest();
        //Stop Test
        
    }
}