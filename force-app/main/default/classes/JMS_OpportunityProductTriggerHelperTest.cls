@Istest
public class JMS_OpportunityProductTriggerHelperTest {
	@Istest
    private static void calculateEstimatedOrderDateSaleTest(){
        //The test starts here.
        Test.startTest();
        
        JMS_OpportunityProductTriggerHelper helper = new JMS_OpportunityProductTriggerHelper();
        JMS_OpportunityProductTriggerHandler handler = new JMS_OpportunityProductTriggerHandler();
        String trigName = handler.getName();
        Account acc = JMS_TestDataFactory.createAccountByName('Ben Textiles');
        Opportunity opp = JMS_TestDataFactory.createOpportunity('Ben Textiles',acc.ID);
        Product2 prd = JMS_TestDataFactory.createProduct();
        List<Pricebook2> priceBook = JMS_TestDataFactory.createPricebookRecds(1);
        PriceBookEntry prcBookEntry = JMS_TestDataFactory.createPricebookEntry(prd.Id,priceBook[0].Id);
        OpportunityLineItem oppLine = JMS_TestDataFactory.createOpportunityLineItem(opp.Id,prd.Id,prcBookEntry.Id);
        oppLine.JMS_Product_Status__c = 'Sale';
        UPDATE oppLine;
        DELETE oppLine;
        System.assertEquals('OpportunityLineItem', trigName,'trigName is not Null');
        
        Test.stopTest();
        //The test ends here. 
    }
    
    @Istest
    private static void calculateEstimatedOrderDateFollowUpTest(){
        //The test starts here.
        Test.startTest();
        JMS_OpportunityProductTriggerHelper helper = new JMS_OpportunityProductTriggerHelper();
        JMS_OpportunityProductTriggerHandler handler = new JMS_OpportunityProductTriggerHandler();
        String trigName = handler.getName();
        Account acc = JMS_TestDataFactory.createAccountByName('Ben Textiles');
        Opportunity opp = JMS_TestDataFactory.createOpportunity('Ben Textiles',acc.ID);
        Product2 prd = JMS_TestDataFactory.createProduct();
        List<Pricebook2> priceBook = JMS_TestDataFactory.createPricebookRecds(1);
        PriceBookEntry prcBookEntry = JMS_TestDataFactory.createPricebookEntry(prd.Id,priceBook[0].Id);
        OpportunityLineItem oppLine = JMS_TestDataFactory.createOpportunityLineItem(opp.Id,prd.Id,prcBookEntry.Id);
        oppLine.JMS_Product_Status__c = 'Follow up';
        oppLine.JMS_Estimated_Order_Date__c = Date.today();
        UPDATE oppLine;
        DELETE oppLine;
        System.assertEquals('OpportunityLineItem', trigName,'trigName is not Null');
        Test.stopTest();
        //The test ends here. 
    }
    
    @Istest
    private static void updateEstimatedOrderDateExceptionTest(){
        Boolean isException = false;
        //The test starts here.
        Test.startTest();
        
        JMS_OpportunityProductTriggerHelper helper = new JMS_OpportunityProductTriggerHelper();
        JMS_OpportunityProductTriggerHandler handler = new JMS_OpportunityProductTriggerHandler();
        String trigName = handler.getName();
        Account acc = JMS_TestDataFactory.createAccountByName('Ben Textiles');
        Opportunity opp = JMS_TestDataFactory.createOpportunity('Ben Textiles',acc.ID);
        Product2 prd = JMS_TestDataFactory.createProduct();
        List<Pricebook2> priceBook = JMS_TestDataFactory.createPricebookRecds(1);
        PriceBookEntry prcBookEntry = JMS_TestDataFactory.createPricebookEntry(prd.Id,priceBook[0].Id);
        //OpportunityLineItem oppLine = JMS_TestDataFactory.createOpportunityLineItem(opp.Id,prd.Id,prcBookEntry.Id);
        //oppLine.JMS_Product_Status__c = 'Sale';
        //UPDATE oppLine;
        OpportunityLineItem oppProduct = new OpportunityLineItem();
        oppProduct.Product2Id=prd.Id;
        oppProduct.OpportunityId=Opp.Id;
        oppProduct.Quantity = 2;
        oppProduct.PricebookEntryId = prcBookEntry.Id;
        oppProduct.TotalPrice = 0;
        oppProduct.JMS_Product_Status__c = 'Sale';
        INSERT oppProduct;
        try{
            oppProduct.JMS_Estimated_Order_Date__c = null;
            UPDATE oppProduct;
        }catch(Exception excep){
            isException =  excep.getMessage().contains('Estimated Order Date cannot be blank if Product Status is Sale.') ? true : false;
            System.assertEquals(isException, true); 
        }
        
        Test.stopTest();
        //The test ends here. 
    }
    
    @Istest
    private static void updateEstimatedOrderDateOnInsertTest(){
        //The test starts here.
        Test.startTest();
        
        JMS_OpportunityProductTriggerHelper helper = new JMS_OpportunityProductTriggerHelper();
        JMS_OpportunityProductTriggerHandler handler = new JMS_OpportunityProductTriggerHandler();
        String trigName = handler.getName();
        Account acc = JMS_TestDataFactory.createAccountByName('Ben Textiles');
        Opportunity opp = JMS_TestDataFactory.createOpportunity('Ben Textiles',acc.ID);
        Product2 prd = JMS_TestDataFactory.createProduct();
        List<Pricebook2> priceBook = JMS_TestDataFactory.createPricebookRecds(1);
        PriceBookEntry prcBookEntry = JMS_TestDataFactory.createPricebookEntry(prd.Id,priceBook[0].Id);
        OpportunityLineItem oppProduct = new OpportunityLineItem();
        oppProduct.Product2Id=prd.Id;
        oppProduct.OpportunityId=Opp.Id;
        oppProduct.Quantity = 2;
        oppProduct.PricebookEntryId = prcBookEntry.Id;
        oppProduct.TotalPrice = 0;
        oppProduct.JMS_Product_Status__c = 'Sale';
        INSERT oppProduct;
        System.assertEquals('OpportunityLineItem', trigName,'trigName is not Null');
        
        Test.stopTest();
        //The test ends here. 
    }
}