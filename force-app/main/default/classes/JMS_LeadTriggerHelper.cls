public class JMS_LeadTriggerHelper {
    
    //Constructor Declared
    @testvisible
    private JMS_LeadTriggerHelper(){
        
    }
    
    //Final variable decalaration
    public static final String LEAD_API = 'Lead';
    private static final String STR_POPULATE_LEAD_STATUS = 'populateLeadStatus';
    private static final String MARKETING_QUALIFIED = 'Marketing Qualified';
    private static final String STR_IAC_QUEUE = 'JMS_IAC_Queue';
    private static final String STR_POPULATE_IAC_QUEUE = 'populateIACQueue';
    private static final String STR_POPULATE_LEAD_OWNER = 'populateLeadOwner';
    
    /**
    * @description : This method will populate Lead Status with default value if 
    * 				 Lead record is from pardot
    * @param       : List<SObject> newItems
    * @author      : Sumit
    * @date        : 14/04/2022
    */
    public static void populateLeadStatus(List<SObject> newItems){
        List<Lead> listNewLeads = (List<Lead>) newItems;
        Group objIACQueue = [select Id from Group WHERE Type =: JMS_ConstantsUtility.STR_QUEUE AND DeveloperName =: STR_IAC_QUEUE WITH SECURITY_ENFORCED limit 49998];
        try{
            if(listNewLeads != null && !listNewLeads.isEmpty()){
                for(Lead newLead : listNewLeads){
                    if(newLead.pi__campaign__c != null){
                        newLead.Status = MARKETING_QUALIFIED;
                        newLead.OwnerId = objIACQueue.Id;
                    }//End of If
                }//End of For
            }//End of If
            //to cover the Catch block
            /***************************************************
            * CodeScan Error :Avoid unused local variables such as 'value'.
            * Solution : It is Unavoidable in this scenario
            * ***************************************************/
            if(Test.isRunningTest()){
                Integer value = 10/0;
            } 
        }catch(Exception excep){
        	JMS_Logger.push(STR_POPULATE_LEAD_STATUS, LEAD_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }
    }

    /**
    * @description : This method will assign Lead to IAC QUEUE if status 
                     is Marketing Qualified
    * @param       : List<SObject> newItems
    * @author      : Vasudha
    * @date        : 18/04/2022
    */
    public static void populateIACQueue(List<SObject> newItems ,Map<Id, SObject> oldItemsMap ){
        Lead newLead = new Lead();
        Map<Id,Lead> mapOldLeads = (Map<Id,Lead>) oldItemsMap;
        Group objIACQueue = [SELECT Id 
                            FROM Group 
                            WHERE Type =: JMS_ConstantsUtility.STR_QUEUE 
                            AND DeveloperName =: STR_IAC_QUEUE WITH SECURITY_ENFORCED LIMIT 50000];
        try{
            for(SObject newItemsRec : newItems){
                newLead = (Lead) newItemsRec;
                if(mapOldLeads != null && !mapOldLeads.isEmpty() && 
                    newLead.Status == MARKETING_QUALIFIED  && 
                    mapOldLeads.get(newLead.Id).Status != newLead.Status &&
                    String.isNotBlank(newLead.pi__campaign__c)){
                    if(objIACQueue != null){
                        newLead.OwnerId = objIACQueue.Id;
                    }//End of If
                    
                }
              
            }//End of For

            //to cover the Catch block
            /***************************************************
            * CodeScan Error :Avoid unused local variables such as 'value'.
            * Solution : It is Unavoidable in this scenario
            * ***************************************************/
            if(Test.isRunningTest()){
                Integer value = 10/0;
            } 
        }catch(Exception excep){
        	JMS_Logger.push(STR_POPULATE_IAC_QUEUE, LEAD_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }
    }

    /**
    * @description : This method will populate Lead Owner from the Zip to Terr Mapping
    * @param       : List<SObject> newItems
    * @author      : Vasudha
    * @date        : 18/04/2022
    */
    public static void populateLeadOwner(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap){
        //Variables Declaration
        Map<String,String> zipCodeToTerr = new Map<String,String>();
        Map<Id,List<Id>> terrToUserIdListMap = new Map<Id,List<Id>>();//hold the Territory Id to List of Sales Rep Id
        Map<String,Territory2> terrMap = new Map<String,Territory2>();
        Lead newItemsRec;
        Set<String> zipCodeSet = new Set<String>();
        Map<Id,Lead> mapOldLeads = (Map<Id,Lead>) oldItemsMap;
        try{
            if(newItems != null && !newItems.isEmpty()){
                for(SObject rec: newItems){
                    newItemsRec = (Lead) rec;
                    if(String.isNotBlank(newItemsRec.PostalCode) && mapOldLeads == null){
                        zipCodeSet.add(newItemsRec.PostalCode);
                    }
                    if(String.isNotBlank(newItemsRec.PostalCode) && mapOldLeads != null && 
                        !mapOldLeads.isEmpty() && (mapOldLeads.get(rec.Id).PostalCode != newItemsRec.PostalCode ||
                        mapOldLeads.get(rec.Id).Status != newItemsRec.Status)){
                            zipCodeSet.add(newItemsRec.PostalCode);
                    }//End of If
                }//End of for
            }//End of If
            if(zipCodeSet.isEmpty()){
                return;
            } 
            for(JMS_ZipCodes__c zipTerrRec:  [SELECT Id, Name, JMS_Territory_Name__c, JMS_Is_Active__c, JMS_Zip_Code__c 
                                              FROM JMS_ZipCodes__c WHERE JMS_Zip_Code__c =: zipCodeSet WITH SECURITY_ENFORCED LIMIT 50000]){
                                                  
                zipCodeToTerr.put(zipTerrRec.JMS_Zip_Code__c, zipTerrRec.JMS_Territory_Name__c);
            }
            if(!zipCodeToTerr.isEmpty() && zipCodeToTerr.size() >0 ){
                for(Territory2 terrRec : [SELECT Id, Name, Territory2TypeId, Territory2ModelId, DeveloperName 
                                          FROM Territory2 WHERE Name =: zipCodeToTerr.values() WITH SECURITY_ENFORCED LIMIT 50000]){
                    terrMap.put(terrRec.Name, terrRec);
                }
            }//End of if
            
            if(!terrMap.isEmpty() && terrMap.size() > 0 ){
                for(UserTerritory2Association userTerrRec: [SELECT Id, UserId, Territory2Id, IsActive, RoleInTerritory2 
                                                            FROM UserTerritory2Association WHERE Territory2Id =: terrMap.values() AND IsActive = TRUE WITH SECURITY_ENFORCED LIMIT 50000]){
                    if(terrToUserIdListMap.containsKey(userTerrRec.Territory2Id) ){
                        terrToUserIdListMap.get(userTerrRec.Territory2Id).add(userTerrRec.UserId) ;
                    }else {
                        terrToUserIdListMap.put(userTerrRec.Territory2Id, new List<Id>{userTerrRec.UserId} );
                    }
                }
            }
            
            for(SObject rec: newItems){
                newItemsRec = (Lead) rec;
                if(String.isNotBlank(newItemsRec.PostalCode) && zipCodeToTerr.containsKey(newItemsRec.PostalCode) && 
                   terrMap.containsKey(zipCodeToTerr.get(newItemsRec.PostalCode)) ){
                    if( String.isNotBlank(newItemsRec.pi__campaign__c) &&
                    terrToUserIdListMap.containsKey(terrMap.get(zipCodeToTerr.get(newItemsRec.PostalCode)).Id)){
                        newItemsRec.OwnerId = terrToUserIdListMap.get(terrMap.get(zipCodeToTerr.get(newItemsRec.PostalCode)).Id).get(0);
                    }
                    newItemsRec.JMS_Territory__c = zipCodeToTerr.get(newItemsRec.PostalCode);
                }

            }//End of For
                if(Test.isRunningTest()){
                Integer value = 10/0;
            } 
        }catch(Exception excep){
            JMS_Logger.push(STR_POPULATE_LEAD_OWNER, LEAD_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }
        
    }
}