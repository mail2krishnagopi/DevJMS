@isTest
public class LightningLookupControllerTest {

    static testMethod void myTest1() {

        Account acct = new Account(Name = 'Test Account');
        insert acct;
        LightningLookupController.LookupRecords res = LightningLookupController.getRecords('Account', '', 'Name', '', 'Name like \'test%\'');
        System.assertEquals(null,res);
        res = LightningLookupController.getRecords('Account', 'Id', '', '', 'Name like \'test%\'');
        System.assertEquals(null,res);
        res = LightningLookupController.getRecords('Account', 'Id', '', 'CreatedDate', 'Name like \'test%\'');
        System.assertEquals(null,res);
        res = LightningLookupController.getRecords('Account', '', '', 'CreatedDate', 'Name like \'test%\'');
        System.assertEquals(null,res);
        res = LightningLookupController.getRecords('Account', 'Id', 'Name', 'CreatedDate', 'Name like \'test%\'');
        System.assertEquals(1,res.lstDisplay.size());
        System.assertEquals(1,res.lstValue.size());
        System.assertEquals(1,res.lstRecords.size());
        res = LightningLookupController.getRecords('Account', 'Id', 'Name', 'CreatedDate', 'Name like \'hufdehf%\'');
        System.assertEquals(1,res.lstDisplay.size());
        System.assertEquals(1,res.lstValue.size());
        System.assertEquals(1,res.lstRecords.size());
        System.assertEquals('No records found!',res.lstDisplay[0]);
        String s = LightningLookupController.getHelpText('Account.Name');
        s = LightningLookupController.getReference('Account.OwnerId');
        System.assertEquals('User',s);
        res = LightningLookupController.getFieldValue('Account', acct.Id, 'Name');
        System.assertEquals(acct.Name,res.lstDisplay[0]);
        System.assertEquals(acct.Id,res.lstValue[0]);
        System.assertEquals(1, res.lstRecords.size());
    }
    
}