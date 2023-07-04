@IsTest
private class giic_DemandPlanningForWarehouseTest {
    @IsTest
    static void testBatchExecution() {
        // Create test data
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
         gii__Warehouse__c testWarehouse1 = new gii__Warehouse__c(Name = 'Test Warehouse1',gii__WarehouseGroup__c = testWareHouseGroup1.Id);
        insert testWarehouse1; 
         gii__Warehouse__c testWarehouse2 = new gii__Warehouse__c(Name = 'Distribution Center',gii__WarehouseGroup__c = testWareHouseGroup1.Id);
        insert testWarehouse2; 
     gii__SystemPolicy__c   objSystemPolicy = new gii__SystemPolicy__c(Name='GII',gii__Description__c='Glovia Policies',gii__PriceBookName__c='Standard',
                                                       gii__StockUM__c='Each',
                                                       gii__AutoReleaseOrder__c=true, gii__AllowZeroUnitPrice__c=true, 
                                                       gii__Warehouse__c =testWarehouse1.Id,
                                                       gii__AutoApprovePurchaseOrders__c=true);
            insert objSystemPolicy;
        
        gii__Product2Add__c testProdRef = new gii__Product2Add__c(gii__ProductReference__c = objpro.Id,gii__Service__c	=false,giic_DefaultReplenishmentWarehouse__c =testWarehouse2.Id  );

        insert testProdRef;
      
       //giic_Test_DataCreationUtility.insertProductInventory();
       //gii__InventoryReserve__c
           	
        
        gii__ProductInventory__c testProductInventory = new gii__ProductInventory__c(
            
            gii__Product__c = testProdRef.Id,
            gii__Warehouse__c = testWarehouse1.Id,
            gii__PurchaseOrderQuantity__c = 10,
            gii__WorkOrderQuantity__c = 20,
            //	gii__AvailableQuantity__c = 10,
            //gii__TotalOnOrder__c = 5,
            gii__OrderPointQuantity__c = 20,
            gii__MinimumOrderQuantity__c = 5,
            gii__OrderQuantityMultiple__c = 5
        );
        insert testProductInventory;
         gii__Location__c  loc  = new gii__Location__c( gii__Warehouse__c = testWarehouse1.id ,gii__Sequence__c = 1);
        insert loc;
         gii__ProductInventorybyLocation__c testProdInvenByLoc =  new gii__ProductInventorybyLocation__c(

             gii__Location__c = loc.Id ,
             gii__ProductInventory__c=testProductInventory.id,gii__Product__c=testProductInventory.gii__Product__c,
             gii__Warehouse__c=testWarehouse1.Id);
        
        insert testProdInvenByLoc;
      gii__ProductInventoryQuantityDetail__c testProdInvenQuanDetail =  new  gii__ProductInventoryQuantityDetail__c(
         gii__ProductInventory__c=testProductInventory.Id,
          gii__ProductInventorybyLocation__c=testProdInvenByLoc.id,
         gii__Product__c=testProductInventory.gii__Product__c,
          gii__Warehouse__c=testWarehouse1.Id,
          gii__Location__c= loc.Id,
          gii__OnHandQuantity__c =10000,
          gii__ReservedQuantity__c = 500,
          gii__SupplyReserved__c	=100,
          gii__BlockedQuantity__c	= 200,
          gii__LotRestricted__c = true
      );   
        
        insert testProdInvenQuanDetail;

 
         gii__InventoryReserve__c inv = new gii__InventoryReserve__c();
        //inv.gii__SalesOrderLine__c=soLineToInsert[0].id;
        inv.gii__ProductInventorySequence__c =testProductInventory.id;
        inv.gii__BackOrderQuantity__c = 10;
        inv.gii__SellingUMBackOrderQuantity__c = 20;
        inv.gii__NonStockQuantity__c = 6;
        inv.gii__ReserveQuantity__c	 =10;

        inv.gii__Product__c =testProductInventory.gii__Product__c;
        insert inv;
      
//        String accName = Label.giic_JMS_E_S_US_Account;    
       // Account testAccount = new Account(name = 'giic_JMS_E_S_US_Account');
       // insert testAccount;
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
 
        // Initiate and execute the batch
        giic_DemandPlanningForWarehouse batch = new giic_DemandPlanningForWarehouse();
        Test.startTest();
        Database.executeBatch(batch);
      
        Test.stopTest();
        try{
            giic_DemandPlanningForWarehouse.gettoqntity( testProductInventory, 20000);}
        catch(exception e){
            system.debug(e);
        }
       gii__TransferOrder__c testTransferOrder = new gii__TransferOrder__c	(gii__FromWarehouse__c	= testWarehouse.Id,gii__TransferToWarehouse__c = testWarehouse1.iD  );
       // insert testTransferOrder;
        // Verify the results
       /* List<gii__TransferOrder__c> transferOrders = [
            SELECT Id, gii__TransferToWarehouse__c, gii__FromWarehouse__c
            FROM gii__TransferOrder__c
        ];
        System.assertEquals(1, transferOrders.size());

        List<gii__TransferOrderLine__c> transferOrderLines = [
            SELECT Id, gii__TransferOrder__c, gii__Product__c, gii__Quantity__c
            FROM gii__TransferOrderLine__c
        ];
        System.assertEquals(1, transferOrderLines.size());*/
    }

    @IsTest
    static void testSchedulableExecution() {
        // Enqueue the schedulable class
        Test.startTest();
        String cronExp = '0 0 0 ? * * *'; // Define your desired cron expression
        giic_DemandPlanningForWarehouse scheduler = new giic_DemandPlanningForWarehouse();
        System.schedule('Test Schedule', cronExp, scheduler);
        Test.stopTest();

        // Verify that the schedulable class is scheduled
        List<CronTrigger> cronTriggers = [
            SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'Create TO & TOL Batch'
        ];
        System.assertEquals(1, cronTriggers.size());
    }
}