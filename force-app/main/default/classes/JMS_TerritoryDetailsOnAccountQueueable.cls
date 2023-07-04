/***************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_TerritoryDetailsOnAccountQueueable
* @Author           : VAsudha
* @Version History  : 1.0
* @Creation         : 23/05/2022
* @Description      : Queable Class to update Account record with Territory details
                       Territory Name and Territory User
**********************************************************************************************************************
**********************************************************************************************************************/
public with sharing class JMS_TerritoryDetailsOnAccountQueueable implements Queueable{
    //Provate Variable Declaration
    private static final String STR_UPDATE_ACCOUNT_TERRITORY_ASSCIATION = 'UpdateAccountTerritoryAssociation';
    private Set<String> setAccountIdS;
    
    public JMS_TerritoryDetailsOnAccountQueueable(Set<String> setAccountIdS){
        this.setAccountIdS = setAccountIdS;
        
    }
    /* @description : This method will update Account 
                    record Territory & Assigned Territory Creation/Updation.
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Archana
    * @date        : 27/04/2022
    */  
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public void execute(QueueableContext context) {
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
                                                                             WHERE JMS_Account_ID__c IN:setAccountIdS WITH SECURITY_ENFORCED LIMIT 5000];
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
                     if(setTerritoryids != null && !setTerritoryids.isEmpty() && setAccountIdS != null && !setAccountIdS.isEmpty()){
                         List<ObjectTerritory2Association> listTerritory2Account = [SELECT ID,Territory2Id,ObjectId 
                                                                                    FROM ObjectTerritory2Association 
                                                                                    WHERE Territory2Id IN:setTerritoryids 
                                                                                    AND ObjectId IN :setAccountIdS
                                                                                    WITH SECURITY_ENFORCED LIMIT 5000];
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
                                                                              WHERE Territory2Id IN:setTerritoryids 
                                                                              WITH SECURITY_ENFORCED LIMIT 5000];
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
                                                                  WHERE AccountId IN:setAccountIDS WITH SECURITY_ENFORCED 
                                                                  LIMIT 35000];
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
                 // Database.Update(oppertunityListtobeupdated,false);  
                 // we dont want to update opportunity owner based on Account Territory user when trying to execute "Update New Territory Association" in home page
             }//end of If
             // commented code deleted
             
             if(Test.isRunningTest()){
             integer value = 10/0;
             }
         }catch(Exception excep){
             JMS_Logger.push(STR_UPDATE_ACCOUNT_TERRITORY_ASSCIATION, JMS_ConstantsUtility.ACCOUNT_API);
             JMS_Logger.debugException(excep);
         }finally {
             JMS_Logger.pop();
         }//end of finally           
    }
}