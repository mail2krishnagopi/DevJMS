public class ProductWrapper {
    @AuraEnabled public Boolean isSelected; 
    @AuraEnabled public Boolean isFavProduct;
    @AuraEnabled public String priceBookEntryId; 
    @AuraEnabled public String Id;
    @AuraEnabled public String ProductId;    
    @AuraEnabled public String ProductName;
    @AuraEnabled public String ProductCode;
    @AuraEnabled public Decimal UnitPrice;  
    @AuraEnabled public String ProductFamily;  
    @AuraEnabled public String PriceBookName;
    @AuraEnabled public String Description;
    @AuraEnabled public Integer OrderQuantity;
    @AuraEnabled public String ProductImageId;
    @AuraEnabled public String ProdNameInitial;
    @AuraEnabled public Boolean addToCart;
    @AuraEnabled public String OrganizationId;
  //  @AuraEnabled public String CurrencySymbol;
    
    public ProductWrapper(){ 
        this.isSelected     = false;
        this.isFavProduct   = false;    
        this.ProductId      = '';
        this.ProductName    = '';
        this.ProductCode    = '';
        this.UnitPrice      = 0.0;
        this.ProductFamily  = '';
        this.PriceBookName  = '';
        this.Description    = ''; 
        this.ProdNameInitial= '';
        this.OrderQuantity  = 0;
        this.ProductImageId = '';
        this.addToCart      = false;
        this.Id      = '';
        this.OrganizationId = UserInfo.getOrganizationId();
      //  this.CurrencySymbol = CommonUtil.getCurrencySymbol(new gii__PriceBookEntry__c());
    }        
}