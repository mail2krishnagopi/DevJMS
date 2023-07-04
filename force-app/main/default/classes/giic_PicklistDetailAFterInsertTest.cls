@isTest
public class giic_PicklistDetailAFterInsertTest {
    
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
        
         gii__PickList__c pkInstance = new gii__PickList__c();
        pkInstance.gii__OrderType__c='Standard' ;
        // pkInstance.gii__SalesOrder__c=lstSalesOrder[0].id  ;
        // pkInstance.gii__Product__c=lstProd[0].id ;
        
        pkInstance.gii__PicklistSequence__c=1 ;
        pkInstance.gii__CreditStatus__c='ok' ;
        system.debug('pkInstance>>'+pkInstance);
        insert pkInstance;
        
        gii__PickListDetail__c  pkDInstance = new gii__PickListDetail__c();
        pkDInstance.gii__PickList__c=pkInstance.id ;
        pkDInstance.gii__PickQuantity__c =1;
        insert pkDInstance;
        
        system.debug('pkInstance.id>>'+pkInstance.id);
        
    }
     @isTest static void testpicklist() {
          test.startTest();
         gii__PickListDetail__c  pkDList = [select id , gii__PickList__c  from gii__PickListDetail__c];
         test.stopTest();
         
     }
}