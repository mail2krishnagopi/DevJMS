public with sharing class SOPaymentController {
    @AuraEnabled
    public static PayWrapper getPaymentDetails(String accountId){
        System.debug('accountId:::' + accountId);
        PayWrapper objPayWrapper = new PayWrapper();
        try{
            if(accountId != null && accountId != ''){
                List<gii__AccountAdd__c> lstAR = [Select Id, gii__PaymentMethod__c, gii__BankName__c, gii__BankAccountNumber__c from gii__AccountAdd__c where gii__Account__c = :accountId];
                System.debug(':::::lstAR = ' + lstAR);
                if(!lstAR.isEmpty()){
                    objPayWrapper.Id = lstAR[0].Id; 
                    objPayWrapper.DefaultPaymentMethod = String.isEmpty(lstAR[0].gii__PaymentMethod__c) ? '' : lstAR[0].gii__PaymentMethod__c; 
                    objPayWrapper.BankName = lstAR[0].gii__BankName__c; 
                    objPayWrapper.BankAccNumber = lstAR[0].gii__BankAccountNumber__c; 
                }                
            }           
        }catch(exception ex){
            System.debug(':::::Exception = ' + ex.getMessage());
        } 
        System.debug('objPayWrapper:::' + objPayWrapper);
        return objPayWrapper;
    }
}