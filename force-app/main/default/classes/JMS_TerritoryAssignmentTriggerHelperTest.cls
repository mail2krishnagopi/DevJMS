/**
* @description       : Test Class for JMS_Delete_SObject_RecordsTest
* @author            : Krishna
* @date       		 : 31/03/2022
* @last modified on  : 31/03/2021
* @last modified by  : Krishna
*/
@Istest
private class JMS_TerritoryAssignmentTriggerHelperTest {
    @IsTest
    private static void clearAccountTerritoryTest(){
        User userName = JMS_TestDataFactory.createAdminUser();
        Territory2Model terrModel = JMS_TestDataFactory.createTerritory2Model();
        Territory2 terr = JMS_TestDataFactory.createTerritory(terrModel.Id);
        System.runAs(userName){
            //Create Account Record
            Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
            Opportunity opp = JMS_TestDataFactory.createOpportunity('Test Opportunity',acc.Id);
            opp.Description = 'Test';
            JMS_Territory_Assignment__c terrAssig = JMS_TestDataFactory.createJMSTeritoryAssignment(terr.Id,acc.Id);
            terrAssig.JMS_ZipCodeAssignment__c = '12112';
            UPDATE terrAssig;
            Map<Id,JMS_Territory_Assignment__c> mapIdVsTerriAssig = NEW Map<Id,JMS_Territory_Assignment__c>();
            mapIdVsTerriAssig.put(terrAssig.Id, terrAssig);
            //Delete Territory
            DELETE terrAssig;
            //UnDelete Territory
            UNDELETE terrAssig;
            //Start Test
            Test.startTest();
            JMS_TerritoryAssignmentTriggerHelper helper = new JMS_TerritoryAssignmentTriggerHelper();
            JMS_TerritoryAssignmentTriggerHandler handler = new JMS_TerritoryAssignmentTriggerHandler();
            String trigName = handler.getName();
            JMS_TerritoryAssignmentTriggerHelper.clearAccountTerritory(mapIdVsTerriAssig);
            System.assertEquals('JMS_Territory_Assignment__c', trigName,'trigName is not Null');
            //Stop Test
            Test.stopTest();
    	}
	}
}