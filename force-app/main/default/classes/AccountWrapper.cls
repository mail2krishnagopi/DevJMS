public class AccountWrapper {
 @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String BillingStreet;
        @AuraEnabled public String BillingCity;
        @AuraEnabled public String BillingPostalCode;
        @AuraEnabled public String BillingState;
        @AuraEnabled public String BillingCountry;
        @AuraEnabled public String ShippingStreet;
        @AuraEnabled public String ShippingCity;
        @AuraEnabled public String ShippingPostalCode;
        @AuraEnabled public String ShippingState;
        @AuraEnabled public String ShippingCountry; 
        @AuraEnabled public String Phone; 
        @AuraEnabled public String warehouseName; 
        @AuraEnabled public Decimal TaxAmt;
        @AuraEnabled public List<ProductWrapper> prodList;
        
        public AccountWrapper(){ 
            this.Id = '';
            this.Name = '';
            this.BillingStreet = '';
            this.BillingCity = '';
            this.BillingPostalCode = '';
            this.BillingState = '';
            this.BillingCountry = '';
            this.ShippingStreet = '';
            this.ShippingCity = '';
            this.ShippingPostalCode = '';
            this.ShippingState = '';
            this.ShippingCountry = ''; 
            this.Phone = '';
            this.warehouseName = '';
            this.TaxAmt = 0;            
            this.prodList = new List<ProductWrapper>();
        }
}