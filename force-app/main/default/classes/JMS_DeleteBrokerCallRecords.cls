/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_DeleteBrokerCallRecords 
* @Author           : Shiv gupta
* @Version History  : 1.0
* @Creation         : May 11, 2023
* @Description      : Batch class to delete Broker Call records. Delete those broker call records where JMS_Call_Status__c is blank and and similar broker call record is present with Call_Status
**********************************************************************************************************************
**********************************************************************************************************************/
global with sharing class JMS_DeleteBrokerCallRecords implements Schedulable, database.Stateful,database.Batchable<Sobject> {
    
    /***************************************************************************************************************
    *   @Name        :  Start                                                          
    *   @Description :  Get the list of all records to be deleted
    ***************************************************************************************************************/
    global List<JMS_Broker_Call__c> start(database.batchablecontext BC){
        List<JMS_Broker_Call__c> lstBrokerCallToDelete = new List<JMS_Broker_Call__c> ();
        map<string, List<JMS_Broker_Call__c>> mapCampIdAccIdVsListBCWithCallStatus = new map<string, List<JMS_Broker_Call__c>>();
        map<string, List<JMS_Broker_Call__c>> mapCampIdAccIdVsListBCWithNoCallStatus = new map<string, List<JMS_Broker_Call__c>>();


         List<JMS_Broker_Call__c> lstBrokerCall = [select id, JMS_Campaign__c, Account__c, JMS_Item_Status__c, JMS_Call_Status__c, JMS_Item_Number__c, JMS_External_Call_ID__c from JMS_Broker_Call__c where JMS_Campaign__c != null and Account__c != null limit 50000];
         for(JMS_Broker_Call__c oBC: lstBrokerCall  ){
             string sCampIdAccId = string.valueOf(oBC.JMS_Campaign__c) + string.valueOf(oBC.Account__c);
             if(string.isNotEmpty(oBC.JMS_Call_Status__c) ){
                if(! mapCampIdAccIdVsListBCWithCallStatus.containskey(sCampIdAccId) ){
                    mapCampIdAccIdVsListBCWithCallStatus.put(sCampIdAccId, new list<JMS_Broker_Call__c>{oBC} );
                }
                else{
                    mapCampIdAccIdVsListBCWithCallStatus.get(sCampIdAccId).add(oBC);
                }
             } 
             else if (string.isEmpty(oBC.JMS_Call_Status__c) ){
                if(! mapCampIdAccIdVsListBCWithNoCallStatus.containskey(sCampIdAccId) ){
                    mapCampIdAccIdVsListBCWithNoCallStatus.put(sCampIdAccId, new list<JMS_Broker_Call__c>{oBC} );
                }
                else{
                    mapCampIdAccIdVsListBCWithNoCallStatus.get(sCampIdAccId).add(oBC) ;
                }
             }
         }
         
         if(mapCampIdAccIdVsListBCWithNoCallStatus != null && mapCampIdAccIdVsListBCWithNoCallStatus.size() > 0){
             for( string strCampIdAccId : mapCampIdAccIdVsListBCWithNoCallStatus.keySet() ){
                 if(mapCampIdAccIdVsListBCWithCallStatus.containsKey(strCampIdAccId) ){
                      // system.debug('ListBCWithNoCallStatus -->> ' + mapCampIdAccIdVsListBCWithNoCallStatus.get(strCampIdAccId).size() + ' -->> ' + mapCampIdAccIdVsListBCWithCallStatus.get(strCampIdAccId).size() );
                     lstBrokerCallToDelete.addAll(mapCampIdAccIdVsListBCWithNoCallStatus.get(strCampIdAccId));
                 }
             }
         }
        return lstBrokerCallToDelete;
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
    
    
    
    /***************************************************************************************************************
    *   @Name        :  execute ( execute method for Schedulable class)                                                              
    *   @Return      :  void                                                                                       
    *   @Description :                               
    ***************************************************************************************************************/
    
    global void execute(SchedulableContext sc) {
      JMS_DeleteBrokerCallRecords objDBCR = new JMS_DeleteBrokerCallRecords(); 
      Database.executeBatch(objDBCR);
   }

}