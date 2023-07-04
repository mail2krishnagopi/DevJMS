/**
* @description : This Test class will be used to cover JMS_AccountTriggerHelper
* @author      : Archana Mohapatra
* @date        : 25/02/2022
*/
@isTest
public class JMS_AccountTriggerHelperTest {
    //Constant Names
    private static final String AccountName = 'Account';
    private static final String JMS_Operator = 'Operator';
    //Code Sacn Error Fix - The String literal used many times.
    private static final String STR_Trigger_Not_Null = 'trigName is not Null';
    //testSetup
    @testSetup static void setup(){
        JMS_Trigger_Manager__c obj = new JMS_Trigger_Manager__c();
        obj.JMS_Disabled_Objects__c = 'Case';
        obj.JMS_Mute_All_Triggers__c = FALSE;
        obj.JMS_Mute_All_Validations__c = TRUE;
        obj.Name = 'Test Class';
        insert obj;
        //Creating Account Data
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        acc.BillingPostalCode = '01021';
        UPDATE acc;	
    }
    //Start
    @isTest
    private static void testrestrictAccountFieldUpdates(){
        
        //Query the Test Account Data
        Account acct = JMS_TestDataFactory.createAccountWithFireflyId('Dummy Test Record with FF ID');
        INSERT acct;
        acct.JMS_Customer_Health__c = 'B';
        //Start Test
        test.startTest();
        try{
        	UPDATE acct;   
        }catch(Exception excep){
            String error = excep.getMessage();
        	System.assertEquals(true, error.contains(' Accounts from Firefly cannot be edited, except for the Expected GPO, Expected Distributor, Food Management Company, Vendor Management Company, Comments and Broker Territory fields.'));    
        }
         
        System.assertEquals(acct.Name, 'Dummy Test Record with FF ID',STR_Trigger_Not_Null);
        Test.stopTest();
        //End Test
    }//End
    //Start
    @isTest
    private static void testinitiateNewTerritoryAssignment(){
        //Query the Test Account Data
        Account acct = [SELECT Id, BillingPostalCode FROM Account WHERE Name = 'Test Account' LIMIT 1 ];
        //Creating a Map
        Map<Id,Account> mapAcc = new Map<Id,Account>();
        mapAcc.put(acct.Id,acct);
        acct.BillingPostalCode = '12345';
       
        List<Account> acclist = new List<Account>();
        acclist.add(acct);
        
        //Start test
        test.startTest();
        UPDATE acct;
        //JMS_AccountTriggerHelper helper = new JMS_AccountTriggerHelper();
        JMS_AccountTriggerHandler handler = new JMS_AccountTriggerHandler();
        String trigName = handler.getName();
        //JMS_AccountTriggerHelper.initiateNewTerritoryAssignment(acclist,mapAcc); 
        System.assertEquals(AccountName, trigName,STR_Trigger_Not_Null); 
        Test.stopTest();
        //End Test
    }//End
    //Start
 
