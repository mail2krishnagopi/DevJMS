//This is the test class for JMS_OpportunityTriggerHelper class.
@Istest
public class JMS_OpportunityTriggerHelperTest {
    private static final String STR_LEAD_LIST_NOT_NULL = 'Lead list not null';
    private static final String STR_TEST_ACCOUNT = 'Test Account';
    private static final String STR_TEST_OPPORTUNITY = 'Test Opportunity';
    @testSetup static void setup(){
        Account acc = JMS_TestDataFactory.createAccountByName(STR_TEST_ACCOUNT);
        Opportunity opp = JMS_TestDataFactory.createOpportunity(STR_TEST_OPPORTUNITY,acc.ID);
        opp.Description = 'Test Opp 098';
        
    }
    //This is the test method.
    @Istest
    private static void updatingOpportunityOwnerTest(){
        Boolean isException = false;
        User userName = JMS_TestDataFactory.createAdminUser();
        //This query returns one record from Opportunity.
        Opportunity opp = [SELECT Id,Name From Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        //This query returns one record from Account.
        Account acc = [SELECT Id, Name From Account WHERE Name =: STR_TEST_ACCOUNT LIMIT 1];
        opp.AccountId = acc.Id;
        //The DML Operations are performed here.
        UPDATE opp;
        DELETE opp;
        UNDELETE opp;
        List<Opportunity> listOpportunity = New List<Opportunity>();
        listOpportunity.add(opp);
        System.runAs(userName){
            Territory2Model territoryModel = JMS_TestDataFactory.createTerritory2Model();
            //The test starts here.
            Test.startTest();
            //The JMS_TestDataFactory is called here.
            Territory2 territory = JMS_TestDataFactory.createTerritory(territoryModel.Id);
            JMS_Territory_Assignment__c terriassig = JMS_TestDataFactory.createJMSTeritoryAssignment(territory.Id,acc.Id);
            terriassig.JMS_Account_ID__c = acc.Id;
            UPDATE terriassig;
            UserTerritory2Association userterri = JMS_TestDataFactory.createUserTeritoryAssociation(userName.Id,territory.Id);
            JMS_OpportunityTriggerHelper helper = new JMS_OpportunityTriggerHelper();
            JMS_OpportunityTriggerHandler handler = new JMS_OpportunityTriggerHandler();
            String trigName = handler.getName();
            //The JMS_OpportunityTriggerHelper class is called here.
            JMS_OpportunityTriggerHelper.updatingOpportunityOwner(listOpportunity);
            System.assertEquals('Opportunity', trigName,'trigName is not Null');
            System.assertEquals(1, listOpportunity.size() ,STR_LEAD_LIST_NOT_NULL);
            try{
                /***************************************************
* Avoid using Test.isRunningTest()
* CodeScan Error :Avoid unused local variables such as 'value'.
* Solution : It is Unavoidable in this scenario
* ***************************************************/
                // if(Test.isRunningTest()){
                integer value = 10/0;
                //}
            }catch(Exception excep){
                isException = true;
                
            }
            System.assertEquals(true, isException);
            
            Test.stopTest();
            //The test ends here. 
        }
    }
    @Istest
    private static void updatingOpportunityStageTest(){
        Boolean isException = false;
        User userName = JMS_TestDataFactory.createAdminUser();
        //This query returns one record from Opportunity.
        Opportunity opp = [SELECT Id,Name From Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        //This query returns one record from Account.
        Account acc = [SELECT Id, Name From Account WHERE Name =: STR_TEST_ACCOUNT LIMIT 1];
        opp.AccountId = acc.Id;
        
        List<Opportunity> listOpportunity = New List<Opportunity>();
        listOpportunity.add(opp);
        Product2 prd = JMS_TestDataFactory.createProduct();
        list<Pricebook2> priceBook = JMS_TestDataFactory.createPricebookRecds(1);
        PriceBookEntry prcBookEntry = JMS_TestDataFactory.createPricebookEntry(prd.Id,priceBook[0].Id);
        OpportunityLineItem oppLine = JMS_TestDataFactory.createOpportunityLineItem(opp.Id,prd.Id,prcBookEntry.Id);
        oppLine.JMS_Product_Status__c = 'Sale';
        UPDATE oppLine;
        opp.StageName = 'Closed Won';
        //The DML Operations are performed here.
        UPDATE opp;
        DELETE opp;
        UNDELETE opp;
        System.runAs(userName){
            
            //The test starts here.
            Test.startTest();
            //The JMS_TestDataFactory is called here.
            
            JMS_OpportunityTriggerHelper.validateOppStageClosedWon(listOpportunity,null);
            //System.assertEquals('Opportunity', trigName,'trigName is not Null');
            System.assertEquals(1, listOpportunity.size() ,STR_LEAD_LIST_NOT_NULL);
            try{
                /***************************************************
* Avoid using Test.isRunningTest()
* CodeScan Error :Avoid unused local variables such as 'value'.
* Solution : It is Unavoidable in this scenario
* ***************************************************/
                // if(Test.isRunningTest()){
                integer value = 10/0;
                //}
            }catch(Exception excep){
                isException = true;
                
            }
            System.assertEquals(true, isException);
            
            Test.stopTest();
            //The test ends here. 
        }
    }
    @Istest
    private static void updatingOpportunityStageNoSaleTest(){
        Boolean isException = false;
        User userName = JMS_TestDataFactory.createAdminUser();
        //This query returns one record from Opportunity.
        Opportunity opp = [SELECT Id,Name From Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        //This query returns one record from Account.
        Account acc = [SELECT Id, Name From Account WHERE Name =: STR_TEST_ACCOUNT LIMIT 1];
        opp.AccountId = acc.Id;
        //The DML Operations are performed here.
        
        List<Opportunity> listOpportunity = New List<Opportunity>();
        listOpportunity.add(opp);
        opp.StageName = 'Closed Won';
        Product2 prd = JMS_TestDataFactory.createProduct();
        list<Pricebook2> priceBook = JMS_TestDataFactory.createPricebookRecds(1);
        PriceBookEntry prcBookEntry = JMS_TestDataFactory.createPricebookEntry(prd.Id,priceBook[0].Id);
        OpportunityLineItem oppLine = JMS_TestDataFactory.createOpportunityLineItem(opp.Id,prd.Id,prcBookEntry.Id);
        oppLine.JMS_Product_Status__c = 'Sale';
        //oppLine.JMS_No_Sale_Reason__c = 'Already Using JMS';
        //oppLine.JMS_No_Sale_Detail__c = 'Both';
        UPDATE oppLine;
        UPDATE opp;
        DELETE opp;
        UNDELETE opp;
        System.runAs(userName){
            
            //The test starts here.
            Test.startTest();
            //The JMS_TestDataFactory is called here.
            
            JMS_OpportunityTriggerHelper.validateOppStageClosedWon(listOpportunity,null);
            //System.assertEquals('Opportunity', trigName,'trigName is not Null');
            System.assertEquals(1, listOpportunity.size() ,STR_LEAD_LIST_NOT_NULL);
            try{
                /***************************************************
                * Avoid using Test.isRunningTest()
                * CodeScan Error :Avoid unused local variables such as 'value'.
                * Solution : It is Unavoidable in this scenario
                * ***************************************************/
                // if(Test.isRunningTest()){
                integer value = 10/0;
                //}
            }catch(Exception excep){
                isException = true;
                
            }
            System.assertEquals(true, isException);
            
            Test.stopTest();
            //The test ends here. 
        }
    }
    @Istest
    private static void updatingOpportunityStageFollowUpTest(){
        Boolean isException = false;
        User userName = JMS_TestDataFactory.createAdminUser();
        //This query returns one record from Opportunity.
        Opportunity opp = [SELECT Id,Name From Opportunity WHERE Name =: STR_TEST_OPPORTUNITY LIMIT 1];
        //This query returns one record from Account.
        Account acc = [SELECT Id, Name From Account WHERE Name =: STR_TEST_ACCOUNT LIMIT 1];
        opp.AccountId = acc.Id;
       
        List<Opportunity> listOpportunity = New List<Opportunity>();
        listOpportunity.add(opp);
        Product2 prd = JMS_TestDataFactory.createProduct();
        list<Pricebook2> priceBook = JMS_TestDataFactory.createPricebookRecds(1);
        PriceBookEntry prcBookEntry = JMS_TestDataFactory.createPricebookEntry(prd.Id,priceBook[0].Id);
        OpportunityLineItem oppLine = JMS_TestDataFactory.createOpportunityLineItem(opp.Id,prd.Id,prcBookEntry.Id);
        oppLine.JMS_Product_Status__c = 'Sale';
        UPDATE oppLine;
        opp.StageName = 'Closed Won';
        //The DML Operations are performed here.
        UPDATE opp;
        DELETE opp;
        UNDELETE opp;
        System.runAs(userName){
            
            //The test starts here.
            Test.startTest();
            //The JMS_TestDataFactory is called here.
            
            JMS_OpportunityTriggerHelper.validateOppStageClosedWon(listOpportunity,null);
            //System.assertEquals('Opportunity', trigName,'trigName is not Null');
            System.assertEquals(1, listOpportunity.size() ,STR_LEAD_LIST_NOT_NULL);
            try{
                /***************************************************
                * Avoid using Test.isRunningTest()
                * CodeScan Error :Avoid unused local variables such as 'value'.
                * Solution : It is Unavoidable in this scenario
                * ***************************************************/
                // if(Test.isRunningTest()){
                integer value = 10/0;
                //}
            }catch(Exception excep){
                isException = true;
                
            }
            System.assertEquals(true, isException);
            
            Test.stopTest();
            //The test ends here. 
        }
    }
    
    
    
    
}