trigger giic_SalesQuoteLineTrigger on gii__SalesQuoteLine__c (after insert) {
    
    /*if(trigger.isinsert){
        set<id> SalesQuoteId = new set<id>();
        for(gii__SalesQuoteLine__c SQLRecord : trigger.new){
            if(SQLRecord.gii__SalesQuote__c != null){
                  SalesQuoteId.add(SQLRecord.gii__SalesQuote__c);
            }
          
        }
        
        if(SalesQuoteId.size()> 0){
            delete [select id , gii__SalesQuote__c from gii__SalesQuoteLine__c where gii__SalesQuote__c =: SalesQuoteId];
        }
    }*/

}