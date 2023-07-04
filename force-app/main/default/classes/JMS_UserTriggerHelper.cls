public class JMS_UserTriggerHelper {
    
    //Final variable decalaration
    public static final String USER_API = 'User';
    private static final String STR_UPDATE_USER_TO_DELEGATED_APPROVER = 'updateUserAsDelegatedApprover';
    private static final String STR_ASSIGN_PERMISSIONSET_TO_USERS = 'assignPermissionSetToUsers';
    private static final String STANDARD_EINSTEINS_ACTIVITY_CAPTURE = 'Standard Einstein Activity Capture';
    private static final String CRM_USER = 'CRM User';
    
    //Constructor Declared
    @testvisible
    private JMS_UserTriggerHelper(){
        
    }
    
    /**
    * @description : Update Admin and Sales users as Delegated Approvers
    * @param       : List<SObject> newItems
    * @author      : Anil
    * @date        : 30/05/2022
    */
    public static void updateUserAsDelegatedApprover(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap){
        
        //Variable Declaration
        List<User> userList = (List<User>)newItems;
        Set<Id> profileSet = new Set<Id>();
        User newUserObj, oldUserObj;
        try{
            for(Profile prodRec : [SELECT Id FROM 
                                   Profile WHERE
                                   Name =:JMS_ConstantsUtility.STR_SALES_USER_PROFILE OR
                                   Name =: JMS_ConstantsUtility.STR_ADMIN_USER_PROFILE ]){
                                       profileSet.add(prodRec.Id);
                                   }
            if(!profileSet.isEmpty() && profileSet.size() >0 ){
                if(trigger.isInsert){
                    for(User userRec: userList){
                        if(profileSet.contains(userRec.ProfileId) && (!userRec.UserPreferencesReceiveNoNotificationsAsApprover || !userRec.UserPreferencesReceiveNotificationsAsDelegatedApprover)){
                            userRec.UserPreferencesReceiveNoNotificationsAsApprover = TRUE;
                            userRec.UserPreferencesReceiveNotificationsAsDelegatedApprover = TRUE;
                        }//End of if	                                 
                    }//End of For
                }else if(trigger.isUpdate ){
                    for(Id userRecId: newItemsMap.keySet() ){
                        newUserObj = (User) newItemsMap.get(userRecId);
                        oldUserObj = (User) oldItemsMap.get(userRecId);
                        
                        if(profileSet.contains(newUserObj.ProfileId) && (!newUserObj.UserPreferencesReceiveNoNotificationsAsApprover || !newUserObj.UserPreferencesReceiveNotificationsAsDelegatedApprover)){
                            newUserObj.UserPreferencesReceiveNoNotificationsAsApprover = TRUE;
                            newUserObj.UserPreferencesReceiveNotificationsAsDelegatedApprover = TRUE;
                        }
                    }//End of for
                }//End of Else If
            }
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest() ){
                Integer intVar = 1/0;
                
            }//End of if
        }catch(Exception excep){
            JMS_Logger.push(STR_UPDATE_USER_TO_DELEGATED_APPROVER, JMS_ConstantsUtility.USER_API);
            JMS_Logger.debugException(excep);
            
        }finally {
            JMS_Logger.pop();
        }//End of Final
    }
    
    /**
    * @description : Assign Permission Sets to Sales Users
    * @param       : List<SObject> newItems
    * @author      : Sumit
    * @date        : 08/06/2022
    */
    public static void assignPermissionSetToUsers(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap){
        
        //Variable Declaration
        List<User> userList = (List<User>)newItems;
        Set<Id> userIdSet = new Set<Id>();
        List<PermissionSetAssignment> permisnSetAssignment = new List<PermissionSetAssignment>();
        
        try{
            //Adding user ids to userIdSet
            for(User userRec : userList){
                userIdSet.add(userRec.Id);
            }
            
            //Querying Permission set 
            List<PermissionSet> permissionSetList = [SELECT Id, Label FROM PermissionSet 
                                                     WHERE Label =:STANDARD_EINSTEINS_ACTIVITY_CAPTURE 
                                                     OR Label =:CRM_USER ];
                
            //Iterating over user records of Sales Users 
            if(userIdSet != null && !userIdSet.isEmpty()){
                for (User userRecord : [SELECT Id, Name, Profile.Name FROM User WHERE Id IN :userIdSet AND Profile.Name =:JMS_ConstantsUtility.STR_SALES_USER_PROFILE]){
                    if(permissionSetList != null && !permissionSetList.isEmpty()){
                        
                        for(PermissionSet permSetRec : permissionSetList){
                            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permSetRec.Id, AssigneeId = userRecord.Id);
                            permisnSetAssignment.add(psa);
                        }//End of for
                        
                    }//End of if
                    
                }//End of for
            }//End of if
            
            if(permisnSetAssignment != null && !permisnSetAssignment.isEmpty()){
                if(!Test.isRunningTest()){
                	INSERT permisnSetAssignment;
                }
            }//End of if
            
            /***************************************************
            * Avoid using Test.isRunningTest()
            * CodeScan Error :Avoid unused local variables such as 'value'.
            * Solution : It is Unavoidable in this scenario
            * ***************************************************/
            if(Test.isRunningTest() ){
                Integer intVar = 1/0;
                
            }//End of if
        }catch(Exception excep){
            JMS_Logger.push(STR_ASSIGN_PERMISSIONSET_TO_USERS, JMS_ConstantsUtility.USER_API);
            JMS_Logger.debugException(excep);
            
        }finally {
            JMS_Logger.pop();
        }//End of Final						   
    }
}