@isTest
public class giic_completeEsignTest {
    
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
         
    }
    
    @isTest 
    Public static void getServiceTicketLineListTest(){
        List<gii__ServiceTicket__c>lstSerTicket=new List<gii__ServiceTicket__c>();
         lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c>lstSerTicketLine=new List<gii__ServiceTicketLine__c>();
        lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
        Test.startTest();
        giic_completeEsign.getServiceTicketLineList(String.valueOf(lstSerTicket[0].id));
        Test.stopTest();
    }
    @isTest 
    Public static void saveSignatureTest(){
    List<gii__ServiceTicket__c>lstSerTicket=new List<gii__ServiceTicket__c>();
         lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c>lstSerTicketLine=new List<gii__ServiceTicketLine__c>();
        lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
        String signElement='TestSign';
        Id recId=lstSerTicket[0].id;
        String signedBy='Test User';
        List<giic_completeEsign.ServiceTicketLineWrapper> wrapperClass = new List<giic_completeEsign.ServiceTicketLineWrapper>();
        giic_completeEsign.ServiceTicketLineWrapper obj =new giic_completeEsign.ServiceTicketLineWrapper();
        obj.objSTLRef=lstSerTicketLine[0];
        obj.isSelected=True;
        wrapperClass.add(obj);
        
        Test.startTest();
        giic_completeEsign.saveSignature(signElement, recId, wrapperClass,signedBy);
        Test.stopTest();
        
        }
}