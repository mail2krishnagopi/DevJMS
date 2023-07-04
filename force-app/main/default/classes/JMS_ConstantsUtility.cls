/*************************************************************
*   @Name: JMS_ConstantsUtility
*   @Description: To
*   @Date:  2/18/2022
*   @Inputs:       NA
*   @Author: Sachin Awati
**************************************************************/
public class JMS_ConstantsUtility {
    
    //Variable nomenclature - Object_Field_Value
    
    //GLOBALS
    //enter globals
    ////string values
    public static final Boolean FLAG = TRUE;
    public static final Boolean FALSE_FLAG = FALSE;
    public static final String OPERATOR_RECORDTYPE = 'Operator';
    public static final String EMPTY_STRING = '';
    public static final String NONE = 'None';
    public static final String COLON = ':';
    public static final String ATRATE_DOUBLE = '@@';
    public static final String DOUBLE_SLASH_PLUS = '\\+'; 
    public static final String DOUBLE_QUOTE = '\"';
    public static final String BACKWARD_SLASH = '/';
    public static final String New_Line = '\n';
    public static final String SPACE_STRING = ' ';
    public static final String DASH_STRING = '--';
    public static final String EQUAL_STRING = '=';
    public static final String COMPARISON_STRING = '==';
    public static final String SINGLE_DASH_STRING = '-';
    public static final String STR_COMMA_STRING = ',';
    public static final String SEMICOLAN = ';';
    public static final String PLUS = '+';
    public static final String DATA_TYPE_STRING = 'String';
    public static final String RECORD_ID = 'Id';
    public static final String NULL_STRING = 'null';
    public static final String GROUP_EDIT_ACCESS = 'Edit';
    public static final String SUCCESS = 'SUCCESS';
    public static final String ERROR = 'ERROR';
    public static final String WARNING = 'WARNING';
    public static final String PARTIAL = 'PARTIAL';
    public static final String FILTER = 'FILTER';
    public static final String RECORDTYPE_ID = 'RecordTypeId';
    public static final String STR='string';
    public static final String BOLEAN='boolean';
    public static final String DATES='date';
    public static final String DATETIMES='datetime';
    public static final String DEC='decimal';
    public static final String REL='__r';
    public static final string SPLIT_BY_COMMA  = ',';
    public static final string CASE_ID = 'caseId';
    public static final String LINE_BREAK = '<br/>';
    public static final String STR_SALE = 'SALE';
    public static final String STR_NO_SALE = 'NO-SALE';
    public static final String STR_NOSALE = 'NOSALE';
    public static final String STR_IAC = 'IAC';
    public static final String STR_TAB = '|';
    public static final Integer INT_ZERO = 0;
    public static final Integer INT_THREE = 3;
    public static final Integer INT_FOUR = 4;
    public static final Integer INT_NINETY = 90;
    public static final String STR_DISTRIBUTOR = 'Distributor';
    
    
    // Date Values
    public static final String DATE_DD = 'DD';
    public static final String DATE_MM = 'MM';
    public static final String DATE_MON = 'MON';
    public static final String DATE_MONM = 'MMM';
    public static final String DATE_YY = 'YY';
    public static final String DATE_YYYY = 'YYYY';
    public static final String DATE_JULIAN = 'JJJ';
    
    public static final String NEW_STRING = 'New';//New is a string value used
    public static final String STR_RECORD_URLS='(RecordURLs)';
    public static final String STR_USERNAME='(username)';
    public static final String STR_FIREFLY_ID ='(FireFlyId)';
    public static final String STR_OWNER_NAME='OwnerName';
    public static final String STR_AFTER_UPDATE ='afterupdate';
    public static final String STR_AFTER_UNDELETE ='afterundelete';
    public static final String STR_TERRITORY2_ASSIGNMENTRULE ='Territory2Manual';
    public static final String STR_INPROGRESS_REJECTED ='InProgress - Rejected';
    public static final String STR_EQUIPMENT_INTEGRITY = 'Equipment_Integrity';
	public static final String STR_SUBMITTED = 'Submitted';
        
    //Equipment Request Status
    //Status Values
    public static final String STR_ACTIVE_PENDING_RSM='Active - Pending RSM';
    public static final String STR_ACTIVE_PENDING_NAM_TRADE='Active - Pending NAM';
    public static final String STR_ACTIVE_PENDING_EQUIPMENT_INTEGRITY ='Active - Pending Equipment Integrity';
    public static final String STR_COMPLETED ='Completed';
    public static final String STR_APPROVED ='Approved';
    public static final String STR_New = 'New';
    
