/* @uthor : Sunil Rathore
* Description: This class will be used as a extension of the vf page and it will execute the batch class
* Task number: 2975
*/
public class giic_DemandOrdCreationBatchExecute {
    public giic_DemandOrdCreationBatchExecute(ApexPages.StandardSetController controller) {
    }
    public PageReference runBatch() {
        giic_DemandOrderCreationBatch objBatch = new giic_DemandOrderCreationBatch();
        database.executeBatch(objBatch);
        PageReference orderPage = new PageReference(System.label.giic_DemandOrderURL);
        orderPage.setRedirect(true);
        return orderPage;

    } 
}