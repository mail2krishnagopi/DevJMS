/**
* @description       : Test Class for JMS_DeleteBrokerCallRecords
* @author            : Shiv Gupta
* @date              : 18/05/2023
* @last modified on  : 18/05/2023
* @last modified by  : Shiv
*/
@isTest
private class JMS_DeleteBrokerCallRecordsTest {
    static testMethod void executeBatchTest(){
        List<JMS_Broker_Call__c> lstBC = new List<JMS_Broker_Call__c>();
        Account acct = JMS_TestDataFactory.createAccountByName('TestAccount');
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        JMS_Broker_Call__c objBC1 = new JMS_Broker_Call__c();
        objBC1.Account__c = acct.Id;
        objBC1.JMS_Campaign__c = camp.Id;
        objBC1.JMS_Call_Status__c = 'Complete';
        lstBC.add(objBC1);
        
        JMS_Broker_Call__c objBC11 = new JMS_Broker_Call__c();
        objBC11.Account__c = acct.Id;
        objBC11.JMS_Campaign__c = camp.Id;
        objBC11.JMS_Call_Status__c = 'Complete';
        lstBC.add(objBC11);
        
        JMS_Broker_Call__c objBC2 = new JMS_Broker_Call__c();
        objBC2.Account__c = acct.Id;
        objBC2.JMS_Campaign__c = camp.Id;
        lstBC.add(objBC2);
        
        JMS_Broker_Call__c objBC21 = new JMS_Broker_Call__c();
        objBC21.Account__c = acct.Id;
        objBC21.JMS_Campaign__c = camp.Id;
        lstBC.add(objBC21);
        
        insert lstBC;
        
        //Start Test
        Test.startTest();
        JMS_DeleteBrokerCallRecords ba= new JMS_DeleteBrokerCallRecords();
        Database.executeBatch(ba);
        // ba.start(null);
        
        Test.stopTest();
        //Start Test
    }
    
    static testMethod void ScheduleBatchClassTest(){
        List<JMS_Broker_Call__c> lstBC = new List<JMS_Broker_Call__c>();
        Account acct = JMS_TestDataFactory.createAccountByName('TestAccount');
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        JMS_Broker_Call__c objBC1 = new JMS_Broker_Call__c();
        objBC1.Account__c = acct.Id;
        objBC1.JMS_Campaign__c = camp.Id;
        objBC1.JMS_Call_Status__c = 'Complete';
        lstBC.add(objBC1);
        
        JMS_Broker_Call__c objBC11 = new JMS_Broker_Call__c();
        objBC11.Account__c = acct.Id;
        objBC11.JMS_Campaign__c = camp.Id;
        objBC11.JMS_Call_Status__c = 'Complete';
        lstBC.add(objBC11);
        
        JMS_Broker_Call__c objBC2 = new JMS_Broker_Call__c();
        objBC2.Account__c = acct.Id;
        objBC2.JMS_Campaign__c = camp.Id;
        lstBC.add(objBC2);
        
        JMS_Broker_Call__c objBC21 = new JMS_Broker_Call__c();
        objBC21.Account__c = acct.Id;
        objBC21.JMS_Campaign__c = camp.Id;
        lstBC.add(objBC21);
        
        insert lstBC;
        
        //Start Test
        Test.startTest();
        
        JMS_DeleteBrokerCallRecords objSchedulebatch = new JMS_DeleteBrokerCallRecords();
        String sch = '0 0 22 ? * 6L';
        String jobID = System.schedule('Schedule Job', sch, objSchedulebatch);

        
        Test.stopTest();
        //Start Test
    }
}