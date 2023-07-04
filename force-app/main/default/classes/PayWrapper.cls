public class PayWrapper {
    @AuraEnabled public String Id;
    @AuraEnabled public String DefaultPaymentMethod;
    @AuraEnabled public String SelectedPaymentMethod;
    @AuraEnabled public String BankName;
    @AuraEnabled public String BankAccNumber;  
    @AuraEnabled public List<String> ListCardType;
    @AuraEnabled public String SelectedCardType;
    @AuraEnabled public String NameOnCard;
    @AuraEnabled public String NumberOnCard;
    @AuraEnabled public String CVV;
    @AuraEnabled public String ExpiryMonth;
    @AuraEnabled public List<String> ListExpiryMonth;
    @AuraEnabled public String ExpiryYear;
    @AuraEnabled public  Map<String, String> mapAccRefFieldLables;
    public PayWrapper(){
        this.Id = '';
        this.DefaultPaymentMethod = '';
        this.SelectedPaymentMethod = '';
        this.BankName = '';
        this.BankAccNumber = '';
        this.ListCardType = Label.SOCardTypes.split(',');
        this.SelectedCardType = '';
        this.NameOnCard = '';
        this.NumberOnCard = '';
        this.CVV = '';
        this.ExpiryMonth='';
        this.ListExpiryMonth = Label.SOMonths.split(',');
        this.ExpiryYear = '';
        this.mapAccRefFieldLables = CommonUtil.getAccountRefLables();
    }
}