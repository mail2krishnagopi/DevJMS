@isTest
public class giic_JMSCommonUtilityTest {
    
    @testSetup 
    Public static void setup() {
        
     //giic_Test_DataCreationUtility.testSystemPolicyCreation();
         
    }
    
  
  /*  @isTest
    public static void quickShipTest(){
        
        list<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        List<gii__SalesOrderLine__c> lstSOLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
        List<gii__Warehouse__c> lstWarehouse = giic_Test_DataCreationUtility.insertWarehouse();
        
        lstSOLine[0].gii__ServiceTicket__c = lstservTicket[0].id  ;
        lstSOLine[0].gii__ServiceTicketLine__c = lstservTicketLine[0].id ;
        lstSOLine[0].gii__Status__c = 'Shipped';
        update lstSOLine;
        lstservTicketLine[0].giic_SalesOrder__c = lstSalesOrder[0].id  ;
        lstservTicketLine[0].giic_SalesOrderLine__c = lstSOLine[0].id ;
        update lstservTicketLine;
      
        
     /*   List<gii__SalesOrderLine__c> lstSOLine1 = [SELECT Id,Name,giic_Product__c,gii__SalesOrder__r.gii__Account__c,
                                                  gii__SalesOrder__r.giic_Site__c ,gii__SalesOrder__r.giic_Notes__c,
                                                  gii__Product__c,gii__Site__c, gii__UpdateAsset__c,
                                                  gii__SalesOrder__c,gii__OpenQuantity__c,gii__Status__c,
                                                  gii__SalesOrder__r.giic_Site__r.name,
                                                  gii__Product__r.giic_New_Certification_Training_Required__c,
                                                  gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c, 
                                                  gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.gii__Certification__c,
                                                  gii__Product__r.giic_Certification__c ,
                                                  gii__Product__r.gii__SerialControlled__c,
                                                  
                                                  gii__ServiceTicketLine__c
                                                  FROM gii__SalesOrderLine__c  ];


       
        List<Id> lstSOLIds = new List<Id>();
        List<gii__SalesOrderLine__c> lstSalsOrdUp = new List<gii__SalesOrderLine__c>();
        for(gii__SalesOrderLine__c cc : lstSOLine1){
         cc.gii__Product__r.gii__SerialControlled__c = true;
         cc.gii__Status__c ='Shipped';
            lstSalsOrdUp.add(cc);
             lstSOLIds.add(cc.id);
        }
         update lstSalsOrdUp;
         lstSOLine =lstSalsOrdUp;
          system.debug('lstSOLine:::T:'+lstSalsOrdUp);
         system.debug('lstSOLine:t:::'+lstSOLine.size());
        system.debug('lstSOLine:::St:'+lstSalsOrdUp[0].gii__Status__c);*/
 /*List<Id> lstSOLIds = new List<Id>();
        lstSOLIds.add(lstSOLine[0].Id);
         List<gii__InventoryReserve__c> lstIR = [Select id, gii__Status__c ,gii__ProductSerial__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__SalesOrderLine__c FROM gii__InventoryReserve__c WHERE gii__SalesOrderLine__c IN : lstSOLIds];
             system.debug('lstIR::::>>'+lstIR);
             system.debug('lstIR::::>>'+lstIR[0].gii__Status__c);
        lstIR[0].gii__Product__c =lstSOLine[0].gii__Product__c;
        update lstIR;
        
        Test.startTest();
       
        giic_JMSCommonUtility.quickShip(lstSOLIds);
        Test.stopTest();
            
    }*/
    
