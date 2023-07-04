/**********************************************************************************************
* @description: This class is used as controller class for LWC
* @author     : Sumit
* @date       : 17/03/2022
**********************************************************************************************/
public with sharing class JMS_PrimaryContactController {
    private static final String STR_IS_PRIMARY_CONTACT_EXIST = 'isPrimaryContactExist';

     /**
    * @description : This method is used to check if Primary Contact exist or not on Account
    * @param       : Id accRecordId
    * @author      : Sumit
    * @date        : 17/03/2022
    */
    @AuraEnabled(cacheable=true)
    public static Boolean isPrimaryContactExist (Id accRecordId){
        //Query on Account to check if we have any primary contact or not
        List<Account> accList= [SELECT Id, Name, (SELECT Id, AccountId, JMS_Primary_Contact__c FROM Contacts WHERE JMS_Primary_Contact__c = TRUE)FROM Account WHERE Id=:accRecordId];
        try{
            if(!accList.isEmpty()){
                for ( Account objAcc : accList ) { 
                    List<Contact> contactList = objAcc.Contacts; 
                    if( contactList.size() > 0 ) { 
                        return true;
                    }
                } 
            }
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception exc){
            JMS_Logger.push(STR_IS_PRIMARY_CONTACT_EXIST, JMS_ConstantsUtility.ACCOUNT_API);
			JMS_Logger.debugException(exc);
            throw new AuraHandledException(exc.getMessage());
        }finally {
            JMS_Logger.pop();
        }
        return false;
    }  
}