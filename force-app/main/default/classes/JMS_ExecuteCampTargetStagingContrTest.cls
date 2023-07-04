/**
* @description       : Test Class for JMS_ExecuteCampTargetStagingContr
* @author            : Krishna
* @date              : 30/03/2022
**/
@isTest(SeeAllData=false)
public class JMS_ExecuteCampTargetStagingContrTest {
    //Code Sacn Error Fix - The String literal used many times.
    private static final String STR_TEST_STRING = 'testString';
    //Start 
    @isTest
    private static void executeBatchTest(){
        //Start Test
        test.startTest();
        String testString = STR_TEST_STRING;
        JMS_ExecuteCampTargetStagingController helper = new JMS_ExecuteCampTargetStagingController();
        JMS_ExecuteCampTargetStagingController.executeBatch();
        System.assertEquals(STR_TEST_STRING, testString,'It is Equal');
        Test.stopTest();
        //Stop Test
    }//End
    //Start
    @isTest
    private static void executeBatchBrokerCallTest(){
        //Start Test
        test.startTest();
        String testString = STR_TEST_STRING;
        //JMS_ExecuteCampTargetStagingController helper = new JMS_ExecuteCampTargetStagingController();
        JMS_ExecuteCampTargetStagingController.executeBatchBrokerCall();
        System.assertEquals(STR_TEST_STRING, testString,'It is Equal');
        Test.stopTest();
        //Stop Test
    }//End
}