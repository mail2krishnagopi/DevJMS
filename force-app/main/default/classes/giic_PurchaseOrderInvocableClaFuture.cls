/**
 * @description       : 
 * @author            : himanshu.kumar@fujitsu.com
 * @group             : 
 * @last modified on  : 11-04-2023
 * @last modified by  : himanshu.kumar@fujitsu.com
**/
global class giic_PurchaseOrderInvocableClaFuture {
    @future
    public static void processRecords(String POID ,list<String> listSTLIds)
    {  
        Map<Id,gii__ServiceTicketLine__c> prdsrl = new Map<ID,gii__ServiceTicketLine__c>();
        list<gii__ServiceTicketLine__c> poLinesToCreate =[select id,gii__ServiceTicket__c ,
                                                              gii__Product__c,gii__Quantity__c,
                                                              gii__FieldServiceEngineer__c,
                                                              gii__ServiceTicketLineStatus__c,
                                                              gii__FieldServiceEngineer__r.gii__Warehouse__c,
                                                              gii__FieldServiceEngineer__r.gii__Supplier__c,
                                                              gii__FieldServiceEngineer__r.gii__ThirdPartySupplier__c,
                                                              gii__AssetReference__c,gii__AssetReference__r.id,
                                                              gii__AssetReference__r.gii__ProductSerial__c
                                                              from gii__ServiceTicketLine__c
                                                              where id=:listSTLIds ];
        for (gii__ServiceTicketLine__c serLine : poLinesToCreate) {
            
            prdsrl.put(serLine.Id,serLine);
            
        }
                                                              
       list<gii__PurchaseOrderLine__c> purLinesToInsert=[select id, gii__ServiceTicketLine__c,
                                                         gii__OrderQuantity__c,gii__PurchaseOrder__c,
                                                         gii__ReceiptStatus__c,gii__Product__c,
                                                         gii__ServiceTicket__c,gii__ShipTo__c,
                                                         gii__ShipTo__r.gii__DefaultReceivingLocation__c
                                                         from gii__PurchaseOrderLine__c
                                                         where gii__PurchaseOrder__c=:POID];
        
        // create list for purchase order receipts
                    List<gii__PurchaseOrderReceipt__c> listPurchaseOrderReceipt = new List<gii__PurchaseOrderReceipt__c>();
                    
                    // create the purchase order receipt sObject and populate its required fields, and optionally other fields.
                    gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c();
                    // Set the record id of Purchase Order and receipt date;
                    poReceipt.gii__PurchaseOrder__c = POID; //Purchase order id which is required.
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
				
                    
        
    }

}