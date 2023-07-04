public class ProductSearchWrapper {
        @AuraEnabled public Integer resultSize;
        @AuraEnabled public Integer totalItems;
        @AuraEnabled public List<ProductWrapper> prodList;
        @AuraEnabled public List<ProductWrapper> favProdList;
        @AuraEnabled public List<ProductWrapper> topProdList;
        @AuraEnabled public List<String> prodInitials;
        //@AuraEnabled public List<ProductFamilyWrapper> prodFamilyList;
        //@AuraEnabled public List<ProductPackagingWrapper> prodPackagingList;
        //@AuraEnabled public List<ProductTreatmentWrapper> prodTreatmentList;
        @AuraEnabled public ProductAdvancedFilter prodFilter;
    
        public ProductSearchWrapper(){             
            this.resultSize = 0; this.totalItems = 0;
            this.prodList = new List<ProductWrapper>();
            this.favProdList = new List<ProductWrapper>();
            this.topProdList = new List<ProductWrapper>();
            this.prodInitials = new List<String>();
            //this.prodFamilyList = new List<ProductFamilyWrapper>(); 
            //this.prodPackagingList = new List<ProductPackagingWrapper>(); 
            //this.prodTreatmentList = new List<ProductTreatmentWrapper>(); 
            this.prodFilter = new ProductAdvancedFilter();
            // Name => gii__MerchandiseType__c
            // gii__ProductImageId__c => gii__Size__c
            // gii__Revision__c => gii__Color__c
        }
}