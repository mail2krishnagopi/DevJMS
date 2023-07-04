public without sharing class giic_JMSCommonUtility
{

    /**************************************************
    Method  : quickShip
    Purpose : This method is used to Quick Ship the SO Lines
    *****************************************************/
    @InvocableMethod(label='QuickShip' description='Create Quick Ship for SO Line')
    public static void quickShip(List<Id> lstSOLIds){
        if(lstSOLIds != null && lstSOLIds.size() > 0){
            
            //List<gii__SalesOrderLine__c> lstSOLine = [Select Id, Name, gii__SalesOrder__c, gii__Product__c, gii__OrderQuantity__c FROM gii__SalesOrderLine__c WHERE Id IN : setSOLIds];
            
            /*
            //Create Inventory Reserve
            // map for sales order line ids and quantity to be reserved
            Map<Id,Double> mapSOLineQuantity = new Map<Id,Double>();
            for(gii__SalesOrderLine__c obj : lstSOLine){
                // build map for sales order line ids and quantity to be reserved
                mapSOLineQuantity.put(obj.Id, obj.gii__OrderQuantity__c);
            }
            Boolean  isNewSOLine = false; 
            String strAction = 'Partial Reservation';            
            // execute method to create inventory reservation records 
             try {
                gii.Reserve2.Reservations(mapSOLineQuantity, isNewSOLine, strAction);
            }catch(exception e){
                system.debug('Error : '+e.getMessage());
            }     
            */
            
            //Create Quick Ship
            List<Id> lstIRIds = new List<Id>();
            Map<id, id> invResMap = new Map<id,id>();
            List<gii__InventoryReserve__c> lstIR = [Select id, gii__Status__c ,gii__ProductSerial__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__SalesOrderLine__c FROM gii__InventoryReserve__c WHERE gii__SalesOrderLine__c IN : lstSOLIds];
             system.debug('lstIR::::>>'+lstIR);
             system.debug('lstIR::::>>'+lstIR[0].gii__Status__c);
            for(gii__InventoryReserve__c obj : lstIR){
                // add inventory reserve ids to the list
                lstIRIds.add(obj.Id);
                if(obj.gii__Product__r.gii__SerialControlled__c == true){
                    invResMap.put(obj.gii__SalesOrderLine__c, obj.gii__ProductSerial__c);
                }
            }
            String strGroupBy = 'SalesOrder';
            // get ship date string value in yyyy-MM-DD format
            String strShippedDate = system.today().year() + '-' + system.today().month() + '-' + system.today().day();   
            String strGroupByAndShippedDate = strGroupBy + ';' + strShippedDate;
            system.debug('lstIRIds::::'+lstIRIds);
            system.debug('strGroupByAndShippedDate::::'+strGroupByAndShippedDate);
            // execute method to create pick lists
            gii.OrderShipment.quickShip(lstIRIds, strGroupByAndShippedDate);
            
             system.debug('lstSOLIds::::'+lstSOLIds);
             List<gii__SalesOrderLine__c> testt = [Select Id, Name, gii__SalesOrder__c,gii__Site__c, 
                                                             gii__Product__c
                                                             FROM gii__SalesOrderLine__c 
                                                             WHERE Id IN : lstSOLIds 
                                                             AND gii__Status__c = 'Received'];
             system.debug('testt::::'+testt);
            //Update SO Line and Create Asset Reference
            List<gii__SalesOrderLine__c> lstShippedSOLine = new List<gii__SalesOrderLine__c>();
             lstShippedSOLine = [Select Id, Name, gii__SalesOrder__c,gii__Site__c, 
                                                             gii__Product__c, gii__Product__r.Name, 
                                                             gii__OrderQuantity__c,
                                                             gii__SalesOrder__r.gii__Account__c, 
                                                             (SELECT Id,gii__Site__c,
                                                              giic_Inventory_Reserve_Product_Serial__c 
                                                              FROM Service_Ticket_Lines__r) 
                                                             FROM gii__SalesOrderLine__c 
                                                             WHERE Id IN : lstSOLIds 
                                                             AND gii__Status__c = 'Received'];
            
            List<gii__AssetReference__c> lstAssetRef = new List<gii__AssetReference__c>();
             system.debug('lstShippedSOLine:'+ lstShippedSOLine);
            system.debug('lstShippedSOLine:size'+ lstShippedSOLine.size());
            system.debug('Inventory Reserve MAp:'+ invResMap);
            system.debug('Inventory Reserve MAp:.size()'+ invResMap.size());
            
            for(gii__SalesOrderLine__c obj : lstShippedSOLine){
                //Update Release Flag
                obj.giic_Released__c = true;
                //Create Asset Reference
                gii__AssetReference__c objAssetRef = new gii__AssetReference__c();
              
                objAssetRef.gii__ProductReference__c = obj.gii__Product__c;
                objAssetRef.gii__SalesOrder__c = obj.gii__SalesOrder__c;
                objAssetRef.gii__SalesOrderLine__c = obj.Id;
                objAssetRef.gii__Account__c = obj.gii__SalesOrder__r.gii__Account__c;
                objAssetRef.gii__Status__c = 'Installed'; //added
                objAssetRef.gii__InstallDate__c = system.today(); //added
                system.debug('Site Info from STL:'+ obj.Service_Ticket_Lines__r[0].gii__Site__c);
                objAssetRef.gii__Site__c = obj.Service_Ticket_Lines__r[0].gii__Site__c;//added
                if((invResMap.get(obj.Id) != Null) && (!invResMap.isempty()))
                {
                    system.debug('invResMap.get(obj.Id)'+invResMap.get(obj.Id)); 
                    objAssetRef.gii__ProductSerial__c = invResMap.get(obj.Id);
                }
                objAssetRef.Name = obj.gii__Product__r.Name + ' ' +obj.Service_Ticket_Lines__r[0].giic_Inventory_Reserve_Product_Serial__c;
                lstAssetRef.add(objAssetRef);
            }
            update lstShippedSOLine;
            insert lstAssetRef;
            
            //Update Asset Reference in Service Ticket Line
            List<gii__ServiceTicketLine__c> lstSTLine = new List<gii__ServiceTicketLine__c>();
            for(gii__SalesOrderLine__c objSOL : lstShippedSOLine){
                if(objSOL.Service_Ticket_Lines__r != null && objSOL.Service_Ticket_Lines__r.size() > 0){
                    for(gii__AssetReference__c objAR : lstAssetRef){
                        if(objSOL.Id == objAR.gii__SalesOrderLine__c){
                            objSOL.Service_Ticket_Lines__r[0].gii__AssetReference__c = objAR.Id;

                            lstSTLine.add(objSOL.Service_Ticket_Lines__r[0]);
                            break;
                        }
                    }//for objAR
                }
            }//for objSOL
            if(lstSTLine.size() > 0){
                update lstSTLine;
            }
        }
    }
}