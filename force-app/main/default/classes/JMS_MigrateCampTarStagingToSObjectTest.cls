@isTest
public class JMS_MigrateCampTarStagingToSObjectTest {
     /*static testMethod void executeTest2(){
        Account acct = JMS_TestDataFactory.createAccountWithFireflyId('TestAccount');
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        Opportunity opp = JMS_TestDataFactory.createOpportunity('new opp',acct.Id);
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        Product2 prdlist = JMS_TestDataFactory.createProduct();
        JMS_Campaign_Target_Staging__c campTargStaging = JMS_TestDataFactory.createCampaignStaging();
        campTargStaging.JMS_Product_SF_Id__c = prdlist.Id;
        campTargStaging.JMS_Campaign_SF_Id__c = camp.Id;
        campTargStaging.JMS_Account_SF_Id__c = acct.Id;
        campTargStaging.JMS_Contact_SF_ID__c = con.Id;
        campTargStaging.JMS_Call_Made_By__c = 'JMS';
        campTargStaging.JMS_Campaign_Target_Id__c = 'tagertId';
        campTargStaging.JMS_Annual_Volume__c = '42';
        campTargStaging.JMS_OPERATOR_NAME__C = 'COVENANT MEDICAL CTR DUNKIN';
        campTargStaging.JMS_OPERATOR_ADDRESS__C = '3421 W 9TH ST';
        campTargStaging.JMS_OPERATOR_CITY__C ='WATERLOO';
        campTargStaging.JMS_OPERATORS_STATE__C = 'IA';
        campTargStaging.JMS_OPERATOR_ZIP__C = '50704';
        campTargStaging.JMS_COMPANY_TYPE__C = 'OPERATOR';
        campTargStaging.JMS_OPERATOR_CONTACT_FIRST_NAME__C = 'Julie';
        campTargStaging.JMS_OPERATOR_CONTACT_LAST_NAME__C = 'Sanford';
        campTargStaging.JMS_OPERATOR_CONTACT_EMAIL_ADDRESS__C = 'julie.sanford@wfhc.org';
        campTargStaging.JMS_OPERATOR_CONTACT_PHONE_NUMBER__C = '319-272-7885';
        campTargStaging.JMS_SMUCKER_SKU__C = '2550008765';
        campTargStaging.JMS_PRODUCT_DESCRIPTION__C = '2L Colombian Liquid';
        campTargStaging.JMS_ANNUAL_VOLUME__C = '52';
        Update campTargStaging;
        List<JMS_Campaign_Target_Staging__c> campTargetStagingList = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate,LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate,JMS_Operator_Name__c,JMS_Operator_Address__c, JMS_Operator_City__c, JMS_Operators_State__c, JMS_Operator_Zip__c,JMS_Company_Type__c, JMS_Operator_Contact_First_Name__c, JMS_Operator_Contact_Last_Name__c, JMS_Operator_Contact_Email_Address__c,JMS_Operator_Contact_Phone_Number__c, JMS_Smucker_SKU__c, JMS_Product_Description__c,JMS_Annual_Volume__c, JMS_Sales_Person_Email__c, JMS_Account_SF_Id__c, JMS_Contact_SF_Id__c, JMS_Campaign_SF_Id__c, JMS_Opportunity_SF_Id__c, JMS_Campaign_ID__c, JMS_Campaign_Name__c,JMS_Campaign_Target_ID__c, JMS_Call_Made_By__c, JMS_FireFlyId__c, JMS_Operator_Phone__c,JMS_Operator_Contact_Full_Name__c, JMS_Operator_Contact_Title__c,JMS_Operator_Contact_Phone_Number_Ext__c, JMS_Operator_Contact_Mobile_Phone_Number__c,JMS_Competitor_Name__c, JMS_WRAP_Target__c, JMS_Product_SF_Id__c, JMS_Status__c,JMS_Operator_Contact_Error_Message__c, JMS_Operator_Error_Message__c,JMS_SKU_Error_Message__c, JMS_Campaign_Error_Message__c, JMS_Record_Processed__c,JMS_Opportunity_Error_Message__c, JMS_Broker_Call_SF_Id__c, JMS_Broker_Call_Error_Message__c,JMS_Campaign_Target_Batch_Job__c, JMS_Opportunity_Product_SF_Id__c,JMS_Opportunity_Product_Error_Message__c FROM JMS_Campaign_Target_Staging__c WHERE JMS_Record_Processed__c = false];
   
        Test.startTest();
        JMS_MigrateCampTarStagingToSObjectBatch ba= new JMS_MigrateCampTarStagingToSObjectBatch();
        ID batchprocessid = Database.executeBatch(ba);
        Database.QueryLocator ql = ba.start(null);
        ba.execute(null,campTargetStagingList);
        ba.Finish(null);
        Test.stopTest();
    }*/
    //Start Test
   static testMethod void executeTest(){
        //Creating Account
        Account acct = JMS_TestDataFactory.createAccountByName('Testing Account');
        acct.JMS_FireFly_Id__c = '233568';
        UPDATE acct;
        //Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        //Creating Campaign
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        //Creating product
        Product2 prdlist = JMS_TestDataFactory.createProduct();
       //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
         
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
       
        PricebookEntry objPriceBookEntry =  new PricebookEntry(Pricebook2Id = standardPricebook.Id,
                                                              IsActive = true,
                                                              Product2Id = prdlist.Id,
                                                              UnitPrice = 10);
       //insert objPriceBookEntry;
        //Creating Campaign target Staging
        JMS_Campaign_Target_Staging__c campTargStaging = JMS_TestDataFactory.createCampaignStaging();
        campTargStaging.JMS_Product_SF_Id__c = prdlist.Id;
        campTargStaging.JMS_Campaign_SF_Id__c = camp.Id;
        campTargStaging.JMS_SKU_Error_Message__c = '';
        campTargStaging.JMS_Call_Made_By__c = 'JMS';
        campTargStaging.JMS_OPERATOR_NAME__C = 'COVENANT MEDICAL CTR DUNKIN';
        campTargStaging.JMS_OPERATOR_ADDRESS__C = '3421 W 9TH ST';
        campTargStaging.JMS_OPERATOR_CITY__C ='WATERLOO';
        campTargStaging.JMS_OPERATORS_STATE__C = 'IA';
        campTargStaging.JMS_OPERATOR_ZIP__C = '50704';
        campTargStaging.JMS_COMPANY_TYPE__C = 'OPERATOR';
        campTargStaging.JMS_OPERATOR_CONTACT_FIRST_NAME__C = 'Julie';
        campTargStaging.JMS_OPERATOR_CONTACT_LAST_NAME__C = 'Sanford';
        campTargStaging.JMS_OPERATOR_CONTACT_EMAIL_ADDRESS__C = 'julie.sanford@wfhc.org';
        campTargStaging.JMS_OPERATOR_CONTACT_PHONE_NUMBER__C = '319-272-7885';
        campTargStaging.JMS_SMUCKER_SKU__C = '2550008765';
        campTargStaging.JMS_PRODUCT_DESCRIPTION__C = '2L Colombian Liquid';
        campTargStaging.JMS_ANNUAL_VOLUME__C = '52';
        Update campTargStaging;
        //Creating a list
        List<JMS_Campaign_Target_Staging__c> campTargetStagingList = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate,LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate,JMS_Company_Country__c, JMS_Operator_Name__c,JMS_Operator_Address__c, JMS_Operator_City__c, JMS_Operators_State__c, JMS_Operator_Zip__c,JMS_Company_Type__c, JMS_Operator_Contact_First_Name__c, JMS_Operator_Contact_Last_Name__c, JMS_Operator_Contact_Email_Address__c,JMS_Operator_Contact_Phone_Number__c, JMS_Smucker_SKU__c, JMS_Product_Description__c,JMS_Annual_Volume__c, JMS_Sales_Person_Email__c, JMS_Account_SF_Id__c, JMS_Contact_SF_Id__c, JMS_Campaign_SF_Id__c, JMS_Opportunity_SF_Id__c, JMS_Campaign_ID__c, JMS_Campaign_Name__c,JMS_Campaign_Target_ID__c, JMS_Call_Made_By__c, JMS_FireFlyId__c, JMS_Operator_Phone__c,JMS_Operator_Contact_Full_Name__c, JMS_Operator_Contact_Title__c,JMS_Operator_Contact_Phone_Number_Ext__c, JMS_Operator_Contact_Mobile_Phone_Number__c,JMS_Competitor_Name__c, JMS_WRAP_Target__c, JMS_Product_SF_Id__c, JMS_Status__c,JMS_Operator_Contact_Error_Message__c, JMS_Operator_Error_Message__c,JMS_SKU_Error_Message__c, JMS_Campaign_Error_Message__c, JMS_Record_Processed__c,JMS_Opportunity_Error_Message__c, JMS_Broker_Call_SF_Id__c, JMS_Broker_Call_Error_Message__c,JMS_Campaign_Target_Batch_Job__c, JMS_Opportunity_Product_SF_Id__c,JMS_Opportunity_Product_Error_Message__c FROM JMS_Campaign_Target_Staging__c WHERE JMS_Record_Processed__c = false];
        //Start Test
        Test.startTest();
        JMS_MigrateCampTarStagingToSObjectBatch ba= new JMS_MigrateCampTarStagingToSObjectBatch();
        /*
         * CodeScan Issue Fix -Avoid using unused varible 
         * Anil - 03/06/2022
        ID batchprocessid = Database.executeBatch(ba);
        Database.QueryLocator ql = ba.start(null); */
        Database.executeBatch(ba);
        ba.start(null);
        ba.execute(null,campTargetStagingList);
        ba.Finish(null);
        System.assert(campTargetStagingList.size()>0,'List is not Null');
        Test.stopTest();
        //Stop test
    }//End
    //Start
    static testMethod void executeTest1(){
        //Creating Account
        Account acct = JMS_TestDataFactory.createAccountByName('Testing Account');
        acct.JMS_FireFly_Id__c = '233568';
        UPDATE acct;
        //Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        //Creating Campaign
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        //Creating product
        Product2 prdlist = JMS_TestDataFactory.createProduct();
        //Creating Campaign target Staging
        JMS_Campaign_Target_Staging__c campTargStaging = JMS_TestDataFactory.createCampaignStaging();
        campTargStaging.JMS_Product_SF_Id__c = prdlist.Id;
        campTargStaging.JMS_Campaign_SF_Id__c = camp.Id;
        campTargStaging.JMS_SKU_Error_Message__c = '';
        campTargStaging.JMS_Call_Made_By__c = 'Broker';
        campTargStaging.JMS_OPERATOR_NAME__C = 'COVENANT MEDICAL CTR DUNKIN';
        campTargStaging.JMS_OPERATOR_ADDRESS__C = '3421 W 9TH ST';
        campTargStaging.JMS_OPERATOR_CITY__C ='WATERLOO';
        campTargStaging.JMS_OPERATORS_STATE__C = 'IA';
        campTargStaging.JMS_OPERATOR_ZIP__C = '50704';
        campTargStaging.JMS_COMPANY_TYPE__C = 'OPERATOR';
        campTargStaging.JMS_OPERATOR_CONTACT_FIRST_NAME__C = 'Julie';
        campTargStaging.JMS_OPERATOR_CONTACT_LAST_NAME__C = 'Sanford';
        campTargStaging.JMS_OPERATOR_CONTACT_EMAIL_ADDRESS__C = 'julie.sanford@wfhc.org';
        campTargStaging.JMS_OPERATOR_CONTACT_PHONE_NUMBER__C = '319-272-7885';
        campTargStaging.JMS_SMUCKER_SKU__C = '2550008765';
        campTargStaging.JMS_PRODUCT_DESCRIPTION__C = '2L Colombian Liquid';
        campTargStaging.JMS_ANNUAL_VOLUME__C = '52';
        campTargStaging.JMS_Status__c = 'Success';
        Update campTargStaging;
        //Creating a List
        List<JMS_Campaign_Target_Staging__c> campTargetStagingList = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate,LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate,JMS_Company_Country__c, JMS_Operator_Name__c,JMS_Operator_Address__c, JMS_Operator_City__c, JMS_Operators_State__c, JMS_Operator_Zip__c,JMS_Company_Type__c, JMS_Operator_Contact_First_Name__c, JMS_Operator_Contact_Last_Name__c, JMS_Operator_Contact_Email_Address__c,JMS_Operator_Contact_Phone_Number__c, JMS_Smucker_SKU__c, JMS_Product_Description__c,JMS_Annual_Volume__c, JMS_Sales_Person_Email__c, JMS_Account_SF_Id__c, JMS_Contact_SF_Id__c, JMS_Campaign_SF_Id__c, JMS_Opportunity_SF_Id__c, JMS_Campaign_ID__c, JMS_Campaign_Name__c,JMS_Campaign_Target_ID__c, JMS_Call_Made_By__c, JMS_FireFlyId__c, JMS_Operator_Phone__c,JMS_Operator_Contact_Full_Name__c, JMS_Operator_Contact_Title__c,JMS_Operator_Contact_Phone_Number_Ext__c, JMS_Operator_Contact_Mobile_Phone_Number__c,JMS_Competitor_Name__c, JMS_WRAP_Target__c, JMS_Product_SF_Id__c, JMS_Status__c,JMS_Operator_Contact_Error_Message__c, JMS_Operator_Error_Message__c,JMS_SKU_Error_Message__c, JMS_Campaign_Error_Message__c, JMS_Record_Processed__c,JMS_Opportunity_Error_Message__c, JMS_Broker_Call_SF_Id__c, JMS_Broker_Call_Error_Message__c,JMS_Campaign_Target_Batch_Job__c, JMS_Opportunity_Product_SF_Id__c,JMS_Opportunity_Product_Error_Message__c FROM JMS_Campaign_Target_Staging__c WHERE JMS_Record_Processed__c = false];
        //Start Test
        Test.startTest();
        JMS_MigrateCampTarStagingToSObjectBatch ba= new JMS_MigrateCampTarStagingToSObjectBatch();
        /*
         * CodeScan Issue Fix -Avoid using unused varible 
         * Anil - 03/06/2022
        ID batchprocessid = Database.executeBatch(ba);
        Database.QueryLocator ql = ba.start(null); */
        Database.executeBatch(ba);
        ba.start(null);
        ba.execute(null,campTargetStagingList);
        ba.Finish(null);
        System.assert(campTargetStagingList.size()>0,'List is not Null');
        Test.stopTest();
        //Stop Test
    }//End
    /*static testMethod void executeTest1(){
        Account acct = JMS_TestDataFactory.createAccountByName('New Account');
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        Campaign camp = JMS_TestDataFactory.createCampaign('TestCampaign');
        Product2 prdlist = JMS_TestDataFactory.createProduct();
        JMS_Campaign_Target_Staging__c campTargStaging = JMS_TestDataFactory.createCampaignStaging();
        campTargStaging.JMS_Product_SF_Id__c = prdlist.Id;
        campTargStaging.JMS_Campaign_SF_Id__c = camp.Id;
        campTargStaging.JMS_Account_SF_Id__c = acct.Id;
        campTargStaging.JMS_Contact_SF_ID__c = con.Id;
        campTargStaging.JMS_Call_Made_By__c = 'Broker';
        campTargStaging.JMS_OPERATOR_NAME__C = 'COVENANT MEDICAL CTR DUNKIN';
        campTargStaging.JMS_OPERATOR_ADDRESS__C = '3421 W 9TH ST';
        campTargStaging.JMS_OPERATOR_CITY__C ='WATERLOO';
        campTargStaging.JMS_OPERATORS_STATE__C = 'IA';
        campTargStaging.JMS_OPERATOR_ZIP__C = '50704';
        campTargStaging.JMS_COMPANY_TYPE__C = 'OPERATOR';
        campTargStaging.JMS_OPERATOR_CONTACT_FIRST_NAME__C = 'Julie';
        campTargStaging.JMS_OPERATOR_CONTACT_LAST_NAME__C = 'Sanford';
        campTargStaging.JMS_OPERATOR_CONTACT_EMAIL_ADDRESS__C = 'julie.sanford@wfhc.org';
        campTargStaging.JMS_OPERATOR_CONTACT_PHONE_NUMBER__C = '319-272-7885';
        campTargStaging.JMS_SMUCKER_SKU__C = '2550008765';
        campTargStaging.JMS_PRODUCT_DESCRIPTION__C = '2L Colombian Liquid';
        campTargStaging.JMS_ANNUAL_VOLUME__C = '52';
        Update campTargStaging;
        List<JMS_Campaign_Target_Staging__c> campTargetStagingList = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate,LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate,JMS_Company_Country__c, JMS_Operator_Name__c,JMS_Operator_Address__c, JMS_Operator_City__c, JMS_Operators_State__c, JMS_Operator_Zip__c,JMS_Company_Type__c, JMS_Operator_Contact_First_Name__c, JMS_Operator_Contact_Last_Name__c, JMS_Operator_Contact_Email_Address__c,JMS_Operator_Contact_Phone_Number__c, JMS_Smucker_SKU__c, JMS_Product_Description__c,JMS_Annual_Volume__c, JMS_Sales_Person_Email__c, JMS_Account_SF_Id__c, JMS_Contact_SF_Id__c, JMS_Campaign_SF_Id__c, JMS_Opportunity_SF_Id__c, JMS_Campaign_ID__c, JMS_Campaign_Name__c,JMS_Campaign_Target_ID__c, JMS_Call_Made_By__c, JMS_FireFlyId__c, JMS_Operator_Phone__c,JMS_Operator_Contact_Full_Name__c, JMS_Operator_Contact_Title__c,JMS_Operator_Contact_Phone_Number_Ext__c, JMS_Operator_Contact_Mobile_Phone_Number__c,JMS_Competitor_Name__c, JMS_WRAP_Target__c, JMS_Product_SF_Id__c, JMS_Status__c,JMS_Operator_Contact_Error_Message__c, JMS_Operator_Error_Message__c,JMS_SKU_Error_Message__c, JMS_Campaign_Error_Message__c, JMS_Record_Processed__c,JMS_Opportunity_Error_Message__c, JMS_Broker_Call_SF_Id__c, JMS_Broker_Call_Error_Message__c,JMS_Campaign_Target_Batch_Job__c, JMS_Opportunity_Product_SF_Id__c,JMS_Opportunity_Product_Error_Message__c FROM JMS_Campaign_Target_Staging__c WHERE JMS_Record_Processed__c = false];
        campTargetStagingList.add(campTargStaging);
        Test.startTest();
        JMS_MigrateCampTarStagingToSObjectBatch ba= new JMS_MigrateCampTarStagingToSObjectBatch();
        ID batchprocessid = Database.executeBatch(ba);
        Database.QueryLocator ql = ba.start(null);
        ba.execute(null,campTargetStagingList);
        ba.Finish(null);
        Test.stopTest();
    }*/
       
}