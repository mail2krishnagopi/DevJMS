@isTest
public class giic_PLSRequestWrapperTest {

    
@testSetup static void setup() {
        giic_Test_DataCreationUtility.getTestClassUser();
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
       //giic_Test_DataCreationUtility.insertSite();

        //giic_Test_DataCreationUtility.insertAssetReference();
    }  
    
    
     @isTest
    static void testPostMethod() {
        // Create a new instance of the class that contains the POST method
        //giic_BookingConfirmation myClass = new giic_BookingConfirmation();
      
        // List<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        //List<gii__SalesOrderLine__c> lstSalesOrderLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
       List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        
        
        gii__SalesOrder__c so = new gii__SalesOrder__c();
        //open sales order 
        so =  new gii__SalesOrder__c(
            gii__Account__c = lstAccount[0].id ,
            gii__ScheduledDate__c = SYSTEM.today(),
            gii__OrderDate__c = SYSTEM.today(),
            gii__Warehouse__c = dcwarehouse[0].id,
            gii__TransferToWarehouse__c =dcwarehouse[1].id,
            gii__PaymentMethod__c = 'Credit Card',
            gii__OrderType__c='Transfer',
            gii__Carrier__c = lstCarrier != null && lstCarrier.size() > 0 ? lstCarrier[0].Id : null,
            gii__Released__c = false,
            //To overcome validation rule failure
            gii__ShipToStateProvince__c = 'MO',
            gii__BillingStateProvince__c = 'MO'
        );
        insert so;
        gii__TransferOrder__c to =  new gii__TransferOrder__c();
        to.gii__Account__c = lstAccount[0].id ;
        to.gii__OrderDate__c = SYSTEM.today();
        to.gii__TransferToWarehouse__c = dcwarehouse[0].id;
        to.gii__FromWarehouse__c = dcwarehouse[1].id;     //rt start
        to.gii__Carrier__c = lstCarrier[0].id;
        insert to;
        
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        shipment.gii__SalesOrder__c  =so.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        
        shipment.gii__ForwardToInvoice__c=false  ;
        shipment.gii__ShippedDate__c=system.today()  ;
        shipment.giic_loadId__c='14739864'  ;
        shipment.giic_BOL__c= '14739864';
        shipment.giic_SCAC__c= 'SAIA' ;
        shipment.giic_Hazmat__c =true  ;
        insert shipment;
        
        list<gii__Shipment__c> shippp=   [SELECT Id,Name,
                                          giic_loadId__c,giic_BOL__c,
                                          giic_SCAC__c,gii__ProductAmount__c,
                                          gii__SalesOrder__c,gii__TransferOrder__c,
                                          giic_Quantity__c,gii__Account__c,
                                          gii__Status__c, giic_statusDescription__c,
                                          giic_EstimatedDeliveryDate__c, giic_TrackingDate__c,
                                          gii__TransferOrder__r.Name
                                          FROM gii__Shipment__c
                                          where id =: shipment.id];
        
       
                      Test.startTest();
        
        giic_PLSRequestWrapper.getRequestedJson(shipment);
      
        Test.stopTest();
           }
   
     @isTest
    static void testPostMethod2() {
        // Create a new instance of the class that contains the POST method
        //giic_BookingConfirmation myClass = new giic_BookingConfirmation();
      
        // List<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        //List<gii__SalesOrderLine__c> lstSalesOrderLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
       List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        
        
        gii__SalesOrder__c so = new gii__SalesOrder__c();
        //open sales order 
        so =  new gii__SalesOrder__c(
            gii__Account__c = lstAccount[0].id ,
            gii__ScheduledDate__c = SYSTEM.today(),
            gii__OrderDate__c = SYSTEM.today(),
            gii__Warehouse__c = dcwarehouse[0].id,
            gii__TransferToWarehouse__c =dcwarehouse[1].id,
            gii__PaymentMethod__c = 'Credit Card',
            gii__OrderType__c='Transfer',
            gii__Carrier__c = lstCarrier != null && lstCarrier.size() > 0 ? lstCarrier[0].Id : null,
            gii__Released__c = false,
            //To overcome validation rule failure
            gii__ShipToStateProvince__c = 'MO',
            gii__BillingStateProvince__c = 'MO'
        );
        insert so;
        gii__TransferOrder__c to =  new gii__TransferOrder__c();
        to.gii__Account__c = lstAccount[0].id ;
        to.gii__OrderDate__c = SYSTEM.today();
        to.gii__TransferToWarehouse__c = dcwarehouse[0].id;
        to.gii__FromWarehouse__c = dcwarehouse[1].id;     //rt start
        to.gii__Carrier__c = lstCarrier[0].id;
        insert to;
        
        gii__Shipment__c shipment = new gii__Shipment__c();
        
       // shipment.gii__SalesOrder__c  =so.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        
        shipment.gii__ForwardToInvoice__c=false  ;
        shipment.gii__ShippedDate__c=system.today()  ;
        shipment.giic_loadId__c='14739864'  ;
        shipment.giic_BOL__c= '14739864';
        shipment.giic_SCAC__c= 'SAIA' ;
        //shipment.gii__ProductAmount__c=55.82  ;
        insert shipment;
        
        list<gii__Shipment__c> shippp=   [SELECT Id,Name,
                                          giic_loadId__c,giic_BOL__c,
                                          giic_SCAC__c,gii__ProductAmount__c,
                                          gii__SalesOrder__c,gii__TransferOrder__c,
                                          giic_Quantity__c,gii__Account__c,
                                          gii__Status__c, giic_statusDescription__c,
                                          giic_EstimatedDeliveryDate__c, giic_TrackingDate__c,
                                          gii__TransferOrder__r.Name
                                          FROM gii__Shipment__c
                                          where id =: shipment.id];
        
       
                      Test.startTest();
        
        giic_PLSRequestWrapper.getRequestedJson(shipment);
      
        Test.stopTest();
           }

}