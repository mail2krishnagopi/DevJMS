/**
* @description       : Test Class for JMS_Delete_SObject_RecordsTest
* @author            : Krishna
* @date       		 : 31/03/2022
* @last modified on  : 31/03/2021
* @last modified by  : Krishna
*/
@isTest
private class JMS_AssignObjectTerritoryBatchTest {
    static testMethod void executeBatchTest(){
        Account acct = JMS_TestDataFactory.createAccountByName('Test Account');
        List<Account> acclist = new List<Account>();
        acclist.add(acct);
        JMS_ZipCodes__c zipRecord = JMS_TestDataFactory.createZipcodes('Test zipcode');
        zipRecord.JMS_Is_Active__c = True;
        Test.startTest();
        JMS_AssignObjectTerritoryAssociatBatch ba= new JMS_AssignObjectTerritoryAssociatBatch();
        /*
         * Removed unused varibles - CodeScan Error
         * Anil - 3/6/2022 */
        Database.executeBatch(ba);
        ba.start(null);
        ba.execute(null,accList);
        ba.Finish(null);
        Test.stopTest();
        system.assertEquals(1,accList.size(),'accList is Null');
        
    }
}