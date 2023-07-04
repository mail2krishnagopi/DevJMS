public class giic_getPLSOauthToken {
    
    public static string getAuthorizationToken() {
         JMS_Integration_Setting__c jmsIntAttr = JMS_Integration_Setting__c.getInstance();        
        //getting data from custom settings
        String OAUTH_ENDPOINT = jmsIntAttr.giic_PLSOAUTHEndpoint__c;             
        String CLIENT_ID = jmsIntAttr.giic_PLSCLIENTKEY__c;           
        String CLIENT_SECRET = jmsIntAttr.giic_PLSCLIENTSECRET__c;
        String USERNAME = jmsIntAttr.giic_PLSUSERNAME__c;
        String PASSWORD = jmsIntAttr.giic_PLSPASSWORD__c;
       // system.debug('###::'+jmsIntAttr.giic_PLSPASSWORD__c);
        //system.debug('###::'+giic_PLSPASSWORD__c);
        //system.debug('###::'+giic_PLSPASSWORD__c);
        /*    
        // OAuth endpoint
        String OAUTH_ENDPOINT = 'http://ltl.uat.plsthree.pro/restful/oauth/token';
        
        // OAuth client credentials
        String CLIENT_ID = '7e9914a3a73265593ec0fd4450b90ee56119851817d82b7de64bbaf16b5f5834';
        String CLIENT_SECRET = '5c53566862c23bc57e9b0c5c0ac3f54408faf994956d1fd15788f93211270bb5';
        
        // User credentials
        String USERNAME = 'gloviaapi';
        String PASSWORD = 'P96FSZ1daJ5da2h';*/
        
        // OAuth grant type
        String GRANT_TYPE = 'password';
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(OAUTH_ENDPOINT);
        request.setMethod('POST');
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(CLIENT_ID + ':' + CLIENT_SECRET));
        request.setHeader('Authorization', authHeader);
        String body = 'grant_type=' + GRANT_TYPE + '&username=' + USERNAME + '&password=' + PASSWORD;
        request.setBody(body);
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        system.debug('###::'+responseMap);
        system.debug('Token' + (String) responseMap.get('access_token'));
        return (String) responseMap.get('access_token');
        
    }
    
    
}