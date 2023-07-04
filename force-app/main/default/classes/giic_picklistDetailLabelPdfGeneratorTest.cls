@isTest(SeeAllData=true) 
public class giic_picklistDetailLabelPdfGeneratorTest {
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            // Generate a mock PDF
            Blob mockPdf = generateMockPdf();
            
            // Create a mock HTTPResponse with the PDF as content
            HTTPResponse mockResponse = new HTTPResponse();
            mockResponse.setBodyAsBlob(mockPdf);
            mockResponse.setStatusCode(200);
            
            return mockResponse;
        }
    }
    
    // Generate a mock PDF
    private static Blob generateMockPdf() {
        // Mock PDF generation logic goes here
        // Return a sample PDF content as Blob
        String mockPdfContent = 'Mock PDF Content';
        return Blob.valueOf(mockPdfContent);
    }
    
    @isTest static void PDFGeneratorTest(){
        
        list<gii__PickList__c> picklistRecs = [select id,Name from gii__PickList__c limit 1 ];
        system.debug('picklistRecs#####:: '+picklistRecs);
        List<gii__PickListDetail__c> picklistDetailList =[select id,name,gii__Product__r.giic_Picklist_Detail_Barcode_Image__c,
                                                          giic_Picklist_Detail_Barcode_Image__c,gii__Product__r.gii__Description__c,
                                                          gii__Product__r.gii__PrimarySupplier__r.name,gii__SalesOrder__r.name,
                                                          gii__TransferOrder__r.name from gii__PickListDetail__c where gii__PickList__r.id= :picklistRecs[0].id];
        List<ID> recordIds = new List<ID>();
        for(gii__PickListDetail__c eachPickDetail:picklistDetailList){
            recordIds.add(eachPickDetail.id);                
        }
        
        
        if (!picklistRecs.isEmpty()) {
            gii__PickList__c picklistRec = picklistRecs[0];
            
            // Create test data related to the existing data
            gii__PickListDetail__c picklistDetail = new gii__PickListDetail__c();
            picklistDetail.gii__PickList__c = picklistRec.Id;
            // Set required fields and any other necessary fields for the picklist detail record
            insert picklistDetail;
             
            Blob mockPdf = generateMockPdf();
            Attachment attachmentPDF = new Attachment();
        attachmentPDF.parentId = picklistRecs[0].Id;
        attachmentPDF.Name = picklistRecs[0].Name + ' Label.pdf';
        attachmentPDF.body = mockPdf;
        insert attachmentPDF;
        System.debug('Attachment ID: ' + attachmentPDF.Id);
            
            // Call the method to test
            Test.startTest();
            // Generate a mock PageReference object
            PageReference pageRef = Page.giic_generatePDFLabel;
            // Set the parameters on the mock PageReference object
            pageRef.getParameters().put('ids', String.valueOf(picklistDetail.Id));
            
            // Get the content of the Visualforce page as a string
            //  String pageContent = Test.getContent(pageRef).toString();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            giic_picklistDetailLabelPdfGenerator.PDFGenerator(picklistRecs[0].id);
            
            Test.stopTest();
            
        } 
        
        
    }
}