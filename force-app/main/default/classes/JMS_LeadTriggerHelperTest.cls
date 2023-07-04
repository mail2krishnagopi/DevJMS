/**
* @description       : Test Class for JMS_LeadTriggerHelper
* @author            : Krishna
* @date              : 30/03/2022
**/
//Start
@Istest
private class JMS_LeadTriggerHelperTest {
    //Constant Names
    private static final String leadName = 'Test Lead';
    //Start of test
    @IsTest
    private static void populateLeadStatusTest(){
        //Creating lead record
        Lead leadRecord = JMS_TestDataFactory.createLeadByName(leadName);
        UPDATE leadRecord;
        DELETE leadRecord;
        UNDELETE leadRecord;
        //Adding a list
        List<Lead> leadList = New List<Lead>();
        leadList.add(leadRecord);
        //Start Test
        Test.startTest();
        JMS_LeadTriggerHelper helper = new JMS_LeadTriggerHelper();
        JMS_LeadTriggerHandler handler = new JMS_LeadTriggerHandler();
        String trigName = handler.getName();
        JMS_LeadTriggerHelper.populateLeadStatus(leadList);
        System.assertEquals('Lead', trigName,'trigName is not Null');
        System.assertEquals(1, leadList.size() ,'Lead list not null');
        Test.stopTest();
        //Stop Test
        
    }//End
    //Start
     @IsTest
    private static void populateIACQueueTest(){
        //Creating lead record
        Lead leadRecord = JMS_TestDataFactory.createLeadByName(leadName);
        leadRecord.Status = 'Marketing Qualified';
        UPDATE leadRecord;
        DELETE leadRecord;
        UNDELETE leadRecord;
        //Adding a list
        List<Lead> leadList = New List<Lead>();
        Lead leadRecord1 = JMS_TestDataFactory.createLeadByName(leadName);
        leadRecord1.Status = 'Unqualified';
        UPDATE leadRecord1;
        //Adding a Map
        Map<Id,Lead> MapIdLead = New Map<Id,Lead>();
        MapIdLead.put(leadRecord.Id,leadRecord1);
        leadList.add(leadRecord);
        //Start Test
        Test.startTest();
        //JMS_LeadTriggerHelper helper = new JMS_LeadTriggerHelper();
        JMS_LeadTriggerHandler handler = new JMS_LeadTriggerHandler();
        String trigName = handler.getName();
        JMS_LeadTriggerHelper.populateIACQueue(leadList,MapIdLead);
        System.assertEquals('Lead', trigName,'trigName is not Null');
        System.assertEquals(1, leadList.size() ,'Lead list not null');
        Test.stopTest();
        //Stop Tets
        
    }//End
    //Start
     @IsTest
    private static void populateLeadOwnerTest(){
        //Creating lead record
        Lead leadRecord = JMS_TestDataFactory.createLeadByName(leadName);
        List<Lead> leadList = New List<Lead>();
        //Creating lead record
        Lead leadRecord1 = JMS_TestDataFactory.createLeadByName(leadName);
        leadRecord1.Status = 'Unqualified';
        UPDATE leadRecord1;
        //Creating a Map
        Map<Id,Lead> newMapIdLead = New Map<Id,Lead>();
        newMapIdLead.put(leadRecord.Id,leadRecord);
        Map<Id,Lead> oldMapIdLead = New Map<Id,Lead>();
        oldMapIdLead.put(leadRecord.Id,leadRecord1);
        leadList.add(leadRecord);
        //Creating Zip code record
        JMS_ZipCodes__c zipRecord = JMS_TestDataFactory.createZipcodes('Test zipcode');
        zipRecord.JMS_Zip_Code__c ='12345';
        UPDATE zipRecord;
        //Start Test
        Test.startTest();
        //JMS_LeadTriggerHelper helper = new JMS_LeadTriggerHelper();
        JMS_LeadTriggerHandler handler = new JMS_LeadTriggerHandler();
        String trigName = handler.getName();
        JMS_LeadTriggerHelper.populateLeadOwner(leadList,newMapIdLead,oldMapIdLead);
        System.assertEquals('Lead', trigName,'trigName is not Null');
        System.assertEquals(1, leadList.size() ,'Lead list not null');
        Test.stopTest();
        //Stop Test
        
    }
}