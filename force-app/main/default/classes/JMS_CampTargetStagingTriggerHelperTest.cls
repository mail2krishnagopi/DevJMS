@isTest
public class JMS_CampTargetStagingTriggerHelperTest {
	
    static testmethod void executeBatch(){
        JMS_CampaignTargetStagingTriggerHelper cClass = new JMS_CampaignTargetStagingTriggerHelper();
        JMS_Campaign_Target_Staging__c campObj = JMS_TestDataFactory.createAWSCampaignStaging();
        Update campObj;
        Delete campObj;
        Undelete campObj;
        
    }
}