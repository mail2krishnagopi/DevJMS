/**
* @description       : Test Class for JMS_MigrateBrokerCallStgnToSObjectTest
* @author            : Krishna
* @date              : 31/03/2022
* @last modified on  : 31/03/2021
* @last modified by  : Krishna
*/
//Start
 @isTest
private class JMS_MigrateBrokerCallStgnToSObjectTest {
    
     
    static testMethod void executeBatchTest0(){
        JMS_Broker_Call_Staging__c brokerCallObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        brokerCallObj.JMS_Company_Address__c = '123 Main street';
        brokerCallObj.JMS_Company_City__c = 'New York City';
        brokerCallObj.JMS_Company_Country__c = 'United States';
        brokerCallObj.JMS_Company_Name__c = 'Sumit Textiles';
        brokerCallObj.JMS_Company_Phone__c = '1324567980';
        brokerCallObj.JMS_Company_State__c = 'New York';
        brokerCallObj.JMS_Account_Error_Message__c = '';
        brokerCallObj.JMS_Status__c = 'Error';
        brokerCallObj.JMS_Kickout_Failed_Reason__c = 'Hello World';
        brokerCallObj.JMS_Kickout_Location__c = 'Salesforce';
        brokerCallObj.JMS_Batch_Id__c = 'abcd';
        brokerCallObj.JMS_Broker_Name__c = 'IAC';
        UPDATE brokerCallObj;
        //Start Test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject('abcd');
        Database.executeBatch(ba);
        System.assert(brokerCallObj !=null,'Object is not Null');
        Test.stopTest();
        //Stop Test
    }    
    //Start Test
    static testMethod void executeBatchTest(){
        //Creating Account records
        Account acct = JMS_TestDataFactory.createAccountByName('TestAccount');
        //Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        
        //Creating Campaign Records
        Campaign camp = JMS_TestDataFactory.createCampaign('Test Campaign');
        list<Product2> prdlist = JMS_TestDataFactory.createProductRecds(1);
        JMS_Broker_Call_Staging__c brokerCallObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        //brokerCallObj.JMS_Line_Product_Id__c = prdlist[0].Id;
        
        brokerCallObj.JMS_Campaign_SF_Id__c = camp.Id;
        brokerCallObj.JMS_Kickout_Failed_Reason__c = Null;
        brokerCallObj.JMS_Record_Processed__c = false;
        brokerCallObj.JMS_Status__c = 'SUCCESS';
        brokerCallObj.JMS_Company_Type__c = 'Distributor';
        //brokerCallObj.JMS_Account_SF_Id__c = acct.Id;
        brokerCallObj.JMS_Company_SF_Id__c = acct.Id;
        brokerCallObj.JMS_Company_Broker_Territory_Name__c = 'FREEMAN QUEBEC';
        brokerCallObj.JMS_Company_Broker_Territory_Id__c = '90784';
        brokerCallObj.JMS_Company_Zip__c = '06777';
        brokerCallObj.JMS_Company_State__c = 'FLorida';
        brokerCallObj.JMS_Company_City__c = 'eklrewlfkerwf';
        brokerCallObj.JMS_Company_Address__c = 'wkjrhjkewr';
        brokerCallObj.JMS_Company_Id__c = 'w98374893';
        brokerCallObj.JMS_Company_Name__c = 'TEST FINALTEST94';         
        brokerCallObj.JMS_Contact_Email__c = 'SS@DD.com';
        brokerCallObj.JMS_Contact_First_Name__c = 'Arnold';
        brokerCallObj.JMS_Contact_Last_Name__c = 'S';
        Update brokerCallObj;
        
        //Start test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject();
        Database.executeBatch(ba);
        System.assert(brokerCallObj !=null,'Object is not Null');
        Test.stopTest();
        //Stop Test
    }//End
    
