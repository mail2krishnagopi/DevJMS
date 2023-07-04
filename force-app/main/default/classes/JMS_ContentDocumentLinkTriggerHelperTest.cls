/**
* @description : This Test class will be used to cover JMS_ContentDocumentLinkTriggerHelper
* @author      : Krishna
* @date        : 25/03/2022
*/
//Start of Test Class
@Istest
private class JMS_ContentDocumentLinkTriggerHelperTest {
    //Start
    @IsTest
    private static void contentDocumentLinkTest(){
        //Creating the Account Data
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        //Creating the Opportunity Data
        Opportunity newOpp = JMS_TestDataFactory.createOpportunity('Test opp',String.valueof(acc.Id));
        //Creating the JMS_Equipment_Request__c Data
        JMS_Equipment_Request__c newRequest = JMS_TestDataFactory.createEquipmentRequest(newOpp.Id);
        newRequest.JMS_Equipment_Cost__c = 100000;
        ContentVersion contentDoc = JMS_TestDataFactory.createContentVersion('Newdoc');
        ContentVersion docVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentDoc.Id LIMIT 1];
        ContentDocumentLink contentDocLink = JMS_TestDataFactory.createContentDocumentLink(newOpp.Id,docVersion1.ContentDocumentId);
        List<ContentDocumentLink> dataList = new List<ContentDocumentLink>();
        dataList.add(contentDocLink);
        //Start Test
        Test.startTest();
        JMS_ContentDocumentLinkTriggerHelper helper = new JMS_ContentDocumentLinkTriggerHelper();
        JMS_ContentDocumentLinkTriggerHandler handler = new JMS_ContentDocumentLinkTriggerHandler();
        String trigName = handler.getName();
        JMS_ContentDocumentLinkTriggerHelper.beforeInsert(dataList, 'JMS_Equipment_Request__c');
        System.assertEquals('ContentDocumentLink', trigName,'trigName is not Null');
        System.assert(dataList.size()>0,'List is not Null');
        Test.stopTest();
        //End Test
        UPDATE contentDocLink;
        DELETE contentDocLink;
    }//End
    //Start
    @IsTest
    private static void updateEquipmentRequestTest(){
        //Creating the Account Data
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account1');
        //Creating the Opportunity Data
        Opportunity newOpp = JMS_TestDataFactory.createOpportunity('Test opp1',String.valueof(acc.Id));
        //Creating the JMS_Equipment_Request__c Data
        JMS_Equipment_Request__c newRequest = JMS_TestDataFactory.createEquipmentRequest(newOpp.Id);
        List<JMS_Equipment_Request__c> dataList = new List<JMS_Equipment_Request__c>();
        dataList.add(newRequest);
        //Start Test
        Test.startTest();
        //JMS_ContentDocumentLinkTriggerHelper helper = new JMS_ContentDocumentLinkTriggerHelper();
        JMS_ContentDocumentLinkTriggerHandler handler = new JMS_ContentDocumentLinkTriggerHandler();
        String trigName = handler.getName();
        JMS_ContentDocumentLinkTriggerHelper.updateEquipmentReqonDocUpload(dataList);
        System.assertEquals('ContentDocumentLink', trigName,'trigName is not Null');
        System.assert(dataList.size()>0,'List is not Null');
        Test.stopTest();
        //End Test
    }//End
}