/**
* @Version 		  : 1.0
* @Name 			  : giic_Test_DataCreationUtility
* @description       : Create Test data for test classes
* @author            : 

* @last modified on  :
* @last modified by  :
**/
@IsTest(SeeAllData=false)
public class giic_Test_DataCreationUtility {
    public static gii__SystemPolicy__c objSystemPolicy{get;set;}
    public static List<Account> lstAccount{get;set;}
    public static List<gii__Warehouse__c> lstWarehouse{get;set;}
    //  public static List<gii__Location__c> lstLocations{get;set;}
    public static List<gii__Product2Add__c> lstProd{get;set;}
    public List<Product2> lstProducts;
    public static list<gii__SalesOrder__c> lstSalesOrder; //insertBulkSalesOrder
    public static list<gii__SalesOrderLine__c> lstSalesOrderLine;
    
    public static list<gii__TransferOrderStaging__c> lstTOStaging;
    public static list<gii__TransferOrderLineStaging__c> lstTOLStaging;
    public static list<gii__TransferOrder__c> lstTransferOrder; //insertBulkSalesOrder
    public static list<gii__TransferOrderLine__c> lstTransferOrderLine;
    
    
    // beloew variable added by Himanshu,kumar@fujitsu.com
    public static list<gii__WarehouseGroup__c> lstwhg;
    public static List<gii__Warehouse__c> lstWarehouse_N{get;set;}
    public static List<gii__UnitofMeasure__c> lstUnitofMeasure;
    public static gii__UnitofMeasure__c objUnitofMeasure1;
    public static gii__UnitofMeasure__c objUnitofMeasure2;
    public static gii__UnitofMeasure__c objUnitofMeasure3;
    public static List<gii__Carrier__c> lstCarrier;
    public static List<gii__ServiceTicket__c> lstservTicket;
    public static List<gii__ServiceTicketLine__c> lstservTicketLine;
    public static List<gii__AssetReference__c> lstAssetReference;
    public static List<gii__Site__c>  lstSite;
    public static List<gii__ServiceType__c>  lstServiceType;
    public static List<gii__PurchaseRequisition__c>  lstPurchaseRequisition;
    public static List<gii__PurchaseRequisitionLine__c>  lstPurchaseRequisitionLine;
    public static List<gii__WorkOrder__c>  lstWorkOrder;
    public static List<gii__Location__c> lstLocations{get;set;}
    public static list<gii__ProductInventory__c> lstPI;
    public static list<gii__ProductInventorybyLocation__c> lstPIL;
    public static list<gii__ProductInventoryQuantityDetail__c> lstPIQD;
    
    public static list<gii__PickList__c> picklist;
    
    public static User getTestClassUser(){ 
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User user = new User(Alias = 'standt', Email='standarduser@gom.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testpermissionsetuser@gom.com');
        insert user;
        return user;
    }
    
    public static void testSystemPolicyCreation(){ 
        if(objSystemPolicy == null) {
            insertWarehouse();
            objSystemPolicy = new gii__SystemPolicy__c(Name='GII',gii__Description__c='Glovia Policies',gii__PriceBookName__c='Standard',
                                                       gii__StockUM__c='Each',
                                                       gii__AutoReleaseOrder__c=true, gii__AllowZeroUnitPrice__c=true, 
                                                       gii__Warehouse__c = lstWarehouse[0].Id,
                                                       gii__AutoApprovePurchaseOrders__c=true);
            insert objSystemPolicy;
            gii__GloviaSystemSetting__c objGCS = new gii__GloviaSystemSetting__c();
            objGCS.gii__DoNotAutoReserveInventory__c = true;
            objGCS.gii__DoNotAutoReserveNonStock__c = true;
            objGCS.gii__DecimalsWhenRoundingQuantities__c=2;
            insert objGCS;
            //  giic_Test_DataCreationUtility.insertDisableTriggersCustomSetting();
        }
    }
    
