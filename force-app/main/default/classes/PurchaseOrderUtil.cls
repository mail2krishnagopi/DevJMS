public with sharing class PurchaseOrderUtil {
    
    public static void deletePO(String poId){
        Set<Id> poIds = new Set<Id>();
        List<gii__PurchaseOrderLine__c> polines = getPOLinesByLastModifiedById(UserInfo.getUserId());
        for(gii__PurchaseOrderLine__c pol : polines){
            poIds.add(pol.gii__PurchaseOrder__c);    
        }    
        delete polines;
        delete [select Id from gii__PurchaseOrder__c where Id IN: poIds];
    }
    
    public static string wareHouseNameAcc(string accountId, string warehouseId){
        System.debug('In util:::'+accountId+'**warehouseId***'+warehouseId);
        if(warehouseId != '' && warehouseId != null){
            return [SELECT id,Name from gii__Warehouse__c WHERE id=:warehouseId LIMIT 1].Name;
        }
        return [SELECT id,Name,gii__DefaultWarehouse__c,gii__DefaultWarehouse__r.name FROM gii__AccountAdd__c WHERE id=:accountId LIMIT 1].gii__DefaultWarehouse__r.name;
    }
    
    public static Id createPurchaseOrder(String soId, String accountId, Integer discount){
        gii__PurchaseOrder__c so = new gii__PurchaseOrder__c();
        if(soId !=null && soId != '') so.Id = soId;
        so.gii__Supplier__c = accountId;
        if(discount != null && Integer.valueof('' + discount) > 0) {
            System.debug(':::::discount='+discount);
            so.gii__SupplierDiscountPercent__c = Integer.valueof('' + discount);  
        } 
        upsert so;
        return so.Id;
    }
    
    public static List<gii__PurchaseOrderLine__c> createPOLines(String soId, String accountId, List<ProductWrapper> selProductList, Boolean isPlaceOrder){
        Map<Id, AggregateResult> cartProdsMap = new Map<Id, AggregateResult>([Select gii__Product__c Id, Id cpId, gii__PurchaseOrder__c from gii__PurchaseOrderLine__c
                                                                              where gii__PurchaseOrder__r.gii__Supplier__c = :accountId and Is_Active_Cart_Line__c = true
                                                                              group by gii__Product__c, Id, gii__PurchaseOrder__c]);
        
        Set<String> setdeleteCartProduct = new Set<String>();
        List<gii__PurchaseOrderLine__c> cartProductlst = new List<gii__PurchaseOrderLine__c>(); 
        for(ProductWrapper objProd : selProductList){
            gii__PurchaseOrderLine__c objCartProduct = new gii__PurchaseOrderLine__c();
            if(objProd.OrderQuantity > 0 ){                
                if(cartProdsMap.containsKey(objProd.ProductId)) objCartProduct.Id =  (String)cartProdsMap.get(objProd.ProductId).get('cpId');                
                if(!cartProdsMap.containsKey(objProd.ProductId)) objCartProduct.gii__PurchaseOrder__c = soId;
                //objCartProduct = objProd.PriceBookName;
                objCartProduct.gii__Product__c       = objProd.ProductId;
                objCartProduct.gii__OrderQuantity__c = objProd.OrderQuantity;
                objCartProduct.gii__UnitPrice__c     = objProd.UnitPrice;
                PurchaseOrderUtil.setDefaultValueinPOLine(objCartProduct, isPlaceOrder);
                cartProductlst.add(objCartProduct);                    
            }else if(objProd.OrderQuantity <= 0){//objProd.addToCart == false
                if(cartProdsMap.containsKey(objProd.ProductId)) setdeleteCartProduct.add(objProd.ProductId);                    
            } 
        }
        System.debug('::::cartProductlst-->'+cartProductlst);
        System.debug('setdeleteCartProduct-->'+setdeleteCartProduct); 
        if(cartProductlst != null && cartProductlst.size() > 0) upsert cartProductlst;
        
        if(!setdeleteCartProduct.isEmpty()){
            PurchaseOrderUtil.deletePOLines(accountId, setdeleteCartProduct);
        }         
        return cartProductlst;
    }
    /*
    public static void createSOPayment(String soId, Integer totalAmt, String paymentMethod, String selectedPayMethod,
                                      Integer percentPayAmt, Integer customPayAmt, String paymentMethodId)
    {
        gii__SalesOrderPayment__c sop = new gii__SalesOrderPayment__c();
        sop.gii__SalesOrder__c = soId;
        sop.gii__PaymentMethod__c = paymentMethod;
        if(selectedPayMethod == 'fullPay'){
            sop.gii__PaidAmount__c =Integer.valueOf(totalAmt); 
        }
        else if(selectedPayMethod == 'percentPay'){
            sop.gii__PaidAmount__c = Integer.valueOf(percentPayAmt);  
        }
        else{
            sop.gii__PaidAmount__c = Integer.valueOf(customPayAmt);  
        }
        sop.gii__PaymentDate__c = System.today();
        if(paymentMethod != null && paymentMethod != '')sop.gii__PaymentMethod__c  = paymentMethod;
        insert sop; 
    }*/
    
    public static List<gii__PurchaseOrderLine__c> getPOLinesByLastModifiedById(String userId){
        return [SELECT Id, gii__Product__c, gii__Product__r.Name, gii__Product__r.gii__ProductImageId__c, gii__PurchaseOrder__c, gii__OrderQuantity__c, gii__UnitPrice__c
                FROM gii__PurchaseOrderLine__c 
                WHERE LastModifiedById =: userId 
                and Is_Active_Cart_Line__c = true];  
    }
    
    public static List<gii__PurchaseOrderLine__c> getSOLinesByActId(String accountId){
        return [SELECT Id, gii__Product__c, gii__Product__r.Name, gii__Product__r.gii__ProductImageId__c, gii__PurchaseOrder__c, gii__OrderQuantity__c, gii__UnitPrice__c
                FROM gii__PurchaseOrderLine__c 
                WHERE gii__PurchaseOrder__r.gii__Supplier__c =: accountId 
                and Is_Active_Cart_Line__c = true and LastModifiedById =:UserInfo.getUserId()];  
    }
    
    public static List<gii__PurchaseOrderLine__c> getSOLinesByProdIdAndActId(String accountId, Set<String> prodId){
        return [SELECT Id, gii__Product__c, gii__Product__r.Name, gii__Product__r.gii__ProductImageId__c, gii__PurchaseOrder__c, gii__OrderQuantity__c, gii__UnitPrice__c 
                FROM gii__PurchaseOrderLine__c 
                WHERE gii__PurchaseOrder__r.gii__Supplier__c =: accountId 
                and gii__Product__c in :prodId
                and Is_Active_Cart_Line__c = true and LastModifiedById =:UserInfo.getUserId()];  
    }
    
    public static Boolean deletePOLines(String accountId, Set<String> prodIds){
        delete [Select id from gii__PurchaseOrderLine__c WHERE gii__Product__c IN : prodIds 
                and gii__PurchaseOrder__r.gii__Supplier__c = :accountId and Is_Active_Cart_Line__c = true 
                and LastModifiedById =:UserInfo.getUserId()];
        return true;
    }

    public static void setDefaultValueinPOLine(gii__PurchaseOrderLine__c sol, Boolean isPlaceOrder){
        sol.Is_Active_Cart_Line__c= isPlaceOrder? false : true;
    }
}