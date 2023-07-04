public class giic_createShipmentFedexApi {
    
    
    public static string createShipment(gii__Shipment__c shipmentInfo)
    {
        System.debug('Called Create Shipment Method');
        string message;
        HttpResponse response;
        Decimal totalshipingCost = 0.0;
        String trackingNumber ='';
        //try{
            
            //JMS_Integration_Setting__c    jmsIntAttr = [select id,giic_FEDEX_Pickup_Type__c,giic_FEDEX_Packaging_Type__c,giic_FEDEX_OAUTH_Endpoint__c,giic_FEDEX_Endpoint_URL__c,giic_FEDEX_CLIENT_KEY__c, giic_FEDEX_CLIENT_SECRET__c,giic_FEDEX_Account_Number__c from JMS_Integration_Setting__c limit 1];
            giic_JMSIntegrationMapping__mdt jmsIntAttr = [SELECT Id, Label, giic_Account_Number__c, giic_CLIENT_KEY__c, giic_CLIENT_SECRET__c, giic_Endpoint_URL__c, giic_Fedex_Packaging_Type__c, giic_Fedex_Pickup_Type__c, giic_USERNAME__c, giic_PASSWORD__c, giic_Integration_Type__c, giic_OAUTH_Endpoint__c FROM giic_JMSIntegrationMapping__mdt limit 1];
            String ACCOUNT_NUMBER = jmsIntAttr.giic_Account_Number__c;
            string requestBody;    
            
            requestBody=  giic_FedexRequestSchema.generateFedExRequestJson(shipmentInfo,ACCOUNT_NUMBER,jmsIntAttr);
            
            system.debug('requestBody' + requestBody);
            String accessToken = giic_getFedexOauthToken.getAccessToken(jmsIntAttr);
            system.debug('authToken' + accessToken);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://apis-sandbox.fedex.com/ship/v1/shipments');
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Type', 'application/json');          
            
            request.setBody(requestBody.replaceall('currency_X', 'currency'));
            
            
            // Send the HTTP request and get the response
            Http http = new Http();
            response = http.send(request);
            
            System.debug('Status Code' + response.getStatusCode());
            if (response.getStatusCode() == 200) {
                // Update the record with data from the response
                String responseReceived = response.getBody();
                message = 'success';
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('responseReceived' + responseReceived);
                system.debug('responseReceived' + result);
                
                Map<String, Object> outputMap = (Map<String, Object>) result.get('output');
                system.debug('outputMap' + outputMap);
                List<Object> transactionShipments = (List<Object>) outputMap.get('transactionShipments');
                system.debug('transactionShipment' + transactionShipments );
                List<Object> alerts;
                //List<Object> alerts =  List<Object>();
                boolean containsalerts = false;
                boolean containsPieceResponse = false;
                boolean containsShipmentRating = false;
                for (Object shipmentObj : transactionShipments) {
                    Map<String, Object> shipment = (Map<String, Object>) shipmentObj;
                    
                    String masterTrackingNumber = (String) shipment.get('masterTrackingNumber');
                    
                    if (shipment.containsKey('alerts')) { 
                        containsalerts = true;
                    }
                    if (shipment.containsKey('pieceResponses')) { 
                        containsPieceResponse = true;
                    }
                    if (shipment.containsKey('completedShipmentDetail')) { 
                        // containsShipmentRating = true;
                        Map<String, Object> shipDetails = (Map<String, Object>) shipment.get('completedShipmentDetail');
                        system.debug('shipDetails' + shipDetails);
                        system.debug('shipDetails' + shipDetails.containsKey('shipmentRating'));
                        Map<String, Object> shipmentRating = (Map<String, Object>) shipDetails.get('shipmentRating');
                        system.debug('shipmentRating' + shipmentRating);
                        if (shipDetails.containsKey('shipmentRating')) { 
                            containsShipmentRating = true;
                        }
                    }
                    
                }       
                system.debug('containsalerts' + containsalerts);
                system.debug('containsPieceResponse' + containsPieceResponse);
                system.debug('containsShipmentRating' + containsShipmentRating);
                
                giic_FedexResponseSchema obj = giic_FedexResponseSchema.parse(response.getBody());            
                gii__Shipment__c shipment = [select id,gii__TrackingNumber__c from gii__Shipment__c where id =: shipmentInfo.id];
                
                
                trackingNumber = obj.output.transactionShipments[0].masterTrackingNumber;       
                system.debug('responseMap obj ==> ' + obj);
                system.debug('responseMap obj ==> ' + obj.output.transactionShipments[0].masterTrackingNumber);
                system.debug('responseMap obj ==> ' + obj.output.transactionShipments[0].pieceResponses[0].masterTrackingNumber);
                
                // Update Shipment Record                      
                shipment.gii__TrackingNumber__c = trackingNumber;
                shipment.giic_Integration_Status__c = 'FedEx Integration completed successfully';
                update shipment;
                
                //Attach Shipping Label/Commercial Invoice PDF to FILES
                //  if(pieceResponsesCheck != null && !pieceResponsesCheck.isEmpty()) {
                List<ContentVersion> contentVersionList = new List<ContentVersion>();
                for(giic_FedexResponseSchema.pieceResponseWrapper res : obj.output.transactionShipments[0].pieceResponses)        
                {
                    ContentVersion cv = new ContentVersion();
                    cv.VersionData = EncodingUtil.base64Decode(res.packageDocuments[0].encodedLabel);
                    cv.ContentLocation = 'S';
                    cv.Title =  'FEDEX' + '.' + 'ShippingLabel' + '.' + shipment.gii__TrackingNumber__c  + '.pdf';
                    cv.PathOnClient = 'ionicLogo.pdf'; 
                    cv.FirstPublishLocationId =shipment.Id;
                    contentVersionList.add(cv);
                }  
                
                if(shipmentInfo.gii__SalesOrder__r.gii__ShipToCountry__c != 'US' && shipmentInfo.gii__SalesOrder__r.gii__ShipToCountry__c != 'USA'
                 && shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c != 'US' && shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c != 'USA')
                {
                    
                    ContentVersion cv = new ContentVersion();
                    cv.VersionData = EncodingUtil.base64Decode(obj.output.transactionShipments[0].shipmentDocuments[0].encodedLabel);
                    cv.ContentLocation = 'S';
                    cv.Title =  'FEDEX' + '.' + 'Commercial Invoice' + '.' + shipment.gii__TrackingNumber__c + '.pdf';  
                    cv.PathOnClient = 'ionicLogo.pdf'; 
                    cv.FirstPublishLocationId =shipment.Id;
                    contentVersionList.add(cv);                
                    
                }
                
                system.debug('contentVersionList.size ==>' + contentVersionList);
                if(contentVersionList.size()>0)
                {
                    Database.Insert(contentVersionList);
                }
                
                
                List<ContentVersion> insertedContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionList];
                
                ContentWorkspace ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name = 'FEDEX Library' LIMIT 1];
                
                List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                for (ContentVersion cv : insertedContentVersions) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cv.ContentDocumentId;
                    cdl.ShareType = 'I';
                    cdl.Visibility = 'AllUsers';
                    cdl.LinkedEntityId = ws.Id; 
                    contentDocumentLinks.add(cdl);
                }
                
                if(contentDocumentLinks.size()>0)
                {
                    Database.Insert(contentDocumentLinks);
                }
                // }
                
                //Add shipping Charge as Additional Charge Info into Sales Order
                
                String salesOrderInfo = shipmentInfo.gii__SalesOrder__c;
                String transOrderInfo = shipmentInfo.gii__TransferOrder__c;  
                if(salesOrderInfo != '' && salesOrderInfo != null)
                {               
                    system.debug(containsShipmentRating);
                    //  if(obj.output.transactionShipments[0].alerts.isempty()) {
                    if(containsShipmentRating){
                        System.debug('Enter ShippingCost Loop' + obj.output.transactionShipments[0].completedShipmentDetail.shipmentRating.shipmentRateDetails[0].totalNetCharge);            
                        totalshipingCost = obj.output.transactionShipments[0].completedShipmentDetail.shipmentRating.shipmentRateDetails[0].totalNetCharge;
                    }
                    
                    system.debug('totalshipingCost'+totalshipingCost);
                    if(totalshipingCost > 0)
                    {
                        gii__AdditionalCharge__c shipChargeInfo = [Select Id,Name FROM gii__AdditionalCharge__c 
                                                                   where Name =: System.Label.giic_ShippingCharge limit 1];
                        
                        gii__SalesOrderAdditionalCharge__c salesOrdAddChargeInfo = new gii__SalesOrderAdditionalCharge__c();
                        salesOrdAddChargeInfo.gii__SalesOrder__c = shipmentInfo.gii__SalesOrder__c;
                        salesOrdAddChargeInfo.gii__UnitPrice__c = totalshipingCost;
                        salesOrdAddChargeInfo.gii__AdditionalCharge__c = shipChargeInfo.Id;
                        salesOrdAddChargeInfo.gii__Quantity__c = 1;
                        insert salesOrdAddChargeInfo;
                    }
                    else
                    {
                        gii__AdditionalCharge__c shipChargeInfo = [Select Id,Name FROM gii__AdditionalCharge__c 
                                                                   where Name =: System.Label.giic_ShippingCharge limit 1];
                        
                        gii__SalesOrderAdditionalCharge__c salesOrdAddChargeInfo = new gii__SalesOrderAdditionalCharge__c();
                        salesOrdAddChargeInfo.gii__SalesOrder__c =  shipmentInfo.gii__SalesOrder__c;
                        salesOrdAddChargeInfo.gii__UnitPrice__c = totalshipingCost;
                        salesOrdAddChargeInfo.gii__AdditionalCharge__c = shipChargeInfo.Id;
                        salesOrdAddChargeInfo.gii__NoChargeReason__c = 'Sample';
                        salesOrdAddChargeInfo.gii__Quantity__c = 1;
                        insert salesOrdAddChargeInfo;
                        
                    }
                }
            }       
            
            else {
                
                gii__Shipment__c shipment = [select id,gii__TrackingNumber__c from gii__Shipment__c where id =: shipmentInfo.id];
                shipment.giic_Integration_Status__c = 'FedEx Shipment API Invoked with errors';
                if(!test.isRunningTest()){
                Database.update(shipment);
                }
                System.Debug('Error in this record ---- >'+shipment);
                
                gii__ErrorLog__c errorlog = new gii__ErrorLog__c();
                errorlog.giic_ErrorMessage__c = response.getBody();           
                errorlog.giic_Shipment__c = shipment.id;
                errorlog.gii__ErrorCode__c = response.getStatus();
                if(!Test.isRunningTest()){
                Database.insert(errorlog);
                }
                
                
                // Display an error message
                system.debug('Error thrown is ' + response.getStatus() + ' ' + response.getBody());
                throw new AuraHandledException('Error calling external system: ' + response.getStatus() + ' ' + response.getBody());
                
            }  
      /*  }
        catch(Exception e)
        {
            message = 'failure';
            gii__Shipment__c shipment = [select id,gii__TrackingNumber__c from gii__Shipment__c where id =: shipmentInfo.id];
            shipment.giic_Integration_Status__c = 'FedEx Shipment API Invoked with errors';
            
            Database.update(shipment);
            System.Debug('Error in this record ---- >'+shipment);
            
            gii__ErrorLog__c errorlog = new gii__ErrorLog__c();
            errorlog.giic_ErrorMessage__c = e.getMessage();           
            errorlog.giic_Shipment__c = shipment.id;
            errorlog.gii__ErrorCode__c = response.getStatus();
            
            Database.insert(errorlog);
            
            system.debug('Error thrown is ' + response.getStatus() + ' ' + response.getBody());
                throw new AuraHandledException('Error calling external system: ' + response.getStatus() + ' ' + response.getBody());
            
        }*/
        
        return message;
    }    
    
}