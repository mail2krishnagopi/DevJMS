/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_MigrateBrokerCallStgnToSObjectHelper
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 02/05/2022
* @Description      : This class is validationg Broker Call Landing records 
                        and giving the errors
**********************************************************************************************************************
**********************************************************************************************************************/
public class JMS_MigrateBrokerCallStgnToSObjectHelper {  
     /**
    * @description : This method will validate the entered values on Broker call Stajing object
    * @param       : List<SObject> newItems
    * @author      : ANil
    * @date        : 06/05/2022
    */

    //Broker Call object Mapping validations
    public static String validateBrokerCall(JMS_Broker_Call_Landing__c objBCLanding){
        String strBcErrorMessage = JMS_ConstantsUtility.EMPTY_STRING;
        set<String> setAccountPlanToIds = new set<String>();
        set<String> setCampignNames = new set<String>();
        set<String> setProductItemNum = new set<String>();

        //Validating Broker name is not EMPTY
        if(String.isBlank(objBCLanding.JMS_Broker_Name__c)){
            strBcErrorMessage += System.Label.JMS_Broker_Name_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        
        if(String.isBlank(objBCLanding.JMS_Broker_Name__c)){
            strBcErrorMessage += System.Label.JMS_Broker_Name_Missing_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        //Validating Broker call comments
        if(String.isBlank(objBCLanding.JMS_Call_Comments__c) && String.isNotBlank(objBCLanding.JMS_Item_Status__c)){
            //Item Status Upper case
            String strItemStatusUpperCase = (objBCLanding.JMS_Item_Status__c).toUpperCase();
            String strSaleUpperCase = (JMS_ConstantsUtility.STR_SALE).toUpperCase();
            if(strItemStatusUpperCase != strSaleUpperCase){
                strBcErrorMessage += System.Label.JMS_Broker_call_Comment_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
            }
        }
      
        //Validating Broker Call ID 
        if(String.isBlank(objBCLanding.JMS_Broker_call_id__c) ){   
            strBcErrorMessage += System.Label.JMS_Broker_Call_Id_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        //Validating Broker Call ID 
        if(String.isNotBlank(objBCLanding.JMS_Call_Date__c) ){   
            Date callDate = Date.parse(objBCLanding.JMS_Call_Date__c);
            Date todayDate = Date.today();
            if(callDate > todayDate){
                strBcErrorMessage += System.Label.JMS_Call_Date_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
            }
        }else{
            strBcErrorMessage += System.Label.JMS_Call_Date_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        return strBcErrorMessage;
    }

    /**
    * @description : This method will validate the entered values on Broker call Stajing object
    * @param       : List<SObject> newItems
    * @author      : ANil
    * @date        : 10/05/2022
    */
    //Account object Mapping validations
    public static String validateAccount(JMS_Broker_Call_Landing__c objBCLanding){
        String strAccErrorMessage = JMS_ConstantsUtility.EMPTY_STRING;
        if(String.isBlank(objBCLanding.JMS_Company_Name__c)){
             strAccErrorMessage += System.Label.JMS_Company_Name_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objBCLanding.JMS_Company_Address__c)){
             strAccErrorMessage += System.Label.JMS_Company_Address_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objBCLanding.JMS_Company_City__c)){
             strAccErrorMessage += System.Label.JMS_Company_City_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objBCLanding.JMS_Company_State__c)){
             strAccErrorMessage += System.Label.JMS_Company_State_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        else if(String.isNotBlank(objBCLanding.JMS_Company_State__c) && (objBCLanding.JMS_Company_State__c).length() < JMS_ConstantsUtility.INT_THREE){
            strAccErrorMessage += System.Label.JMS_State_Code_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objBCLanding.JMS_Company_Zip__c)){
             strAccErrorMessage += System.Label.JMS_Company_ZipCode_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        if(String.isBlank(objBCLanding.JMS_Company_Country__c)){
            strAccErrorMessage += System.Label.JMS_Operator_Country_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }else if(String.isNotBlank(objBCLanding.JMS_Company_Country__c) && (objBCLanding.JMS_Company_Country__c).length() < JMS_ConstantsUtility.INT_FOUR){
            strAccErrorMessage += System.Label.JMS_Country_Short_Form_Error_Msg + JMS_ConstantsUtility.SPACE_STRING;
        }
        return strAccErrorMessage;
    }

}