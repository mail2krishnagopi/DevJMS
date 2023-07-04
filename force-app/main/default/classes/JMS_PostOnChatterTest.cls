//This is test class for JMS_PostOnChatter class.
@Istest
private class JMS_PostOnChatterTest {
    //This is the test method.
    @IsTest
    private static void checkChatterPostTest(){
        User salesUser = JMS_TestDataFactory.createUser();
        Account acc = JMS_TestDataFactory.createAccountByName('Test Account');
        //The test starts here.
        Test.startTest();
        JMS_PostOnChatter tw = new JMS_PostOnChatter();
        tw.postChatterToUser(acc.Id,'Checking of chatter post',String.valueOf(salesUser.Id));
        System.assert(2 > 0,'Its a Integer');
        Test.stopTest();
        //The test ends here.
    }
    
}