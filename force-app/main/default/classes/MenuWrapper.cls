public class MenuWrapper {
    @AuraEnabled public String Title;
    @AuraEnabled public String SubTitle;
    @AuraEnabled public String TabType;
    @AuraEnabled public String URL;
    @AuraEnabled public String TheamCSS;
    @AuraEnabled public String Icon;
    @AuraEnabled public String ListIconSize;
    @AuraEnabled public String TilesIconSize;
    @AuraEnabled public String SelectedTab;
    
    public MenuWrapper(){
        this.Title = '';
        this.SubTitle = '';
        this.TabType = '';
        this.URL = ''; 
        this.TheamCSS = '';
        this.Icon = '';
        this.ListIconSize = '';
        this.TilesIconSize = '';
        this.SelectedTab = '';
    }    
}