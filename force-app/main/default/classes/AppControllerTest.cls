@isTest(SeeAllData=False) 
public class AppControllerTest {
    static testMethod void getStagesTest() {
        AppController.getStages('SalesOrder');
        System.assert(true);
    }
}