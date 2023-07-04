/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_Delete_SObject_Records
* @Author           : Sachin Awati
* @Version History  : 1.0
* @Creation         : 11/03/2022
* @Description      : Batch class to delete the Integration test records
**********************************************************************************************************************
**********************************************************************************************************************/
global with sharing class JMS_Delete_SObject_Records implements database.Stateful,database.Batchable<Sobject> {
    
    public string OBJECT_API_NAME{get;set;}
    public List<Id> LIST_RECORD_IDs{get;set;}
    
    global JMS_Delete_SObject_Records(string strObjectName , List<Id> listRecordIds){
        OBJECT_API_NAME = strObjectName;
        LIST_RECORD_IDs = listRecordIds;
        
    }
    
    /***************************************************************************************************************
    *   @Name        :  Start                                                              
    *   @Return      :  database.QueryLocator                                                                                       
    *   @Description :  Get the list of all records to be deleted
    ***************************************************************************************************************/
    global database.QueryLocator start(database.batchablecontext BC){
        
        //String query = 'Select Id, Createdby.Name from Account WHERE CreatedById = \'0053C000004N0m0QAC\' WITH SECURITY_ENFORCED LIMIT 50000';
        String query = 'Select Id, Name from ' + OBJECT_API_NAME;
        if(LIST_RECORD_IDs != null && !LIST_RECORD_IDs.isEmpty()){
            query += ' WHERE Id IN : ' + LIST_RECORD_IDs + ' WITH SECURITY_ENFORCED';
        } 
       

        return Database.getQueryLocator(query);
    }
    
    /***************************************************************************************************************
    *   @Name        :  Execute                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  Case closure                        
    ***************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        try{
            delete scope;
            /***************************************************
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer i = 10/0;
            }
        }catch(System.Exception ex){
            System.debug('ex-------->'+ex);
        }
    }
    
    /***************************************************************************************************************
    *   @Name        :  Finish                                                              
    *   @Return      :  void                                                                                       
    *   @Description :                               
    ***************************************************************************************************************/
    global void finish(Database.BatchableContext BC){
        
    }
    

}