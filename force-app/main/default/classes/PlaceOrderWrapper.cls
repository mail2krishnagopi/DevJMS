public class PlaceOrderWrapper{
    
    @AuraEnabled public AccountWrapper parentAcc;
    @AuraEnabled public  List<AccountWrapper> lstChild;
    @AuraEnabled public  Map<String, String> mapAccFieldLables;
    @AuraEnabled public  Map<String, String> mapAccRefFieldLables;
    @AuraEnabled public  Map<String, String> mapSOLFieldLables;
    
    public PlaceOrderWrapper(){
        this.parentAcc = new AccountWrapper();
        this.lstChild = new List<AccountWrapper>();
        this.mapAccFieldLables = CommonUtil.getAccountLables();
        this.mapAccRefFieldLables = CommonUtil.getAccountRefLables();
        this.mapSOLFieldLables = CommonUtil.getSalesOrderLineLables();
    }        
}