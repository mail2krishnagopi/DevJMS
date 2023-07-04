public class JMS_Product2TriggerHelper {
    //Constructor Declared
    @testvisible
    private JMS_Product2TriggerHelper(){
        
    }
    //Final variable decalaration
    private static Final Integer DEFAULT_PRICE = 0;
    private static final String PRODUCT2_API = 'Product2';
    private static final String STR_DEFAULT_ACTIVE_PRODUCT = 'defaultActiveProduct';
    private static final String STR_CREATE_PRICEBOOK_ENTRY = 'createPriceBookEntry';
    
     /**
    * @description : This method is used for creating Price Book Entry with creation of Product
    * @param       : List<SObject> newItems
    * @author      : Sumit
    * @date        : 09/03/2022
    */
    public static void createPriceBookEntry(List<SObject> newItems) {
        //variable declaration
        Product2 newProduct2Rec;
        List<priceBookEntry> priceBookEntryList= new List<priceBookEntry>();
        try{
            //Query Standard Pricebook record from database
            List<Pricebook2> pricebookList = [SELECT Id FROM Pricebook2 WHERE isActive = TRUE AND isStandard = TRUE  LIMIT 1];
            
            if(test.isRunningTest() ){
                Pricebook2 newpriceBook = new Pricebook2(Id = Test.getStandardPricebookId());
                pricebookList.add(newpriceBook);
            }
            
            if(!newItems.isEmpty()) {
                for(SObject product: newItems){
                    newProduct2Rec = (Product2)product;
                    if(!pricebookList.isEmpty() && newProduct2Rec.IsActive == TRUE) {
                        for(Pricebook2 priceBook : pricebookList) {
                            PriceBookEntry priceBkEntry = new PriceBookEntry();
                            priceBkEntry.Product2Id = newProduct2Rec.Id;
                            priceBkEntry.Pricebook2Id= priceBook.Id;
                            priceBkEntry.IsActive = TRUE;
                            priceBkEntry.UnitPrice = DEFAULT_PRICE;
                            priceBkEntry.UseStandardPrice = FALSE;
                            //Adding new price book entry to a list 
                            priceBookEntryList.add(priceBkEntry);   
                        }  
                    }
                }   
            }
            //Insert Pricebook Entry records
            if(!priceBookEntryList.isEmpty()){
                INSERT priceBookEntryList;
            }
        }catch(Exception excep){
            JMS_Logger.push(STR_CREATE_PRICEBOOK_ENTRY, PRODUCT2_API);
			JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }
    }

    /**
    * @description : This method is usedfor making isActive to true by before insert
    * @param       : List<SObject> newItems
    * @author      : Sumit
    * @date        : 05/04/2022
    */
    public static void defaultActiveProduct(List<SObject> newItems) {
        //Variable Declaration
        List<Product2> listNewProduct = (List<Product2>) newItems;
        try{
            if(!listNewProduct.isEmpty() && listNewProduct != Null){
                for(Product2 prod : listNewProduct){
                    prod.IsActive = TRUE;
                }
        	}
        }catch(Exception excep){
            JMS_Logger.push(STR_DEFAULT_ACTIVE_PRODUCT, PRODUCT2_API);
			JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        }
    }
    
    /**
    * @description : This method is used for populating the Item Number
    * @param       : List<SObject> newItems
    * @author      : Sachin
    * @date        : 05/04/2022
    */
    public static void updateProduct(List<SObject> newItems) {
        
        List<Product2> prodRecList = (List<Product2>)newItems;
        for(Product2 prdRec : prodRecList){
            if(string.isNotBlank(prdRec.JMS_AWS_External_Id__c) && string.isBlank( prdRec.StockKeepingUnit)){
                prdRec.StockKeepingUnit = prdRec.JMS_AWS_External_Id__c;
            }
            
        }
        
    }
}