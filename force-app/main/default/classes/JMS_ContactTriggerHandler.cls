public class JMS_ContactTriggerHandler extends JMS_TriggerHandler{
	private static final string Contact_API = 'Contact';

    
    /**
    * @description : handler class
    */
    public JMS_ContactTriggerHandler() {
        super(Contact_API);     
    } 
    
    /* To get the API name of the executing trigger context*/
    public override String getName() {
        return Contact_API;
    }
     
    /* To invoke before insert trigger logic */
    public override  void beforeInsert(List<SObject> newItems) {
        JMS_ContactTriggerHelper.checkPrimaryContactInsert(newItems);
    }
    
    /* To invoke before update trigger logic */
    public  override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
		JMS_ContactTriggerHelper.checkPrimaryContactUpdate(newItems, newItemsMap, oldItemsMap);
    }
    
    /* To invoke before delete trigger logic */
    public  override void beforeDelete(Map<Id, SObject> oldItemsMap) {
        
        
    }
    
    /* To invoke after update trigger logic */
    public  override void afterUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
    }
    
    /* To invoke after delete trigger logic */
    public  override void afterDelete(Map<Id,SObject> oldItemsMap) {
        
    }
    
    /* To invoke after undelete trigger logic */
    public  override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }

    /* To invoke after insert trigger logic */
    public  override void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap) {
      
    }
}