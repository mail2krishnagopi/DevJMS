public class giic_HistoricalDemandQntCalBatchExecute {
    
    public giic_HistoricalDemandQntCalBatchExecute(ApexPages.StandardSetController controller) {
    }
   
    public PageReference runBatch() {
        giic_HistoricalDemandQntCalHandlerBatch objBatch = new giic_HistoricalDemandQntCalHandlerBatch();
        database.executeBatch(objBatch);
        PageReference orderPage = new PageReference(System.label.giic_Product_Invetory);
        orderPage.setRedirect(true);
        return orderPage;

    } 

}