public class giic_MockHttpResponsegeneratePDF implements HttpCalloutMock {
        private Attachment attachment;
        
        public giic_MockHttpResponsegeneratePDF(Attachment attachment) {
            this.attachment = attachment;
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBodyAsBlob(this.attachment.Body);
            return response;
        }
}