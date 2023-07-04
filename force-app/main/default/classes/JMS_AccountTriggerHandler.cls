public class JMS_AccountTriggerHandler extends JMS_TriggerHandler{
    
    private static final string Account_API = 'Account';
    
    
    /**
    * @description : handler class
    */
    public JMS_AccountTriggerHandler() {
        super(Account_API);     
    } 
    
    /* To get the API name of the executing trigger context*/
    public override String getName() {
        return Account_API;
    }
    
    /**
    * @description before insert trigger event
    * @param newItems
    */ 
    public override  void beforeInsert(List<SObject> newItems) {
        JMS_AccountTriggerHelper.populateRecordTypeId(newItems);
    }
    
    /* To invoke before update trigger logic */
    public  override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        JMS_AccountTriggerHelper helper = new  JMS_AccountTriggerHelper();
        helper.restrictAccountFieldUpdates(newItems, newItemsMap, oldItemsMap);
        JMS_AccountTriggerHelper.populateRecordTypeId(newItems);
    }
    
    /* To invoke before delete trigger logic */
    public  override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    
    /* To invoke after update trigger logic */
    public  override void afterUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        JMS_AccountTriggerHelper.getAccountDetails(newItems , oldItemsMap , 'afterupdate');
        JMS_AccountTriggerHelper.initiateNewTerritoryAssignment(newItems, oldItemsMap);

    }
    
    /* To invoke after delete trigger logic */
    public  override void afterDelete(Map<Id, SObject> oldItemsMap) {
        JMS_AccountTriggerHelper.handleMergeOnDelete( oldItemsMap);
    }
    
    /* To invoke after undelete trigger logic */
    public  override void afterUndelete(Map<Id, SObject> oldItemsMap) {
        JMS_AccountTriggerHelper.getAccountDetails(null,oldItemsMap , 'afterundelete');
    }

    
    /* To invoke after insert trigger logic */
    public  override void afterInsert(List<SObject> newItems, Map<Id, SObject> oldItemsMap) {
    JMS_AccountTriggerHelper.initiateNewTerritoryAssignment(newItems,NULL);

    }

}