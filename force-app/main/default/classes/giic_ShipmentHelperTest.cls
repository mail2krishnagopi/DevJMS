@isTest
public class giic_ShipmentHelperTest {
    
    @testSetup static void setup() {
       // giic_Test_DataCreationUtility.getTestClassUser();
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
        //giic_Test_DataCreationUtility.insertSite();
        
        //giic_Test_DataCreationUtility.insertAssetReference();
    }
    
    @isTest
    static void testPostMethod() {
        
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'PLS';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        gii__Carrier__c carrierTest = [Select id,Name,gii__Description__c from gii__Carrier__c where id=:oCarr1.Id];
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
            gii__Carrier__c = oCarr1.Id ,
            gii__Released__c = false,
            //To overcome validation rule failure
            gii__ShipToStateProvince__c = 'MO',
            gii__BillingStateProvince__c = 'MO'
        );
        insert so;
         
        so.gii__PaymentMethod__c = 'Debit Card';
        update So;
        gii__SalesOrder__c soNew = [select id,name,gii__OrderType__c from gii__SalesOrder__c where id=:so.id];
        
         system.debug('soname'+soNew.Name);
         
         
        gii__TransferOrder__c to =  new gii__TransferOrder__c();
        to.gii__Account__c = lstAccount[0].id ;
        to.gii__OrderDate__c = SYSTEM.today();
        to.gii__TransferToWarehouse__c = dcwarehouse[0].id;
        to.gii__FromWarehouse__c = dcwarehouse[1].id;     //rt start
        to.gii__Carrier__c = oCarr1.id;
        insert to;
        
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        shipment.gii__SalesOrder__c  =soNew.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        shipment.giic_ShipmentCarrier__c = carrierTest.id;        
        shipment.gii__ForwardToInvoice__c=false  ;
        shipment.gii__ShippedDate__c=system.today()  ;
        shipment.giic_loadId__c='14739864'  ;
        shipment.giic_BOL__c= '14739864';
        shipment.giic_SCAC__c= 'SAIA' ;
       shipment.giic_Integration_Status__c = 'PLS Shipment API completed Successfully';
        //shipment.gii__ProductAmount__c=55.82  ;
        Test.startTest();
         insert shipment;
        
      gii__Shipment__c  shipmentnew = [select id,gii__Account__c,gii__TransferOrder__c,gii__TransferOrder__r.Name,giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c,gii__SalesOrder__c,gii__SalesOrder__r.Name,giic_Integration_Status__c from gii__Shipment__c where id=:shipment.id];
       
        try{ 
           
            system.debug('shipment'+shipmentnew.gii__SalesOrder__r.Name);
            giic_ShipmentHelper.fetchData(shipmentnew.id);}
        catch(exception e){
            
        }
         
        
       
/* giic_ShipmentHelper.processFedexShipment(shipment);
giic_ShipmentHelper.processPLSShipment(shipment);
giic_ShipmentHelper.validateSalesOrderFields(shipment);
giic_ShipmentHelper.checkMandatorySalesOrderFieldsforFedex(shipment);
giic_ShipmentHelper.checkMandatoryTransferOrderFieldsforFedex(shipment);
giic_ShipmentHelper.validateTransferOrderFields(shipment);
giic_ShipmentHelper.updateShipmentRecord(shipment , 123 ,'test');
giic_ShipmentHelper.updateErrorRecord(shipment.id , 'fail');
*/
     /*   oCarr1.Name = 'FedEx';
        update oCarr1;
        giic_ShipmentHelper.fetchData(shipment.id);*/
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
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'PLS';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        gii__Carrier__c carrierTest = [Select id,Name,gii__Description__c from gii__Carrier__c where id=:oCarr1.Id]; 
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
         gii__SalesOrder__c soNew = [select id,name,gii__OrderType__c from gii__SalesOrder__c where id=:so.id];
        
