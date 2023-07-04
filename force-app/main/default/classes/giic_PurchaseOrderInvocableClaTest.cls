@isTest
public class giic_PurchaseOrderInvocableClaTest {
    
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    @isTest static void testMethodGetServiceTicketLine() {
        list<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
        list<gii__Warehouse__c> lstWarehouse = giic_Test_DataCreationUtility.insertWarehouse();
        List<Account> lstAcc = giic_Test_DataCreationUtility.insertConsumerAccount();
        
         List<gii__AssetReference__c> lstAssetReference =giic_Test_DataCreationUtility.insertAssetReference();
         gii__FieldServiceEngineer__c fieldServiceEngg = new gii__FieldServiceEngineer__c();
         fieldServiceEngg.name ='CHRIS ORTHODOXOU';
         fieldServiceEngg.gii__Warehouse__c=lstWarehouse[0].id;
         fieldServiceEngg.gii__Supplier__c = lstAcc[0].Id;
        fieldServiceEngg.gii__ThirdPartySupplier__c = true;
         insert fieldServiceEngg;
         
         lstservTicketLine[0].gii__FieldServiceEngineer__c=fieldServiceEngg.id;
        lstservTicketLine[0].gii__AssetReference__c=lstAssetReference[0].id;
        lstservTicketLine[0].gii__ServiceTicketLineStatus__c ='Closed';
        update lstservTicketLine;
        
        system.debug('lstservTicketLine  >>  '+lstservTicketLine); 
        
        test.startTest();
        giic_PurchaseOrderInvocableCla.createPurchaseRecords(lstservTicket);
        test.stopTest();
    }
    
}