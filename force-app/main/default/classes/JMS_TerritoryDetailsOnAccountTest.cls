/**
* @description       : Test Class for JMS_TerritoryDetailsOnAccountTest
* @author            : Vasudha
* @date       		 : 20/05/2022
*/
@isTest(SeeAllData=false)
public class JMS_TerritoryDetailsOnAccountTest {
	@testSetup static void setup(){
        //Creating Account Record
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        acc.BillingPostalCode = '01021';
        UPDATE acc;
    }
    
    @isTest
    private static void testUpdateTerritoryOnAccount(){
        User userName = JMS_TestDataFactory.createAdminUser();
        //Get the Account Record
        //Code scan Fix - define Where 
        Account acc = [SELECT Id FROM Account WHERE Name =: 'Test Account' LIMIT 1];
        acc.JMS_Record_Type_Name__c = 'JMS_Operator';
        //Update Account
        UPDATE acc;
        set<String> accIds = new set<String>();
        accIds.add(acc.Id);
        //Creating List of Accounts
        List<Account> acclist = new List<Account>();
        acclist.add(acc);
        //Run as System Admin User
        System.runAs(userName){
            Territory2Model territoryModel = JMS_TestDataFactory.createTerritory2Model();
            Territory2 territory = JMS_TestDataFactory.createTerritory(territoryModel.Id);
            //Creating Custom territory Assignment Object
            JMS_Territory_Assignment__c terriassig = JMS_TestDataFactory.createJMSTeritoryAssignment(territory.Id,acc.Id);
            terriassig.JMS_Account_ID__c = acc.Id;
            //Creating User Territory object
            UserTerritory2Association userterri = JMS_TestDataFactory.createUserTeritoryAssociation(userName.Id,territory.Id);
            ObjectTerritory2Association objAssoc = JMS_TestDataFactory.createTeritoryAssociation(acc.Id,territory.Id);
            //Creating Opportunity Record
            Opportunity opp = JMS_TestDataFactory.createOpportunity('Test opp',acc.Id);
            opp.Description = 'Test';
            //Start Test
            test.startTest();
            JMS_AccountTriggerHelper helper = new JMS_AccountTriggerHelper();
            JMS_AccountTriggerHandler handler = new JMS_AccountTriggerHandler();
            String trigName = handler.getName();
                if(accIds != null && !accIds.isEmpty()){
                    System.enqueuejob(new  JMS_TerritoryDetailsOnAccountQueueable(accIds));
                } 
            
            System.assertEquals('Account', trigName,'trigName is not Null');
            //Stop Test
            Test.stopTest();
    	}
    }
}