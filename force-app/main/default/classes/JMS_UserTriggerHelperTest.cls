/**
* @description       : Test Class for JMS_UserTriggerHelperTest
* @author            : Sachin
* @date       		 : 30/05/2022
*/
@isTest
public class JMS_UserTriggerHelperTest {
    private static final String STANDARD_EINSTEINS_ACTIVITY_CAPTURE = 'Standard Einstein Activity Capture';
    private static final String CRM_USER = 'CRM User';

	@isTest
    private static void testuser(){
        User salesUser = JMS_TestDataFactory.createUser();
        salesUser.UserPreferencesReceiveNoNotificationsAsApprover = FALSE;
        salesUser.UserPreferencesReceiveNotificationsAsDelegatedApprover = FALSE;
        //Updating User
        Update salesUser;
        System.assertEquals( 'standarduser6@testorg.com', salesUser.Email );
    }//End
    @isTest
    private static void assignPermissionSetToUsersTest(){
        User salesUser = JMS_TestDataFactory.createUser();
        salesUser.UserPreferencesReceiveNoNotificationsAsApprover = FALSE;
        salesUser.UserPreferencesReceiveNotificationsAsDelegatedApprover = FALSE;
        //Updating User
        Update salesUser;
        List<User> userListRecord = New List<User>();
        userListRecord.add(salesUser);
        JMS_UserTriggerHelper.assignPermissionSetToUsers(userListRecord,NULL,NULL);
        System.assertEquals( 'standarduser6@testorg.com', salesUser.Email );
        
    }//End
}//End