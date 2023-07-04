@isTest
public class giic_ShipmentHelperMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        String body = '{"soNum":"SO-20221111-000007","shipmentNo":"SHP-20221116-000003","poNum":"PO4252023","pickupDate":"2022-11-16","originAddress":{"stateCode":"NJ","postalCode":"08512","name":"E & S - JMS CRANBURY NJ","countryCode":"USA","contactPhone":"1234567890","contactName":"Adam Kamerer","city":"Cranbury","addressCode":"a5c3C0000003bXrQAI","address1":"20 Haypress Rd Ste 322"},"materials":[{"width":4,"weightUnit":"LBS","weight":4,"quantity":1,"productDescription":"This is for Shipment","packagingType":"CAS","length":3,"height":3,"hazmat":false,"dimensionUnit":"INCH","commodityClass":"50"}],"destinationAddress":{"stateCode":"FL","postalCode":"33467","name":"PALOMINO GARDENS","countryCode":"USA","contactPhone":"1234567890","contactName":"Adam Kamerer","city":"Lake Worth","addressCode":"a4i3C000000YSAlQAO","address1":"9885 Palomio Dr"},"accessorialTypes":["REP"]}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode(200);
        return response; 
    }
}