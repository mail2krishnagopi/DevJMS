/**
 * @description       : 
 * @author            : himanshu.kumar@fujitsu.com
 * @group             : 
 * @last modified on  : 11-04-2023
 * @last modified by  : himanshu.kumar@fujitsu.com
**/
global  class giic_RMAProcessFlowFuture {
@future
    public static void processRecords(String stlId ,String rmaId,String rmaDetails)
    {   
               gii__ServiceTicketLine__c stlRec  = [select id ,gii__Site__c, gii__Site__r.gii__Account__c,
                                                    gii__Product__r.id,gii__AssetReference__r.gii__ProductSerial__c,
                                                    gii__Product__c,gii__AssetReference__c
                                                    from gii__ServiceTicketLine__c where id=:stlId];
      
        system.debug('ServiceTicketLine>>>>  ' + stlRec);
        system.debug('stlRec gii__Site__c>>> ' + stlRec.gii__Site__c);
        system.debug('stlRec gii__Site__r.ACC>>> ' + stlRec.gii__Site__r.gii__Account__c);
        
        
        system.debug('stlRec gii__Product__c>>> ' + stlRec.gii__Product__c);
        system.debug('stlRec gii__Product__c.Id>>> ' + stlRec.gii__Product__r.id); 
        
         system.debug('stlRec gii__AssetReference__c>>> ' + stlRec.gii__AssetReference__c);
        system.debug('stlRec gii__AssetReference__c.PS>>> ' + stlRec.gii__AssetReference__r.gii__ProductSerial__c); 
        
         gii__Site__c siteRecord   = [select id , gii__Account__c 
                                      from gii__Site__c  where id =: stlRec.gii__Site__c];
        system.debug(' siteRecord>>> ' + siteRecord);
        system.debug(' siteRecord Acc>>> ' + siteRecord.gii__Account__c);
        
        
       gii__AssetReference__c assetRefRecord =[select id , gii__ProductSerial__c 
                                 from gii__AssetReference__c where id=: stlRec.gii__AssetReference__c];
        system.debug(' assetRefRecord>>> ' + assetRefRecord);
        system.debug(' assetRefRecord PS>>> ' + assetRefRecord.gii__ProductSerial__c);
        
                gii__AccountAdd__c accRef = [select id,gii__DefaultWarehouse__c, gii__DefaultTransferToWarehouse__c, 
                                             gii__DefaultTransferToWarehouse__r.gii__DefaultRMADispositionLocation__c,
                                             gii__DefaultWarehouse__r.gii__DefaultRMADispositionLocation__c 
                                             from gii__AccountAdd__c 
                                             where gii__Account__c =:stlRec.gii__Site__r.gii__Account__c];

                List<gii__RMAReceipt__c> rmaRcpts = [Select Id from gii__RMAReceipt__c 
                                                     where gii__RMALineDetail__c= :rmaDetails];

        
        //RMA Disposition
        // list for RMA disposition information
        List<gii.RMACreation.RMADisposition> listRMADispositions = new List<gii.RMACreation.RMADisposition>();        
        // create RMA Disposition  
        gii.RMACreation.RMADisposition RMADisposition = new gii.RMACreation.RMADisposition();
        // record id for RMA receipt line
        RMADisposition.RMAReceiptId = rmaRcpts[0].Id;  
        // Quantity for scrap for the RMA receipt (Selling UM) 
        RMADisposition.DispositionLocationId = accRef.gii__DefaultTransferToWarehouse__r.gii__DefaultRMADispositionLocation__c;   
        RMADisposition.DispositionQuantity = 1;   
        
        // scrap date   
        RMADisposition.DispositionDate = system.today();  
        
        // add  to the list
        listRMADispositions.add(RMADisposition);
        
        //output for RMA Disposition Result for scrap
        gii.RMACreation.RMADispositionResult resultDisposition = new gii.RMACreation.RMADispositionResult();
        
        // call the method to create RMA disposition records
        resultDisposition = gii.RMACreation.createRMADispositionsforReceipts(listRMADispositions);
        
        // debug to print the result
        system.debug('::resultDisposition='+ resultDisposition);
        
        // Exception Handling
        if (resultDisposition.Exceptions != null) {
            if (resultDisposition.Exceptions.size() > 0) {
                List<String> ErrorMsgList = new List<String>();
                for(gii.RMACreation.GOMException e : resultDisposition.Exceptions) { 
                    //ErrorMsgList.add(e.getMessage());
                    System.debug('::Error='+e.getMessage());
                    //throw new AuraHandledException(e.getMessage());
                }
                if(ErrorMsgList.size()>0){
                    system.debug(ErrorMsgList);
                    // return null;
                }
            }          
        }
        
        //Create Transfer Order
        //=========================
        
        
        // system.debug('+++fromWarehouse'+fromWarehouse);
        //system.debug('+++toWarehouse'+toWarehouse);
        //system.debug('+++requiredDate'+requiredDate);
        
        String customLWarehouseName = Label.giic_manifold_warehouse;
        System.debug('customLWarehouseName: ' + customLWarehouseName);

       gii__Warehouse__c toWarehouse = [SELECT Name, Id FROM gii__Warehouse__c where Name =: customLWarehouseName limit 1];
	   system.debug('+++toWarehouse'+ toWarehouse.Name +'--'+ toWarehouse.id);
        
        gii__TransferOrder__c to=new gii__TransferOrder__c();
        List<gii__TransferOrderLine__c> toLinesList = new List<gii__TransferOrderLine__c>();
        gii__TransferOrderLine__c tol;
        to.gii__Account__c =  siteRecord.gii__Account__c;//stlRec.gii__Site__r.gii__Account__c;
        to.gii__FromWarehouse__c = accRef.gii__DefaultTransferToWarehouse__c; 
        to.gii__TransferToWarehouse__c = toWarehouse.id;
        to.gii__RequiredDate__c = system.today();
        to.giic_RMA__c = rmaId;
        
        
        insert to;
        
        tol = new gii__TransferOrderLine__c();
        tol.gii__TransferOrder__c = to.id;
        tol.gii__Quantity__c = 1;
        tol.gii__Product__c = stlRec.gii__Product__r.id;
        tol.gii__RequiredDate__c = system.today();
        tol.giic_Forced_Direct_Reservation_after_del__c = true;
        
        toLinesList.add(tol);
        
        
        if(toLinesList.size()>0){
            system.debug('toLinesList' + toLinesList.size());
            insert toLinesList;
        }
        
        gii__InventoryReserve__c invRese = [Select id, gii__ProductSerial__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__TransferOrderLine__c FROM gii__InventoryReserve__c 
                                            WHERE gii__TransferOrderLine__c=: toLinesList[0].id];
        system.debug('invRese ' + invRese.id + invRese.gii__ProductSerial__c);
         Delete invRese;
        
        // create list for inventory reservation records
        List<gii__InventoryReserve__c> listInventoryReserve 
            = new List<gii__InventoryReserve__c>();
        
        // create inventory reservation record
        gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
        // assign Transfer Order line record id
        ir.gii__TransferOrderLine__c = toLinesList[0].id;  
        // assign Product Inventory Quantity Detail id of the location and product lot
        
        
        gii__ProductInventoryQuantityDetail__c piqd = [select id,gii__Warehouse__c, gii__Location__c,
                                                       gii__Product__c, gii__ProductSerial__c From 
                                                       gii__ProductInventoryQuantityDetail__c
                                                       where gii__Warehouse__c =: accRef.gii__DefaultTransferToWarehouse__c
                                                       and gii__Location__c =: accRef.gii__DefaultTransferToWarehouse__r.gii__DefaultRMADispositionLocation__c
                                                       and gii__ProductSerial__c  =: assetRefRecord.gii__ProductSerial__c];
        
        ir.gii__ProductInventoryQuantityDetail__c = piqd.id; 
        ir.gii__ProductSerial__c =  assetRefRecord.gii__ProductSerial__c;//stlRec.gii__AssetReference__r.gii__ProductSerial__c;
        // quantity to be reserved from the location for the Transfer Order line (stocking UM)
        ir.gii__ReserveQuantity__c = 1.0;  
        //add reservation record to the list
        listInventoryReserve.add(ir);
        
        // input object for reservation creation
        gii.TransferOrderDirectReservation.inputDirectReservation inputDirResObj
            = new gii.TransferOrderDirectReservation.inputDirectReservation();
        // assign the list of reservations to the input object  
        inputDirResObj.listInvReserve = listInventoryReserve;
        inputDirResObj.Action = 'Reserve';  
        inputDirResObj.ShippedDate = system.today();  // specify shipment date
        
        
        // output for DirectReservationResult
        gii.TransferOrderDirectReservation.DirectReservationResult resultDirResObj
            = new gii.TransferOrderDirectReservation.DirectReservationResult();
        
        
        // execute direct reservaion and quick ship method
        resultDirResObj = gii.TransferOrderDirectReservation.CreateReservation(inputDirResObj);
        
        
        // Debug to print the result object
        system.debug(resultDirResObj);
        if (resultDirResObj.Exceptions != null) {
            if (resultDirResObj.Exceptions.size() > 0) {
                List<String> ErrorMsgList = new List<String>();
                for(gii.TransferOrderDirectReservation.GOMException e : resultDirResObj.Exceptions) { 
                    ErrorMsgList.add(e.getMessage());
                }
                if(ErrorMsgList.size()>0){
                    system.debug(ErrorMsgList);
                    //return null;
                    
                }
            }          
        } 
        
        gii__InventoryReserve__c invRev = [Select id,giic_Forced_Direct_Reservation_after_del__c,gii__ProductSerial__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__TransferOrderLine__c FROM gii__InventoryReserve__c WHERE gii__TransferOrderLine__c=: toLinesList[0].id];
        system.debug('invRese ' + invRev.id + invRev.gii__ProductSerial__c);
        invRev.giic_Forced_Direct_Reservation_after_del__c = true;
        
        update invRev;
        
        
        
        
    }
}