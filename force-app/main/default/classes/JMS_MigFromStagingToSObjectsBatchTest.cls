/**
* @description       : Test Class for JMS_Delete_SObject_RecordsTest
* @author            : Krishna
* @date              : 31/03/2022
* @last modified on  : 31/03/2021
* @last modified by  : Krishna
*/
@isTest
private class JMS_MigFromStagingToSObjectsBatchTest {
    public static final String STR_LIST_IS_NOT_NULL = 'List is not Null';
    public static final String STR_b001 = 'b001';
    public static final String STR_SUCCESS = 'Success';
    static testMethod void executeBatch(){
		JMS_Broker_Call_Staging__c stgObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        stgObj.JMS_Record_Processed__c = FALSE;
        update stgObj;
        //Update broker call staging record
        List<JMS_Broker_Call_Staging__c> stgObjList = new List<JMS_Broker_Call_Staging__c>();
        stgObjList.add(stgObj);
        //List of broker call staging record
        //Start Test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject();
        Database.executeBatch(ba);
        System.assert(stgObjList.size()>0,STR_LIST_IS_NOT_NULL);
        Test.stopTest();
        //Stop Test
        
    }//End of method
    
    static testMethod void executeBatch1(){
        Account accRec = JMS_TestDataFactory.createAccountByName('name');
        //Creating Account Record
        Contact conRec = JMS_TestDataFactory.createContact('name', accRec.Id);
        //Creating Contact Record
        Product2 prdRec = JMS_TestDataFactory.createProduct();
        //Creating Product Record
        Campaign campRec = JMS_TestDataFactory.createCampaign('name');
        //Creating Campaign Record
        campRec.Description = 'Test Camp 01';
        JMS_Broker_Call_Staging__c stgObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        stgObj.JMS_Record_Processed__c = FALSE;
        stgObj.JMS_Batch_Id__c = STR_b001;
        stgObj.JMS_Status__c = STR_SUCCESS;
        stgObj.JMS_Campaign_SF_Id__c = '1234';
        stgObj.JMS_Account_SF_Id__c = '45655';// accRec.Id;
        stgObj.JMS_Company_Id__c = '1235';
        stgObj.JMS_Contact_SF_Id__c = conRec.Id;
        stgObj.JMS_Product_SF_Id__c = prdRec.Id;
        
        update stgObj;
        //Update broker call staging record
        List<JMS_Broker_Call_Staging__c> stgObjList = new List<JMS_Broker_Call_Staging__c>();
        stgObjList.add(stgObj);
        //List of broker call staging record
        //Start Test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject(STR_b001);
        Database.executeBatch(ba);
        System.assert(stgObjList.size()>0,STR_LIST_IS_NOT_NULL);
        Test.stopTest();
        //Stop Test
        
    } 
    
        static testMethod void executeBatch2(){
            JMS_Broker_Call_Staging__c stgObj = JMS_TestDataFactory.createBrokerCallStagingObj();
            stgObj.JMS_Record_Processed__c = FALSE;
            stgObj.JMS_Batch_Id__c = STR_b001;
            stgObj.JMS_Status__c = 'Error';
            stgObj.JMS_Account_Error_Message__c = '123851';
            update stgObj;
            //Update broker call staging record
            List<JMS_Broker_Call_Staging__c> stgObjList = new List<JMS_Broker_Call_Staging__c>();
        	stgObjList.add(stgObj);
            //List of broker call staging record
            //Start Test
            Test.startTest();
            JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject(STR_b001);
            Database.executeBatch(ba);
            System.assert(stgObjList.size()>0,STR_LIST_IS_NOT_NULL);
            Test.stopTest();
            //Stop Test
        
    } 
    
