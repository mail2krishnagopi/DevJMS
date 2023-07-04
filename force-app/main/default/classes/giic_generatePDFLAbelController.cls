public class giic_generatePDFLAbelController {
    
    public List<gii__PickListDetail__c> myObjects { get; set; }
    public List<Attachment>  AttachmentList { get; set; }
    public giic_generatePDFLAbelController() {
        String idsParam = ApexPages.currentPage().getParameters().get('ids');
        List<Id> recordIds = idsParam.split(',');
        myObjects = [select id,name,gii__Product__r.giic_Picklist_Detail_Barcode_Image__c,
                     gii__Product__r.gii__ProductBarcode__c,gii__Product__r.giic_BarCodeImage__c,
                     giic_Picklist_Detail_Barcode_Image__c,gii__Product__r.gii__Description__c
                     ,gii__Product__r.gii__PrimarySupplier__r.name,
                     gii__SalesOrder__r.name,gii__TransferOrder__r.name,
                     (select id from Attachments)  from gii__PickListDetail__c WHERE Id IN :recordIds];
        
        for (gii__PickListDetail__c result : myObjects) {
            if(result.Attachments!=null){
                AttachmentList =result.Attachments;
            }
        }
        system.debug('myObjects' + myObjects);
    }
}