public class giic_HistoricalDemandQntCalHandlerBatch implements Database.Batchable<sObject>{
    public giic_HistoricalDemandQntCalHandlerBatch() {
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        Map<String, Schema.SObjectField> fieldMap = gii__ProductInventory__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        String query = ('SELECT ' + String.join(lstFieldNames, ',') + ' FROM gii__ProductInventory__c ');
        
        system.debug('query>>>>>'+query);
      return Database.getQueryLocator(query);
      
      /*return Database.getQueryLocator([select id,gii__Product__r.gii__ProductReference__r.Make__c,
                                         gii__Warehouse__r.name,gii__Product__r.gii__Family__c,
                                         gii__Product__c,gii__AvailableQuantity__c,
                                         giic_MinQtyCalculated__c,gii__InTransitQuantity__c,
                                         gii__PurchaseOrderQuantity__c, giic_SafetyStockCalculated__c,
                                         giic_MaxQtyCalculated__c,giic_NumberOfMonth__c,  
                                         giic_12MonthsDemand__c, giic_HistoricalSO__c, 
									     giic_HistoricalTO__c, giic_HistoricalWO__c 
                                         FROM gii__ProductInventory__c where id='a313C000000FdLrQAK']); */// where id='a313C000000FdLrQAK'
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
         giic_HistoricalDemandQntCalHandler objHandler = new giic_HistoricalDemandQntCalHandler();
                system.debug('objHandler>>'+objHandler);
        objHandler.getThequantityCount((List<gii__ProductInventory__c>)scope);  
        
    }
    
    public void finish(Database.BatchableContext BC){
    }
}