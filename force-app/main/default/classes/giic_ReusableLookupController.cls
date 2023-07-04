/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : Class to process custom lookup values
Reviewer - Soni Jagdale
*************************************************************************************/
public with sharing class giic_ReusableLookupController {

    /* Method name : findRecords
    * Description : this method will return values of records based on object sent as parameter
    * Return Type : null
    * Parameter : searchKey and objectName as String
    */
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName, boolean isprod,String filter,String displayApiName) {  
        String filterQuery = '';
        String soql ='';
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        searchText += String.isNotBlank(displayApiName)? ( ' OR '+ displayApiName + ' LIKE \'' + String.escapeSingleQuotes(searchKey) + '%\')') : '';  
        if(objectName == 'gii__Warehouse__c'){
            searchText += ' AND giic_WarehouseType__c = ' + '\''+giic_Constants.CENTRAL + '\'';
        }
        if(isprod && objectName =='gii__Product2Add__c' && String.isNotBlank(filter)){
            searchText += ' AND gii__ProductGroup__r.Name = '+'\''+filter+'\'';
        }
        if(objectName =='gii__WeeklyCapacity__c' && String.isNotBlank(filter)){
            searchText += ' AND gii__ProductionLine__c = '+'\''+filter+'\'';
            soql = 'SELECT Id, Name,gii__ActualCapacityWeekUnits__c,gii__WeekNumber__c '+(String.isNotBlank(displayApiName)?(','+displayApiName):'')+' FROM ' +objectName+ ' WHERE ('+(String.isNotBlank(displayApiName)?('('):'')+'Name LIKE '+searchText+' ) LIMIT 6';  
        }else{
            soql = 'SELECT Id, Name '+(String.isNotBlank(displayApiName)?(','+displayApiName):'')+' FROM ' +objectName+ ' WHERE ('+(String.isNotBlank(displayApiName)?('('):'')+'Name LIKE '+searchText+' ) LIMIT 6';  
 
        }
        system.debug('SQOAL+++'+soql);
       
        String sql = soql;
        return Database.query(sql);  
    } 
}