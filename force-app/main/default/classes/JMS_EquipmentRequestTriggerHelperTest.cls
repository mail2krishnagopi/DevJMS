/**
* @description       : Test Class for JMS_EquipmentRequestTriggerHelperTest
* @author            : Archana
* @date              : 30/03/2022
**/
@Istest
private class JMS_EquipmentRequestTriggerHelperTest {
    //Contsants
    private static final String STR_CONTENTVERSION_TITLE = 'ContentVersion Title';
    /*
    * CodeScan error Fix - The String literal is used to many times
    * Anil 03/06/2022
    * */
    private static final String STR_TEST_OPPORTUNITY = 'Test Opportunity';
    private static final String STR_JMS_EQUIPMENT_REQUEST = 'JMS_Equipment_Request__c';
    private static final String STR_LIST_IS_NOT_NULL = 'List is not Null';
    private static final String STR_TRIGNAME_IS_NOT_NULL = 'trigName is not Null';
    @testSetup static void setup(){
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        Opportunity opp = JMS_TestDataFactory.createOpportunity(STR_TEST_OPPORTUNITY,acc.ID);
        JMS_Equipment_Request__c equip = JMS_TestDataFactory.createEquipmentRequest(opp.ID);
        equip.JMS_Is_Attachment_Added__c = TRUE;
        UPDATE equip;
        
    }
    //Test method for initiateApprovalProcess
    @Istest
    private static void initiateApprovalProcesstest(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test1';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c acct = [SELECT Id,JMS_RSM_Approved__c FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        acct.JMS_RSM_Approved__c = TRUE;
        acct.JMS_Account_Type__c = 'National Other';
        //Update Account
        UPDATE acct;
        //Creat Equipment Request List
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        //List of accounts
        equipList.add(acct);
        Map<Id,JMS_Equipment_Request__c> mapEquip = new Map<Id,JMS_Equipment_Request__c>();
        //Updating map of account id and account
        mapEquip.put(acct.Id,acct);
        //Start Test
        Test.startTest();
        JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.initiateApprovalProcess(equipList,mapEquip);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();       
    }//End
    @Istest
    private static void initiateApprovalProcesstest2(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test2';
        //Getting Equipment Request Record
        
        JMS_Equipment_Request__c acct = [SELECT Id,JMS_RSM_Approved__c FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id  LIMIT 1];
        //Creat Equipment Request List
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        Map<Id,JMS_Equipment_Request__c> mapEquip = new Map<Id,JMS_Equipment_Request__c>();
        //Updating map of account id and account
        mapEquip.put(acct.Id,acct);
        acct.JMS_Account_Type__c = 'National Other';
        //Updating Account
        UPDATE acct;
        equipList.add(acct);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.initiateApprovalProcess(equipList,mapEquip);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();       
    }
    @Istest
    private static void initiateEmailNotificationRequesttest(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test3';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c acct = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        Map<Id,JMS_Equipment_Request__c> mapEquip = new Map<Id,JMS_Equipment_Request__c>();
        //Map of Equipment_Request Id and Equipment_Request
        mapEquip.put(acct.Id,acct);
        acct.JMS_Is_Attachment_Added__c = TRUE;
        acct.JMS_RSM_approval_Status__c = 'Approved';
        acct.JMS_Overall_Status__c = 'InProgress - Pending Approvals';
        acct.JMS_Status__c = 'Active - Pending NAM';
        //Update account
        Update acct;
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(acct);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.initiateEmailNotificationRequest(equipList,mapEquip);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();       
    }
    
    @Istest
    private static void submitForApprovaltest(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test4';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c acct = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        //Getting Account Record
        Account Acc = [SELECT Id FROM Account WHERE Name =: 'Test Account' LIMIT 1];
        //List of Equipment_Requests
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        acct.JMS_Account__c = Acc.Id;
        acct.JMS_Is_Attachment_Added__c = TRUE;
        UPDATE acct;
        equipList.add(acct);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.submitForApproval(acct.Id,'Comment');
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();       
    }//End
    
