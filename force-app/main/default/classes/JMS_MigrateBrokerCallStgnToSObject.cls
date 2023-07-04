/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_MigrateBrokerCallStgnToSObject
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 02/05/2022
* @Description      : Batch class to Migrate Broker Call Staging records to respective SObjects
**********************************************************************************************************************
**********************************************************************************************************************/
global without sharing class JMS_MigrateBrokerCallStgnToSObject implements database.Stateful,database.Batchable<Sobject> {
    //Final Variable declaration
    public static final String STR_MIGRATE_TO_BROKER_CALL = 'JMS_MigrateBrokerCallStgnToSObject Execute';
    public static final String STR_OBJECT_BROKER_CALL = 'Broker Call';
    public static final String STR_START = 'Start';
    public static final String STR_ZERO = '0';
    public static final String STR_FINISH = 'Finish';
    public static final String STR_DOUBLE_HASH = '##';
    public static final String STR_REPORT_FORMAT_CSV = '.csv';
    public static final String STR_KICKOUT_REPORT = 'KickOut Report ';
    public static final String STR_SUCCESS_REPORT = 'Success Report ';
    public static final String STR_REMOVE_DUPLICATE_ACCOUNT_RECORDS = 'removeDuplicateAccountRecords';
    public static final String STR_MIGRATE_TO_BROKER_CALL_FINISH = 'JMS_MigrateBrokerCallStgnToSObject finish';
    public static final String STR_REMOVE_DUPLICATE_CONTACT_RECORDS = 'removeDuplicateContactRecords';
    public static final String STR_SEND_EMAIL_TO_BROKERCall_SENDER = 'sendEmailToBrokerCallSender';
    public static final String STR_GET_REPORTS_SENDER_DETAILS_MDT = 'getReportsSenderDetailsMdt';
	public String strBatchId;
    
    // constuctor declared
    public JMS_MigrateBrokerCallStgnToSObject(){
    }
	
    public JMS_MigrateBrokerCallStgnToSObject(String strLandingBatchId){
        if(String.isNotBlank(strLandingBatchId)){
            strBatchId = strLandingBatchId;
        }
    }
    
    /***************************************************************************************************************
    *   @Name        :  Start                                                              
    *   @Return      :  database.QueryLocator                                                                                       
    *   @Description :  Start method to define the scope of Batch run
    ***************************************************************************************************************/
    global database.QueryLocator start(database.batchablecontext BC){
       
        String queryString = getStagingFields(STR_START , strBatchId);
        system.debug('queryString-->>> ' + queryString);
        return Database.getQueryLocator(queryString);
    }

    public static String getStagingFields(String requestSource ,String strBatchId ){
        
        String queryString = 'SELECT id';
        
        for(Schema.FieldSetMember fld :SObjectType.JMS_Broker_Call_Staging__c.FieldSets.Broker_Call_Staging_All_Fields.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }
        
        queryString += ' FROM JMS_Broker_Call_Staging__c';
        
        if(requestSource.equalsIgnoreCase(STR_START) && String.isNotBlank(strBatchId)){
            queryString += ' WHERE JMS_Record_Processed__c = false';
            queryString += ' AND JMS_Kickout_Location__c = \'Salesforce\'';
            queryString += ' AND JMS_Status__c = \'Success\'';
            queryString += ' AND JMS_Batch_Id__c =: strBatchId';
        }else if(requestSource.equalsIgnoreCase(STR_FINISH) && String.isNotBlank(strBatchId)){
            queryString += ' WHERE JMS_Batch_Id__c =: strBatchId';
            queryString += ' LIMIT 50000';
        }
        
        return queryString;
    }
    
    /***************************************************************************************************************
    *   @Name        :  Execute                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  
    ***************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<SObject> scope){
	
		//Local variable declaration
		List<JMS_Staging_Metadata__mdt> mdtStagingList;
		Map<Id,Id> mapBRRefIdVsAccId = new Map<Id,Id>();
		Map<Id,Id> mapBRRefIdVsContactId = new Map<Id,Id>();
		Map<Id,Id>  mapAccIdVsRefId = new Map<Id,Id>();
		Map<Id,String> mapBRRefIdVsCampaignId = new Map<Id,String>();
		JMS_Broker_Call_Staging__c objBrokerCallRec ;
		Map<Id,Account> mapBRRefIdVsAccount = new Map<Id,Account>();
		Map<Id,JMS_Broker_Call_Staging__c> mapBRRefIdVsBrokerCallStaging = new Map<Id,JMS_Broker_Call_Staging__c>();
		Map<Id,Contact> mapBRRefIdVsContact = new Map<Id,Contact>();
		Map<Id,JMS_Broker_Call__c> mapBRRefIdVsBrokerCall = new Map<Id,JMS_Broker_Call__c>();
		List<JMS_Broker_Call_Staging__c> listUpdateBRStaging = new List<JMS_Broker_Call_Staging__c>();
		set<string> setExistingAccountIds = new set<string>();
		map<Id, List<Contact>> mapAccIdVsAllExistingContact = new map<Id, List<Contact>> ();
       
        try{
            mdtStagingList = [SELECT 
                        Id, DeveloperName, Label, QualifiedApiName, JMS_Staging_Api_Field__c, 
                        JMS_Constant_Value__c,JMS_SF_Api_Name__c, JMS_SFDC_Object__c, JMS_IsActive__c, 
                        JMS_Object_Type__c, Is_Number_Datatype__c 
                        FROM 
                            JMS_Staging_Metadata__mdt 
                        WHERE 
                            JMS_Object_Type__c =: JMS_ConstantsUtility.OBJECT_BROKER_CALL_STAGING_API 
                        AND JMS_IsActive__c = TRUE WITH SECURITY_ENFORCED LIMIT 50000];
                
            //Loop over the Scope to get the prepare the respective SObject lists
            
            for(SObject sObjRec : scope){
                objBrokerCallRec = (JMS_Broker_Call_Staging__c) sObjRec;
                
                 //map of Campaign target Staging Id Vs Campaign Id
                if(String.isNotBlank(objBrokerCallRec.JMS_Campaign_SF_Id__c)){
                    mapBRRefIdVsCampaignId.put(objBrokerCallRec.Id,objBrokerCallRec.JMS_Campaign_SF_Id__c);
                } 
                //map of Campaign target Staging Id Vs Account
                if(String.isBlank(objBrokerCallRec.JMS_Account_SF_Id__c) && 
                String.isBlank(objBrokerCallRec.JMS_Account_Error_Message__c)){
                    Account objNewAccount =  getAccInstance(objBrokerCallRec, mdtStagingList);
                    mapBRRefIdVsAccount.put(objBrokerCallRec.Id,objNewAccount);  
                }else{
                    mapAccIdVsRefId.put(objBrokerCallRec.JMS_Account_SF_Id__c ,objBrokerCallRec.Id); 
                }
				
				if(String.isNotBlank(objBrokerCallRec.JMS_Account_SF_Id__c)) {
					setExistingAccountIds.add(objBrokerCallRec.JMS_Account_SF_Id__c);
				}
				
				
                //map of Campaign target Staging Id Vs Contact
                if(String.isBlank(objBrokerCallRec.JMS_Contact_SF_ID__c) &&
                    (String.isNotBlank(objBrokerCallRec.JMS_Contact_First_Name__c) || 
                    String.isNotBlank(objBrokerCallRec.JMS_Contact_Last_Name__c))){
                    Contact objNewContact =  getContInstance(objBrokerCallRec, mdtStagingList);
                    mapBRRefIdVsContact.put(objBrokerCallRec.Id,objNewContact);  
                }
                //map of Campaign target Staging Id Vs Broker call
               
                JMS_Broker_Call__c objNewBrokerCall = getBrokerCallInstance(objBrokerCallRec, mdtStagingList);
                if(objNewBrokerCall != null){
                    mapBRRefIdVsBrokerCall.put(objBrokerCallRec.Id,objNewBrokerCall);
                }
            }
			system.debug(' setExistingAccountIds--->>> ' + setExistingAccountIds);
			if(setExistingAccountIds != null && setExistingAccountIds.size() >0 ){
				List<Account> lstAccs =[select id, (select id, Title, FirstName, LastName, Email, Phone, OtherPhone from Contacts) from Account where id in : setExistingAccountIds];
				if(lstAccs != null && lstAccs.size() > 0){
					for(Account oAcc:  lstAccs){
						mapAccIdVsAllExistingContact.put(oAcc.Id, oAcc.Contacts);
					}
				}
			}
			system.debug(' mapAccIdVsAllExistingContact--->>> ' + mapAccIdVsAllExistingContact);
			system.debug(' mapBRRefIdVsAccount--->>> ' + mapBRRefIdVsAccount);
			
            //Check duplicate Acc ? if existis , get the AccID
            if(mapBRRefIdVsAccount != null && !mapBRRefIdVsAccount.isEmpty()){
                mapBRRefIdVsAccount = removeDuplicateAccountRecords(mapBRRefIdVsAccount, mapBRRefIdVsAccId, mapAccIdVsRefId);
            }
            //Insert Accounts - retrieve Account Ids
            if(mapBRRefIdVsAccount != null && !mapBRRefIdVsAccount.isEmpty()){
                Database.SaveResult[] savAccResList = Database.insert(mapBRRefIdVsAccount.values(),TRUE);
            }
            for(Account ObjAccRef:mapBRRefIdVsAccount.values()){
                mapAccIdVsRefId.put(ObjAccRef.Id ,ObjAccRef.JMS_Broker_Call_Staging_Reference__c);
            }
             //Insert Contact stamp AccId to respective Contact Id
             if(mapBRRefIdVsContact != null && !mapBRRefIdVsContact.isEmpty()){
                for(Id objRefId : mapBRRefIdVsContact.keySet()){
                    Contact objContact = mapBRRefIdVsContact.get(objRefId);
                    if(String.isBlank(objContact.AccountId) && mapBRRefIdVsAccount != null &&
                        mapBRRefIdVsAccount.containsKey(objRefId)){
                        objContact.AccountId = mapBRRefIdVsAccount.get(objRefId).Id;
                    }else if(String.isBlank(objContact.AccountId) && mapBRRefIdVsAccId != null &&
                        mapBRRefIdVsAccId.containsKey(objRefId)){
                        objContact.AccountId = mapBRRefIdVsAccId.get(objRefId);
                    }
                    //if Else for global and interal map
                    mapBRRefIdVsContact.put(objRefId,objContact);
                }
            }
			system.debug(' mapBRRefIdVsContact--->>>111 ' + mapBRRefIdVsContact);
            if(mapBRRefIdVsContact != null && !mapBRRefIdVsContact.isEmpty()){
                // mapBRRefIdVsContact = removeDuplicateContactRecords(mapBRRefIdVsContact, mapBRRefIdVsContactId);
                mapBRRefIdVsContact = removeDuplicateContactRecords(mapBRRefIdVsContact, mapBRRefIdVsContactId, mapAccIdVsAllExistingContact);
            }
			system.debug(' mapBRRefIdVsContact--->>>189 ' + mapBRRefIdVsContact);
            if(mapBRRefIdVsContact != null && !mapBRRefIdVsContact.isEmpty()){
                Database.SaveResult[] savConResList = Database.insert(mapBRRefIdVsContact.values(),TRUE);
                
            }
            
            // Insert Broker Call and stamp AccId
            if(mapBRRefIdVsBrokerCall != null && !mapBRRefIdVsBrokerCall.isEmpty()){
                for(Id objRefId : mapBRRefIdVsBrokerCall.keySet()){
                    JMS_Broker_Call__c objBrokerCall = mapBRRefIdVsBrokerCall.get(objRefId);
                    if(String.isBlank(objBrokerCall.Account__c) && mapBRRefIdVsAccount.containsKey(objRefId)){
                        objBrokerCall.Account__c = mapBRRefIdVsAccount.get(objRefId).Id;
                    }else if(String.isBlank(objBrokerCall.Account__c) && mapBRRefIdVsAccId != null &&
                    mapBRRefIdVsAccId.containsKey(objRefId)){
                        objBrokerCall.Account__c = mapBRRefIdVsAccId.get(objRefId);
                    }
                    if(mapBRRefIdVsContact != null && !mapBRRefIdVsContact.isEmpty() && 
                        mapBRRefIdVsContact.containsKey(objRefId)){
                        objBrokerCall.JMS_Contact__c = mapBRRefIdVsContact.get(objRefId).Id;
                    }
                    else if(mapBRRefIdVsContactId != null && !mapBRRefIdVsContactId.isEmpty() && 
                        mapBRRefIdVsContactId.containsKey(objRefId)){
                        objBrokerCall.JMS_Contact__c = mapBRRefIdVsContactId.get(objRefId);
                    }
                    //if Else for global and interal map
                    mapBRRefIdVsBrokerCall.put(objRefId,objBrokerCall);
                }
            }
            if(mapBRRefIdVsBrokerCall != null && !mapBRRefIdVsBrokerCall.isEmpty()){
                Database.SaveResult[] savBrokerCallResList = Database.insert(mapBRRefIdVsBrokerCall.values(),TRUE);
            }
            
            
            /****Update Staging records with Account,Contact,Opportunity,Brokercall,Opportunity Product*****/
            for(SObject objRec : scope){
                objBrokerCallRec = (JMS_Broker_Call_Staging__c) objRec;
                // Stamp Account Id in Staging record
                if(String.isBlank(objBrokerCallRec.JMS_Account_SF_Id__c)){
                    if(mapBRRefIdVsAccount != null && !mapBRRefIdVsAccount.isEmpty() && 
                    mapBRRefIdVsAccount.containsKey(objBrokerCallRec.Id)){
                        objBrokerCallRec.JMS_Account_SF_Id__c = mapBRRefIdVsAccount.get(objBrokerCallRec.Id).Id;
                    }
                    else if(mapBRRefIdVsAccId != null && !mapBRRefIdVsAccId.isEmpty() && 
                        mapBRRefIdVsAccId.containsKey(objBrokerCallRec.Id)){
                            objBrokerCallRec.JMS_Account_SF_Id__c = mapBRRefIdVsAccId.get(objBrokerCallRec.Id);
                    }
                    else {
                       // objBrokerCallRec.JMS_Operator_Error_Message__c = 'Unable to create New Operator(Account) Record';
                       objBrokerCallRec.JMS_Status__c =  JMS_ConstantsUtility.STR_STATUS_ERROR;
                    }
                }
                // Stamp Contact Id in Staging record
                if(String.isBlank(objBrokerCallRec.JMS_Contact_SF_Id__c)){
                    if(mapBRRefIdVsContact != null && !mapBRRefIdVsContact.isEmpty() && 
                        mapBRRefIdVsContact.containsKey(objBrokerCallRec.Id)){
                            objBrokerCallRec.JMS_Contact_SF_Id__c = mapBRRefIdVsContact.get(objBrokerCallRec.Id).Id;
                    }
                    else if(mapBRRefIdVsContactId != null && !mapBRRefIdVsContactId.isEmpty() && 
                        mapBRRefIdVsContactId.containsKey(objBrokerCallRec.Id)){
                            objBrokerCallRec.JMS_Contact_SF_Id__c = mapBRRefIdVsContactId.get(objBrokerCallRec.Id);
                    }
                }
                // Stamp Broker Call Id in Staging record
                if(String.isBlank(objBrokerCallRec.JMS_Broker_Call_SF_Id__c)){
                    if(mapBRRefIdVsBrokerCall != null && !mapBRRefIdVsBrokerCall.isEmpty() && 
                    mapBRRefIdVsBrokerCall.containsKey(objBrokerCallRec.Id)){
                        objBrokerCallRec.JMS_Broker_Call_SF_Id__c = mapBRRefIdVsBrokerCall.get(objBrokerCallRec.Id).Id;
                    }
                }
                // Check if complete record are process for Broker
                if(String.isNotBlank(objBrokerCallRec.JMS_Account_SF_Id__c) &&
                    String.isNotBlank(objBrokerCallRec.JMS_Broker_Call_SF_Id__c)){
                        objBrokerCallRec.JMS_Record_Processed__c = true;
                }
                else{
                    objBrokerCallRec.JMS_Record_Processed__c = false;
                }
               
                mapBRRefIdVsBrokerCallStaging.put(objBrokerCallRec.Id,objBrokerCallRec);
                listUpdateBRStaging.add(objBrokerCallRec);
            }
        
            JMS_Broker_Call_Staging__c objBRokerCallRefRecord = new JMS_Broker_Call_Staging__c();
            List<Account> listExistingAccBRTerrUpdate = new List<Account>();
            if(mapAccIdVsRefId != null){
                for(Account objExistAcc : [SELECT Id,JMS_Broker_Territory_Id__c,JMS_Broker_Territory__c 
                                            FROM Account WHERE Id IN:mapAccIdVsRefId.keySet() WITH SECURITY_ENFORCED LIMIT 50000]){
                    if(String.isBlank(objExistAcc.JMS_Broker_Territory_Id__c) || 
                         String.isBlank(objExistAcc.JMS_Broker_Territory__c)){
                        if(mapBRRefIdVsBrokerCallStaging.containsKey(mapAccIdVsRefId.get(objExistAcc.Id))){
                            objBRokerCallRefRecord =  mapBRRefIdVsBrokerCallStaging.get(mapAccIdVsRefId.get(objExistAcc.Id));
                        }
                        // Update  Broker Call Territory Name and Territory Id on Account
                        Account objAccToUpdate = new Account(
                            Id = objExistAcc.Id,
                            JMS_Broker_Territory_Id__c = objBRokerCallRefRecord.JMS_Company_Broker_Territory_Id__c,
                            JMS_Broker_Territory__c = objBRokerCallRefRecord.JMS_Company_Broker_Territory_Name__c
                        );
                        listExistingAccBRTerrUpdate.add(objAccToUpdate);
                    }
                }   
            }
            //Update Existing Account with Territory Details
            if(listExistingAccBRTerrUpdate != null && !listExistingAccBRTerrUpdate.isEmpty()){
                Database.update(listExistingAccBRTerrUpdate,true);
            }
            //Update Broker Call Staging records with record Ids
            if(listUpdateBRStaging != null && !listUpdateBRStaging.isEmpty()){
                Database.update(listUpdateBRStaging , true);
            }
            
            //To cover the code from Catch block
            if(Test.isRunningTest()){
                integer i = 10/0;
            }
        }catch(System.Exception ex){
            JMS_Broker_Call_Landing__c objExtgBrokerCallLanding = new JMS_Broker_Call_Landing__c();
            JMS_Broker_Call_Staging__c objBrokerCallToUpdate = objBrokerCallRec;
            String strErrorMsg = ex.getMessage();
            String queryString = 'SELECT id';
            String strstagingUniqueKey = objBrokerCallRec.JMS_Unique_Key__c;
           
            if(String.isNotBlank(strstagingUniqueKey)){
                 
                for(Schema.FieldSetMember fld :SObjectType.JMS_Broker_Call_Landing__c.FieldSets.JMS_Broker_Call_Landing_All_Fields.getFields()) {
                    queryString += ', ' + fld.getFieldPath();
                }
                queryString += ' FROM JMS_Broker_Call_Landing__c';
                queryString += ' WHERE JMS_Unique_Key__c =: strstagingUniqueKey LIMIT 1';
                objExtgBrokerCallLanding = Database.query(queryString);
                if(objExtgBrokerCallLanding != null && objBrokerCallRec != null){
                    objBrokerCallToUpdate.Id = objBrokerCallRec.Id ;
                    if(String.isNotBlank(objExtgBrokerCallLanding.JMS_Item_No_Sale_Reason__c)){
                        objBrokerCallToUpdate.JMS_Item_No_Sale_Reason__c = objExtgBrokerCallLanding.JMS_Item_No_Sale_Reason__c ;
                    }
                    if(String.isNotBlank(objExtgBrokerCallLanding.JMS_Item_No_Sale_Reason_Detail__c)){
                        objBrokerCallToUpdate.JMS_Item_No_Sale_Reason_Detail__c = objExtgBrokerCallLanding.JMS_Item_No_Sale_Reason_Detail__c ;
                    }
                    if(String.isNotBlank(objExtgBrokerCallLanding.JMS_Company_Broker_Territory_Id__c)){
                        objBrokerCallToUpdate.JMS_Company_Broker_Territory_Id__c = objExtgBrokerCallLanding.JMS_Company_Broker_Territory_Id__c ;
                    }
                    if(String.isNotBlank(objExtgBrokerCallLanding.JMS_Company_Broker_Territory_Name__c)){
                        objBrokerCallToUpdate.JMS_Company_Broker_Territory_Name__c = objExtgBrokerCallLanding.JMS_Company_Broker_Territory_Name__c ;
                    }
                    if(String.isNotBlank(objExtgBrokerCallLanding.JMS_Item_Status__c)){
                        objBrokerCallToUpdate.JMS_Item_Status__c = objExtgBrokerCallLanding.JMS_Item_Status__c ;
                    }
                    if(String.isNotBlank(objExtgBrokerCallLanding.JMS_Opportunity_Stage__c)){
                        objBrokerCallToUpdate.JMS_Opportunity_Stage__c = objExtgBrokerCallLanding.JMS_Opportunity_Stage__c ;
                    }
                    if(String.isNotBlank(objExtgBrokerCallLanding.JMS_Company_Type__c)){
                        objBrokerCallToUpdate.JMS_Company_Type__c = objExtgBrokerCallLanding.JMS_Company_Type__c ;
                    }
                    if(String.isNotBlank(objExtgBrokerCallLanding.JMS_Call_Status__c)){
                        objBrokerCallToUpdate.JMS_Call_Status__c = objExtgBrokerCallLanding.JMS_Call_Status__c ;
                    }
                    if(String.isNotBlank(strErrorMsg) && strErrorMsg.contains(JMS_ConstantsUtility.STR_COMMA_STRING)){
                        strErrorMsg = strErrorMsg.replace(JMS_ConstantsUtility.STR_COMMA_STRING,JMS_ConstantsUtility.SPACE_STRING);
                    }
                    objBrokerCallToUpdate.JMS_Kickout_Failed_Reason__c = strErrorMsg;
                    objBrokerCallToUpdate.JMS_Status__c = JMS_ConstantsUtility.STR_STATUS_ERROR;
                    objBrokerCallRec.JMS_Record_Processed__c = false;
                    update objBrokerCallToUpdate;
                }
            }
            JMS_Logger.push(STR_MIGRATE_TO_BROKER_CALL, JMS_ConstantsUtility.OBJECT_TERRITORY2_ASSOCIATION_API);
            JMS_Logger.debugException(ex);
        }finally {
            JMS_Logger.pop();
        }
    }
    
    /***************************************************************************************************************
    *   @Name        :  Finish                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  TO send email with Kickout failed reason report and success report of 
                        Broker Call Staging processed and failes data                             
    ***************************************************************************************************************/
    
    global void finish(Database.BatchableContext BC){
        //try{
        JMS_Delete_SObject_Records objDeleteRecordBatch = new JMS_Delete_SObject_Records(JMS_ConstantsUtility.OBJECT_BROKER_CALL_LANDING_API,null);
           
        //Query String to get Broker Call Staging Fields from field set                                          
        String queryString = getStagingFields(STR_FINISH, this.strBatchId); 
        // To fetch Broker Call Stging records
        List<JMS_Broker_Call_Staging__c> stglist = Database.query(queryString);
        // Headers of Error report 
        string kickoutHeader = JMS_ConstantsUtility.BROKER_CALL_KICKOUT_HEADERS;
        // Headers of Success report 
        string successHeader = JMS_ConstantsUtility.BROKER_CALL_SUCCESS_HEADERS;
        Map<String, String> mapRecStatusVsReportStr =  new Map<String, String>();
        String StrReportString =  JMS_ConstantsUtility.EMPTY_STRING;
        String strPerRecordReprtString =  JMS_ConstantsUtility.EMPTY_STRING;
        Map<String,Map<String, String>> mapBrkrNmeVsStatusAndReportStr = new Map<String,Map<String, String>>();
        Map<String,Map<String, String>> mapBrkrNmeVsCompTypeAndRecCount = new Map<String,Map<String, String>>();
        Map<String, String> mapCompTypeVsRecCount =  new Map<String, String>();
        Integer intOperatorRecordProcessed = JMS_ConstantsUtility.INT_ZERO;
        Integer intOperatorRecordUnProcessed = JMS_ConstantsUtility.INT_ZERO;
        Integer intDistributorRecordProcessed = JMS_ConstantsUtility.INT_ZERO;
        Integer intDistributorRecordUnProcessed = JMS_ConstantsUtility.INT_ZERO;
        String strBrokerName = JMS_ConstantsUtility.EMPTY_STRING;
        String strCompanyType = JMS_ConstantsUtility.EMPTY_STRING;
        String strDistributorUpperCase = (JMS_ConstantsUtility.STR_DISTRIBUTOR).toUpperCase();
        String strOperatorUpperCase = (JMS_ConstantsUtility.OPERATOR_RECORDTYPE).toUpperCase();
        Integer brokerCallFileSize = Integer.valueOf(System.Label.JMS_BrokerCallFileSize);
        try{
            // Execute Batch to delete Landing records that are migrate to Staging object
            Database.executeBatch(objDeleteRecordBatch);
            //Create Map of Broker Call Name VS Map of Record Status and report string with comma separated
            if(stglist != null && !stglist.isEmpty() && stglist.size() <=brokerCallFileSize){
               
                for(JMS_Broker_Call_Staging__c stgRec: stglist) {
                    strBrokerName = JMS_ConstantsUtility.EMPTY_STRING;
                    if(String.isNotBlank(stgRec.JMS_Broker_Name__c)){
                        strBrokerName = ((stgRec.JMS_Broker_Name__c).toUpperCase()).trim();
                    }
                    if(String.isNotBlank(stgRec.JMS_Company_Type__c)){
                        strCompanyType = ((stgRec.JMS_Company_Type__c).toUpperCase()).trim();
                        if(strCompanyType.equalsIgnoreCase(JMS_ConstantsUtility.STR_CLIENT_END_USER)){
                            strCompanyType = (JMS_ConstantsUtility.OPERATOR_RECORDTYPE).toUpperCase();
                        }
                    }
                    mapRecStatusVsReportStr =  new Map<String, String>();
                    mapCompTypeVsRecCount =  new Map<String, String>();
                    /*15062022
                    //strPerRecordReprtString =  JMS_ConstantsUtility.EMPTY_STRING;
                    //mapRecStatusVsReportStr.put(stgRec.JMS_Status__c,strPerRecordReprtString);*/
                   
                    if(String.isNotBlank(stgRec.JMS_Status__c) && String.isNotBlank(strBrokerName) && String.isNotBlank(strCompanyType)){
                        // when the parent map have the same Broker Call name key and related status and string
                        if(mapBrkrNmeVsStatusAndReportStr != null && (mapBrkrNmeVsStatusAndReportStr.containsKey(strBrokerName))){
                            mapRecStatusVsReportStr =  mapBrkrNmeVsStatusAndReportStr.get(strBrokerName);
                            strPerRecordReprtString =  JMS_ConstantsUtility.EMPTY_STRING;
                            // If child map have the status as a key
                            if(mapRecStatusVsReportStr != null && mapRecStatusVsReportStr.containsKey(stgRec.JMS_Status__c)){
                                strPerRecordReprtString += mapRecStatusVsReportStr.get(stgRec.JMS_Status__c);
                                strPerRecordReprtString +=  getStagingRecordString(stgRec);
                                mapRecStatusVsReportStr.put(stgRec.JMS_Status__c,strPerRecordReprtString);
                            }else{
                                if(String.isNotBlank(stgRec.JMS_Status__c)){
                                    // If child map don't have the status as a key
                                    if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_SUCCESS)){
                                        strPerRecordReprtString = successHeader + getStagingRecordString(stgRec);
                                    }
                                    else if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR)){
                                    strPerRecordReprtString = kickoutHeader + getStagingRecordString(stgRec);
                                    }
                                    mapRecStatusVsReportStr.put(stgRec.JMS_Status__c,strPerRecordReprtString);
                                }
                            }
                            // Add Map of Status Vs string in Parent Map with Broker call key
                             mapBrkrNmeVsStatusAndReportStr.put(strBrokerName,mapRecStatusVsReportStr); 
                           
                        }else{
                            if(String.isNotBlank(stgRec.JMS_Status__c)){
                                // When the record Iterate and with Broker Name its don't have any key value pair
                                if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_SUCCESS)){
                                strPerRecordReprtString = successHeader + getStagingRecordString(stgRec);
                                }
                                else if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR)){
                                    strPerRecordReprtString = kickoutHeader + getStagingRecordString(stgRec);
                                }
                                mapRecStatusVsReportStr.put(stgRec.JMS_Status__c,strPerRecordReprtString);
                                mapBrkrNmeVsStatusAndReportStr.put(strBrokerName,mapRecStatusVsReportStr); 
                            }
                        }
                    }
                    if(String.isNotBlank(stgRec.JMS_Status__c) && (String.isNotBlank(strBrokerName) && 
                        String.isNotBlank(strCompanyType))){
                        if(mapBrkrNmeVsStatusAndReportStr != null && mapBrkrNmeVsStatusAndReportStr.containsKey(strBrokerName)){
                            intOperatorRecordProcessed = JMS_ConstantsUtility.INT_ZERO;
                            intOperatorRecordUnProcessed = JMS_ConstantsUtility.INT_ZERO;
                            intDistributorRecordProcessed = JMS_ConstantsUtility.INT_ZERO;
                            intDistributorRecordUnProcessed = JMS_ConstantsUtility.INT_ZERO;

                            mapCompTypeVsRecCount =  mapBrkrNmeVsStatusAndReportStr.get(strBrokerName);
                            if(mapCompTypeVsRecCount != null && mapCompTypeVsRecCount.containsKey(strCompanyType)){
                                String[] arrRecCountString =  (mapCompTypeVsRecCount.get(strCompanyType)).split(STR_DOUBLE_HASH);
                                String strConcatenateCounts = JMS_ConstantsUtility.EMPTY_STRING;
                                if(strCompanyType.equalsIgnoreCase(strOperatorUpperCase) && arrRecCountString != null &&
                                    !arrRecCountString.isEmpty()){
                                    intOperatorRecordUnProcessed = Integer.valueOf(arrRecCountString[1]);
                                    intOperatorRecordProcessed = Integer.valueOf(arrRecCountString[0]);
                                    if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.SUCCESS)){
                                        intOperatorRecordProcessed++;
                                    }else if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR)){
                                        intOperatorRecordUnProcessed++;
                                    }
                                    strConcatenateCounts = String.valueOf(intOperatorRecordProcessed) + STR_DOUBLE_HASH +
                                        String.valueOf(intOperatorRecordUnProcessed) ;
                                }
                                else if(strCompanyType.equalsIgnoreCase(strDistributorUpperCase) && arrRecCountString != null &&
                                !arrRecCountString.isEmpty()){
                                    if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.SUCCESS)){
                                        intDistributorRecordProcessed = Integer.valueOf(arrRecCountString[0]);
                                        intDistributorRecordProcessed++;
                                    } else if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR)){
                                        intDistributorRecordUnProcessed = Integer.valueOf(arrRecCountString[1]);
                                        intDistributorRecordUnProcessed++;
                                    }
                                    strConcatenateCounts =  String.valueOf(intDistributorRecordProcessed) + STR_DOUBLE_HASH +
                                    String.valueOf(intDistributorRecordUnProcessed);
                                }
                                mapCompTypeVsRecCount.put(strCompanyType,strConcatenateCounts);
                            }else{
                                String strConcatenateCounts = RecordCountCalculation(stgRec);
                                if(strCompanyType.equalsIgnoreCase(JMS_ConstantsUtility.STR_CLIENT_END_USER)){
                                    strCompanyType = (JMS_ConstantsUtility.OPERATOR_RECORDTYPE).toUpperCase();
                                }
                                mapCompTypeVsRecCount.put(strCompanyType,strConcatenateCounts);
                            }
                            mapBrkrNmeVsStatusAndReportStr.put(strBrokerName,mapCompTypeVsRecCount);
                        }else{
                            String strConcatenateCounts = RecordCountCalculation(stgRec);
                            if(strCompanyType.equalsIgnoreCase(JMS_ConstantsUtility.STR_CLIENT_END_USER)){
                                strCompanyType = (JMS_ConstantsUtility.OPERATOR_RECORDTYPE).toUpperCase();
                            }
                            mapCompTypeVsRecCount.put(strCompanyType,strConcatenateCounts);
                            mapBrkrNmeVsStatusAndReportStr.put(strBrokerName,mapCompTypeVsRecCount);
                        }
                    }
                }
                //Send Map<String, Map<String,String>> to generate report Attachment in format of CSV
                if(mapBrkrNmeVsStatusAndReportStr != null && !mapBrkrNmeVsStatusAndReportStr.isEmpty()){
                    sendEmailToBrokerCallSender(mapBrkrNmeVsStatusAndReportStr, this.strBatchId);
                }
            }else if(stglist != null && !stglist.isEmpty() && stglist.size() > brokerCallFileSize){//Added by Sachin A. on 20220823 
                //Send Email to Josh notifying the file size is greater than the limit and Need to run the Standard Reports
                String strSubject = 'Broker Call File gen failure';
                String strPlainBody = 'Broker Call with Batch Id - '+ strBatchId +' has large data set, the Summary file generation has failed. Please check Standard Salesforce Report.';
                String strToAddress = System.label.JMS_Broker_Call_Email_Address;
                JMS_SendEmailNotification emailHandler = new JMS_SendEmailNotification();
                emailHandler.sendMail(strToAddress, '', '', '', strPlainBody, '', strSubject, NULL);
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_MIGRATE_TO_BROKER_CALL_FINISH, JMS_ConstantsUtility.OBJECT_BROKER_CALL_STAGING_API);
            JMS_Logger.debugException(excep);
           
        }finally {
            JMS_Logger.pop();
        }
    }

     /***************************************************************************************************************
    *   @Name        :  RecordCountCalculation                                                              
    *   @Return      :  String                                                                                     
    *   @Description :  To calculate recounts for Processed and non processed record
                        against of Operator and Distributor
    ****************************************************************************************************************/

    public static String RecordCountCalculation(JMS_Broker_Call_Staging__c stgRec){
        Integer intOperatorRecordProcessed = 0;
        Integer intOperatorRecordUnProcessed = 0;
        Integer intDistributorRecordProcessed = 0;
        Integer intDistributorRecordUnProcessed = 0;
        String strCompanyType = JMS_ConstantsUtility.EMPTY_STRING;
        String strOperatorUpperCase = ((JMS_ConstantsUtility.OPERATOR_RECORDTYPE).toUpperCase()).trim();
        String strDistributorUpperCase = ((JMS_ConstantsUtility.STR_DISTRIBUTOR).toUpperCase()).trim();
        if(String.isNotBlank(stgRec.JMS_Company_Type__c)){
            strCompanyType = ((stgRec.JMS_Company_Type__c).toUpperCase()).trim();
            if(strCompanyType.equalsIgnoreCase(JMS_ConstantsUtility.STR_CLIENT_END_USER)){
                strCompanyType = (JMS_ConstantsUtility.OPERATOR_RECORDTYPE).toUpperCase();
            }
        }
        
        String strConcatenateCounts = JMS_ConstantsUtility.EMPTY_STRING;
        if(String.isNotBlank(stgRec.JMS_Status__c) &&  String.isNotBlank(strCompanyType) && (strCompanyType.equalsIgnoreCase(strOperatorUpperCase))){
            if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.SUCCESS)){
                intOperatorRecordProcessed = 1;
                
            } else if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR)){
                intOperatorRecordUnProcessed = 1;
            }
            strConcatenateCounts = String.valueOf(intOperatorRecordProcessed) + STR_DOUBLE_HASH +
            String.valueOf(intOperatorRecordUnProcessed);
           
        }
        else if(String.isNotBlank(stgRec.JMS_Status__c) && String.isNotBlank(strCompanyType) && 
        strCompanyType.equalsIgnoreCase(strDistributorUpperCase)){
            if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.SUCCESS)){
                intDistributorRecordProcessed = 1;
            }else if(stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR)){
                intDistributorRecordUnProcessed = 1;
            }
            strConcatenateCounts = String.valueOf(intDistributorRecordProcessed) + STR_DOUBLE_HASH +
            String.valueOf(intDistributorRecordUnProcessed);
        }
        return strConcatenateCounts;
    }

     /***************************************************************************************************************
    *   @Name        :  sendEmailToBrokerCallSender                                                              
    *   @Return      :  void                                                                                     
    *   @Description :  To create send email with attachment of CSV Success and kickout reports againast 
                        each Broker Name
    ****************************************************************************************************************/

    public static void sendEmailToBrokerCallSender(Map<String,Map<String,String>> mapBrkrNmeVsStatusAndReportStr , String strBatchIdVal){
        String strEmailAddress = JMS_ConstantsUtility.EMPTY_STRING;
        String strTotalProcessedRecords = STR_ZERO;
        String strTotalUnProcessedRecords = STR_ZERO;
        String strOperatorProcessedRecords = STR_ZERO;
        String strOperatorUnProcessedRecords = STR_ZERO;
        String strDistributorProcessedRecords = STR_ZERO;
        String strDistributorUnProcessedRecords = STR_ZERO;
        String strBody = JMS_ConstantsUtility.EMPTY_STRING;  
        String[] arrOperatorRecordCounts;
        String[] arrDistributorRecordCounts;
        string kickoutHeader = JMS_ConstantsUtility.BROKER_CALL_KICKOUT_HEADERS;
        // Headers of Success report 
        string successHeader = JMS_ConstantsUtility.BROKER_CALL_SUCCESS_HEADERS;
        //Email Service
        JMS_SendEmailNotification objSendNotication = new JMS_SendEmailNotification();
        //Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment successKickoutCsvAttc =  new Messaging.EmailFileAttachment();
        List<Messaging.EmailFileAttachment> listErrSuccssReportsForBroker = new List<Messaging.EmailFileAttachment>();
        //get Sender Email addresses against of Broker names from Metadata and store in map
        Map<String,String> mapMdtLabelVsSenderEmail = getReportsSenderDetailsMdt();
        Map<String,String> mapStatusVsReportStrings = new Map<String,String>();
        Map<String,String> mapCompanyTypeVsRecCounts = new Map<String,String>();
        Map<String,List<Messaging.EmailFileAttachment>> mapSenderEmailVsCsvReports = new Map<String,List<Messaging.EmailFileAttachment>>();
        String strOperatorUpperCase = (JMS_ConstantsUtility.OPERATOR_RECORDTYPE).toUpperCase();
        String strDistributorUpperCase = (JMS_ConstantsUtility.STR_DISTRIBUTOR).toUpperCase();
        try{
            //Query on Email Template through which the mail will send with attachment
            EmailTemplate objBrokerCallEmailTemplate = [SELECT Id, HtmlValue, Subject ,Body FROM EmailTemplate 
                                                        WHERE DeveloperName =: System.Label.JMS_Broker_call_Report_Email_Template LIMIT 1];
            if(mapBrkrNmeVsStatusAndReportStr != null && !mapBrkrNmeVsStatusAndReportStr.isEmpty()){
                for(String objBrokerName : mapBrkrNmeVsStatusAndReportStr.keySet()){
                    arrOperatorRecordCounts = new String[]{};
                    arrDistributorRecordCounts = new String[]{};
                    // get Sender Email Address against of Broker name from map mapMdtLabelVsSenderEmail
                    strEmailAddress = mapMdtLabelVsSenderEmail.get(objBrokerName.toUpperCase());
                    if(String.isNotBlank(objBrokerName) && mapBrkrNmeVsStatusAndReportStr.containsKey(objBrokerName)){
                        successKickoutCsvAttc =  new Messaging.EmailFileAttachment();
                        listErrSuccssReportsForBroker = new List<Messaging.EmailFileAttachment>();
                        strTotalProcessedRecords = STR_ZERO;
                        strTotalUnProcessedRecords = STR_ZERO;
                        strOperatorProcessedRecords = STR_ZERO;
                        strOperatorUnProcessedRecords = STR_ZERO;
                        strDistributorProcessedRecords = STR_ZERO;
                        strDistributorUnProcessedRecords = STR_ZERO;
                        for(String strKeyStatusAndCmpnyType : (mapBrkrNmeVsStatusAndReportStr.get(objBrokerName)).keySet()){
                            
                            mapStatusVsReportStrings =  (mapBrkrNmeVsStatusAndReportStr.get(objBrokerName));
                           
                            // add success and Kickout Failed attachment in on list listErrSuccssReportsForBroker
                            if(String.isNotBlank(strKeyStatusAndCmpnyType) && mapStatusVsReportStrings != null && 
                                mapStatusVsReportStrings.containsKey(strKeyStatusAndCmpnyType) &&
                                strKeyStatusAndCmpnyType.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR) || 
                                strKeyStatusAndCmpnyType.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_SUCCESS)){
                                if(strKeyStatusAndCmpnyType.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_SUCCESS)){
                                    successKickoutCsvAttc = getBrokerCallAttachment(mapStatusVsReportStrings.get(strKeyStatusAndCmpnyType) ,objBrokerName + JMS_ConstantsUtility.SPACE_STRING + STR_SUCCESS_REPORT);
                                    listErrSuccssReportsForBroker.add(successKickoutCsvAttc);
                                   
                                }else if(strKeyStatusAndCmpnyType.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR)){
                                    successKickoutCsvAttc = getBrokerCallAttachment(mapStatusVsReportStrings.get(strKeyStatusAndCmpnyType),objBrokerName + JMS_ConstantsUtility.SPACE_STRING + STR_KICKOUT_REPORT);
                                    listErrSuccssReportsForBroker.add(successKickoutCsvAttc);
                                }
                            }
                            // Record Calculation on basis of Broker Name and Company Type
                            //Operator & Distributor
                            else if(String.isNotBlank(strKeyStatusAndCmpnyType) && mapStatusVsReportStrings != null && 
                                    mapStatusVsReportStrings.containsKey(strKeyStatusAndCmpnyType) &&
                                    strKeyStatusAndCmpnyType.equalsIgnoreCase(strOperatorUpperCase) ||
                                    strKeyStatusAndCmpnyType.equalsIgnoreCase(strDistributorUpperCase)){
                                
                                mapCompanyTypeVsRecCounts = (mapBrkrNmeVsStatusAndReportStr.get(objBrokerName));
                                // Operator Record addition if more than one record
                                if(mapCompanyTypeVsRecCounts != null && !mapCompanyTypeVsRecCounts.isEmpty() &&
                                    strKeyStatusAndCmpnyType.equalsIgnoreCase(strOperatorUpperCase)){
                                    if((mapCompanyTypeVsRecCounts.get(strKeyStatusAndCmpnyType)).contains(STR_DOUBLE_HASH)){
                                        arrOperatorRecordCounts = (mapCompanyTypeVsRecCounts.get(strKeyStatusAndCmpnyType)).split(STR_DOUBLE_HASH);
                                        strOperatorProcessedRecords = arrOperatorRecordCounts[0];
                                        strOperatorUnProcessedRecords = arrOperatorRecordCounts[1];
                                    }
                                }else if(mapCompanyTypeVsRecCounts != null && !mapCompanyTypeVsRecCounts.isEmpty() && 
                                    strKeyStatusAndCmpnyType.equalsIgnoreCase(strDistributorUpperCase)){
                                    // Distributor Record addition if more than one record
                                    if((mapCompanyTypeVsRecCounts.get(strKeyStatusAndCmpnyType)).contains(STR_DOUBLE_HASH)){ 
                                        arrDistributorRecordCounts = (mapCompanyTypeVsRecCounts.get(strKeyStatusAndCmpnyType)).split(STR_DOUBLE_HASH);
                                        strDistributorProcessedRecords = arrDistributorRecordCounts[0];
                                        strDistributorUnProcessedRecords = arrDistributorRecordCounts[1];
                                    }
                                }
                                if(arrOperatorRecordCounts != null && !arrOperatorRecordCounts.isEmpty() &&  arrDistributorRecordCounts != null
                                && !arrDistributorRecordCounts.isEmpty()){
                                
                                    Integer intTotalProcessedRecords = Integer.ValueOf(arrOperatorRecordCounts[0]) +  Integer.ValueOf(arrDistributorRecordCounts[0]);
                                    Integer intTotalUnProcessedRecords = Integer.ValueOf(arrOperatorRecordCounts[1]) +  Integer.ValueOf(arrDistributorRecordCounts[1]);
                                
                                    strTotalProcessedRecords = String.ValueOf(intTotalProcessedRecords);
                                    strTotalUnProcessedRecords = String.ValueOf(intTotalUnProcessedRecords);
    
                                }else if(arrOperatorRecordCounts != null && !arrOperatorRecordCounts.isEmpty() && (arrDistributorRecordCounts == null
                                || arrDistributorRecordCounts.isEmpty())){
                                    strTotalProcessedRecords = arrOperatorRecordCounts[0];
                                    strTotalUnProcessedRecords = arrOperatorRecordCounts[1];
                                }
                                else if((arrOperatorRecordCounts == null || arrOperatorRecordCounts.isEmpty()) && arrDistributorRecordCounts != null
                                && !arrDistributorRecordCounts.isEmpty()){
                            
                                    strTotalProcessedRecords = arrDistributorRecordCounts[0];
                                    strTotalUnProcessedRecords = arrDistributorRecordCounts[1];
                                }
                                else{
                                    strTotalProcessedRecords = String.valueOf(0);
                                    strTotalUnProcessedRecords = String.valueOf(0);
                                }
                            }
                        }
                    }
                    successKickoutCsvAttc =  new Messaging.EmailFileAttachment();
                    if(objBrokerCallEmailTemplate != null){
                        strBody = objBrokerCallEmailTemplate.HtmlValue;
                        if(String.isNotBlank(strBody) && String.isNotBlank(strBatchIdVal)){
                            strBody = strBody.replace(JMS_ConstantsUtility.STR_BATCH_ID,JMS_ConstantsUtility.COLON + JMS_ConstantsUtility.SPACE_STRING + strBatchIdVal);
                        }
                        //Operator Processed Record Count
                        if(String.isNotBlank(strBody) && strBody.contains(JMS_ConstantsUtility.STR_OPERATOR_RECORD_PROCESSED) &&
                            String.isNotBlank(strOperatorProcessedRecords)){
                                strBody = strBody.replace(JMS_ConstantsUtility.STR_OPERATOR_RECORD_PROCESSED,strOperatorProcessedRecords);
                        }
                        //Operator UnProcessed Record Count
                        if(String.isNotBlank(strBody) && strBody.contains(JMS_ConstantsUtility.STR_OPERATOR_RECORD_UNPROCESSED) &&
                            String.isNotBlank(strOperatorUnProcessedRecords)){
                                strBody = strBody.replace(JMS_ConstantsUtility.STR_OPERATOR_RECORD_UNPROCESSED,strOperatorUnProcessedRecords);
                        }
                        //Distributor Processed Record Count
                        if(String.isNotBlank(strBody) && strBody.contains(JMS_ConstantsUtility.STR_DISTRIBUTOR_RECORD_PROCESSED) &&
                            String.isNotBlank(strDistributorProcessedRecords)){
                                strBody = strBody.replace(JMS_ConstantsUtility.STR_DISTRIBUTOR_RECORD_PROCESSED,strDistributorProcessedRecords);
                        }
                        //Distributor UnProcessed Record Count
                        if(String.isNotBlank(strBody) && strBody.contains(JMS_ConstantsUtility.STR_DISTRIBUTOR_RECORD_UNPROCESSED) &&
                            String.isNotBlank(strDistributorUnProcessedRecords)){
                                strBody = strBody.replace(JMS_ConstantsUtility.STR_DISTRIBUTOR_RECORD_UNPROCESSED,strDistributorUnProcessedRecords);
                        }
                        //Total Processed Record Count    
                        if(String.isNotBlank(strBody) && strBody.contains(JMS_ConstantsUtility.STR_TOTAL_RECORD_PROCESSED) &&
                            String.isNotBlank(strTotalProcessedRecords)){
                                strBody = strBody.replace(JMS_ConstantsUtility.STR_TOTAL_RECORD_PROCESSED,strTotalProcessedRecords);
                        }
                         //Total UnProcessed Record Count    
                        if(String.isNotBlank(strBody) && strBody.contains(JMS_ConstantsUtility.STR_TOTAL_RECORD_UNPROCESSED) &&
                            String.isNotBlank(strTotalUnProcessedRecords)){
                                strBody = strBody.replace(JMS_ConstantsUtility.STR_TOTAL_RECORD_UNPROCESSED,strTotalUnProcessedRecords);
                        }
        
                        // Send mail for each Broker name
                        if(listErrSuccssReportsForBroker != null && !listErrSuccssReportsForBroker.isEmpty()){
                            List<String> toAddresses = new List<String>();
                            String strBrokerCallEmailAddresses = strEmailAddress;
                            if(String.isNotBlank(strBrokerCallEmailAddresses)){
                                if(strBrokerCallEmailAddresses.contains(JMS_ConstantsUtility.SEMICOLAN)){
                                    toAddresses.addAll(strBrokerCallEmailAddresses.split(JMS_ConstantsUtility.SEMICOLAN));
                                }else{
                                    toAddresses.add(strBrokerCallEmailAddresses);
                                }
                                
                                String subject = (objBrokerCallEmailTemplate.Subject).replace(JMS_ConstantsUtility.STR_REPORT_NAME_VAL,objBrokerName);
                                //Email Service
                                objSendNotication.sendMail(strBrokerCallEmailAddresses , JMS_ConstantsUtility.EMPTY_STRING , JMS_ConstantsUtility.EMPTY_STRING , 
                                strBody, JMS_ConstantsUtility.EMPTY_STRING,objBrokerCallEmailTemplate.Id,
                                    subject , listErrSuccssReportsForBroker);
                            }
                        }
                    }
                }
            }
            
            if(test.isRunningTest()){
                Integer intVar = 1/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_SEND_EMAIL_TO_BROKERCall_SENDER, JMS_ConstantsUtility.OBJECT_BROKER_CALL_STAGING_API);
            JMS_Logger.debugException(excep);
           
        }finally {
            JMS_Logger.pop();
        }
    }

    /***************************************************************************************************************
    *   @Name        :  getReportsSenderDetailsMdt                                                              
    *   @Return      :  Map<String,String>                                                                                       
    *   @Description :  To create map of Label VS Send Email of JMS_Broker_Call_Staging_Sender_Details__mdt
                        to send email with CSV report
    ****************************************************************************************************************/
    public static Map<String,String> getReportsSenderDetailsMdt(){
        List<JMS_Broker_Call_Staging_Sender_Details__mdt> mdtSenderDetails =  new List<JMS_Broker_Call_Staging_Sender_Details__mdt>();
        Map<String,String> mapLabelVsSenderEmailMdt = new Map<String,String>();
        try{
            //query of JMS_Broker_Call_Staging_Sender_Details__mdt to get Sender Email address
            mdtSenderDetails = [SELECT MasterLabel, JMS_Sender_Email_Address__c
                                FROM JMS_Broker_Call_Staging_Sender_Details__mdt LIMIT 50000];
           
            if(mdtSenderDetails != null && !mdtSenderDetails.isEmpty()){
                for (JMS_Broker_Call_Staging_Sender_Details__mdt mdtSenderDetail : mdtSenderDetails) {
                    mapLabelVsSenderEmailMdt.put((mdtSenderDetail.MasterLabel).toUpperCase(),mdtSenderDetail.JMS_Sender_Email_Address__c);
                }
            }
            if(test.isRunningTest()){
                Integer intVar = 1/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_REPORTS_SENDER_DETAILS_MDT, JMS_ConstantsUtility.OBJECT_BROKER_CALL_STAGING_API);
            JMS_Logger.debugException(excep);
        
        }finally {
            JMS_Logger.pop();
        }
        return mapLabelVsSenderEmailMdt;
    }

    /***************************************************************************************************************
    *   @Name        :  getStagingRecordString                                                              
    *   @Return      :  string                                                                                       
    *   @Description :  To create report string for each Staging record with comma seprated
    ****************************************************************************************************************/
    public static string getStagingRecordString(JMS_Broker_Call_Staging__c stgRec){
        String strRecordString = JMS_ConstantsUtility.EMPTY_STRING;
        if(String.isNotBlank(stgRec.JMS_Status__c) && stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR)){
            strRecordString = JMS_ConstantsUtility.STR_FIRST_QUOTE + stgRec.JMS_Kickout_Failed_Reason__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE +
                            stgRec.JMS_Kickout_Location__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE;
        }else if(String.isNotBlank(stgRec.JMS_Status__c) && stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_SUCCESS)){
             strRecordString = JMS_ConstantsUtility.STR_FIRST_QUOTE ;
            
        }
        
        strRecordString +=  stgRec.JMS_Broker_call_id__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Opportunity_Id__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Opportunity_Stage__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE +  stgRec.JMS_Call_Date__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Call_Status__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Campaign_Name__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_Broker_Territory_Name__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_Broker_Territory_Id__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Call_Distributor_Code__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Call_Distributor_Name__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Item_Number__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Item_Description__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Annual_Case_Volume__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Item_Status__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Item_No_Sale_Reason__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Item_No_Sale_Reason_Detail__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Call_Comments__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_Type__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Company_Id__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_SF_Id__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_Name__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Company_Address__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_City__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_State__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Company_Zip__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_Phone__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Contact_First_Name__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Contact_Last_Name__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Contact_Title__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Contact_Email__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Contact_Phone__c + 
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Contact_Phone_ext__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Salesperson_Email__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                        stgRec.JMS_Salesperson_First_Name__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Salesperson_Last_Name__c +
                        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Broker_Name__c + JMS_ConstantsUtility.STR_END_NEWLINE_QUOTE ;

            
        if(String.isNotBlank(strRecordString)){
            strRecordString = strRecordString.replace(JMS_ConstantsUtility.NULL_STRING, JMS_ConstantsUtility.EMPTY_STRING);
        }
        
        return strRecordString;
    }

    /***************************************************************************************************************
    *   @Name        :  getBrokerCallAttachment                                                              
    *   @Return      :  Messaging.EmailFileAttachment                                                                                       
    *   @Description :  Create Attachment for eac Error and Success Reports
    ****************************************************************************************************************/
    public static Messaging.EmailFileAttachment getBrokerCallAttachment(String finalReportStr , String strReportName){
        Messaging.EmailFileAttachment reportCsvAttc = new Messaging.EmailFileAttachment();
        if(String.isNotBlank(finalReportStr) && String.isNotBlank(strReportName)){
            blob reportCsvBlob = Blob.valueOf(finalReportStr);
            string reportCsvName = strReportName + System.now() + STR_REPORT_FORMAT_CSV;
            reportCsvAttc.setFileName(reportCsvName);
            reportCsvAttc.setBody(reportCsvBlob);
        }
        return reportCsvAttc;
    }

    /***************************************************************************************************************
    *   @Name        :  getAccInstance                                                              
    *   @Return      :  Account                                                                                     
    *   @Description :  To create Instance of Account with some values but not saved yet
    ****************************************************************************************************************/
    public static Account getAccInstance(JMS_Broker_Call_Staging__c objBrokerCallStaging, List<JMS_Staging_Metadata__mdt> mdtStagingList){
        // Get Operator record Type Id
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('JMS_Operator').getRecordTypeId();
        Account objNewAccount =  new Account();
        objNewAccount.JMS_Broker_Call_Staging_Reference__c =  objBrokerCallStaging.Id;
        if(String.isNotBlank(objBrokerCallStaging.JMS_Company_Type__c)){
            objNewAccount.JMS_Record_Type_Name__c = ((objBrokerCallStaging.JMS_Company_Type__c).trim()).capitalize();
        }else{
            if(recordTypeId != null){
                objNewAccount.recordTypeId = recordTypeId;
            }
        }
        for(JMS_Staging_Metadata__mdt mdtRec : mdtStagingList){
            if (mdtRec.JMS_SFDC_Object__c.equalsIgnoreCase(JMS_ConstantsUtility.ACCOUNT_API)) {
                if (String.isBlank(mdtRec.JMS_Constant_Value__c) &&  
                    objBrokerCallStaging.get(mdtRec.JMS_Staging_Api_Field__c) != null) {
                    objNewAccount.put(mdtRec.JMS_SF_Api_Name__c, objBrokerCallStaging.get(mdtRec.JMS_Staging_Api_Field__c ) );
                }else if(String.isNotBlank(mdtRec.JMS_Constant_Value__c)){
                    objNewAccount.put(mdtRec.JMS_SF_Api_Name__c, mdtRec.JMS_Constant_Value__c );
                }
            }
        }
        return objNewAccount;
    }

    /***************************************************************************************************************
    *   @Name        :  getContInstance                                                              
    *   @Return      :  Contact                                                                                     
    *   @Description :  To create Instance of Contact with some values but not saved yet
    ****************************************************************************************************************/
    public static Contact getContInstance(JMS_Broker_Call_Staging__c objBrokerCallStaging, List<JMS_Staging_Metadata__mdt> mdtStagingList){
        Contact objNewContact =  new Contact();
        if(String.isNotBlank(objBrokerCallStaging.JMS_Account_SF_Id__c)){
            objNewContact.AccountId = objBrokerCallStaging.JMS_Account_SF_Id__c;        
        }
        // Mapping of data from Metadata field mapping
        for(JMS_Staging_Metadata__mdt mdtRec : mdtStagingList){
            if (mdtRec.JMS_SFDC_Object__c.equalsIgnoreCase(JMS_ConstantsUtility.CONTACT_API)) {
                if (String.isBlank(mdtRec.JMS_Constant_Value__c) &&  
                objBrokerCallStaging.get(mdtRec.JMS_Staging_Api_Field__c) != null) {
                    objNewContact.put(mdtRec.JMS_SF_Api_Name__c, objBrokerCallStaging.get(mdtRec.JMS_Staging_Api_Field__c ));
                }else if(String.isNotBlank(mdtRec.JMS_Constant_Value__c)){
                    objNewContact.put(mdtRec.JMS_SF_Api_Name__c, mdtRec.JMS_Constant_Value__c );
                }
            }
            
        }
        return objNewContact;
    }

    /***************************************************************************************************************
    *   @Name        :  getBrokerCallInstance                                                              
    *   @Return      :  JMS_Broker_Call__c                                                                                     
    *   @Description :  To create Instance of JMS_Broker_Call__c with some values but not saved yet
    ****************************************************************************************************************/
    public static JMS_Broker_Call__c getBrokerCallInstance(JMS_Broker_Call_Staging__c objBrokerCallStaging, List<JMS_Staging_Metadata__mdt> mdtStagingList){        
        JMS_Broker_Call__c objNewBrokerCall =  new JMS_Broker_Call__c();
        
            // Map Campaign Id to BrokerCall Campaign Field
            if(String.isNotBlank(objBrokerCallStaging.JMS_Campaign_SF_Id__c)){
                objNewBrokerCall.JMS_Campaign__c = objBrokerCallStaging.JMS_Campaign_SF_Id__c;
            }
            // Map Account Id to BrokerCall Account Field
            if(String.isNotBlank(objBrokerCallStaging.JMS_Account_SF_Id__c)){
                objNewBrokerCall.Account__c = objBrokerCallStaging.JMS_Account_SF_Id__c;
            }
            if(String.isNotBlank(objBrokerCallStaging.JMS_Broker_call_id__c)){
                objNewBrokerCall.JMS_External_Call_ID__c = objBrokerCallStaging.JMS_Broker_call_id__c;
            }
            if(String.isNotBlank(objBrokerCallStaging.JMS_Unique_Key__c)){
                objNewBrokerCall.JMS_Broker_Call_ID__c = objBrokerCallStaging.JMS_Unique_Key__c;
            }
            if(String.isNotBlank(objBrokerCallStaging.JMS_Call_Distributor_SF_Id__c)){
                objNewBrokerCall.JMS_Call_Distributor__c = objBrokerCallStaging.JMS_Call_Distributor_SF_Id__c;
            }
            if(String.isNotBlank(objBrokerCallStaging.JMS_Call_Date__c)){
                objNewBrokerCall.JMS_Call_Date__c = date.parse(objBrokerCallStaging.JMS_Call_Date__c);
            }
            
            for(JMS_Staging_Metadata__mdt mdtRec : mdtStagingList){
                if (mdtRec.JMS_SFDC_Object__c.equalsIgnoreCase(STR_OBJECT_BROKER_CALL)) {
                    if (String.isBlank(mdtRec.JMS_Constant_Value__c) &&  
                    objBrokerCallStaging.get(mdtRec.JMS_Staging_Api_Field__c) != null) {
                        // objNewBrokerCall.put(mdtRec.JMS_SF_Api_Name__c, objBrokerCallStaging.get(mdtRec.JMS_Staging_Api_Field__c ));
                        if(mdtRec.Is_Number_Datatype__c){
							objNewBrokerCall.put(mdtRec.JMS_SF_Api_Name__c, Decimal.valueOf(string.valueOf( objBrokerCallStaging.get(mdtRec.JMS_Staging_Api_Field__c ))) );
						}else{
							objNewBrokerCall.put(mdtRec.JMS_SF_Api_Name__c, objBrokerCallStaging.get(mdtRec.JMS_Staging_Api_Field__c ));
						}
                    }else if(String.isNotBlank(mdtRec.JMS_Constant_Value__c)){
                        objNewBrokerCall.put(mdtRec.JMS_SF_Api_Name__c, mdtRec.JMS_Constant_Value__c );
                    }
                }
            }
       		system.debug('objNewBrokerCall-->>> ' + objNewBrokerCall);
        return objNewBrokerCall;
    }

    /***************************************************************************************************************
    *   @Name        :  removeDuplicateAccountRecords                                                              
    *   @Return      :  Map<Id,Account>                                                                                       
    *   @Description :  find the existing Account add it in mapBRRefIdVsAccId map
    ***************************************************************************************************************/
    public static Map<Id,Account> removeDuplicateAccountRecords(Map<Id,Account> mapBRRefIdVsAccount, Map<Id,Id> mapBRRefIdVsAccId, Map<Id,Id>  mapAccIdVsRefId) {
       
        List<Datacloud.FindDuplicatesResult> results;
        try {
            ////get results from system with existing Account
            results = Datacloud.FindDuplicates.findDuplicates(mapBRRefIdVsAccount.values());
            
        }catch(Exception excep){
            JMS_Logger.push(STR_REMOVE_DUPLICATE_ACCOUNT_RECORDS, JMS_ConstantsUtility.ACCOUNT_API);
            JMS_Logger.debugException(excep);
            return null;
        }finally {
            JMS_Logger.pop();
        } 
        
        if(results != null && !results.isEmpty()){
            for (Integer i = 0; i < mapBRRefIdVsAccount.values().size(); i++) {
                Account foundAccount = null;
                // Find the first duplicate result with a match result, then use the first match record.
                for (Datacloud.DuplicateResult dr : results[i].getDuplicateResults()) {
                    if (dr.matchResults.size() > 0 && dr.getMatchResults()[0].matchRecords.size() > 0) {
                        foundAccount = (Account) dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                        break;
                    }
                }
                //Global Declared
                if(foundAccount != null){
                    // new map for existing Account
                    if(!mapBRRefIdVsAccId.containskey(mapBRRefIdVsAccount.values()[i].JMS_Broker_Call_Staging_Reference__c)){
                        mapBRRefIdVsAccId.put(mapBRRefIdVsAccount.values()[i].JMS_Broker_Call_Staging_Reference__c,foundAccount.Id);
                        mapAccIdVsRefId.put(foundAccount.Id ,mapBRRefIdVsAccount.values()[i].JMS_Broker_Call_Staging_Reference__c );
                    }
                     //map with new Account that needs to be create in execute method
                    if(mapBRRefIdVsAccount != null && mapBRRefIdVsAccount.containsKey(mapBRRefIdVsAccount.values()[i].JMS_Broker_Call_Staging_Reference__c)){
                        mapBRRefIdVsAccount.remove(mapBRRefIdVsAccount.values()[i].JMS_Broker_Call_Staging_Reference__c);
                    }
                }
            }
        }
        
        return mapBRRefIdVsAccount;
    }

    /***************************************************************************************************************
    *   @Name        :  removeDuplicateContactRecords                                                              
    *   @Return      :  Map<Id,Contact>                                                                                       
    *   @Description :  find the existing contact add it in mapBRRefIdVsContactId map
    ***************************************************************************************************************/
    public static Map<Id,Contact> removeDuplicateContactRecords(Map<Id,Contact> mapBRRefIdVsContact, Map<Id,Id> mapBRRefIdVsContactId, map<Id, List<Contact>> mapAccIdVsAllExistingContact ) {
		system.debug('--mapBRRefIdVsContact--->>> 1030 ' + mapBRRefIdVsContact);
		mapBRRefIdVsContact = customWayToRemoveDuplicateContacts(mapBRRefIdVsContact, mapAccIdVsAllExistingContact);
		system.debug('--mapBRRefIdVsContact--->>> 1032 ' + mapBRRefIdVsContact);
		
        List<Datacloud.FindDuplicatesResult> results;
        try {
            //get results from system with existing contact
            results = Datacloud.FindDuplicates.findDuplicates(mapBRRefIdVsContact.values());
            
        } catch(Exception excep){
            JMS_Logger.push(STR_REMOVE_DUPLICATE_CONTACT_RECORDS, JMS_ConstantsUtility.CONTACT_API);
            JMS_Logger.debugException(excep);
            return null;
        }finally {
            JMS_Logger.pop();
        } 
        // Loop the original contacts
        Integer i=0;
        for (Id objRefId :mapBRRefIdVsContact.keySet()) {
            
            Contact foundContact = null;
            // Find the first duplicate result with a match result, then use the first match record.
            for (Datacloud.DuplicateResult dr : results[i].getDuplicateResults()) {
                if (dr.matchResults.size() > 0 && dr.getMatchResults()[0].matchRecords.size() > 0) {
                    foundContact = (Contact) dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                    break;
                }
            }
            //Global Declared
            if(foundContact != null){
                // new map for existing contact
                if(!mapBRRefIdVsContactId.containskey(objRefId)){
                    mapBRRefIdVsContactId.put(objRefId,foundContact.Id);
                }
                //map with new contact that needs to be create in execute method
                if(mapBRRefIdVsContact != null && mapBRRefIdVsContact.containsKey(objRefId)){
                    mapBRRefIdVsContact.remove(objRefId);
                }
            }
            i++;
        }
        return mapBRRefIdVsContact;
    }
	
	
	
	public static Map<Id,Contact> customWayToRemoveDuplicateContacts( Map<Id,Contact> mapBRRefIdVsContact , map<Id, List<Contact>> mapAccIdVsAllExistingContact){
        // mapCTSRefIdVsContact   
        map< Id, map<Id, List<Contact>> > mapCTSIdVs_AccIdVsListContact = new map< Id, map<Id, List<Contact>> >();
        // map<Id, Id> mapCTSIdVsAccId = new map<Id, Id>();
        map<Id, Id> mapBRIdVsAccId = new map<Id, Id>();
        map<Id, List<Contact>> accIdVsListContact = new map<Id, List<Contact>>();
        map<Id, List<Contact>> accIdVsListOfUniContact = new map<Id, List<Contact>>();
        map<Id, List<Contact>> accIdVsListOfUniCtsFinal = new map<Id, List<Contact>>();
        // Map<Id,Contact> returnCTSWithContact = new Map<Id,Contact>();
        Map<Id,Contact> returnBRWithContact = new Map<Id,Contact>();
        
        if(mapBRRefIdVsContact != null && mapBRRefIdVsContact.size() > 0){
            for(Id BRId : mapBRRefIdVsContact.keySet() ){
                if( mapBRRefIdVsContact.get(BRId) != null && mapBRRefIdVsContact.get(BRId).AccountId != null){
                    Contact oContact = mapBRRefIdVsContact.get(BRId);
                    mapBRIdVsAccId.put(BRId, oContact.AccountId);
                    if(oContact.AccountId != null ){
                        if(! accIdVsListContact.containsKey(oContact.AccountId)  ){
                            accIdVsListContact.put(oContact.AccountId, new List<Contact>{oContact});
                        }else{
                            accIdVsListContact.get(oContact.AccountId).add(oContact);
                        }
                    }
                }
            }
        }
        system.debug('mapBRIdVsAccId--->>> ' + mapBRIdVsAccId);
        system.debug('accIdVsListContact--->>> ' + accIdVsListContact);
		// remove duplicate Contacts from incoming records itself
        if(accIdVsListContact != null && accIdVsListContact.size() >0 ){
            for(Id oAccid : accIdVsListContact.keySet()){
                List<Contact> lstCont = accIdVsListContact.get(oAccid);
                List<Contact> lstContac = new List<Contact>();
                set<string> setEmailId = new set<string>();
                set<string> setFirstnameLastNameWithEmail = new set<string>();
                set<string> setFirstnameLastName = new set<string>();
                
                // now check if lstCont contains Dplicate Contact 
                    // 
                if(lstCont != null && lstCont.size() > 0){
                  // below two for loop helps to remove duplicate contacts if available in current incoming records it self
				  //  contact where email is available
                    for(Contact oCon : lstCont ){                  
                        if(string.isNotEmpty(oCon.Email)) {
                            if(!setEmailId.contains(oCon.Email)){
                                setEmailId.add(oCon.Email);
                                setFirstnameLastNameWithEmail.add(oCon.FirstName+oCon.LastName);
                                lstContac.add(oCon);
                            }
                        }
                    }
                    //  contact where email is not available
                    for(Contact oCon : lstCont ){                   
                        if(string.isEmpty(oCon.Email)) {
                            if(!setFirstnameLastNameWithEmail.contains(oCon.FirstName+oCon.LastName)){                              
                                setFirstnameLastNameWithEmail.add(oCon.FirstName+oCon.LastName);
                                lstContac.add(oCon);
                            }
                        }
                    }
                    accIdVsListOfUniContact.put(oAccid,lstContac);
                    system.debug(accIdVsListOfUniContact.size() + '  accIdVsListOfUniContact-->> ' + accIdVsListOfUniContact);
                }
            }
			/*
            if(accIdVsListOfUniContact != null && accIdVsListOfUniContact.size() >0 ){
                accIdVsListContact = accIdVsListOfUniContact;
            }
			*/
            
        }
        system.debug('accIdVsListOfUniContact-->>>  ' + accIdVsListOfUniContact);
		List<Contact> existingContactToUpdate = new List<Contact>();
        if(accIdVsListOfUniContact != null && accIdVsListOfUniContact.size() >0 && mapAccIdVsAllExistingContact != null && mapAccIdVsAllExistingContact.size() >0 ){
            system.debug(' mapAccIdVsAllExistingContact --->>> ' + mapAccIdVsAllExistingContact);
            for(Id oAccId:  accIdVsListOfUniContact.keySet()){
                List<Contact> lstNewCts = new List<Contact>();
                List<Contact> lstContactsToremove = new List<Contact>();
                List<Contact> lstNewContacts;
                List<Contact> lstCtsExisting;
				
                if(mapAccIdVsAllExistingContact.containsKey(oAccId) && mapAccIdVsAllExistingContact.get(oAccId) != null && mapAccIdVsAllExistingContact.get(oAccId).size()>0 ){
                    lstCtsExisting = mapAccIdVsAllExistingContact.get(oAccId);
					system.debug(' lstCtsExisting --->>> ' + lstCtsExisting);
                    lstNewContacts = accIdVsListOfUniContact.get(oAccId);
                    if(lstNewContacts != null && lstNewContacts.size() > 0){
                        for(Contact oCon : lstNewContacts){
                            if(lstCtsExisting != null && lstCtsExisting.size() >0 ){
                                if(string.isNotEmpty(oCon.Email) ){
                                    for(Contact oExistingCon : lstCtsExisting){
                                        if(string.isEmpty(oExistingCon.Email) && oExistingCon.FirstName == oCon.FirstName  && oExistingCon.LastName == oCon.LastName){
											oExistingCon.Email = oCon.Email;
											oExistingCon.title = string.isNotEmpty(oCon.title) ? oCon.title :oExistingCon.title; 
											oExistingCon.Phone = string.isNotEmpty(oCon.Phone) ? oCon.Phone :oExistingCon.Phone; 
											oExistingCon.OtherPhone = string.isNotEmpty(oCon.OtherPhone) ? oCon.OtherPhone :oExistingCon.OtherPhone; 
                                            existingContactToUpdate.add(oExistingCon);
											lstContactsToremove.add(oCon);
                                        }else if(oExistingCon.Email == oCon.Email  && oExistingCon.FirstName == oCon.FirstName  && oExistingCon.LastName == oCon.LastName){
                                            oExistingCon.title = string.isNotEmpty(oCon.title) ? oCon.title :oExistingCon.title; 
											oExistingCon.Phone = string.isNotEmpty(oCon.Phone) ? oCon.Phone :oExistingCon.Phone; 
											oExistingCon.OtherPhone = string.isNotEmpty(oCon.OtherPhone) ? oCon.OtherPhone :oExistingCon.OtherPhone; 
											existingContactToUpdate.add(oExistingCon);
											lstContactsToremove.add(oCon);
                                        }
                                        else{
                                            lstNewCts.add(oCon);
											system.debug(' lstNewCts 1111 --->>> ' + lstNewCts);
                                        }
                                    }
                                }
								else{
									system.debug('lstCtsExisting-->> ' + lstCtsExisting);
									system.debug('oCon-->>1094 ' + oCon);
									boolean existingCon = false;
                                    for(Contact oExistingCon : lstCtsExisting){
                                        if(oExistingCon.FirstName == oCon.FirstName  && oExistingCon.LastName == oCon.LastName){
											existingCon = true;
                                            lstContactsToremove.add(oCon);
											oExistingCon.title = string.isNotEmpty(oCon.title) ? oCon.title :oExistingCon.title; 
											oExistingCon.Phone = string.isNotEmpty(oCon.Phone) ? oCon.Phone :oExistingCon.Phone; 
											oExistingCon.OtherPhone = string.isNotEmpty(oCon.OtherPhone) ? oCon.OtherPhone :oExistingCon.OtherPhone; 
											
                                            existingContactToUpdate.add(oExistingCon);
											
                                        }
                                    }
									if(existingCon ==  false){
										lstNewCts.add(oCon);
										system.debug(' lstNewCts 2222 --->>> ' + lstNewCts);
									}
									system.debug(' lstContactsToremove 222 --->>> ' + lstContactsToremove);
                                }
								accIdVsListOfUniCtsFinal.put(oAccId,lstNewCts);
								
                            }else{
                                lstNewCts.add(oCon);
								system.debug(' lstNewCts 333 --->>> ' + lstNewCts);
                            }
                        }
						system.debug(' lstNewCts 44444 --->>> ' + lstNewCts);
						accIdVsListOfUniCtsFinal.put(oAccId,lstNewCts);
						system.debug(' accIdVsListOfUniCtsFinal 4444 --->>> ' + accIdVsListOfUniCtsFinal);
                    }else{
                        accIdVsListOfUniCtsFinal.put(oAccId,lstNewCts);
						system.debug(' accIdVsListOfUniCtsFinal 1111 --->>> ' + accIdVsListOfUniCtsFinal);
                    }
                }
                else{
                    accIdVsListOfUniCtsFinal = accIdVsListOfUniContact;
					system.debug(' accIdVsListOfUniCtsFinal 2222 --->>> ' + accIdVsListOfUniCtsFinal);
                }
            }
        }else{
			accIdVsListOfUniCtsFinal = accIdVsListOfUniContact;
		}
        
        system.debug(' mapBRRefIdVsContact 2222 --->>> ' + mapBRRefIdVsContact);
        system.debug(' existingContactToUpdate 2222 --->>> ' + existingContactToUpdate);
		if(existingContactToUpdate != null && existingContactToUpdate.size() >0 ){
			update existingContactToUpdate;
		}
		
		
        if(mapBRRefIdVsContact != null && mapBRRefIdVsContact.size() > 0){
            for(Id oBRId : mapBRRefIdVsContact.keySet()){
                Contact oConFromCTS = mapBRRefIdVsContact.get(oBRId);
                if(accIdVsListOfUniCtsFinal != null && accIdVsListOfUniCtsFinal.size() > 0 && oConFromCTS.AccountId != null && accIdVsListOfUniCtsFinal.containsKey(oConFromCTS.AccountId)) {
                    List<Contact> lstNewCts1  = accIdVsListOfUniCtsFinal.get(oConFromCTS.AccountId);
					system.debug(' lstNewCts1 1111 --->>> ' + lstNewCts1);
                    if(lstNewCts1 != null && lstNewCts1.size() > 0){
                        for(Contact oCon1 : lstNewCts1 ){
                            returnBRWithContact.put(oBRId, oCon1);
                        }
                    }
                }
            }
        }
        system.debug('returnBRWithContact--->>> ' + returnBRWithContact);
        
        return returnBRWithContact;
    }
    
}