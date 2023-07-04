public with sharing class POSupplierController {
     @AuraEnabled
    public static List < sObject > fetchLookup(String searchKeyWord, String objectName) {
        system.debug('objectName-->' + objectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +objectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    
    @AuraEnabled
    public static Map<String, Object> getPurchaseOrderSteps(string processName){
        System.debug('getPurchaseOrderSteps');
        String strProcessName = (String)processName;
        List<ProcessSteps__mdt> psMD= [SELECT Id, Active__c, Process__c, Page_Name__c, Step_Name__c, Step_Number__c FROM ProcessSteps__mdt WHERE Active__c =: true AND Process__c =: processName  ORDER BY Step_Number__c ASC];
        Map<String, Object> mp = new Map<String, Object>();
        List<ProcessStepsWrapper> stepList = new List<ProcessStepsWrapper>();
        for(ProcessSteps__mdt step : [SELECT Id, Active__c, Process__c, Page_Name__c, Step_Name__c, Step_Number__c 
                                      FROM ProcessSteps__mdt 
                                      WHERE Active__c =: true 
                                      AND Process__c =: strProcessName 
                                      ORDER BY Step_Number__c ASC]){
                                          
            ProcessStepsWrapper psw = new ProcessStepsWrapper();
            psw.Active = step.Active__c;
            psw.Process = step.Process__c;
            psw.Page_Name = step.Page_Name__c;
            psw.Step_Number = step.Step_Number__c;
            psw.Step_Name = step.Step_Name__c;
            stepList.add(psw);
        }
        System.debug('purchaseOrderSteps: ' + stepList);
        mp.put('ProcessSteps', stepList);
        PurchaseOrderUtil.deletePO(null);
        return mp;
        
    }
  
    @AuraEnabled
    public static SObject setPurchaseOrderFields(String fieldSetJson){
        try{
            System.debug('fieldSetJson : ' + fieldSetJson);
            gii__PurchaseOrder__c purchaseOrder = new gii__PurchaseOrder__c();
            List<FieldSetMember> fieldSetMembers = (List<FieldSetMember>)JSON.deserialize(fieldSetJson, List<FieldSetMember>.class);
            for(FieldSetMember fieldMember : fieldSetMembers){
                if(fieldMember.value != null && fieldMember.value != ''){
                    if(fieldMember.type == 'DATE'){
                        purchaseOrder.put(fieldMember.fieldPath, Date.valueOf(fieldMember.value));
                    }
                    else{
                        purchaseOrder.put(fieldMember.fieldPath, fieldMember.value);
                    }
                    System.debug('Add value : ' + fieldMember.value + ' to field : ' + fieldMember.fieldPath);
                }
            }
            
            System.debug('Purchase Order after setting values : ' + purchaseOrder);
            //upsert purchaseOrder;
            return purchaseOrder;
        }
        catch(exception e){
            system.debug('Exception' + e);
            return null;
        }
        
    }
    
    @AuraEnabled
    public static List<FieldSetMember> getFieldSet(String purchaseOrder){ 
        List<Schema.FieldSetMember> fieldSet = SObjectType.gii__PurchaseOrder__c.FieldSets.Create_Purchase_Order.getFields(); 
        Map<String, Schema.SObjectField> mapOfFields = Schema.SObjectType.gii__PurchaseOrder__c.fields.getMap();
        Id po = null;
        System.debug('puchaseOrder : ' + purchaseOrder);
        //SObject purchaseOrderObj = null;
        Map<String, Object> mapOfFieldNameToValue = new Map<String, Object>();
        
        if(String.isBlank(purchaseOrder)){
            for(gii__PurchaseOrderLine__c poLine : [SELECT Id, Is_Active_Cart_Line__c, gii__PurchaseOrder__c, CreatedById FROM gii__PurchaseOrderLine__c WHERE Is_Active_Cart_Line__c =: true AND CreatedById =: UserInfo.getUserId() LIMIT 1]){
                po = poLine.gii__PurchaseOrder__c;
            }
            if(po != null){
                String soqlQuery = 'SELECT Id';
                for(Schema.FieldSetMember field : fieldSet){
                    soqlQuery += ', ' + field.fieldPath;
                }
                System.debug('soqlQuery : ' + soqlQuery);
                soqlQuery += ' FROM gii__PurchaseOrder__c WHERE Id =: po LIMIT 1';
                gii__PurchaseOrder__c tempPO = Database.query(soqlQuery);
                mapOfFieldNameToValue = tempPO.getPopulatedFieldsAsMap();
                System.debug('puchaseOrder : ' + purchaseOrder);
                System.debug('soqlQuery : ' + soqlQuery);
            }
        }
        else{
            mapOfFieldNameToValue = (Map<String, Object>)JSON.deserializeUntyped(purchaseOrder);
        }
        
        List<FieldSetMember> fs = new List<FieldSetMember>();
        for(Schema.FieldSetMember field : fieldSet){
            Schema.DescribeFieldResult describeResult = mapOfFields.get(field.getFieldPath()).getDescribe();
            FieldSetMember newField = new FieldSetMember(describeResult);
            //newField.type = newField.type == 'BOOLEAN' ? 'CHECKBOX' : newField.type;
            if(!mapOfFieldNameToValue.isEmpty()){
                if(newField.type == 'DATE'){
                    if(mapOfFieldNameToValue.get(newField.fieldPath) != null){
                        List<String> tempList = String.valueOf(mapOfFieldNameToValue.get(newField.fieldPath)).split('-');
                        newField.value = String.valueOf(Date.parse(tempList[1] + '/' + tempList[2] + '/' + tempList[0]));  
                    }
                }
                else{
                    if(mapOfFieldNameToValue.get(newField.fieldPath) != null){
                        newField.value = String.valueOf(mapOfFieldNameToValue.get(newField.fieldPath));
                    }
                }
                System.debug('newField : ' + newField);
                System.debug('newField value : ' + newField.value);
            }
            if(field.getRequired()){
                newField.isRequired = true;
                System.debug('required Field : ' + field);
            }
            fs.add(newField);
        }
        return fs;
    }
    
    @AuraEnabled
    public static String getPriceBook(String selectedAccountId){ 
        String priceBook = '';
        for(gii__AccountAdd__c accountRef : [SELECT Id, gii__SupplierPriceBook__c, gii__PriceBookName__c, gii__Account__c FROM gii__AccountAdd__c WHERE gii__Account__c =: selectedAccountId LIMIT 1]){
            priceBook = accountRef.gii__SupplierPriceBook__c;
            System.debug('accountRef : ' + accountRef);
            System.debug('accountRef supplier price book : ' + accountRef.gii__SupplierPriceBook__c);
        }
        
        if(priceBook == null)
            priceBook = 'Standard';
        
        return priceBook;
    }
}