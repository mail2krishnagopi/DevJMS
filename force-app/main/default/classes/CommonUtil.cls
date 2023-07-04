public class CommonUtil {
    public static List<String> getPicklistOptions( String objectName, String fieldName ) {         
        List<String> options = new List<String>();        
        for ( PicklistEntry entry : Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap().get( fieldName ).getDescribe().getPicklistValues() ) {
            options.add(entry.getValue());
        }        
        return options;
    }
    
    public static Map<String, String> getFieldLables(String sobjectAPI, Set<String> setFieldAPI) {
        Map<String, String> mapLables = new Map<String, String>();
        Map<String, SObjectField> fieldMapPOReceipt = Schema.getGlobalDescribe().get(sobjectAPI).getDescribe().fields.getMap();
        for(String fieldAPI : setFieldAPI ){
            Schema.SObjectField field = fieldMapPOReceipt.get(fieldAPI); 
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();            
            mapLables.put(fieldAPI, fieldDescribe.getLabel());
        }
        return mapLables;
    }
    
    public static Map<String, String> getAccountLables() {
        Set<String> setFieldAPI = new Set<String>{'Name', 'BillingAddress', 'ShippingAddress', 'Phone', 'ShippingCountry'};
            return getFieldLables('Account', setFieldAPI);
    }
    public static Map<String, String> getAccountRefLables() {
        Set<String> setFieldAPI = new Set<String>{'Name', 'gii__PaymentMethod__c', 'gii__BankAccountNumber__c', 'gii__BankName__c'};
            return getFieldLables('gii__AccountAdd__c', setFieldAPI);
    } 
    public static Map<String, String> getSalesOrderLineLables() {
        Set<String> setFieldAPI = new Set<String>{'Name', 'gii__Product__c', 'gii__UnitPrice__c', 'gii__OrderQuantity__c', 'gii__ProductAmount__c', 
            'gii__DiscountPercent__c', 'gii__TotalAmount__c', 'gii__NetAmount__c'};
            return getFieldLables('gii__SalesOrderLine__c', setFieldAPI);
    }
}