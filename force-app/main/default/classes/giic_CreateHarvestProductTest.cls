@isTest
public class giic_CreateHarvestProductTest {
@testSetup static void setup() {
       giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    @isTest static void testMethodRetrieveProductData() {
        
         List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
        List<gii__Product2Add__c> prodList = [Select Id, Name, gii__ProductCode__c,
                                              gii__SerialControlled__c, gii__LotControlled__c 
                                              from gii__Product2Add__c 
                                              Where id =:lstProd[0].id];
        
        test.startTest();
        giic_CreateHarvestProduct.retrieveProductData(prodList[0].name);
         
        test.stopTest();
    }


    @isTest static void testMethodCreateHarvestProducts() {
        list<giic_CreateHarvestProduct.harvestProductWrapper> wrapperList = new list< giic_CreateHarvestProduct.harvestProductWrapper>();
        giic_CreateHarvestProduct.harvestProductWrapper wrapper = new giic_CreateHarvestProduct.harvestProductWrapper();
        
         List<gii__UnitofMeasure__c> lstUnitofMeasure = giic_Test_DataCreationUtility.insertUnitofMeasure();
         system.debug('lstUnitofMeasure>>>'+ lstUnitofMeasure);
         system.debug('lstUnitofMeasure[0]>>>'+ lstUnitofMeasure[0]);
        
        List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
        List<gii__Product2Add__c> prodList = [Select Id, Name, gii__ProductCode__c,
                                              gii__SerialControlled__c, gii__LotControlled__c,
                                              gii__BuyingUnitofMeasure__c ,gii__StockingUnitofMeasure__c,
                                              gii__SellingUnitofMeasure__c
                                              from gii__Product2Add__c 
                                              Where id =:lstProd[0].id];
        system.debug('prodList>>>'+ prodList);
        
        
        
        prodList[0].gii__SerialControlled__c= true;
        prodList[0].gii__BuyingUnitofMeasure__c=lstUnitofMeasure[0].id;
        prodList[0].gii__SellingUnitofMeasure__c=lstUnitofMeasure[0].id;
        prodList[0].gii__StockingUnitofMeasure__c=lstUnitofMeasure[0].id;
        update prodList[0]; 
        
         system.debug('prodList>>>[0]'+ prodList[0]);
         system.debug('prodList>>>'+ prodList);
        
         List<gii__Warehouse__c> lstWarehouse = giic_Test_DataCreationUtility.insertWarehouse();
                system.debug('lstWarehouse>>>'+ lstWarehouse);  
        

         List<gii__WorkOrder__c> lstWorkOrder = giic_Test_DataCreationUtility.InsertWorkOrder();
         system.debug('lstWorkOrder>>>'+ lstWorkOrder);
         system.debug('lstWorkOrder[0]>>>'+ lstWorkOrder[0]);
        
        
       
        List<gii__Location__c> lstLocations = giic_Test_DataCreationUtility.insertLocations();
         system.debug('lstLocations>>>'+ lstLocations);
         system.debug('lstLocations[0]>>>'+ lstLocations[0]);
        
        
        lstWarehouse[0].giic_DefaultHarvestLocation__c =lstLocations[0].id;
            update lstWarehouse;
        system.debug('lstWarehouse>>>22 '+ lstWarehouse);
        List<gii__Warehouse__c> lstWarehouseMain =[SELECT Id,Name , giic_DefaultHarvestLocation__c 
                                                   FROM gii__Warehouse__c  
                                                   where id =:lstWarehouse[0].id];
        system.debug('lstWarehouseMain>>>'+ lstWarehouseMain);  
        
         List<gii__ProductInventory__c> lstPI = giic_Test_DataCreationUtility.insertProductInventory();
         system.debug('lstPI>>>'+ lstPI);
         system.debug('lstPI[0]>>>'+ lstPI[0]);
        List<gii__ProductInventorybyLocation__c> lstPIL = giic_Test_DataCreationUtility.insertProductInventoryByLoc();
        system.debug('lstPIL>>>'+ lstPIL);
        system.debug('lstPIL[0]>>>'+ lstPIL[0]);
        
        List<gii__ProductInventoryQuantityDetail__c> lstPIQD = giic_Test_DataCreationUtility.insertProductInventoryQTYDetails();
        system.debug('lstPIQD>>>'+ lstPIQD);
        system.debug('lstPIQD[0]>>>'+ lstPIQD[0]);
         
        
        wrapper.objHarvestRef   = prodList[0];
        wrapper.isSelected   = true;

        wrapper.quantity   = '2';
        wrapper.Warehouse =lstWarehouse[0].id;
        wrapper.Location   = '2';
        wrapper.harvestDate ='50';
        wrapper.prodSerial ='50';
        wrapper.lotNumber ='50';
        wrapperList.add(wrapper);
       
        
        test.startTest();
        giic_CreateHarvestProduct.createHarvestProducts(wrapperList,lstWorkOrder[0].id );
        
        
        prodList[0].gii__SerialControlled__c= false;
        update prodList[0]; 
        giic_CreateHarvestProduct.createHarvestProducts(wrapperList,lstWorkOrder[0].id );

        test.stopTest();
        
    }   
    
    
     @isTest static void testMethodWithoutProdInventory() {
        list<giic_CreateHarvestProduct.harvestProductWrapper> wrapperList = new list< giic_CreateHarvestProduct.harvestProductWrapper>();
        giic_CreateHarvestProduct.harvestProductWrapper wrapper = new giic_CreateHarvestProduct.harvestProductWrapper();
        
         List<gii__UnitofMeasure__c> lstUnitofMeasure = giic_Test_DataCreationUtility.insertUnitofMeasure();
         system.debug('lstUnitofMeasure>>>'+ lstUnitofMeasure);
         system.debug('lstUnitofMeasure[0]>>>'+ lstUnitofMeasure[0]);
        
        List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
        List<gii__Product2Add__c> prodList = [Select Id, Name, gii__ProductCode__c,
                                              gii__SerialControlled__c, gii__LotControlled__c,
                                              gii__BuyingUnitofMeasure__c ,gii__StockingUnitofMeasure__c,
                                              gii__SellingUnitofMeasure__c
                                              from gii__Product2Add__c 
                                              Where id =:lstProd[0].id];
        system.debug('prodList>>>'+ prodList);
        
        
        
        prodList[0].gii__SerialControlled__c= true;
        prodList[0].gii__BuyingUnitofMeasure__c=lstUnitofMeasure[0].id;
        prodList[0].gii__SellingUnitofMeasure__c=lstUnitofMeasure[0].id;
        prodList[0].gii__StockingUnitofMeasure__c=lstUnitofMeasure[0].id;
        update prodList[0]; 
        
         system.debug('prodList>>>[0]'+ prodList[0]);
         system.debug('prodList>>>'+ prodList);
        
         List<gii__Warehouse__c> lstWarehouse = giic_Test_DataCreationUtility.insertWarehouse();
                system.debug('lstWarehouse>>>'+ lstWarehouse);  
        

         List<gii__WorkOrder__c> lstWorkOrder = giic_Test_DataCreationUtility.InsertWorkOrder();
        // system.debug('lstWorkOrder>>>'+ lstWorkOrder);
         //system.debug('lstWorkOrder[0]>>>'+ lstWorkOrder[0]);
        
        
       
        List<gii__Location__c> lstLocations = giic_Test_DataCreationUtility.insertLocations();
         system.debug('lstLocations>>>'+ lstLocations);
         system.debug('lstLocations[0]>>>'+ lstLocations[0]);
        
        
        lstWarehouse[0].giic_DefaultHarvestLocation__c =lstLocations[0].id;
            update lstWarehouse;
        system.debug('lstWarehouse>>>22 '+ lstWarehouse);
        List<gii__Warehouse__c> lstWarehouseMain =[SELECT Id,Name , giic_DefaultHarvestLocation__c 
                                                   FROM gii__Warehouse__c  
                                                   where id =:lstWarehouse[0].id];
        system.debug('lstWarehouseMain>>>'+ lstWarehouseMain);  
        
        List<gii__ProductInventory__c> lstPI = giic_Test_DataCreationUtility.insertProductInventory();
         //system.debug('lstPI>>>'+ lstPI);
         //system.debug('lstPI[0]>>>'+ lstPI[0]);
        List<gii__ProductInventorybyLocation__c> lstPIL = giic_Test_DataCreationUtility.insertProductInventoryByLoc();
        system.debug('lstPIL>>>'+ lstPIL);
        system.debug('lstPIL[0]>>>'+ lstPIL[0]);
        
        List<gii__ProductInventoryQuantityDetail__c> lstPIQD = giic_Test_DataCreationUtility.insertProductInventoryQTYDetails();
        system.debug('lstPIQD>>>'+ lstPIQD);
        system.debug('lstPIQD[0]>>>'+ lstPIQD[0]);
         
        
        wrapper.objHarvestRef   = prodList[0];
        wrapper.isSelected   = true;

        wrapper.quantity   = '2';
        wrapper.Warehouse =lstWarehouse[0].id;
        wrapper.Location   = '2';
        wrapper.harvestDate ='50';
        wrapper.prodSerial ='50';
        wrapper.lotNumber ='50';
        wrapperList.add(wrapper);
       
         gii__InventoryAdjustment__c iAdj =new gii__InventoryAdjustment__c();
         							 iAdj.gii__ProductInventory__c = lstPI[0].id;
         								iAdj.gii__AdjustmentDate__c=System.today();
         
         insert iAdj;
          system.debug('@@Iadj'+iAdj);
         gii__WorkOrderStaging__c woStg = new gii__WorkOrderStaging__c();
         
       	 woStg.giic_InventoryAdjustment__c = iAdj.id;
         insert woStg; 
         system.debug('@@WO'+woStg);
        test.startTest();
        giic_CreateHarvestProduct.createHarvestProducts(wrapperList,lstWorkOrder[0].id );
        
        
        prodList[0].gii__SerialControlled__c= false;
        update prodList[0]; 
        giic_CreateHarvestProduct.createHarvestProducts(wrapperList,lstWorkOrder[0].id );

        test.stopTest();
        
    }   
    
}