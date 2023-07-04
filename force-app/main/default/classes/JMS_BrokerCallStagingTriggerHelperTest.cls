@isTest
public class JMS_BrokerCallStagingTriggerHelperTest {
	static testMethod void executeBatchTest0(){
        JMS_BrokerCallStagingTriggerHelper bClass = new JMS_BrokerCallStagingTriggerHelper();
        JMS_Broker_Call_Staging__c brokerCallObj = JMS_TestDataFactory.createAWSBrokerCallStagingObj();
        Update brokerCallObj;
        Delete brokerCallObj;
        Undelete brokerCallObj;
    }
}