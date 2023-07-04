public with sharing class SOSummaryController {
    @AuraEnabled
    public static PlaceOrderWrapper getInfo(String accountId){ 
        System.debug(':::::accountId = ' + accountId);
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
            for(gii__SalesOrderLine__c objProduct : SalesOrderUtil.getSOLinesByActId(accountId)){
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
            SalesOrderUtil.deleteSOLines(accountId, new Set<String>{objProduct.ProductId});
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage()); 
        }
        return getInfo(accountId);
    }
    
    @AuraEnabled
    public static List<gii__SalesOrderLine__c> addProductsToCart(String productlist, String accountId){
        Savepoint sp = Database.setSavepoint();  
        List<gii__SalesOrderLine__c> cartProductlst ;
        try{
            System.debug(':::accountId-->' + accountId);
            List<ProductWrapper> selProductList = (List<ProductWrapper>)System.JSON.deserialize(productlist,List<ProductWrapper>.class);
            System.debug('deserialized selProductList-->' + selProductList);
            //String accountRefId = [Select Id FROM gii__AccountAdd__c WHERE gii__Account__r.Id =:accountId][0].Id; 
            //system.debug('accountRefId-->'+accountRefId);
            
            //SOQL on Cart-Product & make a Map => Key = Product Id & Value will have CartProdct Object                        
            
            List<gii__SalesOrderLine__c> cartList = SalesOrderUtil.getSOLinesByActId(accountId);   
            String cartId = '';
            if(cartList.isEmpty()){
                cartId = SalesOrderUtil.createSalesOrder(null, accountId, null);
                System.debug(':::::::::::cartId'+ cartId);
            }else{
                cartId = cartList[0].gii__SalesOrder__c;    
            }
            cartProductlst= SalesOrderUtil.createSOLines(cartId, accountId, selProductList, false);                
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('###############Exception:' + e);
            throw new AuraHandledException('Exception:'+e.getMessage());
        }
        return cartProductlst;
    }
    
    @AuraEnabled
    public static Map<String, String> placeSalesOrderWithLine(String accountId, String paymentMethod, String paymentMethodId, String destributor, Integer discount, String selectedPayMethod, Integer totalAmt, Integer percentAmt, Integer percentPayAmt, Integer customPayAmt, String comments){
        System.debug(':::::accountId = ' + accountId); 
        System.debug(':::::paymentMethod = ' + paymentMethod); 
        System.debug(':::::paymentMethodId = ' + paymentMethodId); 
        System.debug(':::::destributor = ' + destributor); 
        //System.debug(':::::selectedDealer = ' + selectedDealer); 
        System.debug(':::::discount = ' + discount); 
        System.debug(':::::selectedPayMethod = ' + selectedPayMethod); 
        System.debug(':::::totalAmt = ' + totalAmt); 
        System.debug(':::::percentAmt = ' + percentAmt); 
        System.debug(':::::percentPayAmt = ' + percentPayAmt); 
        System.debug(':::::customPayAmt = ' + customPayAmt); 
        System.debug(':::::comments = ' + comments);
        
        Savepoint sp = Database.setSavepoint();        
        try{ 
            //gii__AccountAdd__c objAcRef = [Select Id, gii__DefaultWarehouse__c, gii__DefaultTransferToWarehouse__c from gii__AccountAdd__c where gii__Account__c = :accountId];
            AccountWrapper objDestributor = (AccountWrapper)JSON.deserialize(destributor, AccountWrapper.class);
            //AccountWrapper objDealer = (AccountWrapper)JSON.deserialize(selectedDealer, AccountWrapper.class);
            //objAcRef.gii__DefaultTransferToWarehouse__c = objAcRef.gii__DefaultWarehouse__c;
            //System.debug(':::::selectedPayMethod = ' + selectedPayMethod);
            //System.debug(':::::objAcRef.gii__DefaultTransferToWarehouse__c  = ' + objAcRef.gii__DefaultTransferToWarehouse__c);
            //if(objAcRef.gii__DefaultTransferToWarehouse__c == null)throw new giic_CustomException('Exception: Default Transfer To Warehouse not found');
            
            //Upsert Sales Order
            List<gii__SalesOrderLine__c> solList = SalesOrderUtil.getSOLinesByActId(accountId);   
            String soId = '';
            if(solList.isEmpty()){
                soId = SalesOrderUtil.createSalesOrder(null, accountId, null);
                System.debug(':::::::::::soId='+ soId);
            }else{
                soId = solList[0].gii__SalesOrder__c;    
            }
            //Upsert Sales Order Lines
            List<gii__SalesOrderLine__c> cartProductlst= SalesOrderUtil.createSOLines(soId, accountId, objDestributor.prodList, true);
            //Create Sales Order Payment
            SalesOrderUtil.createSOPayment(soId, totalAmt, paymentMethod, selectedPayMethod, percentPayAmt, customPayAmt, paymentMethodId, comments);        
                       
            Map<String, String> retMap = new Map<String, String>{'recordId' => soId, 'UrlPathPrefix' =>''};
            List<Network> ntwrl = [Select Name, UrlPathPrefix from Network where Id= :Network.getNetworkId()];
            if(ntwrl != null && !ntwrl.isEmpty()) {
                String path = ntwrl[0].UrlPathPrefix;
                if(path != null)
                	retMap.put('UrlPathPrefix',  path + '/'); 
            }
            //return 'SUCCESS';  
            return retMap;
        }catch(exception e){
            Database.rollback(sp);
            System.debug(':::::Exception = ' + e.getMessage()); 
            throw new AuraHandledException('Exception:'+e.getMessage());
        }        
    }
   
}