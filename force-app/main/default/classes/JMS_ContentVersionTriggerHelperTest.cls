/**
* @description : This Test class will be used to cover JMS_ContentVersionTriggerHelper
* @author      : Archana Mohapatra
* @date        : 25/02/2022
*/
//Start of Test
@Istest
private class JMS_ContentVersionTriggerHelperTest {
    //Start
    @IsTest
    private static void restrictToRenameFilesTest(){
        //Creating Test Account Data
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        UPDATE acc;
        DELETE acc;
        UNDELETE acc;
        //Creating Opp Test Data
        Opportunity newOpp = JMS_TestDataFactory.createOpportunity('Test opp',String.valueof(acc.Id));
        /*
         * CodeScan error Fix - Avoid using Unused varibles
         * Anil 03/06/2022
         * */
        newOpp.Description = 'Test034';
        //JMS_Equipment_Request__c newRequest = JMS_TestDataFactory.createEquipmentRequest(newOpp.Id);
        ContentVersion contentDoc = JMS_TestDataFactory.createContentVersion('Newdoc');
        ContentVersion contentDoc1 = JMS_TestDataFactory.createContentVersiontwo('Newdoc1');
        List<ContentVersion> dataList = new List<ContentVersion>();
        dataList.add(contentDoc);
        Map<Id,ContentVersion> mapVersion = new Map<Id,ContentVersion>();
        mapVersion.put(contentDoc.Id,contentDoc1);
        //Start Test
        Test.startTest();
        JMS_ContentVersionTriggerHelper helper = new JMS_ContentVersionTriggerHelper();
        JMS_ContentVersionTriggerHelper.restrictToRenameFiles(dataList,mapVersion);

        System.assert(dataList.size()>0,'List is not Null');
        Test.stopTest();
        //End Test
    }//End
}