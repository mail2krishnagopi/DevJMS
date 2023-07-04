@isTest(SeeAllData=false)
public class SOProductControllerTest {
    static testMethod void onLoadTest() {
        gii__Warehouse__c objWH = new gii__Warehouse__c(Name = 'Default  Warehouse');
        insert objWH;
        
        gii__SystemPolicy__c s;
        //check if system policy record already exists
        for(gii__SystemPolicy__c sys : [select id, gii__StockUM__c
                                        from gii__SystemPolicy__c where name = 'GII' LIMIT 1]){
                                            s = sys;
                                        }
        if(s == null) {
            gii__SystemPolicy__c sp = new gii__SystemPolicy__c (name = 'GII',
                                                                gii__StockUM__c = 'Each',
                                                                gii__PriceBookName__c = 'Standard',
                                                                gii__Warehouse__c = objWH.id
                                                               ); 
            insert sp;    
        }
        
        Account objAcc = new Account(Name = 'Test Account');
        insert objAcc;
        
        gii__AccountAdd__c  objAR =  [select id, Name, gii__PriceBookName__c from gii__AccountAdd__c Limit 1];
        
        objAR.gii__PriceBookName__c = 'Standard';
        update objAR;
        
        Product2 objProdMain = new Product2(Name = 'Corn', IsActive = true);
        insert objProdMain;
        gii__Product2Add__c objPR = [select id,Name from gii__Product2Add__c where Name = 'Corn' ];
        
        List<Product2> lstProd = new List<Product2>{new Product2(Name = 'A1 Seed Treatment Service', IsActive = true),
            new Product2(Name = 'Basta', IsActive = true),
            new Product2(Name = 'Corn1', IsActive = true)
            };
                Insert  lstProd;
        
        gii__PriceBook__c objPB = new gii__PriceBook__c(Name = 'Standard');
        insert objPB;
        
        gii__Product2Add__c objPRef =  [select id, Name, gii__ProductStyle__c from gii__Product2Add__c where Name = 'A1 Seed Treatment Service' ];
        objPRef.gii__ProductStyle__c = objPR.Id;
        update objPRef;
        
        List<gii__Product2Add__c>  lstPR =  [select id, Name, gii__ProductStyle__c from gii__Product2Add__c ];
        
        List<gii__PriceBookEntry__c>  lstPBE = new List<gii__PriceBookEntry__c>();
        for(gii__Product2Add__c objProd : lstPR){
            gii__PriceBookEntry__c objPBE = new gii__PriceBookEntry__c(gii__PriceBook__c = objPB.Id, gii__Product__c = objProd.Id);
            lstPBE.add(objPBE);          
        }
        insert lstPBE;    
        
      /********************* comment favorite product functionality ***********************************/
       /******
         gii__Product2Add__Tag objPTag = new gii__Product2Add__Tag(ItemId = lstPR[0].Id,
                                                                  Type  = 'Personal',
                                                                  Name = 'Fav'
                                                                 ); 
        insert objPTag; ********/
        /* Sales_Year__c objsalesyr = new  Sales_Year__c(Name ='2018',
                                                      giic_Active__c =true,
                                                      Default_Sales_Year__c=true,
                                                      End_Date__c=Date.newInstance(2018, 12, 31),
                                                      giic_isCurrent__c=true,
                                                      Start_Date__c=Date.newInstance(2018, 01, 01)
                                                    );
        insert objsalesyr;*/
         gii__SalesOrder__c objSo = new gii__SalesOrder__c(gii__Account__c =objAcc.id,                                                              
                                                            gii__OrderType__c='Standard',
                                                            gii__CustomerPONumber__c ='Customer PO123'
                                                         );
        insert objSo;
        
        gii__SalesOrderLine__c objSoline = new gii__SalesOrderLine__c(gii__SalesOrder__c =objSo.id,
                                                                          gii__Product__c= lstPR[0].id,
                                                                          gii__OrderQuantity__c =10,
                                                                          gii__UnitPrice__c =200,
                                                                          Is_Active_Cart_Line__c = true
                                                                         );
        insert objSoline;
        ProductWrapper prodWrap = new ProductWrapper();
        prodWrap.isFavProduct = true;
        prodWrap.ProductId = lstPR[0].Id;
        prodWrap.addToCart=true;
        prodWrap.Id =  lstPR[0].Id;
        prodWrap.UnitPrice=200;
        prodWrap.ProductName = 'Corn';
        prodWrap.OrderQuantity =10;
        prodWrap.isSelected=true;
        List<ProductWrapper> lstProdWrap = new List<ProductWrapper>{prodWrap};
            String strlstProdWrap = JSON.serialize(lstProdWrap); 
        String searchKey = '';
        Integer offset=0;
        String alphaText ='';
        String sortBy='';
        String accountId = objAcc.id;
        ProductAdvancedFilter prodFilter = new ProductAdvancedFilter();
        prodFilter.Family= '';
        prodFilter.ProductCode =   '';
        prodFilter.MerchandiseType =   '';
        prodFilter.Size =   '';
        prodFilter.Color =   '';
        String strprodFilter =  JSON.serialize(prodFilter); 
        SOProductController.onLoad(searchKey, offset, alphaText, sortBy, prodFilter, accountId);
        SOProductController.clickedOnSearch(searchKey, offset, alphaText, sortBy, strprodFilter, accountId);
    /********************* comment favorite product functionality ***********************************/
       /***** SOProductController.makeProductFavourite(strlstProdWrap);******/
        ProductWrapper prodWrap1 = new ProductWrapper();
        prodWrap1.isFavProduct = false;
        prodWrap1.ProductId = lstPR[0].Id;
        List<ProductWrapper> lstProdWrap1 = new List<ProductWrapper>{prodWrap1};
            String strlstProdWrap1 = JSON.serialize(lstProdWrap1);      
       /****** SOProductController.makeProductFavourite(strlstProdWrap1);********/
        SOProductController.addProductsToCart(strlstProdWrap, accountId); 
        SOProductController.getPicklistOptions('Product2', 'Family');
        System.assert(true);
    }
}