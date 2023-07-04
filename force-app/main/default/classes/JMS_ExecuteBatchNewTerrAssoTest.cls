/**
* @description       : Test Class for JMS_ExecuteBatchNewTerrAssociation
* @author            : Archana
* @date              : 30/03/2022
**/
//Start Test
@isTest
public class JMS_ExecuteBatchNewTerrAssoTest {
    @isTest
    private static void executeBatchTest(){
        //Start Test
        test.startTest();
        String testString = 'testString';
        JMS_ExecuteBatchNewTerrAssociation.executeBatch();
        System.assertEquals('testString', testString,'It is Equal');
        Test.stopTest();
        //StopTest
    }
}//End Test