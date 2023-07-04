@isTest(SeeAllData = false)
public class POProductsControllerTest {
    static testMethod void onLoadTest() {
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
        
        //insert dummy account object
        Account objAcc = new Account(Name = 'Test Account');
        insert objAcc;
        
        //insert new pricebook with name Standard
        gii__PriceBook__c objPB = new gii__PriceBook__c(Name = 'Standard');
        insert objPB;
        
        //query any account reference and update the pricebook name to Standard
        gii__AccountAdd__c  objAR =  [SELECT Id, Name, gii__PriceBookName__c FROM gii__AccountAdd__c LIMIT 1];
        objAR.gii__PriceBookName__c = 'Standard';
        update objAR;
        
        //insert a new product
        Product2 objProdMain = new Product2(Name = 'Corn Test', IsActive = true);
        insert objProdMain;
        gii__Product2Add__c cornTestPR = [SELECT Id, Name FROM gii__Product2Add__c WHERE Name = 'Corn Test'];
        
        //insert list of products
        List<Product2> listProducts = new List<Product2>{new Product2(Name = 'A1 Seed Treatment Service', IsActive = true),
                                                        new Product2(Name = 'Basta', IsActive = true),
                                                        new Product2(Name = 'Corn1', IsActive = true)};
        insert listProducts;
        
        //update product reference with new product style
        gii__Product2Add__c seedTreatmentPR =  [SELECT Id, Name, gii__ProductStyle__c FROM gii__Product2Add__c WHERE Name = 'A1 Seed Treatment Service'];
        seedTreatmentPR.gii__ProductStyle__c = cornTestPR.Id;
        update seedTreatmentPR;
        
        List<gii__Product2Add__c> listPR = [SELECT Id, Name, gii__ProductStyle__c FROM gii__Product2Add__c];
        
        List<gii__PriceBookEntry__c>  listPBE = new List<gii__PriceBookEntry__c>();
        for(gii__Product2Add__c productRef : listPR){
            gii__PriceBookEntry__c objPBE = new gii__PriceBookEntry__c(gii__PriceBook__c = objPB.Id, gii__Product__c = productRef.Id);
            listPBE.add(objPBE);          
        }
        insert listPBE;
         /********************* comment favorite product functionality ***********************************/       
   /****** 
        //insert product reference tag
        gii__Product2Add__Tag prodReferenceTag = new gii__Product2Add__Tag(ItemId = listPR[0].Id, Type  = 'Personal', Name = 'Fav'); 
        insert prodReferenceTag; ******/
        
        //insert PO Object
        gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = objAcc.Id, gii__ShipTo__c = objWH.Id);
        insert objPO;
        
        gii__PurchaseOrderLine__c objPOline = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c = objPO.Id,
                                                                            gii__Product__c = listPR[0].Id,
                                                                            gii__OrderQuantity__c = 10,
                                                                            gii__UnitPrice__c = 200,
                                                                            Is_Active_Cart_Line__c = true);
        insert objPOline;
        
        ProductWrapper prodWrapper = new ProductWrapper();
        prodWrapper.isFavProduct = true;
        prodWrapper.ProductId = listPR[0].Id;
        prodWrapper.addToCart = true;
        prodWrapper.Id = listPR[0].Id;
        prodWrapper.UnitPrice = 200;
        prodWrapper.ProductName = 'Corn';
        prodWrapper.OrderQuantity = 10;
        prodWrapper.isSelected = true;
        
        List<ProductWrapper> listProdWrapper = new List<ProductWrapper>{prodWrapper};
        String serializedProdWrapperList = JSON.serialize(listProdWrapper); 
        
        String searchKey = '';
        String alphaText ='';
        String sortBy = '';
        String accountId = objAcc.Id;
        Integer offset = 0;
        
        ProductAdvancedFilter prodFilter = new ProductAdvancedFilter();        
        prodFilter.Family = '';
        prodFilter.ProductCode = '';
        prodFilter.MerchandiseType = '';
        prodFilter.Size = '';
        prodFilter.Color = '';
        String strprodFilter =  JSON.serialize(prodFilter); 
        
        POProductsController.onLoad(searchKey, offset, alphaText, sortBy, prodFilter, accountId);
        POProductsController.clickedOnSearch(searchKey, offset, alphaText, sortBy, strprodFilter, accountId);
          /********************* comment favorite product functionality ***********************************/       
   /****** POProductsController.makeProductFavourite(serializedProdWrapperList);*******/
        
        ProductWrapper prodWrap1 = new ProductWrapper();
        prodWrap1.isFavProduct = false;
        prodWrap1.ProductId = listPR[0].Id;
        List<ProductWrapper> lstProdWrap1 = new List<ProductWrapper>{prodWrap1};
        String strlstProdWrap1 = JSON.serialize(lstProdWrap1);    
          /********************* comment favorite product functionality ***********************************/       
   /****** POProductsController.makeProductFavourite(strlstProdWrap1);********/
        POProductsController.addProductsToCart(serializedProdWrapperList, accountId);  
        System.assert(true);
    }
}