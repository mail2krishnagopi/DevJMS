public with sharing class giic_DemandOrderCreationBatch implements Database.Batchable<sObject>{
    public giic_DemandOrderCreationBatch() {

    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        Map<String, Schema.SObjectField> fieldMap = gii__ProductInventory__c.sObjectType.getDescribe().fields.getMap();
    	Set<String> setFieldNames = fieldMap.keySet();
    	list<String> lstFieldNames = new List<String>(setFieldNames);
    String query = ('SELECT ' + String.join(lstFieldNames, ',') + ' FROM gii__ProductInventory__c ');
       
     system.debug('query>>>>>'+query);
       return Database.getQueryLocator(query);
       
           /* return Database.getQueryLocator([select id,gii__Product__r.gii__ProductReference__r.Make__c,
                                              gii__Warehouse__r.name,gii__Product__r.gii__Family__c,
                                              gii__Product__c,gii__AvailableQuantity__c,gii__SupplyPlanEnabled__c,
                                             giic_MinQtyCalculated__c,gii__InTransitQuantity__c,
                                             gii__PurchaseOrderQuantity__c, giic_SafetyStockCalculated__c,
                                             giic_MaxQtyCalculated__c FROM gii__ProductInventory__c
                                             where id='a313C000000FdLrQAK']);*/ // where a313C000000FdLrQAK  id='a313C000000FdLrQAK'*/
     }
  
     public void execute(Database.BatchableContext BC, List<sObject> scope){
        giic_ProductInventoryTrgHandler objHandler = new giic_ProductInventoryTrgHandler();
         system.debug('objHandler>>'+objHandler);
        objHandler.createDemandOrder((List<gii__ProductInventory__c>)scope);  
        /*List<List<gii__DemandOrder__c>> lstDmdOrder = objHandler.createDemandOrder((List<gii__ProductInventory__c>)scope);  
        system.debug('scope>>>>>>'+lstDmdOrder.size());
        system.debug('scope>>>>>>1 '+lstDmdOrder[0].size());
        system.debug('scope>>>>>>2 '+lstDmdOrder[1].size());
        try{
            if(lstDmdOrder[0].size() > 0){
                insert lstDmdOrder[0];
            }else if(lstDmdOrder[1].size() > 0){
                update lstDmdOrder[1];
            }
                 
        }
        catch(exception e){
            system.debug('Error occured in the giic_DemandOrderCreationBatch due to '+e.getMessage());
        }*/
        

       // system.debug('scope>>>>>>11'+lstDmdOrder[0]);
       // system.debug('scope>>>>>>11'+lstDmdOrder[1]);
      // for(sobject s : scope){
       //s.put(Field,Value); 
       //}
       //update scope;
      }
  
     public void finish(Database.BatchableContext BC){
     }
}