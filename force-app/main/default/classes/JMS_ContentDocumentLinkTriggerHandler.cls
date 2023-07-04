public class JMS_ContentDocumentLinkTriggerHandler extends JMS_TriggerHandler{
    
    private static final string CONTENT_DOCUMENT_LINK_API = 'ContentDocumentLink';

    
    /**
    * @description : handler class
    */
    public JMS_ContentDocumentLinkTriggerHandler() {
        super(CONTENT_DOCUMENT_LINK_API);     
    } 
    
    /* To get the API name of the executing trigger context*/
    public override String getName() {
        return CONTENT_DOCUMENT_LINK_API;
    }
    
    /**
    * @description before insert trigger event
    * @param newItems
    */ 
    public override  void beforeInsert(List<SObject> newItems) {
        JMS_ContentDocumentLinkTriggerHelper.beforeInsert(newItems,JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
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

    
    /* To invoke after elete trigger logic */
    public  override void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap) {
      
    }

}