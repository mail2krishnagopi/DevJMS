public with sharing class JMS_ContentVersionTriggerHelper {
    private static final String STR_RESTRICT_TO_RENAME_FILES = 'restrictToRenameFiles';
    /**
    * @description : To retrict user to not able to change the attached 
                     file name
    * @param       : List<SObject> newItems,Map<Id, SObject> oldItemsMap
    * @author      : Vasudha
    * @date        : 06/04/2022
    */
    public static void restrictToRenameFiles(List<SObject> newItems , Map<Id, sObject> oldItems){
        // Initialize Variables
        List<ContentVersion> listContentVersion = (List<ContentVersion>) newItems;
        Map<Id,ContentVersion> mapOldContentVersions = (Map<Id,ContentVersion>) oldItems;
        try{
            if(listContentVersion != null && !listContentVersion.isEmpty()){
                for(ContentVersion objContentVersion :listContentVersion){
                    if(mapOldContentVersions != null && mapOldContentVersions.containsKey(objContentVersion.Id) && objContentVersion.Title != mapOldContentVersions.get(objContentVersion.Id).Title){
                        objContentVersion.addError(System.Label.JMS_Restrict_To_Change_File_Name);
                    }//end of if
                }// end of for 
            }// end of if
        }catch(Exception excep){
            JMS_Logger.push(STR_RESTRICT_TO_RENAME_FILES, JMS_ConstantsUtility.CONTENT_VERSION_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }// end of finally
    }//end of restrictToRenameFiles meth
}