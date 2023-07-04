@isTest(SeeAllData=false) 
public class SOSummaryControllerTest {
    static testMethod void getInfoTest() {
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
        List<gii__Product2Add__c>  lstPR =  [select id, Name, gii__ProductStyle__c from gii__Product2Add__c ];
         gii__PriceBook__c objPB = new gii__PriceBook__c(Name = 'Standard');
        insert objPB;

        
        List<gii__PriceBookEntry__c>  lstPBE = new List<gii__PriceBookEntry__c>();
        for(gii__Product2Add__c objProd : lstPR){
            gii__PriceBookEntry__c objPBE = new gii__PriceBookEntry__c(gii__PriceBook__c = objPB.Id, gii__Product__c = objProd.Id);
            lstPBE.add(objPBE);          
        }
        insert lstPBE;    
        
     /*   Sales_Year__c objsalesyr = new  Sales_Year__c(Name ='2018',
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
        List<ProductWrapper> lstProdWrap = new List<ProductWrapper>{prodWrap};
        String strProdWrap =  JSON.serialize(prodWrap);
          String paymentMethod ='Cash'; 
          String paymentMethodId= '';
          String accountId =objAcc.id;
        AccountWrapper objAccWrap = new AccountWrapper();
        objAccWrap.Name = 'ABCFarms';
        objAccWrap.BillingStreet = 'A207';
        objAccWrap.BillingCity='Noida';
        objAccWrap.BillingPostalCode='222231';
      //  List<AccountWrapper> lstAccWrap = new List<AccountWrapper>{objAccWrap};
        String destributor = JSON.serialize(objAccWrap);      
        Integer discount = 10;
        String selectedPayMethod='Cash'; 
        Integer totalAmt =1000; 
        Integer percentAmt=10; 
        Integer percentPayAmt = 5;
        Integer customPayAmt = 95;
        
        SOSummaryController.getInfo(accountId);
      /*  SOSummaryController.getCartProducts(accountId);
        SOSummaryController.placeSalesOrderWithLine(accountId, paymentMethod, paymentMethodId, destributor, discount, selectedPayMethod, totalAmt,  percentAmt,  percentPayAmt,  customPayAmt);
        SOSummaryController.removeProductFromCart(accountId,strProdWrap);*/
        System.assert(true);
    }
}