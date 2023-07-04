public class JMS_TriggerDispatcher {
	/**
     * @description CR_TriggerDispatcher constructor
     */
    private JMS_TriggerDispatcher() {
    }
    private static Map<String, List<String>> recordsAlreadyProcessedByContext; 
    
    static {
        recordsAlreadyProcessedByContext = new Map<String, List<String>>();
    }
    
    /**
* @description Run methods check if the trigger is enabled and if the records have been executed in the context
* @param       handler
* @author     : Sachin Awati
* @date       : 18/02/2022
*/
    public static void run(JMS_TriggerHandler handler){
        
        if(handler != null){
            
            if (handler.isDisabled()){
                return;
            }
            
            if(wereObjectsAlreadyExecutedInContext(Trigger.new) && !(Trigger.isBefore && Trigger.isInsert)){
                return;
            }
            
            
            //pass complete Trigger context without filters
            switch on Trigger.operationType {
                when BEFORE_INSERT{
                    handler.beforeInsert(Trigger.new);
                }
                when AFTER_INSERT{
                    handler.afterInsert(Trigger.new, Trigger.newMap);
                }
                when BEFORE_UPDATE{
                    handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
                }
                when AFTER_UPDATE{
                    handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
                }
                when BEFORE_DELETE{
                    handler.beforeDelete(Trigger.oldMap);
                }
                when AFTER_DELETE{
                    handler.afterDelete(Trigger.oldMap);
                }
                when AFTER_UNDELETE{
                    handler.afterUndelete(Trigger.newMap);
                }
            }
        }
        
    }
    
    private static TriggerContext getTriggerContext(){
        TriggerContext context;
        
        if (Trigger.isBefore){
            if (Trigger.isInsert){
                context = TriggerContext.BEFORE_INSERT;
            }
            else if (Trigger.isUpdate){
                context = TriggerContext.BEFORE_UPDATE;
            }
            else if (Trigger.isDelete){
                context = TriggerContext.BEFORE_DELETE;
            }
        }    
        else if (Trigger.isAfter){
            if (Trigger.isInsert){
                context = TriggerContext.AFTER_INSERT;
            }
            else if (Trigger.isUpdate){
                context = TriggerContext.AFTER_UPDATE;
            }
            else if (Trigger.isDelete){
                context = TriggerContext.AFTER_DELETE;
            }
            else if (Trigger.isUndelete){
                context = TriggerContext.AFTER_UNDELETE;
            }
            
        }
        
        return context;
    }
    
    /**
* @description Validates whether the same list of records were already executed by this trigger in this context
* @param      objects
* @return boolean
*/
    private static Boolean wereObjectsAlreadyExecutedInContext(List<SObject> objects){
        String recordIdString = JMS_ConstantsUtility.EMPTY_STRING;
        
        if(objects != null){
            for(SObject obj : objects){
                recordIdString += obj.get(JMS_ConstantsUtility.RECORD_ID);
            }
            
            // Build a composite key from the trigger context and the object type
            String contextKey = getTriggerContext().name() + JMS_ConstantsUtility.SINGLE_DASH_STRING + objects.get(0).getSObjectType().getDescribe().getName();
            
            if(recordsAlreadyProcessedByContext.containsKey(contextKey)){
                for(String prevIdString : recordsAlreadyProcessedByContext.get(contextKey)){
                    if(prevIdString.equals(recordIdString)){
                        return true;
                    }
                }
                
                recordsAlreadyProcessedByContext.get(contextKey).add(recordIdString);
            }
            else{
                recordsAlreadyProcessedByContext.put(contextKey, new List<String>{recordIdString});
            }
        }
        
        return false;
    }
    
    /**
* @Author          : Sachin Awati
* @Date            : 18/02/2022
* @Description     : Enum object that will be used in the method skipObjectfromRecursiveCall  
**/     
    private enum TriggerContext {
        BEFORE_INSERT, 
            BEFORE_UPDATE, 
            BEFORE_DELETE,
            AFTER_INSERT, 
            AFTER_UPDATE, 
            AFTER_DELETE,
            AFTER_UNDELETE
            }
}