/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-02-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class giic_CreatePurchaseOrder {
    @AuraEnabled(cacheable=true)
    public static List<ServiceWrapper> getServiceTicketLine(string serTickId){
        try{
            List<gii__ServiceTicketLine__c> serLst = new List<gii__ServiceTicketLine__c>();
            Set<Id> servicelineIds = new Set<Id>();
            for (gii__ServiceTicketLine__c serviceLine : [SELECT Id,Name,gii__ServiceTicket__c,gii__IsClosed__c,gii__Product__c,gii__Product__r.name,
                                                          gii__AssetReference__c,giic_SalesOrder__c,gii__AssetReference__r.name,gii__ServiceDueDate__c,gii__AssetReference__r.gii__ProductSerial__c,
                                                          gii__Quantity__c, gii__TotalActualCost__c,gii__FieldServiceEngineer__r.gii__Supplier__r.Name,
                                                          gii__FieldServiceEngineer__r.gii__Warehouse__c,gii__FieldServiceEngineer__r.gii__Warehouse__r.gii__DefaultReceivingLocation__c
                                                          FROM gii__ServiceTicketLine__c WHERE gii__ServiceTicket__c =: serTickId]) {
                                                              serLst.add(serviceLine);
                                                              servicelineIds.add(serviceLine.Id);
                                                          }
            
            Map<Id,gii__PurchaseOrderLine__c> serviceLineToPurchaseMap = new Map<Id,gii__PurchaseOrderLine__c>();
            for (gii__PurchaseOrderLine__c purchaseOrderLine : [SELECT gii__ServiceTicketLine__c FROM gii__PurchaseOrderLine__c WHERE gii__ServiceTicketLine__c IN:servicelineIds]) {
                serviceLineToPurchaseMap.put(purchaseOrderLine.gii__ServiceTicketLine__c, purchaseOrderLine);
            }
            List<gii__PurchaseOrder__c> purchaseOrders = new List<gii__PurchaseOrder__c>();
            purchaseOrders = [SELECT gii__ServiceTicket__c FROM gii__PurchaseOrder__c WHERE gii__ServiceTicket__c =:serTickId];
            Boolean isPurchaseOrderExists = false;
            if (purchaseOrders != null && !purchaseOrders.isEmpty()) {
                isPurchaseOrderExists = true;
            }
            ServiceWrapper[] serWrapList = new ServiceWrapper[]{};
                for (gii__ServiceTicketLine__c serviceLine : serLst) {
                    ServiceWrapper service = new ServiceWrapper();
                    service.isPurchaseOrderExists = isPurchaseOrderExists;
                    service.serviceLine = serviceLine;
                    if (serviceLineToPurchaseMap.containsKey(serviceLine.Id)) {
                        service.isLineDetailExits = true;
                    } else {
                        service.isLineDetailExits = false;
                    }
                    service.isSelected = false;
                    serWrapList.add(service);
                }
            return serWrapList;
        }catch(exception e){
            system.debug(e.getmessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static string createPoRecords(String recordJson) {
        
        try{
            System.debug('recordJson,...'+recordJson);
            ServiceWrapper[] serviceWrapList = new ServiceWrapper[] {};
                serviceWrapList = (ServiceWrapper[])JSON.deserialize(recordJson, ServiceWrapper[].class);
            System.debug('serviceWrapList...'+serviceWrapList);
            /*if(true){
return null;
}*/
            Set<Id> serviceTicketIds = new Set<Id>();
            gii__ServiceTicketLine__c[] poLinesToCreate = new gii__ServiceTicketLine__c[]{};
                Boolean isPONeedToCreate = false;
            for (ServiceWrapper serWrap : serviceWrapList) {
                serviceTicketIds.add(serWrap.serviceLine.gii__ServiceTicket__c);
                if (serWrap.isSelected == true && serWrap.isLineDetailExits == false) {
                    poLinesToCreate.add(serWrap.serviceLine);
                }
                if (serWrap.isPurchaseOrderExists == false) {
                    isPONeedToCreate = true;
                }
                
            }
            Map<string,string> seLinWhrids = new Map<string,string>();
            Map<string,string> serlineLoc = new Map<string,string>();
            Map<string,string> locationmap = new Map<string,string>();
            string locId ; 
           
            gii__PurchaseOrder__c purchaseOrder = new gii__PurchaseOrder__c();
            if (isPONeedToCreate == true) {
                gii__ServiceTicket__c[] serviceTicketList = [SELECT gii__Account__c FROM gii__ServiceTicket__c WHERE Id IN:serviceTicketIds];
                gii__ServiceTicketLine__c stl=[select id,gii__ServiceTicket__c,gii__FieldServiceEngineer__r.gii__Warehouse__c,gii__FieldServiceEngineer__r.gii__Supplier__c,gii__TotalActualCost__c  from gii__ServiceTicketLine__c where gii__ServiceTicket__r.id IN: serviceTicketIds limit 1];
                purchaseOrder.gii__ServiceTicket__c = serviceTicketList[0].Id;
                //purchaseOrder.gii__Supplier__c = serviceTicketList[0].gii__Account__c;
                if(stl!=null){
                    purchaseOrder.gii__Supplier__c = stl.gii__FieldServiceEngineer__r.gii__Supplier__c;
                    purchaseOrder.gii__ShipTo__c = stl.gii__FieldServiceEngineer__r.gii__Warehouse__c;
                }
                insert purchaseOrder;
                
            } else {
                purchaseOrder = [SELECT gii__ServiceTicket__c FROM gii__PurchaseOrder__c WHERE gii__ServiceTicket__c IN:serviceTicketIds LIMIT 1];
            }
                /*  system.debug('poLinesToCreate>>> '+poLinesToCreate);  
                  system.debug('!poLinesToCreate.isEmpty()>>> '+(!poLinesToCreate.isEmpty())); 
                  if (!poLinesToCreate.isEmpty()) {
                   // for (gii__ServiceTicketLine__c serLine : poLinesToCreate) {
                       // if(purchaseOrder.gii__ShipTo__r.gii__DefaultReceivingLocation__c != null){
                        locId = purchaseOrder.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
                       // }else{
                            //seLinWhrids.put(serLine.Id,purchaseOrder.gii__ShipTo__c);
                       // }
                   // }
                     system.debug('seLinWhrids '+seLinWhrids);
                    system.debug('seLinWhrids.values() '+seLinWhrids.values());
                    if(purchaseOrder.gii__ShipTo__r.gii__DefaultReceivingLocation__c != null){
                    List<gii__Location__c> locslst = [SELECT id,gii__Warehouse__c FROM gii__Location__c WHERE gii__Warehouse__c = : purchaseOrder.gii__ShipTo__c];
                        if(!locslst.isEmpty()){
                        locId = locslst[0].Id;
                        }
                    }
                    system.debug('### '+seLinWhrids);
                    system.debug('### '+serlineLoc);
                    if(locId == null){
                        return 'Error No Location for Warehouse';
                    }
                }*/
                Map<Id,gii__ServiceTicketLine__c> prdsrl = new Map<ID,gii__ServiceTicketLine__c>();
            if (!poLinesToCreate.isEmpty()) {
                gii__PurchaseOrderLine__c[] purLinesToInsert = new gii__PurchaseOrderLine__c[]{};
                    for (gii__ServiceTicketLine__c serLine : poLinesToCreate) {
                        gii__PurchaseOrderLine__c purLine = new gii__PurchaseOrderLine__c();
                        purLine.gii__ServiceTicketLine__c = serLine.Id;
                        purLine.gii__OrderQuantity__c = serLine.gii__Quantity__c;
                        //purLine.gii__NoChargeReason__c = 'Sample';
                        purLine.gii__PurchaseOrder__c = purchaseOrder.Id;
                        purLine.gii__ReceiptStatus__c	= 'Open';
                        //purLine.gii__SalesOrder__c = serLine.giic_SalesOrder__c;
                        purLine.gii__Product__c = serLine.gii__Product__c;
                        //purLine.gii__SalesOrderLine__c = serLine.giic_SalesOrderLine__c;
                        purLine.gii__ServiceTicket__c = serLine.gii__ServiceTicket__c;
                        purLine.gii__ServiceTicketLine__c = serLine.Id;	
                        purLine.gii__UnitPrice__c = serLine.gii__TotalActualCost__c;
                        purLinesToInsert.add(purLine);
                        prdsrl.put(serLine.Id,serLine);
                        
                    }
                
                if (!purLinesToInsert.isEmpty()) {
                    
                    insert purLinesToInsert;
                    system.debug('### : '+purLinesToInsert[0].gii__ReceiptStatus__c);
                }
                
                //Id PurchaseOrderId = 'a0tG0000004wxQQ'; //Purchase Order Id 
                // create list for purchase order receipts
                List<gii__PurchaseOrderReceipt__c> listPurchaseOrderReceipt = new List<gii__PurchaseOrderReceipt__c>();
                
                // create the purchase order receipt sObject and populate its required fields, and optionally other fields.
                gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c();
                
                // Set the record id of Purchase Order and receipt date;
                poReceipt.gii__PurchaseOrder__c = purchaseOrder.Id; //Purchase order id which is required.
                poReceipt.gii__ReceiptDate__c   = System.today();  //Receipt Date which is required. 
                
                
                listPurchaseOrderReceipt.add(poReceipt);
                
                // insert purchase order receipt 
                DataBase.SaveResult[] result = Database.Insert(listPurchaseOrderReceipt, false);
                
                // get purchase order Receipt id
                Id PurchaseOrderReceiptId;
                for (Database.SaveResult sr:result) {
                    if (sr.isSuccess()) {
                        PurchaseOrderReceiptId = sr.getId(); 
                        listPurchaseOrderReceipt.clear();
                    }
                    else {
                        Database.Error err = sr.getErrors()[0];
                        system.debug(' EXCEPTION : ' + err.getMessage());  
                    }
                }
                //PORL
                
                //Id PurchaseOrderReceiptId = 'a0sG0000006GEdQ'; //Purchase Order Receipt Id 
                //Id PurchaseOrderLineId    = 'a0qG0000004bG43'; //Purchase Order Line Id 
                //Id LocationId             = 'a2rG00000004Q0d'; //Location Id 
                /*Map<string,string> locationmap = new Map<string,string>();
List<gii__Location__c> locslst = [SELECT id,gii__Warehouse__c FROM gii__Location__c WHERE gii__Warehouse__c IN : seLinWhrids.values()];
for(gii__Location__c loc : locslst){
locationmap.put(loc.gii__Warehouse__c,loc.id);
}*/
                // create list for purchase order receipt lines
                List<gii__PurchaseOrderReceiptLine__c> listpoReceiptLine = new List<gii__PurchaseOrderReceiptLine__c>();
                if (PurchaseOrderReceiptId != null ) {
                    // create the purchase order receipt Line sObject and populate its required fields, and optionally other fields.
                    for (gii__PurchaseOrderLine__c serLineprl : purLinesToInsert) {
                        gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
                        poReceiptLine.gii__PurchaseOrderReceipt__c = PurchaseOrderReceiptId;
                        poReceiptLine.gii__ShipTo__c = serLineprl.gii__ShipTo__c;
                        poReceiptLine.gii__Product__c = serLineprl.gii__Product__c;
                        poReceiptLine.giic_IntegrationStatus__c = 'Submitted';
                        poReceiptLine.gii__ProductSerial__c = prdsrl.get(serLineprl.gii__ServiceTicketLine__c).gii__AssetReference__r.gii__ProductSerial__c;
                       /* if(serlineLoc.get(serLineprl.gii__ServiceTicketLine__c) != null){
                            poReceiptLine.gii__Location__c   = serlineLoc.get(serLineprl.gii__ServiceTicketLine__c);
                        }else if(locationmap.get(seLinWhrids.get(serLineprl.gii__ServiceTicketLine__c)) != null){
                            poReceiptLine.gii__Location__c   = locationmap.get(seLinWhrids.get(serLineprl.gii__ServiceTicketLine__c));
                        }else{
                            return 'Error No Location for Warehouse';
                            //break;
                        }*/
                        poReceiptLine.gii__Location__c = serLineprl.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
                        //gii__ProductInventoryQuantityDetail__c prdInv = getProdInv(seLinWhrids.get(serLineprl.gii__ServiceTicketLine__c),serLineprl.gii__Product__c);
                        //poReceiptLine.gii__ProductInventory__c	 = prdInv.gii__ProductInventory__c;
                        //poReceiptLine.gii__Location__c = prdInv.gii__Location__c;
                        //poReceiptLine.
                        // set the record id for the purchase order line
                        poReceiptLine.gii__PurchaseOrderLine__c = serLineprl.Id; 
                         //system.debug('+++ Total Cost'+serLineprl.gii__ServiceTicketLine__c+serLineprl.gii__ServiceTicketLine__r.name+serLineprl.gii__ServiceTicketLine__r.gii__TotalActualAmount__c );
                        system.debug('+++ Total Cost'+prdsrl.get(serLineprl.gii__ServiceTicketLine__c).gii__TotalActualCost__c);
						poReceiptLine.gii__UnitPrice__c = prdsrl.get(serLineprl.gii__ServiceTicketLine__c).gii__TotalActualCost__c;//Added by Manogna						
                        
                        system.debug('###'+poReceiptLine.gii__Location__c);
                        poReceiptLine.gii__BuyingUMReceivedQuantity__c    = serLineprl.gii__OrderQuantity__c;
                        // add line to the list
                        listpoReceiptLine.add(poReceiptLine);
                    }
                    /*if(!listpoReceiptLine.isEmpty()){
insert listpoReceiptLine;
}*/
                    // insert purchase order receipt lines
                    if (listpoReceiptLine.size() > 0) {
                        try {
                            insert listpoReceiptLine;
                        }
                        Catch(DMLException e) {
                            system.debug(e.getMessage());
                        }
                    }
                }
                
                
                
                
                
            }
            system.debug('Rec Id '+purchaseOrder.Id);
            return purchaseOrder.Id;
        }catch(exception e){
            system.debug(e.getMessage()+'####'+e.getlinenumber());
            return 'Error';
        }
        
    }
    
    public static gii__ProductInventoryQuantityDetail__c getProdInv(Id warId, Id prodId){
        List<gii__ProductInventoryQuantityDetail__c> prodInvlst = [SELECT Id,gii__ProductInventory__c,gii__Location__c FROM gii__ProductInventoryQuantityDetail__c WHERE gii__Product__c =: prodId AND gii__Warehouse__c =: warId LIMIT 1 ];
        if(!prodInvlst.isEmpty()){
            return prodInvlst[0];
        }else{
            return null;
        }
    }
    
    
    public class ServiceWrapper {
        @AuraEnabled
        public Boolean isPurchaseOrderExists;
        @AuraEnabled
        public Boolean isLineDetailExits;
        @AuraEnabled
        public gii__ServiceTicketLine__c serviceLine;
        @AuraEnabled
        public Boolean isSelected;
    }
}