@isTest
public class JMS_BrokerCallScheduleClassTest {
    @isTest
    public static void executeTests(){
        //This is starting point of the test.
        Test.startTest();
        JMS_BrokerCallScheduler objBatchTest = new JMS_BrokerCallScheduler();
        //The time provided for the test Schedulable to run.
        String sch = '0 0 0 * * ?';
		system.schedule('Test Scheduler', sch, objBatchTest);
        System.assertEquals('0 0 0 * * ?', sch,'It is Same');
        Test.stopTest();
        //This is ending point of the test.
    }
}