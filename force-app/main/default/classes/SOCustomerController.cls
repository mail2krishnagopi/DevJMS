public with sharing class SOCustomerController {
    @AuraEnabled
    public static PlaceOrderWrapper getFilterAccounts(String searchText){ 
        
        PlaceOrderWrapper objPOWrapper = new PlaceOrderWrapper();   
        try{   
            if(searchText != null && searchText!= ''){
                String accId = getAccId();            
                objPOWrapper.lstChild.addAll(getFilterDealerAccounts(accId, searchText)); 
            }else{
                return getInfo('',true);
            } 
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage());
        }       
        return objPOWrapper; 
    }
    @AuraEnabled
    public static List<AccountWrapper> getFilterDealerAccounts(String accountId, String searchText){        
        System.debug(':::::accountId = ' + accountId);
        System.debug(':::::searchText = ' + searchText);
        List<AccountWrapper> lstDlrAcc = new List<AccountWrapper>();
        try{
            String searchKey = '%' + searchText + '%'; 
            List<Account>  lstAcc  = (List<Account>)[FIND :searchText IN ALL FIELDS RETURNING Account(id, Name, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry, 
                                                                                                      BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, Phone Where ParentId = :accountId )][0];
            System.debug(':::::lstAcc=' + lstAcc);
            if(!lstAcc.isEmpty()){
                for(Account acc : lstAcc){
                    AccountWrapper objACWrapper = new AccountWrapper();  
                    objACWrapper.Id = acc.Id;
                    objACWrapper.Name =  acc.Name;
                    objACWrapper.ShippingStreet =  acc.ShippingStreet == null ? '' : acc.ShippingStreet;
                    objACWrapper.ShippingCity =  acc.ShippingCity == null ? '' : acc.ShippingCity;
                    objACWrapper.ShippingPostalCode =  acc.ShippingPostalCode == null ? '' : acc.ShippingPostalCode;
                    objACWrapper.ShippingState =  acc.ShippingState == null ? '' : acc.ShippingState;
                    objACWrapper.ShippingCountry =  acc.ShippingCountry == null ? '' : acc.ShippingCountry;
                    objACWrapper.BillingStreet =  acc.BillingStreet == null ? '' : acc.BillingStreet;
                    objACWrapper.BillingCity =  acc.BillingCity == null ? '' : acc.BillingCity;
                    objACWrapper.BillingPostalCode =  acc.BillingPostalCode == null ? '' : acc.BillingPostalCode;
                    objACWrapper.BillingState =  acc.BillingState == null ? '' : acc.BillingState;
                    objACWrapper.BillingCountry =  acc.BillingCountry == null ? '' : acc.BillingCountry;
                    objACWrapper.Phone = acc.Phone;
                   
                    lstDlrAcc.add(objACWrapper);
                }
            }
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage());
        }   
        return lstDlrAcc; 
    }    
    @AuraEnabled
    public static PlaceOrderWrapper getInfo(String accountId, Boolean isExternalUser){ 
        System.debug(':::::accountId = ' + accountId);
        PlaceOrderWrapper objPOWrapper = new PlaceOrderWrapper();   
        try{        
            if(isExternalUser){
                String accId = getAccId();            
                objPOWrapper.lstChild.addAll(getDealerAccounts(accId));                
            }else{
                objPOWrapper.lstChild.addAll(getDealerAccounts(accountId));
            }
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage());
        }       
        return objPOWrapper;   
    }
    @AuraEnabled
    public static String getAccId(){ 
        User user = [select Id, Name, ContactId from User where Id = :UserInfo.getUserId() LIMIT 1];
        Contact con = [Select Id, AccountId from Contact Where Id = :user.ContactId]; 
        return con.AccountId;
    }
    @AuraEnabled
    public static List<AccountWrapper> getDealerAccounts(String accountId){        
        System.debug(':::::accountId = ' + accountId);
        List<AccountWrapper> lstDlrAcc = new List<AccountWrapper>();
        try{
            String searchQuery = 'Select gii__Account__c, gii__Account__r.Name, gii__Account__r.Phone, gii__Account__r.ShippingStreet, gii__Account__r.ShippingCity, gii__Account__r.ShippingPostalCode, gii__Account__r.ShippingState, gii__Account__r.ShippingCountry, gii__Account__r.BillingStreet, gii__Account__r.BillingCity, gii__Account__r.BillingPostalCode, gii__Account__r.BillingState, gii__Account__r.BillingCountry, gii__TaxLocation__c from gii__AccountAdd__c Where gii__Account__r.parentid = \''+ accountId +'\'';             
            System.debug(':::::searchQuery = ' + searchQuery); 
            List<gii__AccountAdd__c>  lstAcc = (List<gii__AccountAdd__c>)Database.query(searchQuery);       
            System.debug(':::::lstAcc=' + lstAcc);
            if(!lstAcc.isEmpty()){
                for(gii__AccountAdd__c acc : lstAcc){
                    AccountWrapper objACWrapper = new AccountWrapper();  
                    objACWrapper.Id = acc.gii__Account__c;
                    objACWrapper.Name =  acc.gii__Account__r.Name;
                    objACWrapper.ShippingStreet =  acc.gii__Account__r.ShippingStreet == null ? '' : acc.gii__Account__r.ShippingStreet;
                    objACWrapper.ShippingCity =  acc.gii__Account__r.ShippingCity == null ? '' : acc.gii__Account__r.ShippingCity;
                    objACWrapper.ShippingPostalCode =  acc.gii__Account__r.ShippingPostalCode == null ? '' : acc.gii__Account__r.ShippingPostalCode;
                    objACWrapper.ShippingState =  acc.gii__Account__r.ShippingState == null ? '' : acc.gii__Account__r.ShippingState;
                    objACWrapper.ShippingCountry =  acc.gii__Account__r.ShippingCountry == null ? '' : acc.gii__Account__r.ShippingCountry;
                    objACWrapper.BillingStreet =  acc.gii__Account__r.BillingStreet == null ? '' : acc.gii__Account__r.BillingStreet;
                    objACWrapper.BillingCity =  acc.gii__Account__r.BillingCity == null ? '' : acc.gii__Account__r.BillingCity;
                    objACWrapper.BillingPostalCode =  acc.gii__Account__r.BillingPostalCode == null ? '' : acc.gii__Account__r.BillingPostalCode;
                    objACWrapper.BillingState =  acc.gii__Account__r.BillingState == null ? '' : acc.gii__Account__r.BillingState;
                    objACWrapper.BillingCountry =  acc.gii__Account__r.BillingCountry == null ? '' : acc.gii__Account__r.BillingCountry;
                    objACWrapper.Phone = acc.gii__Account__r.Phone;
                 
                    lstDlrAcc.add(objACWrapper);
                }
            }
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage());
        }   
        return lstDlrAcc; 
    }
    @AuraEnabled
    public static Account editDistributorAccount(Account destributorAcc){
        System.debug(':::::destributorAcc=' + destributorAcc);   
        try{
            update destributorAcc;            
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage()); 
        }
        return destributorAcc;
    }
    
    @AuraEnabled
    public static PlaceOrderWrapper addNewDealer(Account newDealer, String accountId, Boolean isExternalUser ){
        System.debug(':::::newDealer=' + newDealer);   
        try{
            if(isExternalUser){
                newDealer.ParentId = getAccId();                 
            }else{ newDealer.ParentId = accountId;  }    
            
            newDealer.BillingStreet      = newDealer.ShippingStreet;
            newDealer.BillingCity        = newDealer.ShippingCity;
            newDealer.BillingState       = newDealer.ShippingState;
            newDealer.BillingCountry     = newDealer.ShippingCountry;
            newDealer.BillingPostalCode  = newDealer.ShippingPostalCode;
            insert newDealer;            
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage()); 
        }
        return getInfo(accountId, isExternalUser);
    }
    @AuraEnabled
    public static Account addNewAcc(Account newDealer){
        System.debug(':::::newDealer=' + newDealer);   
        try{    
            newDealer.BillingStreet      = newDealer.ShippingStreet;
            newDealer.BillingCity        = newDealer.ShippingCity;
            newDealer.BillingState       = newDealer.ShippingState;
            newDealer.BillingCountry     = newDealer.ShippingCountry;
            newDealer.BillingPostalCode  = newDealer.ShippingPostalCode;
            insert newDealer;            
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage()); 
        }
        return newDealer;
    }
    
    @AuraEnabled
    public static List<sObject> fetchAccounts(String searchKeyWord, String objectName) {
        List <sObject> returnList = new List <sObject> ();
        
        String searchKey = '%' + searchKeyWord + '%'; 
        returnList = (List<Account>)[FIND :searchKeyWord IN ALL FIELDS RETURNING Account(id, Name, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry, 
                                                                                         BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, Phone )][0];
        //    String sQuery = 'select id, Name from ' + objectName + ' where (Name LIKE :searchKey or AccountNumber LIKE :searchKey or Phone LIKE :searchKey) order by createdDate DESC limit 5';
        
        //  returnList = Database.query(sQuery);        
        System.debug('returnList:::' + returnList);
        return returnList;        
    }
}