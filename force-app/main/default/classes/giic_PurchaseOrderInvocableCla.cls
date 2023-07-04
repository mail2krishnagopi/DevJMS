/**
* @description       : 
* @author            : himanshu.kumar@fujistsu.com
* @group             : 
* @last modified on  : 15-02-2023
* @last modified by  : himanshu.kumar@fujistsu.com
**/
public with sharing class giic_PurchaseOrderInvocableCla {
    
    @InvocableMethod(label='Create Purchase Pecord' description='Returns Purchase record id')
    public static list<String> createPurchaseRecords(list<gii__ServiceTicket__c> listServiceTicket) { 
        list<String> returnResult =  new list<String>();
        
        system.debug('listServiceTicket>>'+listServiceTicket);
        system.debug('listServiceTicket[0]>>'+listServiceTicket[0]);
        list<gii__ServiceTicketLine__c> listServiceLineItem =[select id,gii__ServiceTicket__c ,
                                                              gii__Product__c,gii__Quantity__c,
                                                              gii__FieldServiceEngineer__c,
                                                              gii__ServiceTicketLineStatus__c,gii__Type__c, gii__Type__r.name,
                                                              gii__FieldServiceEngineer__r.gii__Warehouse__c,
                                                              gii__FieldServiceEngineer__r.gii__Supplier__c,
                                                              gii__FieldServiceEngineer__r.gii__ThirdPartySupplier__c,
                                                              gii__AssetReference__c,gii__AssetReference__r.id,
                                                              gii__AssetReference__r.gii__ProductSerial__c,gii__TotalActualCost__c,
                                                              giic_Total_Actual_Cost_Currency__c
                                                              from gii__ServiceTicketLine__c
                                                              where  gii__ServiceTicket__c =: listServiceTicket[0].id
                                                              AND
                                                              gii__ServiceTicketLineStatus__c='Closed'
                                                              AND
                                                              gii__AssetReference__c != null
                                                              AND
                                                              gii__FieldServiceEngineer__r.gii__ThirdPartySupplier__c =true
                                                              ];
        system.debug('listServiceLineItem>>'+listServiceLineItem);
        system.debug('listServiceLineItem.size>>'+listServiceLineItem.size());
        
       /* system.debug('listServiceLineItem.gii__FieldServiceEngineer__c>>'+listServiceLineItem[0].gii__FieldServiceEngineer__c);
        system.debug('listServiceLineItem.gii__Warehouse__c>>'+listServiceLineItem[0].gii__FieldServiceEngineer__r.gii__Warehouse__c);
        system.debug('listServiceLineItem.gii__Supplier__c>>'+listServiceLineItem[0].gii__FieldServiceEngineer__r.gii__Supplier__c);
        system.debug('listServiceLineItem.gii__AssetReference__c>>'+listServiceLineItem[0].gii__AssetReference__c);
        system.debug('listServiceLineItem.gii__ProductSerial__c>>'+listServiceLineItem[0].gii__AssetReference__r.gii__ProductSerial__c);
         
        */
         gii__Product2Add__c thirdPartySerProduct = [select id from gii__Product2Add__c where Name =: 'Third Party Service' limit 1];
        if(listServiceLineItem.size() > 0){
            
            try{
                Set<Id> serviceTicketIds = new Set<Id>();
                Set<Id>servicelineIds = new Set<Id>();
                for(gii__ServiceTicketLine__c stl : listServiceLineItem){
                    serviceTicketIds.add(stl.gii__ServiceTicket__c);
                    servicelineIds.add(stl.id);
                }
                
                // checking any  PO created or not 
                List<gii__PurchaseOrder__c> listPurchaseOrders = [SELECT gii__ServiceTicket__c ,gii__ShipTo__c,
                                                                  gii__ShipTo__r.gii__DefaultReceivingLocation__c
                                                                  FROM gii__PurchaseOrder__c 
                                                                  WHERE gii__ServiceTicket__c =:serviceTicketIds];
                
                Map<Id,gii__PurchaseOrderLine__c> serviceLineToPurchaseMap = new Map<Id,gii__PurchaseOrderLine__c>();
                // checking any POL created or not
                for (gii__PurchaseOrderLine__c purchaseOrderLine : [SELECT gii__ServiceTicketLine__c FROM gii__PurchaseOrderLine__c WHERE gii__ServiceTicketLine__c IN:servicelineIds]) {
                    serviceLineToPurchaseMap.put(purchaseOrderLine.gii__ServiceTicketLine__c, purchaseOrderLine);
                }
                
                // purchased line oitem to create for following service ticket line item
                // filtering the STL line if any already POL created that one STL removibg from list.
                
                list<gii__ServiceTicketLine__c> poLinesToCreate = new list<gii__ServiceTicketLine__c>();
                Set<String> setSTLIds = new Set<String>();
                for(gii__ServiceTicketLine__c serviceLine : listServiceLineItem){
                    if (!serviceLineToPurchaseMap.containsKey(serviceLine.Id)) {
                        poLinesToCreate.add(serviceLine);
                        setSTLIds.add(serviceLine.id);
                    }
                    
                }
                
                // check the purchased order  exit or not
                gii__PurchaseOrder__c purchaseOrder = new gii__PurchaseOrder__c();
                if(listPurchaseOrders.size() == 0){
                    
                   // gii__ServiceTicket__c[] serviceTicketList = [SELECT gii__Account__c FROM gii__ServiceTicket__c WHERE Id IN:serviceTicketIds];
                   // gii__ServiceTicketLine__c stl=[select id,gii__ServiceTicket__c,gii__FieldServiceEngineer__r.gii__Warehouse__c,gii__FieldServiceEngineer__r.gii__Supplier__c from gii__ServiceTicketLine__c where gii__ServiceTicket__r.id IN: serviceTicketIds limit 1];
                    purchaseOrder.gii__ServiceTicket__c = listServiceTicket[0].Id;
                   
                    system.debug('listServiceLineItem>>'+listServiceLineItem);
                    system.debug('listServiceLineItem.size>>'+listServiceLineItem.size());
                    system.debug('listServiceLineItem.gii__FieldServiceEngineer__c>>'+listServiceLineItem[0].gii__FieldServiceEngineer__c);
                    system.debug('listServiceLineItem.gii__Warehouse__c>>'+listServiceLineItem[0].gii__FieldServiceEngineer__r.gii__Warehouse__c);
                    system.debug('listServiceLineItem.gii__Supplier__c>>'+listServiceLineItem[0].gii__FieldServiceEngineer__r.gii__Supplier__c);
                    system.debug('listServiceLineItem[0]!=null>>'+(listServiceLineItem[0]!=null));
                    if(listServiceLineItem[0]!=null){
                        purchaseOrder.gii__Supplier__c = listServiceLineItem[0].gii__FieldServiceEngineer__r.gii__Supplier__c;
                        purchaseOrder.gii__ShipTo__c = listServiceLineItem[0].gii__FieldServiceEngineer__r.gii__Warehouse__c;
                    }
                    insert purchaseOrder;
                } else {
                    purchaseOrder = listPurchaseOrders[0];
                }
                 List<gii__PurchaseOrder__c> listPurchaseOrdersNew = [SELECT gii__ServiceTicket__c ,gii__ShipTo__c,
                                                                  gii__ShipTo__r.gii__DefaultReceivingLocation__c
                                                                  FROM gii__PurchaseOrder__c 
                                                                  WHERE id=: purchaseOrder.id];
                 system.debug('listPurchaseOrdersNew>>1 '+purchaseOrder);
                system.debug('listPurchaseOrdersNew>>2 '+purchaseOrder.gii__ShipTo__c);
                system.debug('listPurchaseOrdersNew>>3 '+purchaseOrder.gii__ShipTo__r.gii__DefaultReceivingLocation__c);
                
                system.debug('purchaseOrder>>1 '+purchaseOrder);
                system.debug('purchaseOrder>>2 '+purchaseOrder.gii__ShipTo__c);
                system.debug('purchaseOrder>>3 '+purchaseOrder.gii__ShipTo__r.gii__DefaultReceivingLocation__c);
                
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
                           purLine.gii__Product__c = thirdPartySerProduct.Id;
                            purLine.gii__UnitPrice__c = serLine.giic_Total_Actual_Cost_Currency__c;
                            purLine.gii__UnitCost__c = serLine.giic_Total_Actual_Cost_Currency__c;
                            //purLine.gii__SalesOrderLine__c = serLine.giic_SalesOrderLine__c;
                            purLine.gii__ServiceTicket__c = serLine.gii__ServiceTicket__c;
                            purLine.gii__ServiceTicketLine__c = serLine.Id;
                            //purLine.gii__ShipTo__c =purchaseOrder.gii__ShipTo__c ;
                            
                            purLinesToInsert.add(purLine);
                            prdsrl.put(serLine.Id,serLine);
                            
                        }
                    
                    if (!purLinesToInsert.isEmpty()) {
                        
                        insert purLinesToInsert;
                         system.debug('purLinesToInsert 1 : '+purLinesToInsert[0]);
                        system.debug('purLinesToInsert 2 : '+purLinesToInsert[0].gii__ShipTo__c);
                         system.debug('purLinesToInsert 3 : '+purLinesToInsert[0].gii__ShipTo__r.gii__DefaultReceivingLocation__c);
                        system.debug(' purLinesToInsert1 4 '+purLinesToInsert[0].gii__ReceiptStatus__c);
                    }
                    
                    if (purLinesToInsert.size() > 0) {
                        List<String> listSTLIds = new List<String>(setSTLIds);
                        giic_PurchaseOrderInvocableClaFuture.processRecords(purchaseOrder.Id ,listSTLIds);
                    }
                    /*
                    // create list for purchase order receipts
                    List<gii__PurchaseOrderReceipt__c> listPurchaseOrderReceipt = new List<gii__PurchaseOrderReceipt__c>();
                    
                    // create the purchase order receipt sObject and populate its required fields, and optionally other fields.
                    gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c();
                    // Set the record id of Purchase Order and receipt date;
                    poReceipt.gii__PurchaseOrder__c = purchaseOrder.Id; //Purchase order id which is required.
                    poReceipt.gii__ReceiptDate__c   = System.today();  //Receipt Date which is required. 
                    
                    listPurchaseOrderReceipt.add(poReceipt);
                     system.debug('listPurchaseOrderReceipt>>'+listPurchaseOrderReceipt);
                      system.debug('listPurchaseOrderReceipt.size>>'+listPurchaseOrderReceipt.size());
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
                     system.debug('PurchaseOrderReceiptId>>'+PurchaseOrderReceiptId);
                      //system.debug('listServiceLineItem.size>>'+listPurchaseOrderReceipt.size());
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
                            poReceiptLine.gii__Location__c = serLineprl.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
                            poReceiptLine.gii__PurchaseOrderLine__c = serLineprl.Id; 
                            system.debug('###'+poReceiptLine.gii__Location__c);
                            poReceiptLine.gii__BuyingUMReceivedQuantity__c    = serLineprl.gii__OrderQuantity__c;
                            // add line to the list
                            listpoReceiptLine.add(poReceiptLine);
                            
                            system.debug('ProductSeria>>'+prdsrl.get(serLineprl.gii__ServiceTicketLine__c).gii__AssetReference__r.gii__ProductSerial__c);
                            system.debug('servic Ticket line id>>'+prdsrl.get(serLineprl.gii__ServiceTicketLine__c).id);
                            system.debug('Assest id>>'+prdsrl.get(serLineprl.gii__ServiceTicketLine__c).gii__AssetReference__c);
         
                        }
                         system.debug('listpoReceiptLine>>'+listpoReceiptLine);
                      system.debug('listpoReceiptLine.size>>'+listpoReceiptLine.size());
                        // insert purchase order receipt lines
                        if (listpoReceiptLine.size() > 0) {
                            insert listpoReceiptLine;
                        }
                           system.debug('listpoReceiptLine>1>'+listpoReceiptLine);
                      system.debug('listpoReceiptLine.size>1>'+listpoReceiptLine.size());
                    }
                    */
                    
                    
                }
                
                system.debug('Rec Id '+purchaseOrder.Id);
                returnResult.add(purchaseOrder.Id);
                
            }catch(exception e){
                system.debug(e.getMessage()+'####'+e.getlinenumber());
                returnResult.add('Error' + e.getMessage());
                
            } 
        }
       
        if (returnResult.size() == 0) {
           returnResult.add('current record is not correct');
        }
        return returnResult; 
        
    }
}