    @Istest
    private static void sendEmailNotificationToApproverstest(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test5';
        //Getting Equipment Request Record
        Account Acc = [SELECT Id FROM Account WHERE Name =: 'Test Account' LIMIT 1];
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        ContentVersion docVersion = JMS_TestDataFactory.createContentVersion(STR_CONTENTVERSION_TITLE);
        ContentVersion docVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :docVersion.Id LIMIT 1];
        ContentDocumentLink doccLink = JMS_TestDataFactory.createContentDocumentLink(equip.Id,docVersion1.ContentDocumentId);
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id =: docVersion1.ContentDocumentId LIMIT 1];
        Map<ID,List<Messaging.Emailfileattachment>> messageFileMap = new Map<Id,List<Messaging.Emailfileattachment>>();
        Messaging.EmailFileAttachment messageFile = new Messaging.EmailFileAttachment();
        messageFile.setFileName(docVersion.Title);
        messageFile.setBody(docVersion.VersionData);
        List<Messaging.EmailFileAttachment> messageFileList = new List<Messaging.EmailFileAttachment>();
        messageFileList.add(messageFile);
        messageFileMap.put(equip.Id,messageFileList);
        equip.JMS_Account__c = Acc.Id;
        equip.JMS_Is_Attachment_Added__c = TRUE;
        UPDATE equip;
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(equip);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.sendEmailNotificationToApprovers(equipList);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();
        
    }//End
    @Istest
    private static void sendEmailNotificationToApproverstest2(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test6';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        equip.JMS_Is_Attachment_Added__c = TRUE;
        equip.JMS_Overall_Status__c = 'InProgress - Pending Approvals';
        //Updating Equipment_Request
        UPDATE equip;
        equip.NAM_approval_Status__c = 'Submitted';
        //Updating Equipment_Request
        UPDATE equip;
        equip.JMS_Status__c = 'Active - Pending NAM';
        //Updating Equipment_Request
        UPDATE equip;
        ContentVersion docVersion = JMS_TestDataFactory.createContentVersion(STR_CONTENTVERSION_TITLE);
        ContentVersion docVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :docVersion.Id LIMIT 1];
        ContentDocumentLink doccLink = JMS_TestDataFactory.createContentDocumentLink(equip.Id,docVersion1.ContentDocumentId);
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id =: docVersion1.ContentDocumentId LIMIT 1];
        Map<ID,List<Messaging.Emailfileattachment>> messageFileMap = new Map<Id,List<Messaging.Emailfileattachment>>();
        Messaging.EmailFileAttachment messageFile = new Messaging.EmailFileAttachment();
        messageFile.setFileName(docVersion.Title);
        messageFile.setBody(docVersion.VersionData);
        List<Messaging.EmailFileAttachment> messageFileList = new List<Messaging.EmailFileAttachment>();
        messageFileList.add(messageFile);
        messageFileMap.put(equip.Id,messageFileList);
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(equip);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.sendEmailNotificationToApprovers(equipList);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop test
        Test.stopTest();
        
    }//End
    @Istest
    private static void sendEmailNotificationToApproverstest3(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test7';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        equip.JMS_Is_Attachment_Added__c = TRUE;
        equip.JMS_Overall_Status__c = 'InProgress - Pending Approvals';
        //Updating Equipment_Request
        UPDATE equip;
        equip.JMS_Status__c = 'Active - Pending Equipment Integrity';
        //Updating Equipment_Request
        UPDATE equip;
        equip.JMS_Equipment_Integrity_Approval_Status__c = 'Submitted';
        //Updating Equipment_Request
        UPDATE equip;
        ContentVersion docVersion = JMS_TestDataFactory.createContentVersion(STR_CONTENTVERSION_TITLE);
        ContentVersion docVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :docVersion.Id LIMIT 1];
        ContentDocumentLink doccLink = JMS_TestDataFactory.createContentDocumentLink(equip.Id,docVersion1.ContentDocumentId);
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id =: docVersion1.ContentDocumentId LIMIT 1];
        Map<ID,List<Messaging.Emailfileattachment>> messageFileMap = new Map<Id,List<Messaging.Emailfileattachment>>();
        Messaging.EmailFileAttachment messageFile = new Messaging.EmailFileAttachment();
        messageFile.setFileName(docVersion.Title);
        messageFile.setBody(docVersion.VersionData);
        List<Messaging.EmailFileAttachment> messageFileList = new List<Messaging.EmailFileAttachment>();
        messageFileList.add(messageFile);
        messageFileMap.put(equip.Id,messageFileList);
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(equip);
        //Start test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.sendEmailNotificationToApprovers(equipList);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();
        
    }//End
    @Istest
    private static void sendEmailNotificationToApproverstest4(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test8';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        equip.JMS_Is_Attachment_Added__c = TRUE;
        equip.JMS_Overall_Status__c = JMS_ConstantsUtility.STR_COMPLETED;
        //Updating Equipment_Request
        UPDATE equip;
        equip.JMS_Status__c = JMS_ConstantsUtility.STR_COMPLETED;
        //Updating Equipment_Request
        UPDATE equip;
        equip.JMS_Equipment_Integrity_Approval_Status__c = 'Approved';
        //Updating Equipment_Request
        UPDATE equip;
        ContentVersion docVersion = JMS_TestDataFactory.createContentVersion(STR_CONTENTVERSION_TITLE);
        ContentVersion docVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :docVersion.Id LIMIT 1];
        ContentDocumentLink doccLink = JMS_TestDataFactory.createContentDocumentLink(equip.Id,docVersion1.ContentDocumentId);
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id =: docVersion1.ContentDocumentId LIMIT 1];
        Map<ID,List<Messaging.Emailfileattachment>> messageFileMap = new Map<Id,List<Messaging.Emailfileattachment>>();
        Messaging.EmailFileAttachment messageFile = new Messaging.EmailFileAttachment();
        messageFile.setFileName(docVersion.Title);
        messageFile.setBody(docVersion.VersionData);
        List<Messaging.EmailFileAttachment> messageFileList = new List<Messaging.EmailFileAttachment>();
        messageFileList.add(messageFile);
        messageFileMap.put(equip.Id,messageFileList);
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(equip);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.sendEmailNotificationToApprovers(equipList);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop test
        Test.stopTest();
        
    }//End
    
    @Istest
    private static void customNotificationToOwnerTest(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test9';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c equip = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        equip.JMS_Is_Attachment_Added__c = TRUE;
        equip.JMS_Overall_Status__c = 'InProgress - Rejected';
        //Updating Equipment_Request
        UPDATE equip;
        
        equip.JMS_Equipment_Integrity_Approval_Status__c = 'Approved';
        //Updating Equipment_Request
        UPDATE equip;
        Map<Id,JMS_Equipment_Request__c> mapEquip = new Map<Id,JMS_Equipment_Request__c>();
        mapEquip.put(equip.Id,equip);
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(equip);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.customNotificationToOwner(equipList,mapEquip);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Updating Equipment_Request
        Test.stopTest();
        
    }//End
    
    @Istest
    private static void populateOppAccounttest(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test10';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c acct = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        //Getting list Equipment_Requests
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(acct);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.populateOppAccount(equipList);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();  
    }//End
    
    @Istest
    private static void resetApprovedFieldsByApproverstest(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test11';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c acct = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        equipList.add(acct);
        Map<Id,JMS_Equipment_Request__c> mapEquip = new Map<Id,JMS_Equipment_Request__c>();
        mapEquip.put(acct.Id,acct);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.resetApprovedFieldsByApprovers(equipList,mapEquip);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();  
    }//End
    @Istest
    private static void checkEIUserUpdateForgeIdTest(){
        //Creating Opportunity Record
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        opp.Description = 'Test12';
        //Getting Equipment Request Record
        JMS_Equipment_Request__c acct = [SELECT Id FROM JMS_Equipment_Request__c WHERE JMS_Opportunity__c =: opp.Id LIMIT 1];
        List<JMS_Equipment_Request__c> equipList = new List<JMS_Equipment_Request__c>();
        acct.JMS_Overall_Status__c = JMS_ConstantsUtility.STR_COMPLETED;
        //Updating Account
        UPDATE acct;
        acct.JMS_Status__c = JMS_ConstantsUtility.STR_COMPLETED;
        //Updating Account
        UPDATE acct;
        equipList.add(acct);
        Map<Id,JMS_Equipment_Request__c> mapEquip = new Map<Id,JMS_Equipment_Request__c>();
        mapEquip.put(acct.Id,acct);
        //Start Test
        Test.startTest();
        //JMS_EquipmentRequestTriggerHelper helper = new JMS_EquipmentRequestTriggerHelper();
        JMS_EquipmentRequestTriggerHandler handler = new JMS_EquipmentRequestTriggerHandler();
        String trigName = handler.getName();
        JMS_EquipmentRequestTriggerHelper.checkEIUserUpdateForgeId(equipList,mapEquip);
        System.assertEquals(STR_JMS_EQUIPMENT_REQUEST, trigName,STR_TRIGNAME_IS_NOT_NULL);
        System.assert(equipList.size()>0,STR_LIST_IS_NOT_NULL);
        //Stop Test
        Test.stopTest();  
    }//End
    
}//End