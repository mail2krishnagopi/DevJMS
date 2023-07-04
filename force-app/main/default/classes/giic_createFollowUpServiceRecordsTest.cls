@isTest
public class giic_createFollowUpServiceRecordsTest {
    @testSetup static void setup() {
      //   giic_Test_DataCreationUtility.getTestClassUser();
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
        
    }
    @isTest 
    public static void createServiceRecordsTest(){
       
         List<Account> lstAccount=giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__ServiceTicket__c> lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
        
        
            List<gii__ServiceTicketLine__c> lstSerTicketLineAll =[select id 
                                                                  from gii__ServiceTicketLine__c where 
                                                                 id=: lstSerTicketLine[0].id];        
        List<giic_createFollowUpServiceRecords.InputVariables> wrapperClass = new List<giic_createFollowUpServiceRecords.InputVariables>();
        giic_createFollowUpServiceRecords.InputVariables obj=new giic_createFollowUpServiceRecords.InputVariables();
        obj.serviceTicketLine=lstSerTicketLine;
        obj.accountID=lstAccount[0].id;
        wrapperClass.add(obj);
        System.debug('wrapperClass ->TC '+wrapperClass);
         Test.startTest();
       giic_createFollowUpServiceRecords.createServiceRecords(wrapperClass);
        Test.stopTest();
        
    }

    
     @isTest 
    public static void createFollowUpServiceLineRecordsTest(){
       
         List<Account> lstAccount=giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__ServiceTicket__c> lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
      
        gii__ServiceType__c  insertServiceType = new gii__ServiceType__c();
        insertServiceType.name ='Removal';
        insert insertServiceType;
        
        gii__ServiceType__c  insertServiceType1 = new gii__ServiceType__c();
        insertServiceType1.name ='Installation';
        insert insertServiceType1;
            List<gii__ServiceTicketLine__c> lstSerTicketLineAll =[select id 
                                                                  from gii__ServiceTicketLine__c where 
                                                                 id=: lstSerTicketLine[0].id];        
       /* List<giic_createFollowUpServiceRecords.InputVariables> wrapperClass = new List<giic_createFollowUpServiceRecords.InputVariables>();
        giic_createFollowUpServiceRecords.InputVariables obj=new giic_createFollowUpServiceRecords.InputVariables();
        obj.serviceTicketLine=lstSerTicketLine;
        obj.accountID=lstAccount[0].id;
        wrapperClass.add(obj);
        System.debug('wrapperClass ->TC '+wrapperClass);
*/
         Test.startTest();
       giic_createFollowUpServiceRecords.createFollowUpServiceLineRecords(lstSerTicketLine[0].id, lstSerTicketLine[0],lstAccount[0].id);
        Test.stopTest();
        
    }

}