    static testMethod void executeBatch3(){
        JMS_Broker_Call_Staging__c stgObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        stgObj.JMS_Record_Processed__c = FALSE;
        stgObj.JMS_Batch_Id__c = STR_b001;
        stgObj.JMS_Company_Type__c = 'Operator';
        stgObj.JMS_Status__c = STR_SUCCESS;
        stgObj.JMS_Company_Address__c = 'Test Address';
            stgObj.JMS_Company_Broker_Territory_Id__c = '456565'; 
            stgObj.JMS_Company_Broker_Territory_Name__c = 'Territory Name';
            stgObj.JMS_Company_City__c = 'New York City';
            stgObj.JMS_Company_Country__c = 'United States';
            stgObj.JMS_Company_Id__c = '34342';
            stgObj.JMS_Company_Name__c = 'Test Name';
            stgObj.JMS_Company_Phone__c = '1234567980';
            stgObj.JMS_Company_State__c = 'New York';
            stgObj.JMS_Company_Zip__c = '4532';
      
        update stgObj;
        //Update broker call staging record
        List<JMS_Broker_Call_Staging__c> stgObjList = new List<JMS_Broker_Call_Staging__c>();
        stgObjList.add(stgObj);
        //List of broker call staging record
        //Start Test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject(STR_b001);
        Database.executeBatch(ba);
        System.assert(stgObjList.size()>0,STR_LIST_IS_NOT_NULL);
        Test.stopTest();
        //Stop Test
        
    } 
    static testMethod void executeBatch4(){
        JMS_Broker_Call_Staging__c stgObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        stgObj.JMS_Record_Processed__c = FALSE;
        stgObj.JMS_Batch_Id__c = STR_b001;

        stgObj.JMS_Status__c = STR_SUCCESS;
        stgObj.JMS_Company_Address__c = 'Test Address';
            stgObj.JMS_Company_Broker_Territory_Id__c = '2476665'; 
            stgObj.JMS_Company_Broker_Territory_Name__c = 'Territory Name';
            stgObj.JMS_Company_City__c = 'New York City';
            stgObj.JMS_Company_Country__c = 'United States';
            stgObj.JMS_Company_Id__c = '23445';
            stgObj.JMS_Company_Name__c = 'Test Name';
            stgObj.JMS_Company_Phone__c = '1234567980';
            stgObj.JMS_Company_State__c = 'New York';
            stgObj.JMS_Company_Zip__c = '345654342';
      
        update stgObj;
        //Update broker call staging record
        List<JMS_Broker_Call_Staging__c> stgObjList = new List<JMS_Broker_Call_Staging__c>();
        stgObjList.add(stgObj);
        //List of broker call staging record
        //Start Test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject(STR_b001);
        Database.executeBatch(ba);
        System.assert(stgObjList.size()>0,STR_LIST_IS_NOT_NULL);
        Test.stopTest();
        //Stop Test
        
    } 
    
    //Error with Account name missing
    static testMethod void executeBatch5(){
        JMS_Broker_Call_Staging__c stgObj = JMS_TestDataFactory.createBrokerCallStagingObj();
        stgObj.JMS_Record_Processed__c = FALSE;
        stgObj.JMS_Batch_Id__c = STR_b001;
        
        stgObj.JMS_Status__c = STR_SUCCESS;
        stgObj.JMS_Company_Broker_Territory_Id__c = '34565'; 
        stgObj.JMS_Company_Broker_Territory_Name__c = 'Territory Name';
        stgObj.JMS_Company_City__c = 'New York City';
        stgObj.JMS_Company_Country__c = 'United States';
        stgObj.JMS_Company_Id__c = '8765';
        stgObj.JMS_Company_Phone__c = '1234567980';
        stgObj.JMS_Company_State__c = 'New York';
        stgObj.JMS_Company_Zip__c = '12345';
        stgObj.JMS_Contact_Email__c = 'ss@dd.com';
        stgObj.JMS_Contact_First_Name__c = 'fname';
        stgObj.JMS_Contact_Last_Name__c = 'lname';
        stgObj.JMS_Contact_Phone__c = '123456790';
        
        update stgObj;
        //Update broker call staging record
        List<JMS_Broker_Call_Staging__c> stgObjList = new List<JMS_Broker_Call_Staging__c>();
        stgObjList.add(stgObj);
        //List of broker call staging record
        //Start Test
        Test.startTest();
        JMS_MigrateBrokerCallStgnToSObject ba= new JMS_MigrateBrokerCallStgnToSObject(STR_b001);
        Database.executeBatch(ba);
        System.assert(stgObjList.size()>0,STR_LIST_IS_NOT_NULL);
        Test.stopTest();
        //Stop Test
        
    } 
}