    public static List<gii__Warehouse__c> insertWarehouse(){
        
        lstWarehouse = new List<gii__Warehouse__c>();
        List<gii__Warehouse__c> dcwarehouse = [SELECT Id,Name FROM gii__Warehouse__c WHERE Name ='E & S - Washington - Wylie' OR Name='E & S - JMS WESTMINSTER CO' limit 2];
        if(dcwarehouse.size() > 0){
            lstWarehouse = dcwarehouse;
        }else{
            gii__Warehouse__c objWarehouse = new gii__Warehouse__c();
            objWarehouse.Name='E & S - Washington - Wylie';  
          // objWarehouse.gii__WareHouseCountry__c ='USA';
            lstWarehouse.add(objWarehouse);
            
            gii__Warehouse__c objWarehouse2 = new gii__Warehouse__c();
          objWarehouse2.Name='E & S - JMS WESTMINSTER CO';  
            //objWarehouse2.gii__WareHouseCountry__c ='USA';
lstWarehouse.add(objWarehouse2);           
            
            insert lstWarehouse; 
        }
        return lstWarehouse;
    }
    public static List<gii__Warehouse__c> insertWarehouseWly(){
        string str =Label.giic_DCWarehouse;
        lstWarehouse = new List<gii__Warehouse__c>();
        List<gii__Warehouse__c> dcwarehouse = [SELECT Id,Name FROM gii__Warehouse__c WHERE Name =: str limit 1];
        if(dcwarehouse.size() > 0){
            lstWarehouse = dcwarehouse;
        }else{
            gii__Warehouse__c objWarehouse = new gii__Warehouse__c();
            objWarehouse.Name=Label.giic_DCWarehouse;  
            lstWarehouse.add(objWarehouse);
            
            /*gii__Warehouse__c objWarehouse2 = new gii__Warehouse__c();
objWarehouse2.Name='E & S - JMS WESTMINSTER CO';  
lstWarehouse.add(objWarehouse2); */           
            
            insert lstWarehouse; 
        }
        return lstWarehouse;
    }
    
    
    
    
    // added by Himanshu,kumar@fujitsu.com
    public static List<gii__WarehouseGroup__c> getWareHouseGroup(){
        List<gii__WarehouseGroup__c> warehouseGrpList = new List<gii__WarehouseGroup__c>();
        warehouseGrpList.add(new gii__WarehouseGroup__c(Name = 'Test Warehouse Group'));
        return warehouseGrpList;
    }
    
    // added by Himanshu,kumar@fujitsu.com
    public static List<gii__Warehouse__c> insertWarehouse_N(Integer WNumber){
        lstWarehouse_N = new List<gii__Warehouse__c>();
        List<gii__Warehouse__c> lstWarehouseTemp = insertWarehouse();
        Map<String, gii__Warehouse__c> mapWarehouseTemp = new Map<String,gii__Warehouse__c>();
        for(gii__Warehouse__c wh : lstWarehouseTemp){
            mapWarehouseTemp.put(wh.Name, wh);
        }
        gii__Warehouse__c objWarehouse;
        gii__Warehouse__c objWarehouseTemp;
        if(WNumber != null && WNumber > 0){
            for( integer intW =0; intW < WNumber; intW ++ ){
                objWarehouse = new gii__Warehouse__c();
                objWarehouseTemp = new gii__Warehouse__c();
                if(mapWarehouseTemp != null && mapWarehouseTemp.size() > 0){
                    objWarehouseTemp = mapWarehouseTemp.get('TestWarehouse' + string.valueOf(intW));
                }
                if(objWarehouseTemp == null){
                    objWarehouse.Name='TestWarehouse' + string.valueOf(intW);  
                    //  objWarehouse.giic_WarehouseCode__c = string.valueOf(6601 + intW);
                    lstWarehouse_N.add(objWarehouse);
                    
                }
                else{
                    lstWarehouse_N.add(objWarehouseTemp);
                }
            }
        }
        objWarehouse = new gii__Warehouse__c();
        objWarehouseTemp = new gii__Warehouse__c();
        if(mapWarehouseTemp != null && mapWarehouseTemp.size() > 0)
            objWarehouseTemp = mapWarehouseTemp.get('gii__Wh');
        if(objWarehouseTemp == null){             
            objWarehouse.Name='gii__Wh';  
            // objWarehouse.giic_WarehouseCode__c = 'GII';
            lstWarehouse_N.add(objWarehouse);
        }
        else{
            lstWarehouse_N.add(objWarehouseTemp);
        }
        system.debug('lstWarehouse_N--->>> ' + lstWarehouse_N );
        upsert lstWarehouse_N; 
        return lstWarehouse_N;
    }
    
    // added by Himanshu,kumar@fujitsu.com
    public static List<gii__Warehouse__c> getWarehouseForGroup(Id accountId, Id warehouseGrpId){
        List<gii__Warehouse__c> warehouses = new List<gii__Warehouse__c>();
        for(Integer i= 0; i< 5; i++){
            warehouses.add(new gii__Warehouse__c(Name = 'Test Warehouse' + String.valueOf(i), 
                                                 gii__WarehouseGroup__c = warehouseGrpId, 
                                                 gii__Account__c = accountId, 
                                                 gii__Geolocation__Latitude__s  = 10.00 * i, 
                                                 gii__Geolocation__Longitude__s = 15.00 * i));
        }
        return warehouses;
    }
    
