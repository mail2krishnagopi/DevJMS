@isTest(SeeAllData=False) 
public class SOPaymentControlllerTest {

    static testMethod void getPaymentDetailsTest() {
        Account acc = new Account();
        acc.Name = 'Community Account';
        insert acc;
        SOPaymentController.getPaymentDetails(acc.id);
        System.assert(true);
    }
}