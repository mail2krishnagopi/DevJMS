public class FieldSetMember {
    
    public FieldSetMember(Schema.DescribeFieldResult f) {
        this.fieldPath = f.getName();
        this.label = f.getLabel();
        this.type = '' + f.getType();
        this.readOnly = !f.isAccessible();
        this.isRequired = false;
        this.value = '';
        if(!f.getReferenceTo().isEmpty())
            this.referenceTo = String.valueOf(f.getReferenceTo()[0]);
        System.debug('label : ' + this.label);
        System.debug('fieldPath : ' + this.fieldPath);
        System.debug('type : ' + this.type);
        System.debug('referenceTo : ' + this.referenceTo);
        System.debug('required : ' + this.isRequired);
        System.debug('');
    } 
    public FieldSetMember() {
        this.fieldPath = '';
        this.label = '';
        this.type = '';
        this.readOnly = false;
        this.isRequired = false;
        this.value = '';
        this.referenceTo = '';
    } 

    @AuraEnabled
    public String referenceTo {get;set;}
    @AuraEnabled
    public Boolean readOnly {get;set;}
    @AuraEnabled
    public Boolean isRequired {get;set;}
    @AuraEnabled
    public String fieldPath {get;set; }
    @AuraEnabled
    public String label {get;set; }
    @AuraEnabled
    public String type {get;set;}
    @AuraEnabled
    public String value {get;set;}
}