    // added by Himanshu,kumar@fujitsu.com
    public static List<Account> insertConsumerAccount(){
        lstwhg =  getWareHouseGroup();
        insert lstwhg;
        /* if(lstWarehouse_N == null || lstWarehouse_N.size() == 0){
insertWarehouse_N(5);
}*/
        // id recortTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('JMS_Operator').getRecordTypeId();
        if(lstAccount == null || lstAccount.size() == 0){
            lstAccount = new List<Account>();
            // RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'JMS_Operator'];
            Account objAccount = new Account();
            //objAccount.RecordTypeId = recortTypeId;
            //objAccount.OwnerId = UserInfo.getUserId();
            objAccount.Name = 'Test Account';
             objAccount.JMS_Skip_Standard_Account_Duplicate_Rule__c=false;
            objAccount.BillingStreet = '8 Clement Drive';
            objAccount.BillingCountry = 'United States';
            objAccount.BillingState = 'Ohio';
            objAccount.BillingPostalCode = '08083';
            //objAccount.BillingState = 'New Jersey';
            objAccount.BillingCity = 'Somerdale'; 
            // objAccount.BillingStreet = '8 Clement Drive';  
            objAccount.ShippingStreet = '8 Clement Drive';
            objAccount.ShippingCountry = 'United States';
            objAccount.ShippingPostalCode = '08083';
            //objAccount.ShippingState = 'New Jersey';
            objAccount.ShippingCity = 'Somerdale'; 
            objAccount.ShippingState = 'Ohio';
            objAccount.ShippingStreet = '8 Clement Drive';
            /*  objAccount.giic_WarehouseGroup__c = lstwhg[0].id;
objAccount.Location_Code__c = lstWarehouse_N[0].giic_WarehouseCode__c;
objAccount.ClinicCustomerNo__c = '123456';
objAccount.ShipToCustomerNo__c = '12345678';
objAccount.Business_Email__c = 'test@example.com';
objAccount.ShipToCustomerNo__c = '12345678';
objAccount.Insite_Customer_Type__c = 'VET';
objAccount.Bill_To_Customer_ID__c = 'Test-12345678';
*/
            lstAccount.add(objAccount);
            
            Database.insert(lstAccount);
            getWarehouseForGroup(lstwhg[0].id,lstAccount[0].id);
        }
        return lstAccount;
    }
    
    // added by Himanshu,kumar@fujitsu.com
    public static List<gii__AccountAdd__c> getAccountReference(List<Account> accList){
        List<gii__AccountAdd__c> accRefList = new List<gii__AccountAdd__c>();
        Integer i = 0;
        for(Account acc : accList){
            accRefList.add(new gii__AccountAdd__c(Name = 'Test Account'+String.valueOf(i), gii__Account__c = acc.Id ));
            i++;
        }
        insert accRefList;
        return accRefList;
    }
    
    // added by Himanshu,kumar@fujitsu.com
    public static List<gii__UnitofMeasure__c> insertUnitofMeasure(){
        lstUnitofMeasure = new List<gii__UnitofMeasure__c>();
        if(lstUnitofMeasure == null || lstUnitofMeasure.size() == 0){
            objUnitofMeasure1 = new gii__UnitofMeasure__c();
            objUnitofMeasure1.Name = 'Box';
            objUnitofMeasure1.gii__Description__c = 'Box';
            objUnitofMeasure1.gii__DisplayName__c   = 'Box';
            objUnitofMeasure1.gii__UniqueId__c = 'Box';
            lstUnitofMeasure.add(objUnitofMeasure1);
            objUnitofMeasure2 = new gii__UnitofMeasure__c();
            objUnitofMeasure2.Name = 'Each';
            objUnitofMeasure2.gii__UniqueId__c = 'Each';
            objUnitofMeasure2.gii__Description__c = 'Each unit of measure descpotion';
            objUnitofMeasure2.gii__DisplayName__c   = 'Each';
            lstUnitofMeasure.add(objUnitofMeasure2);
            objUnitofMeasure3 = new gii__UnitofMeasure__c(Name = 'Bag', gii__UniqueId__c = 'Bag', gii__Description__c = 'Bag', gii__DisplayName__c = 'Bag');
            lstUnitofMeasure.add(objUnitofMeasure3);
            gii__UnitofMeasure__c objUnitofMeasure4 = new gii__UnitofMeasure__c(Name = 'CASE', gii__UniqueId__c = 'CASE', gii__Description__c = 'Case', gii__DisplayName__c = 'CASE');
            lstUnitofMeasure.add(objUnitofMeasure4);
            gii__UnitofMeasure__c objUnitofMeasure5 = new gii__UnitofMeasure__c(Name = 'EA', gii__UniqueId__c = 'EA', gii__Description__c = 'EA', gii__DisplayName__c = 'EA');
            lstUnitofMeasure.add(objUnitofMeasure5);
            insert lstUnitofMeasure;
        }
        
        return lstUnitofMeasure;
    }
    
