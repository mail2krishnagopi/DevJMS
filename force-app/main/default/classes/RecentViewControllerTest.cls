@IsTest(SeeAllData=false)
public class RecentViewControllerTest {
    static testMethod void testgetData(){    
        RecentViewController.getData();
        System.assert(true);
    }
}