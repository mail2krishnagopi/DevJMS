public class JMS_CampaignTargetStagingTriggerHandler extends JMS_TriggerHandler{
	    private static final string Campaign_Target_API = 'JMS_Campaign_Target_Staging__c';

    
    /**
    * @description : handler class
    */
    public JMS_CampaignTargetStagingTriggerHandler() {
        super(Campaign_Target_API);     
    } 
    
    /* To get the API name of the executing trigger context*/
    public override String getName() {
        return Campaign_Target_API;
    }
    
    /**
    * @description before insert trigger event
    * @param newItems
    */ 
    public override  void beforeInsert(List<SObject> newItems) {
		JMS_CampaignTargetStagingTriggerHelper.updateStatusErrorForAWS(newItems);
    }
    
    /* To invoke before update trigger logic */
    public  override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {



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