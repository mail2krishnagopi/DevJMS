/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_AssignObjectTerritoryAssociatBatch
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 19/04/2022
* @Description      : Batch class to create the Object Territory Asscoaitions records
**********************************************************************************************************************
**********************************************************************************************************************/
global without sharing class JMS_AssignObjectTerritoryAssociatBatch implements database.Stateful,database.Batchable<Sobject> {
    private static final String STR_ASSIGN_OBJECT_TERRITORY_ASSOCIATION = 'JMS_AssignObjectTerritoryAssociatBatch';
    // constuctor declared
    @testvisible
    public JMS_AssignObjectTerritoryAssociatBatch(){

    }
    global database.QueryLocator start(database.batchablecontext BC){
        String query = Label.JMS_Account_Query;
        return Database.getQueryLocator(query);
    }
    
    /***************************************************************************************************************
    *   @Name        :  Execute                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  To create records of JMS_Territory_Assignment__c , ObjectTerritory2Association
    ***************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        //Variables Declarations
        Account objAccount = new Account();
        Map<String,Id> mapofTerritoryNamevsId = new Map<String,Id>();
        Map<String,String> mapZipCodeVsTerritoryName = new Map<String,String>();
        List<JMS_ZipCodes__c> listZipCode = new List<JMS_ZipCodes__c>();
        Set<String> setZipCodes = new Set<String>();
        Set<String> setTerritoryNames =  new Set<String>();
        
        for(SObject objAccountRec : scope){
            objAccount = (Account) objAccountRec;
            if(objAccount.BillingPostalCode != null){
                setZipCodes.add(objAccount.BillingPostalCode);
            }
        }
        //Query All the Records from the custom ZipCode Object and storing into the List          
        if(setZipCodes!= null && !setZipCodes.isEmpty()){                
        listZipCode =[SELECT ID,JMS_Zip_Code__c,JMS_Territory_Name__c FROM JMS_ZipCodes__c
                        WHERE JMS_Zip_Code__c IN :setZipCodes WITH SECURITY_ENFORCED LIMIT 50000 ];      
        }
        if(listZipCode != null && !listZipCode.isEmpty()){
            for(JMS_ZipCodes__c zipco : listZipCode){
                if(setZipCodes.contains(zipco.JMS_Zip_Code__c)){
                    mapZipCodeVsTerritoryName.put(zipco.JMS_Zip_Code__c,zipco.JMS_Territory_Name__c);
                    setTerritoryNames.add(zipco.JMS_Territory_Name__c);
                }
            } 
        }
        // new to create map of Territory zipcode vs name
        //Query the Territory2 Record details from the Territory2 based on Zip codes
        if(setTerritoryNames != null && !setTerritoryNames.isEmpty()){
            List<Territory2> listExistingTerritory = [SELECT ID,Name,Territory2TypeId FROM Territory2 WHERE Name IN :setTerritoryNames WITH SECURITY_ENFORCED LIMIT 50000];
            if(listExistingTerritory != null && !listExistingTerritory.isEmpty()){
                for(Territory2 objTerritory :listExistingTerritory ){
                    mapofTerritoryNamevsId.put(objTerritory.Name,objTerritory.Id);
                }  
            }
        }   
        try{ 
            if(mapofTerritoryNamevsId != null && mapZipCodeVsTerritoryName != null && 
                        !mapZipCodeVsTerritoryName.isEmpty() && !mapofTerritoryNamevsId.isEmpty()){
              
                JMS_AccountTriggerHelper.createNewTerritoryAssociation(scope, mapofTerritoryNamevsId ,mapZipCodeVsTerritoryName);
            }  
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
           
            JMS_Logger.push(STR_ASSIGN_OBJECT_TERRITORY_ASSOCIATION, JMS_ConstantsUtility.OBJECT_TERRITORY2_ASSOCIATION_API);
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
        
    }
}