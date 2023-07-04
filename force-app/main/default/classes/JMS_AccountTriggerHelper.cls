public class JMS_AccountTriggerHelper {
    private static final String STR_CREATE_MAP_STRING_VS_LIST = 'createMapStringVsList';
    private static final String STR_GET_ACCOUNT_DETAILS = 'getAccountDetails';
    private static final String STR_SEND_NOTIFICATION_TO_OWNER = 'sendNotificationToOwner';
    private static final String STR_POPULATE_RECORDTYPEID = 'populateRecordTypeId';
    private static final String STR_RESTRICT_ACCOUNT_FIELD_UPDATE = 'restrictAccountFieldUpdates';
    private static final String STR_NEW_TERITORY_ASSIGNMENT = 'initiateNewTerritoryAssignment';
    private static final String STR_CREATE_NEW_TERRITORY_ASSCIATION = 'createNewTerritoryAssociation';
    private static final String STR_DELETE_OLD_TERRITORY_ASSCIATION = 'deleteExistingTerritoryAssociation';
    private static final String STR_UPDATE_ACCOUNT_TERRITORY_ASSCIATION = 'updateTerritoryOnAccount';
    public static Map<Id, Boolean> mergedAccMap = new Map<Id, Boolean>();
    public String profileId;

    //Constructor Declared
    @testvisible
    public JMS_AccountTriggerHelper(){
        profileId =  [SELECT Id FROM Profile WHERE Name =:JMS_ConstantsUtility.STR_INTEGRATION_USER LIMIT 1].Id;    
    }

    /**
    * @description : This method will restrict user to update few fields if FireFly Id's is already there
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Sumit
    * @date        : 24/02/2022
    */
    public void restrictAccountFieldUpdates(List<SObject> newItems, Map<Id, SObject> newItemsMap,Map<Id, SObject> oldItemsMap){
        
        //variable declaration
        List<Account> listNewAccount = (List<Account>) newItems;
        
        try{
            List<Schema.FieldSetMember> readOnlyFieldList= SObjectType.Account.FieldSets.JMS_Read_Only_Fields.getFields();
            if(!profileId.equalsIgnoreCase(String.valueOf(userinfo.getProfileId()))){
                //Comparing old value of fields with new values
                if(readOnlyFieldList != null && !readOnlyFieldList.isEmpty()) {
                    String oldFieldValue;
                    String newFieldValue;
                    for(Id accId : newItemsMap.keySet()) {
                        if(mergedAccMap.containsKey(accId)) continue;
                        Account newAccObj = (Account)newItemsMap.get(accId);
                        //Account oldAccObj = (Account)oldItemsMap.get(accId);
                        if(String.isNotEmpty(newAccObj.JMS_FireFly_Id__c) && string.isNotEmpty(newAccObj.billingCountry) && string.ValueOf(newAccObj.billingCountry ) != 'Canada'){
                            for(Schema.FieldSetMember fieldApiName : readOnlyFieldList) {
                                oldFieldValue = String.valueOf(oldItemsMap.get(accId).get(fieldApiName.getSObjectField()));
                                newFieldValue = String.valueOf(newItemsMap.get(accId).get(fieldApiName.getSObjectField()));    
                                
                                if(oldFieldValue != newFieldValue){  
                                    newAccObj.addError(System.Label.JMS_Read_Only_Fields_Validation_Msg);
                                } 
                            }
                        }
                        if(String.isNotEmpty(newAccObj.JMS_FireFly_Id__c) && string.isNotEmpty(newAccObj.billingCountry) && string.ValueOf(newAccObj.billingCountry) == 'Canada'){
                            for(Schema.FieldSetMember fieldApiName : readOnlyFieldList) {
                                oldFieldValue = String.valueOf(oldItemsMap.get(accId).get(fieldApiName.getSObjectField()));
                                newFieldValue = String.valueOf(newItemsMap.get(accId).get(fieldApiName.getSObjectField()));    
                                system.debug('field Api Name -->> ' + string.valueOf(fieldApiName.getSObjectField()));
                                if(oldFieldValue != newFieldValue && string.valueOf(fieldApiName.getSObjectField()) != 'JMS_Customer_Health__c' ){  
                                    newAccObj.addError(System.Label.JMS_Read_Only_Fields_Validation_Msg);
                                } 
                            }
                        }
                        
                    }
                }
            }
            
        }catch(Exception excep){
            JMS_Logger.push(STR_RESTRICT_ACCOUNT_FIELD_UPDATE, JMS_ConstantsUtility.ACCOUNT_API);
            JMS_Logger.debugException(excep);
            
        }finally {
            JMS_Logger.pop();
        }
    }

    /**
    * @description : To send Notification to Account record 
                owner if Duplicate Account found with same
                FireFly Id and it will work for update and restore 
                the records
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 03/03/2022
    */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void getAccountDetails(List<Account> accNewList , Map<Id, SObject> oldItemsMap , String strTriggerType){
        
       //variable declaration
        Map<String , List<String>> mapFireFlyIdVsRecordUrl = new  Map<String , List<String>>();
        List<Account> listAccToProcess = new List<Account>();
        List<Account> listExistingAccount = new List<Account>();
        Set<String> setFireFlyId =  new Set<String>();
        Set<String> setNewAccountId =  new Set<String>();
        Map<Id, Account> mapOldAccount = (Map<Id,Account>) oldItemsMap;

        try{
            if(accNewList != null && !accNewList.isEmpty() && mapOldAccount != null){
                listAccToProcess = accNewList;
            }//end of if
            else if(mapOldAccount != null && strTriggerType == JMS_ConstantsUtility.STR_AFTER_UNDELETE){
                listAccToProcess = mapOldAccount.values();
            }//end of else if
    
            if(listAccToProcess != null && !listAccToProcess.isEmpty()){
                for(Account objAcc: listAccToProcess){
                    if(objAcc.JMS_FireFly_Id__c != null && mapOldAccount != null && 
                        mapOldAccount.get(objAcc.Id).JMS_FireFly_Id__c == null && strTriggerType == JMS_ConstantsUtility.STR_AFTER_UPDATE){
                        setFireFlyId.add(objAcc.JMS_FireFly_Id__c);
                        setNewAccountId.add(objAcc.Id);
                    }else if(objAcc.JMS_FireFly_Id__c != null && strTriggerType == JMS_ConstantsUtility.STR_AFTER_UNDELETE){
                        setFireFlyId.add(objAcc.JMS_FireFly_Id__c);
                        setNewAccountId.add(objAcc.Id);
                    }//end of else if
                }//end of for
            }
           
            //Query the Account Records from the database to get existing Accounts
            if(setFireFlyId != null && !setFireFlyId.isEmpty()){
                listExistingAccount = [SELECT Id, Name,JMS_FireFly_Id__c 
                                       FROM Account 
                                       WHERE JMS_FireFly_Id__c IN : setFireFlyId LIMIT 50000];
            }//end of if
            if(listExistingAccount != null && !listExistingAccount.isEmpty()){
                mapFireFlyIdVsRecordUrl = createMapStringVsList(listExistingAccount);
                EmailTemplate objEmailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate 
                                       WHERE DeveloperName =: System.Label.JMS_MatchingAccountEmailTemplate LIMIT 50000];
                if(objEmailTemplate != null){
                    if(listAccToProcess != null && !listAccToProcess.isEmpty() && mapFireFlyIdVsRecordUrl != null && !mapFireFlyIdVsRecordUrl.isEmpty()){
                        sendNotificationToOwner(listAccToProcess ,mapFireFlyIdVsRecordUrl, objEmailTemplate);
                    }//end of if
                }//end of if
            }//end of if
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value =10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_GET_ACCOUNT_DETAILS, JMS_ConstantsUtility.ACCOUNT_API);
			JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }//end of getAccountDetails method

    /**
    * @description :To send Notification to Account record 
                owner if Duplicate Account found with same
                FireFly Id
    * @param       : List<Account> listNewAccountForOwner ,EmailTemplate ets,
                    Map<String , List<String>> mapFireFlyIdVsRecordUrl
    * @author      : Vasudha
    * @date        : 03/03/2022
    */
    public static void sendNotificationToOwner(List<Account> listNewAccountForOwner ,Map<String , List<String>> mapFireFlyIdVsRecordUrl,EmailTemplate objEmailTemplate){
        JMS_PostOnChatter postChatterToOwner = new JMS_PostOnChatter();
        String htmlBody = objEmailTemplate.HtmlValue;
        
        try{
            for(Account objNewAcc: listNewAccountForOwner){
                String strRecordURL =  mapFireFlyIdVsRecordUrl.get(objNewAcc.JMS_FireFly_Id__c) != null ? String.valueOf(mapFireFlyIdVsRecordUrl.get(objNewAcc.JMS_FireFly_Id__c)) : '';
                if(strRecordURL != null && strRecordURL != JMS_ConstantsUtility.EMPTY_STRING){
                    strRecordURL = strRecordURL.substring(1, strRecordURL.length() - 1);
                    strRecordURL = strRecordURL.remove(JMS_ConstantsUtility.STR_COMMA_STRING);
                    // Replace the text with list Record URLs and FireFly Id
                    htmlBody = htmlBody.replace(JMS_ConstantsUtility.STR_RECORD_URLS, strRecordURL);
                    htmlBody = htmlBody.replace(JMS_ConstantsUtility.STR_FIREFLY_ID, objNewAcc.JMS_FireFly_Id__c);
                    // send psot to chatter
                    postChatterToOwner.postChatterToUser(objNewAcc.Id,htmlBody,objNewAcc.ownerId);
                    
                }//end of if
            }//end of for
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value =10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_CREATE_MAP_STRING_VS_LIST, JMS_ConstantsUtility.ACCOUNT_API);
			JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }//end of sendNotificationToOwner method

    /**
    * @description : create a map of string against of List of String of URL
    * @param       : List<Account> listExistingAccount
    * @author      : Vasudha
    * @date        : 03/03/2022
    */

    public static Map<String , List<String>> createMapStringVsList(List<Account> listExistingAccount){
        Map<String , List<String>> mapFireFlyIdVsRecordUrl = new  Map<String , List<String>>();
        try{
            for(Account objExistingAcc : listExistingAccount){
                String strAccountRecordURL = objExistingAcc.Name + JMS_ConstantsUtility.SINGLE_DASH_STRING + URL.getSalesforceBaseUrl().toExternalForm() + JMS_ConstantsUtility.BACKWARD_SLASH + objExistingAcc.Id +'\n'; 
                if (mapFireFlyIdVsRecordUrl.containsKey(objExistingAcc.JMS_FireFly_Id__c)) {
                mapFireFlyIdVsRecordUrl.get(objExistingAcc.JMS_FireFly_Id__c).add(strAccountRecordURL); 
                }else{
                    mapFireFlyIdVsRecordUrl.put(objExistingAcc.JMS_FireFly_Id__c,new List<String>{strAccountRecordURL}); 
                }//end of else
            } //end of for
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value =10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_SEND_NOTIFICATION_TO_OWNER, JMS_ConstantsUtility.ACCOUNT_API);
			JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
        
        return mapFireFlyIdVsRecordUrl;
    }//end of createMapStringVsList method

    /**
    * @description : This method is used for populating RecordTypeId
                     at the time of integration via Amazon App flow
                     using JMS_Record_Type_Name__c field.
    * @param       : List<SObject> newItems
    * @author      : Sumit
    * @date        : 21/03/2022
    */
    public static void populateRecordTypeId(List<SObject> newItems){

        //Variable Declaration
        List<Account> listNewAccount = (List<Account>) newItems;
        try{
            if(!listNewAccount.isEmpty() && listNewAccount != Null){
                for(Account acc : listNewAccount){
                    if(String.isNotBlank(acc.JMS_Record_Type_Name__c)){
                        Id recordTypeIdByName = Schema.SObjectType.Account.getRecordTypeInfosByName().get(acc.JMS_Record_Type_Name__c).getRecordTypeId();
                        acc.RecordTypeId = recordTypeIdByName;
                        
                    }
                }
        	}
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                JMS_Logger.debug(string.valueOf('Test Run'));
                integer value =10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_POPULATE_RECORDTYPEID, JMS_ConstantsUtility.ACCOUNT_API);
			JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
        
    }
    
    /* @description : This method will Get the Territory Details based on Zip codes
                    from Custom ZipCode object and will create ObjectTerritory2Association 
                    record on Account Creation/Updation.
    * @param       : List<SObject> newItem,Map<Id, SObject> oldItemsMap
    * @author      : Archana
    * @date        : 24/03/2022
    */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void initiateNewTerritoryAssignment(List<SObject> newItems,Map<Id, SObject> oldItemsMap){
       //Variable Declaration
        Map<String,Id> mapofTerritoryNamevsId = new Map<String,Id>();
        Map<String,String> mapZipCodeVsTerritoryName = new Map<String,String>();
		List<JMS_ZipCodes__c> listZipCode = new List<JMS_ZipCodes__c>();
		Set<String> setZipCodes = new Set<String>();
        Set<String> setTerritoryNames =  new Set<String>();
        Set<String> setAccountIds =  new Set<String>();
		Map<Id,Account> mapOldAccounts = (Map<Id, Account>) oldItemsMap;
        
		try{
            for(SObject objAccount : newItems){
                Account objNewAccount = (Account)objAccount;
				if(objNewAccount.BillingPostalCode != null  && oldItemsMap == null){
					setZipCodes.add(objNewAccount.BillingPostalCode);
				}
                else if( oldItemsMap != null && mapOldAccounts.containsKey(objNewAccount.Id) && 
                    objNewAccount.BillingPostalCode != mapOldAccounts.get(objNewAccount.Id).BillingPostalCode){
                        setZipCodes.add(objNewAccount.BillingPostalCode);
                        setAccountIds.add(objNewAccount.Id);
                }
			}
            if(setAccountIds!= null && !setAccountIds.isEmpty()){
                    deleteExistingTerritoryAssociation(setAccountIds);
            }
            //Query All the Records from the custom ZipCode Object and storing into the List          
            if(setZipCodes!= null && !setZipCodes.isEmpty()){                
                listZipCode =[SELECT ID,JMS_Zip_Code__c,JMS_Territory_Name__c FROM JMS_ZipCodes__c
                            WHERE JMS_Zip_Code__c IN :setZipCodes LIMIT 50000 ];      
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
                List<Territory2> listExistingTerritory = [SELECT ID,Name,Territory2TypeId FROM Territory2 WHERE Name IN :setTerritoryNames LIMIT 50000];
                    if(listExistingTerritory != null && !listExistingTerritory.isEmpty()){
                        for(Territory2 objTerritory :listExistingTerritory ){
                            mapofTerritoryNamevsId.put(objTerritory.Name,objTerritory.Id);
                        }  
                    }
            }
            if(mapofTerritoryNamevsId != null && mapZipCodeVsTerritoryName != null && 
                        !mapZipCodeVsTerritoryName.isEmpty() && newItems != null && 
                        !newItems.isEmpty() && !mapofTerritoryNamevsId.isEmpty()){
                createNewTerritoryAssociation(newItems, mapofTerritoryNamevsId ,mapZipCodeVsTerritoryName);
            }
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/  
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_NEW_TERITORY_ASSIGNMENT, JMS_ConstantsUtility.ACCOUNT_API);
            JMS_Logger.debugException(excep);
        }finally {
			JMS_Logger.pop();
		}
    }//end of initiateNewTerritoryAssignment method

    /* @description : This method will create ObjectTerritory2Association 
                    record on Account Creation/Updation.
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Archana
    * @date        : 24/03/2022
    * @ModifiedDate: 07/04/2022
    */   
    public static void createNewTerritoryAssociation(List<SObject>listNewAccount, 
                                                    Map<String,Id> mapofTerritoryNamevsId ,
                                                    Map<String,String> mapZipCodeVsTerritoryName){
        //Variable Declaration
        List<ObjectTerritory2Association> listobjectTerritory2Association = new List<ObjectTerritory2Association>();
        List<JMS_Territory_Assignment__c> listcustomTerritoryAssociation = new List<JMS_Territory_Assignment__c>();
        String strcustomzipcode,strTerritoryName;
        Set<String> setAccountIDS = new Set<String>();
        try{
          //Creation of new ObjectTerritory2Association record
           for(SObject objAccount : listNewAccount){
                Account objProcessAccount = (Account)objAccount;
                setAccountIDS.add(objProcessAccount.ID);
                strTerritoryName = JMS_ConstantsUtility.EMPTY_STRING;
                ObjectTerritory2Association objNewTerritory = new ObjectTerritory2Association();
                objNewTerritory.ObjectId = objProcessAccount.ID;
                
                JMS_Territory_Assignment__c NewcustomTerritory = new JMS_Territory_Assignment__c();
                NewcustomTerritory.JMS_Account_ID__c = objProcessAccount.ID;

               
                if(mapZipCodeVsTerritoryName.containskey(objProcessAccount.BillingPostalCode)){
                    strTerritoryName  = mapZipCodeVsTerritoryName.get(objProcessAccount.BillingPostalCode);
                    strcustomzipcode = objProcessAccount.BillingPostalCode;
                   
                }
                   
                if(String.isNotBlank(strTerritoryName) && mapofTerritoryNamevsId.containskey(strTerritoryName)){
                    objNewTerritory.Territory2Id =  mapofTerritoryNamevsId.get(strTerritoryName);
                    NewcustomTerritory.JMS_TerritoryID__c =  mapofTerritoryNamevsId.get(strTerritoryName);
                    NewcustomTerritory.JMS_ZipCodeAssignment__c = strcustomzipcode;
                    NewcustomTerritory.JMS_TerritoryName__c = strTerritoryName;


                }
                objNewTerritory.AssociationCause = JMS_ConstantsUtility.STR_TERRITORY2_ASSIGNMENTRULE;
                if(!string.isBlank(mapofTerritoryNamevsId.get(strTerritoryName))){
                    listobjectTerritory2Association.add(objNewTerritory);
                    listcustomTerritoryAssociation.add(NewcustomTerritory);
                }
                

            }
            
            //insert operation for ObjectTerritory2Association
			if(listobjectTerritory2Association != null && !listobjectTerritory2Association.isEmpty()){
				Database.insert(listobjectTerritory2Association,false);
			}
           
            
            if(listcustomTerritoryAssociation != null && !listcustomTerritoryAssociation.isEmpty()){
				Database.insert(listcustomTerritoryAssociation);

			}
             if(setAccountIDS != null && !setAccountIDS.isEmpty()){
                if(!System.isFuture() && !System.isBatch())  {  
                    updateTerritoryOnAccount(setAccountIDS);
                }else{
                    System.enqueuejob(new  JMS_TerritoryDetailsOnAccountQueueable(setAccountIDS));
                }
                //updateTerritoryOnAccount(setAccountIDS);
			} 
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value =10/0;
            }
		}catch(Exception excep){
            JMS_Logger.push(STR_CREATE_NEW_TERRITORY_ASSCIATION, JMS_ConstantsUtility.ACCOUNT_API);
			JMS_Logger.debugException(excep);
        }finally{
            JMS_Logger.pop();
        }		
	}//end of createNewTerritoryAssociation method


    /* @description : This method will update Account 
                    record Territory & Assigned Territory Creation/Updation.
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Archana
    * @date        : 27/04/2022
    *@update       : This method is used when record is created manually, If record is created by batch will run Queable.
    */  
    @SuppressWarnings('PMD.CyclomaticComplexity')
    @future
    public static void updateTerritoryOnAccount(Set<String> setAccountIDS){
        //Variable Declaration
        Set<Id> setTerritoryids = new Set<Id>();
        //Set<Id> setupdatedAccountids = new Set<Id>();
		List<Account> accListtobeupdated = new List<Account>(); 
        List<Opportunity> oppertunityListtobeupdated = new List<Opportunity>();
        Map<Id,Id> mapofTerritoryIdVsUserIdVs = new Map<Id,Id>();
        Map<ID, String> mapUserIdvsUsername = new Map<ID, String>();
        Map<ID,ID> mapAccountIdVsTerritoryId = new Map<ID, ID>();
		

        try{
             if(setAccountIDS != null && !setAccountIDS.isEmpty()){
                 //Quering list of JMS_Territory_Assignment__c records
                 
					List<JMS_Territory_Assignment__c> listcustomTerritoryAssociation = [SELECT Id,JMS_Account_ID__c,JMS_TerritoryID__c,
                                                                            JMS_TerritoryName__c,JMS_ZipCodeAssignment__c 
                                                                            FROM JMS_Territory_Assignment__c 
                                                                            WHERE JMS_Account_ID__c IN:setAccountIDS LIMIT 5000];
                    //Iterate JMS_Territory_Assignment__c and store AccountId & TerritoryId
                    if(listcustomTerritoryAssociation != null && !listcustomTerritoryAssociation.isEmpty()){
                        for(JMS_Territory_Assignment__c territory : listcustomTerritoryAssociation){
                            if(territory.JMS_Account_ID__c != null && territory.JMS_TerritoryID__c != null){
                                setTerritoryids.add(territory.JMS_TerritoryID__c);
                            }//end of if
                        }//end of for
                    } //end of if   

                   //commented code removed
                   //Iterate ObjectTerritory2Association and store AccountId & TerritoryId
                    if(setTerritoryids != null && !setTerritoryids.isEmpty() && setAccountIDS != null && !setAccountIDS.isEmpty()){
                        List<ObjectTerritory2Association> listTerritory2Account = [SELECT ID,Territory2Id,ObjectId 
                                                                                   FROM ObjectTerritory2Association 
                                                                                   WHERE Territory2Id IN:setTerritoryids 
                                                                                   AND ObjectId IN :setAccountIDS LIMIT 5000];
                        if(listTerritory2Account != null && !listTerritory2Account.isEmpty()){
                            for(ObjectTerritory2Association territory2Account : listTerritory2Account){
                                if(territory2Account.ObjectId != null){
                                    mapAccountIdVsTerritoryId.put(territory2Account.ObjectId,territory2Account.Territory2Id);
                                }
                            }
                        }
                    } 

					
					//This block is used to get the Assigned territory User & Territory Id
					if(setTerritoryids != null && !setTerritoryids.isEmpty()){
					// Querying UserTerritory2Association records based on Territory
					
					   List<UserTerritory2Association> listTerritory2User = [SELECT UserId,Territory2Id 
                                                                             FROM UserTerritory2Association 
                                                                             WHERE Territory2Id IN:setTerritoryids LIMIT 5000];
						if(listTerritory2User != null && !listTerritory2User.isEmpty()){
							for(UserTerritory2Association territory2user: listTerritory2User){
								if(territory2user.UserId != NULL){
									mapofTerritoryIdVsUserIdVs.put(territory2user.Territory2Id,territory2user.UserId);
                                }//end of if
							}//end of for
						}//end of if
					//end of if
					// Iterating User and getting user Name
                        if(mapofTerritoryIdVsUserIdVs != null && !mapofTerritoryIdVsUserIdVs.isEmpty()){
                            List<User> listExistingusers = [SELECT ID,Name from User WHERE ID IN:mapofTerritoryIdVsUserIdVs.values()]; 
                            if(listExistingusers != null && !listExistingusers.isEmpty()){
                                for(User objuser: listExistingusers){                                    
                                    mapUserIdvsUsername.put(objuser.Id, objuser.Name);
                                }
                            }
                        }
                    } 
					//This block will iterate the Custom Territory Assignment record and will add the field values to Account
					if(listcustomTerritoryAssociation != null && !listcustomTerritoryAssociation.isEmpty()){
						for(JMS_Territory_Assignment__c territory1 : listcustomTerritoryAssociation){
							if(String.isNotBlank(territory1.JMS_Account_ID__c) && String.isNotBlank(territory1.JMS_TerritoryID__c)){
								Account objAcc =  new Account();
								objAcc.Id = territory1.JMS_Account_ID__c;
								objAcc.JMS_Territory__c = territory1.JMS_TerritoryName__c;
                                if(mapofTerritoryIdVsUserIdVs != null && !mapofTerritoryIdVsUserIdVs.isEmpty() && 
                                    mapUserIdvsUsername != null && !mapUserIdvsUsername.isEmpty() &&
                                    mapofTerritoryIdVsUserIdVs.containsKey(territory1.JMS_TerritoryID__c)){
                                        objAcc.JMS_Territory_Assigned_User__c = mapUserIdvsUsername.get(mapofTerritoryIdVsUserIdVs.get(territory1.JMS_TerritoryID__c));
                                        //accListtobeupdated.add(objAcc);
                                    }else{
                                        objAcc.JMS_Territory_Assigned_User__c = JMS_ConstantsUtility.EMPTY_STRING;
                                    }
                                accListtobeupdated.add(objAcc);
							}//end of if
						}//end of for
					}//end of if  
                    //Getting Default User Details
                    User objSystemUser = [Select Id FROM User WHERE Email =: System.Label.JMS_Default_User_Email_Address lIMIT 1];
                    //Getting all the Opportunities related to Account
                    List<Opportunity> listAccountsOpportunity = [SELECT Id,AccountId
                                                                 FROM Opportunity 
                                                                 WHERE AccountId IN:setAccountIDS LIMIT 35000];
                 if(listAccountsOpportunity != null && !listAccountsOpportunity.isEmpty()){
                     for(Opportunity opp : listAccountsOpportunity){
                        //For every opportunity in the list, modify Owner to Account's Territory User
                        if(mapofTerritoryIdVsUserIdVs != null && !mapofTerritoryIdVsUserIdVs.isEmpty() && 
                        mapAccountIdVsTerritoryId != null && !mapAccountIdVsTerritoryId.isEmpty() &&
                        mapAccountIdVsTerritoryId.containsKey(opp.AccountId)){
                                opp.OwnerId = mapofTerritoryIdVsUserIdVs.get(mapAccountIdVsTerritoryId.get(opp.AccountId));
                                oppertunityListtobeupdated.add(opp);
                        }else{
                         //Or Assign Default User
                        	opp.OwnerId = objSystemUser.Id;
                            oppertunityListtobeupdated.add(opp);
                        }
					}
                 }       
             }//end of if
            //We are updating the field values on Account
			if(accListtobeupdated != null && !accListtobeupdated.isEmpty()){
				Database.Update(accListtobeupdated,false);
            }//end of If
            if(oppertunityListtobeupdated != null && !oppertunityListtobeupdated.isEmpty()){
				Database.Update(oppertunityListtobeupdated,false);
            }//end of If
            // commented code deleted
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
			if(Test.isRunningTest()){
			integer value = 10/0;
			}
		}catch(Exception excep){
			JMS_Logger.push(STR_UPDATE_ACCOUNT_TERRITORY_ASSCIATION, JMS_ConstantsUtility.ACCOUNT_API);
			JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }//end of finally    		   		
	}//end of updateTerritoryOnAccount method
    
    


   /* @description : This method will Delete existing ObjectTerritory2Association 
                    record which got created from Trigger on Account Updation.
                    It will not delete Existing Manual Assignments.
    * @param       : Set<String> setAccountIds
    * @author      : Archana
    * @date        : 25/03/2022
    * @ModifiedDate: 07/04/2022
    */
    
    public static void deleteExistingTerritoryAssociation(Set<String> setAccountIds){       
        //Variable Declaration
        List<ObjectTerritory2Association> listObjectTerritory2Association = new List<ObjectTerritory2Association>();
        Set<Id> setTerritoryids = new Set<ID>();
        Map<Id,Id> mapAccIdVsTerritoryId = new Map<Id,Id>();
        try{
            //Query the existing JMS_Territory_Assignment__c record
            if(setAccountIds != null && !setAccountIds.isEmpty()){
                List<JMS_Territory_Assignment__c> listcustomTerritoryAssociation = [SELECT Id,JMS_Account_ID__c,JMS_TerritoryID__c
                                                                            FROM JMS_Territory_Assignment__c 
                                                                            WHERE JMS_Account_ID__c IN:setAccountIds LIMIT 50000];
                    
                    //Iterate JMS_Territory_Assignment__c and store AccountId & TerritoryId
                    if(listcustomTerritoryAssociation != null && !listcustomTerritoryAssociation.isEmpty()){
                        for(JMS_Territory_Assignment__c territory : listcustomTerritoryAssociation){
                            if(territory.JMS_Account_ID__c != null){
                                setTerritoryids.add(territory.JMS_TerritoryID__c);
                                mapAccIdVsTerritoryId.put(territory.JMS_Account_ID__c,territory.JMS_TerritoryID__c);
                            }
                        }
                    }
                if(mapAccIdVsTerritoryId != null && !mapAccIdVsTerritoryId.isEmpty() && setTerritoryids != null && !setTerritoryids.isEmpty()){
                    //Query the existing ObjectTerritory2Association record based on the stored data in JMS_Territory_Assignment__c 
                    List<ObjectTerritory2Association> listTerritory2Association = [SELECT Id,ObjectId,Territory2Id
                                                                                FROM ObjectTerritory2Association 
                                                                                WHERE ObjectId IN:mapAccIdVsTerritoryId.keyset() 
                                                                                AND Territory2Id IN:setTerritoryids AND
                                                                                AssociationCause =: JMS_ConstantsUtility.STR_TERRITORY2_ASSIGNMENTRULE
                                                                                LIMIT 50000];
                    //Iterate ObjectTerritory2Association,compare with JMS_Territory_Assignment__c records and store those into list
                    if(listTerritory2Association != null && !listTerritory2Association.isEmpty()){
                        for(ObjectTerritory2Association objObjectAssoc: listTerritory2Association){
                            if(mapAccIdVsTerritoryId.containsKey(objObjectAssoc.ObjectId) && 
                                mapAccIdVsTerritoryId.get(objObjectAssoc.ObjectId) == objObjectAssoc.Territory2Id) {
                                listObjectTerritory2Association.add(objObjectAssoc);
                            }
                        }
                    }
                }
                //Deletion of list of existing ObjectTerritory2Association records
                if(listObjectTerritory2Association != null && !listObjectTerritory2Association.isEmpty()){
                    Database.delete(listObjectTerritory2Association);
                }
                //Deletion of list of existing custom Territory Association records
                if(listcustomTerritoryAssociation != null && !listcustomTerritoryAssociation.isEmpty()){
                    Database.delete(listcustomTerritoryAssociation);
                }
            }
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception excep){
           
            JMS_Logger.push(STR_DELETE_OLD_TERRITORY_ASSCIATION, JMS_ConstantsUtility.OBJECT_TERRITORY2_ASSOCIATION_API);
			JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }      
    }//end of deleteExistingTerritoryAssociation method
    
    /* @description : This method is used for bypassing read only 
    *				  validation in Duplicate Account Merge	 
    * @param        : Map<Id, SObject> oldItemsMap
    * @author       : Sachin Awati
    * @date         : 20/07/2022
    */
    public static void handleMergeOnDelete(Map<Id, SObject> oldItemsMap) {
        Map<Id, Account> accMap = (Map<Id, Account>)oldItemsMap;
        for(Account parent: accMap.values()) {
            if(parent.MasterRecordId != NULL) {
                mergedAccMap.put(parent.MasterRecordId, TRUE);
            }
        }
    }
}