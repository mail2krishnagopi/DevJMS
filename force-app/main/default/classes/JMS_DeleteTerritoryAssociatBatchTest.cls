/**
* @description       : Test Class for JMS_Delete_SObject_RecordsTest
* @author            : Krishna
* @date       		 : 31/03/2022
* @last modified on  : 31/03/2021
* @last modified by  : Krishna
*/
//Start Of Test
@isTest
private class JMS_DeleteTerritoryAssociatBatchTest {
    static testMethod void deleteObjectTerritoryTest(){
        //List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Broker_Assignments' LIMIT 1];
        User userName = JMS_TestDataFactory.createAdminUser();
        Territory2Model terrModel = JMS_TestDataFactory.createTerritory2Model();
        Territory2 terr = JMS_TestDataFactory.createTerritory(terrModel.Id);
        System.runAs(userName){
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        JMS_Territory_Assignment__c terrAssig = JMS_TestDataFactory.createJMSTeritoryAssignment(terr.Id,acc.Id);
        List<JMS_Territory_Assignment__c> terrAsslist = new List<JMS_Territory_Assignment__c>();
        terrAsslist.add(terrAssig);
        ObjectTerritory2Association terrAsso = JMS_TestDataFactory.createTeritoryAssociation(acc.Id,terr.Id);
        //Start Test
        Test.startTest();
        JMS_DeleteObjectTerritoryAssociatBatch ba= new JMS_DeleteObjectTerritoryAssociatBatch();
         /*
         * CodeScan error Fix - Avoid using Unused varibles
         * Anil 03/06/2022
         * */
        //ID batchprocessid = Database.executeBatch(ba);
        //Database.QueryLocator ql = ba.start(null);
        Database.executeBatch(ba);
        ba.start(null);
        ba.execute(null,terrAsslist);
        ba.Finish(null);
        Test.stopTest();
        //End
        system.assertEquals(1,terrAsslist.size(),'accList is Null');
        }//End
        
    }
}