/**
*Covers Code Coverage for 
*@Apex Class: giic_RecieveandPutaway, CustomLookupLwcController
*@Apex Trigger:
*@Flow:
**/
@isTest
public class giic_RecieveandPutawayTest {
	@testSetup static void setup() {
       giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
	@isTest 
	static void searchOrderListTest_PO() {
        List<gii__Location__c> locLst = new List<gii__Location__c>();
		List<gii__LocationBin__c> locBinLst = new List<gii__LocationBin__c>();
		List<gii__ProductInventory__c> pdInLst = new List<gii__ProductInventory__c>();
		List<gii__ABCClass__c> abcClsLst = new List<gii__ABCClass__c>();
		List<gii__PurchaseOrderLine__c> poLineLst = new List<gii__PurchaseOrderLine__c>();
		List<String> purchaseOrder = new List<String>();
		List<String> purchaseOrderLine = new List<String>();
		List<String> Quantity = new List<String>();
		List<String> Location = new List<String>();
		List<String> LocationBin = new List<String>();
		List<String> productSerial = new List<String>(); 
		List<String> transferOrder = new List<String>(); 
		List<String> transferOrderLine = new List<String>(); 
		List<String> productRecords = new List<String>(); 
		List<String> recivedQuantity = new List<String>(); 
        List<Account> lstAcc = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> wareHouseList = giic_Test_DataCreationUtility.insertWarehouse();
        List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
		//ABC Class
        abcClsLst.add(new gii__ABCClass__c(Name = 'Test_ABC_Class'));
		abcClsLst.add(new gii__ABCClass__c(Name = 'Test_123_Class'));
		insert abcClsLst;
		//Location
        locLst.add(new gii__Location__c(Name = 'Test_Loc_WH0', gii__Warehouse__c = wareHouseList[0].Id, giic_ABC_Class__c = abcClsLst[0].Id, gii__BinControlled__c = true));
		locLst.add(new gii__Location__c(Name = 'Test_Loc_WH0_1', gii__Warehouse__c = wareHouseList[0].Id, giic_ABC_Class__c = abcClsLst[0].Id));
        locLst.add(new gii__Location__c(Name = 'Test_Loc_WH1', gii__Warehouse__c = wareHouseList[1].Id, giic_ABC_Class__c = abcClsLst[1].Id));
        Insert locLst;
		//Location Bin
        locBinLst.add(new gii__LocationBin__c(gii__Location__c = locLst[0].Id, giic_ABC_Class__c = abcClsLst[0].Id));
		locBinLst.add(new gii__LocationBin__c(gii__Location__c = locLst[0].Id, giic_ABC_Class__c = abcClsLst[1].Id));
        insert locBinLst;
		//Product Inventory
        pdInLst.add(new gii__ProductInventory__c(gii__PrimaryLocation__c = locLst[0].Id, gii__Product__c = lstProd[0].Id, gii__Warehouse__c = wareHouseList[0].Id, gii__SalesOrderQuantity__c = 50, giic_ABC_Class__c = abcClsLst[0].Id));
		pdInLst.add(new gii__ProductInventory__c(gii__PrimaryLocation__c = locLst[0].Id, gii__Product__c = lstProd[1].Id, gii__Warehouse__c = wareHouseList[0].Id, gii__SalesOrderQuantity__c = 5, giic_ABC_Class__c = abcClsLst[1].Id));
		pdInLst.add(new gii__ProductInventory__c(gii__PrimaryLocation__c = locLst[2].Id, gii__Product__c = lstProd[0].Id, gii__Warehouse__c = wareHouseList[1].Id, gii__SalesOrderQuantity__c = 30, giic_ABC_Class__c = abcClsLst[1].Id));
        Insert pdInLst;
        gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = lstAcc[0].Id, gii__ShipTo__c = wareHouseList[0].Id);
        insert objPO;
        gii__PurchaseOrder__c objPO1 = [Select Id, Name from gii__PurchaseOrder__c where Id =: objPO.Id];
        poLineLst.add(new gii__PurchaseOrderLine__c(gii__OrderQuantity__c = 2, gii__PurchaseOrder__c = objPO.Id, gii__ReceiptStatus__c	= 'Open', gii__Product__c = lstProd[0].Id, gii__NoChargeReason__c = 'Test Run', gii__ShipTo__c = wareHouseList[0].Id));
		poLineLst.add(new gii__PurchaseOrderLine__c(gii__OrderQuantity__c = 2, gii__PurchaseOrder__c = objPO.Id, gii__ReceiptStatus__c	= 'Open', gii__Product__c = lstProd[1].Id, gii__NoChargeReason__c = 'Test Run', gii__ShipTo__c = wareHouseList[0].Id));
        insert poLineLst;
        test.startTest();
            giic_RecieveandPutaway.searchOrderList(wareHouseList[0].Name,'','',objPO1.Name,'','false');
            giic_RecieveandPutaway.searchOrderList('','','',objPO1.Name,'','false');
            giic_RecieveandPutaway.searchOrderList('','Sel Pro PD Dry 32#-Dog','',objPO1.Name,'','false');
            
            giic_RecieveandPutaway.getLoggedInUserDefaultWarehouse();
			insert new gii__WarehouseUser__c(Name = UserInfo.getName(), gii__Active__c = true, gii__DefaultWarehouse__c = wareHouseList[0].Id, gii__User__c = Id.valueOf(UserInfo.getUserId()));
            giic_RecieveandPutaway.getLoggedInUserDefaultWarehouse();
			giic_RecieveandPutaway.getPOLineQuantity(String.valueOf(poLineLst[0].Id));
			giic_RecieveandPutaway.getIsLocationBinControlled(String.valueOf(locLst[0].Id));
			
			purchaseOrder.add(String.valueOf(objPO.Id));
			purchaseOrderLine.add(String.valueOf(poLineLst[0].Id));
			Quantity.add(String.valueOf(2));
			Location.add(String.valueOf(locLst[0].Id));
			LocationBin.add(null);
			transferOrder.add(null); 
			transferOrderLine.add(null); 
			productRecords.add(String.valueOf(lstProd[0].Id)); 
			recivedQuantity.add(String.valueOf(2)); 
			giic_RecieveandPutaway.processSelectedRecords(purchaseOrder, purchaseOrderLine, Quantity, Location, LocationBin, productSerial, transferOrder, transferOrderLine, productRecords, recivedQuantity, false);
	    test.stopTest();
    }
    
