/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class giic_DistributeapInvoicetoServicetickets {
    @AuraEnabled(cacheable=true)
    public static List<ServiceWrapper> getServiceTicketLine(string apInvoiceId){
    try{
        Integer tollerPer = Integer.valueOf(system.Label.giic_AP_Invoice_Tolerance);
                
     /*   String userCurrency = UserInfo.getDefaultCurrency();
        System.debug('userCurrency' + userCurrency);
        
        Map<String, Decimal> currencyConversionRates = new Map<String, Decimal>();
        List<CurrencyType> currencies = [SELECT ConversionRate, IsoCode FROM CurrencyType];

        for (CurrencyType cur : currencies) {
            currencyConversionRates.put(cur.IsoCode, cur.ConversionRate);
        }
        
        System.debug('currencyConversionRates' + currencyConversionRates);
        */
        Set<Id> porlIds = new Set<Id>();
        system.debug('#####:: '+apInvoiceId);
        gii__APInvoice__c apInvoice = [SELECT Id,gii__Supplier__c,giic_Service_Ticket__c,convertCurrency(gii__DocumentAmount__c),Name 
                                            FROM gii__APInvoice__c
                                            WHERE Id=: apInvoiceId LIMIT 1];
        List<gii__VoucherDistribution__c> vchrDist = [SELECT Id,gii__APInvoice__c,gii__PurchaseOrderReceiptLine__c
                                                            FROM gii__VoucherDistribution__c 
                                                            WHERE gii__APInvoice__c  =: apInvoiceId ];
        
        system.debug('##### apInvSupId:: '+apInvoice.ID);
        for(gii__VoucherDistribution__c vchr : vchrDist){
            porlIds.add(vchr.gii__PurchaseOrderReceiptLine__c);
        }
        
        List<gii__PurchaseOrderReceiptLine__c> porlList = [SELECT Id,Name,convertCurrency(gii__UnvoucheredAmount__c),convertCurrency(gii__UnitPrice__c),gii__PurchaseOrderLine__c,gii__PurchaseOrderReceipt__c,gii__PurchaseOrderLine__r.Name, 
                                                           gii__PurchaseOrderLine__r.gii__ServiceTicketLine__r.gii__DateTimeClosed__c,
         													gii__PurchaseOrderLine__r.gii__ServiceTicketLine__r.Name,gii__PurchaseOrderLine__r.gii__ServiceTicket__r.Name,
        													 gii__PurchaseOrderLine__r.gii__ServiceTicketLine__r.gii__AssetReference__c,
                                                           gii__PurchaseOrderLine__r.gii__UnitCost__c,  gii__PurchaseOrder__r.Name,gii__PurchaseOrderLine__r.gii__ServiceTicketLine__r.gii__AssetReference__r.Name
                                                             FROM gii__PurchaseOrderReceiptLine__c
                                                             WHERE gii__PurchaseOrder__r.gii__Supplier__c =: apInvoice.gii__Supplier__c AND
                                                             gii__PurchaseOrder__r.gii__ServiceTicket__c =: apInvoice.giic_Service_Ticket__c AND 
                                                             gii__PurchaseOrderLine__c != null AND  
                                                             gii__PurchaseOrder__c != null AND 
                                                             gii__PurchaseOrderLine__r.gii__ServiceTicketLine__r.gii__AssetReference__c != null AND 
                                                             gii__UnvoucheredAmount__c != 0];
        
        ServiceWrapper[] serWrapList = new ServiceWrapper[]{};

        system.debug('porlList'+ porlList);

        for (gii__PurchaseOrderReceiptLine__c serviceLine : porlList) {
            if(!porlIds.contains(serviceLine.Id)){
            ServiceWrapper service = new ServiceWrapper();
            service.serviceLine = serviceLine;
            service.tolerancePer= tollerPer;
            service.docAmount = apInvoice.gii__DocumentAmount__c;
            serWrapList.add(service);
           }
        }
        system.debug('#####:: '+serWrapList);
        return serWrapList;
    }catch(exception e){
        system.debug(e.getmessage());
        return null;
    }
    }

    
@AuraEnabled
public static string createPoRecords(String recordJson,string apvirId,Boolean isForAppr) {
   
try{
ServiceWrapper[] serviceWrapList = new ServiceWrapper[] {};
serviceWrapList = (ServiceWrapper[])JSON.deserialize(recordJson, ServiceWrapper[].class);
System.debug('serviceWrapList'+serviceWrapList);
List<gii__PurchaseOrderReceiptLine__c> porlLst = new List<gii__PurchaseOrderReceiptLine__c>();
List<gii__VoucherDistribution__c> vcrDrLst = new List<gii__VoucherDistribution__c>();
for (ServiceWrapper serWrap : serviceWrapList) {
    gii__VoucherDistribution__c vcrObj = new gii__VoucherDistribution__c();
    vcrObj.gii__APInvoice__c = apvirId;
    vcrObj.gii__PurchaseOrderReceipt__c = serWrap.serviceLine.gii__PurchaseOrderReceipt__c;
    vcrObj.gii__PurchaseOrderReceiptLine__c = serWrap.serviceLine.Id;
  vcrObj.gii__VoucherAmount__c = serWrap.serviceLine.gii__UnvoucheredAmount__c;
    vcrObj.gii__VoucherQuantity__c	= serWrap.serviceLine.gii__UnvoucheredQuantity__c;
    
    
    vcrDrLst.add(vcrObj);
}
gii__APInvoice__c apinv = new gii__APInvoice__c();


apinv.Id = apvirId;
//apinv.giic_Integration_Status__c = 'Approved';
system.debug('###:: '+isForAppr);
if(!vcrDrLst.isEmpty()){
    insert vcrDrLst;
    if(isForAppr){
        submitForApproval(apvirId);
       // apinv.giic_Integration_Status__c = 'Submitted';
    }
    else{
        apinv.giic_Integration_Status__c = 'Submitted';
        apinv.giic_AP_Invoice_Status__c ='Approved';
    }
    update apinv;
}
return null;
}catch(exception e){
    system.debug('### get Line: '+e.getlinenumber()+'###'+e.getmessage());
    return 'Error';
}
}
public static void submitForApproval(string apinvid){  
    try{      
    // Create an approval request for  Opportunity        
    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
    req.setComments('Auto Submitting approval request.');        
    req.setObjectId(apinvid);
    req.setProcessDefinitionNameOrId('giic_AP_Invoice');
    req.setSkipEntryCriteria(true);
    // Submit the approval request for the Opportunity        
    Approval.ProcessResult result = Approval.process(req); 
    system.debug('###: '+result);  
    }catch(exception e){
        system.debug('### get Line: '+e.getlinenumber()+'###'+e.getmessage());
    }     
}     


    public class ServiceWrapper {
      
        @AuraEnabled
        public Integer tolerancePer;
        @AuraEnabled
        public gii__PurchaseOrderReceiptLine__c serviceLine;
        @AuraEnabled
        public Boolean isSelected;
         @AuraEnabled
        public decimal docAmount;
    }

    
    
}