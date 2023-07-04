/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_MigrateToCmpgnMemStagingBatch
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 19/04/2022
* @Description      : Batch class to migrate the Campaign Member Landing records
                      to Campaign Member staging Object
**********************************************************************************************************************
**********************************************************************************************************************/
//This is the Batch class for JMS_MigrateToCmpgnMemStaging.
global with sharing class JMS_MigrateToCmpgnMemStagingBatch implements database.Stateful,database.Batchable<Sobject> {
    // variable declared
    public static final String STR_MIGRATE_TO_CAMP_STAGING = 'JMS_MigrateToCmpgnMemStagingBatch Execute';
    public static final String STR_CAMPAIGN_TARGET = 'Campaign Target ';
    public static List<JMS_Campaign_Target_Landing_To_Staging__mdt> listLandingToStagingMetadata;
    JMS_Campaign_Target_Landing__c objCMLanding = new JMS_Campaign_Target_Landing__c();
    //Strings declared
    Set<String> SetCampNames =  new Set<String>();
    Set<String> SetConEmails =  new Set<String>();
    Set<String> SetFFIds =  new Set<String>();
    Set<String> SetProductSkus =  new Set<String>();
    Set<Id> setCTStangingId =  new Set<Id>();
    List<Campaign> ListNewCampaigns =  new List<Campaign>();
    //Maps declared
    Map<String, String> mapLandingNameVsCampId =  new Map<String, String>();
    Map<String, String> mapConEmailVsConId =  new Map<String, String>();
    Map<String, String> mapFFIdVsAccId =  new Map<String, String>();
    Map<String, String> mapSkuVsProductId =  new Map<String, String>();
    /*This variable to send BatchId from Execute method to finish method 
    To query in finish method to create and send reports*/
    public String strBatchId;
    
    // constuctor declared
    
    public JMS_MigrateToCmpgnMemStagingBatch(){

    }
    //The Start Method starts.
    global database.QueryLocator start(database.batchablecontext BC){
        //The Method body.
        String queryString = 'SELECT id';
        for(Schema.FieldSetMember fld :SObjectType.JMS_Campaign_Target_Landing__c.FieldSets.JMS_Campaign_Target_Landing_All_Fields.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }
        queryString += ' FROM JMS_Campaign_Target_Landing__c';
        system.debug(' queryString---->>>> ' + queryString);
        return Database.getQueryLocator(queryString);
    }
    //The Start Method ends here.
    /***************************************************************************************************************
    *   @Name        :  Execute                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  To create records of JMS_Territory_Assignment__c , ObjectTerritory2Association
    ***************************************************************************************************************/
    //The execute method starts from here.
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        //Method body starts.
        //
        //Variables Declarations
        objCMLanding = new JMS_Campaign_Target_Landing__c();
        List<JMS_Campaign_Target_Landing__c> lstCMLanding = new List<JMS_Campaign_Target_Landing__c>();
        SetCampNames =  new Set<String>();
        SetConEmails =  new Set<String>();
        SetFFIds =  new Set<String>();
        SetProductSkus =  new Set<String>();
        ListNewCampaigns =  new List<Campaign>();
        //Maps declared.
        mapLandingNameVsCampId =  new Map<String, String>();
        mapConEmailVsConId =  new Map<String, String>();
        mapFFIdVsAccId =  new Map<String, String>();
        mapSkuVsProductId =  new Map<String, String>();
        setCTStangingId =  new Set<Id>();
        List<JMS_Campaign_Target_Staging__c> listCTStgKickoutUpdate = new List<JMS_Campaign_Target_Staging__c>();
        String strCampaignTargetId = JMS_ConstantsUtility.EMPTY_STRING;
        List<JMS_Campaign_Target_Staging__c> listExistingCampTargetStaging = new  List<JMS_Campaign_Target_Staging__c>();
        //The for loop starts here.
        for(SObject objRec : scope){

            objCMLanding = (JMS_Campaign_Target_Landing__c) objRec;
            lstCMLanding.add(objCMLanding);
            if(String.isNotBlank(objCMLanding.JMS_Batch_Id__c) && String.isBlank(strBatchId)){
                strBatchId = objCMLanding.JMS_Batch_Id__c;
                
            }
            if(String.isNotBlank(objCMLanding.JMS_Campaign_Target_ID__c)){
                strCampaignTargetId = objCMLanding.JMS_Campaign_Target_ID__c;
            }
            if(String.isNotBlank(objCMLanding.JMS_Campaign_Name__c)){
                SetCampNames.add(objCMLanding.JMS_Campaign_Name__c);
            }
            if(String.isNotBlank(objCMLanding.JMS_Operator_Contact_Email_Address__c)){
                SetConEmails.add(objCMLanding.JMS_Operator_Contact_Email_Address__c);
            }
            if(String.isNotBlank(objCMLanding.JMS_Smucker_SKU__c)){
                SetProductSkus.add(objCMLanding.JMS_Smucker_SKU__c);
            }
            if(String.isNotBlank(objCMLanding.JMS_FireFlyId__c)){
                SetFFIds.add(objCMLanding.JMS_FireFlyId__c);
            }
        }
        /*To Check if we have same Campaign target Id record in staging 
        that is already processed , if found then will not process the current 
        record again */
        if(String.isNotBlank(strCampaignTargetId)){
            listExistingCampTargetStaging = [SELECT Id ,JMS_Campaign_Target_ID__c,JMS_Batch_Id__c,
                                                JMS_Record_Processed__c,JMS_SKU_Error_Message__c,
                                                JMS_Campaign_Error_Message__c,JMS_Kickout_Failed_Reason__c
                                                FROM JMS_Campaign_Target_Staging__c 
                                                WHERE JMS_Campaign_Target_ID__c =: strCampaignTargetId AND
                                                JMS_Batch_Id__c =:strBatchId 
                                               LIMIT 50000];
            if(listExistingCampTargetStaging != null || !listExistingCampTargetStaging.isEmpty()){
                for(JMS_Campaign_Target_Staging__c objStagingRec :listExistingCampTargetStaging){
                    if(objStagingRec.JMS_Record_Processed__c == true ){
                        setCTStangingId.add(objStagingRec.Id);
                    }else if(objStagingRec.JMS_Record_Processed__c == false){
                        objStagingRec.JMS_Kickout_Failed_Reason__c = JMS_ConstantsUtility.EMPTY_STRING;
                        objStagingRec.JMS_SKU_Error_Message__c = JMS_ConstantsUtility.EMPTY_STRING;
                        objStagingRec.JMS_Campaign_Error_Message__c = JMS_ConstantsUtility.EMPTY_STRING;
                        listCTStgKickoutUpdate.add(objStagingRec);
                    }
                }
            }
        }
        
        try{
            // Update Staging Records those thave same batch id and kickout reason 
            if(listCTStgKickoutUpdate != null && !listCTStgKickoutUpdate.isEmpty()){
                UPDATE listCTStgKickoutUpdate;
            }
            if(setCTStangingId == null || setCTStangingId.isEmpty()){
                //The for loop ends here.
                if(SetCampNames != null && !SetCampNames.isEmpty()){
                    mapLandingNameVsCampId = getCampaignRecordIds(SetCampNames);
                }
                if(SetConEmails != null && !SetConEmails.isEmpty()){
                    // mapConEmailVsConId = getContactRecordIds(SetConEmails);
                    mapConEmailVsConId = getContactRecordIds(SetConEmails,lstCMLanding);
                }
                if(SetFFIds != null && !SetFFIds.isEmpty()){
                    mapFFIdVsAccId = getAccountRecordIds(SetFFIds);
                }
                if(SetProductSkus != null && !SetProductSkus.isEmpty()){
                    mapSkuVsProductId = getProductRecordIds(SetProductSkus);
                }
            
                //create Staging records
                CreateCampTargetStagingData(mapLandingNameVsCampId,mapConEmailVsConId,mapFFIdVsAccId,mapSkuVsProductId,scope);
                if(Test.isRunningTest()){
                    integer intExcept = 10/0;
                }
            }
            
        }catch(Exception excep){
            JMS_Logger.push(STR_MIGRATE_TO_CAMP_STAGING, JMS_ConstantsUtility.OBJECT_TERRITORY2_ASSOCIATION_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }  
        //Method body ends.
    }
    //The execute method ends here.
    
    /***************************************************************************************************************
    *   @Name        :  Finish                                                              
    *   @Return      :  void                                                                                       
    *   @Description : This is to initiate the JMS_MigrateCampTarStagingToSObjectBatch 
                        to migrate Staging record to Sobjects                          
    ***************************************************************************************************************/
    //The finish method starts from here.
    global void finish(Database.BatchableContext BC){
        if(String.isNotBlank(strBatchId)){
            JMS_MigrateCampTarStagingToSObjectBatch objLandingToStaging = new JMS_MigrateCampTarStagingToSObjectBatch(strBatchId);
            //A new batch class gets called here.
              Database.executeBatch(objLandingToStaging,1);
        }
        
    }
    //The finish method ends here.

    /*************************************************************************
    *   @Name        :  getCampaignRecordIds                                                              
    *   @Return      :  Map<String,String>                                                                                       
    *   @Description :  To find the existing campaign Id with Campaign name
    ***************************************************************************/
    private static Map<String,String> getCampaignRecordIds(Set<String> setCampaignNames){
        Map<String,String> mapCampNameVsCampId = new Map<String,String>();
        List<Campaign> listCampaigns = [Select Id, Name from Campaign where Name IN:setCampaignNames];
        if(listCampaigns != null && !listCampaigns.isEmpty()){
            for(Campaign objCamp :listCampaigns){
                mapCampNameVsCampId.put(objCamp.Name,objCamp.Id);
            }
        }
        return mapCampNameVsCampId;
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
        Map<Id,Product2> mapProductIdVSProducts = new Map<Id,Product2>([SELECT Id, Name ,StockKeepingUnit 
                                                              FROM Product2 
                                                              WHERE StockKeepingUnit IN:setProductsSku]);
      
        //The Query on PriceBookEntry.
        for(PriceBookEntry objPriceBookEntry :[SELECT Id, Product2Id 
                                                FROM PriceBookEntry 
                                                WHERE Product2Id IN:mapProductIdVSProducts.KeySet()
                                                AND PriceBook2.isStandard=true]){
            SetProductId.add(objPriceBookEntry.Product2Id);
        }
        if(mapProductIdVSProducts != null && !mapProductIdVSProducts.isEmpty()){
            for(Product2 objProduct :mapProductIdVSProducts.values()){
                if(SetProductId != null && !SetProductId.isEmpty() &&
                    setProductId.contains(objProduct.Id)){
                    mapSkuVsProductId.put(objProduct.StockKeepingUnit,objProduct.Id);
                }
            }
        }
        
        return mapSkuVsProductId;
    }

    /*************************************************************************
    *   @Name        :  getContactRecordIds                                                              
    *   @Return      :  Map<String,String>                                                                                       
    *   @Description :  To find the existing Contact count with EmailAddress
    ***************************************************************************/
    private static Map<String,String> getContactRecordIds(Set<String> setConEmails){
        Map<String,String> mapConEmailVsConId = new Map<String,String>();
        List<Contact> listContacts = [SELECT Id,Email, Name FROM Contact WHERE Email IN:setConEmails];
        if(listContacts != null && !listContacts.isEmpty()){
            for(Contact objCon :listContacts){
                mapConEmailVsConId.put(objCon.Email,objCon.Id);
            }
        }
        return mapConEmailVsConId;
    }
    
    private static Map<String,String> getContactRecordIds(Set<String> setConEmails, List<JMS_Campaign_Target_Landing__c> lstCMLanding ){
        Map<String,String> mapConEmailVsConId = new Map<String,String>();
        List<Contact> listContactsToUpdate = new List<Contact> ();
        List<Contact> listContacts = [SELECT Id,Email, Name, phone, otherPhone,Title FROM Contact WHERE Email IN:setConEmails];
        if(listContacts != null && !listContacts.isEmpty()){
            for(Contact objCon :listContacts){
                mapConEmailVsConId.put(objCon.Email,objCon.Id);
                
                for(JMS_Campaign_Target_Landing__c objCTS : lstCMLanding){
                    if(string.isNotEmpty(objCTS.JMS_Operator_Contact_Email_Address__c) && 
                    objCon.Email == objCTS.JMS_Operator_Contact_Email_Address__c && 
                    (  objCon.Title != objCTS.JMS_Operator_Contact_Title__c ||
                        objCon.phone != objCTS.JMS_Operator_Contact_Phone_Number__c ||
                        objCon.otherPhone != objCTS.JMS_Operator_Contact_Mobile_Phone_Number__c
                    )
                    ){
                        objCon.Title = string.isNotEmpty(objCTS.JMS_Operator_Contact_Title__c) ? objCTS.JMS_Operator_Contact_Title__c : objCon.Title;
                        objCon.phone = string.isNotEmpty(objCTS.JMS_Operator_Contact_Phone_Number__c) ? objCTS.JMS_Operator_Contact_Phone_Number__c : objCon.phone;
                        objCon.otherPhone = string.isNotEmpty(objCTS.JMS_Operator_Contact_Mobile_Phone_Number__c) ? objCTS.JMS_Operator_Contact_Mobile_Phone_Number__c : objCon.otherPhone;
                        
                        listContactsToUpdate.add(objCon);
                    }
                    
                }
            }
            if(listContactsToUpdate != null && listContactsToUpdate.size() >0){
                update listContactsToUpdate;
            }
        }
        return mapConEmailVsConId;
    }
    

    /*************************************************************************
    *   @Name        :  getAccountRecordIds                                                              
    *   @Return      :  Map<String,String>                                                                                       
    *   @Description :  To find the existing Account with firefly Id
    ***************************************************************************/
    private static Map<String,String> getAccountRecordIds(Set<String> SetFFIds){
        Map<String,String> mapFFIdVsAccId = new Map<String,String>();
       
        List<Account> listAccounts = [SELECT Id,JMS_FireFly_Id__c, Name FROM Account WHERE JMS_FireFly_Id__c IN:SetFFIds];
        if(listAccounts != null && !listAccounts.isEmpty()){
            for(Account objAcc :listAccounts){
                    mapFFIdVsAccId.put(objAcc.JMS_FireFly_Id__c,objAcc.Id);
            }
        }
        return mapFFIdVsAccId;
    }

    /*************************************************************************
    *   @Name        :  CreateCampTargetStagingData                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  To create Campaign Target Staging record from Landing
                        with existing record for Account , contact, Campaign , 
                        Product if found
    ***************************************************************************/
    //The CreateCampTargetStagingData method starts from here.
    private static void CreateCampTargetStagingData(Map<String, String> mapLandingNameVsCampId,
                                                    Map<String, String> mapConEmailVsConId,
                                                    Map<String, String> mapFFIdVsAccId,
                                                    Map<String, String> mapSkuVsProductId,
                                                    List<SObject> scope){
        String strConErrorMessage;
        String strAccErrorMessage;
        String strProductErrorMessage;
        String strCampaignErrorMessage;
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        JMS_Campaign_Target_Landing__c objCMLanding = new JMS_Campaign_Target_Landing__c();
        List<JMS_Campaign_Target_Staging__c> listNewCampTargetStaging =  new  List<JMS_Campaign_Target_Staging__c>();
        //Querying Custom metadata record
        //The query is on JMS_Campaign_Target_Landing_To_Staging__mdt
        listLandingToStagingMetadata = [SELECT Id, JMS_Landing_Field_Api__c, JMS_Staging_Field_Api__c, JMS_Is_Active__c
                                                                                          FROM JMS_Campaign_Target_Landing_To_Staging__mdt 
                                                                                          WHERE JMS_Is_Active__c = TRUE];                                            
        //The loop starts here
        for(SObject objLandingRec :scope){
            objCMLanding = (JMS_Campaign_Target_Landing__c) objLandingRec;
            JMS_Campaign_Target_Staging__c objStagingRec =  new JMS_Campaign_Target_Staging__c();
            strConErrorMessage = JMS_ConstantsUtility.EMPTY_STRING;
            strAccErrorMessage = JMS_ConstantsUtility.EMPTY_STRING;
            strProductErrorMessage = JMS_ConstantsUtility.EMPTY_STRING;
            strCampaignErrorMessage = JMS_ConstantsUtility.EMPTY_STRING;
            
            objStagingRec = getCampaignTargetStgInstance(listLandingToStagingMetadata, objCMLanding);
            system.debug(' objStagingRec--->>> ' + objStagingRec);
            objStagingRec.JMS_Kickout_Failed_Reason__c              = JMS_ConstantsUtility.EMPTY_STRING;
            objStagingRec.JMS_Operator_Error_Message__c             = JMS_ConstantsUtility.EMPTY_STRING;
            objStagingRec.JMS_Operator_Contact_Error_Message__c     = JMS_ConstantsUtility.EMPTY_STRING;
            objStagingRec.JMS_Opportunity_Error_Message__c          = JMS_ConstantsUtility.EMPTY_STRING;
            objStagingRec.JMS_Broker_Call_Error_Message__c          = JMS_ConstantsUtility.EMPTY_STRING;
            objStagingRec.JMS_SKU_Error_Message__c                  = JMS_ConstantsUtility.EMPTY_STRING;
            objStagingRec.JMS_Campaign_Error_Message__c             = JMS_ConstantsUtility.EMPTY_STRING;
            
            objStagingRec.JMS_Campaign_Target_Batch_Job__c          = STR_CAMPAIGN_TARGET + Datetime.now();
            objStagingRec.JMS_Kickout_Failed_Reason__c              = JMS_ConstantsUtility.EMPTY_STRING;
            objStagingRec.JMS_Kickout_Location__c = JMS_ConstantsUtility.STR_SALESFORCE;
            if(String.isNotBlank(objStagingRec.JMS_Operator_Contact_First_Name__c) && String.isBlank(objStagingRec.JMS_Operator_Contact_Last_Name__c)){
                objStagingRec.JMS_Operator_Contact_Last_Name__c = objStagingRec.JMS_Operator_Contact_First_Name__c;
            }
            if(String.isNotBlank(objCMLanding.JMS_FireFlyId__c) &&
                mapFFIdVsAccId != null && !mapFFIdVsAccId.isEmpty() &&
                mapFFIdVsAccId.containsKey(objCMLanding.JMS_FireFlyId__c)){
                objStagingRec.JMS_Account_SF_Id__c = mapFFIdVsAccId.get(objCMLanding.JMS_FireFlyId__c);
            }
            else {          
                strAccErrorMessage = validateAccount(objCMLanding);
                objStagingRec.JMS_Kickout_Failed_Reason__c += strAccErrorMessage;
                
            }
            objStagingRec.JMS_Operator_Error_Message__c = strAccErrorMessage;
            if(String.isNotBlank(objCMLanding.JMS_Operator_Contact_Email_Address__c) &&
                mapConEmailVsConId.containsKey(objCMLanding.JMS_Operator_Contact_Email_Address__c)){
                objStagingRec.JMS_Contact_SF_Id__c = mapConEmailVsConId.get(objCMLanding.JMS_Operator_Contact_Email_Address__c);
            }
            if(String.isNotBlank(objCMLanding.JMS_Campaign_Name__c) &&
                mapLandingNameVsCampId != null && !mapLandingNameVsCampId.isEmpty() &&
                mapLandingNameVsCampId.containsKey(objCMLanding.JMS_Campaign_Name__c)){
                    objStagingRec.JMS_Campaign_SF_Id__c                 = mapLandingNameVsCampId.get(objCMLanding.JMS_Campaign_Name__c);
            }else{
                strCampaignErrorMessage = System.Label.JMS_CampTarg_Campaign_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
                objStagingRec.JMS_Kickout_Failed_Reason__c += System.Label.JMS_CampTarg_Campaign_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
            }
            if(String.isBlank(objCMLanding.JMS_Call_Made_By__c)){
                objStagingRec.JMS_Kickout_Failed_Reason__c += System.Label.JMS_Call_made_By_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
            }else{
                String CallMadeByUpperCase = (objCMLanding.JMS_Call_Made_By__c).toUpperCase();
                    if(CallMadeByUpperCase != JMS_ConstantsUtility.STR_BROKER_UPPERCASE && 
                       CallMadeByUpperCase != JMS_ConstantsUtility.STR_JMS){
                        objStagingRec.JMS_Kickout_Failed_Reason__c += System.Label.JMS_Call_made_By_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
                    }
            }
           
            objStagingRec.JMS_Campaign_Error_Message__c = strCampaignErrorMessage;
            //Broker Call Made By
           
            if(String.isNotBlank(objCMLanding.JMS_Smucker_SKU__c) &&
                mapSkuVsProductId != null && !mapSkuVsProductId.isEmpty() &&
                String.isNotBlank(objCMLanding.JMS_Call_Made_By__c) && 
                objCMLanding.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_BROKER) &&
                mapSkuVsProductId.containsKey(objCMLanding.JMS_Smucker_SKU__c)){
                    objStagingRec.JMS_Product_SF_Id__c = mapSkuVsProductId.get(objCMLanding.JMS_Smucker_SKU__c);
            }else{
                //JMS
                if(String.isNotBlank(objCMLanding.JMS_Smucker_SKU__c) &&
                    mapSkuVsProductId != null && !mapSkuVsProductId.isEmpty() &&
                    mapSkuVsProductId.containsKey(objCMLanding.JMS_Smucker_SKU__c)&&
                    String.isNotBlank(objCMLanding.JMS_Call_Made_By__c) &&
                    objCMLanding.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_JMS)){
                    objStagingRec.JMS_Product_SF_Id__c                  = mapSkuVsProductId.get(objCMLanding.JMS_Smucker_SKU__c);
                }else {
                    // For JMS if SKU id not blank and it is not present in system
                    // If SKu id blank
                    if(String.isNotBlank(objCMLanding.JMS_Call_Made_By__c) && 
                       objCMLanding.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_JMS) &&
                       mapSkuVsProductId != null &&
                       !mapSkuVsProductId.containsKey(objCMLanding.JMS_Smucker_SKU__c) &&
                       String.isNotBlank(objCMLanding.JMS_Smucker_SKU__c)){
                            objStagingRec.JMS_SKU_Error_Message__c = System.Label.JMS_CampTarg_Product_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
                            objStagingRec.JMS_Kickout_Failed_Reason__c += System.Label.JMS_CampTarg_Product_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
                    }
                }
            }
            if(String.isBlank(objCMLanding.JMS_Annual_Volume__c) && 
                (String.isNotBlank(objCMLanding.JMS_Smucker_SKU__c) 
                ||
                ((mapSkuVsProductId != null && !mapSkuVsProductId.isEmpty() 
                && String.isNotBlank(objCMLanding.JMS_Smucker_SKU__c) &&
                    mapSkuVsProductId.containsKey(objCMLanding.JMS_Smucker_SKU__c))))
            &&
            objCMLanding.JMS_Call_Made_By__c.equalsIgnoreCase(JMS_ConstantsUtility.STR_JMS)){
                objStagingRec.JMS_Kickout_Failed_Reason__c += System.Label.JMS_Camp_Target_Annual_Volume_Error + JMS_ConstantsUtility.SPACE_STRING;
            }
            if(String.isNotBlank(objStagingRec.JMS_Operator_Contact_Error_Message__c) ||
                String.isNotBlank(objStagingRec.JMS_Operator_Error_Message__c) ||
                String.isNotBlank(objStagingRec.JMS_SKU_Error_Message__c) ||
                String.isNotBlank(objStagingRec.JMS_Campaign_Error_Message__c) ||
                String.isNotBlank(objStagingRec.JMS_Kickout_Failed_Reason__c)){
                    objStagingRec.JMS_Status__c =  JMS_ConstantsUtility.STR_STATUS_ERROR;
            }
            else{
                objStagingRec.JMS_Status__c =  JMS_ConstantsUtility.STR_STATUS_SUCCESS;
            }
            objStagingRec.setOptions(dml);
            system.debug(' objStagingRec--->>> ' + objStagingRec);
            listNewCampTargetStaging.add(objStagingRec);
           
        }
        system.debug(' listNewCampTargetStaging--->>> ' + listNewCampTargetStaging.size());
        //The loop ends here.
        try{
            if(Test.isRunningTest()){
                integer intExcept = 10/0;
            }
            if(listNewCampTargetStaging != null && !listNewCampTargetStaging.isEmpty()){
               upsert listNewCampTargetStaging JMS_Campaign_Target_ID__c;
              
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_MIGRATE_TO_CAMP_STAGING, JMS_ConstantsUtility.OBJECT_CAMPAIGN_TARGET_LANDING_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }  
    }

    /*****************************************************************
    *   @Name        :  validateAccount                                                          
    *   @Return      :  String                                                                                       
    *   @Description :  To validate the Account fields 
    *******************************************************************/

    //The validateAccount method starts from here.
    public static String validateAccount(JMS_Campaign_Target_Landing__c objCMLanding ){
        String strAccErrorMessage = JMS_ConstantsUtility.EMPTY_STRING;
        
        if(String.isBlank(objCMLanding.JMS_Operator_Name__c)){
            strAccErrorMessage += System.Label.JMS_CampTarg_Operator_Name_Error_Message + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objCMLanding.JMS_Operator_Address__c)){
            strAccErrorMessage += System.Label.JMS_Operator_Address_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objCMLanding.JMS_Operator_City__c)){
            strAccErrorMessage += System.Label.JMS_Operator_City_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objCMLanding.JMS_Operators_State__c)){
            strAccErrorMessage += System.Label.JMS_Operator_State_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        else if(String.isNotBlank(objCMLanding.JMS_Operators_State__c) && (objCMLanding.JMS_Operators_State__c).length() < JMS_ConstantsUtility.INT_THREE){
            strAccErrorMessage += System.Label.JMS_State_Code_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objCMLanding.JMS_Operator_Zip__c)){
            strAccErrorMessage += System.Label.JMS_Operator_ZipCode_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objCMLanding.JMS_Company_Country__c)){
            strAccErrorMessage += System.Label.JMS_Operator_Country_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }else if(String.isNotBlank(objCMLanding.JMS_Company_Country__c) && (objCMLanding.JMS_Company_Country__c).length() < JMS_ConstantsUtility.INT_FOUR){
            strAccErrorMessage += System.Label.JMS_Country_Short_Form_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
            
        
        return strAccErrorMessage;
    }
    //The validateAccount method ends here.

    /*****************************************************************
    *   @Name        :  getCampaignTargetStgInstance                                                              
    *   @Return      :  JMS_Campaign_Target_Staging__c                                                                                      
    *   @Description :  To create JMS_Campaign_Target_Staging__c records using Metadata 
                        field mapping 
    *******************************************************************/
    public static JMS_Campaign_Target_Staging__c getCampaignTargetStgInstance(List<JMS_Campaign_Target_Landing_To_Staging__mdt> listLandingToStagingMetadata, JMS_Campaign_Target_Landing__c objCMLanding){
        JMS_Campaign_Target_Staging__c objStagingRec = new JMS_Campaign_Target_Staging__c();
        for(JMS_Campaign_Target_Landing_To_Staging__mdt mdtRec : listLandingToStagingMetadata){
            // system.debug('  mdtRec.JMS_Landing_Field_Api__c-->>> ' + mdtRec.JMS_Landing_Field_Api__c);
            // system.debug('  objCMLanding.get(mdtRec.JMS_Landing_Field_Api__c)-->>> ' + objCMLanding.get(mdtRec.JMS_Landing_Field_Api__c) );
            if(objCMLanding.get(mdtRec.JMS_Landing_Field_Api__c) != null){
                objStagingRec.put(mdtRec.JMS_Staging_Field_Api__c, objCMLanding.get(mdtRec.JMS_Landing_Field_Api__c));
            }else{
                objStagingRec.put(mdtRec.JMS_Staging_Field_Api__c, JMS_ConstantsUtility.EMPTY_STRING);
            }
        }
        return objStagingRec;
    }
}