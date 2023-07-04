@isTest
public class giic_ServiceTicketLineTriggerHandlerTest {
    
    @testSetup Public static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
         
    }
  @isTest 
    Public static void onAfterInsertTest(){
        List<gii__ServiceTicket__c>lstSerTicket=new List<gii__ServiceTicket__c>();
        lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c>lstSerTicketLine=new List<gii__ServiceTicketLine__c>();
       lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
        
        Test.startTest();
        giic_ServiceTicketLineTriggerHandler obj= new giic_ServiceTicketLineTriggerHandler();
        obj.onAfterInsert(lstSerTicketLine);
        Test.stopTest();
       
        
       
    }
    
     @isTest 
    Public static void onAfterUpdateTest(){
         List<gii__ServiceTicket__c>lstSerTicket=new List<gii__ServiceTicket__c>();
        lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c>lstSerTicketLine=new List<gii__ServiceTicketLine__c>();
       lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
        List<gii__ServiceTicketLine__c>newlstSerTicketLine=new List<gii__ServiceTicketLine__c>();
        
        lstSerTicketLine[0].gii__Quantity__c=2;
        newlstSerTicketLine.add(lstSerTicketLine[0]);
        update newlstSerTicketLine;
        Map<id,Object>stlMap=new Map<id,Object>();
        stlMap.put(newlstSerTicketLine[0].id,newlstSerTicketLine[0]);
        
         Test.startTest();
        giic_ServiceTicketLineTriggerHandler obj= new giic_ServiceTicketLineTriggerHandler();
        obj.onAfterUpdate(lstSerTicketLine,newlstSerTicketLine,stlMap);
        Test.stopTest();
    }
    
    @isTest 
    Public static void assignFSEBasedOnCertificationTest(){
        
        List<gii__ServiceTicket__c>lstSerTicket=new List<gii__ServiceTicket__c>();
        lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c>lstSerTicketLine=new List<gii__ServiceTicketLine__c>();
        lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
        
        Test.startTest();
       // giic_ServiceTicketLineTriggerHandler obj= new giic_ServiceTicketLineTriggerHandler();
        giic_ServiceTicketLineTriggerHandler.assignFSEBasedOnCertification(lstSerTicketLine);
        Test.stopTest();
        
    }
}