    @isTest public static void quickship1(){
                RecordType prodrecordType = [Select id,name,DeveloperName, SobjectType from RecordType where DeveloperName ='Equipment' and SobjectType ='Product2' limit 1];
       
   	    Product2 objpro = new Product2(Name = 'Third Party Service',
                                       IsActive = true,
                                       ProductCode = '1234567 ',
                                       Family = 'Beverage',
                                       RecordTypeId = prodrecordType.id
                                      );
        insert objpro;
        gii__WarehouseGroup__c testWareHouseGroup = New gii__WarehouseGroup__c(Name = 'Distribution Center',gii__WarehouseGroupDescription__c= 'test');
        insert testWareHouseGroup;
         gii__WarehouseGroup__c testWareHouseGroup1 = New gii__WarehouseGroup__c(Name = 'Test WGCenter',gii__WarehouseGroupDescription__c= 'test');
        insert testWareHouseGroup1;
        
        gii__Warehouse__c testWarehouse = new gii__Warehouse__c(Name = 'Test Warehouse',gii__WarehouseGroup__c = testWareHouseGroup.Id);
        insert testWarehouse; 
        gii__Warehouse__c testWarehouse2 = new gii__Warehouse__c(Name = 'Distribution Center',gii__WarehouseGroup__c = testWareHouseGroup1.Id);
        insert testWarehouse2; 
        
         gii__SystemPolicy__c   objSystemPolicy = new gii__SystemPolicy__c(Name='GII',gii__Description__c='Glovia Policies',gii__PriceBookName__c='Standard',
                                                       gii__StockUM__c='Each',
                                                       gii__AutoReleaseOrder__c=true, gii__AllowZeroUnitPrice__c=true, 
                                                       gii__Warehouse__c =testWarehouse.Id,
                                                       gii__AutoApprovePurchaseOrders__c=true);
            insert objSystemPolicy;
        
        gii__Product2Add__c testProdRef = new gii__Product2Add__c(gii__ProductReference__c = objpro.Id,gii__Service__c	=false,giic_DefaultReplenishmentWarehouse__c =testWarehouse.Id  );

        insert testProdRef;
        
        gii__ProductInventory__c testProductInventory = new gii__ProductInventory__c(
            
            gii__Product__c = testProdRef.Id,
            gii__Warehouse__c = testWarehouse.Id,
            gii__PurchaseOrderQuantity__c = 10,
            gii__WorkOrderQuantity__c = 20,
            //	gii__AvailableQuantity__c = 10,
            //gii__TotalOnOrder__c = 5,
            gii__OrderPointQuantity__c = 20,
            gii__MinimumOrderQuantity__c = 5,
            gii__OrderQuantityMultiple__c = 5
        );
        insert testProductInventory;
        
         gii__Location__c  loc  = new gii__Location__c( gii__Warehouse__c = testWarehouse.id ,gii__Sequence__c = 1);
        insert loc;
         Account objAccount = new Account();
            //objAccount.RecordTypeId = recortTypeId;
            //objAccount.OwnerId = UserInfo.getUserId();
            objAccount.Name = 'JMS - E & S - US Account';
             objAccount.JMS_Skip_Standard_Account_Duplicate_Rule__c=false;
            objAccount.BillingStreet = '8 Clement Drive';
            objAccount.BillingCountry = 'United States';
            objAccount.BillingState = 'Ohio';
            objAccount.BillingPostalCode = '08083';
            //objAccount.BillingState = 'New Jersey';
            objAccount.BillingCity = 'Somerdale'; 
            // objAccount.BillingStreet = '8 Clement Drive';  
            objAccount.ShippingStreet = '8 Clement Drive';
            objAccount.ShippingCountry = 'United States';
            objAccount.ShippingPostalCode = '08083';
            //objAccount.ShippingState = 'New Jersey';
            objAccount.ShippingCity = 'Somerdale'; 
            objAccount.ShippingState = 'Ohio';
            objAccount.ShippingStreet = '8 Clement Drive'; 
        insert objAccount;
 
        
         gii__SalesOrder__c so = new gii__SalesOrder__c();
        //open sales order 
        so =  new gii__SalesOrder__c(
            gii__Account__c = objAccount.Id,
            gii__ScheduledDate__c = SYSTEM.today(),
            gii__OrderDate__c = SYSTEM.today(),
            gii__Warehouse__c = testwarehouse.id,
            gii__TransferToWarehouse__c =testWarehouse2.id,
            gii__PaymentMethod__c = 'Credit Card',
            gii__OrderType__c='Transfer',
            gii__Released__c = false,
            //To overcome validation rule failure
            gii__ShipToStateProvince__c = 'MO',
            gii__BillingStateProvince__c = 'MO'
        );
        
        insert so;
        List<gii__ServiceTicket__c> lstservTicket = new List<gii__ServiceTicket__c>();
          gii__ServiceTicket__c  servTicket = new gii__ServiceTicket__c();
        servTicket.gii__Country__c='United States';
        servTicket.gii__Account__c=objAccount.id;
        servTicket.gii__ServiceDueDate__c = system.today().addDays(3);
        lstservTicket.add(servTicket);
        insert lstservTicket ;
        gii__FieldServiceEngineer__c  fse = new gii__FieldServiceEngineer__c();
        fse.gii__Warehouse__c   =testwarehouse.id;
        fse.gii__Supplier__c =objAccount.id ;
        
        insert fse;
        List<gii__ServiceTicketLine__c> lstservTicketLine = new List<gii__ServiceTicketLine__c>(); 
      
      
        
       gii__SalesOrderLine__c  soline = new gii__SalesOrderLine__c(gii__SalesOrder__c = so.id, giic_TransferOrderQty__c=1 ,
                                                    gii__ReservedQuantity__c=1 ,
                                                    gii__OrderQuantity__c = 2.0, gii__Product__c = testProdRef.Id , 
                                                    gii__UnitPrice__c = 2,gii__Status__c = 'Shipped');
        
        insert soline;
          for(Integer i = 0 ; i< lstservTicket.size() ; i++){
            gii__ServiceTicketLine__c servTicketLine = new gii__ServiceTicketLine__c();
            servTicketLine.gii__Quantity__c = 1;
            servTicketLine.gii__ServiceTicket__c = lstservTicket[0].Id;
            servTicketLine.gii__Product__c = testProdRef.Id;
            servTicketLine.giic_SalesOrderLine__c = soline.Id;
            servTicketLine.gii__FieldServiceEngineer__c =fse.id;
            lstservTicketLine.add(servTicketLine);
        }
        insert lstservTicketLine ;
         List<Id> lstSOLIds = new List<Id>();
        lstSOLIds.add(soline.Id);
         List<gii__InventoryReserve__c> lstIR = [Select id, gii__Status__c ,gii__ProductSerial__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__SalesOrderLine__c FROM gii__InventoryReserve__c WHERE gii__SalesOrderLine__c IN : lstSOLIds];
             system.debug('lstIR::::>>'+lstIR);
             system.debug('lstIR::::>>'+lstIR[0].gii__Status__c);
        lstIR[0].gii__Product__c =soline.gii__Product__c;
        update lstIR;
        
        Test.startTest();
       
        giic_JMSCommonUtility.quickShip(lstSOLIds);
        Test.stopTest();

    }
    /*
    @isTest
    public static void quickShipTestV1(){
        
        List<gii__Product2Add__c> product = giic_Test_DataCreationUtility.insertProduct();
        update product;
        List<gii__SalesOrder__c>lstSalesOrder=new List<gii__SalesOrder__c>();
        List<gii__SalesOrderLine__c> lstSol = new List<gii__SalesOrderLine__c>();
        lstSalesOrder=giic_Test_DataCreationUtility.insertSalesOrder() ;
        lstSol= giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder[0].id,product[0].id);
        system.debug('lstSol****'+lstSol);
        system.debug('lstSalesOrder****'+lstSalesOrder);
        lstSol[0].giic_Released__c=true;
        lstSol[0].gii__Status__c = 'Shipped';
        
        update lstSol;
        system.debug('lstSalesOrder****'+lstSol[0]);
        gii__ProductSerial__c pSerial =new gii__ProductSerial__c();
        
        List<Id>soliId=new List<Id>();
        
        for(gii__SalesOrderLine__c sol : lstSol){
            if(sol.gii__Status__c== 'Shipped'){
            soliId.add(sol.id);
            }
            
        }
        Test.startTest();
        giic_JMSCommonUtility.quickShip(soliId);
        Test.stopTest();
        pSerial.gii__SalesOrder__c= lstSalesOrder[0].id;
        pSerial.gii__SalesOrderLine__c = soliId[0];
        insert pSerial;
        List<gii__ProductInventory__c> proInv = giic_Test_DataCreationUtility.insertProductInventory();
        
        gii__InventoryReserve__c obj =new gii__InventoryReserve__c();
        obj.gii__Product__c = product[0].id;	
        obj.gii__ProductSerial__c=pSerial.id;
        obj.gii__SalesOrderLine__c=soliId[0];
        obj.gii__ProductInventorySequence__c = proInv[0].id;
        insert obj;
        
        
        system.debug('soliId****'+soliId);
        List<gii__SalesOrderLine__c> lstShippedSOLine = [Select Id, Name, gii__SalesOrder__c,gii__Site__c, gii__Product__c, gii__Product__r.Name, gii__OrderQuantity__c, gii__SalesOrder__r.gii__Account__c
                                                         
                                                         FROM gii__SalesOrderLine__c WHERE gii__Status__c = 'Shipped'];
        system.debug('lstShippedSOLine****'+lstShippedSOLine);
*/
        
    }