    //enter object APIs
    //SOBJECT API 
    public static final String USER_API = 'User';
    public static final String CASE_API = 'Case';
    public static final String CONTACT_API = 'Contact';
    public static final String ADDRESS_API = 'Address';
    public static final String PRODUCT_API = 'Product2';
    public static final String ACCOUNT_API = 'Account';
    public static final String Opportunity_API = 'Opportunity';
    public static final String EQUIPMENT_REQUEST_API = 'JMS_Equipment_Request__c';
    public static final String CONTENT_DOCUMENT_LINK_API = 'ContentDocumentLink';
    public static final String CONTENT_DOCUMENT_API = 'ContentDocument';
    public static final String CONTENT_VERSION_API = 'ContentVersion';
    public static final String OBJECT_TERRITORY2_ASSOCIATION_API = 'ObjectTerritory2Association';
    public static final String OBJECT_CAMPAIGN_TARGET_STAGING_API = 'JMS_Campaign_Target_Staging__c';
    public static final String OBJECT_BROKER_CALL_STAGING_API = 'JMS_Broker_Call_Staging__c';
    public static final String OBJECT_CAMPAIGN_TARGET_LANDING_API = 'JMS_Campaign_Target_Landing__c';
    public static final String OBJECT_BROKER_CALL_LANDING_API = 'JMS_Broker_Call_Landing__c';
    public static final String OBJECT_CAMPAIGN_API = 'Campaign';
    public static final String OBJECT_TERRITORY_ASSIGNMENT_API = 'JMS_Territory_Assignment__c';
	
    // Campaign Target Staging Intended For
    public static final String STR_BROKER = 'Broker';
    public static final String STR_BROKER_UPPERCASE = 'BROKER';
    public static final String STR_BEM = 'BEM';
    public static final String STR_JMS = 'JMS';
    
    //Status
    public static final string STR_STATUS_ERROR = 'Error';
    public static final string STR_STATUS_SUCCESS = 'Success';
    public static final string STR_STATUS_SENT = 'Sent';
    public static final string STR_COMPLETE = 'COMPLETE';
    public static final string STR_NO_SALE_STATUS = 'No Sale';
    public static final string STR_SALE_STATUS = 'Sale';
    	
    //Picklist Values
	//enter picklist values
	//Added coments
	//3/06/2022-code scan Issue
	public static final string TASK_STATUS_OPEN  = 'Open';
    public static final string TASK_STATUS_COMPLETED  = 'Completed';//Completed String
    public static final string CASE_STATUS_CLOSED  = 'Closed';
    public static final string CASE_STATUS_ESCALATED  = 'Escalated';
    public static final string CASE_STAUS_INPROGRESS= 'In Progress';//In Progress String
    
    //Email Constants
    //Constant Value
    public static final string DUPLICATE_FIREFLYID_NOTIFICATION  = 'This is to notify about a duplicate account with the same FireFly Id ';
    public static final string EMAIL_REGEX  = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    //Chatter Constants
    //Constant Value
    //Test post value
    public static final String CHATTER_TYPE_TEXTPOST = 'TextPost';
    
    //Queue Names
    //Equipment Request 
    public static final String JMS_EQUIPMENT_REQUEST_EI_APPROVERS = 'JMS_Equipment_Request_EI_Approvers';
    public static final String STR_QUEUE = 'Queue';
    
    //Broker Call Success Headers
    public static final String BROKER_CALL_SUCCESS_HEADERS = 'broker_call_id,opportunity_id,opportunity_status,call_date,call_status,initiative_name,territory_name,territory_id,call_distributor_code,call_distributor_name,jms_item_num,jms_item_description,annual_case_vol,item_status,item_nosale_reason,item_nosale_reason_detail,call_comment,company_type,company_id,company_sf_id,company_name,company_address,company_city,company_state,company_zip,company_phone,contact_first_name,contact_last_name,contact_title,contact_email,contact_phone,contact_phone_ext,salesperson_email,salesperson_first_name,salesperson_last_name,broker_name, \n';  
    //Broker Call Kickout headers
    public static final String BROKER_CALL_KICKOUT_HEADERS = 'kickout_reason,kickout_location,broker_call_id,opportunity_id,opportunity_status,call_date,call_status,initiative_name,territory_name,territory_id,call_distributor_code,call_distributor_name,jms_item_num,jms_item_description,annual_case_vol,item_status,item_nosale_reason,item_nosale_reason_detail,call_comment,company_type,company_id,company_sf_id,company_name,company_address,company_city,company_state,company_zip,company_phone,contact_first_name,contact_last_name,contact_title,contact_email,contact_phone,contact_phone_ext,salesperson_email,salesperson_first_name,salesperson_last_name,broker_name, \n';
    
