@IsTest
private class giic_SalesOrderLineTriggerHandlerTest {
@IsTest
    static void testupdateProdInv(){
        //Create test Data
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
        
       gii__SalesOrderLine__c  soline = new gii__SalesOrderLine__c(gii__SalesOrder__c = so.id, giic_TransferOrderQty__c=1 ,
                                                    gii__ReservedQuantity__c=1 ,
                                                    gii__Warehouse__c = testwarehouse.id, gii__ProductInventory__c = testProductInventory.Id,
                                                    gii__ScheduledDate__c = system.today().adddays(366),
                                                    gii__OrderQuantity__c = 2.0, gii__Product__c = testProdRef.Id , 
                                                    gii__UnitPrice__c = 2);
        
        insert soline;
         gii__SalesOrderLine__c  soline1 = new gii__SalesOrderLine__c(gii__SalesOrder__c = so.id, giic_TransferOrderQty__c=1 ,
                                                    gii__ReservedQuantity__c=1 ,
                                                    gii__Warehouse__c = testwarehouse.id, gii__ProductInventory__c = testProductInventory.Id,
                                                    gii__ScheduledDate__c = system.today().adddays(366),
                                                    gii__OrderQuantity__c = 3.0, gii__Product__c = testProdRef.Id , 
                                                    gii__UnitPrice__c = 2);
        
        insert soline1;
         gii__SalesOrderLine__c  soline2 = new gii__SalesOrderLine__c(gii__SalesOrder__c = so.id, giic_TransferOrderQty__c=1 ,
                                                    gii__ReservedQuantity__c=1 ,
                                                    gii__Warehouse__c = testwarehouse.id, gii__ProductInventory__c = testProductInventory.Id,
                                                    gii__ScheduledDate__c = system.today().adddays(366),
                                                    gii__OrderQuantity__c = 4.0, gii__Product__c = testProdRef.Id , 
                                                    gii__UnitPrice__c = 2);
        
        insert soline2;
        List<gii__SalesOrderLine__c> lstSalesOrderLine = new List<gii__SalesOrderLine__c>();
        lstSalesOrderLine.add(soline);
        /*list<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();              
        
        list<gii__SalesOrderLine__c> lstSalesOrderLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);*/
        
        giic_SalesOrderLineTriggerHandler.updateProdInv(lstSalesOrderLine);
        
        
    } 
    

}