public class ProductAdvancedFilter {
    @AuraEnabled public String Family;
    @AuraEnabled public String ProductCode;
    @AuraEnabled public String MerchandiseType;
    @AuraEnabled public String Size;
    @AuraEnabled public String Color;
    
    public ProductAdvancedFilter(){
        this.Family =   '';
        this.ProductCode =   '';
        this.MerchandiseType =   '';
        this.Size =   '';
        this.Color =   '';
    }
}