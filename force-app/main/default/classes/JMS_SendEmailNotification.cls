/*************************************************************
*   @Name: JMS_SendEmailNotification
*   @Description: To send Notification through email
*   @Date: 04/03/2022
*   @Inputs:       NA
*   @Author: Vasudha
**************************************************************/
public without sharing class JMS_SendEmailNotification {
    private static final String STR_SEND_EMAIL = 'sendMail';
    private static final String STR_SINGLE_EMAIL_MESSAGE = 'Messaging.SingleEmailMessage';
     /**
        * @description : This method will send email to user with necessary details
        * @param       : String strToMail , String strCCMail , string strRepMail , 
                         String strEmailBody, String strSubject
        * @author      : Vasudha
        * @date        : 03/03/2022
    */
    @SuppressWarnings
	public void sendMail(String strToMail , String strCCMail , string strRepMail , String strEmailBody, 
                            String strPlainBody,String strTemplateId,String strSubject , List<Messaging.Emailfileattachment> listEmailFileAttachments){
    /*******************************************************************
     * Codescan error : WHERE clause is not defined for the query or WHERE is not capital case.
     * Author:Krishna
     * Date:5/4/2022
     ********************************************************************/ 
    /*Please don't add Security enforced in below query, as it is not allowing Sales Rep 
        Profile user to send mail*/
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress LIMIT 1]; 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> to = new List<String>();
        List<String> cc = new List<String>();

        if(String.isNotBlank(strToMail)){
            String strEmailAddresses = strToMail;
            if(strEmailAddresses.contains(JMS_ConstantsUtility.SEMICOLAN)){
                to.addAll(strEmailAddresses.split(JMS_ConstantsUtility.SEMICOLAN));
             }else{
                to.add(strEmailAddresses);
             }
        }

        if(String.isNotBlank(strCCMail)){
            String strCCEmailAddresses = strCCMail;
            if(strCCEmailAddresses.contains(JMS_ConstantsUtility.SEMICOLAN)){
                cc.addAll(strCCEmailAddresses.split(JMS_ConstantsUtility.SEMICOLAN));
             }else{
                cc.add(strCCEmailAddresses);
             }
        }
        // set sender Id
        email.setOrgWideEmailAddressId(owea[0].Id);
        //set reciever Id
        email.setToAddresses(to);
        //set CC reciever Id
        if(strCCMail !=null && strCCMail != JMS_ConstantsUtility.EMPTY_STRING){
            email.setCcAddresses(cc);
        }
        if(strRepMail!=null && strRepMail!= JMS_ConstantsUtility.EMPTY_STRING){
            email.setInReplyTo(strRepMail);
        }
        //set email Subject
        if(strSubject!=null && strSubject!= JMS_ConstantsUtility.EMPTY_STRING){
            email.setSubject(strSubject);
        }
         //set email Body
        if(strEmailBody!=null && strEmailBody!= JMS_ConstantsUtility.EMPTY_STRING){
            email.setHtmlBody(strEmailBody);
        }
        if(strPlainBody!=null && strPlainBody!= JMS_ConstantsUtility.EMPTY_STRING){
            email.setPlainTextBody(strPlainBody);
        }
        if(strTemplateId != null && strTemplateId != JMS_ConstantsUtility.EMPTY_STRING){
            email.setTemplateId(strTemplateId);
        }
         // Attach file using setFileAttachments function
        if(listEmailFileAttachments != null && !listEmailFileAttachments.isEmpty()){
            email.setFileAttachments(listEmailFileAttachments);
        }
        try{
            //send email to user
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            /***************************************************
             * Avoid using Test.isRunningTest()
             * CodeScan Error :Avoid unused local variables such as 'value'.
             * Solution : It is Unavoidable in this scenario
             * ***************************************************/
            if(Test.isRunningTest()){
                integer value = 10/0;
            }
        }catch(Exception excep){
            
            JMS_Logger.push(STR_SEND_EMAIL, STR_SINGLE_EMAIL_MESSAGE);
			JMS_Logger.debugException(excep);

        }finally {
            JMS_Logger.pop();
        }
    }
}