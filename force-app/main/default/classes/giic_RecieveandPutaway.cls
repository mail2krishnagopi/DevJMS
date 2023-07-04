public with sharing class giic_RecieveandPutaway {
    @AuraEnabled(cacheable=true)
    public static List<OrderLineWrapper> searchOrderList(string warehouseKeyValue,string productKeyValue,string supplierKeyValue,string purchaseOrderValue,string transferOrderValue, String pageOnLoad) {
        //System.debug('List of Products searchKeyField' + warehouseKeyValue + '--' + productKeyValue + '--' + supplierKeyValue + '--' + purchaseOrderValue + '--' + transferOrderValue+'--'+pageOnLoad);
        List<OrderLineWrapper> ordList = new List<OrderLineWrapper>();
        List<gii__PurchaseOrderLine__c> purchaseOrderResult = new  List<gii__PurchaseOrderLine__c>();
        List<gii__TransferOrderLine__c> transferOrderResult = new  List<gii__TransferOrderLine__c>();
        List<gii__Location__c> locList = new List<gii__Location__c>();
        //Map<Id,Id> locMap = new Map<Id,Id>();
		Map<Id,List<gii__Location__c>> locMap = new Map<Id,List<gii__Location__c>>();
        String currentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' ;
        Boolean executePurchaseQuery = false;
        Boolean executeTransferQuery = false;
        List<gii__LocationBin__c> locBinList = new List<gii__LocationBin__c>();
        //Map<Id,gii__LocationBin__c> locBinMap = new Map<Id,gii__LocationBin__c>();
		Map<Id,List<gii__LocationBin__c>> locBinMap = new Map<Id,List<gii__LocationBin__c>>();
        List<gii__ReceiptQueue__c> receiptQueueRecords = new List<gii__ReceiptQueue__c>();
        receiptQueueRecords = [SELECT gii__TransferOrderLine__c from gii__ReceiptQueue__c];
        List<ID> transferOrderToProcess = new List<ID>();
		boolean onPageLoadRequest = false;
		Map<Id, List<Id>> productInventoryMap = new Map<Id,List<Id>>();
		if(String.isNotBlank(pageOnLoad) && pageOnLoad.equalsIgnoreCase('true')){
			onPageLoadRequest = true;
		}
		
        for(gii__ReceiptQueue__c req : receiptQueueRecords){
            transferOrderToProcess.add(req.gii__TransferOrderLine__c);
        }

        String purchaseOrderquery = 'SELECT Id,Name,gii__LineStatus__c, gii__PurchaseOrder__c, gii__PurchaseOrder__r.Name, gii__Product__c,gii__Product__r.Name,gii__Product__r.gii__SerialControlled__c, gii__OrderQuantity__c, gii__ReceivedQuantity__c, gii__ShipTo__c ,gii__Product__r.gii__ABCClass__c,gii__ShipTo__r.Name,gii__PurchaseOrder__r.gii__OrderStatus__c FROM gii__PurchaseOrderLine__c Where gii__LineStatus__c != \'Received\' AND ';

        String transferOrderquery = 'SELECT Id, Name, gii__Product__c,gii__Product__r.Name,gii__Product__r.gii__SerialControlled__c, gii__Product__r.gii__ABCClass__c, gii__Quantity__c, gii__ReceiptQuantity__c, gii__ReservedQuantity__c, gii__TransferOrder__c, gii__TransferOrder__r.Name, gii__Warehouse__c,gii__Warehouse__r.Name, gii__TransferToWarehouse__c, gii__TransferToWarehouse__r.Name, gii__TransferOrder__r.gii__OrderStatus__c FROM gii__TransferOrderLine__c where Id IN : transferOrderToProcess AND ';

        if(warehouseKeyValue !='' && warehouseKeyValue != null){
            purchaseOrderquery += 'gii__ShipTo__r.Name = \'' + String.escapeSingleQuotes(warehouseKeyValue) + '\' AND ';
            //transferOrderquery += 'gii__Warehouse__r.Name = \'' + String.escapeSingleQuotes(warehouseKeyValue) + '\' AND ';
			transferOrderquery += 'gii__TransferToWarehouse__r.Name = \'' + String.escapeSingleQuotes(warehouseKeyValue) + '\' AND ';
			
            //added If check below to run either PO or TO query only with warehouse details on page load "Receive and Put Away"
            if(onPageLoadRequest){
                executePurchaseQuery = TRUE;
                executeTransferQuery = TRUE;
            }

            /*locList = [select id,giic_ABC_Class__c, gii__Warehouse__c from gii__Location__c where gii__Warehouse__r.Name =: warehouseKeyValue and giic_ABC_Class__c != Null];
            //System.debug('locList' + locList);
            
            locBinList = [select id,giic_ABC_Class__c, gii__Location__c from gii__LocationBin__c where gii__Location__c in : locList and giic_ABC_Class__c != Null];
            //System.debug('locBinList' + locBinList);

            if(locList.size()>0)
            {
                //System.debug('LocList Size'+locList.size());
                for(gii__Location__c loc : locList)
                {
                    locMap.put(loc.giic_ABC_Class__c,loc.id);
                    //System.debug('Checking this LocMAP'+locMap);
                }
            }
            //System.debug('locMap' + locMap);

			if(locBinList.size()>0)
            {
				List<gii__LocationBin__c> locationBinList = new List<gii__LocationBin__c>();
                for(gii__LocationBin__c locBin : locBinList)
                {
                    //locBinMap.put(locBin.gii__Location__c,locBin);
					if(!locBinMap.containsKey(locBin.gii__Location__c)){
						locationBinList = new List<gii__LocationBin__c>();
						locationBinList.add(locBin);		
						locBinMap.put(locBin.gii__Location__c,locationBinList);
					}
					else{
						locationBinList = locBinMap.get(locBin.gii__Location__c);
						locationBinList.add(locBin);
						locBinMap.put(locBin.gii__Location__c,locationBinList);
					}
                }
            }*/
			locMap = getLocationDetails(warehouseKeyValue.split(','));
			if(locmap != null && !locmap.isEmpty()){
				locBinMap = getLocationBinDetails(getLocationIds(locmap));
			}
            //System.debug('locBinMap is' + locBinMap);
        }

        if(productKeyValue != '' && productKeyValue != null){
            purchaseOrderquery += 'gii__Product__r.Name = \'' + String.escapeSingleQuotes(productKeyValue) + '\' AND ';
            transferOrderquery += 'gii__Product__r.Name = \'' + String.escapeSingleQuotes(productKeyValue) + '\' AND ';
            //Commented below to run either PO or TO query
            /*executePurchaseQuery = TRUE;
            executeTransferQuery = TRUE;*/
        }
        if(purchaseOrderValue != '' && purchaseOrderValue != null){
            purchaseOrderquery += 'gii__PurchaseOrder__r.Name = \'' + String.escapeSingleQuotes(purchaseOrderValue) + '\' AND ';
            executePurchaseQuery = TRUE;
        }
        if(transferOrderValue != '' && transferOrderValue != null){
            transferOrderquery += 'gii__TransferOrder__r.Name = \'' + String.escapeSingleQuotes(transferOrderValue) + '\' AND ';
            executeTransferQuery = TRUE;
        }
        if (purchaseOrderquery.endsWith('AND ')) {
            purchaseOrderquery = purchaseOrderquery.substring(0, purchaseOrderquery.length() - 4);
        }
        if (transferOrderquery.endsWith('AND ')) {
            transferOrderquery = transferOrderquery.substring(0, transferOrderquery.length() - 4);
        }
        if(executePurchaseQuery){
            purchaseOrderResult = Database.query(purchaseOrderquery);
			if(purchaseOrderResult != null && !purchaseOrderResult.isEmpty())
			{
				List<String> wareHouseName = new List<String>();
				List<Id> productIds = new List<Id>();
				for(gii__PurchaseOrderLine__c poLine:purchaseOrderResult){
					wareHouseName.add(poLine.gii__ShipTo__r.Name);
					productIds.add(poLine.gii__Product__c);
				}
				productInventoryMap = getProductInventoryDetails(productIds);
				if(String.isBlank(warehouseKeyValue)){
					locMap = getLocationDetails(wareHouseName);
					if(locmap != null && !locmap.isEmpty()){
						locBinMap = getLocationBinDetails(getLocationIds(locmap));
					}
				}
			}
        }
        if(executeTransferQuery){
            transferOrderResult  = Database.query(transferOrderquery);
			if(transferOrderResult != null && !transferOrderResult.isEmpty())
			{
				List<String> wareHouseName = new List<String>();
				List<Id> productIds = new List<Id>();
				for(gii__TransferOrderLine__c toLine:transferOrderResult){
					wareHouseName.add(toLine.gii__TransferToWarehouse__r.Name);
					productIds.add(toLine.gii__Product__c);
				}
				productInventoryMap = getProductInventoryDetails(productIds);
				if(String.isBlank(warehouseKeyValue)){
					locMap = getLocationDetails(wareHouseName);
					if(locmap != null && !locmap.isEmpty()){
						locBinMap = getLocationBinDetails(getLocationIds(locmap));
					}
				}
			}
            //System.debug('Transfer Order List ->' + transferOrderResult + ' Size is ' +transferOrderResult.size() );
        }
        if((!onPageLoadRequest && purchaseOrderResult.size()>0) || (onPageLoadRequest && transferOrderResult.isEmpty() && purchaseOrderResult.size() == 1))
        {
            for(gii__PurchaseOrderLine__c objPurchaseOrderLine : purchaseOrderResult)
            {
                OrderLineWrapper objPOL = new OrderLineWrapper();
                objPOL.warehouseId = objPurchaseOrderLine.gii__ShipTo__c;
                objPOL.warehouseName = objPurchaseOrderLine.gii__ShipTo__r.Name;
                objPOL.RecordURL = currentURL + objPurchaseOrderLine.gii__ShipTo__c;
				//objPOL.warehouseRecordURL = '/' + objPurchaseOrderLine.gii__ShipTo__c;
                objPOL.purchaseOrderId = objPurchaseOrderLine.gii__PurchaseOrder__c;
                objPOL.purchaseOrderRecordURL = currentURL + objPurchaseOrderLine.gii__PurchaseOrder__c;
                objPOL.purchaseOrderName = objPurchaseOrderLine.gii__PurchaseOrder__r.Name;
                objPOL.purchaseOrderLineId = objPurchaseOrderLine.Id;
                objPOL.purchaseOrderLineRecordURL = currentURL + objPurchaseOrderLine.Id;
                objPOL.purchaseOrderLineName = objPurchaseOrderLine.Name;
                objPOL.productId = objPurchaseOrderLine.gii__Product__c;
                objPOL.productRecordURL = currentURL + objPurchaseOrderLine.gii__Product__c;
                objPOL.productName = objPurchaseOrderLine.gii__Product__r.Name;
                objPol.productSerialVal = '';
                if(objPurchaseOrderLine.gii__Product__r.gii__SerialControlled__c){
					objPOL.serialproductChecked = objPurchaseOrderLine.gii__Product__r.gii__SerialControlled__c;
                }
                else
                {
                    objPOL.serialproductChecked = false;
                }
				if(String.isNotBlank(String.valueOf(objPurchaseOrderLine.gii__ReceivedQuantity__c))){
					objPOL.quantity = String.valueOf(objPurchaseOrderLine.gii__OrderQuantity__c - objPurchaseOrderLine.gii__ReceivedQuantity__c); 
					objPOL.receivedQuantity = String.valueOf(objPurchaseOrderLine.gii__OrderQuantity__c - objPurchaseOrderLine.gii__ReceivedQuantity__c); 
				}
				else{
					objPOL.quantity = String.valueOf(objPurchaseOrderLine.gii__OrderQuantity__c); 
					objPOL.receivedQuantity = String.valueOf(objPurchaseOrderLine.gii__OrderQuantity__c); 
				}
               
				if(locMap != null && !locmap.isEmpty() && locmap.containsKey(objPurchaseOrderLine.gii__ShipTo__c) && productInventoryMap != null && !productInventoryMap.isEmpty() && productInventoryMap.containsKey(objPurchaseOrderLine.gii__Product__c))
                {
					List<Id> pInventoryABCcls = productInventoryMap.get(objPurchaseOrderLine.gii__Product__c);
					for(gii__Location__c giiLoc: locmap.get(objPurchaseOrderLine.gii__ShipTo__c)){
						if(giiLoc.giic_ABC_Class__c != null && pInventoryABCcls.contains(giiLoc.giic_ABC_Class__c)){
							objPOL.locationId = giiLoc.Id;
							break;
						}
					}
                    if(objPOL.locationId != null && locBinMap.containsKey(objPOL.locationId))
                    {
						for(gii__LocationBin__c locBinRec:locBinMap.get(objPOL.locationId)){
							if(locBinRec.giic_ABC_Class__c != null && pInventoryABCcls.contains(locBinRec.giic_ABC_Class__c)){
								objPOL.locationBinId = locBinRec.Id;
								break;
							}
						}
					}               
                }
                ordList.add(objPOL);
                //System.debug('This is order list' + ordList);
            }
        }
   
		if((!onPageLoadRequest && transferOrderResult.size()>0) || (onPageLoadRequest && purchaseOrderResult.isEmpty() && transferOrderResult.size() == 1))
        {
            for(gii__TransferOrderLine__c objTransferOrderLine : transferOrderResult)
            {
                OrderLineWrapper objTol = new OrderLineWrapper();
                //objTol.warehouseId = objTransferOrderLine.gii__Warehouse__c;
                //objTol.RecordURL = currentURL + objTransferOrderLine.gii__Warehouse__c;
                //objTol.warehouseName = objTransferOrderLine.gii__Warehouse__r.Name;
				objTol.warehouseId = objTransferOrderLine.gii__TransferToWarehouse__c;
                objTol.RecordURL = currentURL + objTransferOrderLine.gii__TransferToWarehouse__c;
				objTol.warehouseName = objTransferOrderLine.gii__TransferToWarehouse__r.Name;
                objTol.transferOrderId = objTransferOrderLine.gii__TransferOrder__c;
                objTol.transferOrderName = objTransferOrderLine.gii__TransferOrder__r.Name;
                objTol.transferOrderLineId = objTransferOrderLine.Id;
                objTol.transferOrderLineName = objTransferOrderLine.Name;
                objTol.productId = objTransferOrderLine.gii__Product__c;
                objTol.productName = objTransferOrderLine.gii__Product__r.Name;
                objTol.transferOrderRecordURL = currentURL + objTransferOrderLine.gii__TransferOrder__c;
                objTol.transferOrderLineRecordURL = currentURL + objTransferOrderLine.Id;
                objTol.productRecordURL = currentURL + objTransferOrderLine.gii__Product__c;
                objTol.productSerialVal = '';
                if(objTransferOrderLine.gii__Product__r.gii__SerialControlled__c){
					objTol.serialproductChecked = objTransferOrderLine.gii__Product__r.gii__SerialControlled__c;
				}
				else
				{
					objTol.serialproductChecked = false;
				}
				if(String.isNotBlank(String.valueOf(objTransferOrderLine.gii__ReceiptQuantity__c))){
					objTol.quantity = String.valueOf(objTransferOrderLine.gii__Quantity__c - objTransferOrderLine.gii__ReceiptQuantity__c);
					objTol.receivedQuantity = String.valueOf(objTransferOrderLine.gii__Quantity__c - objTransferOrderLine.gii__ReceiptQuantity__c);
				}
				else{
					objTol.quantity = String.valueOf(objTransferOrderLine.gii__Quantity__c);
					objTol.receivedQuantity = String.valueOf(objTransferOrderLine.gii__Quantity__c);
				}

				if(locMap != null && !locmap.isEmpty() && locmap.containsKey(objTransferOrderLine.gii__TransferToWarehouse__c) && productInventoryMap != null && !productInventoryMap.isEmpty() && productInventoryMap.containsKey(objTransferOrderLine.gii__Product__c))
                {
					List<Id> pInventoryABCcls = productInventoryMap.get(objTransferOrderLine.gii__Product__c);
					for(gii__Location__c giiLoc: locmap.get(objTransferOrderLine.gii__TransferToWarehouse__c)){
						if(giiLoc.giic_ABC_Class__c != null && pInventoryABCcls.contains(giiLoc.giic_ABC_Class__c)){
							objTol.locationId = giiLoc.Id;
							break;
						}
					}
                    if(objTol.locationId != null && locBinMap.containsKey(objTol.locationId))
                    {
						for(gii__LocationBin__c locBinRec:locBinMap.get(objTol.locationId)){
							if(locBinRec.giic_ABC_Class__c != null && pInventoryABCcls.contains(locBinRec.giic_ABC_Class__c)){
								objTol.locationBinId = locBinRec.Id;
								break;
							}
						}
					}               
                }
                ordList.add(objTol);
            }
        }
        //System.debug('ReturnList' + ordList);
        executePurchaseQuery = false;
        executeTransferQuery = false;
        return ordList;
    }

    @AuraEnabled
    public static void processSelectedRecords(List<String> purchaseOrder,List<String> purchaseOrderLine,List<String> Quantity,List<String> Location,List<String> LocationBin,List<String> productSerial, List<String> transferOrder, List<String> transferOrderLine, List<String> productRecords, List<String> recivedQuantity, Boolean serialControlledPage) {
        //System.debug(('processSelectedRecords :: purchaseOrder :: '+purchaseOrder);
        //System.debug(('processSelectedRecords :: purchaseOrderLine :: '+purchaseOrderLine);
        //System.debug(('processSelectedRecords :: Quantity :: '+Quantity);
        //System.debug(('processSelectedRecords :: Location :: '+Location);
        //System.debug(('processSelectedRecords :: LocationBin :: '+LocationBin);
        //System.debug(('processSelectedRecords :: productSerial :: '+productSerial);
        //System.debug(('processSelectedRecords :: transferOrder :: '+transferOrder);
        //System.debug(('processSelectedRecords :: transferOrderLine :: '+transferOrderLine);
        //System.debug(('processSelectedRecords :: productRecords :: '+productRecords);
		//System.debug(('processSelectedRecords :: recivedQuantity :: '+recivedQuantity);

        Map<id,List<String>> recordstoProcess = new Map<Id, List<String>>();
        List<String> combinedList = new List<String>();
        List<gii__PurchaseOrderReceiptLine__c> listpoReceiptLine = new List<gii__PurchaseOrderReceiptLine__c>();
        List<DataBase.SaveResult> finalsResults = new List<DataBase.SaveResult>();
		List<purchaseOrderReceipt> purchaseOrderReceiptPair = new List<purchaseOrderReceipt>();
        List<transferOrderReceipt> transferOrderReceiptPair = new List<transferOrderReceipt>();
		//for(Integer i = 0; i < Quantity.size(); i++){
		for(Integer i = 0; i < recivedQuantity.size(); i++){
            if(purchaseOrderLine[i] != null && purchaseOrderLine[i] != ''){
                purchaseOrderReceipt por = new purchaseOrderReceipt();
                por.purchaseOrderValue = purchaseOrder[i];
                por.purchaseOrderLineValue = purchaseOrderLine[i];
                //por.quantityValue = Quantity[i];
				por.quantityValue = recivedQuantity[i];
                por.locationValue = Location[i];
				if(LocationBin[i] != null){
					por.locationBinValue = LocationBin[i];
				}
				if(!productSerial.isEmpty()) {
                    if(serialControlledPage){
                        por.productSerialValue = String.join(productSerial, ',');
                    }
                    else if(!serialControlledPage) {
                        por.productSerialValue = productSerial[i];
                    }
                }
                por.productValue = productRecords[i];
                purchaseOrderReceiptPair.add(por);
            }
            if(transferOrderLine[i] != null && transferOrderLine[i] != '') {
                transferOrderReceipt tor = new transferOrderReceipt();
                tor.transferOrderValue = transferOrder[i];
                tor.transferOrderLineValue = transferOrderLine[i];
                //tor.transferOrderLinequantityValue = Quantity[i];
				tor.transferOrderLinequantityValue = recivedQuantity[i];
                tor.transferOrderLinelocationValue = Location[i];
				if(LocationBin[i] != null){
					tor.transferOrderLinelocationBinValue = LocationBin[i];
				}
				//System.debug(('transferOrderLine :: productSerial :: '+productSerial);
                if(!productSerial.isEmpty()) {
                    if(serialControlledPage){
                        tor.transferOrderLineproductSerialValue = String.join(productSerial, ',');
                    }
                    else if(!serialControlledPage) {
                        tor.transferOrderLineproductSerialValue = productSerial[i];
                    }
                }
			    tor.transferOrderproductValue = productRecords[i];
				//System.debug('transferOrderReceiptPair Add:: TOR ::'+tor);
                transferOrderReceiptPair.add(tor);
            }
        }
        if(purchaseOrderReceiptPair.size() > 0){
            //System.debug('This is por to process' + purchaseOrderReceiptPair);
            processPurchaseOrderReceipt(purchaseOrderReceiptPair);
        }
        if(transferOrderReceiptPair.size() > 0){
            //System.debug('This is tor to process' + transferOrderReceiptPair);
            processTransferOrderReceipt(transferOrderReceiptPair);
        }
	}

	public static void processPurchaseOrderReceipt(List<purchaseOrderReceipt> purchaseOrderReceiptProcess){
		//System.debug('Lets process this' + purchaseOrderReceiptProcess);
		List<Id> productSerialIds = new List<Id>();
		Boolean poReceiptLineProcessError = false;
		for(purchaseOrderReceipt por : purchaseOrderReceiptProcess){
			gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c();  
			poReceipt.gii__PurchaseOrder__c = por.purchaseOrderValue;
			poReceipt.gii__ReceiptDate__c = System.today();
			DataBase.SaveResult result = Database.Insert(poReceipt, false);
			Id PurchaseOrderReceiptId = null;
			ID productSerialID = null;
			if (result.isSuccess()) {
				PurchaseOrderReceiptId = result.getId();
				//System.debug(('PurchaseOrderReceiptId ID is::'+PurchaseOrderReceiptId);
			}
			else {
				Database.Error err = result.getErrors()[0];
				System.debug(' EXCEPTION : ' + err.getMessage());
				throw new DMLException (err.getMessage());
			} 
			//System.debug(('Product Serial is -> '+por.productSerialValue);
			if(por.productSerialValue !=  '' && por.productSerialValue !=  null){
				List<gii__ProductSerial__c> pSerialLst = new List<gii__ProductSerial__c>();
				for(String psStr: por.productSerialValue.split(',') ){
					if(psStr != null && psStr != ''){
						gii__ProductSerial__c pSerial = new gii__ProductSerial__c();
						pSerial.Name = psStr;
						pSerial.gii__Product__c = por.productValue;
						pSerialLst.add(pSerial);
					}
				}
                //System.debug(('pSerialLst is::'+pSerialLst);
				if(pSerialLst != null && !pSerialLst.isEmpty()){
					//System.debug(('Insert pSerialLst ::'+pSerialLst);
					DataBase.SaveResult[] productSerialresult = Database.Insert(pSerialLst, false);
					//System.debug(('Result productSerialresult ::'+productSerialresult);
					for(Database.SaveResult sr: productSerialresult){
						if(sr.isSuccess()) {
							//System.debug(('Product Serial ID is '+sr.getId());
							productSerialIds.add(sr.getId());
							//System.debug(('Product Serial List is '+productSerialIds);
						}
						else {
							for(Database.Error err : sr.getErrors()){
								System.debug('The following error has occurred.');                    
								System.debug(err.getStatusCode() + ': ' + err.getMessage());
								System.debug('Account fields that affected this error: ' + err.getFields());
							}
						}
					}
				}
			}
            //System.debug(('productSerialIds is::'+productSerialIds);
			if(PurchaseOrderReceiptId != null){
				String errorMsg = '';
				/*if(productSerialID != null)
				{
					poReceiptLine.gii__ProductSerial__c = productSerialID;
				}*/
				List<gii__PurchaseOrderReceiptLine__c> poReceiptLineLst = new List<gii__PurchaseOrderReceiptLine__c>();
				if(productSerialIds != null && !productSerialIds.isEmpty()){
					for(Id psId: productSerialIds){
						//System.debug(('for productSerialIds ::');
						gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
						poReceiptLine.gii__PurchaseOrderReceipt__c = PurchaseOrderReceiptId;
						poReceiptLine.gii__PurchaseOrderLine__c = por.purchaseOrderLineValue;
						poReceiptLine.gii__BuyingUMReceivedQuantity__c = 1; //Quantity must be 1 for the serial controlled
						poReceiptLine.gii__Location__c = por.locationValue;
						if(por.locationBinValue != null && por.locationBinValue != ''){
							poReceiptLine.gii__LocationBin__c = por.locationBinValue;
						}
						poReceiptLine.gii__ProductSerial__c = psId;
						poReceiptLineLst.add(poReceiptLine);
					}
				}
				else{
					gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
					poReceiptLine.gii__PurchaseOrderReceipt__c = PurchaseOrderReceiptId;
					poReceiptLine.gii__PurchaseOrderLine__c = por.purchaseOrderLineValue;
					poReceiptLine.gii__BuyingUMReceivedQuantity__c = Integer.valueOf(por.quantityValue);
					poReceiptLine.gii__Location__c = por.locationValue;
					if(por.locationBinValue != null && por.locationBinValue != ''){
						poReceiptLine.gii__LocationBin__c = por.locationBinValue;
					}
					poReceiptLineLst.add(poReceiptLine);
				}

                //System.debug(('poReceiptLineLst is::'+poReceiptLineLst);
                DataBase.SaveResult[] receiptLineresult = Database.Insert(poReceiptLineLst, false);
				
				for(DataBase.SaveResult dbsr: receiptLineresult){
					if (!dbsr.isSuccess()) {
						Database.Error errReceiptLineProcess = dbsr.getErrors()[0];
						errorMsg = errReceiptLineProcess.getMessage();
						System.debug(' receiptLineresult ::' +errorMsg);
						poReceiptLineProcessError = true;
					} 
				}
				if (poReceiptLineProcessError) {
					List<gii__PurchaseOrderReceiptLine__c> poReceiptLine = new List<gii__PurchaseOrderReceiptLine__c>([select id from gii__PurchaseOrderReceiptLine__c where gii__PurchaseOrderReceipt__c =: PurchaseOrderReceiptId]); 
					delete poReceiptLine;
					
					gii__PurchaseOrderReceipt__c poReceiptDelete = [select id from gii__PurchaseOrderReceipt__c where ID =: PurchaseOrderReceiptId]; 
					delete poReceiptDelete;
					throw new DMLException (errorMsg);
				} 
			}
		} 
	}

	public static void processTransferOrderReceipt(List<transferOrderReceipt> transferOrderReceiptProcess){
		Map<Id,Id> mapReceiptQueueLocation = new Map<ID, Id>();
		Map<Id,Id> mapReceiptQueueLocationBin = new Map<ID, Id>();
		Map<Id,Id> maptransferOrderLineLocation = new Map<ID, Id>();
		Map<Id,Id> mapTOLineLocationBin = new Map<ID, Id>();
		Map<Id,Id> mapReceiptQueuetransferOrderLoine = new Map<ID, Id>();
		List<gii__ReceiptQueue__c> receiptQueueList = new List<gii__ReceiptQueue__c>();
		//List<ID> transferOrderLineRecords = new List<ID>();
		List<String> productSerialList = new List<String>();
		//System.debug('processTransferOrderReceipt :: transferOrderReceiptProcess :: '+transferOrderReceiptProcess);
		for(transferOrderReceipt tor : transferOrderReceiptProcess) {
			//transferOrderLineRecords.add(tor.transferOrderLineValue);
			maptransferOrderLineLocation.put(tor.transferOrderLineValue , tor.transferOrderLinelocationValue);
			if(String.isNotBlank(tor.transferOrderLineproductSerialValue)){
                productSerialList.addAll(tor.transferOrderLineproductSerialValue.split(','));
				//System.debug('processTransferOrderReceipt :: productSerialList :: '+productSerialList);
            }
			if(String.isNotBlank(tor.transferOrderLinelocationBinValue)){
                mapTOLineLocationBin.put(tor.transferOrderLineValue , tor.transferOrderLinelocationBinValue);
            }
		}
		if(productSerialList != null && !productSerialList.isEmpty()){
			//System.debug('processTransferOrderReceipt :: receiptQueueList :: Query');
			receiptQueueList = [SELECT id, gii__TransferOrderLine__c from gii__ReceiptQueue__c WHERE gii__TransferOrderLine__c IN : maptransferOrderLineLocation.keySet() AND gii__ProductSerial__r.Name IN: productSerialList];
		}
		else{
			//System.debug('processTransferOrderReceipt :: query :: ');
			receiptQueueList = [SELECT id, gii__TransferOrderLine__c from gii__ReceiptQueue__c WHERE gii__TransferOrderLine__c IN : maptransferOrderLineLocation.keySet()];
		}
		//System.debug('processTransferOrderReceipt :: receiptQueueList :: '+receiptQueueList);
		for(gii__ReceiptQueue__c rq : receiptQueueList){
			mapReceiptQueueLocation = new Map<ID, Id>();
			mapReceiptQueueLocationBin = new Map<ID, Id>();
			mapReceiptQueueLocation.put(rq.id , maptransferOrderLineLocation.get(rq.gii__TransferOrderLine__c));
			gii.TransferOrderReceipt.ReceiptCreationInput inputObj = new gii.TransferOrderReceipt.ReceiptCreationInput();
			inputObj.mapReceiptQueueLocation = mapReceiptQueueLocation;
			inputObj.ReceiptDate = system.today(); //assign receipt date
			if(mapTOLineLocationBin != null && !mapTOLineLocationBin.isEmpty() && mapTOLineLocationBin.containsKey(rq.gii__TransferOrderLine__c)){
				mapReceiptQueueLocationBin.put(rq.id , mapTOLineLocationBin.get(rq.gii__TransferOrderLine__c));
				inputObj.mapReceiptQueueLocationBin = mapReceiptQueueLocationBin;
			}
			gii.TransferOrderReceipt.TransferOrderReceiptsResult Result = new gii.TransferOrderReceipt.TransferOrderReceiptsResult();
			Result = gii.TransferOrderReceipt.getReceiptsforReceiptQueues(inputObj);
            //System.debug('processTransferOrderReceipt :: Check This result ::' + Result);
			if (Result.Exceptions != null) {
				if(Result.Exceptions.size() > 0) {
					throw new DMLException (Result.Exceptions[0].getMessage());
				}
			}
		}
		//System.debug('Receipt Queue and Location ->'+mapReceiptQueueLocation);
	}
	
	@AuraEnabled(cacheable=true)
    public static List<WareHouseUserWrapper> getLoggedInUserDefaultWarehouse(){
		List<WareHouseUserWrapper> whuWrapeList = new List<WareHouseUserWrapper>();
		for(gii__WarehouseUser__c whu: [Select Id, Name, gii__Active__c, gii__DefaultWarehouse__c, gii__DefaultWarehouse__r.Name , gii__User__c from gii__WarehouseUser__c where gii__Active__c =: true and gii__User__c =: Userinfo.getUserId() limit 1]){
			WareHouseUserWrapper whup = new WareHouseUserWrapper();
            whup.defaultWareHouseId = whu.gii__DefaultWarehouse__c;
            whup.defaultWareHouseName = whu.gii__DefaultWarehouse__r.Name;
			whuWrapeList.add(whup);
		}
        if(!whuWrapeList.isEmpty()){
		    return whuWrapeList;
        }
        return null;
	}

    @AuraEnabled(cacheable=true)
    public static List<ReceiptQueueWrapper> getReceiptQueueforTOL(String transferOrderLine){
		List<ReceiptQueueWrapper> receiptQueueList = new List<ReceiptQueueWrapper>();
        if(String.isNotBlank(transferOrderLine)){
			Id transferOrderLineId = Id.valueOf(transferOrderLine);
			for(gii__ReceiptQueue__c rq:[SELECT Id, Name, gii__ProductSerial__r.Name from gii__ReceiptQueue__c WHERE gii__TransferOrderLine__c =: transferOrderLineId AND gii__ProductSerial__c != null]){
				ReceiptQueueWrapper rqw = new ReceiptQueueWrapper();
				rqw.ReceiptQueueId = rq.Id;
				rqw.ReceiptQueueName = rq.Name;
				rqw.ProductSerialName = rq.gii__ProductSerial__r.Name;
				receiptQueueList.add(rqw);
			}
        }
		if(!receiptQueueList.isEmpty()){
		    return receiptQueueList;
        }
        return null;
	}
	
	@AuraEnabled(cacheable=true)
    public static List<OrderLineWrapper> getPOLineQuantity(String purchaseOrderLine){
		List<OrderLineWrapper> poLineList = new List<OrderLineWrapper>();
        if(String.isNotBlank(purchaseOrderLine)){
			Id purchaseOrderLineId = Id.valueOf(purchaseOrderLine);
			for(gii__PurchaseOrderLine__c pol:[SELECT Id, gii__OrderQuantity__c, gii__ReceivedQuantity__c from gii__PurchaseOrderLine__c WHERE Id =: purchaseOrderLineId]){
				OrderLineWrapper polWrap = new OrderLineWrapper();
				if(String.isNotBlank(String.valueOf(pol.gii__ReceivedQuantity__c))){
					polWrap.receivedQuantity = String.valueOf(pol.gii__OrderQuantity__c - pol.gii__ReceivedQuantity__c);
				}
				else{
					polWrap.receivedQuantity = String.valueOf(pol.gii__OrderQuantity__c); 
				}
				poLineList.add(polWrap);
			}
        }
		if(!poLineList.isEmpty()){
		    return poLineList;
        }
        return null;
	}

    @AuraEnabled(cacheable=true)
    public static List<Id> getIsLocationBinControlled(String locId){
		if(String.isNotBlank(locId)){
			Set<Id> locIds = new Set<Id>();
			List<Id> binCtrlLoc = new List<Id>();
			for(String idStr: locId.split(',')){
                if(String.isNotBlank(idStr)){
                    locIds.add(Id.valueOf(idStr));
                }
			}
			for(gii__Location__c loc:[select id, gii__BinControlled__c from gii__Location__c where Id IN: locIds AND gii__BinControlled__c = true]){
				binCtrlLoc.add(loc.Id);
			}
			if(binCtrlLoc != null && !binCtrlLoc.isEmpty()){
				return binCtrlLoc;
			}
		}
		return null;
	}
	
	public static Map<Id,List<gii__Location__c>> getLocationDetails(List<String> warehouseKeyValue){
		//System.debug('getLocationDetails :: warehouseKeyValue ::'+warehouseKeyValue);
		Map<Id,List<gii__Location__c>> locMap = new Map<Id,List<gii__Location__c>>();
		List<gii__Location__c> locationList = new List<gii__Location__c>();
		for(gii__Location__c loc : [select id, giic_ABC_Class__c, gii__Warehouse__c from gii__Location__c where gii__Warehouse__r.Name IN: warehouseKeyValue and giic_ABC_Class__c != Null])
		{
			//System.debug('getLocationDetails :: loc.gii__Warehouse__c ::'+loc.gii__Warehouse__c);
			//System.debug('getLocationDetails :: loc ::'+loc);
			if(!locMap.containsKey(loc.gii__Warehouse__c)){
				locationList = new List<gii__Location__c>();
				locationList.add(loc);		
				locMap.put(loc.gii__Warehouse__c,locationList);
			}
			else{
				locationList = locMap.get(loc.gii__Warehouse__c);
				locationList.add(loc);
				locMap.put(loc.gii__Warehouse__c,locationList);
			}
			//System.debug('getLocationDetails :: locMap ::'+locMap);
		}
		//System.debug('getLocationDetails :: locMap :: return ::'+locMap);
		return locMap;
    }
    
	public static Map<Id, List<gii__LocationBin__c>> getLocationBinDetails(List<Id> locList){
		//System.debug('getLocationBinDetails :: locList ::'+locList);
		List<gii__LocationBin__c> locationBinList = new List<gii__LocationBin__c>();
		Map<Id,List<gii__LocationBin__c>> locBinMap = new Map<Id,List<gii__LocationBin__c>>();
		for(gii__LocationBin__c locBin : [select id,giic_ABC_Class__c, gii__Location__c from gii__LocationBin__c where gii__Location__c in : locList and giic_ABC_Class__c != Null])
		{
			//System.debug('locBin.gii__Location__c :: locList ::'+locBin.gii__Location__c);
			//System.debug('locBin.gii__Location__c :: locBin ::'+locBin);
			if(!locBinMap.containsKey(locBin.gii__Location__c)){
				locationBinList = new List<gii__LocationBin__c>();
				locationBinList.add(locBin);		
				locBinMap.put(locBin.gii__Location__c,locationBinList);
			}
			else{
				locationBinList = locBinMap.get(locBin.gii__Location__c);
				locationBinList.add(locBin);
				locBinMap.put(locBin.gii__Location__c,locationBinList);
			}
			//System.debug('locBin.gii__Location__c :: locBinMap ::'+locBinMap);
		}
		//System.debug('locBin.gii__Location__c :: locBinMap :: return ::'+locBinMap);
		return locBinMap;
	}
	
	public static Map<Id, List<Id>> getProductInventoryDetails(List<Id> productIds){
		//System.debug('getProductInventoryDetails :: productIds ::'+productIds);
		List<Id> abcClassList = new List<Id>();
		Map<Id,List<Id>> piAbcClassMap = new Map<Id,List<String>>();
		for(gii__ProductInventory__c prodInvent : [select id, giic_ABC_Class__c, gii__Warehouse__c, gii__Product__c from gii__ProductInventory__c where gii__Product__c IN: productIds AND giic_ABC_Class__c != Null])
		{
			//System.debug('getProductInventoryDetails :: prodInvent ::'+prodInvent);
			//System.debug('getProductInventoryDetails :: prodInvent.gii__Product__c ::'+prodInvent.gii__Product__c);
			if(!piAbcClassMap.containsKey(prodInvent.gii__Product__c)){
				abcClassList = new List<Id>();
				abcClassList.add(prodInvent.giic_ABC_Class__c);		
				piAbcClassMap.put(prodInvent.gii__Product__c,abcClassList);
			}
			else{
				abcClassList = piAbcClassMap.get(prodInvent.gii__Product__c);
				abcClassList.add(prodInvent.giic_ABC_Class__c);
				piAbcClassMap.put(prodInvent.gii__Product__c,abcClassList);
			}
			//System.debug('getProductInventoryDetails :: piAbcClassMap ::'+piAbcClassMap);
		}
		//System.debug('getProductInventoryDetails :: piAbcClassMap :: retunr ::'+piAbcClassMap);
		return piAbcClassMap;
	}
	
	public static List<Id> getLocationIds(Map<Id,List<gii__Location__c>> locationDetails){
		//System.debug('getLocationIds :: locationDetails ::'+locationDetails);
		List<Id> locationIds = new List<Id>();
		for(Id whId: locationDetails.keySet()){
			//System.debug('getLocationIds :: whId ::'+whId);
			for(gii__Location__c loc: locationDetails.get(whId)){
				//System.debug('getLocationIds :: loc ::'+loc);
				if(!locationIds.contains(loc.Id)){
					locationIds.add(loc.Id);
				}
			}
		}
		//System.debug('getLocationIds :: locationIds :: retunr ::'+locationIds);
		return locationIds;
	}
	
	public class OrderLineWrapper{ 
        @AuraEnabled public gii__PurchaseOrderLine__c objPurchaseOrderLine{get;set;}
        @AuraEnabled public gii__TransferOrderLine__c objTransferOrderLine{get;set;}
        @AuraEnabled public string warehouseId{get;set;}
        @AuraEnabled public string RecordURL{get;set;}
        @AuraEnabled public string purchaseOrderRecordURL{get;set;}
        @AuraEnabled public string purchaseOrderLineRecordURL{get;set;}
        @AuraEnabled public string transferOrderRecordURL{get;set;}
        @AuraEnabled public string transferOrderLineRecordURL{get;set;}
        @AuraEnabled public string productRecordURL{get;set;}
        @AuraEnabled public string warehouseName{get;set;}
        @AuraEnabled public string purchaseOrderId{get;set;}
        @AuraEnabled public string purchaseOrderName{get;set;}
        @AuraEnabled public string purchaseOrderLineId{get;set;}
        @AuraEnabled public string purchaseOrderLineName{get;set;}
        @AuraEnabled public string productId{get;set;}
        @AuraEnabled public string productName{get;set;}
        @AuraEnabled public Boolean serialproductChecked{get;set;}
        @AuraEnabled public String productSerialVal{get;set;}
        @AuraEnabled public string quantity{get;set;}
		@AuraEnabled public string receivedQuantity{get;set;}
        @AuraEnabled public string transferOrderId{get;set;}
        @AuraEnabled public string transferOrderName{get;set;}
        @AuraEnabled public string transferOrderLineId{get;set;} 
		@AuraEnabled public string transferOrderLineName{get;set;} 
        @AuraEnabled public Id locationId{get;set;} 
        @AuraEnabled public Id locationBinId{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
	}

    public class purchaseOrderReceipt {
		public string purchaseOrderValue{get;set;}
		public string purchaseOrderLineValue{get;set;}
		public string quantityValue{get;set;}
		public string locationValue{get;set;}
		public string locationBinValue{get;set;}
		public string productSerialValue ;
		public string productValue{get;set;}
    }

    public class transferOrderReceipt {
        public string transferOrderValue{get;set;}
        public string transferOrderLineValue{get;set;}
        public string transferOrderLinequantityValue{get;set;}
        public string transferOrderLinelocationValue{get;set;}
        public string transferOrderLinelocationBinValue{get;set;}
        public string transferOrderLineproductSerialValue{get;set;}
        public string transferOrderproductValue{get;set;}
    }
	
	public class WareHouseUserWrapper{ 
        @AuraEnabled public string defaultWareHouseId {get;set;}
        @AuraEnabled public string defaultWareHouseName {get;set;}  
    }
	
	public class ReceiptQueueWrapper{ 
		@AuraEnabled public string ReceiptQueueId {get;set;}
        @AuraEnabled public string ReceiptQueueName {get;set;}
        @AuraEnabled public string ProductSerialName {get;set;}  
    }
}