    //Start
    @isTest
    private static void testgetAccountDetails(){
        //Query the Test Account Data
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User userName = JMS_TestDataFactory.createIntUser();
        System.runAs(userName){
        
        acct.JMS_FireFly_Id__c = 'Test123';
        UPDATE acct;
        }
        //Creating a New Map
        Map<Id,Account> mapAcc = new Map<Id,Account>();
        mapAcc.put(acct.Id,acct);
        Account newAcc = JMS_TestDataFactory.createAccountWithFireflyId('New Test Account');
        //Creating a List
        List<Account> acclist = new List<Account>();
        acclist.add(newAcc);
        //Start Test
        test.startTest();
        //JMS_AccountTriggerHelper helper = new JMS_AccountTriggerHelper();
        JMS_AccountTriggerHandler handler = new JMS_AccountTriggerHandler();
        String trigName = handler.getName();
        //JMS_AccountTriggerHelper.getAccountDetails(acclist,mapAcc,'afterundelete');  
        System.assertEquals(AccountName, trigName,STR_Trigger_Not_Null);
        Test.stopTest();
        //End Test
    }//End
    //Start
    @isTest
    private static void testcreateMapStringVsList(){
        //Query the Test Account Data
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        //Creating a List
        List<Account> acclist = new List<Account>();
        acclist.add(acct);
        //Start Test
        test.startTest();
        //JMS_AccountTriggerHelper helper = new JMS_AccountTriggerHelper();
        JMS_AccountTriggerHandler handler = new JMS_AccountTriggerHandler();
        String trigName = handler.getName();
        //JMS_AccountTriggerHelper.createMapStringVsList(acclist);  
        System.assertEquals(AccountName, trigName,STR_Trigger_Not_Null);
        Test.stopTest();
        //End Test
    }//End
    //Start
    @isTest
    private static void testpopulateRecordTypeId(){
        //Query the Test Account Data
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        acct.JMS_Record_Type_Name__c = JMS_Operator;
        UPDATE acct;
        //Creating a List
        List<Account> acclist = new List<Account>();
        acclist.add(acct);
        //Start Test
        test.startTest();
        //JMS_AccountTriggerHelper helper = new JMS_AccountTriggerHelper();
        JMS_AccountTriggerHandler handler = new JMS_AccountTriggerHandler();
        String trigName = handler.getName();
        //JMS_AccountTriggerHelper.populateRecordTypeId(acclist);  
        System.assertEquals(AccountName, trigName,STR_Trigger_Not_Null);
        Test.stopTest();
        //End Test
    }//End
    //Start
    @isTest
    private static void testCreateNewTerritoryAssociation(){
        //Query the Test Account Data
        User userName = JMS_TestDataFactory.createAdminUser();
        JMS_ZipCodes__c zipCodeNew = JMS_TestDataFactory.createZipcodesBasedOnNewZip('ZC-65345', '12346','AFH SOUTH EAST-2');
        Account acc = [SELECT Id, BillingPostalCode FROM Account WHERE Name = 'Test Account' LIMIT 1];
        acc.JMS_Record_Type_Name__c = JMS_Operator;
        acc.BillingPostalCode = '12345';
        UPDATE acc;
        //Creating a New Map
        Map<String,Id> mapofTerritoryNamevsId = new Map<String,Id>();
        Map<String,String> mapZipCodeVsTerritoryName = new Map<String,String>();
        //Creating a List
        List<Account> acclist = new List<Account>();
        acclist.add(acc);
        //User as Admin
        System.runAs(userName){
            Territory2Model territoryModel = JMS_TestDataFactory.createTerritory2Model();
            Territory2 territory = JMS_TestDataFactory.createTerritory(territoryModel.Id);
            JMS_Territory_Assignment__c terriassig = JMS_TestDataFactory.createJMSTeritoryAssignment(territory.Id,acc.Id);
            terriassig.JMS_Account_ID__c = acc.Id;
            UserTerritory2Association userterri = JMS_TestDataFactory.createUserTeritoryAssociation(userName.Id,territory.Id);
            //userterri.UserId = userName.Id;
            //JMS_ZipCodes__c zipCode = JMS_TestDataFactory.createZipcodes('ZC-54353');
            
            mapofTerritoryNamevsId.put(territory.Name,territory.Id);
            mapZipCodeVsTerritoryName.put(zipCodeNew.JMS_Zip_Code__c,zipCodeNew.JMS_Territory_Name__c);
            //Start Test
            test.startTest();
            //JMS_AccountTriggerHelper helper = new JMS_AccountTriggerHelper();
            JMS_AccountTriggerHandler handler = new JMS_AccountTriggerHandler();
            String trigName = handler.getName();
            JMS_AccountTriggerHelper.createNewTerritoryAssociation(acclist,mapofTerritoryNamevsId,mapZipCodeVsTerritoryName);  
            System.assertEquals(AccountName, trigName,STR_Trigger_Not_Null);
            Test.stopTest();
            //End Test
        }
    }//End
    //Start
    @isTest
    private static void testUpdateTerritoryOnAccount(){
        //Query the Test Account Data
        User userName = JMS_TestDataFactory.createAdminUser();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        acc.JMS_Record_Type_Name__c = JMS_Operator;
        UPDATE acc;
        set<String> accIds = new set<String>();
        accIds.add(acc.Id);
        //Creating a List
        List<Account> acclist = new List<Account>();
        acclist.add(acc);
        //User as Admin
        System.runAs(userName){
            Territory2Model territoryModel = JMS_TestDataFactory.createTerritory2Model();
            Territory2 territory = JMS_TestDataFactory.createTerritory(territoryModel.Id);
            JMS_Territory_Assignment__c terriassig = JMS_TestDataFactory.createJMSTeritoryAssignment(territory.Id,acc.Id);
            terriassig.JMS_Account_ID__c = acc.Id;
            UserTerritory2Association userterri = JMS_TestDataFactory.createUserTeritoryAssociation(userName.Id,territory.Id);
            //userterri.IsActive = true;
            ObjectTerritory2Association objAssoc = JMS_TestDataFactory.createTeritoryAssociation(acc.Id,territory.Id);
            //objAssoc.ObjectId = acc.Id;
            Opportunity opp = JMS_TestDataFactory.createOpportunity('Test opp',acc.Id);
            opp.Description = 'Test';
            //Start Test
            test.startTest();
            //JMS_AccountTriggerHelper helper = new JMS_AccountTriggerHelper();
            JMS_AccountTriggerHandler handler = new JMS_AccountTriggerHandler();
            String trigName = handler.getName();
            JMS_AccountTriggerHelper.updateTerritoryOnAccount(accIds);  
            System.assertEquals(AccountName, trigName,STR_Trigger_Not_Null);
            Test.stopTest();
            //End Test
        }
    }//End
    //Start
    @isTest
    private static void testdeleteExistingTerritoryAssociation(){
        //Query the Test Account Data
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User userName = JMS_TestDataFactory.createAdminUser();
        Set<String> newacc = new Set<String>();
        newacc.add(acct.Id);
        System.runAs(userName){
            Territory2Model territoryModel = JMS_TestDataFactory.createTerritory2Model();
            Territory2 territory = JMS_TestDataFactory.createTerritory(territoryModel.Id);
            JMS_Territory_Assignment__c terriassig = JMS_TestDataFactory.createJMSTeritoryAssignment(territory.Id,acct.Id);
            terriassig.JMS_Account_ID__c = acct.Id;
            ObjectTerritory2Association objAssoc = JMS_TestDataFactory.createTeritoryAssociation(acct.Id,territory.Id);
            //Start Test
            Test.startTest();
            //JMS_AccountTriggerHelper helper = new JMS_AccountTriggerHelper();
            JMS_AccountTriggerHandler handler = new JMS_AccountTriggerHandler();
            String trigName = handler.getName();
            JMS_AccountTriggerHelper.deleteExistingTerritoryAssociation(newacc);  
            System.assertEquals(AccountName, trigName,STR_Trigger_Not_Null);
            Test.stopTest();
            //End Tets
        }
    }//End
}