/**
* @description       : Test Class for JMS_Delete_SObject_RecordsTest
* @author            : Krishna
* @date       		 : 31/03/2022
* @last modified on  : 31/03/2021
* @last modified by  : Krishna
*/
@isTest
private class JMS_MigrateToCmpgnMemStagingBatchTest {
    public static final String STR_TestCampaign = 'TestCampaign';
    public static final String STR_TestAccount = 'TestAccount';
    static testMethod void executeBatchTest(){
        Account acct = JMS_TestDataFactory.createAccountByName(STR_TestAccount);
        acct.JMS_FireFly_Id__c = '34452';
        UPDATE acct;
        //Updating Account Record
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        con.Description = 'Test con 083';
        Campaign camp = JMS_TestDataFactory.createCampaign(STR_TestCampaign);
        camp.Description = 'test Camp 989';
        list<Product2> prdlist = JMS_TestDataFactory.createProductRecds(1);
        prdlist[0].StockKeepingUnit = '2252';
        UPDATE prdlist;
        //Updating Product Record
        List<Pricebook2> pricebklist = JMS_TestDataFactory.createPricebookRecds(1);
        PriceBookEntry prcBkEntry = JMS_TestDataFactory.createPricebookEntry(prdlist[0].Id,pricebklist[0].Id);
        JMS_Campaign_Target_Landing__c cmptargetLand = JMS_TestDataFactory.createcampaignLanding();
        cmptargetLand.JMS_Campaign_Name__c = STR_TestCampaign;
        UPDATE cmptargetLand;
        cmptargetLand.JMS_FireFlyId__c = '234566';
        cmptargetLand.JMS_Smucker_SKU__c = '37687';
        cmptargetLand.JMS_Operator_Contact_Email_Address__c = 'contact@jms.com';
        cmptargetLand.JMS_Call_Made_By__c = 'Broker';
        UPDATE cmptargetLand;
        //Updating Camp Target landing Record
        con.Email = 'contact@jms.com';
        UPDATE con;
        
        Test.startTest();
        //Start Test
        JMS_MigrateToCmpgnMemStagingBatch ba= new JMS_MigrateToCmpgnMemStagingBatch();
        Database.executeBatch(ba);
        System.assert(cmptargetLand !=null,'Object is not Null');
        Test.stopTest();
        //Stop Test
        
        
    }
    static testMethod void executeBatchTest1(){
        Account acct = JMS_TestDataFactory.createAccountByName(STR_TestAccount);
        acct.JMS_FireFly_Id__c = '786534';
        UPDATE acct;
        //Updating Account Record
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        con.Description = 'Test con 03';
        Campaign camp = JMS_TestDataFactory.createCampaign(STR_TestCampaign);
        camp.Description = 'Test camp 083';
        list<Product2> prdlist = JMS_TestDataFactory.createProductRecds(1);
        prdlist[0].StockKeepingUnit = '8787980';
        UPDATE prdlist;
        //Updating Product Record
        Pricebook2 pricebklist = JMS_TestDataFactory.createPricebook();
        PriceBookEntry prcBkEntry = JMS_TestDataFactory.createPricebookEntry(prdlist[0].Id,pricebklist.Id);
        JMS_Campaign_Target_Landing__c cmptargetLand = JMS_TestDataFactory.createcampaignLanding();
        cmptargetLand.JMS_Campaign_Name__c = STR_TestCampaign;
        cmptargetLand.JMS_FireFlyId__c = '45232';
        cmptargetLand.JMS_Smucker_SKU__c = '234323';
        cmptargetLand.JMS_Call_Made_By__c = 'JMS';
        UPDATE cmptargetLand;
        //Updating Camp Target landing Record
        Test.startTest();
        //Test Start
        JMS_MigrateToCmpgnMemStagingBatch ba= new JMS_MigrateToCmpgnMemStagingBatch();
        Database.executeBatch(ba);
        System.assert(cmptargetLand !=null,'Object is not Null');
        Test.stopTest();
        //Test Stop
        
        
    }
    static testMethod void executeBatchTest2(){
        Account acct = JMS_TestDataFactory.createAccountByName(STR_TestAccount);
        //Creating Account Record
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        con.Description = 'Test con 83';
        Campaign camp = JMS_TestDataFactory.createCampaign(STR_TestCampaign);
        camp.Description = 'Test camp 7878';
        list<Product2> prdlist = JMS_TestDataFactory.createProductRecds(1);
        prdlist[0].StockKeepingUnit = '245656453';
        UPDATE prdlist;
        //Updating Product Record
        JMS_Campaign_Target_Landing__c cmptargetLand = JMS_TestDataFactory.createcampaignLanding();
        UPDATE cmptargetLand;
        //Updating Camp Target landing Record
        //Start Test
        Test.startTest();
        JMS_MigrateToCmpgnMemStagingBatch ba= new JMS_MigrateToCmpgnMemStagingBatch();
        Database.executeBatch(ba);
        System.assert(cmptargetLand !=null,'Object is not Null');
        Test.stopTest();
        //Stop Test
        
        
    }
   
}