    // added by Himanshu,kumar@fujitsu.com
    public static List<gii__Product2Add__c> insertProduct(){
        List<Product2> lstProducts = new List<Product2>(); 
        system.debug('lstUnitofMeasure.comdd>>>'+ lstUnitofMeasure);
        if(lstUnitofMeasure == null || lstUnitofMeasure.size() == 0  ){
            // system.debug('lstUnitofMeasure.size()>>>In side>>'+ lstUnitofMeasure.size());
            insertUnitofMeasure();
        } 
       // RecordType prodrecordType = [Select id,name,DeveloperName, SobjectType from RecordType where DeveloperName ='Product' and SobjectType ='Product2' limit 1];
        system.debug('lstUnitofMeasure.size()>>>Out side>>'+ lstUnitofMeasure.size());
         RecordType prodrecordType = [Select id,name,DeveloperName, SobjectType from RecordType where DeveloperName ='Equipment' and SobjectType ='Product2' limit 1];
        system.debug('prodrecordType.prodrecordType>>'+ prodrecordType);
        system.debug('----->'+lstProd);
         if(lstProd == null || lstProd.size() == 0 ){
        Product2 objpro = new Product2(Name = 'Third Party Service',
                                       IsActive = true,
                                       ProductCode = '1234567 ',
                                       Family = 'Beverage',
                                       RecordTypeId = prodrecordType.id
                                      );
        
        Product2 objpro1 = new Product2(Name = 'Sel Pro PD Dry 50#-Dog Test',
                                        IsActive = true,
                                        ProductCode = 'DO121',
                                        Family = 'Vet',
                                        RecordTypeId = prodrecordType.id
                                       );
        
        /* Product2 objpro2 = new Product2(Name = 'Sel Pro PD Dry 100#-Dog',
IsActive = true,
ProductCode = '18325',
Family = 'Vet
);

Product2 objpro3 = new Product2(Name = 'Sel Pro PD Dry 200#-Dog',
IsActive = true,
ProductCode = '18325',
Family = 'Vet'
);
*/                         
        lstProducts.add(objpro);
        lstProducts.add(objpro1);
        //  lstProducts.add(objpro2);
        // lstProducts.add(objpro3);
       
            insert lstProducts;
             system.debug('---->'+lstProducts);
            List<gii__Product2Add__c> lstPrds =  [select id  , gii__ProductReference__c 
                                                  from gii__Product2Add__c where gii__ProductReference__c = null ];
            List<gii__Product2Add__c> lstPrds1  =new List<gii__Product2Add__c>(); 
             if(lstPrds.size() > 0) {           
                 for(gii__Product2Add__c prds : lstPrds){
                     prds.gii__ProductReference__c = lstProducts[0].Id;
                     lstPrds1.add(prds);
                 }
                 update lstPrds1;
             }
             lstPrds =lstPrds1;
            system.debug('lstProducts>>>'+ lstProducts);
            lstProd = new List<gii__Product2Add__c>();
            lstProd = [SELECT Id, gii__LotControlled__c, gii__SellingUnitofMeasure__c, 
                       gii__SellingUnitofMeasure__r.Name,gii__StockingUnitofMeasure__c, 
                       gii__StockingUnitofMeasure__r.name, gii__ProductReference__c, 
                       gii__ProductReference__r.Name, gii__NonStock__c, gii__ProductReference__r.ProductCode, 
                       gii__ProductReference__r.Family, gii__Style__c,
                       gii__ProductReference__r.RecordType.Name ,
                       gii__ProductReference__r.RecordTypeId ,gii__SerialControlled__c 
                       from gii__Product2Add__c 
                       WHERE gii__ProductReference__c IN :lstProducts];
            
            //lstProd[0].gii__NonStock__c = false;
            //lstProd[0].gii__SerialControlled__c = true;
            //lstProd[1].gii__NonStock__c = true;
            Integer counter = 1;
            Integer len = 6;
            String str = string.valueof(Math.abs(Crypto.getRandomLong()));
            String randomNumber = str.substring(0, len);
            //system.debug('Random Number-' + randomNumber);
            
            for(gii__Product2Add__c pref : lstProd)
            {
                pref.gii__StockingUnitofMeasure__c = lstUnitofMeasure[0].id;
                //pref.gii__ProductReference__r.RecordType.Name ='Equipment';
            }
            update lstProd;
            
            
            gii__PriceBook__c objPB = new gii__PriceBook__c();
            objPB.Name = 'Standard';
           // insert objPB;
        }
        /*gii__PriceBookEntry__c ObjPriceBookEntry = new gii__PriceBookEntry__c();
ObjPriceBookEntry.gii__Product__c= lstProd[0].id;
ObjPriceBookEntry.gii__PriceBook__c = objPB.id;
ObjPriceBookEntry.gii__UnitPrice__c = 1;
insert ObjPriceBookEntry; */
        
        return lstProd;
    }
    
    // added by Himanshu,kumar@fujitsu.com
    public static List<gii__Carrier__c> createCarrier(){
        
        if(lstCarrier == null || lstCarrier.size() == 0 ){
            lstCarrier = new List<gii__Carrier__c>();
            gii__Carrier__c oCarr1 = new gii__Carrier__c();
            oCarr1.Name = 'Route';
            oCarr1.gii__NoChargeReason__c = 'Promotion';
            lstCarrier.add(oCarr1);
            
            gii__Carrier__c oCarr2 = new gii__Carrier__c();
            oCarr2.Name = 'Parcel';
            oCarr2.gii__NoChargeReason__c = 'Promotion';
            lstCarrier.add(oCarr2);
            insert lstCarrier;
        }
        return lstCarrier;
    }
    
