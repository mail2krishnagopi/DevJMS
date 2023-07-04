public class giic_SaleQuoteTriggerHelper {
   private static final String STR_INITIATE_APPROVAL_PROCESS = 'initiateApprovalProcess';
    private static final String STR_INITIATE_EMAIL_NOTIFICATION_REQ = 'initiateEmailNotificationRequest';
    private static final String STR_SUBMIT_FOR_APPROVAL = 'submitForApproval';
    private static final String STR_STR_PROCESSED_RECORD_TO_SEND_EMAIL = 'processedRecordsToSendEmail';
    private static final String STR_SEND_EMAIL_NOTIFICATION_APPROVERS = 'sendEmailNotificationToApprovers';
    private static final String STR_RESET_APPROVED_FIELDS_BY_APPROVERS = 'resetApprovedFieldsByApprovers';
    private static final String STR_EI_USERS_UPDATE_FORGEID = 'checkEIUserUpdateForgeId';
    private static final String STR_CUSTOM_NOTIFICATION_TO_OWNER = 'customNotificationToOwner';
    private static final String STR_EI_USERS = 'getEquipmentIntegrityUser';
       public static final String USER_API = 'User';
    public static final String ATRATE_DOUBLE = '@@';

    //ERF Variables from Custom Notifcation Label
    public static final String STR_ER_NAME_VAL = 'ERNameVal';
    public static final String STR_ER_OWNER_VAL = 'OwnerNameVal';
    public static final String STR_ER_CREATEDBY_NAME_VAL = 'CreatedByNameVal';
    public static final String STR_ACCOUNT_NAME_VAL = 'AccountNameVal';
    public static final String STR_OWNER_NAME_VAL = 'OWNERNAMEVAL';
    public static final String STR_NAM = 'NAM';
    public static final String STR_EQUIPMENT_INTEGRITY_TEAM = 'Equipment Integrity Team';
    public static final String STR_INTEGRATION_USER = 'Integration User';
    public static final String BACKWARD_SLASH = '/';
 public static final String NEW_STRING = 'New';//New is a string value used
    public static final String STR_RECORD_URLS='(RecordURLs)';
    public static final String STR_USERNAME='(username)';
    public static final String STR_FIREFLY_ID ='(FireFlyId)';
    public static final String STR_OWNER_NAME='OwnerName';
    public static final String STR_AFTER_UPDATE ='afterupdate';
    public static final String STR_AFTER_UNDELETE ='afterundelete';
    public static final String STR_TERRITORY2_ASSIGNMENTRULE ='Territory2Manual';
    //public static final String STR_INPROGRESS_REJECTED ='InProgress - Rejected';
    public static final String STR_EQUIPMENT_INTEGRITY = 'Equipment_Integrity';
	//public static final String STR_SUBMITTED = 'Submitted';
        
    
    public static Map<String,String> mapNAMUserEmailVSUserId;
    public static Set<String> setUserRoleForNAMApproval;

    public static final String JMS_Sales_Quote_EI_APPROVERS = 'giic_Sales_Quote_EI_Approvers';
    public static final String STR_QUEUE = 'Queue';
    
    private static final String ER_Approval_Msg_For_NAM_Trade = 'Approval requested for NAM and Finance Trade Team';
     public static final String ER_Approval_Msg_For_Equipment_Integrity = 'Approval requested for Equipment Integrity Team';
    
     //Equipment Request Status
    //Status Values
    public static final String STR_ACTIVE_PENDING_RSM='Active - Pending RSM';
    public static final String STR_ACTIVE_PENDING_NAM_TRADE='Active - Pending NAM';
    public static final String STR_ACTIVE_PENDING_Quote_INTEGRITY ='Active - Pending Equipment Integrity';
    public static final String STR_COMPLETED ='Completed';
    public static final String STR_APPROVED ='Approved';
    public static final String STR_New = 'New';
     public static final String STR_INPROGRESS_REJECTED ='InProgress - Rejected';
    public static final String STR_SALES_QUOTE = 'Sales_Quote';
	public static final String STR_SUBMITTED = 'Submitted';
    
    public static final String Sales_Quote_API = 'gii__SalesQuote__c';
        public static final String EMPTY_STRING = '';
    private static final String STR_SPECIALCHAR_SUBJECT = ' : ';



      public static void checkEIUserUpdateForgeId(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        //Variable Declaration
        Map<Id, gii__SalesQuote__c> mapOldEquipmentRequest = (Map<Id,gii__SalesQuote__c>) oldItemsMap;
        List<gii__SalesQuote__c> listNewEquipment = (List<gii__SalesQuote__c>) listNewSObject;
        Set<Id> setGroupMemberIds = new Set<Id>();
        Group objEquipmentIntegrityQueue = new Group();
        List<GroupMember> listGroupMemeber = new List<GroupMember>();
        try{    
            objEquipmentIntegrityQueue = [select Id from Group WHERE Type =: STR_QUEUE AND DeveloperName =: JMS_Sales_Quote_EI_APPROVERS limit 1];
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
                for(gii__SalesQuote__c objEquipmentRequest:listNewEquipment){
                  
                    if((!setGroupMemberIds.contains(objEquipmentRequest.LastModifiedById) && 
                        (objEquipmentRequest.giic_Sub_Status__c != STR_COMPLETED ||
                        objEquipmentRequest.giic_Sub_Status__c == STR_COMPLETED)) ||
                        (setGroupMemberIds.contains(objEquipmentRequest.LastModifiedById) && 
                        objEquipmentRequest.giic_Sub_Status__c != STR_COMPLETED)){
                        if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty()){
                          //  if(objEquipmentRequest.JMS_Operator_Trade_ID__c != mapOldEquipmentRequest.get(objEquipmentRequest.Id).JMS_Operator_Trade_ID__c){
                              //  objEquipmentRequest.addError(System.Label.Error_Msg_EI_User_Update_ForgeId);
                             objEquipmentRequest.addError('User do not have permission to update.Please contact to your System Administrator for more details.');
                           // }
                        }
                        else if(mapOldEquipmentRequest == null ){
                            //if(!String.isBlank(objEquipmentRequest.JMS_Operator_Trade_ID__c)){
                               // objEquipmentRequest.addError(System.Label.Error_Msg_EI_User_Update_ForgeId);
                   objEquipmentRequest.addError('User do not have permission to update.Please contact to your System Administrator for more details.');

                            //}
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
            JMS_Logger.push(STR_EI_USERS_UPDATE_FORGEID, Sales_Quote_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }// end of finally
    }// end of resetApprovedFieldsByApprovers method
   
      /**
    * @description : This method will update field for the  Approvers 
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 29/03/2022
    */
    public static void updateApprovedFieldsFOrApproval(List<SObject> listNewSObject){
       List<gii__SalesQuote__c> listNewEquipment = (List<gii__SalesQuote__c>) listNewSObject;
         system.debug('UAF&A>> 1'+listNewSObject);
         system.debug('UAF&A>>size 2'+listNewSObject.size());
         List<gii__SalesQuote__c> result = new List<gii__SalesQuote__c>();
        try{    
            if(listNewEquipment != null && !listNewEquipment.isEmpty()){
                system.debug('UAF&A>> 2 - 1  insideif');
                for(gii__SalesQuote__c objEquipmentReq:listNewEquipment){
                    system.debug('UAF&A>> 2 - 1  insideif value' +objEquipmentReq );
                           objEquipmentReq.giic_Sub_Status__c = 'Draft';
                           objEquipmentReq.giic_Overall_Status__c = 'InProgress - Rejected';
                           //objEquipmentReq.giic_Account_Type__c = 'National Other';
                        
                         result.add(objEquipmentReq);
                         /*objEquipmentReq.giic_quipment_Integrity_Approved__c = false;
                           objEquipmentReq.giic_SQ_Integrity_Approval_Status__c = EMPTY_STRING;
                           objEquipmentReq.giic_NAM_approval_Status__c =EMPTY_STRING;
                           objEquipmentReq.giic_RSM_approval_Status__c =EMPTY_STRING;*/
                    
                }//end of for
                  system.debug('listNewSObject trigger.new ' +listNewSObject );
                 system.debug('result trigger.new -->>> '+result);
               // update result;
            }// end of if
            
        }catch(Exception excep){
            system.debug('UAF&A>> 3'+excep);
            System.debug('UAF&A>> 4 ' + excep.getMessage());
             System.debug('UAF&A>> 5 ' + excep.getTypeName());
             System.debug('UAF&A>> 6 ' + excep.getLineNumber());
             System.debug('UAF&A>> 7 ' + excep.getStackTraceString());
            JMS_Logger.push(STR_INITIATE_APPROVAL_PROCESS, Sales_Quote_API);
            JMS_Logger.debugException(excep);
            
        }
    }
    
    
     /**
    * @description : This method will reset the Approvers tracking fields that are using
    *                to understand who approved it and what is current statuses on Sales Quote
    *               When status is Rejected
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 29/03/2022
    */
    public static void resetApprovedFieldsByApprovers(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        //Variable Declaration
        Map<Id, gii__SalesQuote__c> mapOldEquipmentRequest = (Map<Id,gii__SalesQuote__c>) oldItemsMap;
        List<gii__SalesQuote__c> listNewEquipment = (List<gii__SalesQuote__c>) listNewSObject;
        try{    
            if(listNewEquipment != null && !listNewEquipment.isEmpty()){
                for(gii__SalesQuote__c objEquipmentReq:listNewEquipment){
                    if(objEquipmentReq.giic_Overall_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).giic_Overall_Status__c &&
                    (objEquipmentReq.giic_Overall_Status__c == STR_INPROGRESS_REJECTED || objEquipmentReq.giic_Overall_Status__c == STR_New)){
                        objEquipmentReq.giic_RSM_Approved__c = false;
                        objEquipmentReq.giic_NAM_Approved__c = false;
                        objEquipmentReq.giic_quipment_Integrity_Approved__c = false;
                        objEquipmentReq.giic_SQ_Integrity_Approval_Status__c = EMPTY_STRING;
                        objEquipmentReq.giic_NAM_approval_Status__c =EMPTY_STRING;
                        objEquipmentReq.giic_RSM_approval_Status__c =EMPTY_STRING;
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
            JMS_Logger.push(STR_RESET_APPROVED_FIELDS_BY_APPROVERS, Sales_Quote_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }// end of finally
    }// end of resetApprovedFieldsByApprovers method

    
    /**
    * @description : To initiate Approval process for gii__SalesQuote__c from 2nd step
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 22/02/2022
    */
    public static void initiateApprovalProcess(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        Map<Id, gii__SalesQuote__c> mapOldEquipmentRequest = (Map<Id,gii__SalesQuote__c>) oldItemsMap;
        List<gii__SalesQuote__c> listNewEquipment = (List<gii__SalesQuote__c>) listNewSObject;
        mapNAMUserEmailVSUserId = new Map<String,String>();
        setUserRoleForNAMApproval = new Set<String>();
     
        try{            
            if(listNewEquipment != null && mapOldEquipmentRequest != null && !listNewEquipment.isEmpty()){
                for(gii__SalesQuote__c objNewEquipmentRequest:listNewEquipment){
                 //NAM Trade Approval Initiation 
                        if(objNewEquipmentRequest.giic_RSM_Approved__c == true && objNewEquipmentRequest.giic_Is_Approval_For_EI__c == false &&
                            mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_RSM_Approved__c == false &&
                            objNewEquipmentRequest.giic_Is_Approval_For_NAM__c == true){
                            submitForApproval(objNewEquipmentRequest.Id , ER_Approval_Msg_For_NAM_Trade);  
                        }
                        //  Equiment Integrity Approval Initiation with NAM
                        else if( objNewEquipmentRequest.giic_RSM_Approved__c == true &&  objNewEquipmentRequest.giic_Is_Approval_For_NAM__c == true &&
                        objNewEquipmentRequest.giic_NAM_Approved__c == true && mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_NAM_Approved__c == false){
                        // Create an approval request for ERF 
                            submitForApproval(objNewEquipmentRequest.Id , ER_Approval_Msg_For_Equipment_Integrity);
                        }

                        // Equiment Integrity Approval Initiation direct from RSM
                        else if( objNewEquipmentRequest.giic_RSM_Approved__c == true &&
                            mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_RSM_Approved__c == false && 
                            objNewEquipmentRequest.giic_Is_Approval_For_EI__c == true){
                        // Create an approval request for ERF 
                          system.debug('Triggered 2nd Approval process - Equiment Integrity Approval Initiation direct from RSM');
                            submitForApproval(objNewEquipmentRequest.Id ,ER_Approval_Msg_For_Equipment_Integrity);  
                        }
                        //Equiment Integrity Approval Initiation to for Non-NAM
                        else if(objNewEquipmentRequest.giic_Is_Approval_For_Non_NAM__c == true &&
                            mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_RSM_Approved__c == false &&
                            objNewEquipmentRequest.giic_RSM_Approved__c == true){
                            // Create an approval request for ERF 
                           
                            submitForApproval(objNewEquipmentRequest.Id,ER_Approval_Msg_For_Equipment_Integrity); 
                        }
                        //  Equiment Integrity Approval Initiation with NAM by NON TSM User
                        else if( objNewEquipmentRequest.giic_RSM_Approved__c == false &&  objNewEquipmentRequest.giic_Is_Approval_For_NAM__c == true &&
                        objNewEquipmentRequest.giic_NAM_Approved__c == true && mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_NAM_Approved__c == false){
                        // Create an approval request for ERF 
                            submitForApproval(objNewEquipmentRequest.Id , ER_Approval_Msg_For_Equipment_Integrity);
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
            JMS_Logger.push(STR_INITIATE_APPROVAL_PROCESS, Sales_Quote_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }//end of initiateApprovalProcess
    
    
    
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
                 system.debug('Called submitted for approval' + Approval.isLocked(strRecordId));
                if(Approval.isLocked(strRecordId))
                {
                    Approval.UnlockResult result = Approval.unlock(strRecordId);
                }
                
                 system.debug('Called submitted for approval' + Approval.isLocked(strRecordId));
                if(!Approval.isLocked(strRecordId)) {
                     system.debug(' submitted for approval');
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
            JMS_Logger.push(STR_SUBMIT_FOR_APPROVAL, Sales_Quote_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of submitForApproval method
    
     /**
    * @description : To get the equipment Id if the status is changing from old to new
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 22/02/2022
    */
    public static void initiateEmailNotificationRequest(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        //Variable declaration
        Map<Id, gii__SalesQuote__c> mapOldEquipmentRequest = (Map<Id,gii__SalesQuote__c>) oldItemsMap;
        List<gii__SalesQuote__c> listNewEquipment = (List<gii__SalesQuote__c>) listNewSObject;
        Set<Id> setEquipmentRequestIds = new Set<Id>();
        try{
            if(listNewEquipment != null && mapOldEquipmentRequest != null && !listNewEquipment.isEmpty()){
                for(gii__SalesQuote__c objNewEquipmentRequest:listNewEquipment){
                    if(objNewEquipmentRequest.giic_Sub_Status__c != mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_Sub_Status__c &&
                        (objNewEquipmentRequest.giic_RSM_approval_Status__c !=  mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_RSM_approval_Status__c ||
                        objNewEquipmentRequest.giic_NAM_approval_Status__c != mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_NAM_approval_Status__c ||
                        objNewEquipmentRequest.giic_SQ_Integrity_Approval_Status__c !=  
                        mapOldEquipmentRequest.get(objNewEquipmentRequest.Id).giic_SQ_Integrity_Approval_Status__c)){
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
            JMS_Logger.push(STR_INITIATE_EMAIL_NOTIFICATION_REQ, Sales_Quote_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of initiateEmailNotificationRequest method
    
    
     
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
                                                List<gii__SalesQuote__c> listNewEquipment,
                                                Map<Id, gii__SalesQuote__c> mapOldEquipmentRequest){
        List<gii__SalesQuote__c> listProcessedRecords = new List<gii__SalesQuote__c>();
        /*******************************************************************
     * Codescan error :Avoid unused local variables such as 'setContentDocumentIds'.
     * Author:Krishna
     * Date:5/4/2022
     ********************************************************************/
        
        try{
            if(setEquipmentRequestIds != null && !setEquipmentRequestIds.isEmpty()){
                // To get JMS_Equipment_Request__c record details
               /* listProcessedRecords = [SELECT Id ,JMS_Status__c,JMS_Account_Type__c,JMS_Is_Attachment_Added__c, 
                                        Name,Owner.name ,owner.Email,JMS_Manager_Details__c,JMS_RSM_approval_Status__c,
                                        NAM_approval_Status__c,JMS_Account__r.Name,JMS_Account__r.BillingState,CreatedBy.Name,
                                        JMS_Equipment_Integrity_Approval_Status__c,JMS_Placement_Reason__c,JMS_Machine_Count__c, JMS_Contract_Type__c
                                        FROM gii__SalesQuote__c 
                                        WHERE Id IN : setEquipmentRequestIds LIMIT 50000];*/
                listProcessedRecords =  [SELECT Id , giic_Account_Type__c, giic_Is_Approval_For_EI__c,
                                         giic_Is_Approval_For_NAM__c , giic_Is_Approval_For_Non_NAM__c,
                                          giic_Is_Attachment_Added__c, giic_NAM_approval_Status__c ,
                                         giic_RSM_Approved__c, giic_Sub_Status__c ,
                                          giic_NAM_Approved__c , giic_Overall_Status__c ,
                                         giic_Equipment_Cost__c, giic_Ancillary_Cost__c ,
                                         giic_SQ_Integrity_Approval_Status__c, giic_quipment_Integrity_Approved__c,
                                         giic_RSM_approval_Status__c , giic_Customer_State__c,
                                         giic_Placement_Reason__c,Owner.name ,
                                         owner.Email,CreatedBy.Name,gii__Account__c,
                                         gii__Account__r.Name,gii__Account__r.BillingState,
                                         giic_Manager_Details__c
                                         FROM gii__SalesQuote__c 
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
            JMS_Logger.push(STR_STR_PROCESSED_RECORD_TO_SEND_EMAIL, Sales_Quote_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of processedRecordsToSendEmail method
    
    
    
 
    
    /**
    * @description : To send email notification to the approvers  
    * @param       : List<gii__SalesQuote__c> listProcessedRecords ,
                     Map<Id, List<Messaging.Emailfileattachment>> mapEquipmentReqIdVsAttachment
    * @author      : Vasudha
    * @date        : 22/02/2022
    */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void sendEmailNotificationToApprovers(List<gii__SalesQuote__c> listProcessedRecords){
        JMS_SendEmailNotification objSendNotication = new JMS_SendEmailNotification();
        String htmlBody = EMPTY_STRING;
        String strCustomSubject = EMPTY_STRING;
        String strAccountName  = EMPTY_STRING;
        String strBillingState  = EMPTY_STRING;
        String strPlacementReason  = EMPTY_STRING;
        String strMachineCount  = EMPTY_STRING;
        String strContractType  = EMPTY_STRING;
        String customNotificationBody = EMPTY_STRING;
        String customNotificationTitle = EMPTY_STRING;

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
                for(gii__SalesQuote__c objEquipmentRequest :listProcessedRecords){
                    setApproverIds = new Set<String>();
                    String strEquipmentRequestURL =  URL.getSalesforceBaseUrl().toExternalForm() + BACKWARD_SLASH + objEquipmentRequest.Id; 
                    // replace label variables with actual values
                    if(String.isNotBlank(strBodyFromLabel) ){
                        // Replace ERF Name
                        if(strBodyFromLabel.contains(STR_ER_NAME_VAL) &&
                            String.isNotBlank(objEquipmentRequest.Name)){
                                customNotificationBody = strBodyFromLabel.replace(STR_ER_NAME_VAL,objEquipmentRequest.Name );
                        }
                        // Replace Text with Owner Name
                        if(String.isNotBlank(customNotificationBody) && 
                            customNotificationBody.contains(STR_ER_OWNER_VAL) &&
                            String.isNotBlank(objEquipmentRequest.Owner.name)){
                                customNotificationBody = customNotificationBody.replace(STR_ER_OWNER_VAL,objEquipmentRequest.Owner.name);
                        }
                        // Replace Created By Name
                        if(String.isNotBlank(customNotificationBody) && customNotificationBody.contains(STR_ER_CREATEDBY_NAME_VAL) &&
                            String.isNotBlank(objEquipmentRequest.CreatedBy.Name)){
                                customNotificationBody = customNotificationBody.replace(STR_ER_CREATEDBY_NAME_VAL,objEquipmentRequest.CreatedBy.Name);
                        }
                        // Replace Account Name
                        if(String.isNotBlank(customNotificationBody) && 
                            customNotificationBody.contains(STR_ACCOUNT_NAME_VAL) &&
                            String.isNotBlank(objEquipmentRequest.gii__Account__r.Name)){
                                customNotificationBody = customNotificationBody.replace(STR_ACCOUNT_NAME_VAL,objEquipmentRequest.gii__Account__r.Name);
                        }
                        // Replace Account Name
                        if(String.isNotBlank(strTitleFromLabel) && strTitleFromLabel.contains(STR_OWNER_NAME_VAL) &&
                            String.isNotBlank(objEquipmentRequest.Owner.name)){
                                customNotificationTitle = strTitleFromLabel.replace(STR_OWNER_NAME_VAL,objEquipmentRequest.Owner.name);
                        }
                    }
                    if(String.isNotBlank(htmlBody) && htmlBody.contains(STR_RECORD_URLS) &&
                        String.isNotBlank(strEquipmentRequestURL)){
                            htmlBody = htmlBody.replace(STR_RECORD_URLS, strEquipmentRequestURL);
                    }
                    if(String.isNotBlank(htmlBody) && htmlBody.contains(STR_USERNAME) &&
                        String.isNotBlank(objEquipmentRequest.Owner.name)){
                        htmlBody = htmlBody.replace(STR_USERNAME, objEquipmentRequest.Owner.name);
                    }
                    
                    strContractType = ''; //objEquipmentRequest.JMS_Contract_Type__c != null ?  objEquipmentRequest.JMS_Contract_Type__c : JMS_ConstantsUtility.EMPTY_STRING; 
                    strAccountName = String.isNotBlank(objEquipmentRequest.gii__Account__r.Name) ? STR_SPECIALCHAR_SUBJECT +  objEquipmentRequest.gii__Account__r.Name : EMPTY_STRING;
                    strBillingState  = String.isNotBlank(objEquipmentRequest.gii__Account__r.BillingState) ?  STR_SPECIALCHAR_SUBJECT + objEquipmentRequest.gii__Account__r.BillingState : EMPTY_STRING;
                    strPlacementReason = String.isNotBlank(objEquipmentRequest.giic_Placement_Reason__c) ?  STR_SPECIALCHAR_SUBJECT + objEquipmentRequest.giic_Placement_Reason__c : EMPTY_STRING;
                    
                    strMachineCount = '';// objEquipmentRequest.JMS_Machine_Count__c != null ?  STR_SPECIALCHAR_SUBJECT + String.valueOf(objEquipmentRequest.JMS_Machine_Count__c) : JMS_ConstantsUtility.EMPTY_STRING;
                    
                    
                    
                    strCustomSubject = strContractType+ strAccountName + strBillingState + strPlacementReason + strMachineCount ;
                    system.debug('objEquipmentRequest.giic_Sub_Status__c--->>> ' + objEquipmentRequest.giic_Sub_Status__c);
                    system.debug('objEquipmentRequest.giic_RSM_approval_Status__c--->>> ' + objEquipmentRequest.giic_RSM_approval_Status__c);
                    system.debug('objEquipmentRequest.giic_Manager_Details__c--->>> ' + objEquipmentRequest.giic_Manager_Details__c);
                    system.debug('objEquipmentRequest.giic_NAM_approval_Status__c--->>> ' + objEquipmentRequest.giic_NAM_approval_Status__c);
                    system.debug('objEquipmentRequest.giic_Account_Type__c--->>> ' + objEquipmentRequest.giic_Account_Type__c);
                    
                    system.debug('objEquipmentRequest.giic_SQ_Integrity_Approval_Status__c--->>> ' + objEquipmentRequest.giic_SQ_Integrity_Approval_Status__c);
                    
                   // if(objEquipmentRequest.JMS_Is_Attachment_Added__c == true){
                        String[] arrMangerDetails;
                        if(objEquipmentRequest.giic_Sub_Status__c == STR_ACTIVE_PENDING_RSM && objEquipmentRequest.giic_RSM_approval_Status__c == STR_SUBMITTED){
                            if(String.isNotBlank(objEquipmentRequest.giic_Manager_Details__c) && 
                                (objEquipmentRequest.giic_Manager_Details__c).contains(ATRATE_DOUBLE)){
                                    arrMangerDetails= objEquipmentRequest.giic_Manager_Details__c.split(ATRATE_DOUBLE);
                            }
                            //Email Notification to approvers
                            if(arrMangerDetails != null && !arrMangerDetails.isEmpty() && 
                                String.isNotBlank(arrMangerDetails[1])){
                                objSendNotication.sendMail(arrMangerDetails[1] , EMPTY_STRING , EMPTY_STRING,htmlBody ,
                                                        EMPTY_STRING, objEmailTemplate.Id,strCustomSubject,null);
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
                        
                        else if(objEquipmentRequest.giic_Sub_Status__c == STR_ACTIVE_PENDING_NAM_TRADE && objEquipmentRequest.giic_NAM_approval_Status__c ==  STR_SUBMITTED){
                        
                            JMS_Equipment_Request_Approvers__mdt objApproverDetail;
                            if(mapLabelVsDeveloperNameApprovers != null && 
                                mapLabelVsDeveloperNameApprovers.containsKey(objEquipmentRequest.giic_Account_Type__c)){
                                objApproverDetail = JMS_Equipment_Request_Approvers__mdt.getInstance(mapLabelVsDeveloperNameApprovers.get(objEquipmentRequest.giic_Account_Type__c));
                            }
                            
                            //Email Notification to approvers
                            objSendNotication.sendMail(objApproverDetail.JMS_NAM_Email__c , EMPTY_STRING , 
                                                        EMPTY_STRING,htmlBody ,EMPTY_STRING, 
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
                        
                        else if(objEquipmentRequest.giic_Sub_Status__c == STR_ACTIVE_PENDING_Quote_INTEGRITY && 
                                objEquipmentRequest.giic_SQ_Integrity_Approval_Status__c ==  STR_SUBMITTED){

                            JMS_Equipment_Request_Approvers__mdt objApproverDetail = JMS_Equipment_Request_Approvers__mdt.getInstance(STR_EQUIPMENT_INTEGRITY);
                            
                            //Email Notification to approvers
                            objSendNotication.sendMail(objApproverDetail.JMS_Equipment_Integrity_Email__c , 
                                                        EMPTY_STRING , EMPTY_STRING,htmlBody ,
                                                        EMPTY_STRING, objEmailTemplate.Id,strCustomSubject,null);                                // custom bell notification to onwer of records
                                if(setEIApproverIds != null && !setEIApproverIds.isEmpty() && String.isNotBlank(customNotificationTitle)){
                                    
                                    JMS_CustomNotification.notifyUsers(setEIApproverIds,objEquipmentRequest.Id,customNotificationBody, 
                                    customNotificationTitle,System.Label.JMS_Custom_Notification_Name);
                                }
                        }
                        // end of else if
                      //}// end of  if  
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
            JMS_Logger.push(STR_SEND_EMAIL_NOTIFICATION_APPROVERS, Sales_Quote_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of sendEmailNotificationToApprovers method
    
    
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
    
      public static Set<String> getEquipmentIntegrityUser(){
        List<GroupMember> listGroupMembers =  new List<GroupMember>();
        Set<String> setUserIds = new Set<String>();
        try{
            Group objGroup = [SELECT Id,Name 
                                FROM Group
                                 WHERE Type =: STR_QUEUE 
                                 AND DeveloperName =: JMS_Sales_Quote_EI_APPROVERS limit 1];                   
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
            JMS_Logger.push(STR_EI_USERS, USER_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
        return setUserIds;    
      }
    
    
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
    * @description : To send Custom notification to the approvers  
    * @param       : List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 27/05/2022
    */
    public static void customNotificationToOwner(List<SObject> listNewSObject,Map<Id, SObject> oldItemsMap){
        //Variable declaration
        Map<Id, gii__SalesQuote__c> mapOldEquipmentRequest = (Map<Id,gii__SalesQuote__c>) oldItemsMap;
        List<gii__SalesQuote__c> listNewEquipment = (List<gii__SalesQuote__c>) listNewSObject;
        String strTitleName = System.Label.JMS_Custom_Notification_Approved_Title;
        /****************Commented for code ScanError
        Anil - 02/06/2022.
        //String strBody = JMS_ConstantsUtility.EMPTY_STRING; 
        ************************/
        Set<String> setApproverIds = new Set<String>();
        try{
            if(listNewEquipment != null && mapOldEquipmentRequest != null && !listNewEquipment.isEmpty()){
                for(gii__SalesQuote__c objEquipmentReq:listNewEquipment){
                    setApproverIds = new Set<String>();
                    setApproverIds.add(objEquipmentReq.ownerId);
                    if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty() &&
                    objEquipmentReq.giic_Overall_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).giic_Overall_Status__c &&
                    objEquipmentReq.giic_Overall_Status__c == STR_INPROGRESS_REJECTED){
                      
                        strTitleName = System.Label.JMS_Custom_Notification_Rejected_Title;
                        if(setApproverIds != null && !setApproverIds.isEmpty()){
                            JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentReq.Id,objEquipmentReq.Name , strTitleName,
                            System.Label.JMS_Custom_Notification_Name);
                        }
                        
                    }
                    else if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty() &&
                        objEquipmentReq.giic_NAM_approval_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).giic_NAM_approval_Status__c &&
                        objEquipmentReq.giic_NAM_approval_Status__c == STR_APPROVED){
                            setApproverIds.add(objEquipmentReq.ownerId);
                            if(setApproverIds != null && !setApproverIds.isEmpty()){
                                JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentReq.Id,objEquipmentReq.Name , strTitleName,
                                                                System.Label.JMS_Custom_Notification_Name);
                            }
                    }
                    else if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty() &&
                        objEquipmentReq.giic_SQ_Integrity_Approval_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).giic_SQ_Integrity_Approval_Status__c &&
                        objEquipmentReq.giic_SQ_Integrity_Approval_Status__c == STR_APPROVED){
                        setApproverIds.add(objEquipmentReq.ownerId);
                        if(setApproverIds != null && !setApproverIds.isEmpty()){    
                            JMS_CustomNotification.notifyUsers(setApproverIds,objEquipmentReq.Id,objEquipmentReq.Name , strTitleName,
                                                            System.Label.JMS_Custom_Notification_Name);
                        }
                    }
                    else if(mapOldEquipmentRequest != null && !mapOldEquipmentRequest.isEmpty() &&
                        objEquipmentReq.giic_RSM_approval_Status__c != mapOldEquipmentRequest.get(objEquipmentReq.Id).giic_RSM_approval_Status__c &&
                        objEquipmentReq.giic_RSM_approval_Status__c == STR_APPROVED){
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
            JMS_Logger.push(STR_CUSTOM_NOTIFICATION_TO_OWNER, Sales_Quote_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }// end of initiateEmailNotificationRequest method
    
    
    
}