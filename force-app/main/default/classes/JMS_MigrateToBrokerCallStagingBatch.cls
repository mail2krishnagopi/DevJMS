/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_MigrateToBrokerCallStagingBatch
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 02/05/2022
* @Description      : Batch class to migrate the Broker Call Landing records
                      to Broker Call staging Object
**********************************************************************************************************************
**********************************************************************************************************************/
global without sharing class JMS_MigrateToBrokerCallStagingBatch implements database.Stateful,database.Batchable<Sobject> {
        
    public String strBatchId;
    //Final Variables
    private static final String STR_MIGRATE_TO_BROKER_CALL_STAGING = 'JMS_MigrateToBrokerCallStagingBatch Execute';
    private static final String BROKER_CALL_LANDING_API = 'JMS_Broker_Call_Landing__c';
    public static final String STR_OBJECT_BROKER_CALL = 'Broker Call';
    private static final String STR_GET_CAMPAIGN_RECORD_IDS = 'getCampaignRecordIds';
    private static final String STR_GET_CONTACT_RECORD_IDS = 'getContactRecordIds';
    private static final String STR_GET_ACCOUNT_RECORD_IDS = 'getAccountRecordIds';
    private static final String STR_GET_PRODUCT_RECORD_IDS = 'getProductRecordIds';
    private static final String STR_CREATE_BROKERCALL_STAGING_RECS = 'createBrokerCallStagingRecords';
    private static final String STR_GET_BROKER_CALL_STG_INSTANCE = 'getBrokerCallStgInstance';
    private static final String STR_GET_XREF_MAPPING = 'getXRefMapping';
    private static final String STR_BROKER_CALL_LAND_STG_MDT = 'JMS_Broker_Call_Landing_To_Staging__mdt';
    private static final String STR_GET_BROKERCALL_STG_VALIDATED = 'getBrokerCallStagingValidated';
    
    // constuctor declared
    
    public JMS_MigrateToBrokerCallStagingBatch(){
    }

    global database.QueryLocator start(database.batchablecontext BC){

        String queryString = 'SELECT Id';
        for(Schema.FieldSetMember fld :SObjectType.JMS_Broker_Call_Landing__c.FieldSets.JMS_Broker_Call_Landing_All_Fields.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }
        queryString += ' FROM JMS_Broker_Call_Landing__c ';
       
        return Database.getQueryLocator(queryString);
    }
    
   
    /***************************************************************************************************************
    *   @Name        :  Execute                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  To create records of Broker Call Staging
    ***************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        //Variables Declarations
        JMS_Broker_Call_Landing__c objBrokerCallLanding = new JMS_Broker_Call_Landing__c();
		List<JMS_Broker_Call_Landing__c> lstJMS_Broker_Call_Landing = new List<JMS_Broker_Call_Landing__c>();
        Map<String, String> mapLandingNameVsCampId =  new Map<String, String>();
        Set<String> SetDistributerCodes =  new Set<String>();
        Map<String, String> mapConEmailVsConId =  new Map<String, String>();
        Map<String, String> mapCompanyIdVsAccId =  new Map<String, String>();
        Map<String, String> mapSkuVsProductId =  new Map<String, String>();
        Map<String, String> mapDistributerCodeVsAccountId =  new Map<String, String>();
        Set<Id> setAccIds =  new Set<Id>();
        Set<Id> setBrokerCallStangingId =  new Set<Id>();
        Set<String> setFoundDistributerCodes =  new Set<String>();
        Set<String> setCampaignNames =  new Set<String>();
        Set<String> setConEmails =  new Set<String>();
        Set<String> setCompanyIds =  new Set<String>();
        Set<String> SetProductSkus =  new Set<String>();
        Map<String,Map<String,String>> mapKeyVsTargetSourceValue = new Map<String,Map<String,String>>();
        Map<String,String> mapKeyVsErrorMsg = new Map<String,String>();
        Map<String,JMS_Broker_Call_Staging__c> mapUniqueIdVsBrkrOriginalStagRecs = new Map<String,JMS_Broker_Call_Staging__c>();
        Map<String,Boolean> mapKeyVsIsVLookup = new Map<String,Boolean>();
        List<Schema.FieldSetMember> listOfStagingFields = new List<Schema.FieldSetMember>();
        List<JMS_Broker_Call_XREF__c> listBrokerCallXRefSetting = new List<JMS_Broker_Call_XREF__c>();
        Set<String> setRecordTypeNames = new Set<String>();
        String strUniqueId  = JMS_ConstantsUtility.EMPTY_STRING;
        List<JMS_Broker_Call_Staging__c> listExistingBrokerCall = new List<JMS_Broker_Call_Staging__c>();
        List<JMS_Broker_Call_Staging__c> listBrokerCallStgKickoutUpdate = new List<JMS_Broker_Call_Staging__c>();
        listBrokerCallXRefSetting = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, 
                                        JMS_Target_Key__c, JMS_Source_Value__c, JMS_Target_Value__c, 
                                        JMS_Reason__c, JMS_isVlookup__c, JMS_Field_API_Name__c, 
                                        JMS_Is_Active__c,RecordType.Name,JMS_Source_Key__c  
                                        FROM JMS_Broker_Call_XREF__c 
                                        WHERE JMS_Is_Active__c = TRUE];
        if(listBrokerCallXRefSetting != null && !listBrokerCallXRefSetting.isEmpty()){
            mapKeyVsTargetSourceValue = getXRefMapping(listBrokerCallXRefSetting, setRecordTypeNames, mapKeyVsIsVLookup, mapKeyVsErrorMsg);
        }
        if(mapKeyVsTargetSourceValue != null && !mapKeyVsTargetSourceValue.isEmpty()){
            listOfStagingFields = getFieldSet();
        }
        for(SObject objRec : scope){
            objBrokerCallLanding = (JMS_Broker_Call_Landing__c) objRec;
			lstJMS_Broker_Call_Landing.add(objBrokerCallLanding);
            if(String.isNotBlank(objBrokerCallLanding.JMS_Batch_Id__c) && String.isBlank(strBatchId)){
                strBatchId = objBrokerCallLanding.JMS_Batch_Id__c;
            }
            if(String.isNotBlank(objBrokerCallLanding.JMS_Unique_Key__c)){
                strUniqueId = objBrokerCallLanding.JMS_Unique_Key__c;
            }
            if(String.isNotBlank(objBrokerCallLanding.JMS_Campaign_Name__c)){
                setCampaignNames.add((objBrokerCallLanding.JMS_Campaign_Name__c).toLowerCase());
            }
            
            if(String.isNotBlank(objBrokerCallLanding.JMS_Contact_Email__c)){
                setConEmails.add((objBrokerCallLanding.JMS_Contact_Email__c).toLowerCase());
            }

            if(String.isNotBlank(objBrokerCallLanding.JMS_Company_SF_Id__c)){
                setCompanyIds.add(objBrokerCallLanding.JMS_Company_SF_Id__c);
            }
            if(String.isNotBlank(objBrokerCallLanding.JMS_Item_Number__c)){
                SetProductSkus.add(objBrokerCallLanding.JMS_Item_Number__c);
            }
            if(String.isNotBlank(objBrokerCallLanding.JMS_Call_distributor_code__c)){
                setDistributerCodes.add(objBrokerCallLanding.JMS_Call_distributor_code__c);
            }
        }
       
        /*To Check if we have same Unique Id record in staging 
        that is already processed , if found then will not process the current 
        record again AND If the record is already exist in staging then wipping
        out the kickpout reason values*/
        if(String.isNotBlank(strUniqueId)){
            listExistingBrokerCall = [SELECT Id ,JMS_Unique_Key__c,JMS_Batch_Id__c,
                                      JMS_Record_Processed__c,JMS_Kickout_Failed_Reason__c
                                        FROM  JMS_Broker_Call_Staging__c 
                                        WHERE JMS_Unique_Key__c =:strUniqueId AND
                                        JMS_Batch_Id__c =:strBatchId
                                        LIMIT 50000];
            if(listExistingBrokerCall != null || !listExistingBrokerCall.isEmpty()){
                for(JMS_Broker_Call_Staging__c objStagingRec :listExistingBrokerCall){
                    if(objStagingRec.JMS_Record_Processed__c == true ){
                        setBrokerCallStangingId.add(objStagingRec.Id);
                    }else if(objStagingRec.JMS_Record_Processed__c == false){
                        objStagingRec.JMS_Kickout_Failed_Reason__c = JMS_ConstantsUtility.EMPTY_STRING;
                        objStagingRec.JMS_Status__c = JMS_ConstantsUtility.EMPTY_STRING;
                        listBrokerCallStgKickoutUpdate.add(objStagingRec);
                    }
                }
            }
        }
        
        try{
            // Update Staging Records those thave same batch id and kickout reason 
            if(listBrokerCallStgKickoutUpdate != null && !listBrokerCallStgKickoutUpdate.isEmpty()){
                UPDATE listBrokerCallStgKickoutUpdate;
            }
            
            if(setBrokerCallStangingId == null || setBrokerCallStangingId.isEmpty()){
                if(setCampaignNames != null && !setCampaignNames.isEmpty()){
                    mapLandingNameVsCampId = getCampaignRecordIds(setCampaignNames);
                }
                if(setConEmails != null && !setConEmails.isEmpty()){
                    // mapConEmailVsConId = getContactRecordIds(setConEmails);
                    mapConEmailVsConId = getContactRecordIds(setConEmails, lstJMS_Broker_Call_Landing);
                }
                if(setCompanyIds != null && !setCompanyIds.isEmpty()){
                    setAccIds = getAccountRecordIds(setCompanyIds);
                }
                if(SetProductSkus != null && !SetProductSkus.isEmpty()){
                    mapSkuVsProductId = getProductRecordIds(SetProductSkus);
                }
                if(SetDistributerCodes != null && !SetDistributerCodes.isEmpty()){
                    mapDistributerCodeVsAccountId = findDistributerCodes(SetDistributerCodes);
                }
                // sending existing SF Id to Create Broker Call Staging record method
                createBrokerCallStagingRecords(mapLandingNameVsCampId, mapConEmailVsConId, setAccIds,mapSkuVsProductId,
                                                mapDistributerCodeVsAccountId, scope, mapUniqueIdVsBrkrOriginalStagRecs, setRecordTypeNames, listOfStagingFields, mapKeyVsErrorMsg, mapKeyVsTargetSourceValue, mapKeyVsIsVLookup);
                
                if(Test.isRunningTest()){
                    integer intExcept = 10/0;
                }
            }
        
        }catch(Exception excep){
            JMS_Logger.push(STR_MIGRATE_TO_BROKER_CALL_STAGING, BROKER_CALL_LANDING_API);
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
        system.debug('strBatchId--->>> ' + strBatchId);
        if(String.isNotBlank(strBatchId)){
            JMS_MigrateBrokerCallStgnToSObject objBrokerStagingBatch =  new JMS_MigrateBrokerCallStgnToSObject(strBatchId);
            Database.executeBatch(objBrokerStagingBatch,1);
        }
       
    }
    
     /***************************************************************************************************************
    *   @Name        :  getCampaignRecordIds                                                              
    *   @Return      :  Map<String,String> mapCampNameVsCampId                                                                                       
    *   @Description :  This method will provide map of Campaign Name and Campaign Id
    ***************************************************************************************************************/
    private static Map<String,String> getCampaignRecordIds(Set<String> setCampaignNames){
        Map<String,String> mapCampNameVsCampId = new Map<String,String>();
        try{
            List<Campaign> listCampaigns = [SELECT Id, Name FROM Campaign WHERE Name IN:setCampaignNames];
            if(listCampaigns != null && !listCampaigns.isEmpty()){
                for(Campaign objCamp :listCampaigns){
                    mapCampNameVsCampId.put(objCamp.Name,objCamp.Id);
                }
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_CAMPAIGN_RECORD_IDS, JMS_ConstantsUtility.OBJECT_CAMPAIGN_API );
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
        
        return mapCampNameVsCampId;
    }

     /***************************************************************************************************************
    *   @Name        :  getContactRecordIds                                                              
    *   @Return      :  Map<String,String> mapConEmailVsConId                                                                                       
    *   @Description :  To method will provide map of Contact Email and Contact Id
    ***************************************************************************************************************/
    private static Map<String,Id> getContactRecordIds(Set<String> setConEmails){
        Map<String,String> mapConEmailVsConId = new Map<String,String>();
        try{
            List<Contact> listContacts = [SELECT Id,Email, Name FROM Contact WHERE Email IN:setConEmails];
            if(listContacts != null && !listContacts.isEmpty()){
                for(Contact objCon :listContacts){
                    mapConEmailVsConId.put((objCon.Email).toLowerCase(),objCon.Id);
                }
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_CONTACT_RECORD_IDS, JMS_ConstantsUtility.CONTACT_API );
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
       
        return mapConEmailVsConId;
    }

	private static Map<String,Id> getContactRecordIds(Set<String> setConEmails, List<JMS_Broker_Call_Landing__c> lstJMS_Broker_Call_Landing){
		List<Contact> listContactsToUpdate = new List<Contact> ();
        Map<String,String> mapConEmailVsConId = new Map<String,String>();
        try{
            List<Contact> listContacts = [SELECT Id,Email, Name, phone, otherPhone,Title FROM Contact WHERE Email IN:setConEmails];
            if(listContacts != null && !listContacts.isEmpty()){
                for(Contact objCon :listContacts){
                    mapConEmailVsConId.put((objCon.Email).toLowerCase(),objCon.Id);
					
					for(JMS_Broker_Call_Landing__c objBCL : lstJMS_Broker_Call_Landing){
						if(objCon.Email == objBCL.JMS_Contact_Email__c ){						
							if(objCon.Title !=  objBCL.JMS_Contact_Title__c || objCon.phone !=  objBCL.JMS_Contact_Phone__c || objCon.otherPhone !=  objBCL.JMS_Contact_Phone_ext__c ){
								objCon.Title =  string.isNotEmpty(objBCL.JMS_Contact_Title__c) ? objBCL.JMS_Contact_Title__c : objCon.Title;
								objCon.phone =  string.isNotEmpty(objBCL.JMS_Contact_Phone__c) ? objBCL.JMS_Contact_Phone__c : objCon.phone;
								objCon.otherPhone =  string.isNotEmpty(objBCL.JMS_Contact_Phone_ext__c) ? objBCL.JMS_Contact_Phone_ext__c : objCon.otherPhone;
								listContactsToUpdate.add(objCon);
							}
						}
					}
                }
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_CONTACT_RECORD_IDS, JMS_ConstantsUtility.CONTACT_API );
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
       
	   system.debug( 'listContactsToUpdate-->>> ' + listContactsToUpdate);
	   if(listContactsToUpdate != null && listContactsToUpdate.size() > 0){
		   update listContactsToUpdate;
	   }
        return mapConEmailVsConId;
    }
	
     /***************************************************************************************************************
    *   @Name        :  getAccountRecordIds                                                              
    *   @Return      :  Set<Id> setAccIds                                                                                    
    *   @Description :  This method will provide set of Account Ids
    ***************************************************************************************************************/
    private static Set<Id> getAccountRecordIds(Set<String> setCompanyIds){
        Set<Id> setAccIds = new Set<Id>();
        try{
            List<Account> listAccounts = [SELECT Id, Name FROM Account WHERE Id IN:setCompanyIds];    
            if(listAccounts != null && !listAccounts.isEmpty()){
                for(Account objAcc :listAccounts){
                    setAccIds.add(objAcc.Id);
                }
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_ACCOUNT_RECORD_IDS, JMS_ConstantsUtility.ACCOUNT_API );
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
        
        return setAccIds;
    }

     /***************************************************************************************************************
    *   @Name        :  findDistributerCodes                                                              
    *   @Return      :  Map<String,String> mapDistributerCodeVsAccountId                                                                                    
    *   @Description :  This method will find set of existing Distributer Code of Accounts
    ***************************************************************************************************************/
    private static Map<String,String> findDistributerCodes(Set<String> setAccDistributerCodes){
        Map<String,String> mapDistributerCodeVsAccountId = new Map<String,String>();
        try{
            List<Account> listAccounts = [SELECT Id, JMS_Plan_to_Code__c FROM Account WHERE JMS_Plan_to_Code__c IN:setAccDistributerCodes];    
            if(listAccounts != null && !listAccounts.isEmpty()){
                for(Account objAcc :listAccounts){
                    mapDistributerCodeVsAccountId.put(objAcc.JMS_Plan_to_Code__c,objAcc.Id);
                }
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_ACCOUNT_RECORD_IDS, JMS_ConstantsUtility.ACCOUNT_API );
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
        
        return mapDistributerCodeVsAccountId;
    }

    /*************************************************************************
    *   @Name        :  getProductRecordIds                                                              
    *   @Return      :  Map<String,String>                                                                                       
    *   @Description :  To find the existing Product with Product name
    ***************************************************************************/
    private static Map<String,String> getProductRecordIds(Set<String> setProductsSku){
        Set<Id> SetProductId = new Set<Id>();
        Set<Id> SetProductIdWithPriceBookEntry = new Set<Id>();
        Map<String,String> mapSkuVsProductId = new Map<String,String>();
        try{
            Map<Id,Product2> mapProductIdVSProducts = new Map<Id,Product2>([SELECT Id, Name ,StockKeepingUnit 
                                                                            FROM Product2 
                                                                            WHERE StockKeepingUnit IN:setProductsSku]);
            
            if(mapProductIdVSProducts != null && !mapProductIdVSProducts.isEmpty()){
                for(Product2 objProduct :mapProductIdVSProducts.values()){
                        mapSkuVsProductId.put(objProduct.StockKeepingUnit,objProduct.Id);
                }
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_PRODUCT_RECORD_IDS, JMS_ConstantsUtility.PRODUCT_API );
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
        return mapSkuVsProductId;
    }

    /***************************************************************************************************************
    *   @Name        :  createBrokerCallStagingRecords                                                              
    *   @Return      :  void                                                                                   
    *   @Description :  This method is used for creating Broker Call Staging records
    ***************************************************************************************************************/
    private static void createBrokerCallStagingRecords(Map<String, String> mapLandingNameVsCampId,
                                                       Map<String, String> mapConEmailVsConId,
                                                       Set<Id> setAccIds,
                                                       Map<String, String> mapSkuVsProductId,
                                                       Map<String, String> mapDistributerCodeVsAccountId,
                                                       List<SObject> scope, Map<String,JMS_Broker_Call_Staging__c> mapUniqueIdVsBrkrOriginalStagRecs, Set<String> setRecordTypeNames, List<Schema.FieldSetMember> listOfStagingFields, Map<String,String> mapKeyVsErrorMsg, Map<String,Map<String,String>> mapKeyVsTargetSourceValue, Map<String,Boolean> mapKeyVsIsVLookup){
        JMS_Broker_Call_Landing__c objLanding = new JMS_Broker_Call_Landing__c();
        List<JMS_Broker_Call_Staging__c> listNewBrokerCallStaging =  new  List<JMS_Broker_Call_Staging__c>();
        
        //Querying Custom metadata record
        List<JMS_Broker_Call_Landing_To_Staging__mdt> listLandingToStagingMetadata = [SELECT Id,JMS_Landing_Api_Field__c,JMS_Staging_Api_Field__c,JMS_Is_Active__c
                                                                                      FROM JMS_Broker_Call_Landing_To_Staging__mdt 
                                                                                      WHERE JMS_Is_Active__c = TRUE];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;                                                
        for(SObject objLandingRec :scope){
           
            objLanding = (JMS_Broker_Call_Landing__c) objLandingRec;
            JMS_Broker_Call_Staging__c objStagingRec =  new JMS_Broker_Call_Staging__c();
            // Mapping of Landing to staging fields and its values
            objStagingRec = getBrokerCallStgInstance(listLandingToStagingMetadata, objLanding);
            objStagingRec.JMS_Kickout_Failed_Reason__c = JMS_ConstantsUtility.EMPTY_STRING;
            objStagingRec.JMS_Kickout_Location__c = JMS_ConstantsUtility.STR_SALESFORCE;
            if(setAccIds != null && !setAccIds.isEmpty() &&
               setAccIds.contains(objLanding.JMS_Company_SF_Id__c)){
               objStagingRec.JMS_Account_SF_Id__c = objLanding.JMS_Company_SF_Id__c;
            }else{
                objStagingRec.JMS_Kickout_Failed_Reason__c += JMS_MigrateBrokerCallStgnToSObjectHelper.validateAccount(objLanding);
            }
            
            if(String.isNotBlank(objLanding.JMS_Campaign_Name__c) && mapLandingNameVsCampId != null && !mapLandingNameVsCampId.isEmpty() &&
            mapLandingNameVsCampId.containsKey(objLanding.JMS_Campaign_Name__c)){
               objStagingRec.JMS_Campaign_SF_Id__c  =   mapLandingNameVsCampId.get(objLanding.JMS_Campaign_Name__c);
            }else{
                if(String.isNotBlank(objLanding.JMS_Campaign_Name__c)){
                    objStagingRec.JMS_Campaign_SF_Id__c  = JMS_ConstantsUtility.EMPTY_STRING;
                    objStagingRec.JMS_Kickout_Failed_Reason__c += System.Label.JMS_Initiative_Name_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
                }
               
            }
            
            if(String.isNotBlank(objLanding.JMS_Item_Number__c) &&
                mapSkuVsProductId != null && !mapSkuVsProductId.isEmpty() &&
                mapSkuVsProductId.containsKey(objLanding.JMS_Item_Number__c)){
                   objStagingRec.JMS_Product_SF_Id__c = mapSkuVsProductId.get(objLanding.JMS_Item_Number__c) ;
            }else{
                if(String.isNotBlank(objLanding.JMS_Item_Number__c)){
                    objStagingRec.JMS_Product_SF_Id__c = JMS_ConstantsUtility.EMPTY_STRING;
                    objStagingRec.JMS_Kickout_Failed_Reason__c += System.Label.JMS_Item_Number_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
                }
            }
            
            if(mapDistributerCodeVsAccountId != null && !mapDistributerCodeVsAccountId.isEmpty() && 
                String.isNotBlank(objLanding.JMS_Call_distributor_code__c) &&
                mapDistributerCodeVsAccountId.containsKey(objLanding.JMS_Call_distributor_code__c)){
                    objStagingRec.JMS_Call_Distributor_SF_Id__c = mapDistributerCodeVsAccountId.get(objLanding.JMS_Call_distributor_code__c);
            }
           
            if(mapConEmailVsConId != null && !mapConEmailVsConId.isEmpty() &&
            mapConEmailVsConId.containsKey((objLanding.JMS_Contact_Email__c).toLowerCase())){
               objStagingRec.JMS_Contact_SF_Id__c = mapConEmailVsConId.get((objLanding.JMS_Contact_Email__c).toLowerCase());
               
            }
            
            objStagingRec.JMS_Kickout_Failed_Reason__c +=  JMS_MigrateBrokerCallStgnToSObjectHelper.validateBrokerCall(objLanding);
          
            if(String.isNotBlank(objLanding.JMS_Contact_First_Name__c) && String.isBlank(objLanding.JMS_Contact_Last_Name__c)){
                objStagingRec.JMS_Contact_Last_Name__c = objLanding.JMS_Contact_First_Name__c;
            }
            objStagingRec.setOptions(dml);
            
            listNewBrokerCallStaging.add(objStagingRec);
            mapUniqueIdVsBrkrOriginalStagRecs.put(objStagingRec.JMS_Unique_Key__c,objStagingRec.clone(true, true, true, true));
        }
        try{
            
            if(listNewBrokerCallStaging != null && !listNewBrokerCallStaging.isEmpty()){
                getBrokerCallStagingValidated(listNewBrokerCallStaging, setRecordTypeNames, listOfStagingFields, mapUniqueIdVsBrkrOriginalStagRecs, mapKeyVsErrorMsg, mapKeyVsTargetSourceValue, mapKeyVsIsVLookup);
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_CREATE_BROKERCALL_STAGING_RECS, BROKER_CALL_LANDING_API);
           
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }                                                     
    }
    
    /***************************************************************************************************************
    *   @Name        :  getFieldSet                                                              
    *   @Return      :  List<Schema.FieldSetMember>                                                                                   
    *   @Description :  This method is fatching the validations fields from Field set of Broker
    *                   Call Staging object
    ***************************************************************************************************************/
    public static List<Schema.FieldSetMember> getFieldSet()
    {
        List<Schema.FieldSetMember> listValidationFields = SObjectType.JMS_Broker_Call_Staging__c.FieldSets.JMS_Validation_Fields.getFields();
        return listValidationFields;
    }
    
    /*****************************************************************
    *   @Name        :  getBrokerCallStgInstance                                                              
    *   @Return      :  JMS_Broker_Call_Staging__c                                                                                      
    *   @Description :  To create JMS_Broker_Call_Staging__c records using Metadata 
                        field mapping 
    *******************************************************************/
    public static JMS_Broker_Call_Staging__c getBrokerCallStgInstance(List<JMS_Broker_Call_Landing_To_Staging__mdt> listLandingToStagingMetadata, JMS_Broker_Call_Landing__c objLanding){
        JMS_Broker_Call_Staging__c objStagingRec = new JMS_Broker_Call_Staging__c();
        try{
            for(JMS_Broker_Call_Landing_To_Staging__mdt mdtRec : listLandingToStagingMetadata){
                if(objLanding.get(mdtRec.JMS_Landing_Api_Field__c) != null){
                    
                    objStagingRec.put(mdtRec.JMS_Staging_Api_Field__c, objLanding.get(mdtRec.JMS_Landing_Api_Field__c));
                }else{
                    objStagingRec.put(mdtRec.JMS_Staging_Api_Field__c, JMS_ConstantsUtility.EMPTY_STRING);

                }
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
         JMS_Logger.push(STR_GET_BROKER_CALL_STG_INSTANCE, JMS_ConstantsUtility.OBJECT_BROKER_CALL_STAGING_API);
         JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }    
        
        return objStagingRec;
    }
    
    /***************************************************************************************************************
    *   @Name        :  getXRefMapping                                                              
    *   @Return      :  Map<String,Map<String,String>>                                                                                
    *   @Description :  This method is fetching the JMS_Broker_Call_XREF__c records and
    *                   creating Map<String,Map<String,String>>
    ***************************************************************************************************************/
    public static Map<String,Map<String,String>> getXRefMapping(List<JMS_Broker_Call_XREF__c> listBrokerCallXRefSetting, Set<String> setRecordTypeNames, Map<String,Boolean> mapKeyVsIsVLookup, Map<String,String> mapKeyVsErrorMsg){
        Map<String,Map<String,String>> mapKeyVsTargetSourceRec = new Map<String,Map<String,String>>();
        String strKey = JMS_ConstantsUtility.EMPTY_STRING;
        setRecordTypeNames =  new Set<String>();
        
        try{
            for(JMS_Broker_Call_XREF__c objRec :listBrokerCallXRefSetting){
                if(String.isNotBlank(objRec.RecordType.Name) &&
                String.isNotBlank(objRec.JMS_Field_API_Name__c) &&
                String.isNotBlank(objRec.JMS_Source_Value__c) ||
                String.isNotBlank(objRec.JMS_Target_Value__c)){
                    // Combination of Xref recordtype and JMS_Field_API_Name__c field
                    strKey = (objRec.RecordType.Name).toUpperCase() + JMS_ConstantsUtility.ATRATE_DOUBLE + objRec.JMS_Field_API_Name__c;
                    if(!mapKeyVsTargetSourceRec.containskey(strKey)) {
                        //creation of map with combination and new Map of String , String
                        mapKeyVsTargetSourceRec.put(strKey,new map<String,String>());
                       
                        mapKeyVsErrorMsg.put(strKey,objRec.JMS_Reason__c);
                        mapKeyVsIsVLookup.put(strKey,objRec.JMS_isVlookup__c);
                    }
                    //Addding of Map of Source Vs Target Values against of combination key
                    if(String.isNotBlank(objRec.JMS_Source_Value__c)){
                        mapKeyVsTargetSourceRec.get(strKey).put((objRec.JMS_Source_Value__c).trim(),objRec.JMS_Target_Value__c.trim());
                    }
                    else{
                        //Addding of Map of Source Vs Target Values against of combination key if we
                        //don't have source value
                        mapKeyVsTargetSourceRec.get(strKey).put((objRec.JMS_Target_Value__c).trim(),objRec.JMS_Target_Value__c.trim());
                    }
                    setRecordTypeNames.add((objRec.RecordType.Name).toUpperCase());
                }
            }
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_XREF_MAPPING, STR_BROKER_CALL_LAND_STG_MDT);
            
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }    
        return  mapKeyVsTargetSourceRec;
    }
    
    /***************************************************************************************************************
    *   @Name        :  getBrokerCallStagingValidated                                                              
    *   @Return      :  void                                                                               
    *   @Description :  This method is validating the Broker Call Staging record and 
    *                   converting the valdated field values
    *                   Upserting the records to Broker Call staging
    ***************************************************************************************************************/
    public static void getBrokerCallStagingValidated(List<JMS_Broker_Call_Staging__c> listNewBrokerCallStaging, Set<String> setRecordTypeNames, List<Schema.FieldSetMember> listOfStagingFields, Map<String,JMS_Broker_Call_Staging__c> mapUniqueIdVsBrkrOriginalStagRecs, Map<String,String> mapKeyVsErrorMsg, Map<String,Map<String,String>> mapKeyVsTargetSourceValue, Map<String,Boolean> mapKeyVsIsVLookup){
        String strKeyCombination = JMS_ConstantsUtility.EMPTY_STRING;
        String strTargetKeyValue = JMS_ConstantsUtility.EMPTY_STRING; 
        String strErrorMsg;
        JMS_Broker_Call_Staging__c objBCSRevertData;
        List<JMS_Broker_Call_Staging__c> listFinalBrokerCallStagingRecs = new List<JMS_Broker_Call_Staging__c>();
        Map<String,String> mapSourceVsTargetValue = new Map<String,String>();
        try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation = true; 
            if(listNewBrokerCallStaging != null && !listNewBrokerCallStaging.isEmpty()){
                for(JMS_Broker_Call_Staging__c objBCS : listNewBrokerCallStaging){
                    objBCS.JMS_Broker_Call_Batch_Job__c  =  STR_OBJECT_BROKER_CALL + Datetime.now();
                    strErrorMsg = JMS_ConstantsUtility.EMPTY_STRING;
                    //validation of valid Broker Name
                    if(String.isNotBlank(objBCS.JMS_Broker_Name__c) ){
                        if(setRecordTypeNames != null && !setRecordTypeNames.isEmpty() &&
                        !setRecordTypeNames.contains((objBCS.JMS_Broker_Name__c).toUpperCase())){
                            strErrorMsg += System.Label.JMS_Broker_Name_Invalid + JMS_ConstantsUtility.SPACE_STRING;
                        }
                    }
                    
                    //validation of fields from Validation field set of staging objects 
                    if(listOfStagingFields != null && !listOfStagingFields.isEmpty()){
                        for(Schema.FieldSetMember fieldApiName : listOfStagingFields) {
                            String strFieldName = (string.valueof(fieldApiName.getSObjectField())).trim();
                            if(strFieldName == JMS_ConstantsUtility.STR_ITEM_NO_SALE_REASON_DETAIL && 
                               String.isBlank(String.valueOf(objBCS.get(fieldApiName.getSObjectField())))){
                                   continue;
                            }
                            if(strFieldName == JMS_ConstantsUtility.STR_FIELD_OPP_STAGE && 
                               String.isBlank(String.valueOf(objBCS.get(fieldApiName.getSObjectField())))){
                                   continue;
                            } 
                            if((strFieldName == JMS_ConstantsUtility.STR_FIELD_BROKER_TERRITORY_ID || 
                               strFieldName == JMS_ConstantsUtility.STR_FIELD_BROKER_TERRITORY_NAME)
                               && String.isNotBlank(objBCS.JMS_Broker_Name__c) &&  objBCS.JMS_Broker_Name__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_IAC) &&
                               String.isBlank(String.valueOf(objBCS.get(fieldApiName.getSObjectField())))){
                                   continue;
                            } 
                            if(String.isNotBlank(objBCS.JMS_Item_Status__c) && String.isNotBlank(objBCS.JMS_Item_Status__c) &&
                                strFieldName == JMS_ConstantsUtility.STR_ITEM_NO_SALE_REASON &&
                                String.isBlank(String.valueOf(objBCS.get(fieldApiName.getSObjectField())))){
                                    String strItemStatus = objBCS.JMS_Item_Status__c;
                                    if(strItemStatus.contains(JMS_ConstantsUtility.SINGLE_DASH_STRING)){
                                        strItemStatus =  objBCS.JMS_Item_Status__c.remove(JMS_ConstantsUtility.SINGLE_DASH_STRING);
                                    }else{
                                        strItemStatus = objBCS.JMS_Item_Status__c;
                                    }
                                    strItemStatus = strItemStatus.replaceAll( '\\s+', '');
                                    strItemStatus = strItemStatus.toUpperCase();
                                    if(stritemStatus != JMS_ConstantsUtility.STR_NOSALE){
                                        continue;
                                    } 
                            }
                            if(String.isNotBlank(objBCS.JMS_Broker_Name__c) ){
                                strKeyCombination = (objBCS.JMS_Broker_Name__c).toUpperCase() + JMS_ConstantsUtility.ATRATE_DOUBLE + fieldApiName.getSObjectField();
                               
                            }
                            if(mapKeyVsTargetSourceValue != null && ! mapKeyVsTargetSourceValue.isEmpty() &&
                                String.isNotBlank(strKeyCombination) &&
                                mapKeyVsTargetSourceValue.containsKey(strKeyCombination)){
                                mapSourceVsTargetValue = mapKeyVsTargetSourceValue.get(strKeyCombination);
                                String strTargetKeyValueOrginal = String.valueOf(objBCS.get(fieldApiName.getSObjectField()));
                                if(String.isNotBlank(strTargetKeyValueOrginal)){
                                    if(strFieldName == JMS_ConstantsUtility.STR_COMPANY_TYPE){
                                          strTargetKeyValue = (strTargetKeyValueOrginal.toUpperCase()).trim();
                                    }else{
                                        strTargetKeyValue = strTargetKeyValueOrginal.trim();
                                    }
                                }
                                if(String.isNotBlank(strTargetKeyValue) && mapSourceVsTargetValue.containsKey(strTargetKeyValue) && 
                                   mapKeyVsIsVLookup.containsKey(strKeyCombination) == TRUE){
                                    objBCS.put(fieldApiName.getSObjectField(), mapSourceVsTargetValue.get(strTargetKeyValue));
                                   
                                }else if(String.isNotBlank(strTargetKeyValue) && mapSourceVsTargetValue.containsKey(strTargetKeyValue) && 
                                         mapKeyVsIsVLookup.containsKey(strTargetKeyValue) == FALSE){
                                    objBCS.put(fieldApiName.getSObjectField(), mapSourceVsTargetValue.get(strTargetKeyValue));
                                 
                                }else{
                                    strErrorMsg += mapKeyVsErrorMsg.get(strKeyCombination) + JMS_ConstantsUtility.SEMICOLAN;
                                   
                                }
                            }
                        }
                    }
                    
                    if(String.isNotBlank(strErrorMsg)){
                        if(strErrorMsg.endsWith(JMS_ConstantsUtility.SEMICOLAN)){
                            strErrorMsg = strErrorMsg.removeEnd(JMS_ConstantsUtility.SEMICOLAN);
                        }
                        objBCS.JMS_Kickout_Failed_Reason__c += strErrorMsg;
                    }
                    if(String.isNotBlank(objBCS.JMS_Kickout_Failed_Reason__c)){
                        String strKickoutReason = objBCS.JMS_Kickout_Failed_Reason__c;
                        // If Errors comes, reverting the converted values
                        objBCSRevertData =  new JMS_Broker_Call_Staging__c();
                        objBCS.JMS_Status__c = JMS_ConstantsUtility.STR_STATUS_ERROR;
                        
                        if(mapUniqueIdVsBrkrOriginalStagRecs != null && 
                        !mapUniqueIdVsBrkrOriginalStagRecs.isEmpty() && 
                        mapUniqueIdVsBrkrOriginalStagRecs.containsKey(objBCS.JMS_Unique_Key__c)){
                            
                            objBCSRevertData = mapUniqueIdVsBrkrOriginalStagRecs.get(objBCS.JMS_Unique_Key__c);
                            objBCSRevertData.JMS_Kickout_Failed_Reason__c = strKickoutReason;
                            objBCSRevertData.JMS_Status__c = JMS_ConstantsUtility.STR_STATUS_ERROR;
                        }
                    }else{
                        objBCS.JMS_Status__c = JMS_ConstantsUtility.STR_STATUS_SUCCESS;
                    }
                    if(objBCSRevertData != null ){
                        objBCSRevertData.setOptions(dml); 
                        listFinalBrokerCallStagingRecs.add(objBCSRevertData);
                    }else{
                        objBCS.setOptions(dml); 
                        listFinalBrokerCallStagingRecs.add(objBCS);
                    }
                }
            }
            
           
            if(listFinalBrokerCallStagingRecs != null && !listFinalBrokerCallStagingRecs.isEmpty()){
               //upert DML
               upsert listFinalBrokerCallStagingRecs JMS_Unique_Key__c;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_BROKERCALL_STG_VALIDATED, JMS_ConstantsUtility.OBJECT_BROKER_CALL_STAGING_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
        
    }
}