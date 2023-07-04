@isTest
public class giic_FedexRequestSchemaTest {
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.getTestClassUser();
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
        
        
        
        
    }
    
    
    @isTest
    static void testPostMethod() {
        
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'test222';
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
                                          gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name
                                          from gii__Shipment__c where id =: shipment.id LIMIT 1];
        
        giic_JMSIntegrationMapping__mdt jmsIntAttr2 = new giic_JMSIntegrationMapping__mdt(
            giic_OAUTH_Endpoint__c = 'https://example.com/oauth/token',
            giic_CLIENT_KEY__c = 'testClientId',
            giic_CLIENT_SECRET__c = 'testClientSecret'
        );
        Test.startTest();
        
        //Test.setMock(HttpCalloutMock.class, new giic_ShipmentHelperMock());  
        
        giic_FedexRequestSchema.generateFedExRequestJson(shippp[0] , ''  ,jmsIntAttr2);
        
        Test.stopTest();
        
        
    }
    
    
    @isTest
    static void testPostMethod1() {
        
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
         List<gii__Warehouse__c> dcwarehouse1  = new  List<gii__Warehouse__c>();
        for( gii__Warehouse__c wc:  dcwarehouse){
            wc.gii__WareHouseCountry__c ='india';
            dcwarehouse1.add(wc);
        }
        update dcwarehouse1;
        dcwarehouse =dcwarehouse1;
        
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'test222';
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
        
        //shipment.gii__SalesOrder__c  =so.id  ;
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
                                          gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name
                                          from gii__Shipment__c where id =: shipment.id LIMIT 1];
        
        giic_JMSIntegrationMapping__mdt jmsIntAttr2 = new giic_JMSIntegrationMapping__mdt(
            giic_OAUTH_Endpoint__c = 'https://example.com/oauth/token',
            giic_CLIENT_KEY__c = 'testClientId',
            giic_CLIENT_SECRET__c = 'testClientSecret'
        );
        
        Test.startTest();
        giic_FedexRequestSchema.generateFedExRequestJson(shippp[0] , ''  ,jmsIntAttr2);
        Test.stopTest();
        
        
    }
}