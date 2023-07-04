public with sharing class giic_picklistDetailLabelPdfGenerator
{
    /*   public static final String FORM_HTML_START = '<HTML><BODY>';
public static final String FORM_HTML_END = '</BODY></HTML>';

public static void PDFGenerator1(gii__PickList__c picklistrec)
{
List<gii__PickListDetail__c> picklistDetailList = new List<gii__PickListDetail__c>();      
picklistDetailList = [select id,name,gii__Product__r.gii__ProductBarcode__c,giic_Picklist_Detail_Barcode_Image__c,gii__Product__r.gii__Description__c,gii__Product__r.gii__PrimarySupplier__r.name,gii__SalesOrder__r.name,gii__TransferOrder__r.name from gii__PickListDetail__c where gii__PickList__r.id= :picklistrec.id];


String pdfContent = '' + FORM_HTML_START;

try
{
pdfContent = '' + FORM_HTML_START;


//Dynamically grab all the fields to store in the PDF
Map<String, Schema.SObjectType> sobjectSchemaMap = Schema.getGlobalDescribe();
Schema.DescribeSObjectResult objDescribe = sobjectSchemaMap.get('gii__PickList__c').getDescribe();
Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();


//Manogna Start
system.debug('+++ pdf content v1'+pdfContent);
system.debug('+++ picklistDetailList size'+picklistDetailList.size());
if(picklistDetailList.size()>0){
for(gii__PickListDetail__c eachPickDetail:picklistDetailList){
system.debug('+++ pdf content v2'+pdfContent);
pdfContent = pdfContent + '<P>' + '<b>Product Barcode</b>'+'</P>';
// pdfContent = pdfContent + '<P>' + eachPickDetail.giic_Picklist_Detail_Barcode_Image__c + '</P>';
//Prashanth Code start
Pattern p = Pattern.compile('<img[^>]+src="(.*?)"');
Matcher m = p.matcher(eachPickDetail.giic_Picklist_Detail_Barcode_Image__c);
String imgUrl;
if (m.find()) {
imgUrl = m.group(1);    
}
system.debug('imgUrl=='+imgUrl);
PageReference pageRef = new PageReference(imgUrl.replace('&amp;', '&'));
String eid = pageRef.getParameters().get('eid');
String refid = pageRef.getParameters().get('refid');
system.debug('eid===='+eid);
system.debug('refid===='+refid);
Http http = new Http();
HttpRequest request = new HttpRequest();
String sessionId = UserInfo.getSessionId();
String objectAPI = 'gii__PickListDetail__c';
String richtextFieldAPI = 'giic_Picklist_Detail_Barcode_Image__c';
request.setHeader('Authorization', ('Bearer '+UserInfo.getSessionId()));
request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v57.0/sobjects/'+objectAPI+'/'+ eid + '/richTextImageFields/'+richtextFieldAPI+'/'+ refid );
request.setMethod('GET');
HttpResponse response = http.send(request);
system.debug('+++res'+response.getBody());
system.debug('+++enocoded res'+EncodingUtil.Base64Encode(response.getBodyAsBlob()));
pdfContent = pdfContent + '<P>' + '<b>Product Barcode</b>'+'</P>';
pdfContent = pdfContent + '<P>' + EncodingUtil.Base64Encode(response.getBodyAsBlob()) + '</P>';
//Prashanth code end

pdfContent = pdfContent + '<P>' + '<b>Product Description</b>' + '</P>';
pdfContent = pdfContent + '<P>' + eachPickDetail.gii__Product__r.gii__Description__c + '</P>';

pdfContent = pdfContent + '<P>' + '<b>Supplier Name</b>' + '</P>';
pdfContent = pdfContent + '<P>' + eachPickDetail.gii__Product__r.gii__PrimarySupplier__r.name + '</P>';
if(eachPickDetail.gii__SalesOrder__c!=null){
pdfContent = pdfContent + '<P>' + '<b>Sales Order Number</b>' + '</P>';
pdfContent = pdfContent + '<P>' +  eachPickDetail.gii__SalesOrder__r.name + '</P>';
}
else if( eachPickDetail.gii__TransferOrder__c!=null){
pdfContent = pdfContent + '<P>' + '<b>Transfer Order Number</b>' + '</P>';
pdfContent = pdfContent + '<P>' + eachPickDetail.gii__TransferOrder__r.name + '</P>';
}
else{
pdfContent = pdfContent + '<P>' + '<b>Order Number</b>' + '</P>';
}
}
}
//Manogna End

pdfContent = pdfContent + FORM_HTML_END;
system.debug('+++ pdf content v3'+pdfContent);
}catch(Exception e)

{
pdfContent = '' + FORM_HTML_START;
pdfContent = pdfContent + '<P>THERE WAS AN ERROR GENERATING PDF: ' + e.getMessage() + '</P>';
pdfContent = pdfContent + FORM_HTML_END;
}
system.debug('+++ pdf content v4'+pdfContent);
attachPDF(picklistrec,pdfContent);
}  

public static void attachPDF(gii__PickList__c picklistrec, String pdfContent)
{
try
{
Attachment attachmentPDF = new Attachment();
attachmentPDF.parentId = picklistrec.Id;
attachmentPDF.Name = picklistrec.Name +' Label'+ '.pdf';
attachmentPDF.body = Blob.toPDF(pdfContent); //This creates the PDF content
insert attachmentPDF;
system.debug('+++Attachment'+attachmentPDF.id);

}catch(Exception e)
{     
picklistrec.addError(e.getMessage());
}
}

public static string fetchImageUrl(String imageRichText){
Matcher imgMatcher = Pattern.compile( '<img(.+?)>' ).matcher(imageRichText);
String img = '';
while (imgMatcher.find()){                
String imageTag = imgMatcher.group();
img = imageTag.substringBetween(' src="', '"' );
System.debug('img ===>' + img);
}
return img.unescapeHtml4();
}*/
    
    @future(callout=true)
    public static void PDFGenerator(ID recID)
    {
        System.debug('Called PDF Generator ');
        List<gii__PickListDetail__c> picklistDetailList = new List<gii__PickListDetail__c>();  
        gii__PickListDetail__c picklistDetail;
        
        Blob pdfBlob;
        List<ID> recordIds = new List<ID>();
        List<Blob> pdfBlobList = new  List<Blob>();
        picklistDetailList = [select id,name,gii__Product__r.giic_Picklist_Detail_Barcode_Image__c,giic_Picklist_Detail_Barcode_Image__c,gii__Product__r.gii__Description__c,gii__Product__r.gii__PrimarySupplier__r.name,gii__SalesOrder__r.name,gii__TransferOrder__r.name from gii__PickListDetail__c where gii__PickList__r.id= :recID];
        // picklistDetail =[select id,name,gii__Product__r.giic_Picklist_Detail_Barcode_Image__c,gii__Product__r.giic_BarCodeImage__c,giic_Picklist_Detail_Barcode_Image__c,gii__Product__r.gii__Description__c,gii__Product__r.gii__PrimarySupplier__r.name,gii__SalesOrder__r.name,gii__TransferOrder__r.name from gii__PickListDetail__c where gii__PickList__r.id= :recID limit 1];
        gii__PickList__c picklistRec = [select id,name from gii__PickList__c where id =: recID];
        
        
        for(gii__PickListDetail__c eachPickDetail:picklistDetailList){
            recordIds.add(eachPickDetail.id);                
        }
        
        
        // Generate PDF
        PageReference pageRef = Page.giic_generatePDFLabel;
        //pageRef.getParameters().put('id', picklistDetail.Id);
        pageRef.getParameters().put('ids', String.join(recordIds, ','));
        pdfBlob = pageRef.getContentAsPdf();        
        
        Attachment attachmentPDF = new Attachment();
        attachmentPDF.parentId = picklistrec.Id;
        attachmentPDF.Name = picklistrec.Name + ' Label.pdf';
        attachmentPDF.body = pdfBlob;
        insert attachmentPDF;
        System.debug('Attachment ID: ' + attachmentPDF.Id);
        
        /*ContentVersion cv = new ContentVersion();
        cv.VersionData = pdfBlob;
        cv.ContentLocation = 'S';
        cv.Title = picklistRec.Name + ' Label.pdf';
        cv.PathOnClient = 'ionicLogo.pdf';
        //cv.FirstPublishLocationId = recID;
        insert cv;
        
        // First get the content document Id from ContentVersion
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        ContentWorkspace cws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name =: System.Label.giic_Picklist_Barcode_Library LIMIT 1];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        cdl.LinkedEntityId = cws.Id;
        insert cdl;
       */

        
    }
}