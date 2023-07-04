trigger giic_salesOrderTrigger on gii__SalesOrder__c (after insert) {
    Set<Id> parentIds = new Set<Id>();
    
    
    // Collect the parent record IDs
    for (gii__SalesOrder__c child : Trigger.new) {
        parentIds.add(child.gii__SalesQuote__c);
    }
    
    // Query for the parent records
    List<gii__SalesQuote__c> salesQuoteList = [SELECT Id, giic_Converted_as_Sales_Order__c FROM gii__SalesQuote__c WHERE Id IN :parentIds];
    
    // Update the checkbox field on the parent records
 /*   List<gii__SalesQuote__c> salesQuoteToUpdate = new List<gii__SalesQuote__c>();
    for (gii__SalesQuote__c parent : salesQuoteList) {           
            parent.giic_Converted_as_Sales_Order__c = true; // Set the checkbox field value
        salesQuoteToUpdate.add(parent);
    }
    
    // Perform the updates
    if (!salesQuoteToUpdate.isEmpty()) 
        {
            update salesQuoteToUpdate;
        }
      */  
    
}