/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_MigrateCampTarStagingToSObjectBatch
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 19/04/2022
* @Description      : Batch class to migrate the Campaign Member Landing records
                      to Campaign Member staging Object
**********************************************************************************************************************
**********************************************************************************************************************/
//This is the batch class.
global with sharing class JMS_MigrateCampTarStagingToSObjectBatch implements database.Stateful,database.Batchable<Sobject> {
    //variables
    public static final String STR_MIGRATE_TO_CAMP_STAGING = 'JMS_MigrateToCmpgnMemStagingBatch Execute';
    public static final String STR_OBJECT_BROKER_CALL = 'Broker Call';
    public static final String STR_OBJECT_OPP_PRODUCT = 'Opportunity Product';
    public static final String STR_ANNUAL_VOLUME_FIELD = 'JMS_Annual_Volume__c';
    public static final String STR_KICKOUT_BROKER_ERROR_REPORT = 'Kickout Broker Report ';
    public static final String STR_KICKOUT_JMS_ERROR_REPORT = 'Kickout JMS Report ';
    public static final String STR_BROKER_SUCCESS_REPORT = 'Success Broker Report ';
    public static final String STR_JMS_SUCCESS_REPORT = 'Success JMS Report ';
    public static final String STR_REPORT_FORMAT_CSV = '.csv';
    public static final String STR_MIGRATE_TO_CAMPAIGN_TARGET_FINISH = 'JMS_MigratecAMPAIGNtARGETStgnToSObject finish';
    public static final String STR_START = 'Start';
    public static final String STR_FINISH = 'Finish';
   
    /*This variable to send BatchId from Execute method to finish method 
    To query in finish method to create and send reports*/
    public String strBatchId;
    public String strLocationAWS = JMS_ConstantsUtility.STR_AWS;
    //Variable Declaration of Metadata
    public static List<JMS_Staging_Metadata__mdt> listStagingMetadata;
    public static Map<Id,Id> mapCTSRefIdVsAccId;
    public static Map<Id,Id> mapCTSRefIdVsContactId;
    public static Map<Id,Id>  mapAccIdVsRefId;
    public static Map<Id,String> mapCTSRefIdVsCampaignId;
    //Variable Declaration
    JMS_Campaign_Target_Staging__c objCampTargetStaging = new JMS_Campaign_Target_Staging__c();
    Map<Id,String> mapCTSRefIdVsProductId = new Map<Id,String>();
    // Maps declared.
    Map<Id,Account> mapCTSRefIdVsAccount = new Map<Id,Account>();
    Map<Id,Contact> mapCTSRefIdVsContact = new Map<Id,Contact>();
    Map<Id,JMS_Broker_Call__c> mapCTSRefIdVsBrokerCall = new Map<Id,JMS_Broker_Call__c>();
    Map<Id,Opportunity> mapCTSRefIdVsOpportunity = new Map<Id,Opportunity>();
    Map<Id,CampaignMember> mapCTSRefIdVsCampaignMember = new Map<Id,CampaignMember>();
    Map<Id,OpportunityLineItem> mapCTSRefIdVsOppProduct = new Map<Id,OpportunityLineItem>();
    Map<Id,Id> mapProductIdVsPriceBookEntryId = new Map<Id,Id>();
    List<JMS_Campaign_Target_Staging__c> listUpdateCampTargetStaging = new List<JMS_Campaign_Target_Staging__c>();
    // constuctor declared
    
    public JMS_MigrateCampTarStagingToSObjectBatch(){
    }

    public JMS_MigrateCampTarStagingToSObjectBatch(String strLandingBatchId){
        mapCTSRefIdVsAccId = new Map<Id,Id>();
        mapCTSRefIdVsContactId = new Map<Id,Id>();
        mapAccIdVsRefId = new Map<Id,Id>();
        mapCTSRefIdVsCampaignId = new Map<Id,String>();
        if(String.isNotBlank(strLandingBatchId)){
            strBatchId = strLandingBatchId;
        }
    }

    // The start method.
    global database.QueryLocator start(database.batchablecontext BC){
        // Query to fetch unprocessed JMS_Campaign_Target_Staging__c 
        // records with Success Status
        String queryString = getStagingFields(STR_START ,JMS_ConstantsUtility.EMPTY_STRING);
        system.debug('11111queryString-->>> ' + queryString);
        return Database.getQueryLocator(queryString);
    }

    // The method starts from here.
    public static String getStagingFields(String requestSource ,String strBatchId ){
        String queryString = 'SELECT id';
        // The loops starts here.
        for(Schema.FieldSetMember fld :SObjectType.JMS_Campaign_Target_Staging__c.FieldSets.JMS_Campaign_Target_Staging_All_Fields.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }// The loop ends here.
        queryString += ' FROM JMS_Campaign_Target_Staging__c';
        if(requestSource == STR_START){
           queryString += ' WHERE JMS_Kickout_Location__c != : strLocationAWS AND';
           queryString += ' JMS_Record_Processed__c = false AND JMS_Status__c =  \'Success\'';
        }else{
            if(String.isNotBlank(strBatchId)){
                queryString += ' WHERE JMS_Batch_Id__c =: strBatchId';
                queryString += ' ORDER BY LastModifiedDate DESC';
            }
            queryString += ' LIMIT 50000';
        }
        //It returns the string for the query.
        return queryString;

    }
    // The method ends here.

    
    
    
    /***************************************************************************************************************
    *   @Name        :  Execute                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  To segregate record  of JMS_Campaign_Target_Staging__c to SObjects
    ***************************************************************************************************************/
    //This is the execute method.
    global void execute(Database.BatchableContext BC, List<SObject> scope){
		system.debug('execute execute started scope -->>> ' + scope);
        //initialize the variables
        objCampTargetStaging = new JMS_Campaign_Target_Staging__c();
        mapCTSRefIdVsProductId = new Map<Id,String>();
        mapCTSRefIdVsCampaignId = new Map<Id,String>();
        mapCTSRefIdVsAccount = new Map<Id,Account>();
        mapCTSRefIdVsContact = new Map<Id,Contact>();
        mapCTSRefIdVsBrokerCall = new Map<Id,JMS_Broker_Call__c>();
        mapCTSRefIdVsOpportunity = new Map<Id,Opportunity>();
        mapCTSRefIdVsContactId = new Map<Id,Id>();
        mapCTSRefIdVsAccId = new Map<Id,Id>();
        mapCTSRefIdVsCampaignMember = new Map<Id,CampaignMember>();
        mapCTSRefIdVsOppProduct = new Map<Id,OpportunityLineItem>();
        mapProductIdVsPriceBookEntryId = new Map<Id,Id>();
        listUpdateCampTargetStaging = new List<JMS_Campaign_Target_Staging__c>();
        mapAccIdVsRefId = new Map<Id,Id>();
        map<Id, List<Contact>> mapAccIdVsAllExistingContact = new map<Id, List<Contact>> ();
        
        //The Query
        // Fetch JMS_Staging_Metadata__mdt metadata record of JMS_Campaign_Target_Staging__c
        listStagingMetadata = new List<JMS_Staging_Metadata__mdt>([SELECT id,JMS_SF_Api_Name__c,JMS_Staging_Api_Field__c,JMS_IsActive__c,
                                                                        JMS_SFDC_Object__c,JMS_Object_Type__c,JMS_Constant_Value__c 
                                                                        FROM JMS_Staging_Metadata__mdt 
                                                                        WHERE JMS_Object_Type__c =: JMS_ConstantsUtility.OBJECT_CAMPAIGN_TARGET_STAGING_API
                                                                        AND JMS_IsActive__c = TRUE WITH SECURITY_ENFORCED LIMIT 50000]);

        // Process JMS_Campaign_Target_Staging__c records to create Sobject records
        // The Loop starts here.
        for(SObject objRec : scope){
            objCampTargetStaging = (JMS_Campaign_Target_Staging__c) objRec;
           
            //map of Campaign target Staging Id Vs Product Id
            if(String.isNotBlank(objCampTargetStaging.JMS_Product_SF_Id__c)){
                mapCTSRefIdVsProductId.put(objCampTargetStaging.Id,objCampTargetStaging.JMS_Product_SF_Id__c);
            } 
            //map of Campaign target Staging Id Vs Campaign Id
            if(String.isNotBlank(objCampTargetStaging.JMS_Campaign_SF_Id__c)){
                mapCTSRefIdVsCampaignId.put(objCampTargetStaging.Id,objCampTargetStaging.JMS_Campaign_SF_Id__c);
            } 
            //map of Campaign target Staging Id Vs Account
            if(String.isBlank(objCampTargetStaging.JMS_Account_SF_Id__c) && 
            String.isBlank(objCampTargetStaging.JMS_Operator_Error_Message__c)){
                Account objNewAccount =  getAccInstance(objCampTargetStaging);
                mapCTSRefIdVsAccount.put(objCampTargetStaging.Id,objNewAccount);  
            }else{
                mapAccIdVsRefId.put(objCampTargetStaging.JMS_Account_SF_Id__c ,objCampTargetStaging.Id); 
            }
            
            //map of Campaign target Staging Id Vs Contact
            if(String.isBlank(objCampTargetStaging.JMS_Contact_SF_ID__c) && 
                ( String.isNotBlank(objCampTargetStaging.JMS_Operator_Contact_First_Name__c) ||
                    String.isNotBlank(objCampTargetStaging.JMS_Operator_Contact_Last_Name__c))){
                Contact objNewContact =  getContInstance(objCampTargetStaging);
				system.debug('objNewContact--->>>   ' + objNewContact);
                mapCTSRefIdVsContact.put(objCampTargetStaging.Id,objNewContact);  
            }
            //map of Campaign target Staging Id Vs Broker call
            if(String.isNotBlank(objCampTargetStaging.JMS_Call_Made_By__c) && 
                objCampTargetStaging.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_BROKER) && 
                String.isBlank(objCampTargetStaging.JMS_SKU_Error_Message__c)){
                JMS_Broker_Call__c objNewBrokerCall = getBrokerCallInstance(objCampTargetStaging);
                mapCTSRefIdVsBrokerCall.put(objCampTargetStaging.Id,objNewBrokerCall);
            }
            //map of Campaign target Staging Id Vs Opportunity
            if(String.isNotBlank(objCampTargetStaging.JMS_Call_Made_By__c) && 
                String.isBlank(objCampTargetStaging.JMS_Operator_Error_Message__c) && 
                objCampTargetStaging.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_JMS) && 
                String.isBlank(objCampTargetStaging.JMS_SKU_Error_Message__c)){
                Opportunity objNewOpportunity = getOpportunityInstance(objCampTargetStaging);
                objNewOpportunity.JMS_Opportunity_Source__c = system.label.JMS_CampaignTargetProcess;
                mapCTSRefIdVsOpportunity.put(objCampTargetStaging.Id,objNewOpportunity);
            }           
            //map of Campaign target Staging Id Vs Opportunity Product
            if(String.isNotBlank(objCampTargetStaging.JMS_Product_SF_Id__c) &&
                String.isBlank(objCampTargetStaging.JMS_SKU_Error_Message__c)){
                    OpportunityLineItem objOLI = getOppProductInstance(objCampTargetStaging);
                    mapCTSRefIdVsOppProduct.put(objCampTargetStaging.Id,objOLI);
            }
            //map of Campaign target Staging Id Vs Campaign Member
            if(String.isNotBlank(objCampTargetStaging.JMS_Campaign_SF_Id__c) && 
                String.isBlank(objCampTargetStaging.JMS_Campaign_Error_Message__c)){
                CampaignMember objCampaign = getCampaignInstance(objCampTargetStaging);
                mapCTSRefIdVsCampaignMember.put(objCampTargetStaging.Id,objCampaign);
             }
             
        }
        
        if(mapAccIdVsRefId != null && mapAccIdVsRefId.size() > 0){
            List<Account> lstAccs =[select id, (select id, Title, FirstName, LastName, Email, Phone, OtherPhone from Contacts) from Account where id in : mapAccIdVsRefId.keySet()];
            if(lstAccs != null && lstAccs.size() > 0){
                for(Account oAcc:  lstAccs){
                    mapAccIdVsAllExistingContact.put(oAcc.Id, oAcc.Contacts);
                }
            }
        }
        system.debug(' mapAccIdVsAllExistingContact--->>> ' + mapAccIdVsAllExistingContact);
        
        
        // The Loop Ends here.
        //Check duplicate Acc ? if existis , get the AccID
        if(mapCTSRefIdVsAccount != null && !mapCTSRefIdVsAccount.isEmpty()){
            mapCTSRefIdVsAccount = removeDuplicateAccountRecords(mapCTSRefIdVsAccount);
        }
        try{
            //Insert Accounts - retrieve Account Ids
            if(mapCTSRefIdVsAccount != null && !mapCTSRefIdVsAccount.isEmpty()){
                Database.SaveResult[] savAccResList = Database.insert(mapCTSRefIdVsAccount.values(),TRUE);

                for(Account ObjAccRef:mapCTSRefIdVsAccount.values()){
                    mapAccIdVsRefId.put(ObjAccRef.Id ,ObjAccRef.JMS_Campaign_Target_Staging_Reference__c);
                }
            }
            if(mapCTSRefIdVsCampaignMember != null && !mapCTSRefIdVsCampaignMember.isEmpty()){
                for(Id objRefId :mapCTSRefIdVsCampaignMember.keySet()){
                    CampaignMember objCampMember = mapCTSRefIdVsCampaignMember.get(objRefId);
                    if(String.isBlank(objCampMember.AccountId) && mapCTSRefIdVsAccount != null &&
                        mapCTSRefIdVsAccount.containsKey(objRefId)){
                            objCampMember.AccountId = mapCTSRefIdVsAccount.get(objRefId).Id;
                    }else if(String.isBlank(objCampMember.AccountId) && mapCTSRefIdVsAccId != null &&
                        mapCTSRefIdVsAccId.containsKey(objRefId)){
                            objCampMember.AccountId = mapCTSRefIdVsAccId.get(objRefId);
                    }
                    //if Else for global and interal map
                    mapCTSRefIdVsCampaignMember.put(objRefId,objCampMember);
                }
            }
            if(mapCTSRefIdVsCampaignMember != null && !mapCTSRefIdVsCampaignMember.isEmpty()){
                mapCTSRefIdVsCampaignMember = removeExistingCMRecords(mapCTSRefIdVsCampaignMember);
            }
            if(mapCTSRefIdVsCampaignMember != null && !mapCTSRefIdVsCampaignMember.isEmpty()){
                Database.insert(mapCTSRefIdVsCampaignMember.values(),TRUE);
            }
            //Insert Contact stamp AccId to respective Contact Id
            if(mapCTSRefIdVsContact != null && !mapCTSRefIdVsContact.isEmpty()){
                for(Id objRefId : mapCTSRefIdVsContact.keySet()){
                    
                    Contact objContact = mapCTSRefIdVsContact.get(objRefId);
                    if(String.isBlank(objContact.AccountId) && mapCTSRefIdVsAccount != null &&
                        mapCTSRefIdVsAccount.containsKey(objRefId)){
                        objContact.AccountId = mapCTSRefIdVsAccount.get(objRefId).Id;
                    }else if(String.isBlank(objContact.AccountId) && mapCTSRefIdVsAccId != null &&
                        mapCTSRefIdVsAccId.containsKey(objRefId)){
                        objContact.AccountId = mapCTSRefIdVsAccId.get(objRefId);
                    }
                    //if Else for global and interal map
                    mapCTSRefIdVsContact.put(objRefId,objContact);
                }
            }
            
            if(mapCTSRefIdVsContact != null && !mapCTSRefIdVsContact.isEmpty()){
                // mapCTSRefIdVsContact = removeDuplicateContactRecords(mapCTSRefIdVsContact);
                mapCTSRefIdVsContact = removeDuplicateContactRecords(mapCTSRefIdVsContact,mapAccIdVsAllExistingContact );
            }
			system.debug('mapCTSRefIdVsContact--->>> ' + mapCTSRefIdVsContact);
            if(mapCTSRefIdVsContact != null && !mapCTSRefIdVsContact.isEmpty()){
                Database.insert(mapCTSRefIdVsContact.values(),TRUE);
            }
            // Insert Broker Call and stamp AccId
            if(mapCTSRefIdVsBrokerCall != null && !mapCTSRefIdVsBrokerCall.isEmpty()){
                for(Id objRefId : mapCTSRefIdVsBrokerCall.keySet()){
                    JMS_Broker_Call__c objBrokerCall = mapCTSRefIdVsBrokerCall.get(objRefId);
                    if(String.isBlank(objBrokerCall.Account__c) && mapCTSRefIdVsAccount.containsKey(objRefId)){
                        objBrokerCall.Account__c = mapCTSRefIdVsAccount.get(objRefId).Id;
                    }else if(String.isBlank(objBrokerCall.Account__c) && mapCTSRefIdVsAccId != null &&
                    mapCTSRefIdVsAccId.containsKey(objRefId)){
                        objBrokerCall.Account__c = mapCTSRefIdVsAccId.get(objRefId);
                    }
                    if(mapCTSRefIdVsContact != null && !mapCTSRefIdVsContact.isEmpty() && 
                        mapCTSRefIdVsContact.containsKey(objRefId)){
                        objBrokerCall.JMS_Contact__c = mapCTSRefIdVsContact.get(objRefId).Id;
                    }
                    else if(mapCTSRefIdVsContactId != null && !mapCTSRefIdVsContactId.isEmpty() && 
                        mapCTSRefIdVsContactId.containsKey(objRefId)){
                        objBrokerCall.JMS_Contact__c = mapCTSRefIdVsContactId.get(objRefId);
                    }
                    //if Else for global and interal map
                    mapCTSRefIdVsBrokerCall.put(objRefId,objBrokerCall);
                }
            }
            if(mapCTSRefIdVsBrokerCall != null && !mapCTSRefIdVsBrokerCall.isEmpty()){
                Database.insert(mapCTSRefIdVsBrokerCall.values(),TRUE);
            }
            // Mark Savepoint
            Savepoint sp = Database.setSavepoint();
            // Insert Opportunity and stamp AccId
            if(mapCTSRefIdVsOpportunity != null && !mapCTSRefIdVsOpportunity.isEmpty()){
                for(Id objRefId : mapCTSRefIdVsOpportunity.keySet()){
                    Opportunity objOpportunity = mapCTSRefIdVsOpportunity.get(objRefId);
                    if(String.isBlank(objOpportunity.AccountId) && mapCTSRefIdVsAccount.containsKey(objRefId)){
                        objOpportunity.AccountId = mapCTSRefIdVsAccount.get(objRefId).Id;
                    }else if(String.isBlank(objOpportunity.AccountId) && mapCTSRefIdVsAccId.containsKey(objRefId)){
                        objOpportunity.AccountId = mapCTSRefIdVsAccId.get(objRefId);
                    }
                
                    //if Else for global and interal map
                    mapCTSRefIdVsOpportunity.put(objRefId,objOpportunity);
                } 
            }
            if(mapCTSRefIdVsOpportunity != null && !mapCTSRefIdVsOpportunity.isEmpty()){
                Database.insert(mapCTSRefIdVsOpportunity.values(),TRUE);
            }
            
            if(mapCTSRefIdVsProductId != null && !mapCTSRefIdVsProductId.isEmpty()){
                for(PriceBookEntry objPriceBook :[SELECT Id, Product2Id 
                                                    FROM PriceBookEntry 
                                                    WHERE Product2Id IN:mapCTSRefIdVsProductId.values()
                                                    AND PriceBook2.isStandard=true WITH SECURITY_ENFORCED LIMIT 50000]){
                    mapProductIdVsPriceBookEntryId.put(objPriceBook.Product2Id,objPriceBook.Id);
                }                                   
            }
            if(mapCTSRefIdVsOppProduct != null && !mapCTSRefIdVsOppProduct.isEmpty()){
                for(Id objRefId : mapCTSRefIdVsOppProduct.keySet()){
                    OpportunityLineItem objOLI = mapCTSRefIdVsOppProduct.get(objRefId);
                    if(mapCTSRefIdVsOpportunity != null && mapCTSRefIdVsOpportunity.containsKey(objRefId) &&
                    mapProductIdVsPriceBookEntryId != null && mapProductIdVsPriceBookEntryId.containskey(objOLI.Product2Id)){
                        
                        objOLI.OpportunityId = mapCTSRefIdVsOpportunity.get(objRefId).Id;
                        objOLI.PricebookEntryId = mapProductIdVsPriceBookEntryId.get(objOLI.Product2Id) ;
                    }
                    //if Else for global and interal map
                    if(String.isBlank(objOLI.Product2Id) || String.isBlank(objOLI.OpportunityId) || 
                        String.isBlank(objOLI.PricebookEntryId)){
                        mapCTSRefIdVsOppProduct.remove(objRefId);
                    }else if(String.isNotBlank(objOLI.OpportunityId) && String.isNotBlank(objOLI.PricebookEntryId) &&
                        String.isNotBlank(objOLI.Product2Id)){
                        mapCTSRefIdVsOppProduct.put(objRefId,objOLI);
                    }
                } 
            }
            
            if(mapCTSRefIdVsOppProduct != null && !mapCTSRefIdVsOppProduct.isEmpty()){
                Database.SaveResult[] savAccResList = Database.insert(mapCTSRefIdVsOppProduct.values(),TRUE);
                for (Database.SaveResult sr : savAccResList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            Database.rollback(sp);
                        }
                    }
                }
            }
            /****Update Staging records with Account,Contact,Opportunity,Brokercall,Opportunity Product*****/
            for(SObject objRec : scope){
                objCampTargetStaging = (JMS_Campaign_Target_Staging__c) objRec;
                // Stamp Account Id in Staging record
                if(String.isBlank(objCampTargetStaging.JMS_Account_SF_Id__c)){
                    if(mapCTSRefIdVsAccount != null && !mapCTSRefIdVsAccount.isEmpty() && 
                    mapCTSRefIdVsAccount.containsKey(objCampTargetStaging.Id)){
                        objCampTargetStaging.JMS_Account_SF_Id__c = mapCTSRefIdVsAccount.get(objCampTargetStaging.Id).Id;
                    }
                    else if(mapCTSRefIdVsAccId != null && !mapCTSRefIdVsAccId.isEmpty() && 
                        mapCTSRefIdVsAccId.containsKey(objCampTargetStaging.Id)){
                            objCampTargetStaging.JMS_Account_SF_Id__c = mapCTSRefIdVsAccId.get(objCampTargetStaging.Id);
                    }
                   
                }
                // Stamp Contact Id in Staging record
               
                if(String.isBlank(objCampTargetStaging.JMS_Contact_SF_Id__c)){
                    if(mapCTSRefIdVsContact != null && !mapCTSRefIdVsContact.isEmpty() && 
                        mapCTSRefIdVsContact.containsKey(objCampTargetStaging.Id)){
                           
                        objCampTargetStaging.JMS_Contact_SF_Id__c = mapCTSRefIdVsContact.get(objCampTargetStaging.Id).Id;
                    }
                    else if(mapCTSRefIdVsContactId != null && !mapCTSRefIdVsContactId.isEmpty() && 
                        mapCTSRefIdVsContactId.containsKey(objCampTargetStaging.Id)){
                          
                        objCampTargetStaging.JMS_Contact_SF_Id__c = mapCTSRefIdVsContactId.get(objCampTargetStaging.Id);
                    }
                    
                }
                // Stamp Opportunity Id in Staging record
                if(String.isBlank(objCampTargetStaging.JMS_Opportunity_SF_Id__c)){
                    if(mapCTSRefIdVsOpportunity != null && !mapCTSRefIdVsOpportunity.isEmpty() && 
                    mapCTSRefIdVsOpportunity.containsKey(objCampTargetStaging.Id)){
                        objCampTargetStaging.JMS_Opportunity_SF_Id__c = mapCTSRefIdVsOpportunity.get(objCampTargetStaging.Id).Id;
                    }
                   
                }
                // Stamp Broker Call Id in Staging record
                if(String.isBlank(objCampTargetStaging.JMS_Broker_Call_SF_Id__c)){
                    if(mapCTSRefIdVsBrokerCall != null && !mapCTSRefIdVsBrokerCall.isEmpty() && 
                    mapCTSRefIdVsBrokerCall.containsKey(objCampTargetStaging.Id)){
                        
                        objCampTargetStaging.JMS_Broker_Call_SF_Id__c = mapCTSRefIdVsBrokerCall.get(objCampTargetStaging.Id).Id;
                    }
                }
                // Stamp Opportunity Product Id in Staging record
                if(String.isBlank(objCampTargetStaging.JMS_Opportunity_Product_SF_Id__c) && 
                    String.isNotBlank(objCampTargetStaging.JMS_Opportunity_SF_Id__c)){
                    if(mapCTSRefIdVsOppProduct != null && !mapCTSRefIdVsOppProduct.isEmpty() && 
                    mapCTSRefIdVsOppProduct.containsKey(objCampTargetStaging.Id)){
                        objCampTargetStaging.JMS_Opportunity_Product_SF_Id__c = mapCTSRefIdVsOppProduct.get(objCampTargetStaging.Id).Id;
                    }            
                }
                // Check if complete record are process for Broker
                if(String.isNotBlank(objCampTargetStaging.JMS_Account_SF_Id__c) &&
                String.isNotBlank(objCampTargetStaging.JMS_Broker_Call_SF_Id__c) &&
                String.isBlank(objCampTargetStaging.JMS_Opportunity_SF_Id__c)){
                        objCampTargetStaging.JMS_Record_Processed__c = true;

                }
                 // Check if complete record are process for BEM if don't have product associated
                else if(String.isNotBlank(objCampTargetStaging.JMS_Account_SF_Id__c) &&
                    String.isBlank(objCampTargetStaging.JMS_Product_SF_Id__c) &&
                    String.isNotBlank(objCampTargetStaging.JMS_Opportunity_SF_Id__c) &&
                    String.isBlank(objCampTargetStaging.JMS_Opportunity_Product_SF_Id__c)){
                        objCampTargetStaging.JMS_Record_Processed__c = true;

                }
                 // Check if complete record are process for BEM with product associated
                else if(String.isNotBlank(objCampTargetStaging.JMS_Account_SF_Id__c) &&
                    String.isNotBlank(objCampTargetStaging.JMS_Product_SF_Id__c) &&
                    String.isNotBlank(objCampTargetStaging.JMS_Opportunity_SF_Id__c) &&
                    String.isNotBlank(objCampTargetStaging.JMS_Opportunity_Product_SF_Id__c)){
                        objCampTargetStaging.JMS_Record_Processed__c = true;
                }
                else{
                    objCampTargetStaging.JMS_Record_Processed__c = false;
                }
                
                listUpdateCampTargetStaging.add(objCampTargetStaging);
            }
            if(listUpdateCampTargetStaging != null && !listUpdateCampTargetStaging.isEmpty()){
                Database.update(listUpdateCampTargetStaging , true);
            }
            
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
        }catch(Exception excep){
            JMS_Campaign_Target_Staging__c objCampTarStagUpdateError = objCampTargetStaging;
            String strErrorMsg = excep.getMessage();
            if(strErrorMsg.contains(JMS_ConstantsUtility.STR_COMMA_STRING)){
                strErrorMsg = strErrorMsg.replace(JMS_ConstantsUtility.STR_COMMA_STRING,JMS_ConstantsUtility.SPACE_STRING);
            }
            objCampTarStagUpdateError.JMS_Kickout_Failed_Reason__c =  strErrorMsg;
            objCampTarStagUpdateError.JMS_Status__c = JMS_ConstantsUtility.STR_STATUS_ERROR;
            objCampTarStagUpdateError.JMS_Record_Processed__c = false;
            update objCampTarStagUpdateError;
            
           JMS_Logger.push(STR_MIGRATE_TO_CAMP_STAGING, JMS_ConstantsUtility.OBJECT_CAMPAIGN_TARGET_STAGING_API);
           JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }  
    }
    //This is the end of execute method.
    
    /***************************************************************************************************************
    *   @Name        :  Finish                                                              
    *   @Return      :  void                                                                                       
    *   @Description :                               
    ***************************************************************************************************************/
    //This is the finish method.
    //The method starts from here.
    
    global void finish(Database.BatchableContext BC){
        JMS_SendEmailNotification objSendNotication = new JMS_SendEmailNotification();
        JMS_Delete_SObject_Records objDeleteRecordBatch = new JMS_Delete_SObject_Records(JMS_ConstantsUtility.OBJECT_CAMPAIGN_TARGET_LANDING_API,null);
        //Try Block Start
        try{
            Database.executeBatch(objDeleteRecordBatch);
        
            //Waiting for JMS decision on report .Once it is cleared we removed it or uncomment it.
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName != NULL LIMIT 1];
            //Waiting for JMS decision on report .Once it is cleared we removed it or uncomment it.
            //Query on Email Template
            EmailTemplate objCTEmailTemplate = [SELECT Id, HtmlValue, Subject ,Body FROM EmailTemplate 
                                                        WHERE DeveloperName =: System.Label.JMS_Campaign_Target_Report_Email_Template LIMIT 1];
            //Query String to get Broker Call Staging Fields from field set                                          
            String queryString = getStagingFields(STR_FINISH, this.strBatchId); 
            // To fetch Broker Call Stging records
            List<JMS_Campaign_Target_Staging__c> stglist = Database.query(queryString);
            // Headers of Error report 
            string kickoutHeader = JMS_ConstantsUtility.CAMPAIGN_TARGET_KICKOUT_HEADERS;
            // Headers of Success report 
            // 
            string successHeader = JMS_ConstantsUtility.CAMPAIGN_TARGET_SUCCESS_HEADERS;
            string finalbrokersuccesstStr = JMS_ConstantsUtility.EMPTY_STRING;
            string finalbrokererrorStr = JMS_ConstantsUtility.EMPTY_STRING;
            string finalJMSsuccessStr = JMS_ConstantsUtility.EMPTY_STRING;
            string finalJMSerrorStr = JMS_ConstantsUtility.EMPTY_STRING;
            String strStagingRecordString = JMS_ConstantsUtility.EMPTY_STRING;
            List<Messaging.EmailFileAttachment> listErrSuccssReportsForCT = new List<Messaging.EmailFileAttachment>();
            
            if(stglist != null && !stglist.isEmpty()){
                for(JMS_Campaign_Target_Staging__c stgRec: stglist){
                    string strBrokerSuccess = JMS_ConstantsUtility.EMPTY_STRING;
                    string strBrokerError = JMS_ConstantsUtility.EMPTY_STRING;
                    string strJMSSuccess = JMS_ConstantsUtility.EMPTY_STRING;
                    string strJMSError = JMS_ConstantsUtility.EMPTY_STRING;
                    string csvLine = JMS_ConstantsUtility.EMPTY_STRING;
                    strStagingRecordString = JMS_ConstantsUtility.EMPTY_STRING;

                    if(String.isNotBlank(stgRec.JMS_Call_Made_By__c) && String.isNotBlank(stgRec.JMS_Status__c)){
                        if(stgRec.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_BROKER) && 
                            stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR) ){

                            strStagingRecordString = getStagingRecordString(stgRec);
                                if(String.isNotBlank(strStagingRecordString)){
                                strBrokerError = JMS_ConstantsUtility.STR_FIRST_QUOTE + stgRec.JMS_Kickout_Failed_Reason__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                                                    stgRec.JMS_Kickout_Location__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + strStagingRecordString;
                                }  
                        }else if(stgRec.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_JMS) && 
                            stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_ERROR) ){
                            strStagingRecordString = getStagingRecordString(stgRec);
                            if(String.isNotBlank(strStagingRecordString)){
                            strJMSError = JMS_ConstantsUtility.STR_FIRST_QUOTE + stgRec.JMS_Kickout_Failed_Reason__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
                                            stgRec.JMS_Kickout_Location__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + strStagingRecordString;
                            }  
                        }else if(stgRec.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_BROKER) && 
                            stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_SUCCESS)){
                            strStagingRecordString = getStagingRecordString(stgRec);
                            if(String.isNotBlank(strStagingRecordString)){
                                strBrokerSuccess = JMS_ConstantsUtility.STR_FIRST_QUOTE + strStagingRecordString;
                            }
                        }else if(stgRec.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_JMS) && 
                            stgRec.JMS_Status__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_STATUS_SUCCESS)){
                            strStagingRecordString = getStagingRecordString(stgRec);
                            if(String.isNotBlank(strStagingRecordString)){
                                strJMSSuccess = JMS_ConstantsUtility.STR_FIRST_QUOTE + strStagingRecordString;
                            }
                        }
                        if(String.isNotBlank(strBrokerError)){
                            finalbrokererrorStr = finalbrokererrorStr + strBrokerError.replace(JMS_ConstantsUtility.NULL_STRING, JMS_ConstantsUtility.EMPTY_STRING);
                        }
                        if(String.isNotBlank(strJMSError)){
                            finalJMSerrorStr = finalJMSerrorStr + strJMSError.replace(JMS_ConstantsUtility.NULL_STRING, JMS_ConstantsUtility.EMPTY_STRING);
                        
                            }
                        if(String.isNotBlank(strBrokerSuccess)){
                            finalbrokersuccesstStr = finalbrokersuccesstStr + strBrokerSuccess.replace(JMS_ConstantsUtility.NULL_STRING, JMS_ConstantsUtility.EMPTY_STRING);
                        }
                        if(String.isNotBlank(strJMSSuccess)){
                            finalJMSsuccessStr = finalJMSsuccessStr + strJMSSuccess.replace(JMS_ConstantsUtility.NULL_STRING, JMS_ConstantsUtility.EMPTY_STRING);
                        }
                    }
                }
            }
            //Kickout Attachment
            Messaging.EmailFileAttachment reportCsvAttc1 = new Messaging.EmailFileAttachment();
            if(String.isNotBlank(finalbrokererrorStr)){
                finalbrokererrorStr = kickoutHeader + finalbrokererrorStr;
                blob brokererrorreportCsvBlob = Blob.valueOf(finalbrokererrorStr);
                string brokerErrorReportCsvName = STR_KICKOUT_BROKER_ERROR_REPORT + System.now() + STR_REPORT_FORMAT_CSV;
                reportCsvAttc1.setFileName(brokerErrorReportCsvName);
                reportCsvAttc1.setBody(brokererrorreportCsvBlob);
                listErrSuccssReportsForCT.add(reportCsvAttc1);
            }    
            
            Messaging.EmailFileAttachment reportCsvAttc2 = new Messaging.EmailFileAttachment();
            if(String.isNotBlank(finalJMSerrorStr)){
                finalJMSerrorStr = kickoutHeader + finalJMSerrorStr;
                blob jmserrorreportCsvBlob = Blob.valueOf(finalJMSerrorStr);
                string jmsErrorReportCsvName = STR_KICKOUT_JMS_ERROR_REPORT + System.now() + STR_REPORT_FORMAT_CSV;
                reportCsvAttc2.setFileName(jmsErrorReportCsvName);
                reportCsvAttc2.setBody(jmserrorreportCsvBlob);
                listErrSuccssReportsForCT.add(reportCsvAttc2);
            }
            
            Messaging.EmailFileAttachment reportCsvAttc3 = new Messaging.EmailFileAttachment();
            if(String.isNotBlank(finalbrokersuccesstStr)){
                finalbrokersuccesstStr = successHeader + finalbrokersuccesstStr;
                blob brokersuccessreportCsvBlob = Blob.valueOf(finalbrokersuccesstStr);
                string brokerSuccessreportCsvName = STR_BROKER_SUCCESS_REPORT + System.now() + STR_REPORT_FORMAT_CSV;
                reportCsvAttc3.setFileName(brokerSuccessreportCsvName);
                reportCsvAttc3.setBody(brokersuccessreportCsvBlob);
                listErrSuccssReportsForCT.add(reportCsvAttc3);
            }
            Messaging.EmailFileAttachment reportCsvAttc4 = new Messaging.EmailFileAttachment();
            if(String.isNotBlank(finalJMSsuccessStr)){
                finalJMSsuccessStr = successHeader + finalJMSsuccessStr;
                blob jmssuccessreportCsvBlob = Blob.valueOf(finalJMSsuccessStr);
                string jmsSuccessreportCsvName = STR_JMS_SUCCESS_REPORT + System.now() + STR_REPORT_FORMAT_CSV;
                reportCsvAttc4.setFileName(jmsSuccessreportCsvName);
                reportCsvAttc4.setBody(jmssuccessreportCsvBlob);
                listErrSuccssReportsForCT.add(reportCsvAttc4);
            }
            
            //Email Service     
            //Success Attachment
             //Email Service
             if(listErrSuccssReportsForCT != null && !listErrSuccssReportsForCT.isEmpty() && objCTEmailTemplate != null){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> toAddresses = new List<String>();
                String strCampTargetEmailAddresses = System.Label.JMS_Campaign_Target_Email_Address;
                if(strCampTargetEmailAddresses.contains(JMS_ConstantsUtility.SEMICOLAN)){
                   toAddresses.addAll(strCampTargetEmailAddresses.split(JMS_ConstantsUtility.SEMICOLAN));
                }else{
                   toAddresses.add(strCampTargetEmailAddresses);
                }
                String strBody =  objCTEmailTemplate.HtmlValue;
                if(String.isNotBlank(this.strBatchId)){
                   strBody = strBody.replace(JMS_ConstantsUtility.STR_BATCH_ID,JMS_ConstantsUtility.COLON + JMS_ConstantsUtility.SPACE_STRING + this.strBatchId);
                }
                // set sender Id
                email.setOrgWideEmailAddressId(owea[0].Id);
                email.setSubject(objCTEmailTemplate.Subject);
                email.setToAddresses( toAddresses );
                email.setHtmlBody(strBody);
                //email.setPlainTextBody('Please find the attached Broker Call Kick out Report. ');
                email.setFileAttachments(listErrSuccssReportsForCT);
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
             }
            
        }catch(Exception excep){
            JMS_Logger.push(STR_MIGRATE_TO_CAMPAIGN_TARGET_FINISH, JMS_ConstantsUtility.OBJECT_CAMPAIGN_TARGET_STAGING_API);
            JMS_Logger.debugException(excep);
        
        }finally {
            JMS_Logger.pop();
        }  
}//The finish method ends here.
    
     /*****************************************************************
    *   @Name        :  getStagingRecordString                                                              
    *   @Return      :  string                                                                                      
    *   @Description :  Create a record dtring with comman separated values 
                        to create report attachment 
    *******************************************************************/
    //The method starts from here.
    public static string getStagingRecordString(JMS_Campaign_Target_Staging__c stgRec){
        String strRecordString = JMS_ConstantsUtility.EMPTY_STRING;
        strRecordString = stgRec.JMS_Batch_Id__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Campaign_Name__c + 
        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Campaign_Target_ID__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
        stgRec.JMS_Call_Made_By__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_FireFlyId__c + 
        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Operator_Name__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
        stgRec.JMS_Operator_Address__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Operator_City__c + 
        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Operators_State__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
        stgRec.JMS_Operator_Zip__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_Country__c +
        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Company_Type__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
        stgRec.JMS_Operator_Phone__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Operator_Contact_First_Name__c + 
        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Operator_Contact_Last_Name__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
        stgRec.JMS_Operator_Contact_Email_Address__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Operator_Contact_Title__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Operator_Contact_Phone_Number__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Operator_Contact_Phone_Number_Ext__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
        stgRec.JMS_Operator_Contact_Mobile_Phone_Number__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE +  stgRec.JMS_Smucker_SKU__c + 
        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Product_Description__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + 
        stgRec.JMS_Annual_Volume__c + JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_WRAP_Target__c + 
        JMS_ConstantsUtility.STR_COMMA_WITH_QUOTE + stgRec.JMS_Competitor_Name__c + JMS_ConstantsUtility.STR_END_NEWLINE_QUOTE ;       
        return strRecordString;
    }// The method ends here.

   /*****************************************************************
    *   @Name        :  getCampaignTargetAttachment                                                              
    *   @Return      :  Messaging.EmailFileAttachment                                                                                      
    *   @Description :  Create an email attachment from record string 
                        in format of CSV
    *******************************************************************/
    //The method starts from here.
    public static Messaging.EmailFileAttachment getCampaignTargetAttachment(String finalReportStr , String strReportName){
        Messaging.EmailFileAttachment reportCsvAttc = new Messaging.EmailFileAttachment();
        blob reportCsvBlob = Blob.valueOf(finalReportStr);
        string reportCsvName = strReportName + System.now() + STR_REPORT_FORMAT_CSV;
        reportCsvAttc.setFileName(reportCsvName);
        reportCsvAttc.setBody(reportCsvBlob);

        // It returns the message with the attachment.
        return reportCsvAttc;

    }// The method ends here.

    /*****************************************************************
    *   @Name        :  getAccInstance                                                              
    *   @Return      :  Account                                                                                      
    *   @Description :  To create Account records with Metadata 
                        field mapping & JMS_Campaign_Target_Staging__c 
                        records
    *******************************************************************/
    //The method starts from here.
    public static Account getAccInstance(JMS_Campaign_Target_Staging__c objCampTargStaging){
        // Get Operator record Type Id
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('JMS_Operator').getRecordTypeId();
        Account objNewAccount =  new Account();
        objNewAccount.recordTypeId = recordTypeId;
        objNewAccount.JMS_Campaign_Target_Staging_Reference__c =  objCampTargStaging.Id;
        objNewAccount.JMS_Skip_Standard_Account_Duplicate_Rule__c =  true;
        //The loop starts from here.
        for(JMS_Staging_Metadata__mdt mdtRec : listStagingMetadata){
            if (mdtRec.JMS_SFDC_Object__c.equalsIgnoreCase(JMS_ConstantsUtility.ACCOUNT_API)) {
                if (String.isBlank(mdtRec.JMS_Constant_Value__c) &&  
                    objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c) != null) {
                    objNewAccount.put(mdtRec.JMS_SF_Api_Name__c, objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c ) );
                }else if(String.isNotBlank(mdtRec.JMS_Constant_Value__c)){
                    objNewAccount.put(mdtRec.JMS_SF_Api_Name__c, mdtRec.JMS_Constant_Value__c );
                }
            }
        }
        //The loop ends here.
        return objNewAccount;
    }// The method ends here.

    /*****************************************************************
    *   @Name        :  getContInstance                                                              
    *   @Return      :  Contact                                                                                      
    *   @Description :  To create Contact records with Metadata 
                        field mapping & JMS_Campaign_Target_Staging__c 
                        records
    *******************************************************************/
    // The method starts from here.
    public static Contact getContInstance(JMS_Campaign_Target_Staging__c objCampTargStaging){
        Contact objNewContact =  new Contact();
        if(String.isNotBlank(objCampTargStaging.JMS_Account_SF_Id__c)){
            objNewContact.AccountId = objCampTargStaging.JMS_Account_SF_Id__c;        
        }
        //The loop starts from here.
        for(JMS_Staging_Metadata__mdt mdtRec : listStagingMetadata){
            // The conditional block starts here.
            if (mdtRec.JMS_SFDC_Object__c.equalsIgnoreCase(JMS_ConstantsUtility.CONTACT_API)) {
				system.debug('mdtRec.JMS_Staging_Api_Field__c-->>> ' + mdtRec.JMS_Staging_Api_Field__c);
                system.debug('objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c )-->>> ' + objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c ));
				system.debug('mdtRec.JMS_SF_Api_Name__c-->>> ' + mdtRec.JMS_SF_Api_Name__c);
                if (String.isBlank(mdtRec.JMS_Constant_Value__c) &&  
                objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c) != null) {
                    objNewContact.put(mdtRec.JMS_SF_Api_Name__c, objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c ));
                }else if(String.isNotBlank(mdtRec.JMS_Constant_Value__c)){
                    objNewContact.put(mdtRec.JMS_SF_Api_Name__c, mdtRec.JMS_Constant_Value__c );
                }
            } // The conditional block ends here.
            
        }// The loop ends here.
        return objNewContact;
    }// The method ends here.

    /*****************************************************************
    *   @Name        :  getBrokerCallInstance                                                              
    *   @Return      :  JMS_Broker_Call__c                                                                                      
    *   @Description :  To create JMS_Broker_Call__c records with Metadata 
                        field mapping & JMS_Campaign_Target_Staging__c 
                        records
    *******************************************************************/
    //The method starts from here.
    public static JMS_Broker_Call__c getBrokerCallInstance(JMS_Campaign_Target_Staging__c objCampTargStaging){        
        JMS_Broker_Call__c objNewBrokerCall =  new JMS_Broker_Call__c();
        // Map Product Id to BrokerCall Item Number
        // Checks if it's blank.
        if(String.isNotBlank(objCampTargStaging.JMS_Product_SF_Id__c)){
            objNewBrokerCall.JMS_Item_Number__c = objCampTargStaging.JMS_Product_SF_Id__c;
        }
        // Map Campaign Id to BrokerCall Campaign Field
        if(String.isNotBlank(objCampTargStaging.JMS_Campaign_SF_Id__c)){
            objNewBrokerCall.JMS_Campaign__c = objCampTargStaging.JMS_Campaign_SF_Id__c;
        }
        // Map Account Id to BrokerCall Account Field
        if(String.isNotBlank(objCampTargStaging.JMS_Account_SF_Id__c)){
            objNewBrokerCall.Account__c = objCampTargStaging.JMS_Account_SF_Id__c;
        }
        
        //The loop starts here.
        for(JMS_Staging_Metadata__mdt mdtRec : listStagingMetadata){
            if (mdtRec.JMS_SFDC_Object__c.equalsIgnoreCase(STR_OBJECT_BROKER_CALL)) {
                if (String.isBlank(mdtRec.JMS_Constant_Value__c) &&  
                objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c) != null) {
                    objNewBrokerCall.put(mdtRec.JMS_SF_Api_Name__c, objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c ));
                }else if(String.isNotBlank(mdtRec.JMS_Constant_Value__c)){
                    objNewBrokerCall.put(mdtRec.JMS_SF_Api_Name__c, mdtRec.JMS_Constant_Value__c );
                }
            }
        }// The loop ends here.
        return objNewBrokerCall;
    }//The method ends here.

     /*****************************************************************
    *   @Name        :  getOpportunityInstance                                                              
    *   @Return      :  Opportunity                                                                                      
    *   @Description :  To create Opportunity records with Metadata 
                        field mapping & JMS_Campaign_Target_Staging__c 
                        records
    *******************************************************************/
    //The method starts from here.
    public static Opportunity getOpportunityInstance(JMS_Campaign_Target_Staging__c objCampTargStaging){   
        Opportunity objNewOpp =  new Opportunity();
        if(String.isNotBlank(objCampTargStaging.JMS_Account_SF_Id__c)){
            objNewOpp.AccountId = objCampTargStaging.JMS_Account_SF_Id__c;
        }
        // Map Campaign Id to BrokerCall Campaign Field
        if(String.isNotBlank(objCampTargStaging.JMS_Campaign_SF_Id__c)){
            objNewOpp.CampaignId = objCampTargStaging.JMS_Campaign_SF_Id__c;
        }
        if(String.isNotBlank(objCampTargStaging.JMS_Campaign_Target_ID__c)){
            objNewOpp.JMS_Campaign_Target_Id__c = objCampTargStaging.JMS_Campaign_Target_ID__c;
        }
        
        objNewOpp.Name = objCampTargStaging.JMS_Campaign_Name__c + JMS_ConstantsUtility.SPACE_STRING + 
                            JMS_ConstantsUtility.SINGLE_DASH_STRING + JMS_ConstantsUtility.SPACE_STRING + 
                            objCampTargStaging.JMS_Operator_Name__c;
        objNewOpp.CloseDate =  Date.today().addMonths(1);
        objNewOpp.StageName =  JMS_ConstantsUtility.STR_QUALIFICATION;
        objNewOpp.JMS_Call_Type__c = objCampTargStaging.JMS_Opportunity_Type__c ;
        //Add the objNewAccount to the Insert Account List
        
        return objNewOpp;
    }// The method ends here.

     /*****************************************************************
    *   @Name        :  getCampaignInstance                                                              
    *   @Return      :  CampaignMember                                                                                      
    *   @Description :  To create CampaignMember records with Metadata 
                        field mapping & JMS_Campaign_Target_Staging__c 
                        records
    *******************************************************************/
    //The method starts from here.
    public static CampaignMember getCampaignInstance(JMS_Campaign_Target_Staging__c objCampTargStaging){   
        CampaignMember objNewCampaignMem =  new CampaignMember();
        if(String.isNotBlank(objCampTargStaging.JMS_Account_SF_Id__c)){
            objNewCampaignMem.AccountId = objCampTargStaging.JMS_Account_SF_Id__c;
        }
        // Map Campaign SF Id to CampaignMember Campaign Field
        if(String.isNotBlank(objCampTargStaging.JMS_Campaign_SF_Id__c)){
            objNewCampaignMem.CampaignId = objCampTargStaging.JMS_Campaign_SF_Id__c;
        }
        objNewCampaignMem.Status = JMS_ConstantsUtility.STR_STATUS_SENT;
        return objNewCampaignMem;
    }
    //The method ends here.

    /*****************************************************************
    *   @Name        :  getOppProductInstance                                                              
    *   @Return      :  OpportunityLineItem                                                                                      
    *   @Description :  To create OpportunityLineItem with Metadata 
                        field mapping & JMS_Campaign_Target_Staging__c 
                        records
    *******************************************************************/
    //the method starts from here.
    public static OpportunityLineItem getOppProductInstance(JMS_Campaign_Target_Staging__c objCampTargStaging){   
        OpportunityLineItem objNewOLI =  new OpportunityLineItem();
        objNewOLI.UnitPrice = 0;
        if(String.isNotBlank(objCampTargStaging.JMS_Product_SF_Id__c)){
            objNewOLI.Product2Id = objCampTargStaging.JMS_Product_SF_Id__c;
        }
        //The loop starts here.
        for(JMS_Staging_Metadata__mdt mdtRec : listStagingMetadata){
            if(mdtRec.JMS_SFDC_Object__c.equalsIgnoreCase(STR_OBJECT_OPP_PRODUCT)) {
                if (String.isBlank(mdtRec.JMS_Constant_Value__c) &&  
                    objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c) != null) {
                        if(mdtRec.JMS_Staging_Api_Field__c == STR_ANNUAL_VOLUME_FIELD){
                            Decimal decQuantity = Decimal.valueOf(objCampTargStaging.JMS_Annual_Volume__c);
                            objNewOLI.put(mdtRec.JMS_SF_Api_Name__c, decQuantity);
                        }else{
                            objNewOLI.put(mdtRec.JMS_SF_Api_Name__c, objCampTargStaging.get(mdtRec.JMS_Staging_Api_Field__c ));
                        }
                
                }else if(String.isNotBlank(mdtRec.JMS_Constant_Value__c) &&
                    mdtRec.JMS_SF_Api_Name__c != STR_ANNUAL_VOLUME_FIELD){
                    objNewOLI.put(mdtRec.JMS_SF_Api_Name__c, mdtRec.JMS_Constant_Value__c );
                }
            }
            
        }
        //the loop ends here.
        return objNewOLI;
    } //The method ends here.

    /*****************************************************************
    *   @Name        :  removeDuplicateAccountRecords                                                              
    *   @Return      :  Map<Id,Account>                                                                                       
    *   @Description :  To find and remove duplicate Account record from 
                        mapCTSRefIdVsAccount and add in
                         mapCTSRefIdVsAccountId
    *******************************************************************/
    // The method starts from here.
    public static Map<Id,Account> removeDuplicateAccountRecords(Map<Id,Account> mapCTSRefIdVsAccount) {
       
        List<Datacloud.FindDuplicatesResult> results;
        // Try Block
        try {
            results = Datacloud.FindDuplicates.findDuplicates(mapCTSRefIdVsAccount.values());
        } catch(Exception excep){
            JMS_Logger.push(STR_MIGRATE_TO_CAMP_STAGING, JMS_ConstantsUtility.OBJECT_TERRITORY2_ASSOCIATION_API);
            JMS_Logger.debugException(excep);
         
        }finally {
            JMS_Logger.pop();
        } 
        
        if(results != null && !results.isEmpty()){
            for (Integer i = 0; i < mapCTSRefIdVsAccount.values().size(); i++) {
                Account foundAccount = null;
                // Find the first duplicate result with a match result, then use the first match record.
                // The loop starts here.
                for (Datacloud.DuplicateResult dr : results[i].getDuplicateResults()) {
                    if (dr.matchResults.size() > 0 && dr.getMatchResults()[0].matchRecords.size() > 0) {
                        foundAccount = (Account) dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                        break;
                    }
                } // The loop ends here.
                //Global Declared
                if(foundAccount != null){
                    if(!mapCTSRefIdVsAccId.containskey(mapCTSRefIdVsAccount.values()[i].JMS_Campaign_Target_Staging_Reference__c)){
                        mapCTSRefIdVsAccId.put(mapCTSRefIdVsAccount.values()[i].JMS_Campaign_Target_Staging_Reference__c,foundAccount.Id);
                        mapAccIdVsRefId.put(foundAccount.Id ,mapCTSRefIdVsAccount.values()[i].JMS_Campaign_Target_Staging_Reference__c );
                    }
                    if(mapCTSRefIdVsAccount != null && mapCTSRefIdVsAccount.containsKey(mapCTSRefIdVsAccount.values()[i].JMS_Campaign_Target_Staging_Reference__c)){
                        mapCTSRefIdVsAccount.remove(mapCTSRefIdVsAccount.values()[i].JMS_Campaign_Target_Staging_Reference__c);
    
                    }
    
                }
            }
        }
        
        return mapCTSRefIdVsAccount;
    }// The method ends here.

    /*****************************************************************
    *   @Name        :  removeDuplicateContactRecords                                                              
    *   @Return      :  Map<Id,Contact>                                                                                       
    *   @Description :  To find and remove duplicate contact record from 
                        mapCTSRefIdVsContact  and add in
                         mapCTSRefIdVsContactId
    *******************************************************************/
    //The method starts from here.
    // public static Map<Id,Contact> removeDuplicateContactRecords(Map<Id,Contact> mapCTSRefIdVsContact)
    // removeDuplicateContactRecords(mapCTSRefIdVsContact, );
    public static Map<Id,Contact> removeDuplicateContactRecords(Map<Id,Contact> mapCTSRefIdVsContact, map<Id, List<Contact>> mapAccIdVsAllExistingContact) {
       
       system.debug(' mapCTSRefIdVsContact--->>>1111 ' + mapCTSRefIdVsContact);
       mapCTSRefIdVsContact = customWayToRemoveDuplicateContacts(mapCTSRefIdVsContact, mapAccIdVsAllExistingContact);
       system.debug(' mapCTSRefIdVsContact--->>>2222 ' + mapCTSRefIdVsContact);
       
        List<Datacloud.FindDuplicatesResult> results;
        //Try Block 
        try {
            results = Datacloud.FindDuplicates.findDuplicates(mapCTSRefIdVsContact.values());
        } catch(Exception excep){
            JMS_Logger.push(STR_MIGRATE_TO_CAMP_STAGING, JMS_ConstantsUtility.OBJECT_TERRITORY2_ASSOCIATION_API);
            JMS_Logger.debugException(excep);
           
        }finally {
            JMS_Logger.pop();
        } 
        // Loop the original contacts
        Integer i=0;
        for (Id objRefId :mapCTSRefIdVsContact.keySet()) {
            
            Contact foundContact = null;
            // Find the first duplicate result with a match result, then use the first match record.
            // The loop starts here.
            for (Datacloud.DuplicateResult dr : results[i].getDuplicateResults()) {
                if (dr.matchResults.size() > 0 && dr.getMatchResults()[0].matchRecords.size() > 0) {
                    foundContact = (Contact) dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                    break;
                }
            }
            // The loop ends here.
            //Global Declared
            if(foundContact != null){
                if(!mapCTSRefIdVsContactId.containskey(objRefId)){
                    mapCTSRefIdVsContactId.put(objRefId,foundContact.Id);
                }
                if(mapCTSRefIdVsContact != null && mapCTSRefIdVsContact.containsKey(objRefId)){
                    mapCTSRefIdVsContact.remove(objRefId);
                }
            }
            i++;
        }
        return mapCTSRefIdVsContact;
    }// The method ends here.

   /*****************************************************************
    *   @Name        :  removeExistingCMRecords                                                              
    *   @Return      :  Map<Id,CampaignMember>                                                                                       
    *   @Description :  To remove the existing Campaign Member record from 
                        mapCTSRefIdVsCampaignMember
    *******************************************************************/

    // The method starts here.
    public static Map<Id,CampaignMember> removeExistingCMRecords(Map<Id,CampaignMember> mapCTSRefIdVsCampaignMember){
        List<CampaignMember> listExistingCampaignMember = new List<CampaignMember>();
        if(mapCTSRefIdVsCampaignId != null && !mapCTSRefIdVsCampaignId.isEmpty()){
            listExistingCampaignMember = [SELECT AccountId, CampaignId 
                                        FROM CampaignMember where CampaignId IN :mapCTSRefIdVsCampaignId.values() WITH SECURITY_ENFORCED LIMIT 50000];
        }
        if(listExistingCampaignMember != null && !listExistingCampaignMember.isEmpty()){
            for(CampaignMember  objCamp :listExistingCampaignMember ){
                if(mapAccIdVsRefId.containsKey(objCamp.AccountId)){
                    mapCTSRefIdVsCampaignMember.remove(mapAccIdVsRefId.get(objCamp.AccountId));
                }
            }
        }
         return mapCTSRefIdVsCampaignMember;
    } // The method ends here.
    
    
    
    public static Map<Id,Contact> customWayToRemoveDuplicateContacts( Map<Id,Contact> mapCTSRefIdVsContact , map<Id, List<Contact>> mapAccIdVsAllExistingContact){
        
        map< Id, map<Id, List<Contact>> > mapCTSIdVs_AccIdVsListContact = new map< Id, map<Id, List<Contact>> >();
        map<Id, Id> mapCTSIdVsAccId = new map<Id, Id>();
        map<Id, List<Contact>> accIdVsListContact = new map<Id, List<Contact>>();
        map<Id, List<Contact>> accIdVsListOfUniContact = new map<Id, List<Contact>>();
        map<Id, List<Contact>> accIdVsListOfUniCtsFinal = new map<Id, List<Contact>>();
        Map<Id,Contact> returnCTSWithContact = new Map<Id,Contact>();
        
        if(mapCTSRefIdVsContact != null && mapCTSRefIdVsContact.size() > 0){
            for(Id ctsId : mapCTSRefIdVsContact.keySet() ){
                if( mapCTSRefIdVsContact.get(ctsId) != null && mapCTSRefIdVsContact.get(ctsId).AccountId != null){
                    Contact oContact = mapCTSRefIdVsContact.get(ctsId);
                    mapCTSIdVsAccId.put(ctsId, oContact.AccountId);
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
        system.debug('mapCTSIdVsAccId--->>> ' + mapCTSIdVsAccId);
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
                    //  contact where emial is available
                    for(Contact oCon : lstCont ){                   
                        if(string.isNotEmpty(oCon.Email)) {
                            if(!setEmailId.contains(oCon.Email)){
                                setEmailId.add(oCon.Email);
                                setFirstnameLastNameWithEmail.add(oCon.FirstName+oCon.LastName);
                                lstContac.add(oCon);
                            }
                        }
                    }
                    //  contact where emial is not available
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
            if(accIdVsListOfUniContact != null && accIdVsListOfUniContact.size() >0 ){
                accIdVsListContact = accIdVsListOfUniContact;
            }
            
        }
        system.debug('accIdVsListOfUniContact-->>>  ' + accIdVsListOfUniContact);
		List<Contact> existingContactToUpdate = new List<Contact>();
        if(accIdVsListOfUniContact != null && accIdVsListOfUniContact.size() >0 && mapAccIdVsAllExistingContact != null && mapAccIdVsAllExistingContact.size() >0 ){
            
            for(Id oAccId:  accIdVsListOfUniContact.keySet()){
                List<Contact> lstNewCts = new List<Contact>();
                List<Contact> lstContactsToremove = new List<Contact>();
                List<Contact> lstCts;
                List<Contact> lstCtsExisting;
				
				system.debug(' mapAccIdVsAllExistingContact --->>> ' + mapAccIdVsAllExistingContact);
                if(mapAccIdVsAllExistingContact.containsKey(oAccId) && mapAccIdVsAllExistingContact.get(oAccId) != null && mapAccIdVsAllExistingContact.get(oAccId).size()>0 ){
                    lstCtsExisting = mapAccIdVsAllExistingContact.get(oAccId);
					system.debug(' lstCtsExisting --->>> ' + lstCtsExisting);
                    lstCts = accIdVsListOfUniContact.get(oAccId);
                    if(lstCts != null && lstCts.size() > 0){
                        for(Contact oCon : lstCts){
                            if(lstCtsExisting != null && lstCtsExisting.size() >0 ){
                                if(string.isNotEmpty(oCon.Email) ){
                                    for(Contact oExistingCon : lstCtsExisting){
                                        if(string.isEmpty(oExistingCon.Email) && oExistingCon.FirstName == oCon.FirstName  && oExistingCon.LastName == oCon.LastName){
											oExistingCon.Email = oCon.Email;
											oExistingCon.title = string.isEmpty(oExistingCon.title) && string.isNotEmpty(oCon.title) ? oCon.title :oExistingCon.title; 
											oExistingCon.Phone = string.isEmpty(oExistingCon.Phone) && string.isNotEmpty(oCon.Phone) ? oCon.Phone :oExistingCon.Phone; 
											oExistingCon.OtherPhone = string.isEmpty(oExistingCon.OtherPhone) && string.isNotEmpty(oCon.OtherPhone) ? oCon.OtherPhone :oExistingCon.OtherPhone; 
                                            existingContactToUpdate.add(oExistingCon);
											lstContactsToremove.add(oCon);
                                        }else if(oExistingCon.Email == oCon.Email  && oExistingCon.FirstName == oCon.FirstName  && oExistingCon.LastName == oCon.LastName){
                                            oExistingCon.title = string.isEmpty(oExistingCon.title) && string.isNotEmpty(oCon.title) ? oCon.title :oExistingCon.title; 
											oExistingCon.Phone = string.isEmpty(oExistingCon.Phone) && string.isNotEmpty(oCon.Phone) ? oCon.Phone :oExistingCon.Phone; 
											oExistingCon.OtherPhone = string.isEmpty(oExistingCon.OtherPhone) && string.isNotEmpty(oCon.OtherPhone) ? oCon.OtherPhone :oExistingCon.OtherPhone; 
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
											oExistingCon.title = string.isEmpty(oExistingCon.title) && string.isNotEmpty(oCon.title) ? oCon.title :oExistingCon.title; 
											oExistingCon.Phone = string.isEmpty(oExistingCon.Phone) && string.isNotEmpty(oCon.Phone) ? oCon.Phone :oExistingCon.Phone; 
											oExistingCon.OtherPhone = string.isEmpty(oExistingCon.OtherPhone) && string.isNotEmpty(oCon.OtherPhone) ? oCon.OtherPhone :oExistingCon.OtherPhone; 
											
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
        }
        else{
			accIdVsListOfUniCtsFinal = accIdVsListOfUniContact;
		}
        system.debug(' mapCTSRefIdVsContact 2222 --->>> ' + mapCTSRefIdVsContact);
        system.debug(' existingContactToUpdate 2222 --->>> ' + existingContactToUpdate);
		if(existingContactToUpdate != null && existingContactToUpdate.size() >0 ){
			update existingContactToUpdate;
		}
		
		
        if(mapCTSRefIdVsContact != null && mapCTSRefIdVsContact.size() > 0){
            for(Id oCTSId : mapCTSRefIdVsContact.keySet()){
                Contact oConFromCTS = mapCTSRefIdVsContact.get(oCTSId);
                if(accIdVsListOfUniCtsFinal != null && accIdVsListOfUniCtsFinal.size() > 0 && oConFromCTS.AccountId != null && accIdVsListOfUniCtsFinal.containsKey(oConFromCTS.AccountId)) {
                    List<Contact> lstNewCts1  = accIdVsListOfUniCtsFinal.get(oConFromCTS.AccountId);
					system.debug(' lstNewCts1 1111 --->>> ' + lstNewCts1);
                    if(lstNewCts1 != null && lstNewCts1.size() > 0){
                        for(Contact oCon1 : lstNewCts1 ){
                            returnCTSWithContact.put(oCTSId, oCon1);
                        }
                    }
                }
            }
        }
        system.debug('returnCTSWithContact--->>> ' + returnCTSWithContact);
        
        return returnCTSWithContact;
    }
    
    
}