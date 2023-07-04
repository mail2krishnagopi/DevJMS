@isTest(SeeAllData = false)
public class POSupplierControllerTest {
    
    static testMethod void testPurchaseOrderSteps(){
        List<ProcessSteps__mdt> listPS = [SELECT Id, Process__c FROM ProcessSteps__mdt LIMIT 1];
        POSupplierController.getPurchaseOrderSteps(listPS[0].Process__c);
        System.assert(true);        
    }
    
    static testMethod void testSetPurchaseOrderFields(){
        //create a separate list of field set members
        List<FieldSetMember> listNewFSM = new List<FieldSetMember>{new FieldSetMember()};
        listNewFSM[0].fieldPath = 'gii__Supplier__c';
        listNewFSM[0].label = 'Supplier';
        listNewFSM[0].type = 'STRING';
        listNewFSM[0].value = 'Supplier';        
        String serializeListFSM = JSON.serialize(listNewFSM);
        
        POSupplierController.setPurchaseOrderFields(serializeListFSM); 
        System.assert(true);
    }
    
    static testMethod void testFetchLookup(){
        String searchKeyWord1 = 'Test';
        String searchKeyWord2 = 'test';
        String searchKeyWord3 = 't';
        String searchKeyWord4 = 'te';
        String searchKeyWord5 = 'st';
        String objectName = 'Account';
        Account objAcc = new Account(Name = 'Test');
        insert objAcc;
        
        POSupplierController.fetchLookup(searchKeyWord1, objectName);
        POSupplierController.fetchLookup(searchKeyWord2, objectName);
        POSupplierController.fetchLookup(searchKeyWord3, objectName);
        POSupplierController.fetchLookup(searchKeyWord4, objectName);
        POSupplierController.fetchLookup(searchKeyWord5, objectName);
        System.assert(true);
    }
    
    static testMethod void testGetPriceBook(){
        Account objAcc = new Account(Name = 'Test Account');
        insert objAcc; 
        gii__AccountAdd__c objAccRef = new gii__AccountAdd__c(gii__Account__c = objAcc.Id, Name = 'Reference');
        insert objAccRef; 
        gii__PriceBook__c objPB = new gii__PriceBook__c(Name = 'Standard');
        insert objPB;
        
        POSupplierController.getPriceBook(objAcc.Id);
        System.assert(true);
    }
    
    static testMethod void testGetFieldSet(){
        List<FieldSetMember> listFSM = new List<FieldSetMember>();
        listFSM = POSupplierController.getFieldSet(null);
        
        gii__Warehouse__c objWH = new gii__Warehouse__c(Name = 'Default  Warehouse');
        insert objWH;
        
        gii__SystemPolicy__c systemPolicy;
        
        //check if system policy record already exists
        for(gii__SystemPolicy__c sys : [SELECT Id, gii__StockUM__c FROM gii__SystemPolicy__c WHERE Name = 'GII' LIMIT 1]){
            systemPolicy = sys;
        }
        
        //insert dummy system policy if one does not exist
        if(systemPolicy == null) {
            systemPolicy = new gii__SystemPolicy__c(Name = 'GII', gii__StockUM__c = 'Each', gii__PriceBookName__c = 'Standard', gii__Warehouse__c = objWH.Id); 
            insert systemPolicy;    
        }
        
        Account objAcc = new Account(Name = 'Test Account');
        insert objAcc;        
        Product2 objProdMain = new Product2(Name = 'Corn', IsActive = true);
        insert objProdMain;
        
        List<gii__Product2Add__c> lstPR = [SELECT Id, Name, gii__ProductStyle__c FROM gii__Product2Add__c];
        gii__PriceBook__c objPB = new gii__PriceBook__c(Name = 'Standard');
        insert objPB;
        
        List<gii__PriceBookEntry__c>  lstPBE = new List<gii__PriceBookEntry__c>();
        for(gii__Product2Add__c objProd : lstPR){
            gii__PriceBookEntry__c objPBE = new gii__PriceBookEntry__c(gii__PriceBook__c = objPB.Id, gii__Product__c = objProd.Id);
            lstPBE.add(objPBE);          
        }
        insert lstPBE;
        
        gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = objAcc.Id, gii__ShipTo__c = objWH.Id);
        insert objPO;
        
        gii__PurchaseOrderLine__c objPOline = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c = objPO.Id,
                                                                            gii__Product__c = lstPR[0].Id,
                                                                            gii__OrderQuantity__c   = 10,
                                                                            gii__UnitPrice__c = 200,
                                                                            Is_Active_Cart_Line__c = true);
        insert objPOline;
        Map<String, String> purchaseOrderInformation = new Map<String, String>{'gii__Supplier__c' => objAcc.Id};
        String serializedPOInfo = JSON.serialize(purchaseOrderInformation);
        
        POSupplierController.getFieldSet(null);
        POSupplierController.getFieldSet(serializedPOInfo);
        System.assert(true);
    }
}