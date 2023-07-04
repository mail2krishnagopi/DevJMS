trigger giic_SalesOrderLineTrigger on gii__SalesOrderLine__c (after insert, after update, after delete) {
    if(trigger.isAfter){
        List<gii__SalesOrderLine__c> lstSalesOrdLine = new List<gii__SalesOrderLine__c>();
        if(trigger.isUpdate){
            for(gii__SalesOrderLine__c obj : trigger.newMap.values()){
                system.debug('Inside trigger>>>>');
                if(trigger.oldMap.containsKey(obj.id) && trigger.oldMap.get(obj.id).gii__OrderQuantity__c != obj.gii__OrderQuantity__c ){
                    system.debug('Inside trigger>>>>2');
                    lstSalesOrdLine.add(obj);
                }
            }
            if(lstSalesOrdLine.size() > 0 ){
               // giic_SalesOrderLineTriggerHandler.updateProdInv(lstSalesOrdLine);
            }
        }
        else if(trigger.isInsert){
            system.debug('Inside trigger>>>>3');
           // giic_SalesOrderLineTriggerHandler.updateProdInv(trigger.new);
        }else if(trigger.isDelete){
            system.debug('Inside trigger>>>>4');
            //giic_SalesOrderLineTriggerHandler.updateProdInv(trigger.old);
        }        
    }
}