public class CustomLookupLwcController {
    // Method to fetch lookup search result   
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName, String whereFieldApiName, String wherefieldValue) {    
        List < sObject > returnList = new List < sObject > ();
        //System.Debug('This has been called ::'+searchKey);
        //System.Debug('This has been called :: whereFieldApiName :: '+whereFieldApiName);
        //System.Debug('This has been called :: wherefieldValue :: '+wherefieldValue);
        string sQuery = 'Select Id,Name From '+ sObjectApiName;
        string sWildCardText = '%' + searchKey + '%';
        if(String.isNotBlank(whereFieldApiName) && String.isNotBlank(wherefieldValue)){
            sQuery = sQuery +  ' Where Name Like : sWildCardText AND '+whereFieldApiName+'=\''+wherefieldValue+'\''+' order by createdDate DESC';
        }
        else{
            sQuery = sQuery +' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        } 
        //System.Debug('This has been called :: sQuery :: '+sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        //System.Debug('This is the query Result'+returnList);
        return returnList;
    }
     
     // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}