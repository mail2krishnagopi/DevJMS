public class JMS_Product2TriggerHandler extends JMS_TriggerHandler {
	private static final string Product2_API = 'Product2';

    
    /**
    * @description : handler class
    */
    public JMS_Product2TriggerHandler() {
        super(Product2_API);     
    } 
    
    /* To get the API name of the executing trigger context*/
    public override String getName() {
        return Product2_API;
    }
     
    /* To invoke before insert trigger logic */
    public override  void beforeInsert(List<SObject> newItems) {
        JMS_Product2TriggerHelper.defaultActiveProduct(newItems);
        JMS_Product2TriggerHelper.updateProduct(newItems);
    }
    
    /* To invoke before update trigger logic */
    public  override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        JMS_Product2TriggerHelper.updateProduct(newItems);
    }
    
    /* To invoke before delete trigger logic */
    public  override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    
    /* To invoke after update trigger logic */
    public  override void afterUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
    }
    
    /* To invoke after delete trigger logic */
    public  override void afterDelete(Map<Id, SObject> oldItemsMap) {
    }
    
    /* To invoke after undelete trigger logic */
    public  override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }

    /* To invoke after insert trigger logic */
    public  override void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap) {
    	JMS_Product2TriggerHelper.createPriceBookEntry(newItems);
    }
}