    // added by Himanshu,kumar@fujitsu.com
    public static list<gii__SalesOrder__c> insertSalesOrder(){
        List<gii__Warehouse__c> dcwarehouse = insertWarehouse();
        System.debug('dcwarehouse---'+dcwarehouse);
         System.debug('lstAccount---'+lstAccount);
        if(lstAccount == null || lstAccount.size() == 0){
            insertConsumerAccount();
        } 
        if(lstCarrier == null || lstCarrier.size() == 0){
            createCarrier();
        } 
        
        /* List<gii__Warehouse__c> dcwarehouse = [SELECT Id,Name FROM gii__Warehouse__c WHERE Name ='E & S - Washington Distribution Center' limit 1 ];
if(dcwarehouse.size() < 0){
insertWarehouse(); 
}*/
        
        
        lstSalesOrder = new List<gii__SalesOrder__c>();
        gii__SalesOrder__c so = new gii__SalesOrder__c();
        //open sales order 
        so =  new gii__SalesOrder__c(
            gii__Account__c = lstAccount[0].id ,
            gii__ScheduledDate__c = SYSTEM.today(),
            gii__OrderDate__c = SYSTEM.today(),
            gii__Warehouse__c = dcwarehouse[0].id,
            gii__TransferToWarehouse__c =dcwarehouse[1].id,
            gii__PaymentMethod__c = 'Credit Card',
            gii__OrderType__c='Transfer',
            gii__Carrier__c = lstCarrier != null && lstCarrier.size() > 0 ? lstCarrier[0].Id : null,
            gii__Released__c = false,
            //To overcome validation rule failure
            gii__ShipToStateProvince__c = 'MO',
            gii__BillingStateProvince__c = 'MO'
        );
        lstSalesOrder.add(so);
        //released sales order          
        so =  new gii__SalesOrder__c(
            gii__Account__c = lstAccount[0].id ,
            gii__ScheduledDate__c = SYSTEM.today(),
            gii__OrderDate__c = SYSTEM.today(),
            gii__Warehouse__c = dcwarehouse[0].id,
            gii__TransferToWarehouse__c =dcwarehouse[1].id,
            gii__OrderType__c='Transfer',
            gii__PaymentMethod__c = 'Credit Card',
            gii__Carrier__c = lstCarrier != null && lstCarrier.size() > 0 ? lstCarrier[0].Id : null,
            gii__Released__c = false,
            //To overcome validation rule failure
            gii__ShipToStateProvince__c = 'MO',
            gii__BillingStateProvince__c = 'MO'
        );
        
        //released sales order          
        gii__SalesOrder__c so1 =  new gii__SalesOrder__c(
            gii__Account__c = lstAccount[0].id ,
            gii__ScheduledDate__c = SYSTEM.today(),
            gii__OrderDate__c = SYSTEM.today(),
            gii__OrderType__c='Transfer',
            gii__Warehouse__c = dcwarehouse[0].id,
            gii__TransferToWarehouse__c =dcwarehouse[1].id,
            gii__PaymentMethod__c = 'Invoice',
            gii__Carrier__c = lstCarrier != null && lstCarrier.size() > 0 ? lstCarrier[0].Id : null,
            gii__Released__c = false,
            //To overcome validation rule failure
            gii__ShipToStateProvince__c = 'MO',
            gii__BillingStateProvince__c = 'MO'
        );
        //FTL Sales order
        gii__SalesOrder__c so2 =  new gii__SalesOrder__c(
            gii__Account__c = lstAccount[0].id ,
            gii__ScheduledDate__c = SYSTEM.today(),
            gii__OrderDate__c = SYSTEM.today(),
            gii__Status__c = 'Open', 
            gii__OrderType__c='Transfer',
            gii__Warehouse__c = lstWarehouse[0].id,
            gii__TransferToWarehouse__c =dcwarehouse[1].id,
            gii__PaymentMethod__c = 'Terms',
            gii__Carrier__c = lstCarrier != null && lstCarrier.size() > 0 ? lstCarrier[0].Id : null,
            gii__Released__c = true,
            //To overcome validation rule failure
            gii__ShipToStateProvince__c = 'MO',
            gii__BillingStateProvince__c = 'MO'
        );
        System.debug(so);
        System.debug(so1);
        System.debug(so2);
        lstSalesOrder.add(so);
        lstSalesOrder.add(so1);
        lstSalesOrder.add(so2);
        insert lstSalesOrder;
        
        return lstSalesOrder;
    }
    
