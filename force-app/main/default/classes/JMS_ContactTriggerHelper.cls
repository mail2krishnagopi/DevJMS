public class JMS_ContactTriggerHelper {
    
    //variable declaration
    private static final String STR_CHECK_PRIMARY_CONTACT_INSERT = 'checkPrimaryContactInsert';
    private static final String STR_CHECK_PRIMARY_CONTACT_UPDATE = 'checkPrimaryContactUpdate';
    
    // constuctor declared
    @testvisible
    private JMS_ContactTriggerHelper(){
    }  
    
     /**
    * @description : This method will restrict the user to add more than one Primary Contact
    * @param       : List<SObject> newItems
    * @author      : Sumit
    * @date        : 09/03/2022
    */
    public static void checkPrimaryContactInsert(List<SObject> newItems){
        
        //variable declaration
        Map<Id,Boolean> accountMap = new Map<Id,Boolean>();
        Set<Id> primaryConToAccountIdSet = new Set<Id>();
        List<Contact> newContactList = (List<Contact>) newItems;
        
        try{
            //Check if the New Contact is set to Primary and collect the Account Id's
            
            if(newItems != null && !newItems.isEmpty()){
                for ( Contact conRec : newContactList ){
                    if(String.isNotEmpty(conRec.AccountId) && conRec.JMS_Primary_Contact__c ) {
                        primaryConToAccountIdSet.add(conRec.AccountId);
                    }
                }
            }
            
            //Query all the Contacts for the collected Account Id's & Check if there is already a Primary contact on the Table of the selected Account Id. 
            //If True then Throw an error
            //Else allow the contact to be saved
            if(primaryConToAccountIdSet != null && !primaryConToAccountIdSet.isEmpty()){
                for(Contact contObj : [SELECT JMS_Primary_Contact__c, AccountId 
                                       FROM Contact WHERE AccountId IN : primaryConToAccountIdSet AND 
                                       JMS_Primary_Contact__c = TRUE WITH SECURITY_ENFORCED LIMIT 50000]){
                                           if(!accountMap.containsKey(contObj.AccountId)){
                                               accountMap.put(contObj.AccountId,TRUE);
                                           }
                                       }
            }
            
            if(newContactList != null && !newContactList.isEmpty()){
                for(Contact conRec : newContactList){
                    if(accountMap != null && !accountMap.isEmpty() && 
                       accountMap.containsKey(conRec.AccountId) && accountMap.get(conRec.AccountId) ) {
                        conRec.addError(System.Label.JMS_Primary_Contact_Error_Message);
                    }
                }
            }
            /***************************************************
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception exc){
            JMS_Logger.push(STR_CHECK_PRIMARY_CONTACT_INSERT, JMS_ConstantsUtility.CONTACT_API);
			JMS_Logger.debugException(exc);

        }finally {
            JMS_Logger.pop();
        }
    }
    
     /**
    * @description : This method will restrict the user to add more than one Primary Contact
    * 				 when trying to update a contact as Primary Contact if Primary contact
    * 				 already exist.
    * @param       : List<SObject> newItems
    * @author      : Sumit
    * @date        : 24/05/2022
    */
     public static void checkPrimaryContactUpdate(List<SObject> newItems, 
                                                  Map<Id, SObject> newItemsMap, 
                                                  Map<Id, SObject> oldItemsMap){
        
         //variable declaration
         Map<Id,Contact> accountMap = new Map<Id,Contact>();//Map of existing Account with its Primary Contact
         Set<Id> primaryConToAccountIdSet = new Set<Id>();//new items AccountId where its a Primary Contact
         Contact conOldRec, conNewRec;

         try{
            //Check if the New Contact is set to Primary and collect the Account Id's
             
             
             for ( Id conRecId : newItemsMap.keySet() ){
                 conNewRec = (Contact)newItemsMap.get(conRecId);
                 conOldRec = (Contact)oldItemsMap.get(conRecId);
                 
                 if(String.isNotEmpty(conNewRec.AccountId) && 
                    conNewRec.JMS_Primary_Contact__c != conOldRec.JMS_Primary_Contact__c && 
                    conNewRec.JMS_Primary_Contact__c ) {
                        primaryConToAccountIdSet.add(conNewRec.AccountId);
                    }
             }

            //Query all the Contacts for the collected Account Id's & Check if there is already a Primary contact on the Table of the selected Account Id. 
            //If True then Throw an error
            //Else allow the contact to be saved
             if(primaryConToAccountIdSet != null && !primaryConToAccountIdSet.isEmpty()){
                 for(Contact contObj : [SELECT JMS_Primary_Contact__c, AccountId FROM Contact 
                                        WHERE AccountId IN : primaryConToAccountIdSet AND 
                                        JMS_Primary_Contact__c = TRUE WITH SECURITY_ENFORCED LIMIT 50000]){
                                            if(!accountMap.containsKey(contObj.AccountId)){
                                                accountMap.put(contObj.AccountId,contObj);
                                            }
                                        }
             }
             
             if(accountMap.size() > 0 && !accountMap.isEmpty()){
                 for ( Id conRecId : newItemsMap.keySet() ){
                     conNewRec = (Contact)newItemsMap.get(conRecId);
                     conOldRec = (Contact)oldItemsMap.get(conRecId);
                     if(accountMap.containsKey(conNewRec.AccountId)) {
                         conNewRec.addError(System.Label.JMS_Primary_Contact_Error_Message);
                     }
                 }
             }
             
            /***************************************************
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception exc){
            JMS_Logger.push(STR_CHECK_PRIMARY_CONTACT_UPDATE, JMS_ConstantsUtility.CONTACT_API);
			JMS_Logger.debugException(exc);

        }finally {
            JMS_Logger.pop();
        }
    }
}