         system.debug('soname'+soNew.Name);
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        shipment.gii__SalesOrder__c  =soNew.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        shipment.giic_ShipmentCarrier__c = carriertest.id;   
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
                                          giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c
                                          FROM gii__Shipment__c
                                          where id =: shipment.id];
        
        
        Test.startTest();
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.Name);
        try{ giic_ShipmentHelper.fetchData(shippp[0].id);}
        catch(exception e){
            system.debug(e);
        }
        
        // giic_ShipmentHelper.sendShipmentDetails(shipment);
/*giic_ShipmentHelper.processFedexShipment(shipment);
giic_ShipmentHelper.processPLSShipment(shipment);*/
        try{
            giic_ShipmentHelper.validateSalesOrderFields(shipment);}
        catch(exception e){
            system.debug(e);
        }
        try{
            giic_ShipmentHelper.checkMandatorySalesOrderFieldsforFedex(shipment);}
             catch(exception e){
            system.debug(e);
        }
            try{
                giic_ShipmentHelper.checkMandatoryTransferOrderFieldsforFedex(shipment);
                    }
         catch(exception e){
            system.debug(e);
        }
      try{    
          giic_ShipmentHelper.validateTransferOrderFields(shipment);}
         catch(exception e){
            system.debug(e);
        }
        
        try{
            giic_ShipmentHelper.updateShipmentRecord(shippp[0] , 123 ,'true');}
         catch(exception e){
            system.debug(e);
        }
        try{
        
            giic_ShipmentHelper.updateErrorRecord(shipment.id , 'fail');}
         catch(exception e){
            system.debug(e);
        }

         /*   oCarr1.Name = 'FedEx';
        update oCarr1;
        giic_ShipmentHelper.fetchData(shipment.id);*/
        Test.stopTest();
    }
    @isTest
    static void testPostMethod1_2() {
        // Create a new instance of the class that contains the POST method
        //giic_BookingConfirmation myClass = new giic_BookingConfirmation();
        
        // List<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        //List<gii__SalesOrderLine__c> lstSalesOrderLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'test';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        gii__Carrier__c carrierTest = [Select id,Name,gii__Description__c from gii__Carrier__c where id=:oCarr1.Id]; 
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
         gii__SalesOrder__c soNew = [select id,name,gii__OrderType__c from gii__SalesOrder__c where id=:so.id];
        
         system.debug('soname'+soNew.Name);
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        shipment.gii__SalesOrder__c  =soNew.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        shipment.giic_ShipmentCarrier__c = carriertest.id;   
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
                                          giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c
                                          FROM gii__Shipment__c
                                          where id =: shipment.id];
        
        
        Test.startTest();
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.Name);
        try{ giic_ShipmentHelper.fetchData(shippp[0].id);}
        catch(exception e){
            system.debug(e);
        }
  
        Test.stopTest();
    }
     @isTest
   static void testPostMethod1_3() {
        // Create a new instance of the class that contains the POST method
        //giic_BookingConfirmation myClass = new giic_BookingConfirmation();
        
        // List<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        //List<gii__SalesOrderLine__c> lstSalesOrderLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        //oCarr1.Name = '';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        gii__Carrier__c carrierTest = [Select id,Name,gii__Description__c from gii__Carrier__c where id=:oCarr1.Id]; 
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
         gii__SalesOrder__c soNew = [select id,name,gii__OrderType__c from gii__SalesOrder__c where id=:so.id];
        
         system.debug('soname'+soNew.Name);
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        shipment.gii__SalesOrder__c  =soNew.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        //shipment.giic_ShipmentCarrier__c = carriertest.id;   
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
                                          giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c
                                          FROM gii__Shipment__c
                                          where id =: shipment.id];
        
        
        Test.startTest();
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.Name);
        try{ giic_ShipmentHelper.fetchData(shippp[0].id);}
        catch(exception e){
            system.debug(e);
        }
  
        Test.stopTest();
    }
      @isTest
    static void testPostMethod2_1() {
         List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'PLS';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        gii__Carrier__c carrierTest = [Select id,Name,gii__Description__c from gii__Carrier__c where id=:oCarr1.Id]; 
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
         gii__SalesOrder__c soNew = [select id,name,gii__OrderType__c from gii__SalesOrder__c where id=:so.id];
        
         system.debug('soname'+soNew.Name);
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        //shipment.gii__SalesOrder__c  =soNew.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        shipment.giic_ShipmentCarrier__c = carriertest.id;   
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
                                          giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c
                                          FROM gii__Shipment__c
                                          where id =: shipment.id];
        
        
        Test.startTest();
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.Name);
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.gii__Description__c);
        try{ giic_ShipmentHelper.fetchData(shippp[0].id);}
        catch(exception e){
            system.debug(e);
        }
        
       
        Test.stopTest();
    }
    @isTest
    static void testPostMethod2_2() {
         List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'test';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        gii__Carrier__c carrierTest = [Select id,Name,gii__Description__c from gii__Carrier__c where id=:oCarr1.Id]; 
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
         gii__SalesOrder__c soNew = [select id,name,gii__OrderType__c from gii__SalesOrder__c where id=:so.id];
        
         system.debug('soname'+soNew.Name);
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        //shipment.gii__SalesOrder__c  =soNew.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        shipment.giic_ShipmentCarrier__c = carriertest.id;   
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
                                          giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c
                                          FROM gii__Shipment__c
                                          where id =: shipment.id];
        
        
        Test.startTest();
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.Name);
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.gii__Description__c);
        try{ giic_ShipmentHelper.fetchData(shippp[0].id);}
        catch(exception e){
            system.debug(e);
        }
        
       
        Test.stopTest();
    }
    @isTest
    static void testPostMethod2_3() {
         List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        //oCarr1.Name = 'test';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        gii__Carrier__c carrierTest = [Select id,Name,gii__Description__c from gii__Carrier__c where id=:oCarr1.Id]; 
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
         gii__SalesOrder__c soNew = [select id,name,gii__OrderType__c from gii__SalesOrder__c where id=:so.id];
        
         system.debug('soname'+soNew.Name);
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        //shipment.gii__SalesOrder__c  =soNew.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        //shipment.giic_ShipmentCarrier__c = carriertest.id;   
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
                                          giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c
                                          FROM gii__Shipment__c
                                          where id =: shipment.id];
        
        
        Test.startTest();
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.Name);
        system.debug('shipment'+shippp[0].giic_ShipmentCarrier__r.gii__Description__c);
        try{ giic_ShipmentHelper.fetchData(shippp[0].id);}
        catch(exception e){
            system.debug(e);
        }
        
       
        Test.stopTest();
    }
  
    
    
    @isTest
    static void testPostMethod3() {
        
      //   test.StartTest();
       List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'PLS';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        
        insert oCarr1;
        
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
        
           gii__Carrier__c testShipCarrier = new gii__Carrier__c();
        testShipCarrier.Name = 'PLS';
            testShipCarrier.gii__Description__c = 'FedEx';
        insert testShipCarrier;
        
        
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        shipment.gii__SalesOrder__c  =so.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        shipment.giic_ShipmentCarrier__c = testShipCarrier.id;        
        shipment.gii__ForwardToInvoice__c=false  ;
        shipment.gii__ShippedDate__c=system.today()  ;
        shipment.giic_loadId__c='14739864'  ;
        shipment.giic_BOL__c= '14739864';
        shipment.giic_SCAC__c= 'SAIA' ;
        shipment.giic_Weight__c = 1.0;
        //shipment.gii__ProductAmount__c=55.82  ;
        insert shipment;
        //
         list<gii__Shipment__c> shippp=   [SELECT id,Name,gii__SalesOrder__r.Name,gii__TransferOrder__r.Name,gii__SalesOrder__c,
                        giic_Integration_Status__c,
                        gii__SalesOrder__r.giic_Site__r.Name,
                        gii__SalesOrder__r.giic_Site__c,
                        gii__SalesOrder__r.giic_Site__r.gii__Street__c,
                        gii__SalesOrder__r.giic_Site__r.gii__City__c,
                        gii__SalesOrder__r.giic_Site__r.gii__StateProvince__c,
                        gii__SalesOrder__r.giic_Site__r.gii__Country__c,
                        gii__SalesOrder__r.giic_Site__r.gii__ZipPostalCode__c, 
                        gii__SalesOrder__r.gii__CustomerPONumber__c,
                        gii__ShippedDate__c,gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Account.name,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Phone,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Email,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name,gii__SalesOrder__r.gii__Warehouse__r.giic_Accessorial_Types__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.giic_Accessorial_Types__c,
                        gii__SalesOrder__r.gii__Warehouse__r.Name,gii__SalesOrder__r.gii__Warehouse__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCity__c, 
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCountry__c,  
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStateProvince__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStreet__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name,
                        gic_PackageType__c,giic_CommodityClass__c,giic_Quantity__c,giic_ProductDescription__c,
                        giic_Weight__c,giic_Height__c,giic_Width__c,giic_Length__c,
                        giic_Hazmat__c,giic_Pickup_Type__c,
                        gii__SalesOrder__r.gii__Carrier__r.Name,gii__SalesOrder__r.gii__Carrier__r.gii__Description__c,giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c,
                        gii__SalesOrder__r.gii__ShipToStreet__c,gii__SalesOrder__r.gii__ShipToCity__c,
                        gii__SalesOrder__r.gii__ShipToStateProvince__c,gii__SalesOrder__r.gii__ShipToCountry__c,
                        gii__SalesOrder__r.gii__ShipToZipPostalCode__c,gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCity__c,
                        gii__TransferOrder__r.gii__Carrier__r.Name, gii__TransferOrder__r.gii__Carrier__r.gii__Description__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.Name,gii__TransferOrder__r.gii__TransferToWarehouse__r.Name,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCountry__c, 
                        gii__TransferOrder__r.gii__TransferToWarehouse__c, gii__TransferOrder__r.gii__FromWarehouse__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStateProvince__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStreet__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCity__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStateProvince__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStreet__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name,giic_loadId__c
                                           from gii__Shipment__c];//  WHERE id =: shipment.id LIMIT 1];
        
        
     
        
         
        //test.stopTest();
        JMS_Integration_Setting__c jmsIntAttr = new JMS_Integration_Setting__c(
            giic_PLSOAUTHEndpoint__c  = 'ttps://ltl.uat.plsthree.pro/restful/api/shipment/book',  
            giic_PLSCLIENTKEY__c = 'testClientId',
            giic_PLSCLIENTSECRET__c = 'testClientSecret',
            giic_PLSUSERNAME__c ='1234',
            giic_PLSPASSWORD__c='1234',
            giic_PLSEndpoint_URL__c = 'ttps://ltl.uat.plsthree.pro/restful/api/shipment/book'
        );
        insert jmsIntAttr;
        JMS_Integration_Setting__c jmsIntAttr1 = JMS_Integration_Setting__c.getInstance();        

        system.debug('11>>'+jmsIntAttr);
        system.debug('11>>1 '+jmsIntAttr.giic_PLSEndpoint_URL__c);
        system.debug('222>>'+jmsIntAttr1);
         system.debug('222>>2 '+jmsIntAttr1.giic_PLSEndpoint_URL__c);
         
        giic_JMSIntegrationMapping__mdt jmsIntAttr2 = new giic_JMSIntegrationMapping__mdt(
            giic_OAUTH_Endpoint__c = 'https://example.com/oauth/token',
            giic_CLIENT_KEY__c = 'testClientId',
            giic_CLIENT_SECRET__c = 'testClientSecret'
        );
        system.debug('2333>>'+jmsIntAttr2);
      // Set up mock HTTP response
        //Test.setMock(HttpCalloutMock.class, new giic_ShipmentHelperMock());
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new giic_ShipmentHelperMock());  
       
        try{ giic_ShipmentHelper.sendShipmentDetails(shippp[0]);
           }
        catch(exception e){
            
        }
         
        Test.stopTest();
    }
    
     @isTest
    static void testPostMethod3_1() {
        
      //   test.StartTest();
       List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'PLS';
        oCarr1.gii__Description__c = 'FedEx';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        
        insert oCarr1;
        
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
        
           gii__Carrier__c testShipCarrier = new gii__Carrier__c();
        testShipCarrier.Name = 'PLS';
            testShipCarrier.gii__Description__c = 'FedEx';
        insert testShipCarrier;
        
        
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        shipment.gii__SalesOrder__c  =so.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        shipment.giic_ShipmentCarrier__c = testShipCarrier.id;        
        shipment.gii__ForwardToInvoice__c=false  ;
        shipment.gii__ShippedDate__c=system.today()  ;
        shipment.giic_loadId__c='14739864'  ;
        shipment.giic_BOL__c= '14739864';
        shipment.giic_SCAC__c= 'SAIA' ;
       // shipment.giic_Weight__c = 1.0;
        //shipment.gii__ProductAmount__c=55.82  ;
        insert shipment;
        //
         list<gii__Shipment__c> shippp=   [SELECT id,Name,gii__SalesOrder__r.Name,gii__TransferOrder__r.Name,gii__SalesOrder__c,
                        giic_Integration_Status__c,
                        gii__SalesOrder__r.giic_Site__r.Name,
                        gii__SalesOrder__r.giic_Site__c,
                        gii__SalesOrder__r.giic_Site__r.gii__Street__c,
                        gii__SalesOrder__r.giic_Site__r.gii__City__c,
                        gii__SalesOrder__r.giic_Site__r.gii__StateProvince__c,
                        gii__SalesOrder__r.giic_Site__r.gii__Country__c,
                        gii__SalesOrder__r.giic_Site__r.gii__ZipPostalCode__c, 
                        gii__SalesOrder__r.gii__CustomerPONumber__c,
                        gii__ShippedDate__c,gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Account.name,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Phone,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Email,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name,gii__SalesOrder__r.gii__Warehouse__r.giic_Accessorial_Types__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.giic_Accessorial_Types__c,
                        gii__SalesOrder__r.gii__Warehouse__r.Name,gii__SalesOrder__r.gii__Warehouse__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCity__c, 
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCountry__c,  
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStateProvince__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStreet__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name,
                        gic_PackageType__c,giic_CommodityClass__c,giic_Quantity__c,giic_ProductDescription__c,
                        giic_Weight__c,giic_Height__c,giic_Width__c,giic_Length__c,
                        giic_Hazmat__c,giic_Pickup_Type__c,
                        gii__SalesOrder__r.gii__Carrier__r.Name,gii__SalesOrder__r.gii__Carrier__r.gii__Description__c,giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c,
                        gii__SalesOrder__r.gii__ShipToStreet__c,gii__SalesOrder__r.gii__ShipToCity__c,
                        gii__SalesOrder__r.gii__ShipToStateProvince__c,gii__SalesOrder__r.gii__ShipToCountry__c,
                        gii__SalesOrder__r.gii__ShipToZipPostalCode__c,gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCity__c,
                        gii__TransferOrder__r.gii__Carrier__r.Name, gii__TransferOrder__r.gii__Carrier__r.gii__Description__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.Name,gii__TransferOrder__r.gii__TransferToWarehouse__r.Name,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCountry__c, 
                        gii__TransferOrder__r.gii__TransferToWarehouse__c, gii__TransferOrder__r.gii__FromWarehouse__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStateProvince__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStreet__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCity__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStateProvince__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStreet__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name,giic_loadId__c
                                           from gii__Shipment__c];//  WHERE id =: shipment.id LIMIT 1];
        
        
     
        
         
        //test.stopTest();
        JMS_Integration_Setting__c jmsIntAttr = new JMS_Integration_Setting__c(
            giic_PLSOAUTHEndpoint__c  = 'ttps://ltl.uat.plsthree.pro/restful/api/shipment/book',  
            giic_PLSCLIENTKEY__c = 'testClientId',
            giic_PLSCLIENTSECRET__c = 'testClientSecret',
            giic_PLSUSERNAME__c ='1234',
            giic_PLSPASSWORD__c='1234',
            giic_PLSEndpoint_URL__c = 'ttps://ltl.uat.plsthree.pro/restful/api/shipment/book'
        );
        insert jmsIntAttr;
        JMS_Integration_Setting__c jmsIntAttr1 = JMS_Integration_Setting__c.getInstance();        

        system.debug('11>>'+jmsIntAttr);
        system.debug('11>>1 '+jmsIntAttr.giic_PLSEndpoint_URL__c);
        system.debug('222>>'+jmsIntAttr1);
         system.debug('222>>2 '+jmsIntAttr1.giic_PLSEndpoint_URL__c);
         
        giic_JMSIntegrationMapping__mdt jmsIntAttr2 = new giic_JMSIntegrationMapping__mdt(
            giic_OAUTH_Endpoint__c = 'https://example.com/oauth/token',
            giic_CLIENT_KEY__c = 'testClientId',
            giic_CLIENT_SECRET__c = 'testClientSecret'
        );
        system.debug('2333>>'+jmsIntAttr2);
      // Set up mock HTTP response
        //Test.setMock(HttpCalloutMock.class, new giic_ShipmentHelperMock());
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new giic_ShipmentHelperMock());  
       
        try{ giic_ShipmentHelper.sendShipmentDetails(shippp[0]);
           }
        catch(exception e){
            
        }
         
        Test.stopTest();
    }
    
    
     @isTest
    static void testPostMethod4() {
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        // List<gii__Carrier__c> lstCarrier =  giic_Test_DataCreationUtility.createCarrier();
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'PLS';
        oCarr1.gii__Description__c = 'test111';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        
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
            gii__Carrier__c = oCarr1.Id ,
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
        to.gii__Carrier__c = oCarr1.id;
        insert to;
        
        gii__Shipment__c shipment = new gii__Shipment__c();
        
        shipment.gii__SalesOrder__c  =so.id  ;
        shipment.gii__TransferOrder__c=to.id ;
        shipment.gii__Account__c=lstAccount[0].id ;
        shipment.giic_ShipmentCarrier__c = oCarr1.id;        
        shipment.gii__ForwardToInvoice__c=false  ;
        shipment.gii__ShippedDate__c=system.today()  ;
        shipment.giic_loadId__c='14739864'  ;
        shipment.giic_BOL__c= '14739864';
        shipment.giic_SCAC__c= 'SAIA' ;
        //shipment.gii__ProductAmount__c=55.82  ;
        insert shipment;
        system.debug('Load id'+shipment.giic_loadId__c);
        String msg='{"soNum":"SO-20221111-000007","loadId":"14739864",shipmentNo":"SHP-20221116-000003","poNum":"PO4252023","pickupDate":"2022-11-16","originAddress":{"stateCode":"NJ","postalCode":"08512","name":"E & S - JMS CRANBURY NJ","countryCode":"USA","contactPhone":"1234567890","contactName":"Adam Kamerer","city":"Cranbury","addressCode":"a5c3C0000003bXrQAI","address1":"20 Haypress Rd Ste 322"},"materials":[{"width":4,"weightUnit":"LBS","weight":4,"quantity":1,"productDescription":"This is for Shipment","packagingType":"CAS","length":3,"height":3,"hazmat":false,"dimensionUnit":"INCH","commodityClass":"50"}],"destinationAddress":{"stateCode":"FL","postalCode":"33467","name":"PALOMINO GARDENS","countryCode":"USA","contactPhone":"1234567890","contactName":"Adam Kamerer","city":"Lake Worth","addressCode":"a4i3C000000YSAlQAO","address1":"9885 Palomio Dr"},"accessorialTypes":["REP"]}';
        Test.startTest();
        try{giic_ShipmentHelper.updateShipmentRecord(shipment , 200 ,msg);}
        catch(exception e){}
        giic_ShipmentHelper.updateErrorRecord(shipment.id , 'errors":tjis is big ssye');
        
        Test.stopTest();
    }
    
}