    //// added by Himanshu,kumar@fujitsu.com
    public static List<gii__SalesOrderLine__c> insertSOLine(List<gii__SalesOrder__c> sos){
        // gii__ProductInventorySequence__c prodInvSeq = new gii__ProductInventorySequence__c();
        //prodInvSeq.name='Test';
        // insert prodInvSeq;
        List<gii__Product2Add__c> lstProd12 = new List<gii__Product2Add__c>();
        if(lstProd == null || lstProd.size() == 0){
            insertProduct();
             System.debug('lstProd::::'+lstProd);
            
        }
        System.debug('lstProd::::'+lstProd);
        
      
        if(lstPI == null || lstPI.size() == 0){
            lstPI  = insertProductInventory();
             System.debug('lstProd::::'+lstProd);
         
        }
        
        
        gii__SalesOrderLine__c soline;
        List<gii__SalesOrderLine__c> soLineToInsert = new List<gii__SalesOrderLine__c>();
        
        for(gii__SalesOrder__c so : sos)
        {
            for(Integer i = 0 ; i< lstProd.size() ; i++)
            {//gii__ServiceTicket__c= lstservTicket[0].id,
                soline = new gii__SalesOrderLine__c(gii__SalesOrder__c = so.id, giic_TransferOrderQty__c=1 ,
                                                    gii__ReservedQuantity__c=1 ,
                                                    gii__OrderQuantity__c = 2.0, gii__Product__c = lstProd[i].id , 
                                                    gii__UnitPrice__c = 2);
                soLineToInsert.add(soline);
            }
            System.debug('soLineToInsert'+soLineToInsert);
        }
        
        insert soLineToInsert;
        list<gii__SalesOrderLine__c>  test =[SELECT Id ,gii__Product__c,gii__Product__r.gii__ProductReference__r.RecordType.Name
                                             FROM gii__SalesOrderLine__c where id =: soLineToInsert ];
        
        gii__InventoryReserve__c inv = new gii__InventoryReserve__c();
        inv.gii__SalesOrderLine__c=soLineToInsert[0].id;
        inv.gii__ProductInventorySequence__c =lstPI[0].id;
        inv.gii__Product__c =test[0].gii__Product__c;
        insert inv;
        return soLineToInsert;
    }
    // added by Himanshu,kumar@fujitsu.com
    public static List<gii__SalesOrderLine__c> insertSOLine(Id soReference, Id productRef){
        List<gii__SalesOrderLine__c> soLineToInsert = new List<gii__SalesOrderLine__c>();
        for(Integer  i = 0; i< 5 ; i++){
            soLineToInsert.add(new gii__SalesOrderLine__c(gii__SalesOrder__c = soReference, 
                                                          gii__OrderQuantity__c = 2.0, gii__Product__c = productRef));
        }
        if(soLineToInsert.size()>0)
            Database.insert(soLineToInsert);
        return soLineToInsert;
    }
    
    
    public static List<gii__ServiceTicket__c> insertServTicket(){
        //public static List<gii__ServiceTicket__c > lstservTicket;
        lstservTicket = new List<gii__ServiceTicket__c>();
        
        if(lstAccount == null || lstAccount.size() == 0){
            insertConsumerAccount();
        }
        gii__ServiceTicket__c  servTicket = new gii__ServiceTicket__c();
        servTicket.gii__Country__c='United States';
        servTicket.gii__Account__c=lstAccount[0].id;
        servTicket.gii__ServiceDueDate__c = system.today().addDays(3);
        lstservTicket.add(servTicket);
        insert lstservTicket ;
        
        return lstservTicket;
    }
    
    public static List<gii__ServiceTicketLine__c> insertServTicketLine(List<gii__ServiceTicket__c> lstservTicket){
        //public static List<gii__ServiceTicket__c > lstservTicket;
        lstservTicketLine = new List<gii__ServiceTicketLine__c>();
        
        if(lstProd == null || lstProd.size() == 0){
            insertProduct();
        }
        
        if(lstAccount == null || lstAccount.size() == 0){
            insertConsumerAccount();
        }
        
              List<gii__Warehouse__c> dcwarehouse = insertWarehouse();

        
        gii__FieldServiceEngineer__c  fse = new gii__FieldServiceEngineer__c();
        fse.gii__Warehouse__c   =dcwarehouse[0].id;
        fse.gii__Supplier__c =lstAccount[0].id ;
        
        insert fse;
        
        for(Integer i = 0 ; i< lstservTicket.size() ; i++){
            gii__ServiceTicketLine__c servTicketLine = new gii__ServiceTicketLine__c();
            servTicketLine.gii__Quantity__c = 1;
            servTicketLine.gii__ServiceTicket__c = lstservTicket[0].Id;
            servTicketLine.gii__Product__c = lstProd[0].id;
            servTicketLine.gii__FieldServiceEngineer__c =fse.id;
            lstservTicketLine.add(servTicketLine);
        }
        insert lstservTicketLine ;
        
        return lstservTicketLine;
    }
    
    public static List<gii__Site__c > insertSite(){
        
        if(lstAccount == null || lstAccount.size() == 0){
            insertConsumerAccount();
        }
        
        lstSite  = new List<gii__Site__c >();
        gii__Site__c siteD = new 	gii__Site__c();
        siteD.name='test';
        siteD.gii__Account__c = lstAccount[0].Id;
        lstSite.add(siteD);
        
        insert lstSite ;
        
        return lstSite;
    }
    
    public static List<gii__AssetReference__c> insertAssetReference(){
        //public static List<gii__ServiceTicket__c > lstservTicket;
        lstAssetReference = new List<gii__AssetReference__c>();
        
        if(lstProd == null || lstProd.size() == 0){
            insertProduct();
        }
        
        if(lstSite == null || lstSite.size() == 0){
            insertSite();
        }
        
        if(lstAccount == null || lstAccount.size() == 0){
            insertConsumerAccount();
        }
        
        
        
        
        gii__AssetReference__c assetD = new 	gii__AssetReference__c();
        assetD.name='test';
        assetD.gii__Site__c= lstSite[0].id;
        assetD.gii__ProductReference__c= lstProd[0].id;
        assetD.gii__Account__c= lstAccount[0].id ;
        
        lstAssetReference.add(assetD);
        insert lstAssetReference;
        return lstAssetReference;
    }
    
