@isTest(SeeAllData=false)
public class SOCustomerControllerTest {
    static testMethod void getFilterAccountsTest() {
        String searchText ='TestingAccount';
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
        Account objAcc1 = new Account();
        objAcc1.Name='TestingAccount';
        objAcc1.ParentId=objAcc.id;
        insert objAcc1;
        String accountId = objAcc.id;
        String searchKeyWord='';
        String objectName='Account';
        Boolean isExternalUser = true;
        searchText = 'Te';
        AccountWrapper objAccWrap = new AccountWrapper();
        objAccWrap.Name = 'ABCFarms';
        objAccWrap.BillingStreet = 'A207';
        objAccWrap.BillingCity='Noida';
        objAccWrap.BillingPostalCode='222231';
        objAccWrap.ShippingStreet = 'sector 63';
        objAccWrap.ShippingCity = 'Noida';
        objAccWrap.ShippingPostalCode = '233415';
        objAccWrap.ShippingState = 'Up';
        objAccWrap.ShippingCountry = 'India';
        objAccWrap.Phone='98765432123';
       
        SOCustomerController.getFilterAccounts(searchText);
        SOCustomerController.getFilterDealerAccounts(accountId,searchText);
        SOCustomerController.getDealerAccounts(accountId);
        SOCustomerController.getInfo(accountId,isExternalUser);
        SOCustomerController.fetchAccounts(searchKeyWord,objectName);
        SOCustomerController.addNewAcc(objAcc);
        SOCustomerController.addNewDealer(objAcc,accountId,isExternalUser);
        SOCustomerController.editDistributorAccount(objAcc);
        System.assert(true);
    }
}