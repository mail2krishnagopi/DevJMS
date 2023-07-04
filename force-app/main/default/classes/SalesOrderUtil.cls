public with sharing class SalesOrderUtil {
    public static void deleteSO(String soId){
        Set<Id> soIds = new Set<Id>();
        List<gii__SalesOrderLine__c> solines = getSOLinesByLastModifiedById(UserInfo.getUserId());
        for(gii__SalesOrderLine__c sol :solines){
            soIds.add(sol.gii__SalesOrder__c);    
        }    
        delete solines;
        delete [select id from gii__SalesOrder__c where Id in :soIds];
    }
    public static Id createSalesOrder(String soId, String accountId, Integer discount){
        gii__SalesOrder__c so = new gii__SalesOrder__c();
        if(soId !=null && soId != '') so.Id = soId;
        so.gii__Account__c = accountId;
        if(discount != null && Integer.valueof('' + discount) > 0) {
            System.debug(':::::discount='+discount);
            so.gii__DiscountPercent__c = Integer.valueof('' + discount);  
        } 
        upsert so;
        return so.Id;
    }
    
    public static List<gii__SalesOrderLine__c> createSOLines(String soId, String accountId, List<ProductWrapper> selProductList, Boolean isPlaceOrder){
        Map<Id, AggregateResult> cartProdsMap = new Map<Id, AggregateResult>([Select gii__Product__c Id, Id cpId, gii__SalesOrder__c from gii__SalesOrderLine__c
                                                                              where gii__SalesOrder__r.gii__Account__c = :accountId and Is_Active_Cart_Line__c = true
                                                                              group by gii__Product__c, Id, gii__SalesOrder__c]);
        
        Set<String> setdeleteCartProduct = new Set<String>();
        List<gii__SalesOrderLine__c> cartProductlst = new List<gii__SalesOrderLine__c>(); 
        for(ProductWrapper objProd : selProductList){
            gii__SalesOrderLine__c objCartProduct = new gii__SalesOrderLine__c();
            if(objProd.OrderQuantity > 0 ){                
                if(cartProdsMap.containsKey(objProd.ProductId)) objCartProduct.Id =  (String)cartProdsMap.get(objProd.ProductId).get('cpId');                
                if(!cartProdsMap.containsKey(objProd.ProductId)) objCartProduct.gii__SalesOrder__c = soId;
                //objCartProduct = objProd.PriceBookName;
                objCartProduct.gii__Product__c       = objProd.ProductId;
                objCartProduct.gii__OrderQuantity__c = objProd.OrderQuantity;
                objCartProduct.gii__UnitPrice__c     = objProd.UnitPrice;
                SalesOrderUtil.setDefaultValueinSOLine(objCartProduct, isPlaceOrder);
                cartProductlst.add(objCartProduct);                    
            }else if(objProd.OrderQuantity <= 0){//objProd.addToCart == false
                if(cartProdsMap.containsKey(objProd.ProductId)) setdeleteCartProduct.add(objProd.ProductId);                    
            } 
        }
        System.debug('::::cartProductlst-->'+cartProductlst);
        System.debug('setdeleteCartProduct-->'+setdeleteCartProduct); 
        if(cartProductlst != null && cartProductlst.size() > 0) upsert cartProductlst;
        
        if(!setdeleteCartProduct.isEmpty()){
            SalesOrderUtil.deleteSOLines(accountId, setdeleteCartProduct);
        }         
        return cartProductlst;
    }
    
    public static void createSOPayment(String soId, Integer totalAmt, String paymentMethod, String selectedPayMethod,
                                      Integer percentPayAmt, Integer customPayAmt, String paymentMethodId, String comments)
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
        sop.gii__Comments__c = comments;
        sop.gii__PaymentDate__c = System.today();
        if(paymentMethod != null && paymentMethod != '')sop.gii__PaymentMethod__c  = paymentMethod;
        insert sop; 
    }
    
    public static List<gii__SalesOrderLine__c> getSOLinesByLastModifiedById(String userId){
        return [SELECT Id, gii__Product__c, gii__Product__r.Name, gii__Product__r.gii__ProductImageId__c, gii__SalesOrder__c, gii__OrderQuantity__c, gii__UnitPrice__c
                FROM gii__SalesOrderLine__c 
                WHERE LastModifiedById =: userId 
                and Is_Active_Cart_Line__c = true];  
    }
    
    public static List<gii__SalesOrderLine__c> getSOLinesByActId(String accountId){
        return [SELECT Id, gii__Product__c, gii__Product__r.Name, gii__Product__r.gii__ProductImageId__c, gii__SalesOrder__c, gii__OrderQuantity__c, gii__UnitPrice__c
                FROM gii__SalesOrderLine__c 
                WHERE gii__SalesOrder__r.gii__Account__c =: accountId 
                and Is_Active_Cart_Line__c = true and LastModifiedById =:UserInfo.getUserId()];  
    }
    
    public static List<gii__SalesOrderLine__c> getSOLinesByProdIdAndActId(String accountId, Set<String> prodId){
        return [SELECT Id, gii__Product__c, gii__Product__r.Name, gii__Product__r.gii__ProductImageId__c, gii__SalesOrder__c, gii__OrderQuantity__c, gii__UnitPrice__c 
                FROM gii__SalesOrderLine__c 
                WHERE gii__SalesOrder__r.gii__Account__c =: accountId 
                and gii__Product__c in :prodId
                and Is_Active_Cart_Line__c = true and LastModifiedById =:UserInfo.getUserId()];  
    }
    
    public static Boolean deleteSOLines(String accountId, Set<String> prodIds){
        delete [Select id from gii__SalesOrderLine__c WHERE gii__Product__c IN : prodIds 
                and gii__SalesOrder__r.gii__Account__c = :accountId and Is_Active_Cart_Line__c = true 
                and LastModifiedById =:UserInfo.getUserId()];
        return true;
    }
    
    public static void setDefaultValueinSOLine(gii__SalesOrderLine__c sol, Boolean isPlaceOrder){
        sol.Is_Active_Cart_Line__c= isPlaceOrder? false : true;
    }
}