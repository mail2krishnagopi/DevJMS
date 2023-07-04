public class giic_getFedexOauthToken {
    
    public static string getAccessToken(giic_JMSIntegrationMapping__mdt jmsIntAttr) {
        
    
        String ENDPOINT = jmsIntAttr.giic_OAUTH_Endpoint__c;  // FedEx authorization API endpoint           
        String CLIENT_ID = jmsIntAttr.giic_CLIENT_KEY__c;       // JMS FedEx client ID    
        String CLIENT_SECRET = jmsIntAttr.giic_CLIENT_SECRET__c; // JMS FedEx client secret
        
        // Build the request body
        String requestBody = 'grant_type=client_credentials&client_id=' + CLIENT_ID + '&client_secret=' + CLIENT_SECRET;
        
        // Create the HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);
        
        // Send the HTTP request
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Parse the response body and extract the token
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        String token = (String)responseBody.get('access_token');
        
        system.debug('token' + token);
        
        return token;
        
    }    
}