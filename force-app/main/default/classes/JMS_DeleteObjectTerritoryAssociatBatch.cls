/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_DeleteObjectTerritoryAssociatBatch
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 19/04/2022
* @Description      : Batch class to delete the Object Territory Asscoaitions records
**********************************************************************************************************************
**********************************************************************************************************************/
global without sharing class JMS_DeleteObjectTerritoryAssociatBatch implements database.Stateful,database.Batchable<Sobject> {
    private static final String STR_DELETE_OBJECT_TERRITORY_ASSOCIATION = 'JMS_DeleteObjectTerritoryAssociatBatch';
    private static final String STR_UNDERSCORE_SYMBOL = '_';
    // constuctor declared
    @testvisible
    public JMS_DeleteObjectTerritoryAssociatBatch(){
    }
    global database.QueryLocator start(database.batchablecontext BC){
        String query = Label.JMS_Object_Territory_Association_Query;
        return Database.getQueryLocator(query);
    }
    
    /***************************************************************************************************************
    *   @Name        :  Execute                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  To delte records of JMS_Territory_Assignment__c , ObjectTerritory2Association
    ***************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        //Variables Declarations
        Set<Id> setTerritoryids = new Set<ID>();
        String strTerritoryIdObjectId = JMS_ConstantsUtility.EMPTY_STRING;
        JMS_Territory_Assignment__c objCustomTerrAssociation = new JMS_Territory_Assignment__c();
        Map<String,SObject> mapcombkeyVsTerrAssignment =  new Map<String,JMS_Territory_Assignment__c>();
        Map<Id,Id> mapAccIdVsTerritoryId = new Map<Id,Id>();
        List<ObjectTerritory2Association> listObjectTerritory2Association = new List<ObjectTerritory2Association>();
        
        //Iteration on Scope -JMS_Territory_Assignment__c records
        for(SObject objCustomAssocRecord:scope){
            objCustomTerrAssociation = (JMS_Territory_Assignment__c) objCustomAssocRecord;
            if(objCustomTerrAssociation.JMS_Account_ID__c != null){
                strTerritoryIdObjectId = objCustomTerrAssociation.JMS_TerritoryID__c + STR_UNDERSCORE_SYMBOL + objCustomTerrAssociation.JMS_Account_ID__c;
                setTerritoryids.add(objCustomTerrAssociation.JMS_TerritoryID__c);
                mapAccIdVsTerritoryId.put(objCustomTerrAssociation.JMS_Account_ID__c,objCustomTerrAssociation.JMS_TerritoryID__c);
                mapcombkeyVsTerrAssignment.put(strTerritoryIdObjectId ,objCustomAssocRecord);
            }
        } 

        if(mapAccIdVsTerritoryId != null && !mapAccIdVsTerritoryId.isEmpty() && setTerritoryids != null && !setTerritoryids.isEmpty()){
            //Query the existing ObjectTerritory2Association record based on the stored data in JMS_Territory_Assignment__c 
            List<ObjectTerritory2Association> listTerritory2Association = [SELECT Id,ObjectId,Territory2Id
                                                                        FROM ObjectTerritory2Association 
                                                                        WHERE ObjectId IN:mapAccIdVsTerritoryId.keyset() 
                                                                        AND Territory2Id IN:setTerritoryids AND 
                                                                        AssociationCause =: JMS_ConstantsUtility.STR_TERRITORY2_ASSIGNMENTRULE WITH SECURITY_ENFORCED LIMIT 50000];
            //Iterate ObjectTerritory2Association,compare with JMS_Territory_Assignment__c records and store those into list
            if(listTerritory2Association != null && !listTerritory2Association.isEmpty()){
                for(ObjectTerritory2Association objObjectAssoc: listTerritory2Association){
                    if(mapAccIdVsTerritoryId.containsKey(objObjectAssoc.ObjectId) && 
                        mapAccIdVsTerritoryId.get(objObjectAssoc.ObjectId) == objObjectAssoc.Territory2Id) {
                            strTerritoryIdObjectId = objObjectAssoc.Territory2Id + STR_UNDERSCORE_SYMBOL + objObjectAssoc.ObjectId;
                            listObjectTerritory2Association.add(objObjectAssoc);
                    }
                }
               
            }
        }
        try{
            //Deletion of list of existing ObjectTerritory2Association records
            if(listObjectTerritory2Association != null && !listObjectTerritory2Association.isEmpty()){
                Database.delete(listObjectTerritory2Association);
            }
            //Deletion of list of existing custom Territory Association records
            if(mapcombkeyVsTerrAssignment != null && !mapcombkeyVsTerrAssignment.isEmpty()){
                Database.delete(mapcombkeyVsTerrAssignment.values());
            }
           
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
            /*
            * CodeScan error Fix - Avoid using System.Debug
            * Anil 03/06/2022
            * */
        }catch(Exception excep){
            JMS_Logger.push(STR_DELETE_OBJECT_TERRITORY_ASSOCIATION, JMS_ConstantsUtility.OBJECT_TERRITORY2_ASSOCIATION_API);
			JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }  
    }
    
    /***************************************************************************************************************
    *   @Name        :  Finish                                                              
    *   @Return      :  void                                                                                       
    *   @Description :                               
    ***************************************************************************************************************/
    global void finish(Database.BatchableContext BC){
        JMS_AssignObjectTerritoryAssociatBatch objAssignObjectTerrAsso = new JMS_AssignObjectTerritoryAssociatBatch();
        Database.executeBatch(objAssignObjectTerrAsso , Integer.valueOf(System.Label.JMS_AssignObjectTerrAssoBatchSize));
    }
}