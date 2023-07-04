public with sharing class POProductsController {
    public static String pricebookName = '';
    
    @AuraEnabled
    public static ProductSearchWrapper onLoad(String searchKey, Integer offset, String alphaText, String sortBy, ProductAdvancedFilter prodFilter, String accountId){
        ProductSearchWrapper pObj = new ProductSearchWrapper();
        pObj.prodList = getAdvanceSearch(searchKey, offset, alphaText, sortBy, prodFilter, accountId);
        pObj.resultSize = getResultSize(searchKey, offset, sortBy, prodFilter, alphaText, accountId);
        //pObj.prodInitials = getAlphaList(searchKey, offset, prodFamily, sortBy, prodPackaging, prodTreatment, alphaText, accountId);
        pObj.favProdList = findFavoriteProducts(accountId);
        pObj.topProdList = findTopProducts(accountId);
        pObj.totalItems = getTotalItems(accountId);
       
        System.debug(':::onLoad::::pObj='+ JSON.serialize(pObj));
        return pObj;
    }
    @AuraEnabled
    public static Integer getTotalItems(String accountId){  
       System.debug('::::getTotalItems:::::::accountId=' + accountId);
       List<gii__PurchaseOrderLine__c> cartList = PurchaseOrderUtil.getSOLinesByActId(accountId);           
       return cartList.size();
    }
    
    @AuraEnabled
    public static String searchFilter(String searchKey, String alphaText, String sortBy, ProductAdvancedFilter prodFilter, Boolean isAlpha, String accountId){
        String searchString= '';
        Boolean whereFlag = false;
        if(searchKey != null && searchKey.trim() != ''){ searchString = ' WHERE gii__Product__r.Name like \'%' + searchKey.trim() + '%\''; whereFlag = true;}
        if(isAlpha == true && alphaText != null && alphaText.trim() != '') {searchString += ((searchKey != null && searchKey.trim() != '')? ' and ' : ' where ' )+ (' gii__Product__r.Name like \'' + alphaText.trim() + '%\'');  whereFlag = true;}       
        // System.debug('sortBy = ' + sortBy);
        System.debug('::::prodFilter-->::::' + prodFilter);
        if(prodFilter != null) {
            if(prodFilter.Family != null && prodFilter.Family != ''){ searchString += (whereFlag == true ? ' and ' : ' where ' )+ (' gii__Product__r.gii__Family__c like \'%' + prodFilter.Family + '%\''); whereFlag = true;}
            if(prodFilter.ProductCode != null && prodFilter.ProductCode != ''){ searchString += (whereFlag == true ? ' and ' : ' where ' )+ (' gii__Product__r.gii__ProductCode__c like \'%' + prodFilter.ProductCode + '%\''); whereFlag = true;}
            if(prodFilter.MerchandiseType != null && prodFilter.MerchandiseType != ''){ searchString += (whereFlag == true ? ' and ' : ' where ' )+ (' gii__Product__r.gii__MerchandiseType__c = \'' + prodFilter.MerchandiseType + '\''); whereFlag = true;}
            if(prodFilter.Color != null && prodFilter.Color != ''){ searchString += (whereFlag == true ? ' and ' : ' where ' )+ (' gii__Product__r.gii__Color__c = \'' + prodFilter.Color + '\''); whereFlag = true;}
            if(prodFilter.Size != null && prodFilter.Size != ''){ searchString += (whereFlag == true ? ' and ' : ' where ' )+ (' gii__Product__r.gii__Size__c = \'' + prodFilter.Size + '\''); whereFlag = true;}
            // Name => gii__MerchandiseType__c
            // gii__ProductImageId__c => gii__Size__c
            // gii__Revision__c => gii__Color__c
        }
        System.debug('::::accountId::::' + accountId);
        gii__AccountAdd__c objAR = [Select gii__SupplierPriceBook__c from gii__AccountAdd__c where gii__Account__c = :accountId];
        pricebookName = String.isEmpty(objAR.gii__SupplierPriceBook__c) ? 'Standard' : objAR.gii__SupplierPriceBook__c;
        if(pricebookName != ''){ searchString += (whereFlag == true ? ' and ' : ' where ' )+ (' gii__PriceBook__r.Name = :pricebookName');whereFlag = true;}
        System.debug('searchString = ' + searchString);
        
        searchString += (whereFlag == true ? ' and ' : ' where ' )+ ' gii__Product__r.gii__ProductReference__r.isActive=true '; //and gii__Product__r.gii__ProductStyle__c != null 
        return searchString;
    }
    
    @AuraEnabled
    public static ProductSearchWrapper clickedOnSearch(String searchKey, Integer offset, String alphaText, String sortBy, String prodFilter, String accountId){
        ProductAdvancedFilter prodFilterObj = new ProductAdvancedFilter();
        if(prodFilter != null )prodFilterObj = (ProductAdvancedFilter)System.JSON.deserialize(prodFilter,ProductAdvancedFilter.class);
        ProductSearchWrapper pObj = new ProductSearchWrapper();
        pObj.prodList = getAdvanceSearch(searchKey, offset, alphaText, sortBy, prodFilterObj, accountId);
        pObj.resultSize = getResultSize(searchKey, offset, sortBy, prodFilterObj, alphaText, accountId);
        //pObj.prodInitials = getAlphaList(searchKey, offset, sortBy, prodFamily, prodPackaging, prodTreatment, alphaText, accountId);
        return pObj;
    }
    
    @AuraEnabled
    public static Integer getResultSize(String searchKey, Integer offset, String sortBy, ProductAdvancedFilter prodFilter, String alphaText, String accountId){
        String searchString= searchFilter(searchKey, alphaText, sortBy, prodFilter, true, accountId);
        String prodPriceEntryQuery = 'SELECT count(Id) recordSize FROM gii__PriceBookEntry__c ' + searchString ;
        List<AggregateResult> groupedResults= (List<AggregateResult>)Database.query(prodPriceEntryQuery);
        return (Integer)groupedResults[0].get('recordSize');
    }
        
    @AuraEnabled
    public static List<ProductWrapper> getAdvanceSearch(String searchKey, Integer offset, String alphaText, String sortBy, ProductAdvancedFilter prodFilter, String accountId){
        
        Map<Id, ProductWrapper> mapProductwrapper = new Map<Id, ProductWrapper>();
        List<ProductWrapper> lstProductwrapper = new List<ProductWrapper>();
        System.debug(':::sortBy='+sortBy);
        Map<String,String> mapOrderby = new Map<String,String>{'Name'=>'gii__Product__r.Name','Price'=>'gii__UnitPrice__c','Product Family'=>'gii__Product__r.gii__Family__c'};
       
        String limitAndOffset = ' order by '+ ((sortBy!= null && sortBy != '' && mapOrderby.containsKey(sortBy)) ? mapOrderby.get(sortBy) : 'gii__Product__r.Name') + '  LIMIT '+ System.Label.PaginationPageSize +' OFFSET '+ offset ;
        
        String searchString= searchFilter(searchKey, alphaText, sortBy, prodFilter, true, accountId);
        
        String prodPriceEntryQuery = 'SELECT Id, gii__PriceBook__r.Name, gii__Product__r.Id, gii__Product__r.gii__Description__c, gii__Product__r.Name, gii__Product__r.gii__ProductCode__c, gii__Product__r.gii__ProductImageId__c, gii__UnitPrice__c, gii__Product__r.gii__Family__c, gii__Product__r.gii__StockUM__c FROM gii__PriceBookEntry__c' 
            +searchString + limitAndOffset;
        System.debug(':::prodPriceEntryQuery='+prodPriceEntryQuery);
        Map<String, List<ProductWrapper>> pwMap = new Map<String, List<ProductWrapper>>();
        for(gii__PriceBookEntry__c objProdEntry : (List<gii__PriceBookEntry__c>)Database.query(prodPriceEntryQuery)){                
            ProductWrapper prodWrapper = new ProductWrapper();
            prodWrapper.priceBookEntryId= objProdEntry.Id;
            prodWrapper.PriceBookName   = objProdEntry.gii__PriceBook__r.Name;
            prodWrapper.ProductId       = objProdEntry.gii__Product__r.Id;
            prodWrapper.ProductName     = objProdEntry.gii__Product__r.Name;
            prodWrapper.ProductCode     = objProdEntry.gii__Product__r.gii__ProductCode__c;
            prodWrapper.UnitPrice       = objProdEntry.gii__UnitPrice__c;
            prodWrapper.ProductFamily   = objProdEntry.gii__Product__r.gii__Family__c;
            prodWrapper.Description     = objProdEntry.gii__Product__r.gii__Description__c;
            prodWrapper.ProductImageId  = objProdEntry.gii__Product__r.gii__ProductImageId__c;
            
            mapProductwrapper.put(prodWrapper.priceBookEntryId, prodWrapper);
            System.debug(':::mapProductwrapper='+mapProductwrapper);
            lstProductwrapper.add(prodWrapper);
            if(!pwMap.containsKey(objProdEntry.gii__Product__r.Id)) pwMap.put(objProdEntry.gii__Product__r.Id, new List<ProductWrapper>());
            pwMap.get(objProdEntry.gii__Product__r.Id).add(prodWrapper);
        }
        /********************* comment favorite product functionality ***********************************/       
       /****** for(gii__Product2Add__Tag fv :[Select id, ItemId from gii__Product2Add__Tag WHERE ItemId IN :pwMap.keySet()]){
            if(pwMap.containsKey(fv.ItemId)){
                for(ProductWrapper prodWrapper :pwMap.get(fv.ItemId)){
                    prodWrapper.isFavProduct = true;    
                }    
            }
        }********/
        
        for(gii__PurchaseOrderLine__c cp :PurchaseOrderUtil.getSOLinesByActId(accountId))
        {
            System.debug(':::::prod='+ cp.gii__Product__c);
            if(pwMap.containsKey(cp.gii__Product__c)){
                for(ProductWrapper prodWrapper :pwMap.get(cp.gii__Product__c)){  
                    prodWrapper.addToCart       = true;
                    prodWrapper.Id       = cp.Id;
                    //prodWrapper.PriceBookName   = PRICEBOOKNAME
                    prodWrapper.UnitPrice       = cp.gii__UnitPrice__c;
                    prodWrapper.OrderQuantity   = Integer.valueOf(cp.gii__OrderQuantity__c);
                    System.debug(':::::q='+ cp.gii__OrderQuantity__c);
                    System.debug(':::::q='+ Integer.valueOf(cp.gii__OrderQuantity__c));
                    System.debug(':::::q='+ prodWrapper); 
                }
            }
        }
        
        return lstProductwrapper;                         
    }
    /********************* comment favorite product functionality ***********************************/       
   /****** @AuraEnabled
    public static List<ProductWrapper> makeProductFavourite(String productWrapper){
        system.debug('insideApex productWrapper-->' + productWrapper);
        List<ProductWrapper> wrapper = (List<ProductWrapper>)System.JSON.deserialize(productWrapper,List<ProductWrapper>.class);
        system.debug('deserialized wrapper-->' + wrapper);
        List<gii__Product2Add__Tag> favProductLst = new List<gii__Product2Add__Tag>();
        Set<String> setUnFavProduct = new Set<String>();
        
        for(ProductWrapper prodWrap : wrapper){
            if(prodWrap.isFavProduct==true){
                gii__Product2Add__Tag productTag = new gii__Product2Add__Tag();
                productTag.ItemId  = prodWrap.ProductId;
                productTag.Type  = 'Personal';
                productTag.Name = 'Fav';//prodWrap.ProductName;
                favProductLst.add(productTag);
                system.debug('favProductLst-->'+favProductLst); 
            }
            if(prodWrap.isFavProduct==false){
                setUnFavProduct.add(prodWrap.ProductId);
                system.debug('setUnFavProduct-->'+setUnFavProduct); 
            } 
        }
        if(favProductLst.size() > 0 && favProductLst != null) insert favProductLst;
        if(setUnFavProduct.size() > 0 && setUnFavProduct != null){
            List<gii__Product2Add__Tag> unFavoriteList = [Select id from gii__Product2Add__Tag WHERE ItemId IN : setUnFavProduct];
            system.debug('Product2Add__Tag-->'+[SELECT Id , Name FROM gii__Product2Add__Tag]);
            delete unFavoriteList; 
        }
        //update wrapper;
        return wrapper;
    }**********/
    
    @AuraEnabled
    public static List<gii__PurchaseOrderLine__c> addProductsToCart(String productlist, String accountId){
        Savepoint sp = Database.setSavepoint();  
        List<gii__PurchaseOrderLine__c> cartProductlst ;
        try{
            System.debug(':::accountId-->' + accountId);
            List<ProductWrapper> selProductList = (List<ProductWrapper>)System.JSON.deserialize(productlist,List<ProductWrapper>.class);
            System.debug('deserialized selProductList-->' + selProductList);
            //String accountRefId = [Select Id FROM gii__AccountAdd__c WHERE gii__Account__r.Id =:accountId][0].Id; 
            //system.debug('accountRefId-->'+accountRefId);
            
            //SOQL on Cart-Product & make a Map => Key = Product Id & Value will have CartProdct Object                        
            
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
    
    @AuraEnabled
    public static List<ProductWrapper> findFavoriteProducts(String accountId){ 
        System.debug(':::findFavoriteProducts::accountId='+ accountId);
        String objPrefix= Schema.getGlobalDescribe().get('gii__Product2Add__c').getDescribe().getKeyPrefix();
        
        Map<String, ProductWrapper> favWrapperMap = new Map<String, ProductWrapper>();        
        /********************* comment favorite product functionality ***********************************/       
   /****** for(gii__Product2Add__Tag fv :[Select id, ItemId from gii__Product2Add__Tag where Type='Personal' ]){//WHERE ItemId like :objPrefix
            ProductWrapper prodWrapper = new ProductWrapper();    
            prodWrapper.ProductId       = fv.ItemId;
            prodWrapper.isFavProduct = true;
            prodWrapper.OrderQuantity   = 0;
            favWrapperMap.put(fv.ItemId, prodWrapper);            
            System.debug(':::::ItemId='+ fv.ItemId);
        }
        
        //for(gii__Product2Add__c p :[Select Name, gii__Family__c, gii__Description__c, gii__ProductImageId__c from gii__Product2Add__c where Id in :favWrapperMap.keySet()]){
        for(gii__PriceBookEntry__c p :[SELECT Id, gii__PriceBook__r.Name, gii__Product__c, gii__Product__r.gii__Description__c, gii__Product__r.Name, gii__Product__r.gii__ProductImageId__c, gii__UnitPrice__c, gii__Product__r.gii__Family__c, gii__Product__r.gii__StockUM__c FROM gii__PriceBookEntry__c
               where  gii__Product__c in :favWrapperMap.keySet()])
        {
            if(favWrapperMap.containsKey(p.gii__Product__c)){
                ProductWrapper prodWrapper = favWrapperMap.get(p.gii__Product__c);   
                prodWrapper.ProductName     = p.gii__Product__r.Name;
                prodWrapper.ProductFamily   = p.gii__Product__r.gii__Family__c;
                prodWrapper.Description     = p.gii__Product__r.gii__Description__c;
                prodWrapper.ProductImageId  = p.gii__Product__r.gii__ProductImageId__c;                
                prodWrapper.UnitPrice       = p.gii__UnitPrice__c;
            }
        }
        
        for(gii__PurchaseOrderLine__c cp :PurchaseOrderUtil.getSOLinesByProdIdAndActId(accountId, favWrapperMap.keySet()))
        {
            System.debug(':::::prod='+ cp.gii__Product__c);
            if(favWrapperMap.containsKey(cp.gii__Product__c)){
                ProductWrapper prodWrapper = favWrapperMap.get(cp.gii__Product__c); 
                //prodWrapper.PriceBookName   = PRICEBOOKNAME;
                prodWrapper.Id              = cp.Id;
                prodWrapper.UnitPrice       = cp.gii__UnitPrice__c;
                prodWrapper.OrderQuantity   = Integer.valueOf(cp.gii__OrderQuantity__c);
                
                System.debug(':::::q='+ cp.gii__OrderQuantity__c);
                System.debug(':::::q='+ Integer.valueOf(cp.gii__OrderQuantity__c));
                System.debug(':::::q='+ prodWrapper);                 
            }
        }
        System.debug(':::::m='+ favWrapperMap.values());********/
        return favWrapperMap.values();
    }
    
    @AuraEnabled
    public static List<ProductWrapper> findTopProducts(String accountId){ 
        System.debug(':::findTopProducts::accountId='+ accountId);
        String objPrefix= Schema.getGlobalDescribe().get('gii__Product2Add__c').getDescribe().getKeyPrefix();
        
        Map<String, ProductWrapper> topWrapperMap = new Map<String, ProductWrapper>();
        
        for(AggregateResult ar :[select SUM(gii__OrderQuantity__c) quantity, gii__Product__c from gii__PurchaseOrderLine__c 
                                 where gii__Product__r.gii__ProductReference__r.IsActive=true group by gii__Product__c  order by SUM(gii__OrderQuantity__c) Desc LIMIT 5]){
                                     ProductWrapper prodWrapper = new ProductWrapper();
                                     prodWrapper.ProductId       = (String)ar.get('gii__Product__c');             
                                     prodWrapper.OrderQuantity   = 0;
                                     topWrapperMap.put((String)ar.get('gii__Product__c'), prodWrapper);
                                 }
        /********************* comment favorite product functionality ***********************************/       
   /****** for(gii__Product2Add__Tag fv :[Select id, ItemId from gii__Product2Add__Tag where Type='Personal' ]){//WHERE ItemId like :objPrefix
            if(topWrapperMap.containsKey(fv.ItemId)){
                ProductWrapper prodWrapper = topWrapperMap.get(fv.ItemId);   
                prodWrapper.isFavProduct = true;
            }
        }******/
        
        //for(gii__Product2Add__c p :[Select Name, gii__Family__c, gii__Description__c, gii__ProductImageId__c from gii__Product2Add__c where Id in :topWrapperMap.keySet()]){
         for(gii__PriceBookEntry__c p :[SELECT Id, gii__PriceBook__r.Name, gii__Product__c, gii__Product__r.gii__Description__c, gii__Product__r.Name, gii__Product__r.gii__ProductImageId__c, gii__UnitPrice__c, gii__Product__r.gii__Family__c, gii__Product__r.gii__StockUM__c FROM gii__PriceBookEntry__c
               where  gii__Product__c in :topWrapperMap.keySet()])
         { 
            if(topWrapperMap.containsKey(p.gii__Product__c)){
                ProductWrapper prodWrapper = topWrapperMap.get(p.gii__Product__c);                
                    prodWrapper.ProductName     = p.gii__Product__r.Name;
                    prodWrapper.ProductFamily   = p.gii__Product__r.gii__Family__c;
                    prodWrapper.Description     = p.gii__Product__r.gii__Description__c;
                    prodWrapper.ProductImageId  = p.gii__Product__r.gii__ProductImageId__c;                    
                    prodWrapper.UnitPrice       = p.gii__UnitPrice__c;
              
            }
        }
        
        for(gii__PurchaseOrderLine__c cp :PurchaseOrderUtil.getSOLinesByProdIdAndActId(accountId, topWrapperMap.keySet()) )
        {
            System.debug(':::::prod='+ cp.gii__Product__c);
            if(topWrapperMap.containsKey(cp.gii__Product__c)){
                ProductWrapper prodWrapper = topWrapperMap.get(cp.gii__Product__c); 
                //prodWrapper.PriceBookName   = PRICEBOOKNAME;
                prodWrapper.Id              = cp.Id;
                prodWrapper.UnitPrice       = cp.gii__UnitPrice__c;
                prodWrapper.OrderQuantity   = Integer.valueOf(cp.gii__OrderQuantity__c);
                
                System.debug(':::::q='+ cp.gii__OrderQuantity__c);
                System.debug(':::::q='+ Integer.valueOf(cp.gii__OrderQuantity__c));
                System.debug(':::::q='+ prodWrapper);                 
            }
        }
        System.debug(':::::m='+ topWrapperMap.values());
        return topWrapperMap.values();
    } 
   
    @AuraEnabled
    public static List<String> getPicklistOptions( String objectName, String fieldName ) {         
        System.debug( 'Getting picklist options: objectName=' + objectName + ', fieldName=' + fieldName ); 
        
        List<String> options = new List<String>();        
        for ( PicklistEntry entry : Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap().get( fieldName ).getDescribe().getPicklistValues() ) {
            options.add(entry.getValue());
        }        
        System.debug( 'options=' + options );        
        return options;
    }
}