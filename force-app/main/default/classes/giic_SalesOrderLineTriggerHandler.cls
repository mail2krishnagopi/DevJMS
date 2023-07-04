public with sharing class giic_SalesOrderLineTriggerHandler {
    public giic_SalesOrderLineTriggerHandler() {

    }
    public static void updateProdInv(List<gii__SalesOrderLine__c> lstSalesOrdLine){
        Set<String> setWarehouseId = new Set<String>();
        Set<String> setProdInvId = new Set<String>();
        Map<String,String> mapProdAndProdInv = new Map<String,String>();
        Map<String,String> mapProdAndCount = new Map<String,String>();
        Map<String,Integer> mapProdInvAndCount = new Map<String,Integer>();
        for(gii__SalesOrderLine__c objLine : lstSalesOrdLine){
            setWarehouseId.add(objLine.gii__Warehouse__c);
            setProdInvId.add(objLine.gii__ProductInventory__c);
            mapProdAndProdInv.put(objLine.gii__Product__c,objLine.gii__ProductInventory__c);
        }
        for(gii__SalesOrderLine__c objSaleLine : [Select id,gii__OrderQuantity__c,gii__Product__c from gii__SalesOrderLine__c where gii__Warehouse__c IN: setWarehouseId AND gii__ProductInventory__c IN: setProdInvId and gii__ScheduledDate__c >= LAST_N_MONTHS:12]){// >= LAST_YEAR
            if(mapProdAndCount.containsKey(objSaleLine.gii__Product__c)){
                Integer count = Integer.valueOf(mapProdAndCount.get(objSaleLine.gii__Product__c).substringBefore('&'))+1;
                //system.debug('count>>>>>>>>1 '+count);
                Decimal quantity = Decimal.valueOf(mapProdAndCount.get(objSaleLine.gii__Product__c).substringAfter('&')) + objSaleLine.gii__OrderQuantity__c;
                //system.debug('count>>>>>>>>2 '+quantity);
                mapProdAndCount.put(objSaleLine.gii__Product__c,String.valueOf(count)+'&'+String.valueOf(quantity));
                system.debug('count>>>>>>>>3 '+mapProdAndCount);
            }else{
                Integer count = 1;  
                mapProdAndCount.put(objSaleLine.gii__Product__c,String.valueOf(count)+'&'+String.valueOf(objSaleLine.gii__OrderQuantity__c));
                system.debug('count>>>>>>>>4 '+mapProdAndCount);
            } 
        } 
        for(String prod : mapProdAndCount.keySet()){
            if(Integer.valueOf(mapProdAndCount.get(prod).substringBefore('&')) >= 3){
                mapProdInvAndCount.put(mapProdAndProdInv.get(prod),Integer.valueOf(mapProdAndCount.get(prod).substringAfter('&')));
                system.debug('count>>>>>>>>5 '+mapProdInvAndCount);
            }
        }
        if(mapProdInvAndCount.size() > 0){
            demandOnprodInv(mapProdInvAndCount);
        }
    }
    public static void demandOnprodInv(Map<String,Integer> mapProdInvAndCount){
        try{
            List<gii__ProductInventory__c> lstProdInv = new List<gii__ProductInventory__c>();
            for(gii__ProductInventory__c objInv : [Select id,giic_12MonthsDemand__c from gii__ProductInventory__c where id IN: mapProdInvAndCount.keySet()]){
                objInv.giic_12MonthsDemand__c = mapProdInvAndCount.get(objInv.id);
                lstProdInv.add(objInv);
            }
            system.debug('count>>>>>>>>6 '+lstProdInv.size());
            system.debug('count>>>>>>>>7 '+lstProdInv);
            if(lstProdInv.size() > 0){
                update lstProdInv;
            }
        }
        catch(exception e){
            system.debug('Error occured due to '+e.getMessage());
        }
    }
}