public class ProcessStepsWrapper {
    @AuraEnabled public Boolean Active;
    @AuraEnabled public String Process;
    @AuraEnabled public String Page_Name;
    @AuraEnabled public String Step_Name;
    @AuraEnabled public Decimal Step_Number;
    
    public ProcessStepsWrapper(){
        Active = false;
        Process = '';
        Page_Name = '';
        Step_Number =0;
    } 
}