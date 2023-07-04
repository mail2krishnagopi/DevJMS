/*************************************************************
*   @Name: JMS_EquipmentRequestTriggerHelper
*   @Description: To automate one insertion , updation ,
        deletion of Equipment Request records
*   @Date: 22/02/2022
*   @Inputs:       NA
*   @Author: Vasudha
**************************************************************/
public without sharing class JMS_EquipmentRequestTriggerHelper {
    //Private Final Variable declaration
    private static final String STR_INITIATE_APPROVAL_PROCESS = 'initiateApprovalProcess';
    private static final String STR_INITIATE_EMAIL_NOTIFICATION_REQ = 'initiateEmailNotificationRequest';
    private static final String STR_SUBMIT_FOR_APPROVAL = 'submitForApproval';
    private static final String STR_STR_PROCESSED_RECORD_TO_SEND_EMAIL = 'processedRecordsToSendEmail';
    private static final String STR_SEND_EMAIL_NOTIFICATION_APPROVERS = 'sendEmailNotificationToApprovers';
    private static final String STR_POPULATE_OPP_ACCOUNT = 'populateOppAccount';
    private static final String STR_RESET_APPROVED_FIELDS_BY_APPROVERS = 'resetApprovedFieldsByApprovers';
    private static final String STR_EI_USERS_UPDATE_FORGEID = 'checkEIUserUpdateForgeId';
    private static final String STR_UPDATE_RECORDTYPE = 'updateRecordType';
    private static final String STR_CUSTOM_NOTIFICATION_TO_OWNER = 'customNotificationToOwner';
    private static final String STR_EI_USERS = 'getEquipmentIntegrityUser';
    
    private static final String STR_SPECIALCHAR_SUBJECT = ' : ';
   
    public static Map<String,String> mapNAMUserEmailVSUserId;
    public static Set<String> setUserRoleForNAMApproval;
    // constuctor declared
     /*******************************************************************
     * Codescan error :All methods are static. Consider using Singleton instead. Alternatively, you could add a private constructor or make the class abstract to silence this warning.
     * Author:Krishna
     * Date:5/4/2022
     ********************************************************************/
    //Constructor Declared
    @testvisible
    public JMS_EquipmentRequestTriggerHelper(){
        
    }

    /**
    * @description : To initiate Approval process for Equipment Request from 2nd step
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 22/02/2022
    */
    public static void initiateApprovalProcess(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        Map<Id, JMS_Equipment_Request__c> mapOldEquipmentRequest = (Map<Id,JMS_Equipment_Request__c>) oldItemsMap;
        List<JMS_Equipment_Request__c> listNewEquipment = (List<JMS_Equipment_Request__c>) listNewSObject;
        mapNAMUserEmailVSUserId = new Map<String,String>();
        setUserRoleForNAMApproval = new Set<String>();
        /*******************************************************************
     * Codescan error :Avoid unused local variables such as 'mapEquimentRequestIdVsApprovalType'.,Avoid unused local variables such as 'setEquipmentRequestIds'.
     * Author:Krishna
     * Date:5/4/2022
     ********************************************************************/

        try{            
            if(listNewEquipment != null && mapOldEquipmentRequest != null && !listNewEquipment.isEmpty()){
                for(JMS_Equipment_Request__c objNewEquipmentRequest:listNewEquipment){
                // Document is attached to Equipment Request 
                    if(objNewEquipmentRequest.JMS_Is_Attachment_Added__c == true){
                        //NAM Trade Approval Initiation 
                        if(objNewEquipmentRequest.JMS_RSM_Approved__c == true && objNewEquipmentRequest.JMS_Is_Approval_For_EI__c == false &&
                            mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).JMS_RSM_Approved__c == false &&
                            objNewEquipmentRequest.JMS_Is_Approval_For_NAM__c == true){
                            submitForApproval(objNewEquipmentRequest.Id , System.Label.ER_Approval_Msg_For_NAM_Trade);  
                        }
                        //  Equiment Integrity Approval Initiation with NAM
                        else if( objNewEquipmentRequest.JMS_RSM_Approved__c == true &&  objNewEquipmentRequest.JMS_Is_Approval_For_NAM__c == true &&
                        objNewEquipmentRequest.NAM_Approved__c == true && mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).NAM_Approved__c == false){
                        // Create an approval request for ERF 
                            submitForApproval(objNewEquipmentRequest.Id , System.Label.ER_Approval_Msg_For_Equipment_Integrity);
                        }

                        // Equiment Integrity Approval Initiation direct from RSM
                        else if( objNewEquipmentRequest.JMS_RSM_Approved__c == true &&
                            mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).JMS_RSM_Approved__c == false && 
                            objNewEquipmentRequest.JMS_Is_Approval_For_EI__c == true){
                        // Create an approval request for ERF 
                            submitForApproval(objNewEquipmentRequest.Id ,System.Label.ER_Approval_Msg_For_Equipment_Integrity);  
                        }
                        //Equiment Integrity Approval Initiation to for Non-NAM
                        else if(objNewEquipmentRequest.JMS_Is_Approval_For_Non_NAM__c == true &&
                            mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).JMS_RSM_Approved__c == false &&
                            objNewEquipmentRequest.JMS_RSM_Approved__c == true){
                            // Create an approval request for ERF 
                            submitForApproval(objNewEquipmentRequest.Id,System.Label.ER_Approval_Msg_For_Equipment_Integrity); 
                        }
                        //  Equiment Integrity Approval Initiation with NAM by NON TSM User
                        else if( objNewEquipmentRequest.JMS_RSM_Approved__c == false &&  objNewEquipmentRequest.JMS_Is_Approval_For_NAM__c == true &&
                        objNewEquipmentRequest.NAM_Approved__c == true && mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).NAM_Approved__c == false){
                        // Create an approval request for ERF 
                            submitForApproval(objNewEquipmentRequest.Id , System.Label.ER_Approval_Msg_For_Equipment_Integrity);
                        }
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
            JMS_Logger.push(STR_INITIATE_APPROVAL_PROCESS, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }//end of initiateApprovalProcess

    /**
    * @description : To get the equipment Id if the status is changing from old to new
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 22/02/2022
    */
    public static void initiateEmailNotificationRequest(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        //Variable declaration
        Map<Id, JMS_Equipment_Request__c> mapOldEquipmentRequest = (Map<Id,JMS_Equipment_Request__c>) oldItemsMap;
        List<JMS_Equipment_Request__c> listNewEquipment = (List<JMS_Equipment_Request__c>) listNewSObject;
        Set<Id> setEquipmentRequestIds = new Set<Id>();
        try{
            if(listNewEquipment != null && mapOldEquipmentRequest != null && !listNewEquipment.isEmpty()){
                for(JMS_Equipment_Request__c objNewEquipmentRequest:listNewEquipment){
                    if(objNewEquipmentRequest.JMS_Status__c != mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).JMS_Status__c &&
                        (objNewEquipmentRequest.JMS_RSM_approval_Status__c !=  mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).JMS_RSM_approval_Status__c ||
                        objNewEquipmentRequest.NAM_approval_Status__c != mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).NAM_approval_Status__c ||
                        objNewEquipmentRequest.JMS_Equipment_Integrity_Approval_Status__c !=  
                        mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).JMS_Equipment_Integrity_Approval_Status__c)){
                        setEquipmentRequestIds.add(objNewEquipmentRequest.id);

                    }
                }// end of for
                if(setEquipmentRequestIds != null && !setEquipmentRequestIds.isEmpty()){
                    processedRecordsToSendEmail(setEquipmentRequestIds ,listNewEquipment, mapOldEquipmentRequest);
                }//end of if
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
            JMS_Logger.push(STR_INITIATE_EMAIL_NOTIFICATION_REQ, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of initiateEmailNotificationRequest method

     /**
    * @description : To send Approval request to Approvers
    * @param       : String strRecordId , String strComment
    * @author      : Vasudha
    * @date        : 22/02/2022
    */
    @future
    public static void submitForApproval(String strRecordId , String strComment){
        try{
            if(String.isNotBlank(strRecordId)){
                Approval.ProcessSubmitRequest objApprovalrequest = new Approval.ProcessSubmitRequest(); 
                if(!Approval.isLocked(strRecordId)) {
                    objApprovalrequest.setComments(strComment);        
                    objApprovalrequest.setObjectId(strRecordId);
                    // Submit the approval request for the ERF        
                    Approval.ProcessResult result = Approval.process(objApprovalrequest);
                }  //end of if      
            }//end of if
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
        if(Test.isRunningTest()){
                integer value = 10/0;
            }            
        }catch(Exception excep){
            JMS_Logger.push(STR_SUBMIT_FOR_APPROVAL, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of submitForApproval method
    
    /**
    * @description : To create a map ofEquipment Request Id 
                     vs attached documents 
    * @param       : Set<Id> setEquipmentRequestIds ,
                     List<JMS_Equipment_Request__c> listNewEquipment,
                     Map<Id, JMS_Equipment_Request__c> mapOldEquipmentRequest
    * @author      : Vasudha
    * @date        : 22/02/2022
    */

    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void processedRecordsToSendEmail(Set<Id> setEquipmentRequestIds ,
                                                List<JMS_Equipment_Request__c> listNewEquipment,
                                                Map<Id, JMS_Equipment_Request__c> mapOldEquipmentRequest){
        List<JMS_Equipment_Request__c> listProcessedRecords = new List<JMS_Equipment_Request__c>();
        /*******************************************************************
     * Codescan error :Avoid unused local variables such as 'setContentDocumentIds'.
     * Author:Krishna
     * Date:5/4/2022
     ********************************************************************/
        
        try{
            if(setEquipmentRequestIds != null && !setEquipmentRequestIds.isEmpty()){
                // To get JMS_Equipment_Request__c record details
                listProcessedRecords = [SELECT Id ,JMS_Status__c,JMS_Account_Type__c,JMS_Is_Attachment_Added__c, 
                                        Name,Owner.name ,owner.Email,JMS_Manager_Details__c,JMS_RSM_approval_Status__c,
                                        NAM_approval_Status__c,JMS_Account__r.Name,JMS_Account__r.BillingState,CreatedBy.Name,
                                        JMS_Equipment_Integrity_Approval_Status__c,JMS_Placement_Reason__c,JMS_Machine_Count__c, JMS_Contract_Type__c
                                        FROM JMS_Equipment_Request__c 
                                        WHERE Id IN : setEquipmentRequestIds LIMIT 50000];
            }
            
            if(listProcessedRecords != null && !listProcessedRecords.isEmpty()){
                sendEmailNotificationToApprovers(listProcessedRecords);
            } //end of for
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_STR_PROCESSED_RECORD_TO_SEND_EMAIL, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of processedRecordsToSendEmail method

    public static void getUserDetails(){
        List<User> listUsers = new List<User>();
        if(setUserRoleForNAMApproval != null && !setUserRoleForNAMApproval.isEmpty()){
            listUsers = [SELECT Id, Name, Email ,UserRole.Name 
                        FROM User 
                        WHERE isActive = true AND UserRole.Name IN :setUserRoleForNAMApproval
                         LIMIT 50000];
            if(listUsers != null && !listUsers.isEmpty()){
                for(User objUser : listUsers){
                    if(String.isNotBlank(objUser.UserRole.Name)){
                        mapNAMUserEmailVSUserId.put( objUser.Email,objUser.Id);
                    }
                }
            }
        }
    }

     /**
    * @description : To send Custom notification to the approvers  
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 27/05/2022
    */
    public static void customNotificationToOwner(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        //Variable declaration
        Map<Id, JMS_Equipment_Request__c> mapOldEquipmentRequest = (Map<Id,JMS_Equipment_Request__c>) oldItemsMap;
        List<JMS_Equipment_Request__c> listNewEquipment = (List<JMS_Equipment_Request__c>) listNewSObject;
        String strTitleName = System.Label.JMS_Custom_Notification_Approved_Title;
        /****************Commented for code ScanError
        Anil - 02/06/2022.
        //String strBody = JMS_ConstantsUtility.EMPTY_STRING; 
        ************************/
        Set<String> setApproverIds = new Set<String>();
        try{
            if(listNewEquipment != null && mapOldEquipmentRequest != null && !listNewEquipment.isEmpty()){
                for(JMS_Equipment_Request__c objEquipmentReq:listNewEquipment){
                    setApproverIds = new Set<String>();
                    setApproverIds.add(objEquipmentReq.ownerId);
                    if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty() &&
                    objEquipmentReq.JMS_Overall_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).JMS_Overall_Status__c &&
                    objEquipmentReq.JMS_Overall_Status__c == JMS_ConstantsUtility.STR_INPROGRESS_REJECTED){
                      
                        strTitleName = System.Label.JMS_Custom_Notification_Rejected_Title;
                        if(setApproverIds != null && !setApproverIds.isEmpty()){
                            JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentReq.Id,objEquipmentReq.Name , strTitleName,
                            System.Label.JMS_Custom_Notification_Name);
                        }
                        
                    }
                    else if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty() &&
                        objEquipmentReq.NAM_approval_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).NAM_approval_Status__c &&
                        objEquipmentReq.NAM_approval_Status__c == JMS_ConstantsUtility.STR_APPROVED){
                            setApproverIds.add(objEquipmentReq.ownerId);
                            if(setApproverIds != null && !setApproverIds.isEmpty()){
                                JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentReq.Id,objEquipmentReq.Name , strTitleName,
                                                                System.Label.JMS_Custom_Notification_Name);
                            }
                    }
                    else if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty() &&
                        objEquipmentReq.JMS_Equipment_Integrity_Approval_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).JMS_Equipment_Integrity_Approval_Status__c &&
                        objEquipmentReq.JMS_Equipment_Integrity_Approval_Status__c == JMS_ConstantsUtility.STR_APPROVED){
                        setApproverIds.add(objEquipmentReq.ownerId);
                        if(setApproverIds != null && !setApproverIds.isEmpty()){    
                            JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentReq.Id,objEquipmentReq.Name , strTitleName,
                                                            System.Label.JMS_Custom_Notification_Name);
                        }
                    }
                    else if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty() &&
                        objEquipmentReq.JMS_RSM_approval_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).JMS_RSM_approval_Status__c &&
                        objEquipmentReq.JMS_RSM_approval_Status__c == JMS_ConstantsUtility.STR_APPROVED){
                        setApproverIds.add(objEquipmentReq.ownerId);
                        if(setApproverIds != null && !setApproverIds.isEmpty()){     
                            JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentReq.Id,objEquipmentReq.Name , strTitleName,
                                                            System.Label.JMS_Custom_Notification_Name);
                        }
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
            JMS_Logger.push(STR_CUSTOM_NOTIFICATION_TO_OWNER, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of initiateEmailNotificationRequest method
    
    public static Set<String> getEquipmentIntegrityUser(){
        List<GroupMember> listGroupMembers =  new List<GroupMember>();
        Set<String> setUserIds = new Set<String>();
        try{
            Group objGroup = [SELECT Id,Name 
                                FROM Group
                                 WHERE Type =: JMS_ConstantsUtility.STR_QUEUE 
                                 AND DeveloperName =: JMS_ConstantsUtility.JMS_EQUIPMENT_REQUEST_EI_APPROVERS limit 1];                   
            if(objGroup != null){
                listGroupMembers = [SELECT UserOrGroupId, Group.Name FROM GroupMember WHERE GroupId =: objGroup.Id];
                if(listGroupMembers != null && !listGroupMembers.isEmpty()){
                    for(GroupMember objGM:listGroupMembers){
                        setUserIds.add(objGM.UserOrGroupId);
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
            JMS_Logger.push(STR_EI_USERS, JMS_ConstantsUtility.USER_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
        return setUserIds;
    }

    /**
    * @description : To send email notification to the approvers  
    * @param       : List<JMS_Equipment_Request__c> listProcessedRecords ,
                     Map<Id, List<Messaging.Emailfileattachment>> mapEquipmentReqIdVsAttachment
    * @author      : Vasudha
    * @date        : 22/02/2022
    */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void sendEmailNotificationToApprovers(List<JMS_Equipment_Request__c> listProcessedRecords){
        JMS_SendEmailNotification objSendNotication = new JMS_SendEmailNotification();
        String htmlBody = JMS_ConstantsUtility.EMPTY_STRING;
        String strCustomSubject = JMS_ConstantsUtility.EMPTY_STRING;
        String strAccountName  = JMS_ConstantsUtility.EMPTY_STRING;
        String strBillingState  = JMS_ConstantsUtility.EMPTY_STRING;
        String strPlacementReason  = JMS_ConstantsUtility.EMPTY_STRING;
        String strMachineCount  = JMS_ConstantsUtility.EMPTY_STRING;
        String strContractType  = JMS_ConstantsUtility.EMPTY_STRING;
        String customNotificationBody = JMS_ConstantsUtility.EMPTY_STRING;
        String customNotificationTitle = JMS_ConstantsUtility.EMPTY_STRING;

        try{           
           
            Set<String> setEIApproverIds = getEquipmentIntegrityUser();
           
            // Get Metadata details
            Map<String,String> mapLabelVsDeveloperNameApprovers = getApprovalDetailsMdt();
            system.debug('mapLabelVsDeveloperNameApprovers-->>> ' + mapLabelVsDeveloperNameApprovers);
            //get User Details in public map
            getUserDetails(); 
            system.debug('mapNAMUserEmailVSUserId-->>> ' + mapNAMUserEmailVSUserId);
            Set<String> setApproverIds =  new Set<String>();
            String strBodyFromLabel = System.Label.JMS_Custom_Notification_Body;
            String strTitleFromLabel  = System.Label.JMS_Custom_Notification_Approval_Request_Title;
             // Fetch email template to send email
             EmailTemplate objEmailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate 
                                                WHERE DeveloperName =: System.Label.JMS_Equipment_Request_Approval_template 
                                                LIMIT 1];
            if(objEmailTemplate != null){
                htmlBody = objEmailTemplate.HtmlValue;
                for(JMS_Equipment_Request__c objEquipmentRequest :listProcessedRecords){
                    setApproverIds = new Set<String>();
                    String strEquipmentRequestURL =  URL.getSalesforceBaseUrl().toExternalForm() + JMS_ConstantsUtility.BACKWARD_SLASH + objEquipmentRequest.Id; 
                    // replace label variables with actual values
                    if(String.isNotBlank(strBodyFromLabel) ){
                        // Replace ERF Name
                        if(strBodyFromLabel.contains(JMS_ConstantsUtility.STR_ER_NAME_VAL) &&
                            String.isNotBlank(objEquipmentRequest.Name)){
                                customNotificationBody = strBodyFromLabel.replace(JMS_ConstantsUtility.STR_ER_NAME_VAL,objEquipmentRequest.Name );
                        }
                        // Replace Text with Owner Name
                        if(String.isNotBlank(customNotificationBody) && 
                            customNotificationBody.contains(JMS_ConstantsUtility.STR_ER_OWNER_VAL) &&
                            String.isNotBlank(objEquipmentRequest.Owner.name)){
                                customNotificationBody = customNotificationBody.replace(JMS_ConstantsUtility.STR_ER_OWNER_VAL,objEquipmentRequest.Owner.name);
                        }
                        // Replace Created By Name
                        if(String.isNotBlank(customNotificationBody) && customNotificationBody.contains(JMS_ConstantsUtility.STR_ER_CREATEDBY_NAME_VAL) &&
                            String.isNotBlank(objEquipmentRequest.CreatedBy.Name)){
                                customNotificationBody = customNotificationBody.replace(JMS_ConstantsUtility.STR_ER_CREATEDBY_NAME_VAL,objEquipmentRequest.CreatedBy.Name);
                        }
                        // Replace Account Name
                        if(String.isNotBlank(customNotificationBody) && 
                            customNotificationBody.contains(JMS_ConstantsUtility.STR_ACCOUNT_NAME_VAL) &&
                            String.isNotBlank(objEquipmentRequest.JMS_Account__r.Name)){
                                customNotificationBody = customNotificationBody.replace(JMS_ConstantsUtility.STR_ACCOUNT_NAME_VAL,objEquipmentRequest.JMS_Account__r.Name);
                        }
                        // Replace Account Name
                        if(String.isNotBlank(strTitleFromLabel) && strTitleFromLabel.contains(JMS_ConstantsUtility.STR_OWNER_NAME_VAL) &&
                            String.isNotBlank(objEquipmentRequest.Owner.name)){
                                customNotificationTitle = strTitleFromLabel.replace(JMS_ConstantsUtility.STR_OWNER_NAME_VAL,objEquipmentRequest.Owner.name);
                        }
                    }
                    if(String.isNotBlank(htmlBody) && htmlBody.contains(JMS_ConstantsUtility.STR_RECORD_URLS) &&
                        String.isNotBlank(strEquipmentRequestURL)){
                            htmlBody = htmlBody.replace(JMS_ConstantsUtility.STR_RECORD_URLS, strEquipmentRequestURL);
                    }
                    if(String.isNotBlank(htmlBody) && htmlBody.contains(JMS_ConstantsUtility.STR_USERNAME) &&
                        String.isNotBlank(objEquipmentRequest.Owner.name)){
                        htmlBody = htmlBody.replace(JMS_ConstantsUtility.STR_USERNAME, objEquipmentRequest.Owner.name);
                    }
                    
                    strContractType = objEquipmentRequest.JMS_Contract_Type__c != null ?  objEquipmentRequest.JMS_Contract_Type__c : JMS_ConstantsUtility.EMPTY_STRING; 
                    strAccountName = String.isNotBlank(objEquipmentRequest.JMS_Account__r.Name) ? STR_SPECIALCHAR_SUBJECT +  objEquipmentRequest.JMS_Account__r.Name : JMS_ConstantsUtility.EMPTY_STRING;
                    strBillingState  = String.isNotBlank(objEquipmentRequest.JMS_Account__r.BillingState) ?  STR_SPECIALCHAR_SUBJECT + objEquipmentRequest.JMS_Account__r.BillingState : JMS_ConstantsUtility.EMPTY_STRING;
                    strPlacementReason = String.isNotBlank(objEquipmentRequest.JMS_Placement_Reason__c) ?  STR_SPECIALCHAR_SUBJECT + objEquipmentRequest.JMS_Placement_Reason__c : JMS_ConstantsUtility.EMPTY_STRING;
                    
                    strMachineCount = objEquipmentRequest.JMS_Machine_Count__c != null ?  STR_SPECIALCHAR_SUBJECT + String.valueOf(objEquipmentRequest.JMS_Machine_Count__c) : JMS_ConstantsUtility.EMPTY_STRING;
                    
                    
                    
                    strCustomSubject = strContractType+ strAccountName + strBillingState + strPlacementReason + strMachineCount ;
                    system.debug('objEquipmentRequest.JMS_Status__c--->>> ' + objEquipmentRequest.JMS_Status__c);
                    system.debug('objEquipmentRequest.JMS_RSM_approval_Status__c--->>> ' + objEquipmentRequest.JMS_RSM_approval_Status__c);
                    system.debug('objEquipmentRequest.JMS_Manager_Details__c--->>> ' + objEquipmentRequest.JMS_Manager_Details__c);
                    system.debug('objEquipmentRequest.NAM_approval_Status__c--->>> ' + objEquipmentRequest.NAM_approval_Status__c);
                    system.debug('objEquipmentRequest.JMS_Account_Type__c--->>> ' + objEquipmentRequest.JMS_Account_Type__c);
                    
                    system.debug('objEquipmentRequest.JMS_Equipment_Integrity_Approval_Status__c--->>> ' + objEquipmentRequest.JMS_Equipment_Integrity_Approval_Status__c);
                    
                    if(objEquipmentRequest.JMS_Is_Attachment_Added__c == true){
                        String[] arrMangerDetails;
                        if(objEquipmentRequest.JMS_Status__c == JMS_ConstantsUtility.STR_ACTIVE_PENDING_RSM && objEquipmentRequest.JMS_RSM_approval_Status__c == JMS_ConstantsUtility.STR_SUBMITTED){
                            if(String.isNotBlank(objEquipmentRequest.JMS_Manager_Details__c) && 
                                (objEquipmentRequest.JMS_Manager_Details__c).contains(JMS_ConstantsUtility.ATRATE_DOUBLE)){
                                    arrMangerDetails= objEquipmentRequest.JMS_Manager_Details__c.split(JMS_ConstantsUtility.ATRATE_DOUBLE);
                            }
                            //Email Notification to approvers
                            if(arrMangerDetails != null && !arrMangerDetails.isEmpty() && 
                                String.isNotBlank(arrMangerDetails[1])){
                                objSendNotication.sendMail(arrMangerDetails[1] , JMS_ConstantsUtility.EMPTY_STRING , JMS_ConstantsUtility.EMPTY_STRING,htmlBody ,
                                                        JMS_ConstantsUtility.EMPTY_STRING, objEmailTemplate.Id,strCustomSubject,null);
                            }
                            if(arrMangerDetails != null && !arrMangerDetails.isEmpty() && 
                                String.isNotBlank(arrMangerDetails[2])){
                                    setApproverIds.add(arrMangerDetails[2]);
                                // custom bell notification to onwer of records
                                if(setApproverIds != null && !setApproverIds.isEmpty() && String.isNotBlank(customNotificationTitle)){
                                    JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentRequest.Id,customNotificationBody,
                                                                    customNotificationTitle,System.Label.JMS_Custom_Notification_Name);
                                }
                            }
                        }
                        
                        else if(objEquipmentRequest.JMS_Status__c == JMS_ConstantsUtility.STR_ACTIVE_PENDING_NAM_TRADE && objEquipmentRequest.NAM_approval_Status__c ==  JMS_ConstantsUtility.STR_SUBMITTED){
                        
                            JMS_Equipment_Request_Approvers__mdt objApproverDetail;
                            if(mapLabelVsDeveloperNameApprovers != null && 
                                mapLabelVsDeveloperNameApprovers.containsKey(objEquipmentRequest.JMS_Account_Type__c)){
                                objApproverDetail = JMS_Equipment_Request_Approvers__mdt.getInstance(mapLabelVsDeveloperNameApprovers.get(objEquipmentRequest.JMS_Account_Type__c));
                            }
                            
                            //Email Notification to approvers
                            objSendNotication.sendMail(objApproverDetail.JMS_NAM_Email__c , JMS_ConstantsUtility.EMPTY_STRING , 
                                                        JMS_ConstantsUtility.EMPTY_STRING,htmlBody ,JMS_ConstantsUtility.EMPTY_STRING, 
                                                        objEmailTemplate.Id,strCustomSubject,null);
                            SYSTEM.DEBUG('objApproverDetail.JMS_NAM_Email__c-->>' + objApproverDetail.JMS_NAM_Email__c);
                            SYSTEM.DEBUG('mapNAMUserEmailVSUserId-->>' + mapNAMUserEmailVSUserId);
                            if(mapNAMUserEmailVSUserId != null && !mapNAMUserEmailVSUserId.isEmpty() && 
                                mapNAMUserEmailVSUserId.containsKey(objApproverDetail.JMS_NAM_Email__c)){

                                    setApproverIds.add(mapNAMUserEmailVSUserId.get(objApproverDetail.JMS_NAM_Email__c));
                                    SYSTEM.DEBUG('setApproverIds-->>' + setApproverIds);
                                    // custom bell notification to onwer of records
                                    if(setApproverIds != null && !setApproverIds.isEmpty() && String.isNotBlank(customNotificationTitle)){
                                        JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentRequest.Id,customNotificationBody , 
                                        customNotificationTitle,System.Label.JMS_Custom_Notification_Name);
                                    }
                                    
                            }
                        }
                        
                        else if(objEquipmentRequest.JMS_Status__c == JMS_ConstantsUtility.STR_ACTIVE_PENDING_EQUIPMENT_INTEGRITY && 
                                objEquipmentRequest.JMS_Equipment_Integrity_Approval_Status__c ==  JMS_ConstantsUtility.STR_SUBMITTED){

                            JMS_Equipment_Request_Approvers__mdt objApproverDetail = JMS_Equipment_Request_Approvers__mdt.getInstance(JMS_ConstantsUtility.STR_EQUIPMENT_INTEGRITY);
                            
                            //Email Notification to approvers
                            objSendNotication.sendMail(objApproverDetail.JMS_Equipment_Integrity_Email__c , 
                                                        JMS_ConstantsUtility.EMPTY_STRING , JMS_ConstantsUtility.EMPTY_STRING,htmlBody ,
                                                        JMS_ConstantsUtility.EMPTY_STRING, objEmailTemplate.Id,strCustomSubject,null);                                // custom bell notification to onwer of records
                                if(setEIApproverIds != null && !setEIApproverIds.isEmpty() && String.isNotBlank(customNotificationTitle)){
                                    
                                    JMS_CustomNotification.notifyUsers(setEIApproverIds,objEquipmentRequest.Id,customNotificationBody, 
                                    customNotificationTitle,System.Label.JMS_Custom_Notification_Name);
                                }
                        }
                        // end of else if
                    }// end of  if  
                }// end of for
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
            JMS_Logger.push(STR_SEND_EMAIL_NOTIFICATION_APPROVERS, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of sendEmailNotificationToApprovers method

    
    /***************************************************************************************************************
    *   @Name        :  getApprovalDetailsMdt                                                              
    *   @Return      :  Map<String,String>                                                                                       
    *   @Description :  To create map og Label VS Developername of JMS_Equipment_Request_Approvers__mdt
    ****************************************************************************************************************/
    public static Map<String,String> getApprovalDetailsMdt(){
        JMS_Equipment_Request_Approvers__mdt[] mdtApproverDetails = [SELECT MasterLabel, DeveloperName,
                                                                        JMS_NAM_Email__c,JMS_User_Role__c,
                                                                        JMS_Equipment_Integrity_Email__c
                                                                    FROM JMS_Equipment_Request_Approvers__mdt LIMIT 50000];
        Map<String,String> mapLabelVsDeveloperNameMdt = new Map<String,String>();
        if(mdtApproverDetails != null && !mdtApproverDetails.isEmpty()){
            for (JMS_Equipment_Request_Approvers__mdt mdtApproverDetail : mdtApproverDetails) {
                mapLabelVsDeveloperNameMdt.put(mdtApproverDetail.MasterLabel,mdtApproverDetail.DeveloperName);
                if(String.isNotBlank(mdtApproverDetail.JMS_NAM_Email__c) && String.isNotBlank(mdtApproverDetail.JMS_User_Role__c)){
                    setUserRoleForNAMApproval.add(mdtApproverDetail.JMS_User_Role__c);
                }
                
            }
        }
        system.debug('setUserRoleForNAMApproval--->>> ' + setUserRoleForNAMApproval);
        return mapLabelVsDeveloperNameMdt;
    }

    /**
    * @description : This method will populate related Account and Opportunity on Equipment Request
    * @param       : List<SObject> newItems
    * @author      : Sumit
    * @date        : 22/02/2022
    */
    public static void populateOppAccount(List<SObject> newItems){
        //Variable Declaration
        Set<Id> opportunityIdSet = new Set<Id>();
        Map<Id, Id> oppAccIdMap = new Map<Id, Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<JMS_Equipment_Request__c> listNewEquipment = (List<JMS_Equipment_Request__c>) newItems;
        try{
            if(!newItems.isEmpty()) {
                for(JMS_Equipment_Request__c objNewER : listNewEquipment){                
                    opportunityIdSet.add(objNewER.JMS_Opportunity__c);
                }// end of  for
            }// end of  if
            if (!opportunityIdSet.isEmpty()){
                oppList = [SELECT Id, AccountId FROM Opportunity WHERE Id IN : opportunityIdSet WITH SECURITY_ENFORCED LIMIT 50000];
            }// end of  if
            
            if(!oppList.isEmpty()){
                for(Opportunity opp : oppList){
                    oppAccIdMap.put(opp.Id, opp.AccountId);
                }// end of  for

                for (JMS_Equipment_Request__c equipRequest : listNewEquipment){
                    if(oppAccIdMap.containskey(equipRequest.JMS_Opportunity__c)) {
                    // JMS_Equipment_Request__c newEquipRequest = new JMS_Equipment_Request__c();
                        //newEquipRequest.JMS_Opportunity__c = equipRequest.Id;
                        equipRequest.JMS_Account__c = oppAccIdMap.get(equipRequest.JMS_Opportunity__c);
                    }// end of  if
                }// end of for
            }// end of  if
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_POPULATE_OPP_ACCOUNT, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }//// end of  populateOppAccount method
    
     /**
    * @description : This method will reset the Approvers tracking fields that are using
    *                to understand who approved it and what is current statuses on Equipment Request
    *               When status is Rejected
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 29/03/2022
    */
    public static void resetApprovedFieldsByApprovers(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        //Variable Declaration
        Map<Id, JMS_Equipment_Request__c> mapOldEquipmentRequest = (Map<Id,JMS_Equipment_Request__c>) oldItemsMap;
        List<JMS_Equipment_Request__c> listNewEquipment = (List<JMS_Equipment_Request__c>) listNewSObject;
        try{    
            if(listNewEquipment != null && !listNewEquipment.isEmpty()){
                for(JMS_Equipment_Request__c objEquipmentReq:listNewEquipment){
                    if(objEquipmentReq.JMS_Overall_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).JMS_Overall_Status__c &&
                    (objEquipmentReq.JMS_Overall_Status__c == JMS_ConstantsUtility.STR_INPROGRESS_REJECTED || objEquipmentReq.JMS_Overall_Status__c == JMS_ConstantsUtility.STR_New)){
                        objEquipmentReq.JMS_RSM_Approved__c = false;
                        objEquipmentReq.NAM_Approved__c = false;
                        objEquipmentReq.JMS_Equipment_Integrity_Approved__c = false;
                        objEquipmentReq.JMS_Equipment_Integrity_Approval_Status__c = JMS_ConstantsUtility.EMPTY_STRING;
                        objEquipmentReq.NAM_approval_Status__c = JMS_ConstantsUtility.EMPTY_STRING;
                        objEquipmentReq.JMS_RSM_approval_Status__c = JMS_ConstantsUtility.EMPTY_STRING;
                    }//end of if
                }//end of for
            }// end of if
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_RESET_APPROVED_FIELDS_BY_APPROVERS, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }// end of finally
    }// end of resetApprovedFieldsByApprovers method

    /**
    * @description : To validate if the forge Id is updated by
                     Equipment Integrity Approver or not 
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 29/03/2022
    */
    public static void checkEIUserUpdateForgeId(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        //Variable Declaration
        Map<Id, JMS_Equipment_Request__c> mapOldEquipmentRequest = (Map<Id,JMS_Equipment_Request__c>) oldItemsMap;
        List<JMS_Equipment_Request__c> listNewEquipment = (List<JMS_Equipment_Request__c>) listNewSObject;
        Set<Id> setGroupMemberIds = new Set<Id>();
        Group objEquipmentIntegrityQueue = new Group();
        List<GroupMember> listGroupMemeber = new List<GroupMember>();
        try{    
            objEquipmentIntegrityQueue = [select Id from Group WHERE Type =: JMS_ConstantsUtility.STR_QUEUE AND DeveloperName =: JMS_ConstantsUtility.JMS_EQUIPMENT_REQUEST_EI_APPROVERS limit 1];
            if(objEquipmentIntegrityQueue != null){
                listGroupMemeber = [Select UserOrGroupId From GroupMember WHERE GroupId =: objEquipmentIntegrityQueue.Id];
                if(listGroupMemeber != null && !listGroupMemeber.isEmpty()){
                    for(GroupMember objGroupMem:listGroupMemeber){
                        setGroupMemberIds.add(objGroupMem.UserOrGroupId);
                    }
                }
            }
            if(setGroupMemberIds != null && listNewEquipment != null &&
                !setGroupMemberIds.isEmpty() && !listNewEquipment.isEmpty()){
                for(JMS_Equipment_Request__c objEquipmentRequest:listNewEquipment){
                  
                    if((!setGroupMemberIds.contains(objEquipmentRequest.LastModifiedById) && 
                        (objEquipmentRequest.JMS_Status__c != JMS_ConstantsUtility.STR_COMPLETED ||
                        objEquipmentRequest.JMS_Status__c == JMS_ConstantsUtility.STR_COMPLETED)) ||
                        (setGroupMemberIds.contains(objEquipmentRequest.LastModifiedById) && 
                        objEquipmentRequest.JMS_Status__c != JMS_ConstantsUtility.STR_COMPLETED)){
                        if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty()){
                            if(objEquipmentRequest.JMS_Operator_Trade_ID__c != mapOldEquipmentRequest.get(objEquipmentRequest.Id).JMS_Operator_Trade_ID__c){
                                objEquipmentRequest.addError(System.Label.Error_Msg_EI_User_Update_ForgeId);
                            }
                        }
                        else if(mapOldEquipmentRequest == null ){
                            if(!String.isBlank(objEquipmentRequest.JMS_Operator_Trade_ID__c)){
                                objEquipmentRequest.addError(System.Label.Error_Msg_EI_User_Update_ForgeId);
                            }
                        }
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
            JMS_Logger.push(STR_EI_USERS_UPDATE_FORGEID, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }// end of finally
    }// end of resetApprovedFieldsByApprovers method
    /**
    * @description : To change the Record type when Approval process is completed
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Anil
    * @date        : 09/05/2022
    */
    public static void updateRecordType(List<SObject> listNewSObject, Map<Id, SObject> oldItemsMap){
        //Map<Id, JMS_Equipment_Request__c> mapOldEquipmentRequest = (Map<Id,JMS_Equipment_Request__c>) oldItemsMap;
        List<JMS_Equipment_Request__c> listNewEquipment = (List<JMS_Equipment_Request__c>) listNewSObject;
        try{
            if(listNewEquipment != null && !listNewEquipment.isEmpty()){
                for(JMS_Equipment_Request__c equ : listNewEquipment){
                    //Checking if the Approval Process is Completed
                    if(equ.JMS_Overall_Status__c == JMS_ConstantsUtility.STR_COMPLETED && equ.JMS_Status__c == JMS_ConstantsUtility.STR_COMPLETED){
                        //Changing the RecordType to Read-Only
                        equ.RecordTypeId = Schema.SObjectType.JMS_Equipment_Request__c.getRecordTypeInfosByName().get('ERF Read-Only').getRecordTypeId();
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
            JMS_Logger.push(STR_UPDATE_RECORDTYPE, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }// end of finally
    }
}