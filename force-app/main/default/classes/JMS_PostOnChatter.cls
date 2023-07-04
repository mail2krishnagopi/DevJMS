/*************************************************************
*   @Name: JMS_PostOnChatter
*   @Description: To send Notification to user
*   @Date: 03/03/2022
*   @Inputs:       NA
*   @Author: Offshore(PwC)
**************************************************************/
public without sharing class JMS_PostOnChatter {
   
    /**
        * @description : This method will send Post on chatter with necessary details
        * @param       : Id senderId, String strChatterBody
        * @author      : Offshore(PwC)
        * @date        : 03/03/2022
    */
    public void postChatterToUser(Id senderId, String strChatterBody , String strOwnerId) { 

        try{
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            mentionSegmentInput.id = strOwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            // post body
            textSegmentInput.text = strChatterBody;
            messageBodyInput.messageSegments.add(textSegmentInput);
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            
            //post on Account record
            feedItemInput.subjectId = senderId;
            //post the chatter
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null,feedItemInput);  
        }catch(Exception e){

        }
        

   }     
        
}