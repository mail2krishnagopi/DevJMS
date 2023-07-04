global class giic_BookingConfirmationMockTest implements HttpCalloutMock {
    
     private Integer statusCode;
    private String statusReason;
    private String responseBody;

    public giic_BookingConfirmationMockTest(Integer statusCode, String statusReason, String responseBody) {
        this.statusCode = statusCode;
        this.statusReason = statusReason;
        this.responseBody = responseBody;
    }

    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setStatus(statusReason);
        response.setBody(responseBody);
        return response;
    }
    
    /*global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint() == 'https://testblobstorageaccess.azurewebsites.net/api/token'){
            res.setBody('eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2NTQxMDAzMzUsInVzZXJuYW1lIjoiZjdFWjh0aEpKZ1hjTUh6ejVncG1ITXg0cEVZRkVYdVgifQ.obVI_NVqKImQ3cerFU8sePZOvQ6cHm-39LvEkwvui2k');
        }else if(req.getEndpoint().Contains('https://testblobstorageaccess.azurewebsites.net/api/BlobFileUrl')){
            res.setBody('https://emailarchival.blob.core.windows.net/communication-email-storage/520000180_5109725_20_1_1164174882.html?sv=2021-04-10&se=2022-06-01T15%3A24%3A30Z&sr=b&sp=r&sig=xVZr3ZkKG%2B166GWghRGuhxX5yV2e4Vvtsas2gXTnPRI%3D');
        }
        res.setStatusCode(200);
        return res;
        
        // Create a fake response.
        // Set response values, and 
        // return response.
    }    */
}