//This is a test class for JMS_Product2TriggerHelper class.
@Istest
private class JMS_Product2TriggerHelperTest {
    //This is a test method.
    @IsTest
    private static void creatingPriceBookEntriesTest(){
        //The test starts from here.
        Test.startTest();
        JMS_Product2TriggerHelper helper = new JMS_Product2TriggerHelper();
        JMS_Product2TriggerHandler handler = new JMS_Product2TriggerHandler();
        String trigName = handler.getName();
        Product2[] newProduct = JMS_TestDataFactory.createProductRecds(1);
        //These are the DML Operations.
        Update newProduct;
        Delete newProduct;
        UnDelete newProduct;
        System.assertEquals('Product2', trigName,'trigName is not Null');
        System.assertEquals(1, newProduct.size() ,'Product array not null');
        Test.stopTest();
        //The test ends here.
    }
    
}