/**
 * @description       : 
 * @author            : himanshu.kumar@fujitsu.com
 * @group             : 
 * @last modified on  : 03-15-2023
 * @last modified by  : himanshu.kumar@fujitsu.com
**/
public class giic_RMAProcessFlow {
    
    @InvocableMethod(callout=true label='Invoke RMA Process')
    public static void initiateRMAProcess(List<gii__ServiceTicketLine__c> listStlRecs) {
       system.debug('Invoked RMA Process' + listStlRecs.size() + listStlRecs[0].id);      
        
        gii__ServiceTicketLine__c stlRec =listStlRecs[0];
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
        
        
        gii__AssetReference__c assetRefRecord =[select id , gii__ProductSerial__c ,
                                                gii__Status__c,gii__UsageEndDate__c
                                                from gii__AssetReference__c where id=: stlRec.gii__AssetReference__c];
        system.debug(' assetRefRecord>>> ' + assetRefRecord);
        system.debug(' assetRefRecord PS>>> ' + assetRefRecord.gii__ProductSerial__c);
        
        gii__AccountAdd__c accRef = [select id,gii__DefaultWarehouse__c, gii__DefaultTransferToWarehouse__c, 
                                             gii__DefaultTransferToWarehouse__r.gii__DefaultRMADispositionLocation__c,
                                     gii__DefaultWarehouse__r.gii__DefaultRMADispositionLocation__c 
                                     from gii__AccountAdd__c
                                     where gii__Account__c =:siteRecord.gii__Account__c];
        //gii__Account__c =:stlRec.gii__Site__r.gii__Account__c
        system.debug('Default From Warehouse' + accRef.gii__DefaultWarehouse__c + accRef.gii__DefaultWarehouse__r.gii__DefaultRMADispositionLocation__c);
        system.debug('accRef' + accRef);
        
        system.debug('product :'+ stlRec.gii__Product__c+ 'Product Serial : ' + stlRec.gii__AssetReference__r.gii__ProductSerial__c);
        //create RMA and line
        gii.RMACreation.RMALine line1 = new gii.RMACreation.RMALine();
        line1.ProductId       =   stlRec.gii__Product__c; 
        
        line1.ProductSerialId =  assetRefRecord.gii__ProductSerial__c;// stlRec.gii__AssetReference__r.gii__ProductSerial__c;
        line1.RMAQuantity     =   1;   
        
        
        // create list of RMA detail line objects
        List<gii.RMACreation.RMALine> listRMALines = new List<gii.RMACreation.RMALine>();
        listRMALines.add(line1); 
        
        //Create RMa Header
        gii.RMACreation.RMAHeader rh = new gii.RMACreation.RMAHeader();
        rh.Reason       = 'Damaged';
        
        rh.RMADate          = System.today();
        rh.WarehouseId      = accRef.gii__DefaultTransferToWarehouse__c;   
        rh.AccountId        = siteRecord.gii__Account__c;//stlRec.gii__Site__r.gii__Account__c;   
        // rh.ProductSerialId =  assetRefRecord.gii__ProductSerial__c;
        rh.DocumentText     = 'Thank you for your business. We are working towards excellent customer experience. Terms and conditions apply.';
        // Assing Lines to the RMA header
        rh.RMALines         = listRMALines;
        // Add to the list ofr input of RMA Creation method 
        List<gii.RMACreation.RMAHeader> lstRMAHeader = new List<gii.RMACreation.RMAHeader>();
        lstRMAHeader.add(rh);
        
        //define result object for output
        gii.RMACreation.RMACreationResult Result = new gii.RMACreation.RMACreationResult();
        
        //Execute RMA Creation method
        Result = gii.RMACreation.createRMARecords2(lstRMAHeader);
        
        //Debug to print the list of with RMA lines
        System.debug('::Result='+JSON.serialize(Result.listRMAs));
        
        // Exception Handling
        if (Result.Exceptions != null) {
            if (Result.Exceptions.size() > 0) {
                List<String> ErrorMsgList = new List<String>();
                for(gii.RMACreation.GOMException e : Result.Exceptions) { 
                    //gii.Util.AddMessage(e.getMessage(), 'ERROR');
                    System.debug('::Error='+e.getMessage());
                    // throw new AuraHandledException(e.getMessage());
                }
                //return null;
            }          
        }
        
        gii__RMA__c rma = Result.listRMAs[0];
        
        gii__RMA__c rmaRec = [select id,giic_Service_Ticket_Line__c from gii__RMA__c where id =: rma.Id];
        rmaRec.giic_Service_Ticket_Line__c = stlRec.id;
        
        update rmaRec;
        
        List<gii__RMADetail__c> rmaDetails = [Select Id from gii__RMADetail__c where gii__RMA__c= :rma.Id];
        
        
        
        if(!rmaDetails.isEmpty()){
            // throw new AuraHandledException('RMA Line not created successfully');
            system.debug('RMA Line not created successfully');
        }
        
        //RMA Receipt
        // Create RMA Receipts
        // list for rma receipt information
        List<gii.RMACreation.RMAReceipt> listRMAReceipts = new List<gii.RMACreation.RMAReceipt>();
        
        // create rma receipt  
        gii.RMACreation.RMAReceipt RMAReceipt = new gii.RMACreation.RMAReceipt();
        // record id for rem detail line
        RMAReceipt.RMADetailId      = rmaDetails[0].Id;
        // Quantity to be received for the rma line (Selling UM)  
        RMAReceipt.ReceiptQuantity  = 1;  
        // receipt date
        RMAReceipt.ReceiptDate      = system.today(); 
        
        // add to the list
        listRMAReceipts.add(RMAReceipt);
        
        //output for RMA Receipt Result
        gii.RMACreation.RMAReceiptResult resultReceipt = new gii.RMACreation.RMAReceiptResult();
        
        // call the method to create RMA receipt records
        resultReceipt = gii.RMACreation.createRMAReceiptsforRMADetails(listRMAReceipts);
        // debug to print the result
        system.debug('::resultReceipt='+(resultReceipt));
        
        // Exception Handling
        if (result.Exceptions != null) {
            if (result.Exceptions.size() > 0) {
                List<String> ErrorMsgList = new List<String>();
                for(gii.RMACreation.GOMException e : result.Exceptions) { 
                    //ErrorMsgList.add(e.getMessage());
                    System.debug('::Error='+e.getMessage());
                    //throw new AuraHandledException(e.getMessage());
                }
                if(ErrorMsgList.size()>0){
                    system.debug(ErrorMsgList);
                    //return null;
                }
            }          
        } 
        
        
        List<gii__RMAReceipt__c> rmaRcpts = [Select Id from gii__RMAReceipt__c where gii__RMALineDetail__c= :rmaDetails[0].Id];
        if(rmaRcpts.size() > 0){  //rmaRcpts.isEmpty()
            giic_RMAProcessFlowFuture.processRecords(stlRec.id ,rma.Id ,rmaDetails[0].Id);
            
            system.debug('RMA Receipt is created successfully');
            assetRefRecord.gii__Status__c = 'Decommissioned';
            assetRefRecord.gii__UsageEndDate__c = date.today();
            update assetRefRecord;
        }
        /*         

//RMA Disposition
// list for RMA disposition information
List<gii.RMACreation.RMADisposition> listRMADispositions = new List<gii.RMACreation.RMADisposition>();        
// create RMA Disposition  
gii.RMACreation.RMADisposition RMADisposition = new gii.RMACreation.RMADisposition();
// record id for RMA receipt line
RMADisposition.RMAReceiptId = rmaRcpts[0].Id;  
// Quantity for scrap for the RMA receipt (Selling UM) 
RMADisposition.DispositionLocationId = accRef.gii__DefaultWarehouse__r.gii__DefaultRMADispositionLocation__c;   
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
if (result.Exceptions != null) {
if (result.Exceptions.size() > 0) {
List<String> ErrorMsgList = new List<String>();
for(gii.RMACreation.GOMException e : result.Exceptions) { 
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

gii__TransferOrder__c to=new gii__TransferOrder__c();
List<gii__TransferOrderLine__c> toLinesList = new List<gii__TransferOrderLine__c>();
gii__TransferOrderLine__c tol;
to.gii__Account__c = stlRec.gii__Site__r.gii__Account__c;
to.gii__FromWarehouse__c = accRef.gii__DefaultWarehouse__c;
to.gii__TransferToWarehouse__c = 'a5c3C0000003ajqQAA';
to.gii__RequiredDate__c = system.today();
to.giic_RMA__c = rma.id;


insert to;

tol = new gii__TransferOrderLine__c();
tol.gii__TransferOrder__c = to.id;
tol.gii__Quantity__c = 1;
tol.gii__Product__c = stlRec.gii__Product__r.id;
tol.gii__RequiredDate__c = system.today();
tol.giic_Forced_Direct_Reservation_after_del__c = true;

toLinesList.add(tol);


if(toLinesList.size()>0){
insert toLinesList;
}

//Deleting Auto Created Inventory Reserve Record:

gii__InventoryReserve__c invRese = [Select id, gii__ProductSerial__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__TransferOrderLine__c FROM gii__InventoryReserve__c 
WHERE gii__TransferOrderLine__c=: toLinesList[0].id];
system.debug('invRese ' + invRese.id + invRese.gii__ProductSerial__c);


Delete invRese;

//Create a Direct Reservation using Glovia OM API.


// create list for inventory reservation records
List<gii__InventoryReserve__c> listInventoryReserve 
= new List<gii__InventoryReserve__c>();

// create inventory reservation record
gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
// assign Transfer Order line record id
ir.gii__TransferOrderLine__c = toLinesList[0].id;  
// assign Product Inventory Quantity Detail id of the location and product lot


gii__ProductInventoryQuantityDetail__c piqd = [select id,gii__Warehouse__c, gii__Location__c, gii__Product__c, gii__ProductSerial__c From 
gii__ProductInventoryQuantityDetail__c where gii__Warehouse__c =: accRef.gii__DefaultWarehouse__c
and gii__Location__c =: accRef.gii__DefaultWarehouse__r.gii__DefaultRMADispositionLocation__c
and gii__ProductSerial__c  =: stlRec.gii__AssetReference__r.gii__ProductSerial__c];

ir.gii__ProductInventoryQuantityDetail__c = piqd.id; 
ir.gii__ProductSerial__c =  stlRec.gii__AssetReference__r.gii__ProductSerial__c;
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
// Exception Handling
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

*/
        
     
    }
    
}