public class giic_MockHttpResponseGeneratorTest implements HttpCalloutMock {
    private HttpResponse mockResponse;
    
    public giic_MockHttpResponseGeneratorTest(HttpResponse mockResponse) {
        this.mockResponse = mockResponse;
    }
    
    public HttpResponse respond(HttpRequest request) {
        return mockResponse;
    }
}