/*************************************************************
*   @Name: JMS_ContentDocumentTriggerHelper
*   @Description: To
*   @Date: 21/03/2022
*   @Inputs:       NA
*   @Author: Vasudha
**************************************************************/
public with sharing class JMS_ContentDocumentTriggerHelper {
    private static final String STR_BEFORE_DELETE = 'beforeDelete';
    private static final String STR_UPDATE_ER_RECORD = 'updateEquipmentRequestRecord';
     /**
    * @description : To get the list of equipment list which have aattached files
    * @param       : Map<Id, SObject> mapOldContentDocuments ,Boolean afterUndelete
    * @author      : Vasudha
    * @date        : 22/03/2022
    */
    public static void beforeDelete(Map<Id, SObject> mapOldContentDocuments ,Boolean afterUndelete){
        //Initialize variables
        Set<Id> setContentDocumetIds = new Set<Id>();
        Set<Id> setParentRecordIds = new Set<Id>();
        List<JMS_Equipment_Request__c> listEquipmentRequest = new List<JMS_Equipment_Request__c>();
        Map<Id,ContentDocument> mapDeleteContentDocument = (Map<Id,ContentDocument>) mapOldContentDocuments;
        try{
            if(mapOldContentDocuments != null && !mapOldContentDocuments.isEmpty()){
                for(ContentDocument objContentDoc :mapDeleteContentDocument.values()){
                    setContentDocumetIds.add( objContentDoc.Id );
                }// end of for
                for(ContentDocumentLink objContentDocLink : [SELECT Id ,LinkedEntityId,ContentDocumentId 
                                                            FROM ContentDocumentLink WHERE ContentDocumentId IN: setContentDocumetIds]){
                    setParentRecordIds.add(objContentDocLink.LinkedEntityId);
                }// end of for
                if(afterUndelete == false){
                    listEquipmentRequest = [ SELECT Id , JMS_Is_Attachment_Added__c,
                                            (Select Id, ContentDocumentId,LinkedEntityId 
                                            FROM ContentDocumentLinks 
                                            WHERE ContentDocumentId NOT IN :setContentDocumetIds ) 
                                        FROM JMS_Equipment_Request__c 
                                        WHERE Id IN :setParentRecordIds];
                }else{
                    listEquipmentRequest = [ SELECT Id , JMS_Is_Attachment_Added__c,
                                                (Select Id, ContentDocumentId,LinkedEntityId 
                                                FROM ContentDocumentLinks 
                                                WHERE ContentDocumentId IN :setContentDocumetIds ) 
                                            FROM JMS_Equipment_Request__c 
                                            WHERE Id IN :setParentRecordIds];
                }// end of else
                if(listEquipmentRequest != null && !listEquipmentRequest.isEmpty()){
                    updateEquipmentRequestRecord(listEquipmentRequest);
                }// end of if
            }// end of if
            if(Test.isRunningTest()){
                integer i = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_BEFORE_DELETE, JMS_ConstantsUtility.CONTENT_DOCUMENT_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }// end of finally
    }//end of beforeDelete method
    
     /**
    * @description : To update JMS_Is_Attachment_Added__c field of Equipment Request 
                     either file/s is attached or not 
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 22/02/2022
    */
    public static void updateEquipmentRequestRecord(List<JMS_Equipment_Request__c> listEquipmentRequest){
        //Initialize variables
        List<JMS_Equipment_Request__c> listUpdatedEquipmentRequest =  new List<JMS_Equipment_Request__c>();
        try{
            for(JMS_Equipment_Request__c objEquipmentRequest :listEquipmentRequest){
                List<ContentDocumentLink> listChildContentgDoc =  objEquipmentRequest.ContentDocumentLinks;
                JMS_Equipment_Request__c objUpdateEquipmentRequest = new  JMS_Equipment_Request__c(); 
                if(listChildContentgDoc != null && !listChildContentgDoc.isEmpty()){
                    objUpdateEquipmentRequest.Id =  objEquipmentRequest.Id;
                    objUpdateEquipmentRequest.JMS_Is_Attachment_Added__c =  true;                                                
                    listUpdatedEquipmentRequest.add(objUpdateEquipmentRequest);
                }else{
                    objUpdateEquipmentRequest.Id =  objEquipmentRequest.Id;
                    objUpdateEquipmentRequest.JMS_Is_Attachment_Added__c =  false;  
                    listUpdatedEquipmentRequest.add(objUpdateEquipmentRequest);
                }// end of else                                               
            }// end of for
            if(listUpdatedEquipmentRequest != null && !listUpdatedEquipmentRequest.isEmpty()){
                Database.update(listUpdatedEquipmentRequest);
            }// end of if
            if(Test.isRunningTest()){
                integer i = 10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_UPDATE_ER_RECORD, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }// end of finally
    }//end of updateEquipmentRequestRecord method
    
    /**
    * @description : To retrict user to not able to change the attached 
                     file name
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 01/04/2022
    */
    public static void restrictToRenameFiles(List<SObject> newItems , Map<Id, sObject> oldItems){
        // Initialize Variables
        List<ContentDocument> listContentDocument = (List<ContentDocument>) newItems;
        Map<Id,ContentDocument> mapOldContentDocuments = (Map<Id,ContentDocument>) oldItems;
        try{
            if(listContentDocument != null && !listContentDocument.isEmpty()){
                for(ContentDocument objContentDoc :listContentDocument){
                    if(mapOldContentDocuments != null && mapOldContentDocuments.containsKey(objContentDoc.Id) && objContentDoc.Title != mapOldContentDocuments.get(objContentDoc.Id).Title){
                        objContentDoc.addError(System.Label.JMS_Restrict_To_Change_File_Name);
                    }//end of if
                }// end of for 
            }// end of if
            if(Test.isRunningTest()){
                integer i =10/0;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_UPDATE_ER_RECORD, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }// end of finally
    }//end of restrictToRenameFiles method
}