    public static List<gii__ServiceType__c > InsertServiceType(){
        
        lstServiceType  = new List<gii__ServiceType__c >();
        gii__ServiceType__c  insertServiceType = new gii__ServiceType__c();
        insertServiceType.name ='testt';
        
        lstServiceType.add(insertServiceType);
        insert lstServiceType ;
        
        return lstServiceType;
    }
    
    public static List<gii__PurchaseRequisition__c > InsertPurchaseRequisition(){
        
        // public static List<>  ;
        insertWarehouse();
        lstPurchaseRequisition  = new List<gii__PurchaseRequisition__c >();
        gii__PurchaseRequisition__c  insertPurchaseRequisition = new gii__PurchaseRequisition__c();
        insertPurchaseRequisition.gii__Description__c = 'testt ';
        insertPurchaseRequisition.CurrencyIsoCode ='USD';
        insertPurchaseRequisition.gii__ShipTo__c = lstWarehouse[0].id;
        
        lstPurchaseRequisition.add(insertPurchaseRequisition);
        insert lstPurchaseRequisition ;
        
        return lstPurchaseRequisition;
    }
    
    public static List<gii__PurchaseRequisitionLine__c> InsertPurchaseRequisitionLine(){
        
        insertWarehouse();
        
        if(lstProd == null || lstProd.size() == 0){
            insertProduct();
        }
        if(lstPurchaseRequisition == null || lstPurchaseRequisition.size() == 0){
            InsertPurchaseRequisition();
        }
        
        lstPurchaseRequisitionLine  = new List<gii__PurchaseRequisitionLine__c >();
        
        gii__PurchaseRequisitionLine__c insertPurchaseRequisitionLine = new gii__PurchaseRequisitionLine__c();
        insertPurchaseRequisitionLine.gii__Product__c = lstProd[0].id;
        insertPurchaseRequisitionLine.gii__ShipTo__c = lstWarehouse[0].id;
        insertPurchaseRequisitionLine.gii__PurchaseRequisition__c  =lstPurchaseRequisition[0].id;
        insertPurchaseRequisitionLine.gii__OrderQuantity__c=1;
        
        lstPurchaseRequisitionLine.add(insertPurchaseRequisitionLine);
        insert lstPurchaseRequisitionLine ;
        
        return lstPurchaseRequisitionLine;
    }
    
    //
    public static List<gii__WorkOrder__c> InsertWorkOrder(){
        
        insertWarehouse();
        // InsertPurchaseRequisition();
        if(lstProd == null || lstProd.size() == 0){
            insertProduct();
        }
        
        lstWorkOrder  = new List<gii__WorkOrder__c >();
        
        gii__WorkOrder__c insertWorkOrder = new gii__WorkOrder__c();
        insertWorkOrder.gii__Warehouse__c=lstWarehouse[0].id;
        insertWorkOrder.gii__Product__c =lstProd[0].id;
        insertWorkOrder.gii__OrderQuantity__c=1;
        lstWorkOrder.add(insertWorkOrder);
        insert lstWorkOrder ;
        
        return lstWorkOrder;
    }
    
    public static List<gii__Location__c> insertLocations()
    {
        insertWarehouse();
        if(lstProd == null || lstProd.size() == 0){
            insertProduct();
        }
        gii__Location__c loc = new gii__Location__c();
        lstLocations = new list<gii__Location__c>();
        for(integer i = 0; i < lstWarehouse.size(); i++) //insert 
        {
            loc  = new gii__Location__c( gii__Warehouse__c = lstWarehouse[i].id ,gii__Sequence__c = 1);
            lstLocations.add(loc);
        }
        insert lstLocations;
        return lstLocations;
    }
    
    
    // public static list<gii__ProductLocation__c> lstPIL;
    // public static list<gii__ProductInventoryQuantityDetail__c> lstPIQD;
    
    public static list<gii__ProductInventory__c> insertProductInventory(){
        
        List<gii__Warehouse__c> lstWarehouse = insertWarehouse();
        if(lstProd == null || lstProd.size() == 0){
           lstProd = insertProduct();
        }
        if(lstLocations == null || lstLocations.size() == 0){
            insertLocations();
        }
        lstPI=new list<gii__ProductInventory__c>();
        
        list<gii__ProductInventory__c> lstPIResult=[select id ,gii__Warehouse__c ,
                                                    gii__Product__c,gii__PrimaryLocation__c
                                                    from gii__ProductInventory__c 
                                                    where gii__Warehouse__c =: lstWarehouse[0].id];
        system.debug('lstPIResult>>>'+ lstProd);
        if(lstPIResult == null || lstPIResult.size() <= 0){
            system.debug(lstProd[0].id);
            lstPI.add(new gii__ProductInventory__c(gii__Warehouse__c=lstWarehouse[0].id,gii__Product__c=lstProd[0].id
                                                   , gii__PrimaryLocation__c =lstLocations[0].id
                                                  ));
            insert lstPI;
        }else{
            lstPI=lstPIResult;
        }
        
        system.debug('lstPI:' + lstPI);
        
        return lstPI;
    }
    
