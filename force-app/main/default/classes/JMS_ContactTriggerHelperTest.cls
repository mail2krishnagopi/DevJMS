/**
* @description : This Test class will be used to cover JMS_ContactTriggerHelper
* @date        : 25/02/2022
*/
@Istest
private class JMS_ContactTriggerHelperTest {
    /**
    * @description : This Test class will be used to cover checkPrimaryContactInsert method
    * @date        : 25/02/2022
    */
    @IsTest
    private static void isPrimaryContactExistTestinsert(){
        List<Contact> accList = new List<Contact>();
        //Creat account from Tesr Data Factory
        Account acct = JMS_TestDataFactory.createAccountByName('TestAccount');
        //Creat Contact from Tesr Data Factory
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acct.Id);
        con.JMS_Primary_Contact__c = true;
        Contact con1 = JMS_TestDataFactory.createContactForValidatingPrimaryContact('Test Primary Contact1' , acct.Id);
        con1.JMS_Primary_Contact__c = true;
        insert con1;
        accList.add(con);
        accList.add(con1);
        Test.startTest();
        JMS_ContactTriggerHelper helper = new JMS_ContactTriggerHelper();
        JMS_ContactTriggerHandler handler = new JMS_ContactTriggerHandler();
        String trigName = handler.getName();
        //Calling checkPrimaryContactInsert Method
        JMS_ContactTriggerHelper.checkPrimaryContactInsert(accList);
        System.assertEquals('Contact', trigName,'trigName is not Null');
        System.assert(accList.size()>0,'List is not Null');
        Test.stopTest();
        
    }
    /**
    * @description : This Test class will be used to cover checkPrimaryContactUpdate method
    * @date        : 25/02/2022
    */
    @IsTest
    private static void isPrimaryContactExistTestupdate(){
        List<Contact> accList = new List<Contact>();
        Map<Id, SObject> newItemsMap = new Map<Id, SObject>();
        Map<Id, SObject> oldItemsMap = new Map<Id, SObject>();
        //Creat account from Tesr Data Factory
        Account acc = JMS_TestDataFactory.createAccountByName('New Test Account');
        //Creat Contact from Tesr Data Factory
        Contact con = JMS_TestDataFactory.createContact('Test Primary Contact' , acc.Id);
        con.JMS_Primary_Contact__c = true;
        UPDATE con;
        Contact con1 = JMS_TestDataFactory.createContactForValidatingPrimaryContact('Test Primary Contact1' , acc.Id);
        con1.JMS_Primary_Contact__c = false;
        insert con1;
        accList.add(con);
        accList.add(con1);
        Delete con1;
        UnDelete con1;
        newItemsMap.put(con.Id, con);
        oldItemsMap.put(con.Id, con1);
        Test.startTest();
        //JMS_ContactTriggerHelper helper = new JMS_ContactTriggerHelper();
        JMS_ContactTriggerHandler handler = new JMS_ContactTriggerHandler();
        String trigName = handler.getName();
        //Calling checkPrimaryContactUpdate Method
        JMS_ContactTriggerHelper.checkPrimaryContactUpdate(accList, newItemsMap, oldItemsMap);
        System.assertEquals('Contact', trigName,'trigName is not Null');
        System.assert(accList.size()>0,'List is not Null');
        Test.stopTest();
        
    }//End of method
}//End of class