    @isTest 
	static void searchOrderListTest_TO() {
        List<gii__Location__c> locLst = new List<gii__Location__c>();
		List<gii__LocationBin__c> locBinLst = new List<gii__LocationBin__c>();
		List<gii__ProductInventory__c> pdInLst = new List<gii__ProductInventory__c>();
		List<gii__ABCClass__c> abcClsLst = new List<gii__ABCClass__c>();
		List<String> purchaseOrder = new List<String>();
		List<String> purchaseOrderLine = new List<String>();
		List<String> Quantity = new List<String>();
		List<String> Location = new List<String>();
		List<String> LocationBin = new List<String>();
		List<String> productSerial = new List<String>(); 
		List<String> transferOrder = new List<String>(); 
		List<String> transferOrderLine = new List<String>(); 
		List<String> productRecords = new List<String>(); 
		List<String> recivedQuantity = new List<String>();
		List<Account> lstAcc = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> wareHouseList = giic_Test_DataCreationUtility.insertWarehouse();
        List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
		gii__UnitofMeasure__c measure = new gii__UnitofMeasure__c(gii__DisplayName__c = 'TestEACH', gii__UniqueId__c = 'TestEach');
		insert measure;
		update new gii__Product2Add__c(Id = lstProd[0].Id, gii__SerialControlled__c = true, gii__BuyingUnitofMeasure__c = measure.id, gii__SellingUnitofMeasure__c = measure.id, gii__StockingUnitofMeasure__c = measure.id);
		//ABC Class
        abcClsLst.add(new gii__ABCClass__c(Name = 'Test_ABC_Class_TO'));
		abcClsLst.add(new gii__ABCClass__c(Name = 'Test_123_Class_TO'));
		insert abcClsLst;
		//Location
        locLst.add(new gii__Location__c(Name = 'Test_Loc_WH0_TO', gii__Warehouse__c = wareHouseList[1].Id, giic_ABC_Class__c = abcClsLst[0].Id, gii__BinControlled__c = true));
		locLst.add(new gii__Location__c(Name = 'Test_Loc_WH0_TO_1', gii__Warehouse__c = wareHouseList[1].Id, giic_ABC_Class__c = abcClsLst[0].Id));
        locLst.add(new gii__Location__c(Name = 'Test_Loc_WH1_TO', gii__Warehouse__c = wareHouseList[0].Id, giic_ABC_Class__c = abcClsLst[1].Id));
        Insert locLst;
		//Location Bin
        locBinLst.add(new gii__LocationBin__c(gii__Location__c = locLst[0].Id, giic_ABC_Class__c = abcClsLst[0].Id));
		locBinLst.add(new gii__LocationBin__c(gii__Location__c = locLst[0].Id, giic_ABC_Class__c = abcClsLst[1].Id));
        insert locBinLst;
		//Product Inventory
        pdInLst.add(new gii__ProductInventory__c(gii__PrimaryLocation__c = locLst[0].Id, gii__Product__c = lstProd[0].Id, gii__Warehouse__c = wareHouseList[1].Id, gii__SalesOrderQuantity__c = 50, giic_ABC_Class__c = abcClsLst[0].Id));
		pdInLst.add(new gii__ProductInventory__c(gii__PrimaryLocation__c = locLst[0].Id, gii__Product__c = lstProd[1].Id, gii__Warehouse__c = wareHouseList[1].Id, gii__SalesOrderQuantity__c = 5, giic_ABC_Class__c = abcClsLst[1].Id));
		pdInLst.add(new gii__ProductInventory__c(gii__PrimaryLocation__c = locLst[2].Id, gii__Product__c = lstProd[0].Id, gii__Warehouse__c = wareHouseList[0].Id, gii__SalesOrderQuantity__c = 30, giic_ABC_Class__c = abcClsLst[1].Id));
        Insert pdInLst;
        
        gii__TransferOrder__c objTO = new gii__TransferOrder__c(gii__Account__c = lstAcc[0].Id, gii__FromWarehouse__c = wareHouseList[0].Id, gii__TransferToWarehouse__c = wareHouseList[1].id);
        insert objTO;
        gii__TransferOrder__c objTO1 = [Select Id, Name from gii__TransferOrder__c where Id =: objTO.Id];
        gii__TransferOrderLine__c toLine= new gii__TransferOrderLine__c();
        toLine.gii__TransferOrder__c = objTO.Id;
        toLine.gii__TransferToWarehouse__c = wareHouseList[1].Id;
        toLine.gii__Product__c = lstProd[0].Id;
        toLine.gii__Quantity__c = 10;
		insert toLine;
		gii__ProductSerial__c prdSr = new gii__ProductSerial__c(Name = 'TEST-SN-TO-X1C2Z1', gii__Product__c = lstProd[0].Id, gii__ProductInventory__c = pdInLst[1].Id, gii__Warehouse__c = wareHouseList[1].Id);
		insert prdSr;
        gii__ReceiptQueue__c toRQ = new gii__ReceiptQueue__c();
        toRQ.gii__InTransitWarehouse__c = wareHouseList[1].Id;
        toRQ.gii__TransferOrder__c = objTO.Id;
        toRQ.gii__TransferOrderLine__c = toLine.Id;
        toRQ.gii__OrderType__c = 'Transfer';
		toRQ.gii__ProductInventorySequence__c = pdInLst[1].Id;
		toRQ.gii__ReceiptQuantity__c = 1;
		toRQ.gii__ProductSerial__c = prdSr.Id;
        insert toRQ;
        
        test.startTest();
            giic_RecieveandPutaway.searchOrderList(wareHouseList[1].Name,'','','',objTO1.Name,'true');
			giic_RecieveandPutaway.searchOrderList('','','','',objTO1.Name,'true');
			giic_RecieveandPutaway.getReceiptQueueforTOL(String.valueOf(toLine.Id));
			purchaseOrder.add(null);
			purchaseOrderLine.add(null);
			Quantity.add(String.valueOf(10));
			Location.add(String.valueOf(locLst[0].Id));
			LocationBin.add(String.valueOf(locBinLst[0].Id));
			productSerial.add('TEST-SN-TO-X1C2Z1'); 
			transferOrder.add(String.valueOf(objTO.Id)); 
			transferOrderLine.add(String.valueOf(toLine.Id)); 
			productRecords.add(String.valueOf(lstProd[0].Id)); 
			recivedQuantity.add(String.valueOf(1)); 
			giic_RecieveandPutaway.processSelectedRecords(purchaseOrder, purchaseOrderLine, Quantity, Location, LocationBin, productSerial, transferOrder, transferOrderLine, productRecords, recivedQuantity, true);
	    test.stopTest();
    }
    
    @isTest 
	static void CustomLookupLwcController_Test() {
		List<gii__Location__c> locLst = new List<gii__Location__c>();
		List<gii__Warehouse__c> wareHouseList = giic_Test_DataCreationUtility.insertWarehouse();
        //Location
        locLst.add(new gii__Location__c(Name = 'Test_Loc_WH0_TO', gii__Warehouse__c = wareHouseList[1].Id));
        Insert locLst;
        test.startTest();
			CustomLookupLwcController.fetchLookupData('','gii__Location__c','gii__Warehouse__c', String.valueOf(wareHouseList[1].Id));
			CustomLookupLwcController.fetchLookupData('', 'gii__Location__c', '', '');
			CustomLookupLwcController.fetchDefaultRecord(String.valueOf(wareHouseList[1].Id) , 'gii__Warehouse__c');
		test.stopTest();
	}
}