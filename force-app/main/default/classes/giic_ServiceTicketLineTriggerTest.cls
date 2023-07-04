@isTest
public class giic_ServiceTicketLineTriggerTest {
     @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
         //giic_Test_DataCreationUtility.insertServTicket();
       //  insertServTicketLine(List<gii__ServiceTicket__c> lstservTicket);
    }
  @isTest 
    Public static void STLInsertAndUpdate(){
        List<gii__ServiceTicket__c>lstSerTicket=new List<gii__ServiceTicket__c>();
        lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c>lstSerTicketLine=new List<gii__ServiceTicketLine__c>();
       lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
        
        
       
        
        lstSerTicketLine[0].gii__Quantity__c=2;
        lstSerTicketLine.add(lstSerTicketLine[0]);
        update lstSerTicketLine;
    }
    
}