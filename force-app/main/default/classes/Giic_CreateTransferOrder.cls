public with sharing class Giic_CreateTransferOrder {
    @AuraEnabled(cacheable=true)
    public static string getDCWarehouse() {
        string dcWarehouseID='';
        gii__Warehouse__c dcwarehouse = [SELECT Id,Name FROM gii__Warehouse__c WHERE Name =:Label.giic_DCWarehouse limit 1 ];
        System.debug('dcwarehouse12345'+dcwarehouse);
        if(dcwarehouse!=null){
            dcWarehouseID= dcwarehouse.Id;
        }
        else{
            dcWarehouseID='';
        }
        return dcWarehouseID;
    }
    @AuraEnabled(cacheable=true)
    public static List<salesOrderLineDetailWrapper> getSalesOrderLines(String soId) {
        system.debug('soId::::'+soId);
        List<gii__SalesOrderLine__c> lstSOLine = [SELECT Id,Name,giic_Product__c,gii__Product__r.id, gii__Product__r.Name,gii__OrderQuantity__c,gii__BackOrderQuantity__c,gii__OpenQuantity__c,gii__SalesOrder__c,giic_TransferOrderQty__c,gii__SalesOrder__r.gii__RequiredDate__c,gii__SalesOrder__r.gii__Warehouse__c,gii__SalesOrder__r.gii__Warehouse__r.Id,gii__SalesOrder__r.gii__Account__c FROM gii__SalesOrderLine__c WHERE gii__SalesOrder__c =:soId and gii__LineStatus__c = 'Open' and gii__BackOrderQuantity__c > 0 ];
        system.debug('lstSOLine::::'+lstSOLine);
        List<salesOrderLineDetailWrapper> lstwrpSOLine = new List<salesOrderLineDetailWrapper>();
        for(gii__SalesOrderLine__c obj : lstSOLine){
            if(obj.Service_Ticket_Lines__r == null || obj.Service_Ticket_Lines__r.size() == 0){
            	salesOrderLineDetailWrapper wrpSOLine = new salesOrderLineDetailWrapper();
            	wrpSOLine.objSOLine = obj; 
                wrpSOLine.objSOLine.giic_TransferOrderQty__c=wrpSOLine.objSOLine.gii__BackOrderQuantity__c;
            	lstwrpSOLine.add(wrpSOLine);               
            }
        }
        return lstwrpSOLine;        
    }
    @AuraEnabled
    public static string createTransferOrder(List<salesOrderLineDetailWrapper> solList, String fromWarehouse, String toWarehouse, date requiredDate) {
       string returnVal='';
       system.debug('+++inside createTransferOrder apex method'+solList);
       system.debug('+++fromWarehouse'+fromWarehouse);
       system.debug('+++toWarehouse'+toWarehouse);
       system.debug('+++requiredDate'+requiredDate);
        gii__TransferOrder__c to=new gii__TransferOrder__c();
        List<gii__TransferOrderLine__c> toLinesList = new List<gii__TransferOrderLine__c>();
        gii__TransferOrderLine__c tol;
        //to.gii__Account__c = AccountId; //Account Id which is required.
        to.gii__Account__c = solList[0].objSOLine.gii__SalesOrder__r.gii__Account__c;
        to.gii__FromWarehouse__c = fromWarehouse;
        to.gii__TransferToWarehouse__c = ToWarehouse;
        to.gii__RequiredDate__c = requiredDate;
        to.gii__OrderDate__c = system.today();
        to.giic_SalesOrder__c = solList[0].objSOLine.gii__SalesOrder__r.id;
        insert to;
        
        for(salesOrderLineDetailWrapper  solwrap: solList ){
            if(solwrap.isSelected  ){
                tol = new gii__TransferOrderLine__c();
                tol.gii__TransferOrder__c = to.id;
                tol.gii__Quantity__c = solwrap.objSOLine.giic_TransferOrderQty__c;
                tol.gii__Product__c = solwrap.objSOLine.gii__Product__r.id;
                tol.gii__RequiredDate__c = requiredDate;
               // tol.gii_SalesOrder__c = solwrap.objSOLine.gii__SalesOrder__r.id;
                tol.giic_SalesOrderLine__c = solwrap.objSOLine.id;
                toLinesList.add(tol);
            }          
        }
        if(toLinesList.size()>0){
            insert toLinesList;
        }

        return to.id;
    }
    /*-----------Wrapper Class---------*/
    public class salesOrderLineDetailWrapper{
        @AuraEnabled
        public gii__SalesOrderLine__c objSOLine{get;set;}
        @AuraEnabled
        public Boolean isSelected{get;set;}

        public salesOrderLineDetailWrapper(){
            this.isSelected = false;
        }
    }
}