public class JMS_LeadTriggerHandler extends JMS_TriggerHandler{
    
    private static final string LEAD_API = 'Lead';

    
    /**
    * @description : handler class
    */
    public JMS_LeadTriggerHandler() {
        super(LEAD_API);     
    } 
    
    /* To get the API name of the executing trigger context*/
    public override String getName() {
        return LEAD_API;
    }
    
    /**
    * @description before insert trigger event
    * @param newItems
    */ 
    public override  void beforeInsert(List<SObject> newItems) {
        JMS_LeadTriggerHelper.populateLeadStatus(newItems);
        JMS_LeadTriggerHelper.populateLeadOwner(newItems, null, null);
    }
    
    /* To invoke before update trigger logic */
    public  override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        JMS_LeadTriggerHelper.populateLeadOwner(newItems, null, oldItemsMap);
        JMS_LeadTriggerHelper.populateIACQueue(newItems, oldItemsMap);
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
        //JMS_LeadTriggerHelper.populateLeadOwner(null, null, oldItemsMap);
    }

    
    /* To invoke after insert trigger logic */
    public  override void afterInsert(List<SObject> newItems, Map<Id, SObject> oldItemsMap) {
    }

}