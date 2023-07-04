@isTest
public class giic_PurchaseOrderInvocableClaFutureTest {
    
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    @isTest static void testMethodGetServiceTicketLine() {
        
        list<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> poLinesToCreate = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
        
        
        list<gii__ServiceTicketLine__c>  lstservTicketLine =[select id,gii__ServiceTicket__c ,
                                                              gii__Product__c,gii__Quantity__c,
                                                              gii__FieldServiceEngineer__c,
                                                              gii__ServiceTicketLineStatus__c,
                                                              gii__FieldServiceEngineer__r.gii__Warehouse__c,
                                                              gii__FieldServiceEngineer__r.gii__Supplier__c,
                                                              gii__FieldServiceEngineer__r.gii__ThirdPartySupplier__c,
                                                              gii__AssetReference__c,gii__AssetReference__r.id,
                                                              gii__AssetReference__r.gii__ProductSerial__c
                                                              from gii__ServiceTicketLine__c
                                                              where id=:poLinesToCreate[0].id ];
        
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
        
        
        gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = lstAcc[0].Id, 
                                                                gii__ShipTo__c = lstWarehouse[0].Id,
                                                                gii__ServiceTicket__c=lstservTicketLine[0].Id);
        insert objPO;
        
        gii__PurchaseOrderLine__c purLine = new gii__PurchaseOrderLine__c();
        purLine.gii__ServiceTicketLine__c = lstservTicketLine[0].Id;
        purLine.gii__OrderQuantity__c = lstservTicketLine[0].gii__Quantity__c;
        
        purLine.gii__PurchaseOrder__c = objPO.Id;
        purLine.gii__ReceiptStatus__c	= 'Open';
        purLine.gii__Product__c = lstservTicketLine[0].gii__Product__c;
        purLine.gii__ServiceTicket__c = lstservTicket[0].id;
        purLine.gii__ServiceTicketLine__c = lstservTicketLine[0].Id;
        
        insert purLine;
        
        
        list<String> listSTLIds = new list<String>();
        listSTLIds.add(lstservTicketLine[0].Id);
        
        test.startTest();
        giic_PurchaseOrderInvocableClaFuture.processRecords(objPO.id ,listSTLIds);
        test.stopTest();
    }
}