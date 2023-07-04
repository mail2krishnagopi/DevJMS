@RestResource(urlMapping='/processTrackingUpdate/*')
global with sharing class giic_trackingUpdate {
    @HttpPost
    global static void processIncomingData() {
        boolean isError = false;
        String errorMessage;
        Integer errorCode;
        String ShippingRecord;
        List<gii__Shipment__c> shiplst = new List<gii__Shipment__c>();
        try{
        // Get the incoming JSON data
        RestRequest req = RestContext.request;
        String jsonString = req.requestBody.toString();
            system.debug('#####'+jsonString);
        IncomingData incomingData = (IncomingData) JSON.deserialize(jsonString, IncomingData.class);
        
        System.Debug('This is data' + incomingData);

        // Access the fields in the incoming JSON data
        String bol = incomingData.bol;
            System.Debug('BOL Value' + incomingData.bol);
        String freeMessage = incomingData.freeMessage;
        String scac = incomingData.scac;
        String status = incomingData.status;
        String statusDesc = incomingData.statusDesc;
        Datetime trackingDate = incomingData.trackingDate;
        Datetime estimatedDeliveryDate = incomingData.estimatedDeliveryDate;
        ShippingRecord = incomingData.shipmentNo;
        String loadId = incomingData.loadId;
        // Perform update operation for Shipment
        if(ShippingRecord == '' || ShippingRecord == null){
     			 RestContext.response.statusCode = 500;
                RestContext.response.responseBody = Blob.valueOf('Tracking Update API failed:One or More Mandatory values -ShipmentNo,BOL,SCAC,Load Id,are missing!');
                isError = true;
                errorCode = 500;
                errorMessage = 'Tracking Update API failed:One or More Mandatory values-ShipmentNo,BOL,SCAC,Load Id, are missing!';           
            if(shiplst.size() > 0){
                gii__Shipment__c shipobj = new gii__Shipment__c();
                system.debug('####'+shiplst[0]);
                
                shipobj.Id = shiplst[0].Id;
                
                shipobj.giic_Integration_Status__c = 'PLS Tracking completed with errors';
                //shipobj.CurrencyIsoCode = CurrencyProcessed;
                update shipobj;
            }
        }else{
            	shiplst = [SELECT Id,Name,giic_loadId__c,giic_BOL__c,giic_SCAC__c,gii__ProductAmount__c,gii__SalesOrder__c,gii__TransferOrder__c,giic_Quantity__c FROM gii__Shipment__c WHERE Name =: ShippingRecord LIMIT 1];
            }
          if(bol == '' || scac == '' || loadId == '' || ShippingRecord == '' || bol == null || scac == null || loadId == null || ShippingRecord == null){
                 RestContext.response.statusCode = 500;
        		RestContext.response.responseBody = Blob.valueOf('Tracking Update API failed:One or More Mandatory values-ShipmentNo,BOL,SCAC,Load Id, are missing!');
              isError = true;
                errorCode = 500;
                errorMessage = 'Tracking Update API failed:One or More Mandatory values-ShipmentNo,BOL,SCAC,Load Id, are missing!';
               gii__Shipment__c shipobj = new gii__Shipment__c();
                    system.debug('####'+shiplst[0]);
                    shipobj.Id = shiplst[0].Id;
                   
                    shipobj.giic_Integration_Status__c = 'PLS Tracking completed with errors';
                    //shipobj.CurrencyIsoCode = CurrencyProcessed;
                    update shipobj;
          }else{
            //shiplst = [SELECT Id,Name,giic_loadId__c,giic_BOL__c,giic_SCAC__c,gii__ProductAmount__c,gii__SalesOrder__c,gii__TransferOrder__c FROM gii__Shipment__c WHERE Name =: ShippingRecord LIMIT 1];
            if(shiplst.isEmpty())  {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf('No Shipment record found with the given shipment number');
        isError = true;
                errorCode = 400;
               // errorMessage = 'No Shipment record found with the given shipment number';
               
             // shiplst[0].addError('The Record is not available');
            }
            //if(!shiplst.isEmpty()){//checking record is there or not if there 
            
            else{
             
              gii__Shipment__c shipobj = shiplst[0];
                shipobj.giic_BOL__c = bol;
                shipobj.giic_SCAC__c = scac;
                //shipobj.giic_PLSToGloviaIntegrationstatus__c = status;
                 shipobj.giic_PLSToGloviaIntegrationstatus__c = status;
                shipobj.giic_statusDescription__c	= statusDesc;
                shipobj.giic_IntegrationMessage__c = freeMessage;
           shipobj.giic_Integration_Status__c = 'PLS Tracking details updated successfully';
                shipobj.giic_TrackingDate__c = trackingDate;
                shipobj.giic_EstimatedDeliveryDate__c = estimatedDeliveryDate;
                 shipobj.giic_loadId__c = loadId;
                update shipobj;//updating shipment record
                RestContext.response.statusCode = 200;
        		RestContext.response.responseBody = Blob.valueOf('Data processed successfully');
            }

        // Return any response if needed
        
        
       
          }
        }catch(exception e){
  
            system.debug('####::'+e.getMessage()+'###'+e.getLineNumber());
            if(e.getMessage().contains('Invalid') || e.getMessage().contains('Invalid JSON')){
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('Error in request');
                  isError = true;
                errorCode = 400;
                errorMessage = 'Error in request';
               
            }else{
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('Error in request');
             isError = true;
                errorCode = 400;
                errorMessage = e.getMessage();
               
            system.debug('###'+e.getMessage()+' ###'+e.getLineNumber());
        }
        
    }
        system.debug('##$#$::'+isError);
         if(isError){
            gii__ErrorLog__c errLog = new gii__ErrorLog__c();
             if(shiplst.size() > 0){
            	errLog.giic_Shipment__c = shiplst[0].Id;
                  gii__Shipment__c shipUp = new gii__Shipment__c();
                shipUp.Id = shiplst[0].Id;
                shipUp.giic_PLSToGloviaIntegrationstatus__c = errorMessage;
                shipUp.giic_Integration_Status__c = 'PLS Tracking completed with errors';
                update shipUp;
            }
            errLog.gii__ErrorCode__c = string.valueOf(errorCode);
            errLog.gii__ErrorMessage__c = errorMessage;
             insert errLog;
        }
    }

    // Inner class to represent the structure of the incoming JSON data
    global class IncomingData {
        public String bol;
        public String freeMessage;
        public String scac;
        public String status;
        public String statusDesc;
        public Datetime trackingDate;
        public Datetime estimatedDeliveryDate;
        public String shipmentNo;
        Public string loadId;
    }
}

/*{

   "bol": "14739062",
   "freeMessage": "Test free message",
   "scac": "ABFS",
   "status": "tracking update",
   "statusDesc": "tracking update", // Enable History
   "trackingDate": "2023-03-15T18:59:28.719Z", // Enable History
   "estimatedDeliveryDate": "2023-03-15T18:59:28.719Z" // Enable History

}*/