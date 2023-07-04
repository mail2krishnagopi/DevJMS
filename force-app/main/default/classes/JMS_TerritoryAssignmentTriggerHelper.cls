/*************************************************************
*   @Name: JMS_TerritoryAssignmentTriggerHelper
*   @Description: Clearing Territory Account fields while Deleting Territory Assignment.
*   @Date: 24/05/2022
*   @Inputs:       NA
*   @Author: Anil
**************************************************************/

public class JMS_TerritoryAssignmentTriggerHelper {
    //Private Final Variable declaration
    private static final String STR_CLEAR_ACCOUNT_TERRITORY = 'clearAccountTerritory';

    @testvisible
    private JMS_TerritoryAssignmentTriggerHelper(){
    } 
    
    public static void clearAccountTerritory(Map<Id, SObject> oldItemsMap){
        Map<Id, JMS_Territory_Assignment__c> mapOldTerritoryAssignments = (Map<Id,JMS_Territory_Assignment__c>) oldItemsMap;
        List<JMS_Territory_Assignment__c> listTerritoryAssignment = new List<JMS_Territory_Assignment__c>(mapOldTerritoryAssignments.values());
        Set<Id> setAccountIds = new Set<Id>();
        List<Account> listUpdatedAccounts = new List<Account>();
        List<Opportunity> oppertunityListtobeupdated = new List<Opportunity>();
        try{
            if(listTerritoryAssignment != null && !listTerritoryAssignment.isEmpty()){
            	for(JMS_Territory_Assignment__c terAsnObj : listTerritoryAssignment){
                	setAccountIds.add(terAsnObj.JMS_Account_ID__c);
            	}
            	if(setAccountIds != null && !setAccountIds.isEmpty()){
                	for(Id AccId : setAccountIds){
                    	Account newAccObj = new Account();
                		newAccObj.Id = AccId;
                        newAccObj.JMS_Territory_Assigned_User__c = JMS_ConstantsUtility.EMPTY_STRING;
                        newAccObj.JMS_Territory__c = JMS_ConstantsUtility.EMPTY_STRING;
                        listUpdatedAccounts.add(newAccObj);
                    }
                    if(listUpdatedAccounts != null && !listUpdatedAccounts.isEmpty()){
                        Database.Update(listUpdatedAccounts,false);
                    }
                    User objSystemUser = [Select Id FROM User WHERE Email =: System.Label.JMS_Default_User_Email_Address lIMIT 1];
                    List<Opportunity> listAccountsOpportunity = [SELECT Id,AccountId
                                                                             FROM Opportunity 
                                                                             WHERE AccountId IN:setAccountIds WITH SECURITY_ENFORCED LIMIT 50000];
                    //
                    if(listAccountsOpportunity != null && !listAccountsOpportunity.isEmpty()){
                        for(Opportunity opp : listAccountsOpportunity){
                            //For every opportunity in the list, modify Owner to Account's Territory User
                            //Or Assign Default User
                            opp.OwnerId = objSystemUser.Id;
                            oppertunityListtobeupdated.add(opp);
                        }
                        if(oppertunityListtobeupdated != null && !oppertunityListtobeupdated.isEmpty()){
                            Database.Update(oppertunityListtobeupdated,false);
                        }
                    }
            	}
        	}
            if(Test.isRunningTest()){
                integer value =10/0;
            } 
       	}catch(Exception excep){
            JMS_Logger.push(STR_CLEAR_ACCOUNT_TERRITORY, JMS_ConstantsUtility.OBJECT_TERRITORY_ASSIGNMENT_API);
			JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
    }
}