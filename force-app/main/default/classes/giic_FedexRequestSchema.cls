public class giic_FedexRequestSchema {    
    
    
    public class FedexShipmentWrapperResponse { 
        public String transactionId;	//5ea5708f-16d3-456a-9bc1-ba2f86c1bf4b
        public outputWrapper output;            
    }
    public class outputWrapper {
        public transactionShipmentWrapper[] transactionShipments;
    }
    public class transactionShipmentWrapper{
        public alertWrapper[] alerts;
        public String masterTrackingNumber;	//794957047027
        public String serviceType;	//STANDARD_OVERNIGHT
        public String shipDatestamp;	//2023-04-25
        public String serviceName;	//FedEx Standard Overnight®
        public pieceResponseWrapper[] pieceResponses;
        public shipmentAdvisoryDetailWrapper shipmentAdvisoryDetails;
        public completedShipmentDetailWrapper completedShipmentDetail;
        public String serviceCategory;	//EXPRESS
    }
    public class alertWrapper{
        
    }
    public class pieceResponseWrapper{
        
    }
    
    public class shipmentAdvisoryDetailWrapper{
        
    }
    
    public class completedShipmentDetailWrapper{
        public String url;	//https://wwwtest.fedex.com/document/v1/cache/retrieve/SH,773dcc5a4d2ec699794957047027_SHIPPING_P?isLabel=true&autoPrint=false
        public String contentType;	//LABEL
        public Integer copiesToPrint;	//1
        public String docType;
        
    }
    
    public class FedexCreateShipmentWrapperRequest {
        public FedexRequestShipmentWrapper requestedShipment{get;set;} 
        public String labelResponseOptions {get;set;} 	//STANDARD_OVERNIGHT
        public FedexAccountNumberWrapper  accountNumber{get;set;}         
        
    }
    
    public class FedexAccountNumberWrapper {
        public String value;	//740561073
    }
    
    public class FedexRequestShipmentWrapper {       
        
        public ShipperWrapper shipper{get;set;} 
        public RecipientWrapper[] recipients;       
        public Date shipDatestamp {get;set;} 	//2020-07-03
        public String serviceType {get;set;} 	//STANDARD_OVERNIGHT
        public String packagingType {get;set;} 	//FEDEX_
        public String pickupType {get;set;} 	//USE_SCHEDULED_PICKUP
        public boolean blockInsightVisibility {get;set;} 
        public shippingChargesPaymentWrapper shippingChargesPayment {get;set;} 
        public shipmentSpecialServicesWrapper shipmentSpecialServices {get;set;} 
        public LabelSpecificationWrapper labelSpecification {get;set;}
        public customsClearanceDetailWrapper customsClearanceDetail {get;set;}
        public shippingDocumentSpecificationWrapper shippingDocumentSpecification {get;set;}
        public requestedPackageLineItemsWrapper[] requestedPackageLineItems {get;set;}     
        
    }
    class ShipperWrapper {
        public ContactWrapper contact {get;set;} 
        public AddressWrapper address {get;set;} 
    }
    
    class RecipientWrapper {
        public ContactWrapper contact {get;set;}
        public AddressWrapper address {get;set;}
    }    
    class ContactWrapper {
        public String personName {get;set;} 	//RECIPIENT NAME
        public String phoneNumber {get;set;} 	//1234567890
        public String companyName {get;set;} 	//Recipient Company Name
    }
    class AddressWrapper {
        public string[] streetLines;      
        public String city {get;set;} 
        public String stateOrProvinceCode {get;set;} 
        public String postalCode {get;set;} 
        public String countryCode {get;set;}         
        
    }
    
    public Class shippingChargesPaymentWrapper {
        public String paymentType {get;set;}	//SENDER
    }
    
    public Class shipmentSpecialServicesWrapper {
        public string[] specialServiceTypes {get;set;}
        public etdDetailWrapper etdDetail {get;set;}
    }
    
    
    public Class etdDetailWrapper{
        public string[] requestedDocumentTypes {get;set;}
    }
    public Class LabelSpecificationWrapper {
        public String imageType {get;set;} 	//PDF
        public String labelStockType {get;set;} //PAPER_85X11_TOP_HALF_LABEL
    }
    
    public Class customsClearanceDetailWrapper {
        public DutiesPaymentWrapper dutiesPayment {get;set;}
        public boolean isDocumentOnly {get;set;}
        public CommoditiesWrapper[] commodities {get;set;}
        
    }
    public class DutiesPaymentWrapper {
        public String paymentType {get;set;}	//SENDER
    }
    
    public class CommoditiesWrapper {
        public String description{get;set;} 	//Commodity description
        public String countryOfManufacture {get;set;}	//US
        public Integer quantity	{get;set;}//1
        public String quantityUnits {get;set;}	//PCS
        public PriceWrapper unitPrice {get;set;}
        public PriceWrapper customsValue {get;set;}
        public weightWrapper weight {get;set;}
    }
    
    class PriceWrapper {
        public Decimal amount {get;set;}	//100
        public String currency_X {get;set;}	//USD
    }
    /*class CustomsValueWrapper {
public Integer amount {get;set;}	//100
public String currency {get;set;}	//USD
}
*/
    public Class shippingDocumentSpecificationWrapper {
        public String[] shippingDocumentTypes {get;set;}
        public CommercialInvoiceDetailWrapper commercialInvoiceDetail {get;set;}
    }
    
    public Class CommercialInvoiceDetailWrapper {
        public CustomerImageUsagesWrapper[] customerImageUsages;
        public DocumentFormatWrapper documentFormat;
    }
    public Class CustomerImageUsagesWrapper{
        public String id {get;set;}	//IMAGE_1
        public String type {get;set;}	//LETTER_HEAD
        public String providedImageType {get;set;}
    }
    
    public Class DocumentFormatWrapper{
        public String stockType {get;set;}	//PAPER_LETTER
        public String docType {get;set;}	//PDF
    }
    public Class requestedPackageLineItemsWrapper {        
        public weightWrapper weight {get;set;}
        public DimensionWrapper dimensions {get;set;}
    }
    
    public Class DimensionWrapper {
        public Decimal length;	//100
        public Decimal width;	//50
        public Decimal height;	//30
        public String units;	//CM
    }
    public Class weightWrapper {
        public Decimal value {get;set;}
        public String units {get;set;}
        
    }
    
    public static string generateFedExRequestJson( gii__Shipment__c shipmentInfo, String accNum, giic_JMSIntegrationMapping__mdt jmsIntAttr) {
        
        system.debug('Shipment Info:'+ shipmentInfo);
        
        List<gii__ShipmentDetail__c> shipDetailInfoList = [SELECT Id, gii__Shipment__c, gii__UnitCost__c, gii__UnitPrice__c, gii__TransferOrder__c, 
                                                           gii__StockingUnitofMeasure__c, gii__Shipped_Amount__c, gii__ShippedQuantity__c,CurrencyIsoCode,
                                                           gii__ShippedAmount__c, gii__ProductAmount__c FROM gii__ShipmentDetail__c 
                                                           where gii__Shipment__c =: shipmentInfo.id]; 
        
        /*gii__ShipmentDetail__c shipDetailInfo = [SELECT Id, gii__Shipment__c, gii__UnitCost__c, gii__UnitPrice__c, gii__TransferOrder__c, 
gii__StockingUnitofMeasure__c, gii__Shipped_Amount__c, gii__ShippedQuantity__c,CurrencyIsoCode,
gii__ShippedAmount__c, gii__ProductAmount__c FROM gii__ShipmentDetail__c 
where gii__Shipment__c =: shipmentInfo.id limit 1];*/
        List<gii__ShipmentStaging__c> reqPackLineItems =[SELECT Id,giic_Height__c,giic_Length__c,giic_Shipment__c,giic_Weight_Value__c,giic_Width__c
                                                         from gii__ShipmentStaging__c where giic_Shipment__c =: shipmentInfo.id];
        
        System.debug('reqPackLineItems' +'--' + reqPackLineItems.size() +'--' +reqPackLineItems );
        
        giic_FedexRequestSchema.FedexCreateShipmentWrapperRequest createShipment = new giic_FedexRequestSchema.FedexCreateShipmentWrapperRequest();
        createShipment.labelResponseOptions = 'LABEL';
        
        giic_FedexRequestSchema.FedexAccountNumberWrapper  accNumber = new  giic_FedexRequestSchema.FedexAccountNumberWrapper();
        accNumber.value = accNum;
        
        createShipment.accountNumber = accNumber;
        
        //Build Request Shipment section
        giic_FedexRequestSchema.FedexRequestShipmentWrapper  shipmentRequest = new  giic_FedexRequestSchema.FedexRequestShipmentWrapper();
        shipmentRequest.shipDatestamp = system.today();
        shipmentRequest.serviceType = shipmentInfo.giic_ShipmentCarrier__r.Name;
        
        shipmentRequest.pickupType = jmsIntAttr.giic_FEDEX_Pickup_Type__c;
        shipmentRequest.blockInsightVisibility = false;
        
        
        shipmentRequest.packagingType = jmsIntAttr.giic_FEDEX_Packaging_Type__c; //YOUR_PACKAGING for international
        
        
        createShipment.requestedShipment = shipmentRequest;
        
        
        /*=======================================Build SHipper Request Info Contact & Address==============================================================================*/
        String salesOrderInfo = shipmentInfo.gii__SalesOrder__c;
        String transOrderInfo = shipmentInfo.gii__TransferOrder__c;
        if(salesOrderInfo != '' && salesOrderInfo != null)
        {
             System.debug('Sales Order Flow');
            giic_FedexRequestSchema.ContactWrapper shipperContactInfo = new  giic_FedexRequestSchema.ContactWrapper();
            shipperContactInfo.companyName = 'JMS';
            shipperContactInfo.personName = 'Mark Wheeler';
            shipperContactInfo.phoneNumber = '5231234234';
            
            giic_FedexRequestSchema.AddressWrapper shipperAddressInfo = new giic_FedexRequestSchema.AddressWrapper();
            shipperAddressInfo.streetLines =  new List<String>();
            shipperAddressInfo.streetLines.add(shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStreet__c);
            
            shipperAddressInfo.city = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCity__c;
            shipperAddressInfo.stateOrProvinceCode = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStateProvince__c;
            shipperAddressInfo.countryCode = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCountry__c;
            shipperAddressInfo.postalCode = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseZipPostalCode__c;
            
            
            giic_FedexRequestSchema.ShipperWrapper shipperInfo = new giic_FedexRequestSchema.ShipperWrapper();
            shipperInfo.contact =  shipperContactInfo;
            shipperInfo.address = shipperAddressInfo;
            
            shipmentRequest.shipper = shipperInfo;
            /*==================================================================================================================================================================*/  
            
            /*=======================================Build Recipient Request Info Contact & Address==============================================================================*/
            giic_FedexRequestSchema.ContactWrapper recipientContactInfo = new  giic_FedexRequestSchema.ContactWrapper();
            recipientContactInfo.companyName = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Account.Name;
            recipientContactInfo.personName = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name;
            recipientContactInfo.phoneNumber = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Phone;
            
            giic_FedexRequestSchema.AddressWrapper recipientAddressInfo = new giic_FedexRequestSchema.AddressWrapper();
            recipientAddressInfo.streetLines =  new List<String>();
            recipientAddressInfo.streetLines.add(shipmentInfo.gii__SalesOrder__r.gii__ShipToStreet__c);
            
            recipientAddressInfo.city = shipmentInfo.gii__SalesOrder__r.gii__ShipToCity__c;
            recipientAddressInfo.stateOrProvinceCode = shipmentInfo.gii__SalesOrder__r.gii__ShipToStateProvince__c;
            recipientAddressInfo.countryCode =shipmentInfo.gii__SalesOrder__r.gii__ShipToCountry__c;
            recipientAddressInfo.postalCode = shipmentInfo.gii__SalesOrder__r.gii__ShipToZipPostalCode__c;
            
            
            
            giic_FedexRequestSchema.RecipientWrapper recipientInfo = new giic_FedexRequestSchema.RecipientWrapper();
            
            recipientInfo.contact =  recipientContactInfo;
            recipientInfo.address = recipientAddressInfo;
            
            shipmentRequest.recipients = new List<giic_FedexRequestSchema.RecipientWrapper>();
            shipmentRequest.recipients.add(recipientInfo);
            
            /*=======================================Build LabelSpecification==============================================================================*/ 
            giic_FedexRequestSchema.LabelSpecificationWrapper labelSpecs = new giic_FedexRequestSchema.LabelSpecificationWrapper();
            labelSpecs.imageType = 'PDF';
            labelSpecs.labelStockType = 'PAPER_85X11_TOP_HALF_LABEL';
            
            shipmentRequest.labelSpecification = labelSpecs;
            
            if(shipmentInfo.gii__SalesOrder__r.gii__ShipToCountry__c == 'US' || shipmentInfo.gii__SalesOrder__r.gii__ShipToCountry__c == 'USA')
            {
                giic_FedexRequestSchema.weightWrapper weightsValue = new  giic_FedexRequestSchema.weightWrapper();
                weightsValue.value = 10;
                weightsValue.units = 'LB'; 
                
                giic_FedexRequestSchema.requestedPackageLineItemsWrapper domesticpackLineItems = new  giic_FedexRequestSchema.requestedPackageLineItemsWrapper();
                domesticpackLineItems.weight = weightsValue;
                shipmentRequest.requestedPackageLineItems = new List<giic_FedexRequestSchema.requestedPackageLineItemsWrapper>();
                shipmentRequest.requestedPackageLineItems.add(domesticpackLineItems);
            }
            
            //---------------- Mandatory Attributes for Interntational Shipping --//
            
            
            if(shipmentInfo.gii__SalesOrder__r.gii__ShipToCountry__c != 'US' && shipmentInfo.gii__SalesOrder__r.gii__ShipToCountry__c != 'USA')
            {
                System.debug('**** Executed International Block' + shipmentInfo.gii__SalesOrder__r.gii__ShipToCountry__c);
                //======= Shipment Special Services -- START============/
                giic_FedexRequestSchema.etdDetailWrapper etdDetails = new giic_FedexRequestSchema.etdDetailWrapper();
                etdDetails.requestedDocumentTypes =  new List<String>();
                etdDetails.requestedDocumentTypes.add('COMMERCIAL_INVOICE'); //Default
                
                
                giic_FedexRequestSchema.shipmentSpecialServicesWrapper specialServices = new  giic_FedexRequestSchema.shipmentSpecialServicesWrapper();
                specialServices.specialServiceTypes =  new List<String>();         
                specialServices.specialServiceTypes.add('ELECTRONIC_TRADE_DOCUMENTS'); //Default
                
                specialServices.etdDetail = etdDetails;
                shipmentRequest.shipmentSpecialServices = specialServices;
                
                //======= Shipment Special Services -- END============//
                List< giic_FedexRequestSchema.CommoditiesWrapper> commoditiesInfoList = new List< giic_FedexRequestSchema.CommoditiesWrapper>();
                for(gii__ShipmentDetail__c shipDetailInfo : shipDetailInfoList)
                {                
                    
                    giic_FedexRequestSchema.PriceWrapper unitPriceInfo = new giic_FedexRequestSchema.PriceWrapper();
                    unitPriceInfo.amount = shipDetailInfo.gii__UnitPrice__c;
                    unitPriceInfo.currency_X = shipDetailInfo.CurrencyIsoCode;
                    
                    giic_FedexRequestSchema.PriceWrapper customsValueInfo = new giic_FedexRequestSchema.PriceWrapper();
                    customsValueInfo.amount = (shipDetailInfo.gii__UnitPrice__c * shipDetailInfo.gii__ShippedQuantity__c);
                    customsValueInfo.currency_X = shipDetailInfo.CurrencyIsoCode;
                    
                    giic_FedexRequestSchema.weightWrapper commoditiesWeightInfo = new   giic_FedexRequestSchema.weightWrapper();
                    commoditiesWeightInfo.value = 1;
                    commoditiesWeightInfo.units = 'KG'; 
                    
                    
                    giic_FedexRequestSchema.CommoditiesWrapper commoditiesInfo = new  giic_FedexRequestSchema.CommoditiesWrapper();
                    commoditiesInfo.description = 'Commodity description';
                    commoditiesInfo.countryOfManufacture= 'US';
                    commoditiesInfo.quantity = Integer.valueOf(shipDetailInfo.gii__ShippedQuantity__c);
                    commoditiesInfo.quantityUnits = shipDetailInfo.gii__StockingUnitofMeasure__c;
                    commoditiesInfo.unitPrice = unitPriceInfo;
                    commoditiesInfo.customsValue = customsValueInfo;
                    commoditiesInfo.weight = commoditiesWeightInfo;
                    
                    commoditiesInfoList.add(commoditiesInfo);
                }
                
                giic_FedexRequestSchema.DutiesPaymentWrapper dutiesPayment = new giic_FedexRequestSchema.DutiesPaymentWrapper();
                dutiesPayment.paymentType = 'SENDER';
                
                giic_FedexRequestSchema.customsClearanceDetailWrapper customsClearance = new giic_FedexRequestSchema.customsClearanceDetailWrapper();
                customsClearance.commodities = new List< giic_FedexRequestSchema.CommoditiesWrapper>();   
                customsClearance.commodities = commoditiesInfoList;
                customsClearance.dutiesPayment = dutiesPayment;
                customsClearance.isDocumentOnly = true; //Default
                
                shipmentRequest.customsClearanceDetail = customsClearance;
                
                //================= ShippingDocumentSpecification =============/
                //
                
                
                giic_FedexRequestSchema.CustomerImageUsagesWrapper customImageUsageInfo1 = new giic_FedexRequestSchema.CustomerImageUsagesWrapper();
                customImageUsageInfo1.id = 'IMAGE_1';
                customImageUsageInfo1.providedImageType = 'LETTER_HEAD';
                customImageUsageInfo1.type = 'LETTER_HEAD';
                
                giic_FedexRequestSchema.CustomerImageUsagesWrapper customImageUsageInfo2 = new giic_FedexRequestSchema.CustomerImageUsagesWrapper();
                customImageUsageInfo2.id = 'IMAGE_2';
                customImageUsageInfo2.providedImageType = 'SIGNATURE';
                customImageUsageInfo2.type = 'SIGNATURE';
                
                
                giic_FedexRequestSchema.DocumentFormatWrapper docFormatInfo = new giic_FedexRequestSchema.DocumentFormatWrapper();
                docFormatInfo.docType = 'PDF';
                docFormatInfo.stockType = 'PAPER_LETTER';
                
                
                giic_FedexRequestSchema.CommercialInvoiceDetailWrapper commericalInvoiceInfo = new giic_FedexRequestSchema.CommercialInvoiceDetailWrapper();
                commericalInvoiceInfo.customerImageUsages = new List< giic_FedexRequestSchema.CustomerImageUsagesWrapper>();
                commericalInvoiceInfo.customerImageUsages.add(customImageUsageInfo1);
                commericalInvoiceInfo.customerImageUsages.add(customImageUsageInfo2);
                commericalInvoiceInfo.documentFormat = docFormatInfo;
                
                giic_FedexRequestSchema.shippingDocumentSpecificationWrapper shippingDOCInfo = new giic_FedexRequestSchema.shippingDocumentSpecificationWrapper();
                shippingDOCInfo.shippingDocumentTypes = new List<String>();
                shippingDOCInfo.shippingDocumentTypes.add('COMMERCIAL_INVOICE');
                shippingDOCInfo.commercialInvoiceDetail = commericalInvoiceInfo;
                
                
                shipmentRequest.shippingDocumentSpecification = shippingDOCInfo;
                
                /*=======================================Build RequestedPackageLineItems==============================================================================*/  
                List<giic_FedexRequestSchema.requestedPackageLineItemsWrapper> packLineItemsList = new List<giic_FedexRequestSchema.requestedPackageLineItemsWrapper>();
                for(gii__ShipmentStaging__c reqPAckItems : reqPackLineItems)
                {
                    giic_FedexRequestSchema.weightWrapper weightValue = new  giic_FedexRequestSchema.weightWrapper();
                    weightValue.value = reqPAckItems.giic_Weight_Value__c;
                    weightValue.units = 'KG';  
                    
                    giic_FedexRequestSchema.DimensionWrapper dimensionInfo = new giic_FedexRequestSchema.DimensionWrapper();
                    dimensionInfo.height =reqPAckItems.giic_Height__c;
                    dimensionInfo.length = reqPAckItems.giic_Length__c;
                    dimensionInfo.width = reqPAckItems.giic_Width__c;
                    dimensionInfo.units = 'CM';
                    
                    giic_FedexRequestSchema.requestedPackageLineItemsWrapper packLineItems = new  giic_FedexRequestSchema.requestedPackageLineItemsWrapper();
                    packLineItems.weight = weightValue;
                    packLineItems.dimensions = dimensionInfo; 
                    
                    packLineItemsList.add(packLineItems);
                }
                shipmentRequest.requestedPackageLineItems = packLineItemsList;
                
                
            }
        }
        if(transOrderInfo != '' && transOrderInfo != null)
        {
            System.debug('Transfer Order Flow');
            giic_FedexRequestSchema.ContactWrapper shipperContactInfo = new  giic_FedexRequestSchema.ContactWrapper();
            shipperContactInfo.companyName = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.Name;
            shipperContactInfo.personName = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name;
            shipperContactInfo.phoneNumber =  shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone;
            
            giic_FedexRequestSchema.AddressWrapper shipperAddressInfo = new giic_FedexRequestSchema.AddressWrapper();
            shipperAddressInfo.streetLines =  new List<String>();
            shipperAddressInfo.streetLines.add(shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStreet__c);
            
            shipperAddressInfo.city = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCity__c;
            shipperAddressInfo.stateOrProvinceCode = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStateProvince__c;
            shipperAddressInfo.countryCode =shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCountry__c;
            shipperAddressInfo.postalCode = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseZipPostalCode__c;
            
            
            giic_FedexRequestSchema.ShipperWrapper shipperInfo = new giic_FedexRequestSchema.ShipperWrapper();
            shipperInfo.contact =  shipperContactInfo;
            shipperInfo.address = shipperAddressInfo;
            
            shipmentRequest.shipper = shipperInfo;
            /*==================================================================================================================================================================*/  
            
            /*=======================================Build Recipient Request Info Contact & Address==============================================================================*/
            giic_FedexRequestSchema.ContactWrapper recipientContactInfo = new  giic_FedexRequestSchema.ContactWrapper();
            recipientContactInfo.companyName = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.Name;
            recipientContactInfo.personName = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name;
            recipientContactInfo.phoneNumber = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone;
            
            giic_FedexRequestSchema.AddressWrapper recipientAddressInfo = new giic_FedexRequestSchema.AddressWrapper();
            recipientAddressInfo.streetLines =  new List<String>();
            recipientAddressInfo.streetLines.add(shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStreet__c);
            
            recipientAddressInfo.city = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCity__c;
            recipientAddressInfo.stateOrProvinceCode = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStateProvince__c;
            recipientAddressInfo.countryCode =shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c;
            recipientAddressInfo.postalCode = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseZipPostalCode__c;
            
            
            
            giic_FedexRequestSchema.RecipientWrapper recipientInfo = new giic_FedexRequestSchema.RecipientWrapper();
            
            recipientInfo.contact =  recipientContactInfo;
            recipientInfo.address = recipientAddressInfo;
            
            shipmentRequest.recipients = new List<giic_FedexRequestSchema.RecipientWrapper>();
            shipmentRequest.recipients.add(recipientInfo);       
            
            /*=======================================Build LabelSpecification==============================================================================*/ 
            giic_FedexRequestSchema.LabelSpecificationWrapper labelSpecs = new giic_FedexRequestSchema.LabelSpecificationWrapper();
            labelSpecs.imageType = 'PDF';
            labelSpecs.labelStockType = 'PAPER_85X11_TOP_HALF_LABEL';
            
            shipmentRequest.labelSpecification = labelSpecs;
            
            if(shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c == 'US' || shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c == 'USA') 
            {
                giic_FedexRequestSchema.weightWrapper weightsValue = new  giic_FedexRequestSchema.weightWrapper();
                weightsValue.value = 10;
                weightsValue.units = 'LB'; 
                
                giic_FedexRequestSchema.requestedPackageLineItemsWrapper domesticpackLineItems = new  giic_FedexRequestSchema.requestedPackageLineItemsWrapper();
                domesticpackLineItems.weight = weightsValue;
                shipmentRequest.requestedPackageLineItems = new List<giic_FedexRequestSchema.requestedPackageLineItemsWrapper>();
                shipmentRequest.requestedPackageLineItems.add(domesticpackLineItems);
            }
            
            
            if(shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c != 'US' && shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c != 'USA')
            {
                System.debug('**** Executed International Block' + shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c);
                //======= Shipment Special Services -- START============/
                giic_FedexRequestSchema.etdDetailWrapper etdDetails = new giic_FedexRequestSchema.etdDetailWrapper();
                etdDetails.requestedDocumentTypes =  new List<String>();
                etdDetails.requestedDocumentTypes.add('COMMERCIAL_INVOICE'); //Default
                
                
                giic_FedexRequestSchema.shipmentSpecialServicesWrapper specialServices = new  giic_FedexRequestSchema.shipmentSpecialServicesWrapper();
                specialServices.specialServiceTypes =  new List<String>();         
                specialServices.specialServiceTypes.add('ELECTRONIC_TRADE_DOCUMENTS'); //Default
                
                specialServices.etdDetail = etdDetails;
                shipmentRequest.shipmentSpecialServices = specialServices;
                
                //======= Shipment Special Services -- END============//
                List< giic_FedexRequestSchema.CommoditiesWrapper> commoditiesInfoList = new List< giic_FedexRequestSchema.CommoditiesWrapper>();
                for(gii__ShipmentDetail__c shipDetailInfo : shipDetailInfoList)
                {                
                    
                    giic_FedexRequestSchema.PriceWrapper unitPriceInfo = new giic_FedexRequestSchema.PriceWrapper();
                    unitPriceInfo.amount = shipDetailInfo.gii__UnitPrice__c;
                    unitPriceInfo.currency_X = shipDetailInfo.CurrencyIsoCode;
                    
                    giic_FedexRequestSchema.PriceWrapper customsValueInfo = new giic_FedexRequestSchema.PriceWrapper();
                    customsValueInfo.amount = (shipDetailInfo.gii__UnitPrice__c * shipDetailInfo.gii__ShippedQuantity__c);
                    customsValueInfo.currency_X = shipDetailInfo.CurrencyIsoCode;
                    
                    giic_FedexRequestSchema.weightWrapper commoditiesWeightInfo = new   giic_FedexRequestSchema.weightWrapper();
                    commoditiesWeightInfo.value = 1;
                    commoditiesWeightInfo.units = 'KG'; 
                    
                    
                    giic_FedexRequestSchema.CommoditiesWrapper commoditiesInfo = new  giic_FedexRequestSchema.CommoditiesWrapper();
                    commoditiesInfo.description = 'Commodity description';
                    commoditiesInfo.countryOfManufacture= 'US';
                    commoditiesInfo.quantity = Integer.valueOf(shipDetailInfo.gii__ShippedQuantity__c);
                    commoditiesInfo.quantityUnits = shipDetailInfo.gii__StockingUnitofMeasure__c;
                    commoditiesInfo.unitPrice = unitPriceInfo;
                    commoditiesInfo.customsValue = customsValueInfo;
                    commoditiesInfo.weight = commoditiesWeightInfo;
                    
                    commoditiesInfoList.add(commoditiesInfo);
                }
                
                giic_FedexRequestSchema.DutiesPaymentWrapper dutiesPayment = new giic_FedexRequestSchema.DutiesPaymentWrapper();
                dutiesPayment.paymentType = 'SENDER';
                
                giic_FedexRequestSchema.customsClearanceDetailWrapper customsClearance = new giic_FedexRequestSchema.customsClearanceDetailWrapper();
                customsClearance.commodities = new List< giic_FedexRequestSchema.CommoditiesWrapper>();   
                customsClearance.commodities = commoditiesInfoList;
                customsClearance.dutiesPayment = dutiesPayment;
                customsClearance.isDocumentOnly = true; //Default
                
                shipmentRequest.customsClearanceDetail = customsClearance;
                
                //================= ShippingDocumentSpecification =============/
                //
                
                
                giic_FedexRequestSchema.CustomerImageUsagesWrapper customImageUsageInfo1 = new giic_FedexRequestSchema.CustomerImageUsagesWrapper();
                customImageUsageInfo1.id = 'IMAGE_1';
                customImageUsageInfo1.providedImageType = 'LETTER_HEAD';
                customImageUsageInfo1.type = 'LETTER_HEAD';
                
                giic_FedexRequestSchema.CustomerImageUsagesWrapper customImageUsageInfo2 = new giic_FedexRequestSchema.CustomerImageUsagesWrapper();
                customImageUsageInfo2.id = 'IMAGE_2';
                customImageUsageInfo2.providedImageType = 'SIGNATURE';
                customImageUsageInfo2.type = 'SIGNATURE';
                
                
                giic_FedexRequestSchema.DocumentFormatWrapper docFormatInfo = new giic_FedexRequestSchema.DocumentFormatWrapper();
                docFormatInfo.docType = 'PDF';
                docFormatInfo.stockType = 'PAPER_LETTER';
                
                
                giic_FedexRequestSchema.CommercialInvoiceDetailWrapper commericalInvoiceInfo = new giic_FedexRequestSchema.CommercialInvoiceDetailWrapper();
                commericalInvoiceInfo.customerImageUsages = new List< giic_FedexRequestSchema.CustomerImageUsagesWrapper>();
                commericalInvoiceInfo.customerImageUsages.add(customImageUsageInfo1);
                commericalInvoiceInfo.customerImageUsages.add(customImageUsageInfo2);
                commericalInvoiceInfo.documentFormat = docFormatInfo;
                
                giic_FedexRequestSchema.shippingDocumentSpecificationWrapper shippingDOCInfo = new giic_FedexRequestSchema.shippingDocumentSpecificationWrapper();
                shippingDOCInfo.shippingDocumentTypes = new List<String>();
                shippingDOCInfo.shippingDocumentTypes.add('COMMERCIAL_INVOICE');
                shippingDOCInfo.commercialInvoiceDetail = commericalInvoiceInfo;
                
                
                shipmentRequest.shippingDocumentSpecification = shippingDOCInfo;
                
                /*=======================================Build RequestedPackageLineItems==============================================================================*/  
                List<giic_FedexRequestSchema.requestedPackageLineItemsWrapper> packLineItemsList = new List<giic_FedexRequestSchema.requestedPackageLineItemsWrapper>();
                for(gii__ShipmentStaging__c reqPAckItems : reqPackLineItems)
                {
                    giic_FedexRequestSchema.weightWrapper weightValue = new  giic_FedexRequestSchema.weightWrapper();
                    weightValue.value = reqPAckItems.giic_Weight_Value__c;
                    weightValue.units = 'KG';  
                    
                    giic_FedexRequestSchema.DimensionWrapper dimensionInfo = new giic_FedexRequestSchema.DimensionWrapper();
                    dimensionInfo.height =reqPAckItems.giic_Height__c;
                    dimensionInfo.length = reqPAckItems.giic_Length__c;
                    dimensionInfo.width = reqPAckItems.giic_Width__c;
                    dimensionInfo.units = 'CM';
                    
                    giic_FedexRequestSchema.requestedPackageLineItemsWrapper packLineItems = new  giic_FedexRequestSchema.requestedPackageLineItemsWrapper();
                    packLineItems.weight = weightValue;
                    packLineItems.dimensions = dimensionInfo; 
                    
                    packLineItemsList.add(packLineItems);
                }
                shipmentRequest.requestedPackageLineItems = packLineItemsList;
                
                
            }
        }      
        
        /*==================================================================================================================================================================*/  
        
        
        /*=======================================Build ShippingChargesPayment==============================================================================*/
        giic_FedexRequestSchema.shippingChargesPaymentWrapper shipCharge = new giic_FedexRequestSchema.shippingChargesPaymentWrapper();
        shipCharge.paymentType = 'SENDER';
        
        
        shipmentRequest.shippingChargesPayment = shipCharge;
        
        
        
        
        
        string reqPayload = JSON.serialize(createShipment);  
        
        
        system.debug('reqPayload' + reqPayload);
        
        return reqPayload;
        
    }
}