    //Campaign Target Success headers
   public static final String CAMPAIGN_TARGET_SUCCESS_HEADERS = 'batch_id,campaign_name,target_id,call_made_by,ff_id,account_name,account_address,account_city,account_state,account_zip,account_country,account_type,account_phone,contact_first_name,contact_last_name,contact_email,contact_title,contact_phone,contact_phone_ext,contact_mobile_phone,sku,sku_description,annual_cases,line_description,supplier, \n';
    //Campaign Target Kickout headers
	public static final String CAMPAIGN_TARGET_KICKOUT_HEADERS = 'kickout_reason,kickout_location,batch_id,campaign_name,target_id,call_made_by,ff_id,account_name,account_address,account_city,account_state,account_zip,account_country,account_type,account_phone,contact_first_name,contact_last_name,contact_email,contact_title,contact_phone,contact_phone_ext,contact_mobile_phone,sku,sku_description,annual_cases,line_description,supplier, \n';	
    public static final String STR_ITEM_NO_SALE_REASON_DETAIL = 'JMS_Item_No_Sale_Reason_Detail__c';
    public static final String STR_FIELD_OPP_STAGE = 'JMS_Opportunity_stage__c';
    public static final String STR_FIELD_BROKER_TERRITORY_ID = 'JMS_Company_Broker_Territory_Id__c';
    public static final String STR_FIELD_BROKER_TERRITORY_NAME = 'JMS_Company_Broker_Territory_Name__c';
    public static final String STR_ITEM_NO_SALE_REASON = 'JMS_Item_No_Sale_Reason__c';
    public static final String STR_COMPANY_TYPE = 'JMS_Company_Type__c';
    
    //ERF Variables from Custom Notifcation Label
    public static final String STR_ER_NAME_VAL = 'ERNameVal';
    public static final String STR_ER_OWNER_VAL = 'OwnerNameVal';
    public static final String STR_ER_CREATEDBY_NAME_VAL = 'CreatedByNameVal';
    public static final String STR_ACCOUNT_NAME_VAL = 'AccountNameVal';
    public static final String STR_OWNER_NAME_VAL = 'OWNERNAMEVAL';
    public static final String STR_NAM = 'NAM';
    public static final String STR_EQUIPMENT_INTEGRITY_TEAM = 'Equipment Integrity Team';
    public static final String STR_INTEGRATION_USER = 'Integration User';
    
    //Broker Call Email Template Subject Variable
    public static final String STR_REPORT_NAME_VAL = 'REPORT_NAME_VAL';
    
    //User Profile names
    public static final String STR_SALES_USER_PROFILE = 'Sales Users';
    public static final String STR_ADMIN_USER_PROFILE = 'System Administrator';
    
    //Broker Call Email Template Reports Variables
    public static final String STR_OPERATOR_RECORD_PROCESSED = 'OPERATOR_RECORD_PROCESSED';
    public static final String STR_OPERATOR_RECORD_UNPROCESSED = 'OPERATOR_RECORD_UNPROCESSED';
    public static final String STR_DISTRIBUTOR_RECORD_PROCESSED = 'DISTRIBUTOR_RECORD_PROCESSED';
    public static final String STR_DISTRIBUTOR_RECORD_UNPROCESSED = 'DISTRIBUTOR_RECORD_UNPROCESSED';
    public static final String STR_TOTAL_RECORD_PROCESSED = 'TOTAL_RECORD_PROCESSED';
    public static final String STR_TOTAL_RECORD_UNPROCESSED = 'TOTAL_RECORD_UNPROCESSED';
    public static final String STR_BATCH_ID = 'STR_BATCH_ID';
    
    //BrokerName
    public static final String STR_CLIENT_END_USER = 'CLIENT END USER';
    //Broker Call Staging Kickout Location
    public static final String STR_AWS = 'AWS';
    public static final String STR_SALESFORCE = 'Salesforce';
    //Opportunity Stage
    public static final String STR_CLOSED_WON = 'Closed Won';
    public static final String STR_QUALIFICATION = 'Qualification';
    
    public static final String STR_COMMA_WITH_QUOTE = '","';
    public static final String STR_FIRST_QUOTE = '"';
    public static final String STR_END_NEWLINE_QUOTE = '"\n';
    
}