public with sharing class AppController {
    /*
    @AuraEnabled
    public static String getUserAccount(){
        User user = [select Id, Name, ContactId from User where Id = :UserInfo.getUserId() LIMIT 1];
        Contact con = [Select Id, AccountId from Contact Where Id = :user.ContactId];
        return con.AccountId;
    }
    */
    @AuraEnabled
    public static String getUserType(){        
        return UserInfo.getUserType();
    }
    
    @AuraEnabled
    public static Map<String, Object> getStages(String processName){        
        String strProcessName = (String)processName;
        System.debug('strProcessName:::' + strProcessName);
        List<ProcessStepsWrapper> psMD = new List<ProcessStepsWrapper>();
        for(ProcessSteps__mdt ps :[SELECT Id, Active__c, Process__c, Page_Name__c, Step_Name__c, Step_Number__c FROM ProcessSteps__mdt WHERE Active__c =: true AND Process__c =: strProcessName ORDER BY Step_Number__c ASC]){
            ProcessStepsWrapper pr = new ProcessStepsWrapper();
            pr.Active = ps.Active__c;
            pr.Process = ps.Process__c;
            pr.Page_Name = ps.Page_Name__c;
            pr.Step_Name = ps.Step_Name__c;
            pr.Step_Number = ps.Step_Number__c;
            psMD.add(pr);    
        }
        
        Map<String, Object> mp = new Map<String, Object>();
        mp.put('ProcessSteps', psMD);
        String userType = getUserType();
        if(userType.equalsIgnoreCase('Standard')){            
            mp.put('isExternalUser', false);
        } 
        else{
            //String accountId = getUserAccount();
            mp.put('isExternalUser', true);
            //mp.put('accountId', accountId);
        } 
        SalesOrderUtil.deleteSO(null);
        return mp;
    }
}