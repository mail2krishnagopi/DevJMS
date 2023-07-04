@isTest(SeeAllData = false) 
public class POSummaryControllerTest {
    static testMethod void getInfoTest() {
        gii__Warehouse__c objWH = new gii__Warehouse__c(Name = 'Default  Warehouse');
        insert objWH;
        
        gii__SystemPolicy__c objSysPolicy = null;        
        //check if system policy record already exists
        for(gii__SystemPolicy__c sys : [SELECT Id, gii__StockUM__c FROM gii__SystemPolicy__c WHERE Name = 'GII' LIMIT 1]){
            objSysPolicy = sys;
        }
        
        if(objSysPolicy == null) {
            objSysPolicy = new gii__SystemPolicy__c(Name = 'GII', gii__StockUM__c = 'Each', gii__PriceBookName__c = 'Standard', gii__Warehouse__c = objWH.Id); 
            insert objSysPolicy;    
        }
        
        Account objAcc = new Account(Name = 'Test Account');
        insert objAcc;
        
        gii__AccountAdd__c objAR = [SELECT Id, Name, gii__PriceBookName__c FROM gii__AccountAdd__c LIMIT 1];
        objAR.gii__PriceBookName__c = 'Standard';
        update objAR;
        
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
        
        ProductWrapper prodWrapper = new ProductWrapper();
        prodWrapper.isFavProduct = true;
        prodWrapper.ProductId = lstPR[0].Id;
        prodWrapper.addToCart = true;
        prodWrapper.Id = lstPR[0].Id;
        prodWrapper.UnitPrice = 200;
        prodWrapper.ProductName = 'Corn';
        prodWrapper.OrderQuantity = 10;
        prodWrapper.isSelected = true;
        List<ProductWrapper> lstProdWrap = new List<ProductWrapper>{prodWrapper};
        String strListProdWrapper = JSON.serialize(lstProdWrap);
        String strSingleProdWrapper = JSON.serialize(prodWrapper);
        
        String paymentMethod = 'Cash'; 
        String paymentMethodId = '';
        String accountId = objAcc.Id;
        String warehouseId = objWH.Id;
        
        AccountWrapper objAccWrap = new AccountWrapper();
        objAccWrap.Name = 'ABCFarms';
        objAccWrap.BillingStreet = 'A207';
        objAccWrap.BillingCity='Noida';
        objAccWrap.BillingPostalCode='222231';
        
        String destributor = JSON.serialize(objAccWrap);
        String selectedPayMethod = 'Cash'; 
        Integer discount = 10;        
        Integer totalAmt = 1000; 
        Integer percentAmt = 10; 
        Integer percentPayAmt = 5;
        Integer customPayAmt = 95;
        
        PlaceOrderWrapper placePOWrapper = POSummaryController.getInfo(accountId, warehouseId);
        POSummaryController.getCartProducts(accountId);
        POSummaryController.addProductsToCart(strListProdWrapper, accountId);
        try{
            POSummaryController.addProductsToCart(strSingleProdWrapper, accountId);
        }
        catch(Exception e){
            System.debug('Should throw an exception since a single product is being passed instead of a list : ' + e);
        }
        
        POSummaryController.purchaseOrderWithLines(accountId, destributor, discount, selectedPayMethod, totalAmt, percentAmt, percentPayAmt, customPayAmt);
        try{
            POSummaryController.purchaseOrderWithLines(accountId, '', discount, selectedPayMethod, totalAmt, percentAmt, percentPayAmt, customPayAmt);
        }
        catch(Exception e){
            System.debug('Should throw an exception since the destributor cannot be deserialized : ' + e);
        }
        
        POSummaryController.removeProductFromCart(accountId, strSingleProdWrapper);
        //should give an exception
        //POSummaryController.removeProductFromCart(accountId, strSingleProdWrapper);
        POSummaryController.purchaseOrderLines(objPO.Id, lstProdWrap);
        System.assert(true);
    }
}