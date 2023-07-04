public with sharing abstract class JMS_TriggerHandler {
	private string soBJectName;

        
    /**
    * @description : handler class for Tast
    * @param sName
    */

    public JMS_TriggerHandler (String sName){
        this.soBJectName=sName;
    }
    
    /**********************************************************************************************
* @description : This method checks if the triggers are disabled for the running User by fetching the custom settings  triggerSettings                
* @author     : Sachin Awati
* @date       : 18/02/2022
* @return     : boolean value
**********************************************************************************************/
    public  Boolean isDisabled(){
        boolean isTriggerDisabledValue=false;
        // Check if All Triggers are disabled  
        try{
            JMS_Trigger_Manager__c triggerSettings = JMS_Trigger_Manager__c.getInstance(); 
            if(triggerSettings.JMS_Mute_All_Triggers__c != null && triggerSettings.JMS_Mute_All_Triggers__c){
                return true;
            }
            
            // Check if Trigger is enabled for the SObject 
            if(triggerSettings.JMS_Disabled_Objects__c != null ) {
                String [] objectArray = new List<String>();
                
                objectArray =  triggerSettings.JMS_Disabled_Objects__c.split(JMS_ConstantsUtility.SPLIT_BY_COMMA);
                
                // Check if SoBject type is present in disabled Trigger  List
                if(objectArray !=  null){
                    for(String sobjectVar:objectArray){
                        if(sobjectVar.equalsIgnoreCase(String.valueof(this.soBJectName))){
                            isTriggerDisabledValue=true;
                            break;
                        }
                        else {  
                            isTriggerDisabledValue=false;
                        }
                    }
                }
            }
        }catch(Exception ex){
            throw ex;
        }/**finally{
        }  **/
        return isTriggerDisabledValue;
    }
    
    /**********************************************************************************************
* @description : Set of trigger event Handlers to be implemented 
* @author     : Sachin Awati
* @return null
* @date       : 18/02/2022
**********************************************************************************************/    
    public  abstract String getName();
    
    /**
     * @description method for before insert
     * @param newItems
     */
    public  abstract void beforeInsert(List<SObject> newItems);

     /**
     * @description method for before Update
     * @param newItems
     * @param newItemsMap
     * @param oldItemsMap
     */
    public  abstract void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap);

    /**
     * @description method for before Delete
     * @param oldItemsMap
     */
    public  abstract void beforeDelete(Map<Id, SObject> oldItemsMap);

    /**
     * @description method for after Insert
     * @param newItems
     * @param newItemsMap
     */
    public  abstract void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap);

    /**
     * @description method for after Update
     * @param newItems
     * @param newItemsMap
     * @param oldItemsMap
     */
    public  abstract void afterUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap);

    /**
     * @description method for after Delete
     * @param oldItemsMap
     */
    public  abstract void afterDelete(Map<Id, SObject> oldItemsMap);

     /**
     * @description method for after Undelete
     * @param oldItemsMap
     */
    public  abstract void afterUndelete(Map<Id, SObject> oldItemsMap);
}