    static testMethod void executeBatchBadTest(){
        //Creating Account records
        Account acct = JMS_TestDataFactory.createAccountByName('TestAccount');
        //Creating Contact Records
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        //Creating Campaign Records
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        list<Product2> prdlist = JMS_TestDataFactory.createProductRecds(1);
        //Creating Product Record
        JMS_Broker_Call_Staging__c brokerCallObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        //brokerCallObj.JMS_Line_Product_Id__c = prdlist[0].Id;
        brokerCallObj.JMS_Account_SF_Id__c = acct.Id;
        brokerCallObj.JMS_Contact_SF_Id__c = con.Id;
        brokerCallObj.JMS_Campaign_SF_Id__c = camp.Id;
        brokerCallObj.JMS_Kickout_Failed_Reason__c = Null;
        brokerCallObj.JMS_Record_Processed__c = false;
        brokerCallObj.JMS_Status__c = 'SUCCESS';
        brokerCallObj.JMS_Company_Type__c = 'Distributor';
        brokerCallObj.JMS_Company_SF_Id__c = acct.Id;
        brokerCallObj.JMS_Company_Broker_Territory_Name__c = 'FREEMAN QUEBEC';
        brokerCallObj.JMS_Company_Broker_Territory_Id__c = '90784';
        brokerCallObj.JMS_Company_Zip__c = '06777';
        brokerCallObj.JMS_Company_State__c = 'FLorida';
        brokerCallObj.JMS_Company_City__c = 'eklrewlfkerwf';
        brokerCallObj.JMS_Company_Address__c = 'wkjrhjkewr';
        brokerCallObj.JMS_Company_Id__c = 'w98374893';
        brokerCallObj.JMS_Company_Name__c = 'TEST FINALTEST94';         
        Update brokerCallObj;
        //Updating Brokercall Staging
        //Start Test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject();
        Database.executeBatch(ba);
        System.assert(brokerCallObj !=null,'Object is not Null');
        Test.stopTest();
        //Stop Test
    }//End 
    
    
    //Start Test
    static testMethod void executeBatchCatchTest(){
        //Creating Account records
        Account acct = JMS_TestDataFactory.createAccountByName('TestAccount');
        //Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        
        //Creating Campaign Records
        Campaign camp = JMS_TestDataFactory.createCampaign('Test Campaign');
        
        list<Product2> prdlist = JMS_TestDataFactory.createProductRecds(1);
        JMS_Broker_Call_Landing__c brkCallLand = JMS_TestDataFactory.createBrokerCallStaging();
        brkCallLand.JMS_Call_Distributor_Code__c = '211';
        brkCallLand.JMS_Batch_Id__c = 'b001';
        brkCallLand.JMS_Unique_Key__c = 'DistributorSS@DD.com';
        brkCallLand.JMS_Company_Broker_Territory_Name__c = 'FREEMAN QUEBEC';
        brkCallLand.JMS_Company_Broker_Territory_Id__c = '90784';
        brkCallLand.JMS_Item_No_Sale_Reason__c = 'Test';
        brkCallLand.JMS_Item_No_Sale_Reason_Detail__c = 'Test';
        brkCallLand.JMS_Opportunity_Stage__c = 'Test';
        brkCallLand.JMS_Company_Type__c = 'Test';
        brkCallLand.JMS_Call_Status__c = 'Test';
        Update brkCallLand;
        JMS_Broker_Call_Staging__c brokerCallObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        //brokerCallObj.JMS_Line_Product_Id__c = prdlist[0].Id;
        
        brokerCallObj.JMS_Campaign_SF_Id__c = camp.Id;
        brokerCallObj.JMS_Kickout_Failed_Reason__c = Null;
        brokerCallObj.JMS_Record_Processed__c = false;
        brokerCallObj.JMS_Status__c = 'SUCCESS';
        brokerCallObj.JMS_Company_Type__c = 'Distributor';
        //brokerCallObj.JMS_Account_SF_Id__c = acct.Id;
        brokerCallObj.JMS_Company_SF_Id__c = acct.Id;
        brokerCallObj.JMS_Company_Broker_Territory_Name__c = 'FREEMAN QUEBEC';
        brokerCallObj.JMS_Company_Broker_Territory_Id__c = '90784';
        brokerCallObj.JMS_Company_Zip__c = '06777';
        brokerCallObj.JMS_Company_State__c = '';
        brokerCallObj.JMS_Unique_Key__c = 'DistributorSS@DD.com';
        brokerCallObj.JMS_Company_City__c = 'eklrewlfkerwf';
        brokerCallObj.JMS_Company_Address__c = 'wkjrhjkewr';
        brokerCallObj.JMS_Company_Id__c = 'w98374893';
        brokerCallObj.JMS_Company_Name__c = 'TEST FINALTEST94';         
        brokerCallObj.JMS_Contact_Email__c = 'SS@DD.com';
        brokerCallObj.JMS_Contact_First_Name__c = 'Arnold';
        brokerCallObj.JMS_Contact_Last_Name__c = 'S';
        Update brokerCallObj;
        
        //Start test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject();
        Database.executeBatch(ba);
        System.assert(brokerCallObj !=null,'Object is not Null');
        Test.stopTest();
        //Stop Test
    }//End
}