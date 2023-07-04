/**
* @description       : Test Class for JMS_PrimaryContactController
* @author            : Sumit
* @date       		 : 28/03/2022
* @last modified on  : 28/03/2021
* @last modified by  : Sumit
*/
@Istest
private class JMS_PrimaryContactControllerTest {
    @testSetup static void setup(){
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acc.Id);
        con.Description = 'Test Contact 01';
    }
    @IsTest
    private static void isPrimaryContactExistTest(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Primary Contact' LIMIT 1];
        con.JMS_Primary_Contact__c = true;
        UPDATE con;
        //The test starts from here.
        Test.startTest();
        Boolean isPrimaryContExist = JMS_PrimaryContactController.isPrimaryContactExist(acc.Id);
        System.AssertEquals(isPrimaryContExist, true,'The Value is True');
        Test.stopTest();
        //The test ends here.
    }
    
    @IsTest
    private static void noPrimaryContactExistTest(){
        Boolean isException = false;
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Primary Contact' LIMIT 1];
        con.Description = 'Test';
        //The test starts from here.
        Test.startTest();
        try{
            Boolean isPrimaryContactsExist;
        	isPrimaryContactsExist = JMS_PrimaryContactController.isPrimaryContactExist(acc.Id);
        } catch(Exception exc){
            isException = true;
        }
        System.AssertEquals(isException, true,'The Value is True'); 
        System.AssertEquals(isException, true,'The Value is True');  
        Test.stopTest(); 
        //The test ends here.
    }
    
}