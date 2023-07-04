/*************************************************************
*   @Name: JMS_ContentDocumentLinkTriggerHelper
*   @Description: To
*   @Date: 21/03/2022
*   @Inputs:       NA
*   @Author: Offshore(PwC)
**************************************************************/
public without sharing class JMS_ContentDocumentLinkTriggerHelper {
     /**
    * @description : To get the equipment request Id when user upload the files 
                     and send Ids to update Equipment request record
    * @param       : List<SObject> newItems ,String strObjectName
    * @author      : Offshore(PWC)
    * @date        : 22/03/2022
    */
    public static void beforeInsert(List<SObject> newItems ,String strObjectName){
        List<ContentDocumentLink> listContentDocumentLink = (List<ContentDocumentLink>) newItems;
        Set<Id> setEquipmentRequestIds = new Set<Id>();
        for(ContentDocumentLink objContentLink :listContentDocumentLink){
            setEquipmentRequestIds.add( objContentLink.LinkedEntityId );
        }// end of for       
        List<SObject> listObjectsRecpordsGlobalDescribe = getsObjectsRecordsGlobalDescribe(setEquipmentRequestIds,strObjectName);
        if(listObjectsRecpordsGlobalDescribe != null && !listObjectsRecpordsGlobalDescribe.isEmpty() && strObjectName == 'JMS_Equipment_Request__c'){
            updateEquipmentReqonDocUpload(listObjectsRecpordsGlobalDescribe);
        }// end of if 
    }// end of beforeInsert method  
    
    /**
    * @description : To get the list equipment request record to update
    * @param       : Set<Id> setEquipmentRequestIds,String strObjectName
    * @author      : Offshore(PWC)
    * @date        : 22/03/2022
    */
    public static List<SObject> getsObjectsRecordsGlobalDescribe(Set<Id> setEquipmentRequestIds,String strObjectName){
        // Initialize variables
        Map<String,Schema.SObjectType> objGlobaldescribe = Schema.getGlobalDescribe();
        List<SObject> listsObjectrecords = new List<SObject>();
        Schema.SObjectType sobjType = objGlobaldescribe.get(strObjectName);
        String query = '';
        //Schema.sObjectType sObjectTypeVar = objName.sObjectType;
        DescribeSObjectResult describeResult = sobjType.getDescribe();
        List<String> listFieldNames = new List<String>( describeResult.fields.getMap().keySet());
        if (listFieldNames != null && !listFieldNames.isEmpty() && setEquipmentRequestIds != null && 
            !setEquipmentRequestIds.isEmpty()) {
        query =
        'SELECT ' +
            String.join( listFieldNames, ',' ) +
        ' FROM ' +
            describeResult.getName() + 
        ' WHERE Id IN: setEquipmentRequestIds';
        }// end of if
        
        listsObjectrecords = Database.query( query );    
        return listsObjectrecords;
    }// end of getsObjectsRecordsGlobalDescribe method 
    
     /**
    * @description : To update list equipment request field JMS_Is_Attachment_Added__c
                     if files are attached with records
    * @param       : List<SObject> newItems ,String strObjectName
    * @author      : Offshore(PWC)
    * @date        : 22/03/2022
    */
    public static void updateEquipmentReqonDocUpload(List<sObject> listsObjectProcessRecords){
        // Initialize variables
        List<JMS_Equipment_Request__c> listNewEquipmentRequest = (List<JMS_Equipment_Request__c>) listsObjectProcessRecords;
        List<JMS_Equipment_Request__c> listUpdatedEquipmentRequest =  new List<JMS_Equipment_Request__c>();
        if(listsObjectProcessRecords != null && !listsObjectProcessRecords.isEmpty()){
            for(JMS_Equipment_Request__c objEquipmentRequest : listNewEquipmentRequest) {
            JMS_Equipment_Request__c objUpdateEquipmentRequest = new  JMS_Equipment_Request__c(); 
            objUpdateEquipmentRequest.Id =  objEquipmentRequest.Id;
            objUpdateEquipmentRequest.JMS_Is_Attachment_Added__c =  true;                                                
            listUpdatedEquipmentRequest.add(objUpdateEquipmentRequest);
    
            }// end of for
        }// end of if
        if(listUpdatedEquipmentRequest != null && !listUpdatedEquipmentRequest.isEmpty()){
            Database.update(listUpdatedEquipmentRequest);
        }// end of if
    }// end of updateEquipmentReqonDocUpload

}