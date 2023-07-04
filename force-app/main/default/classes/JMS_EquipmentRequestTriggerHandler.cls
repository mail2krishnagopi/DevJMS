public class JMS_EquipmentRequestTriggerHandler extends JMS_TriggerHandler{
    
    private static final string EQUIPMENT_REQUEST_API = 'JMS_Equipment_Request__c';
    public static Boolean isRun = true;
    
    /**
    * @description : handler class
    */
    public JMS_EquipmentRequestTriggerHandler() {
        super(EQUIPMENT_REQUEST_API);     
    } 
    
    /* To get the API name of the executing trigger context*/
    public override String getName() {
        return EQUIPMENT_REQUEST_API;
    }
    
    /**
    * @description before insert trigger event
    * @param newItems
    */ 
    public override  void beforeInsert(List<SObject> newItems) {
        JMS_EquipmentRequestTriggerHelper.populateOppAccount(newItems);
        JMS_EquipmentRequestTriggerHelper.checkEIUserUpdateForgeId(newItems,null);
    }
    
    /* To invoke before update trigger logic */
    public  override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        JMS_EquipmentRequestTriggerHelper.populateOppAccount(newItems);
        
        JMS_EquipmentRequestTriggerHelper.resetApprovedFieldsByApprovers(newItems,oldItemsMap);
        JMS_EquipmentRequestTriggerHelper.checkEIUserUpdateForgeId(newItems,oldItemsMap);
        JMS_EquipmentRequestTriggerHelper.updateRecordType(newItems,oldItemsMap);
    }
    
    /* To invoke before delete trigger logic */
    public  override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    
    /* To invoke after update trigger logic */
    public  override void afterUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        if(isRun == true){
            JMS_EquipmentRequestTriggerHelper.initiateApprovalProcess(newItems,oldItemsMap);
            JMS_EquipmentRequestTriggerHelper.initiateEmailNotificationRequest(newItems,oldItemsMap);
            JMS_EquipmentRequestTriggerHelper.customNotificationToOwner(newItems,oldItemsMap);
            isRun =  false;
        }
        
    }
    
    /* To invoke after delete trigger logic */
    public  override void afterDelete(Map<Id, SObject> oldItemsMap) {
    }
    
    /* To invoke after undelete trigger logic */
    public  override void afterUndelete(Map<Id, SObject> oldItemsMap) {
        
    }
    
    /* To invoke after insert trigger logic */
    public  override void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap) {
      
    }

}