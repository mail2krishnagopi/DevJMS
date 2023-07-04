@IsTest
public class giic_getFedexOauthTokenTest {

     @IsTest
    static void testGetAccessToken() {
        // Create a test instance of the custom metadata type
        giic_JMSIntegrationMapping__mdt jmsIntAttr = new giic_JMSIntegrationMapping__mdt(
            giic_OAUTH_Endpoint__c = 'https://example.com/oauth/token',
            giic_CLIENT_KEY__c = 'testClientId',
            giic_CLIENT_SECRET__c = 'testClientSecret'
        );
        
        // Create a mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"access_token": "testAccessToken"}');
        
        // Create a mock HTTP class and set the mock response
        Test.setMock(HttpCalloutMock.class, new giic_MockHttpResponseGeneratorTest(mockResponse));
        
        // Call the getAccessToken method in the test context
        Test.startTest();
        String token = giic_getFedexOauthToken.getAccessToken(jmsIntAttr);
        Test.stopTest();
        
        // Verify the access token
        System.assertEquals('testAccessToken', token);
        
    }
}