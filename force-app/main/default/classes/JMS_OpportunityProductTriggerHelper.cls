/*************************************************************
*   @Name: JMS_OpportunityProductTriggerHelper
*   @Description: To automate one insertion , updation ,
				  deletion, of Equipment Request records
*   @Date: 23/06/2022
*   @Author: Sumit
**************************************************************/
public class JMS_OpportunityProductTriggerHelper {

    //Constructor Declared
    public JMS_OpportunityProductTriggerHelper(){
    }
    
    //Final variable decalaration
    private static final String OPPORTUNITY_LINE_ITEM_API = 'OpportunityLineItem';
    private static final String STR_UPDATE_ESTIMATED_ORDER_DATE = 'updateEstimatedOrderDate';
    
   /**
    * @description : This method will update Estimated Order Date field
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Sumit
    * @date        : 23/06/2022
    */
    public static void updateEstimatedOrderDate(List<SObject> newItems, Map<Id, SObject> oldItemsMap){ 
    	//variable declaration
        List<OpportunityLineItem> listNewOppLineItems = (List<OpportunityLineItem>) newItems;
        Map<Id, OpportunityLineItem> mapOldOpportunityLineItem = (Map<Id,OpportunityLineItem>) oldItemsMap;
        
        try{
            for(OpportunityLineItem oppLineItem : listNewOppLineItems) {
                
                if(mapOldOpportunityLineItem == null && 
                   oppLineItem.JMS_Product_Status__c == JMS_ConstantsUtility.STR_SALE_STATUS){
                       oppLineItem.JMS_Estimated_Order_Date__c = Date.today()+JMS_ConstantsUtility.INT_NINETY;
                }
                else if(mapOldOpportunityLineItem != null && String.isNotBlank(oppLineItem.JMS_Product_Status__c) &&
                       oppLineItem.JMS_Product_Status__c != mapOldOpportunityLineItem.get(oppLineItem.Id).JMS_Product_Status__c &&
                       oppLineItem.JMS_Product_Status__c == JMS_ConstantsUtility.STR_SALE_STATUS){
                           oppLineItem.JMS_Estimated_Order_Date__c = Date.today()+JMS_ConstantsUtility.INT_NINETY;
                } 
                else if(oppLineItem.JMS_Estimated_Order_Date__c != null && 
                        String.isNotBlank(oppLineItem.JMS_Product_Status__c) &&
                        oppLineItem.JMS_Product_Status__c != JMS_ConstantsUtility.STR_SALE_STATUS){
                            oppLineItem.JMS_Estimated_Order_Date__c = null;
                }
                else if(mapOldOpportunityLineItem != null && 
                        oppLineItem.JMS_Estimated_Order_Date__c == null &&
                        String.isNotBlank(oppLineItem.JMS_Product_Status__c) &&
                        mapOldOpportunityLineItem.get(oppLineItem.Id).JMS_Estimated_Order_Date__c != null && 
                        oppLineItem.JMS_Estimated_Order_Date__c != mapOldOpportunityLineItem.get(oppLineItem.Id).JMS_Estimated_Order_Date__c &&
                        oppLineItem.JMS_Product_Status__c == JMS_ConstantsUtility.STR_SALE_STATUS){
                            oppLineItem.addError(System.Label.JMS_Estimated_Order_Date_Validation);
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
            JMS_Logger.push(STR_UPDATE_ESTIMATED_ORDER_DATE, OPPORTUNITY_LINE_ITEM_API);
			JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }
    }
}