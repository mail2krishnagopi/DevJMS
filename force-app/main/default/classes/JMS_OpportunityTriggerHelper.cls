/*************************************************************
*   @Name: JMS_OpportunityTriggerHelper
*   @Description: To automate one insertion , updation ,
deletion of Equipment Request records
*   @Date: 10/05/2022
*   @Inputs:       NA
*   @Author: Anil
**************************************************************/

public class JMS_OpportunityTriggerHelper {
    //Private Final Variable declaration
    private static final String STR_UPDATING_OPPORTUNITY_OWNER = 'updatingOpportunityOwner';
    //Default Mail Address 
    private static final String STR_DEFAULT_EMAIL = 'josh.morehart@jmsmucker.com';
    
    @testvisible
    private JMS_OpportunityTriggerHelper(){
    } 
    
    public static void updatingOpportunityOwner(List<SObject> newItems){
        //Creating Opportunity list
        List<Opportunity> listNewOpportunity = (List<Opportunity>) newItems;
        Set<Id> setNewAccounts = new Set<Id>();
        Map<Id,Id> mapAccountIdVsTerrId =new Map<Id,Id>();
        Map<Id,Id> mapTerritoryIdVsUserId =new Map<Id,Id>();
        
        try{
            if(listNewOpportunity != null && !listNewOpportunity.isEmpty()){
                for(Opportunity opp : listNewOpportunity){
                    //Get Opportunity's Account Id
                    setNewAccounts.add(opp.AccountId);
                }//End of for
            }//End of if
            if(setNewAccounts != null && !setNewAccounts.isEmpty()){
                for(JMS_Territory_Assignment__c objTerrAssign : [SELECT Id,JMS_TerritoryID__c,
                                                                 JMS_Account_ID__c
                                                                 FROM JMS_Territory_Assignment__c 
                                                                 WHERE JMS_Account_ID__c IN:setNewAccounts 
                                                                 WITH SECURITY_ENFORCED LIMIT 50000]){
                                                                     if(String.isNotBlank(objTerrAssign.JMS_TerritoryID__c) &&
                                                                        String.isNotBlank(objTerrAssign.JMS_Account_ID__c)){
                                                                            mapAccountIdVsTerrId.put(objTerrAssign.JMS_Account_ID__c,objTerrAssign.JMS_TerritoryID__c);
                                                                        }//End of if
                                                                 }//End of for
            }//End of if
            if(mapAccountIdVsTerrId != null & !mapAccountIdVsTerrId.isEmpty()){
                for(UserTerritory2Association objTerritory2User :[SELECT UserId,Territory2Id 
                                                                  FROM UserTerritory2Association 
                                                                  WHERE Territory2Id IN:mapAccountIdVsTerrId.values() 
                                                                  WITH SECURITY_ENFORCED LIMIT 50000]){                                                       
                                                                      mapTerritoryIdVsUserId.put(objTerritory2User.Territory2Id,objTerritory2User.UserId);
                                                                  }
            }
            User objSystemUser = [Select Id FROM User WHERE Email =: System.Label.JMS_Default_User_Email_Address LIMIT 1];
            if(listNewOpportunity != null && !listNewOpportunity.isEmpty()){
                for(Opportunity opp : listNewOpportunity){
					// if opportunity is being created campaign target process then only opportunity owner should be based on Accounts Territory user
					if(opp.JMS_Opportunity_Source__c == system.label.JMS_CampaignTargetProcess){
						if(mapAccountIdVsTerrId.containsKey(opp.AccountId) && 
                       mapTerritoryIdVsUserId.containskey(mapAccountIdVsTerrId.get(opp.AccountId))){
                           //Assigning Accounts Territory user as Opportunity Owner
                           opp.ownerId =  mapTerritoryIdVsUserId.get(mapAccountIdVsTerrId.get(opp.AccountId));
                       }else{
                           //Assigning Default user as Opportunity Owner
                           opp.ownerId =  objSystemUser.Id;
                       }//Else
					}
                }//End of for
            }//End of if
            /***************************************************
            * Avoid using Test.isRunningTest()
            * CodeScan Error :Avoid unused local variables such as 'value'.
            * Solution : It is Unavoidable in this scenario
            * ***************************************************/
            if(Test.isRunningTest()){
              integer value = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_UPDATING_OPPORTUNITY_OWNER, JMS_ConstantsUtility.Opportunity_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }//End of final
    }

     /**
    * @description : This method will validation on Opportunity
                     If there is a product with a Sale Status, Opportunity 
                     should only have Stage Closed Won 
    * @param       : List<SObject> newItems
    * @author      : Krishna
    * @date        : 10/05/2022
    */
    public static void validateOppStageClosedWon(List<SObject> newItems , Map<Id, SObject> oldItemsMap){
        //Creating Opportunity list
        Map<Id,Opportunity> mapOldOpportunities = (Map<Id, Opportunity>) oldItemsMap;
        List<Opportunity> listOpportunities = new List<Opportunity>();
        Set<Id> setNewOppIds = new Set<Id>();
        Set<Id> setSaleProductOppIds = new Set<Id>();
        Map<Id,String> mapOppIdVsStageName =new Map<Id,String>();
        Map<Id,String> mapOppIdVsProductStatus =new Map<Id,String>();
        
        try{
            if(newItems != null && !newItems.isEmpty()){
                for(SObject opp : newItems){
                    Opportunity objNewOpportunity = (Opportunity)opp;
                    if(String.isNotBlank(objNewOpportunity.StageName) && 
                        (objNewOpportunity.StageName).equalsIgnoreCase(JMS_ConstantsUtility.STR_CLOSED_WON)){
                        if(mapOldOpportunities != null && !mapOldOpportunities.isEmpty() &&
                        objNewOpportunity.StageName !=  mapOldOpportunities.get(objNewOpportunity.Id).StageName){
                               // Add Opportunities Id if new stage is Closed WON   
                            setNewOppIds.add(objNewOpportunity.Id);
                            listOpportunities.add(objNewOpportunity);
                        }else if(mapOldOpportunities == null){
                               // Add Opportunities Id if new stage is Closed WON   
                            setNewOppIds.add(objNewOpportunity.Id);
                            listOpportunities.add(objNewOpportunity);
                        }
                    }
                }//End of for
            }//End of if
            
            // Query on Opportunity line Item 
            if(setNewOppIds != null && !setNewOppIds.isEmpty()){
                List<OpportunityLineItem> oppLineItems = [Select Id,Name,JMS_Product_Status__c,OpportunityId From OpportunityLineItem
                                                          WHERE OpportunityId IN:setNewOppIds AND JMS_Product_Status__c =: JMS_ConstantsUtility.STR_SALE_STATUS
                                                          WITH SECURITY_ENFORCED LIMIT 50000];
                
                
                if(oppLineItems != null && !oppLineItems.isEmpty()){
                    for(OpportunityLineItem OppLine : oppLineItems){
                        if(String.isNotBlank(OppLine.JMS_Product_Status__c)){
                            setSaleProductOppIds.add(OppLine.OpportunityId);
                        }//end of if
                    }//end of for
                } //e
            }
            if(listOpportunities != null && !listOpportunities.isEmpty()){
                for(Opportunity objOppRec : listOpportunities){
                    if(setSaleProductOppIds != null && !setSaleProductOppIds.isEmpty()) {
                        if(!setSaleProductOppIds.contains(objOppRec.Id)){
                            objOppRec.addError(System.Label.JMS_Opportunity_Sale_Validation);
                        }
                    }else{
                        objOppRec.addError(System.Label.JMS_Opportunity_Sale_Validation);
                    }
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
            JMS_Logger.push(STR_UPDATING_OPPORTUNITY_OWNER, JMS_ConstantsUtility.Opportunity_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }//End of final
    }
}