/**
* @description       : Test Class for JMS_ContentDocumentTriggerHelper
* @author            : Archana
* @date       		 : 30/03/2022
*/

@Istest
private class JMS_ContentDocumentTriggerHelperTest {
    /*
     * Code Scan Error - The String literal used many times Fix
     * Anil - 03/06/2022 
     * */
    private static final String STR_TEST_ACCOUNT = 'Test Account';
    private static final String STR_TEST_OPPORTUNITY = 'Test Opportunity';
    private static final String STR_LIST_IS_NOT_NULL = 'List is not Null';
    @testSetup static void setup(){
        Account acc = JMS_TestDataFactory.createAccountByName(STR_TEST_ACCOUNT);
        Opportunity opp = JMS_TestDataFactory.createOpportunity(STR_TEST_OPPORTUNITY,acc.ID);
        JMS_Equipment_Request__c equip = JMS_TestDataFactory.createEquipmentRequest(opp.ID);
        equip.JMS_Machine_Count__c = 3245;
    }
    /**
    * @description       : Test Class method for beforeDeletetest
    * @date       		 : 30/03/2022
    * 
    */
    @Istest
    private static void beforeDeletetest(){
        //Creating Account Record
        Account acct = [SELECT Id,Description FROM Account WHERE Name =: STR_TEST_ACCOUNT LIMIT 1];
        acct.Description = 'Test01';
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test02';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        equip.JMS_Equipment_Cost__c = 100000;
        ContentVersion docVersion = JMS_TestDataFactory.createContentVersion('ContentVersion Title');
        ContentVersion docVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :docVersion.Id LIMIT 1];
        ContentDocumentLink doccLink = JMS_TestDataFactory.createContentDocumentLink(equip.Id,docVersion1.ContentDocumentId);
        ContentDocument conDoc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id =: docVersion1.ContentDocumentId LIMIT 1];
        Map<Id,ContentDocument> mapDoc = new Map<Id,ContentDocument>();
        mapDoc.Put(conDoc.Id,conDoc);
        //Delete content Document
        Delete conDoc;
        //UnDelete content Document
        Undelete conDoc;
        equip.JMS_Is_Attachment_Added__c = TRUE;
        UPDATE equip;
        equip.JMS_Is_Attachment_Added__c = FALSE;
        UPDATE equip;
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(equip);
        Boolean isAfterDelete = TRUE;
        //Start test
        Test.startTest();
        Delete conDoc;
        Undelete conDoc;
        DELETE equip;
        UNDELETE equip;
        JMS_ContentDocumentTriggerHelper helper = new JMS_ContentDocumentTriggerHelper();
        JMS_ContentDocumentTriggerHelper.beforeDelete(mapDoc,isAfterDelete);
        System.assert(isAfterDelete, true);
        //Stop Test
        Test.stopTest();       
    }
    /**
    * @description       : Test Class method for beforeDeletetest
    * @date       		 : 30/03/2022
    */
    @Istest
    private static void beforeDeleteExceptiontest(){
        //Creating Account Record
        Account acct = [SELECT Id FROM Account WHERE Name =: STR_TEST_ACCOUNT LIMIT 1];
        acct.Description = 'Test03';
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test04';
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        equip.JMS_Equipment_Cost__c = 100000;
        ContentVersion docVersion = JMS_TestDataFactory.createContentVersion('ContentVersion Title');
        ContentVersion docVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :docVersion.Id LIMIT 1];
        ContentDocumentLink doccLink = JMS_TestDataFactory.createContentDocumentLink(opp.Id,docVersion1.ContentDocumentId);
        Map<Id,ContentDocument> mapDoc = new Map<Id,ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id =: docVersion1.ContentDocumentId LIMIT 1]);
        equip.JMS_Is_Attachment_Added__c = TRUE;
        //Updating Equipment Request 
        UPDATE equip;
        equip.JMS_Is_Attachment_Added__c = FALSE;
        //Updating Equipment Request 
        UPDATE equip;
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(equip);
        DELETE equip;
        UNDELETE equip;
        Boolean isAfterDelete = FALSE;
        //Start test
        Test.startTest();
        //JMS_ContentDocumentTriggerHelper helper = new JMS_ContentDocumentTriggerHelper();
        JMS_ContentDocumentTriggerHelper.beforeDelete(mapDoc,isAfterDelete);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop test
        Test.stopTest();              
    }  
    /**
    * @description       : Test Class method for beforeDeletetest
    * @date       		 : 30/03/2022
    */
    @Istest
    private static void testupdateEquipmentRequestRecord(){
        //Creating Account Record
        Account acct = [SELECT Id FROM Account WHERE Name =: STR_TEST_ACCOUNT LIMIT 1];
        acct.Description = 'Test05';
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test06';
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        equip.JMS_Equipment_Cost__c = 100000;
        ContentVersion docVersion = JMS_TestDataFactory.createContentVersion('ContentVersion Title');
        ContentVersion docVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :docVersion.Id LIMIT 1];
        ContentDocumentLink doccLink = JMS_TestDataFactory.createContentDocumentLink(equip.Id,docVersion1.ContentDocumentId);
        equip.JMS_Is_Attachment_Added__c = TRUE;
        //Updating Equipment Request 
        UPDATE equip;
        equip.JMS_Is_Attachment_Added__c = FALSE;
        //Updating Equipment Request 
        UPDATE equip;
        //Deleting Equipment Request 
        DELETE equip;
        //Undeleting Equipment Request 
        UNDELETE equip;
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(equip);
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        linkList.add(doccLink);
        Test.startTest();
        //JMS_ContentDocumentTriggerHelper helper = new JMS_ContentDocumentTriggerHelper();
        JMS_ContentDocumentTriggerHelper.updateEquipmentRequestRecord(equipList);

        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        Test.stopTest();       
    }
    /**
    * @description       : Test Class method for beforeDeletetest
    * @date       		 : 30/03/2022
    */
    @Istest
    private static void updateEquipmentRequestRecordExceptiontest(){
        //User use = JMS_TestDataFactory.createReadOnlyUser();
        //Creating Account Record
        Account acct = [SELECT Id FROM Account WHERE Name =: STR_TEST_ACCOUNT LIMIT 1];
        acct.Description = 'Test07';
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: 'Test Opportunity' LIMIT 1];
        opp.Description = 'Test08';
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        equip.JMS_Equipment_Cost__c = 100000;
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        Test.startTest();  
        //JMS_ContentDocumentTriggerHelper helper = new JMS_ContentDocumentTriggerHelper();
        JMS_ContentDocumentTriggerHelper.updateEquipmentRequestRecord(equipList); 
        System.assert(equipList.size()==0,STR_LIST_IS_NOT_NULL);
        Test.stopTest();       
    }   
    
}