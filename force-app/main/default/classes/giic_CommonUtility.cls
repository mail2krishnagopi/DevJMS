/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : Utility Class to create common methods
Reviewer - Soni Jagdale
*************************************************************************************/

public with sharing class giic_CommonUtility {

    /* Method name : getRegionCountryMDT
    * Description :get Country and Legal Entity based on Region from Metadata
    * Return Type : Map<String,List<String>>
    * Parameter : null
    */
    public static Map<String,Map<String,List<String>>> getRegionCountryMDT(){
        String[] regions;
        for(User u : [select id,XC_LegalEntities__c from user where id =:userinfo.getUserId()]){
            if(u.XC_LegalEntities__c != null){
                regions = u.XC_LegalEntities__c.split(';');
            }
        }
        Map<String,Map<String,List<String>>> mapRegCon = new Map<String,Map<String,List<String>>>(); //primary key = region name, secodary key = country name, value = list of countries
        for(XC_CM_CountryLegalEntityAssociation__mdt region : [select giic_Region__c,XC_Country__c,XC_LegalEntity__c from XC_CM_CountryLegalEntityAssociation__mdt where XC_LegalEntity__c IN :regions]){
            if(!mapRegCon.containsKey(region.giic_Region__c)){
                mapRegCon.put(region.giic_Region__c,new Map<String,List<String>>());
            }
            
            if(mapRegCon.containsKey(region.giic_Region__c)){
                Map<String,List<String>> mapConLE = mapRegCon.get(region.giic_Region__c);
                if(!mapConLE.containsKey(region.XC_Country__c)){
                    mapConLE.put(region.XC_Country__c,new List<String>());
                }
                if(mapConLE.containsKey(region.XC_Country__c)){
                    List<String> legalEntities = mapConLE.get(region.XC_Country__c);
                        if(!legalEntities.contains(region.XC_LegalEntity__c) && regions.contains(region.XC_LegalEntity__c) ){
                            legalEntities.add(region.XC_LegalEntity__c);
                        }
                        mapConLE.put(region.XC_Country__c,legalEntities);
                }
                mapRegCon.get(region.giic_Region__c).putAll(mapConLE);
            }
        }
        return mapRegCon;
    }

    /* Method name : getCountyLegalEntryMDT
    * Description :get Legal Entity Based on Country from Metadata
    * Return Type : Map<String,List<String>>
    * Parameter : null
    */
    public static Map<String,List<String>> getCountyLegalEntryMDT(){
        Map<String,List<String>> mapLE = new Map<String,List<String>>(); //key = country name, value = list of legal entities

        /*for(XC_CM_LegalEntity_Configuration__mdt le : [select  XC_Country__c,XC_LegalEntity__c  from XC_CM_LegalEntity_Configuration__mdt]){
            if(!mapLE.containsKey(le.XC_Country__c)){
                mapLE.put(le.XC_Country__c,new List<String>());
            }   
            if(mapLE.containsKey(le.XC_Country__c)){
                List<String> legalEntities = mapLE.get(le.XC_Country__c);
                if(!legalEntities.contains(le.XC_LegalEntity__c)){
                    legalEntities.add(le.XC_LegalEntity__c);
                }
                mapLE.put(le.XC_Country__c,legalEntities);
            }
        }*/
        return mapLE;
    }

    /* Method name : getWarehouseforLegalEntity
    * Description : get warehouses based on legal Entity
    * Return Type : Map<String,List<gii__Warehouse__c>>
    * Parameter : null
    */
    public static Map<String,List<gii__Warehouse__c>> getWarehouseforLegalEntity(){
        Map<String,List<gii__Warehouse__c>> lstMapWarehouseLegalEntity = new Map<String,List<gii__Warehouse__c>>();

        /*for(gii__Warehouse__c objWarehouse : [select id, name,giic_LegalEntity__c,gii__WareHouseCountry__c from gii__warehouse__c where giic_WarehouseType__c =:giic_Constants.CENTRAL]){
            if(objWarehouse.giic_LegalEntity__c != null && objWarehouse.gii__WareHouseCountry__c!= null){
                String key = objWarehouse.gii__WareHouseCountry__c + ' - ' + objWarehouse.giic_LegalEntity__c; //key for the map
                if(!lstMapWarehouseLegalEntity.containsKey(key)){//objWarehouse.giic_LegalEntity__c
                    lstMapWarehouseLegalEntity.put(key, new List<gii__Warehouse__c>());
                }
                lstMapWarehouseLegalEntity.get(key).add(objWarehouse);
            }
        } */  
        return lstMapWarehouseLegalEntity;
    }
    
    
    /* Method name : getDemandForecastSetup
    * Description : get Demand Forecast Setup for Demand Forecast Record
    * Return Type : List<gii__DemandForecastSetup__c>
    * Parameter : Demand Forecast Cycle RecId, Plan name, region name
    */
    public static List<gii__DemandForecastSetup__c> getDemandForecastSetup(String dfRecId, String planName,String regionName){
        List<gii__DemandForecastSetup__c> lstDFS = new List<gii__DemandForecastSetup__c>();
        String whereClause = '';
        
        switch on planName{
            when 'Forecast Plan','Demand Plan','Spareparts Forecast Plan' {
                if(!String.isBlank(regionName)){
                    whereClause = ' AND giic_DemandForecastCycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Region__c = ' + '\''+String.escapeSingleQuotes(regionName) + '\'';
                }else{
                    whereClause = ' AND giic_DemandForecastCycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Region__c = null';
                }
            }
            /*when  'Demand Plan' {
                if(!String.isBlank(regionName)){
                    whereClause = ' AND giic_DemandForecastCycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Region__c = ' + '\''+regionName + '\'';
                }else{
                    whereClause = ' AND giic_DemandForecastCycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Region__c = null';
                }            
            }
            when 'Spareparts Forecast Plan' {
                if(!String.isBlank(regionName)){
                    whereClause = ' AND giic_DemandForecastCycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Region__c = ' + '\''+regionName + '\'';
                }else{
                    whereClause = ' AND giic_DemandForecastCycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Region__c = null';
                }
            }*/
            when 'Supply Plan' {
                if(!String.isBlank(regionName)){
                    whereClause = ' AND giic_Supply_Plan_Cycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Region__c = ' + '\''+String.escapeSingleQuotes(regionName) + '\'';
                }else{
                    whereClause = ' AND giic_Supply_Plan_Cycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'';// + ' AND giic_Region__c = null';
                }
            }
            when 'Production Plan'{
                if(!String.isBlank(regionName)){
                    whereClause = ' AND giic_Supply_Plan_Cycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Supplier__c IN ' + '\''+String.escapeSingleQuotes(regionName) + '\'';
                }else{
                    whereClause = ' AND giic_Supply_Plan_Cycle__c =\'' +String.escapeSingleQuotes(dfRecId) +'\'' + ' AND giic_Supplier__c = null';
                }
            }
        }
        String soql = 'select id,giic_DemandForecastCycle__c,giic_DemandForecastCycle__r.gii__Active__c, giic_RelatedTo__c,giic_Supply_Plan_Cycle__c,giic_ApprovalStatus__c,giic_BatchStatus__c,giic_isCycleFirstRun__c from gii__DemandForecastSetup__c '
            + ' where giic_RelatedTo__c =' + '\''+String.escapeSingleQuotes(planName) +'\'' 
            + whereClause;
        String sql = soql;
        lstDFS = Database.query(sql);
        return lstDFS;
    }
    
    /* Method name : isLoggedInUserApprover
    * Description : To check whelther logged in user is approver or not
    * Return Type : Boolean
    * Parameter : Demand Forecast Cycle Record ID, plan name, region name
    */
    public static Boolean isLoggedInUserApprover(String cycleRecId, String planName,String regionName){
        
        /**Variable Declaration */
        List<GroupMember> lstGroup=new List<GroupMember>();
        List<GroupMember> lastApproverGroup=new List<GroupMember>();
        Id userId = userinfo.getUserId();
        Id dfSetupId;
        boolean isapprover;
        List<gii__DemandForecastSetup__c> dfSetupList = getDemandForecastSetup(cycleRecId,planName,regionName);
        for(gii__DemandForecastSetup__c dfs:dfSetupList){
            if(Approval.isLocked(dfs.id)){
                dfSetupId=dfs.id;
            }
        }
        //If DFS found -check logged in user is approver or not
        List<ProcessInstanceWorkitem> piwiList = [select id,ActorId,Actor.name from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:dfSetupId and ProcessInstance.Status = :giic_Constants.PENDING];
        
        if(!piwiList.isEmpty())
        {
            lstGroup = new List<GroupMember>([Select id,UserOrGroupId from GroupMember where Group.type=:giic_Constants.QUEUE and Group.Name =:piwiList[0].Actor.name and UserOrGroupId =:userId]);
        }
        if(dfSetupId != null){
            if(lstGroup.size() > 0){
                isapprover = true;   
                
            }else{
                isapprover = false;
            }
        }
        return isapprover;
    }

    /* Method name : approve
    * Description : This method will Approve the Demand Forecast Setup
    * Return Type : Null
    * Parameter : Demand Forecast Setup Record ID, String
    */
    public static void approve(String recordId, String approveComments){
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        try{
            for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId]){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Approve');
                req.setcomments(approveComments);
                requests.add(req);
            }
            Approval.ProcessResult[] processResults = Approval.process(requests);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
    }

    /* Method name : approve
    * Description : This method will Approve the Demand Forecast Setup
    * Return Type : Null
    * Parameter : Demand Forecast Setup Record ID, String
    */
    public static void approvePlan(String planCycleId,String planName, String approveComments){
     
        Set<Id> dfsIds = new Set<Id>();
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        List<gii__DemandForecastSetup__c> dfsLst = [select id,giic_DemandForecastCycle__c,giic_RelatedTo__c from gii__DemandForecastSetup__c where giic_DemandForecastCycle__c=: planCycleId AND giic_RelatedTo__c=:planName] ;
        if(!dfsLst.isEmpty()){
        for(gii__DemandForecastSetup__c dfs : dfsLst){
            dfsIds.add(dfs.Id);
        }
            
        List<ProcessInstanceWorkitem> workItemLst = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :dfsIds AND ProcessInstance.Status =:giic_Constants.PENDING];
        if(!workItemLst.isEmpty()){   
            for(ProcessInstanceWorkitem workItem : workItemLst){    
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Approve');
                req.setcomments(approveComments);
                requests.add(req);
                }
            }
        }
        if(requests.size()>0){
            Approval.ProcessResult[] processResults = Approval.process(requests);
        }
    }
    /* Method name : reject
    * Description : This method will Reject the Demand Forecast Setup
    * Return Type : Null
    * Parameter : Demand Forecast Setup Record ID, String
    */
    public static void reject(String recordId, String rejectComments){
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        try{
            for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId]){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Reject');
                req.setcomments(rejectComments);
                requests.add(req);
            }
            Approval.ProcessResult[] processResults = Approval.process(requests);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
    }

    /* Method name : approve
    * Description : This method will Approve the Demand Forecast Setup
    * Return Type : Null
    * Parameter : Demand Forecast Setup Record ID, String
    */
    public static void rejectPlan(String planCycleId,String planName, String rejectComments){
     
        Set<Id> dfsIds = new Set<Id>();
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        List<gii__DemandForecastSetup__c> dfsLst = [select id,giic_DemandForecastCycle__c,giic_RelatedTo__c from gii__DemandForecastSetup__c where giic_DemandForecastCycle__c=: planCycleId AND giic_RelatedTo__c=:planName] ;
        if(!dfsLst.isEmpty()){
            for(gii__DemandForecastSetup__c dfs : dfsLst){
                dfsIds.add(dfs.Id);
            }
            
            List<ProcessInstanceWorkitem> workItemLst = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :dfsIds AND ProcessInstance.Status =:giic_Constants.PENDING];
            if(!workItemLst.isEmpty()){   
                for(ProcessInstanceWorkitem workItem : workItemLst){    
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkitemId(workItem.Id);
                    req.setAction('Reject');
                    req.setcomments(rejectComments);
                    requests.add(req);
                }
            }
        }
        if(requests.size()>0){
            Approval.ProcessResult[] processResults = Approval.process(requests);
        }
    }

    /* Method name : collectErrorLog
    * Description : This method will create error record
    * Return Type : Null
    * Parameter : List<gii__ErrorLog__c>, String,String,String,Boolean
    */
    public static List<gii__ErrorLog__c> collectErrorLog(List<gii__ErrorLog__c> errorLogs,string message,string source,String plancycleId,boolean isfromDFC){
            gii__ErrorLog__c errolog=new gii__ErrorLog__c();
            errolog.giic_Source__c=source;
            errolog.giic_ErrorMessage__c=message;
            if(isfromDFC){
             errolog.giic_DemandForecastCycle__c = plancycleId;
            }else{
             errolog.giic_SupplyPlanCycle__c = plancycleId;
            }
            errorLogs.add(errolog);
        return errorLogs;
    }
    
    /*
* Method name : deActivateErrorLogs
* Description : deactivate error logs from record
* Return Type : void
* Parameter : Set<ID> setRecordIds
*/ 
    public static void deActivateErrorLogs(Set<String> setRecordIds){
        if(!setRecordIds.isEmpty()){
            try{
                List<Integration_Error_Log__c> errList = new List<Integration_Error_Log__c>();
                String recId = new List<String> (setRecordIds).get(0);
                String sObjName = Id.valueOf(recId).getSObjectType().getDescribe().getName();
                String sObjFieldName;
                if(sObjName != null){
                    sObjFieldName = sObjName.replace('gii__','giic_');
                }
                if('Account'.equals(sObjName)){
                    errList = [select Id, giic_IsActive__c from Integration_Error_Log__c where giic_IsActive__c = true and giic_Account__c in : setRecordIds ];
                }/*else if('gii__InventoryAdjustmentStaging__c'.equals(sObjName)){
                    errList = [select Id, giic_IsActive__c from Integration_Error_Log__c where giic_IsActive__c = true and giic_Inventory_Adjustment_Staging__c in : setRecordIds ];
                }else if('gii__PaymentStaging__c'.equals(sObjName)){
                    errList = [select Id, giic_IsActive__c from Integration_Error_Log__c where giic_IsActive__c = true and giic_SalesOrderPaymentStaging__c in : setRecordIds ];
                }*/else if('gii__OrderInvoice__c'.equals(sObjName)){
                    errList = [select Id, giic_IsActive__c from Integration_Error_Log__c where giic_IsActive__c = true and giic_Invoice__c in : setRecordIds ];
                }else{
                    errList=database.query('select Id, giic_IsActive__c from Integration_Error_Log__c where giic_IsActive__c = true and ' +sObjFieldName+ ' in : setRecordIds ');
                }
                
                if(!errList.isEmpty()) {
                    for(Integration_Error_Log__c e :errList){ e.giic_IsActive__c =false;}
                    update errList;
                }
            }catch(exception e){
                System.debug('Ex:'+ e.getMessage() +  'Line No : ' + e.getLineNumber());
                throw e;
            }
        }
    }
}