    public static list<gii__ProductInventorybyLocation__c> insertProductInventoryByLoc(){
        insertWarehouse();
        if(lstPI == null || lstPI.size() == 0){
            insertProductInventory();
        }
        if(lstLocations == null || lstLocations.size() == 0){
            insertLocations();
        } 
        
        if(lstProd == null || lstProd.size() == 0){
            insertProduct();
        }
        
        if(lstPIL == null || lstPIL.size() == 0){
            // system.debug('lstLocations:' + lstLocations);   
            lstPIL=new list<gii__ProductInventorybyLocation__c>();
            map<id,id> mapWHWithLoc=new map<id,id>();
            // for(gii__Location__c objLOc : lstLocations){
            mapWHWithLoc.put(lstLocations[0].gii__Warehouse__c,lstLocations[0].id);
            // }
            for(integer i=0; i< lstPI.size(); i++ ){
                lstPIL.add(new gii__ProductInventorybyLocation__c(gii__Location__c = mapWHWithLoc.get(lstPI[i].gii__Warehouse__c) , gii__ProductInventory__c=lstPI[i].id,gii__Product__c=lstPI[i].gii__Product__c,gii__Warehouse__c=lstPI[i].gii__Warehouse__c));
            }  
            insert lstPIL;
        }
        return lstPIL;
    }
    
    public static list<gii__ProductInventoryQuantityDetail__c> insertProductInventoryQTYDetails(){
        
        if(lstPIL == null || lstPIL.size() == 0){
            insertProductInventoryByLoc();
        }
        if(lstPIQD == null || lstPIQD.size() == 0){
            lstPIQD=new list<gii__ProductInventoryQuantityDetail__c>();
            map<id,id> mapWHWithLoc=new map<id,id>();
            
            // for(gii__Location__c objLOc : lstLocations){
            mapWHWithLoc.put(lstLocations[0].gii__Warehouse__c,lstLocations[0].id);
            // }
            for(gii__ProductInventorybyLocation__c objPIl : lstPIL){
                lstPIQD.add(new  gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=objPIl.gii__ProductInventory__c,gii__ProductInventorybyLocation__c=objPIl.id,
                                                                        gii__Product__c=objPIl.gii__Product__c,gii__Warehouse__c=objPIl.gii__Warehouse__c,gii__Location__c=mapWHWithLoc.get(objPIl.gii__Warehouse__c), gii__OnHandQuantity__c =10000));    
            }
            
            
            insert lstPIQD;
        }
        return lstPIQD;
    }
    
    public static List<gii__APInvoice__c> createAPInvoice(){
        List<gii__APInvoice__c> lstApinv = new List<gii__APInvoice__c>();
       
        
         if(lstAccount == null || lstAccount.size() == 0){
             insertConsumerAccount();
        }
        List<gii__AccountAdd__c>  accntref=  new  List<gii__AccountAdd__c>();
          if(lstAccount.size() > 0){
             accntref =[select id , name ,gii__Account__c from gii__AccountAdd__c
                                       where gii__Account__c != null];
        }
        
        List<gii__ServiceTicket__c> lstSert = insertServTicket();
        gii__APInvoice__c apinv = new gii__APInvoice__c();
        apinv.gii__SupplierDocument__c = 'Test';
        apinv.gii__DocumentDate__c = system.today();
        apinv.gii__DocumentAmount__c = 10;
        system.debug('Acc id::'+lstAccount[0].Id);
        apinv.gii__Supplier__c = lstAccount[0].Id;
        apinv.giic_Service_Ticket__c = lstSert[0].Id;
        apinv.gii__AccountReference__c =accntref[0].Id;
        apinv.giic_AP_Invoice_Status__c	= 'Rejected';
        apinv.giic_Integration_Status__c ='Submitted';
        lstApinv.add(apinv);
        insert lstApinv;
        return lstApinv;
    }
    
     public static list<gii__PickList__c> getPickList(){ 
         
       
          system.debug('lstSalesOrder>>'+lstSalesOrder);
             system.debug('lstAccount>>'+lstAccount);
         if(lstSalesOrder == null || lstSalesOrder.size() == 0){
             insertSalesOrder();
         }
          system.debug('lstSalesOrder11>>'+lstSalesOrder);
           system.debug('lstAccount11>>'+lstAccount);

          system.debug('lstProd>>'+lstProd);
         
         if(lstProd == null || lstProd.size() == 0){
            insertProduct();
        }
          system.debug('lstProd11>>'+lstProd);
        /*   gii__PickList__c pkInstance = new gii__PickList__c();
         pkInstance.gii__OrderType__c='Standard' ;
         pkInstance.gii__SalesOrder__c=lstSalesOrder[0].id  ;
         pkInstance.gii__Product__c=lstProd[0].id ;
       // pkInstance.gii__PicklistStatus__c='Created' ;
         pkInstance.gii__PicklistSequence__c=1 ;
         pkInstance.gii__CreditStatus__c='ok' ;
         system.debug('pkInstance>>'+pkInstance);
          picklist.add(pkInstance);
         insert picklist;*/
         return picklist;
     }
    
}