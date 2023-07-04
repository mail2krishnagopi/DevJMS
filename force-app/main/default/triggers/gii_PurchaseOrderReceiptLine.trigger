trigger gii_PurchaseOrderReceiptLine on gii__PurchaseOrderReceiptLine__c (before insert) {
   /* if(trigger.isBefore && trigger.isInsert){
        for(gii__PurchaseOrderReceiptLine__c porlNew : trigger.new){
            porlNew.giic_IntegrationStatus__c = 'Submitted';
        }
    }*/
}