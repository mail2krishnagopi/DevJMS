/*********************************************************************************************************************
**********************************************************************************************************************
* @Class            : JMS_CustomNotification
* @Author           : Vasudha Tandon
* @Version History  : 1.0
* @Creation         : 2705/2022
* @Description      : This class to send custom bell notification to users
**********************************************************************************************************************
**********************************************************************************************************************/
public with sharing class JMS_CustomNotification {
    //Final Variable Declaration
    private static final String METHOD_NOTIFY_USERS = 'notifyUsers';

    /***************************************************************************************************************
    *   @Name        :  notifyUsers                                                              
    *   @Return      :  void                                                                                       
    *   @Description :  This method is send custom bell notification to users
    ***************************************************************************************************************/
    public static void notifyUsers(Set<String> recipientsIds, String targetId,String strBody,String strTitle,
                                    String strcustomNotificationType) {

        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                    FROM CustomNotificationType 
                                                    WHERE DeveloperName = :strcustomNotificationType limit 1];
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(strTitle);
        notification.setBody(strBody);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }catch(Exception excep){
            JMS_Logger.push(METHOD_NOTIFY_USERS, JMS_ConstantsUtility.EQUIPMENT_REQUEST_API);
            JMS_Logger.debugException(excep);
        }finally {
            JMS_Logger.pop();
        } 
    }
}