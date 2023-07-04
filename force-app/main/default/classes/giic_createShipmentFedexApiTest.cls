@isTest
public class giic_createShipmentFedexApiTest {
     @testSetup static void setup() {
       // giic_Test_DataCreationUtility.getTestClassUser();
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
        //giic_Test_DataCreationUtility.insertSite();
        
        //giic_Test_DataCreationUtility.insertAssetReference();
    }
    
      @isTest
    static void testPostMethod() {
        
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
       
        try{ 
           giic_createShipmentFedexApi.createShipment(shippp[0]);
           }
        catch(exception e){
            
        }
         
        Test.stopTest();
    }
    

}