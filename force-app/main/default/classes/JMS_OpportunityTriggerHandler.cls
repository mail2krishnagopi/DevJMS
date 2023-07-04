public class JMS_OpportunityTriggerHandler extends JMS_TriggerHandler{
    private static final string Opportunity_API = 'Opportunity';

    
    /**
    * @description : handler class
    */
    public JMS_OpportunityTriggerHandler() {
        super(Opportunity_API);     
    } 
    
    /* To get the API name of the executing trigger context*/
    public override String getName() {
        return Opportunity_API;
    }
    
    /**
    * @description before insert trigger event
    * @param newItems
    */ 
    public override  void beforeInsert(List<SObject> newItems) {
        JMS_OpportunityTriggerHelper.updatingOpportunityOwner(newItems);
        JMS_OpportunityTriggerHelper.validateOppStageClosedWon(newItems,null);
    }
    
    /* To invoke before update trigger logic */
    public  override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        JMS_OpportunityTriggerHelper.validateOppStageClosedWon(newItems,oldItemsMap);
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
    public  override void afterInsert(List<SObject> newItems, Map<Id, SObject> oldItemsMap) {
        
   

    }
}