public with sharing class giic_ShipmentHelper {
    
    
    
    @AuraEnabled(cacheable=true)
    public static gii__Shipment__c fetchData(Id recordId) {
        
        gii__Shipment__c shipmentInfo = new gii__Shipment__c();
        shipmentInfo = [SELECT id,Name,gii__SalesOrder__r.Name,gii__TransferOrder__r.Name,gii__SalesOrder__c,
                        giic_Integration_Status__c,
                        gii__SalesOrder__r.giic_Site__r.Name,
                        gii__SalesOrder__r.giic_Site__c,
                        gii__SalesOrder__r.giic_Site__r.gii__Street__c,
                        gii__SalesOrder__r.giic_Site__r.gii__City__c,
                        gii__SalesOrder__r.giic_Site__r.gii__StateProvince__c,
                        gii__SalesOrder__r.giic_Site__r.gii__Country__c,
                        gii__SalesOrder__r.giic_Site__r.gii__ZipPostalCode__c, 
                        gii__SalesOrder__r.gii__CustomerPONumber__c,
                        gii__ShippedDate__c,gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Account.name,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Phone,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Email,
                        gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name,gii__SalesOrder__r.gii__Warehouse__r.giic_Accessorial_Types__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.giic_Accessorial_Types__c,
                        gii__SalesOrder__r.gii__Warehouse__r.Name,gii__SalesOrder__r.gii__Warehouse__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCity__c, 
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCountry__c,  
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStateProvince__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStreet__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name,
                        gic_PackageType__c,giic_CommodityClass__c,giic_Quantity__c,giic_ProductDescription__c,
                        giic_Weight__c,giic_Height__c,giic_Width__c,giic_Length__c,
                        giic_Hazmat__c,giic_Pickup_Type__c,
                        gii__SalesOrder__r.gii__Carrier__r.Name,gii__SalesOrder__r.gii__Carrier__r.gii__Description__c,giic_ShipmentCarrier__c,giic_ShipmentCarrier__r.Name,giic_ShipmentCarrier__r.gii__Description__c,
                        gii__SalesOrder__r.gii__ShipToStreet__c,gii__SalesOrder__r.gii__ShipToCity__c,
                        gii__SalesOrder__r.gii__ShipToStateProvince__c,gii__SalesOrder__r.gii__ShipToCountry__c,
                        gii__SalesOrder__r.gii__ShipToZipPostalCode__c,gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCity__c,
                        gii__TransferOrder__r.gii__Carrier__r.Name, gii__TransferOrder__r.gii__Carrier__r.gii__Description__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.Name,gii__TransferOrder__r.gii__TransferToWarehouse__r.Name,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCountry__c, 
                        gii__TransferOrder__r.gii__TransferToWarehouse__c, gii__TransferOrder__r.gii__FromWarehouse__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStateProvince__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStreet__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCity__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStateProvince__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStreet__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseZipPostalCode__c,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone,
                        gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name from gii__Shipment__c  WHERE Id = :recordId LIMIT 1];
        
        // return [SELECT id,gii__SalesOrder__r.Id, gii__SalesOrder__r.gii__Carrier__r.Name FROM gii__Shipment__c WHERE Id = :recordId];
        // 
        if(shipmentInfo.giic_Integration_Status__c == 'PLS Shipment API completed Successfully' || shipmentInfo.giic_Integration_Status__c == 'FedEx Integration completed successfully'){
            throw new AuraHandledException('Shipment Label Is Already Generated');
        }
        
        
        if(shipmentInfo.gii__SalesOrder__r.Name != null && shipmentInfo.gii__SalesOrder__r.Name != ''){
            if (shipmentInfo.giic_ShipmentCarrier__r.Name == null || shipmentInfo.giic_ShipmentCarrier__r.Name == '') {
                throw new AuraHandledException('Carrier name is blank.');
            }
            else{    
                String CarrierName =  shipmentInfo.giic_ShipmentCarrier__r.Name;
                String CarrierDesc =  shipmentInfo.giic_ShipmentCarrier__r.gii__Description__c;
                
                if(String.isNotBlank(CarrierName))
                {
                    if(CarrierName.contains('PLS'))
                    {
                        validateSalesOrderFields(shipmentInfo);
                    }
                    if(CarrierDesc.contains('FedEx'))
                    {
                        checkMandatorySalesOrderFieldsforFedex(shipmentInfo);
                    }
                }
            }
        }
        else {
            if(shipmentInfo.gii__TransferOrder__r.Name != null && shipmentInfo.gii__TransferOrder__r.Name != ''){
                if (shipmentInfo.giic_ShipmentCarrier__r.Name == null || shipmentInfo.giic_ShipmentCarrier__r.Name == '') {
                    throw new AuraHandledException('Carrier name is blank.');
                }
                else{    
                    String CarrierName =  shipmentInfo.giic_ShipmentCarrier__r.Name;
                    String CarrierDesc =  shipmentInfo.giic_ShipmentCarrier__r.gii__Description__c;
                    
                    if(String.isNotBlank(CarrierName))
                    {
                        if(CarrierName.contains('PLS'))
                        {
                            validateTransferOrderFields(shipmentInfo);
                        }
                        if(CarrierDesc.contains('FedEx'))
                        {
                            checkMandatoryTransferOrderFieldsforFedex(shipmentInfo);
                        }
                    }
                }
            }
        }
        
        return shipmentInfo;
    }
    
    
    @auraEnabled
    public static String sendShipmentDetails(gii__Shipment__c shipmentInfo){
        System.debug('This is ->'+shipmentInfo);
        
        
        String CarrierName =  shipmentInfo.giic_ShipmentCarrier__r.Name;
        String CarrierDesc =  shipmentInfo.giic_ShipmentCarrier__r.gii__Description__c;
        String responseStatus;
        if(String.isNotBlank(CarrierName))
        {
            if(CarrierName.contains('PLS'))
            {
                responseStatus =  processPLSShipment(shipmentInfo);
            }
            if(CarrierDesc.contains('FedEx'))
            {
                
                responseStatus =  processFedexShipment(shipmentInfo);
            }
        }
        
        
        return responseStatus;
        
    }
    
    @auraEnabled
    public static String processFedexShipment(gii__Shipment__c shipmentInfo){
        
        String status = giic_createShipmentFedexApi.createShipment(shipmentInfo);
        return status;
    }
    
    @auraEnabled
    public static String processPLSShipment(gii__Shipment__c shipmentInfo){
        Map<String, object> test = new Map<String, object>();
        Map<String, object> mapResult = new Map<String, object>();
        String result = '';
        String responseReceived;
        
        
        
        if (shipmentInfo.giic_Weight__c == null) {
            throw new AuraHandledException('Required Field is Missing');
        }
        else {
            System.Debug('Check this helper'+shipmentInfo);
            String endPoint = '';            
            String body;
            Boolean isSuccess;
            
            body = giic_PLSRequestWrapper.getRequestedJson(shipmentInfo);
            System.Debug('Body from helper'+body);
            string authtoken = giic_getPLSOauthToken.getAuthorizationToken();
            system.debug('####:: '+authtoken);
            /*    String username = 'gloviaapi';
String password = 'P96FSZ1daJ5da2h';*/
            //String endpointURL = 'https://ltl.uat.plsthree.pro/restful/api/shipment/book'; 
            JMS_Integration_Setting__c jmsIntAttr = JMS_Integration_Setting__c.getInstance();  //gettting from custom settings added by Bhuvana    
            String endpointURL = jmsIntAttr.giic_PLSEndpoint_URL__c; //getting from custom settings added by Bhuvana
            //body = '{"soNum":"SO-20221111-000007","shipmentNo":"SHP-20221116-000003","poNum":"PO4252023","pickupDate":"2022-11-16","originAddress":{"stateCode":"NJ","postalCode":"08512","name":"E & S - JMS CRANBURY NJ","countryCode":"USA","contactPhone":"1234567890","contactName":"Adam Kamerer","city":"Cranbury","addressCode":"a5c3C0000003bXrQAI","address1":"20 Haypress Rd Ste 322"},"materials":[{"width":4,"weightUnit":"LBS","weight":4,"quantity":1,"productDescription":"This is for Shipment","packagingType":"CAS","length":3,"height":3,"hazmat":false,"dimensionUnit":"INCH","commodityClass":"50"}],"destinationAddress":{"stateCode":"FL","postalCode":"33467","name":"PALOMINO GARDENS","countryCode":"USA","contactPhone":"1234567890","contactName":"Adam Kamerer","city":"Lake Worth","addressCode":"a4i3C000000YSAlQAO","address1":"9885 Palomio Dr"},"accessorialTypes":["REP"]}';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setEndpoint(endpointURL);
            //request.setEndpoint('callout:PLSIntegrationDev');
            request.setHeader('content-type', 'application/json');
            //request.setHeader('Accept', 'application/json');
            request.setMethod('POST');
            // Blob headerValue = Blob.valueOf(username + ':' + password);
            // added bearer token from access token response
            String authorizationHeader = 'Bearer ' + authtoken;
            request.setHeader('Authorization', authorizationHeader);//until here by Bhuvana
            system.debug('request:'+request);
            request.setBody(body);
            system.debug('body is '+body);
            request.setTimeout(30000);
            system.debug('request sent is'+request);
            response = http.send(request);
            system.debug('response received' + response );
            system.debug('response body is' + response.getBody() );  
            
            if (response.getStatusCode() == 200) {
                // Update the record with data from the response
                
                responseReceived = response.getBody();
                system.debug('Response sent is ' + responseReceived);
                updateShipmentRecord(shipmentInfo,response.getStatusCode() , response.getBody());
                return 'Success';
            } else {
                // Display an error message
                system.debug('Error thrown is ' + response.getStatus() + ' ' + response.getBody());
                throw new AuraHandledException('Error calling external system: ' + response.getStatusCode() + ' ' +  response.getStatus() + ' ' + response.getBody());
            }  
        }   
    }
    
    public static void validateSalesOrderFields(gii__Shipment__c shipment) {
        
        if (shipment.gii__SalesOrder__r.giic_Site__r.Name == null || shipment.gii__SalesOrder__r.giic_Site__r.Name == '' ||
            shipment.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name == null || shipment.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name == '' ||
            shipment.gii__SalesOrder__r.gii__Warehouse__r.Name == null || shipment.gii__SalesOrder__r.gii__Warehouse__r.Name == ''||
            shipment.gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == null || shipment.gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == '' ||
            shipment.gic_PackageType__c == null || shipment.gic_PackageType__c == '' ||
            shipment.giic_CommodityClass__c == null || shipment.giic_CommodityClass__c == '' ||
            shipment.giic_Quantity__c == null ||
            shipment.giic_ProductDescription__c == null || shipment.giic_ProductDescription__c == '' ||
            shipment.giic_Weight__c == null ||
            shipment.giic_Height__c == null  || shipment.giic_Width__c == null || shipment.giic_Length__c == null  ||
            shipment.giic_Pickup_Type__c == null || shipment.giic_Pickup_Type__c == '' ||
            shipment.gii__SalesOrder__r.gii__Warehouse__r.giic_Accessorial_Types__c == null || shipment.gii__SalesOrder__r.gii__Warehouse__r.giic_Accessorial_Types__c == '')
        {
            throw new AuraHandledException('Required Fields Are Missing');
        }
    }
    
    public static void checkMandatorySalesOrderFieldsforFedex(gii__Shipment__c shipment) {
        if (shipment.gii__SalesOrder__r.giic_Site__r.Name == null || shipment.gii__SalesOrder__r.giic_Site__r.Name == '' ||
            shipment.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name == null || shipment.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name == '' ||
            shipment.gii__SalesOrder__r.gii__Warehouse__r.Name == null || shipment.gii__SalesOrder__r.gii__Warehouse__r.Name == ''||
            shipment.gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == null || shipment.gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == '' )
            
        {
            throw new AuraHandledException('Required Fields Are Missing');
        }
    }
    
    public static void checkMandatoryTransferOrderFieldsforFedex(gii__Shipment__c shipment) {
        
        if (shipment.gii__TransferOrder__r.gii__FromWarehouse__r.Name == null || shipment.gii__TransferOrder__r.gii__FromWarehouse__r.Name == '' ||
            shipment.gii__TransferOrder__r.gii__TransferToWarehouse__r.Name == null || shipment.gii__TransferOrder__r.gii__TransferToWarehouse__r.Name == ''||
            shipment.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == null || shipment.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == '')
        {
            throw new AuraHandledException('Required Fields Are Missing');
        }
    }
    public static void validateTransferOrderFields(gii__Shipment__c shipment) {
        
        if (shipment.gii__TransferOrder__r.gii__FromWarehouse__r.Name == null || shipment.gii__TransferOrder__r.gii__FromWarehouse__r.Name == '' ||
            shipment.gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == null || shipment.gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == '' ||
            shipment.gii__TransferOrder__r.gii__TransferToWarehouse__r.Name == null || shipment.gii__TransferOrder__r.gii__TransferToWarehouse__r.Name == ''||
            shipment.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == null || shipment.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name == '' ||
            shipment.gic_PackageType__c == null || shipment.gic_PackageType__c == '' ||
            shipment.giic_CommodityClass__c == null || shipment.giic_CommodityClass__c == '' ||
            shipment.giic_Quantity__c == null ||
            shipment.giic_ProductDescription__c == null || shipment.giic_ProductDescription__c == '' ||
            shipment.giic_Weight__c == null ||
            shipment.giic_Height__c == null  || shipment.giic_Width__c == null || shipment.giic_Length__c == null  ||
            shipment.giic_Pickup_Type__c == null || shipment.giic_Pickup_Type__c == '' ||
            shipment.gii__TransferOrder__r.gii__FromWarehouse__r.giic_Accessorial_Types__c == null || shipment.gii__TransferOrder__r.gii__FromWarehouse__r.giic_Accessorial_Types__c == '')
        {
            throw new AuraHandledException('Required Fields Are Missing');
        }
    }
    
    @AuraEnabled
    public static void updateShipmentRecord(gii__Shipment__c shipment, Integer statusCode, String message) {
        System.Debug('This is shipment Record'+shipment);
        System.Debug('This is Status Code'+statusCode); 
        Integer  loadId;
        String bol = '';
        if(message != '' && message != null){
            String responseBodyReceived = message;
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBodyReceived);
            loadId = (Integer)responseMap.get('loadId');
            bol = (String)responseMap.get('bol');
        }
        gii__Shipment__c shipmentRecord = new gii__Shipment__c();
        shipmentRecord = [select id,giic_loadId__c,giic_BOL__c, giic_Integration_Status__c from gii__Shipment__c WHERE ID =: shipment.id];
        System.Debug('This is message received'+message);
        
        if(shipmentRecord != null) {
            if(statusCode == 200) {
                shipmentRecord.giic_Integration_Status__c = 'PLS Shipment API completed Successfully';
                if(loadId != null){
                    System.Debug('Load ID is ---- >'+loadId);
                    String loadIdString = String.valueOf(loadId);
                    shipmentRecord.giic_loadId__c = loadIdString;
                }
                if(bol != '' && bol != null){
                    System.Debug('bol ID is ---- >'+bol);
                    shipmentRecord.giic_BOL__c = bol;
                }
                if(!Test.isRunningTest()){
                update shipmentRecord;
                }
                System.Debug('Updated this record ---- >'+shipmentRecord);
            }
            else {
                
                /*    shipmentRecord.giic_Integration_Status__c = 'Completed with Error';
update shipmentRecord;
System.Debug('Error in this record ---- >'+shipmentRecord);

gii__ErrorLog__c errorlog = new gii__ErrorLog__c();
errorlog.giic_ErrorMessage__c = message;
errorlog.gii__ErrorMessage__c = message;
errorlog.giic_Shipment__c = shipmentRecord.id;
errorlog.gii__ErrorCode__c = '400';
insert errorlog; */
                
            }
        }
    }
    
    @AuraEnabled
    public static void updateErrorRecord(ID shipment, String message) {
        
        gii__Shipment__c shipmentRecord = new gii__Shipment__c();
        shipmentRecord = [select id, giic_Integration_Status__c,giic_ShipmentCarrier__r.Name from gii__Shipment__c WHERE ID =: shipment];
        
        if(shipmentRecord.giic_ShipmentCarrier__r.Name == 'PLS'){
            
            shipmentRecord.giic_Integration_Status__c = 'PLS Shipment API completed with errors';
             if(!test.isRunningTest()){
            update shipmentRecord;
             }
            System.Debug('Error in this record ---- >'+shipmentRecord);
            System.Debug('Error Message is ---- >'+message);
            
            gii__ErrorLog__c errorlog = new gii__ErrorLog__c();
            errorlog.giic_ErrorMessage__c = message;
            errorlog.giic_ErrorstatusDescription__c = message;
            if(message.contains('errors":')){
                List<string> errmsglst = message.split('errors":');
                errorlog.gii__ErrorMessage__c = errmsglst[1];
            }
            errorlog.giic_Shipment__c = shipmentRecord.id;
            if(!test.isRunningTest()){
            insert errorlog;
            }
        }
        
    }
   
}