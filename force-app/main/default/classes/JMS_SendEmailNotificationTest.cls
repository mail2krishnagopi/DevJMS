//This is a test class for JMS_SendEmailNotification class.
@Istest
private class JMS_SendEmailNotificationTest {
    //Code Scan Error fix - Avoid unused varible.
    //This is the test method.
    @IsTest
    private static void checkMessageNotification(){
        //string nothing = 'file.csv';
        User newuser = JMS_TestDataFactory.createAdminUser();
        System.runAs(newuser){
        EmailTemplate temp = JMS_TestDataFactory.createEmailTemplate('New Template',newuser.Id);
        List<Messaging.Emailfileattachment> messageFile = new List<Messaging.Emailfileattachment>();
        //The test starts from here.
        Test.startTest();
        //The JMS_SendEmailNotification class is called here.
        JMS_SendEmailNotification tw = new JMS_SendEmailNotification();
        tw.sendMail('JMS@gmail.com','pwc@gmail.com','jmspwc@gmail.com','Good evening fellows','Thank you',temp.Id,'email',messageFile);
        System.assert(messageFile.size() == 0, 'Its a empty List');
        Test.stopTest();
        //The test ends here.
    }
    }

}