public with sharing class POSummaryController {
    @AuraEnabled
    public static PlaceOrderWrapper getInfo(String accountId, string wareHouseId){ 
        System.debug(':::::accountId = ' + accountId +'***wareHouseId**'+wareHouseId);
        PlaceOrderWrapper objPOWrapper = new PlaceOrderWrapper();   
        try{                
            Account parentAc = [select id, Name, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry, 
                                BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, Phone  
                                from Account 
                                where id = :accountId];           
            objPOWrapper.parentAcc.Id =  parentAc.id;
            objPOWrapper.parentAcc.Name =  parentAc.Name;
            objPOWrapper.parentAcc.Phone =  parentAc.Phone;
            objPOWrapper.parentAcc.ShippingStreet =  parentAc.ShippingStreet;
            objPOWrapper.parentAcc.ShippingCity =  parentAc.ShippingCity;
            objPOWrapper.parentAcc.ShippingPostalCode =  parentAc.ShippingPostalCode;
            objPOWrapper.parentAcc.ShippingState =  parentAc.ShippingState;
            objPOWrapper.parentAcc.ShippingCountry =  parentAc.ShippingCountry;
            objPOWrapper.parentAcc.BillingStreet =  parentAc.BillingStreet;
            objPOWrapper.parentAcc.BillingCity =  parentAc.BillingCity;
            objPOWrapper.parentAcc.BillingPostalCode =  parentAc.BillingPostalCode;
            objPOWrapper.parentAcc.BillingState =  parentAc.BillingState;
            objPOWrapper.parentAcc.BillingCountry =  parentAc.BillingCountry;
            
            objPOWrapper.parentAcc.prodList.addAll(getCartProducts(accountId));
            
            objPOWrapper.parentAcc.warehouseName = PurchaseOrderUtil.wareHouseNameAcc(accountId,wareHouseId);
            //objPOWrapper.lstChild.addAll(getDealerAccounts(accountId));            
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage());
        }       
        return objPOWrapper;         
    }
    
     @AuraEnabled
    public static List<ProductWrapper> getCartProducts(String accountId){        
        System.debug(':::::accountId = ' + accountId);
        List<ProductWrapper> lstProdWrapper = new List<ProductWrapper>();
        try{
            for(gii__PurchaseOrderLine__c objProduct : PurchaseOrderUtil.getSOLinesByActId(accountId)){
                ProductWrapper objProd = new ProductWrapper();
                objProd.ProductId = objProduct.gii__Product__c;
                objProd.ProductName = objProduct.gii__Product__r.Name;
                objProd.ProductImageId = objProduct.gii__Product__r.gii__ProductImageId__c;
                objProd.UnitPrice = objProduct.gii__UnitPrice__c;
                objProd.OrderQuantity = Integer.valueOf(objProduct.gii__OrderQuantity__c);                      
                lstProdWrapper.add(objProd);
            }          
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage());
        } 
        System.debug(':::::lstProdWrapper = ' + lstProdWrapper);
        return lstProdWrapper;               
    }
    
     @AuraEnabled
    public static PlaceOrderWrapper removeProductFromCart(String accountId, String selectedProduct){
        System.debug(':::::accountId = ' + accountId);
        ProductWrapper objProduct = (ProductWrapper)JSON.deserialize(selectedProduct, ProductWrapper.class);
        System.debug(':::::objProduct = ' + objProduct);
        try{
            PurchaseOrderUtil.deletePOLines(accountId,new Set<String>{objProduct.ProductId});
            //SalesOrderUtil.deleteSOLines(accountId, new Set<String>{objProduct.ProductId});
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage()); 
        }
        return getInfo(accountId,'');
    }
    @AuraEnabled
    public static List<gii__PurchaseOrderLine__c> addProductsToCart(String productlist, String accountId){
        Savepoint sp = Database.setSavepoint();  
        List<gii__PurchaseOrderLine__c> cartProductlst ;
        try{
            System.debug(':::accountId-->' + accountId);
            List<ProductWrapper> selProductList = (List<ProductWrapper>)System.JSON.deserialize(productlist, List<ProductWrapper>.class);
            System.debug('deserialized selProductList-->' + selProductList);                     
            
            List<gii__PurchaseOrderLine__c> cartList = PurchaseOrderUtil.getSOLinesByActId(accountId);   
            String cartId = '';
            if(cartList.isEmpty()){
                cartId = PurchaseOrderUtil.createPurchaseOrder(null, accountId, null);
                System.debug(':::::::::::cartId'+ cartId);
            }else{
                cartId = cartList[0].gii__PurchaseOrder__c;    
            }
            cartProductlst= PurchaseOrderUtil.createPOLines(cartId, accountId, selProductList, false);                
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('###############Exception:' + e);
            throw new AuraHandledException('Exception:'+e.getMessage());
        }
        return cartProductlst;
    }
    //this method used for to create purchase order and purchase order Line
    @AuraEnabled
    public static Map<String, String> purchaseOrderWithLines(String accountId, String destributor, Integer discount, String selectedPayMethod, Integer totalAmt, Integer percentAmt, Integer percentPayAmt, Integer customPayAmt){
        Savepoint sp = Database.setSavepoint();        
        try{ 
            AccountWrapper objDestributor = (AccountWrapper)JSON.deserialize(destributor, AccountWrapper.class);
            List<gii__PurchaseOrderLine__c> solList = PurchaseOrderUtil.getSOLinesByActId(accountId);   
            String soId = '';
            if(solList.isEmpty()){
                soId = PurchaseOrderUtil.createPurchaseOrder(null, accountId, null);
                System.debug(':::::::::::soId='+ soId);
            }else{
                soId = solList[0].gii__PurchaseOrder__c;    
            }
            //Upsert Sales Order Lines
            List<gii__PurchaseOrderLine__c> cartProductlst= PurchaseOrderUtil.createPOLines(soId, accountId, objDestributor.prodList, true);
            //Create Sales Order Payment
            //SalesOrderUtil.createSOPayment(soId, totalAmt, paymentMethod, selectedPayMethod, percentPayAmt, customPayAmt, paymentMethodId);                  
            Map<String, String> retMap = new Map<String, String>{'recordId' => soId, 'UrlPathPrefix' =>''};
            List<Network> ntwrl = [Select Name, UrlPathPrefix from Network where Id= :Network.getNetworkId()];
            if(ntwrl != null && !ntwrl.isEmpty()){
                String path = ntwrl[0].UrlPathPrefix;
                if(path != null)
                	retMap.put('UrlPathPrefix',  path + '/'); 
            }
            return retMap;
        }catch(exception e){
            Database.rollback(sp);
            System.debug(':::::Exception = ' + e.getMessage()); 
            throw new AuraHandledException('Exception:'+e.getMessage());
        }
    }
    
    //This method used for create purchase order lines called from purchaseOrderWithLines Method
    @AuraEnabled
    public static void purchaseOrderLines(id poId,List<ProductWrapper> prodList){
        system.debug('poId::'+poId+'***'+'prodList:::'+prodList);
        // create list for PO lines
        List<gii__PurchaseOrderLine__c> listPOLine = new List<gii__PurchaseOrderLine__c>();
        if (poId != null && !prodList.isEmpty()) {
            for(ProductWrapper pw :prodList){
                // create the PO line sObject and populate its required fields, and optionally other fields.
                gii__PurchaseOrderLine__c poLine1 = new gii__PurchaseOrderLine__c();
                poLine1.gii__PurchaseOrder__c = poId;        // Purchase Order Id which is required 
                poLine1.gii__Product__c = pw.ProductId; // Product reference Id which is required
                poLine1.gii__OrderQuantity__c = pw.OrderQuantity; // (Buying UM)
                poLine1.gii__UnitPrice__c = pw.UnitPrice;
                // add PO line to the list
                listPOLine.add(poLine1);
            }
            
        }
        
        // insert PO ines
        if (listPOLine.size() > 0) {
            try {
                insert listPOLine;
            }
            Catch(DMLException e) {
                system.debug(e.getMessage());
            }
        }
        
    }
}