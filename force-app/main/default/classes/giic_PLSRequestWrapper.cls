public with sharing class giic_PLSRequestWrapper {
    public giic_PLSRequestWrapper() {

    }

    public shippingRecordHeader shippingrecordHeader {get;set;} 

    public class loadAddress {
        public string name {get;set;}
        public string addressCode {get;set;}
        public string address1 {get;set;}
        public string city {get;set;}
        public string stateCode {get;set;}
        public string postalCode {get;set;}
        public string countryCode {get;set;}
        public string contactName {get;set;}
        public string contactPhone {get;set;}
     /*   public string contactFax {get;set;}
        public string contactEmail {get;set;}
        public string operatingWindowFrom {get;set;}
        public string operatingWindowTo {get;set;} */
    }

    public class sendmaterials {
        public decimal weight {get;set;}
        public string commodityClass {get;set;}
        public string weightUnit {get;set;}
        public string dimensionUnit {get;set;}
        public string productDescription {get;set;}
        public Decimal length {get;set;}
        public Decimal width {get;set;}
        public Decimal height {get;set;}
        public Decimal quantity {get;set;}
        public string packagingType {get;set;}
        public boolean hazmat {get;set;}
        public hazmatInfocls hazmatInfo {get;set;}
            }
    
    public class hazmatInfocls{
        public string unNumber {get;set;}
        public string emergencyCompany {get;set;}
        public string emergencyPhone {get;set;}
        public string emergencyContractNumber {get;set;}
        public string hazmatClass {get;set;}

    }

    public class shippingRecordHeader {

        public string shipmentNo {get;set;}
        public string poNum {get;set;}
        public string soNum {get;set;}
        public Date pickupDate {get;set;}
        public loadAddress originAddress {get;set;}
        public loadAddress destinationAddress {get;set;}
        public List<sendmaterials> materials {get;set;}
        public List<String> accessorialTypes {get;set;}
    }

    

    public static String getRequestedJson (gii__Shipment__c shipmentDetails){

        giic_PLSRequestWrapper reqWrap = new giic_PLSRequestWrapper();
        gii__Shipment__c shipmentInfo = new gii__Shipment__c();
        shipmentInfo = shipmentDetails;
        
        System.Debug('Check this shipment'+shipmentInfo);
     //   shipmentInfo = [SELECT id,Name,gii__SalesOrder__r.Name , gii__SalesOrder__r.gii__CustomerPONumber__c,gii__ShippedDate__c from gii__Shipment__c WHERE ID =: recordID];

        shippingRecordHeader shippingRecord = new shippingRecordHeader();
        List<sendmaterials> sendMaterialInfo = new List<sendmaterials>();
        hazmatInfocls hazmatInfoObj = new hazmatInfocls();
        sendmaterials loadmaterials  = new sendmaterials();
        loadAddress orgAddress = new loadAddress();
        loadAddress desAddress = new loadAddress();
        List<String> accessorialTypes = new List<String>();
        String accType = '';

        shippingRecord.shipmentNo = shipmentInfo.Name;
        
        shippingRecord.pickupDate = shipmentInfo.gii__ShippedDate__c;
        

        loadmaterials.productDescription = shipmentInfo.giic_ProductDescription__c;
        loadmaterials.weight = shipmentInfo.giic_Weight__c;
        loadmaterials.weightUnit = 'LBS';
        loadmaterials.commodityClass = shipmentInfo.giic_CommodityClass__c;
        loadmaterials.length = shipmentInfo.giic_Length__c;
        loadmaterials.width = shipmentInfo.giic_Width__c;
        loadmaterials.height = shipmentInfo.giic_Height__c;
        loadmaterials.dimensionUnit = 'INCH';
        loadmaterials.quantity = shipmentInfo.giic_Quantity__c;
        loadmaterials.packagingType = shipmentInfo.gic_PackageType__c;
        loadmaterials.hazmat = shipmentInfo.giic_Hazmat__c;
        system.debug('###::'+Label.giic_Hazmat_UN_Number);
        system.debug('###::'+Label.giic_Hazmat_Class);
        system.debug('###::'+shipmentInfo.giic_Hazmat__c);
       
        if(shipmentInfo.giic_Hazmat__c){
            hazmatInfoObj.unNumber = Label.giic_Hazmat_UN_Number;
            hazmatInfoObj.emergencyCompany = Label.giic_Hazmat_Emergency_Company;
            hazmatInfoObj.emergencyPhone = Label.giic_Hazmat_EmergencyPhone;
            hazmatInfoObj.emergencyContractNumber = Label.giic_Hazmat_Emergency_ContractNumber;
            hazmatInfoObj.hazmatClass = Label.giic_Hazmat_Class;
            loadmaterials.hazmatInfo = hazmatInfoObj;
        }
        
        
         sendMaterialInfo.add(loadmaterials);


        if(shipmentInfo.gii__TransferOrder__r.Name != null && shipmentInfo.gii__TransferOrder__r.Name != ''){
        desAddress.Name = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.Name;
        desAddress.address1 = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStreet__c;
        desAddress.addressCode = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__c;
        desAddress.city = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCity__c;
        desAddress.contactName = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name;
        desAddress.contactPhone = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone;
        desAddress.countryCode = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseCountry__c;
        desAddress.postalCode = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseZipPostalCode__c;
        desAddress.stateCode = shipmentInfo.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__WareHouseStateProvince__c;

        orgAddress.Name = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.Name;
        orgAddress.address1 = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStreet__c;
        orgAddress.addressCode = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__c;
        orgAddress.city = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCity__c;
        orgAddress.contactName = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name;
        orgAddress.contactPhone = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone;
        orgAddress.countryCode = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseCountry__c;
        orgAddress.postalCode = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseZipPostalCode__c;
        orgAddress.stateCode = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.gii__WareHouseStateProvince__c;

        accType = shipmentInfo.gii__TransferOrder__r.gii__FromWarehouse__r.giic_Accessorial_Types__c;
        accessorialTypes.add(accType);
        }
        else {

            shippingRecord.soNum = shipmentInfo.gii__SalesOrder__r.Name;
            shippingRecord.poNum = shipmentInfo.gii__SalesOrder__r.gii__CustomerPONumber__c;
            accType = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.giic_Accessorial_Types__c;
            accessorialTypes.add(accType);

            desAddress.Name = shipmentInfo.gii__SalesOrder__r.giic_Site__r.Name;
            desAddress.address1 = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__Street__c;
            desAddress.addressCode = shipmentInfo.gii__SalesOrder__r.giic_Site__c;
            desAddress.city = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__City__c;
            desAddress.contactName = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Name;
            desAddress.contactPhone = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__SiteContact__r.Phone;
            desAddress.countryCode = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__Country__c;
            desAddress.postalCode = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__ZipPostalCode__c;
            desAddress.stateCode = shipmentInfo.gii__SalesOrder__r.giic_Site__r.gii__StateProvince__c;
    
            orgAddress.Name = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.Name;
            orgAddress.address1 = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStreet__c;
            orgAddress.addressCode = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__c;
            orgAddress.city = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCity__c;
            orgAddress.contactName = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Name;
            orgAddress.contactPhone = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__FieldServiceEngineer__r.gii__Contact__r.Phone;
            orgAddress.countryCode = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseCountry__c;
            orgAddress.postalCode = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseZipPostalCode__c;
            orgAddress.stateCode = shipmentInfo.gii__SalesOrder__r.gii__Warehouse__r.gii__WareHouseStateProvince__c;
        }

        shippingRecord.materials = sendMaterialInfo;
        shippingRecord.originAddress = orgAddress;
        shippingRecord.destinationAddress = desAddress;
        shippingRecord.accessorialTypes = accessorialTypes;

        String jsonString = JSON.serialize(shippingRecord);
        System.debug('Check this json'+jsonString);

      //  reqWrap.shippingrecordHeader = shippingRecord;

      return jsonString;

      //  String body = JSON.serialize(reqWrap);
     /* String body = '{"shipmentNo":"shipmentNo","pickupNotes":"pu notes","deliveryNotes":"delivery notes","shippingLabelNotes":"sl notes","pickupDate":"2023-03-23","originAddress":{"name":"addr1","addressCode":"LT-120052-0844569","city":"DETROIT","stateCode":"MI","postalCode":"48205","countryCode":"USA","operatingWindowFrom":"08:30","operatingWindowTo":"17:30","notes":"origin notes","contactPhone":"+1(234)5678901","contactName":"Rohit","contactEmail":"rohitkumar.vanvani@fujitsu.com","address1":"Avenue A SW"},"destinationAddress":{"name":"addr2","addressCode":"LT-120052-0844570","city":"CHICAGO","stateCode":"IL","postalCode":"60608","countryCode":"USA","operatingWindowFrom":"08:30","operatingWindowTo":"17:30","notes":"dest notes","contactPhone":"+1(234)5678901","contactName":"Rohit","contactEmail":"rohitkumar.vanvani@fujitsu.com","address1":"Avenue A SW"},"materials":[{"productDescription":"something","weight":20,"weightUnit":"LBS","height":"48","width":"48","length":"48","dimensionUnit":"INCH","quantity":1,"commodityClass":"60","packagingType":"PLT","hazmat":false}],"accessorialTypes":[]}';
        System.Debug('This is body'+body);
        
        return body; */


    }
   
    
}