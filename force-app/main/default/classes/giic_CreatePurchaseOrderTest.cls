@isTest
public class giic_CreatePurchaseOrderTest {
	
    @testSetup static void setup() {
       giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    @isTest static void testMethodGetServiceTicketLine() {
        
        // List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
          list<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
         List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
        
       system.debug('lstservTicketLine  >>  '+lstservTicketLine); 
        
         test.startTest();
          giic_CreatePurchaseOrder.getServiceTicketLine(lstservTicket[0].id);
        test.stopTest();
         
     }
    
      @isTest static void testMethodGetProdInv() {
          
          List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
         
          system.debug('lstProd>>>'+ lstProd);
          
          List<gii__Warehouse__c> lstWarehouse = giic_Test_DataCreationUtility.insertWarehouse();
          system.debug('lstWarehouse>>>'+ lstWarehouse);  
          
          List<gii__ProductInventory__c> lstPI = giic_Test_DataCreationUtility.insertProductInventory();
          system.debug('lstPI>>>'+ lstPI);
          system.debug('lstPI[0]>>>'+ lstPI[0]);
          
         test.startTest();
          giic_CreatePurchaseOrder.getProdInv(lstWarehouse[0].id, lstProd[0].id);
          lstPI[0].gii__Product__c =lstProd[0].id ;
          lstPI[0].gii__Warehouse__c = lstWarehouse[0].id;
          update lstPI[0];
          giic_CreatePurchaseOrder.getProdInv(lstWarehouse[0].id, lstProd[0].id);
          test.stopTest();
         
     }
    
    
     @isTest static void testMethodCreatePoRecords() {
        
         list< giic_CreatePurchaseOrder.ServiceWrapper> wrapperList = new list< giic_CreatePurchaseOrder.ServiceWrapper>();
         giic_CreatePurchaseOrder.ServiceWrapper wrapper = new giic_CreatePurchaseOrder.ServiceWrapper();
            
          list<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
         List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
        System.debug('lstservTicketLine >>'+lstservTicketLine);
         System.debug('lstservTicketLine[0]>>>'+lstservTicketLine[0]);
         
         gii__ServiceTicketLine__c servTicketLineTest = new gii__ServiceTicketLine__c();
         servTicketLineTest=lstservTicketLine[0];
       
         
         List<gii__Warehouse__c> lstWarehouse=giic_Test_DataCreationUtility.insertWarehouse();
          system.debug('lstLocations>>>'+ lstWarehouse);
         system.debug('lstLocations[0]>>>'+ lstWarehouse[0]);
         Account objAccount = [SELECT Id from Account where name='Test Account'];
         gii__FieldServiceEngineer__c fieldServiceEngg = new gii__FieldServiceEngineer__c();
         fieldServiceEngg.name ='CHRIS ORTHODOXOU';
         fieldServiceEngg.gii__Warehouse__c=lstWarehouse[0].id;
         fieldServiceEngg.gii__Supplier__c = objAccount.Id;
         insert fieldServiceEngg;
         
         servTicketLineTest.gii__FieldServiceEngineer__c=fieldServiceEngg.id;
         update servTicketLineTest;
         
         List<gii__Location__c> lstLocations = giic_Test_DataCreationUtility.insertLocations();
         system.debug('lstLocations>>>'+ lstLocations);
         system.debug('lstLocations[0]>>>'+ lstLocations[0]);
         
         
          List<gii__Location__c> locslst = [SELECT id,gii__Warehouse__c 
                                            FROM gii__Location__c 
                                            WHERE gii__Warehouse__c =:fieldServiceEngg.gii__Warehouse__c];
         system.debug('locslst>>>'+ locslst);
         //system.debug('lstLocations[0]>>>'+ lstLocations[0]);
         system.debug('servTicketLineTest>>>'+ servTicketLineTest);
          system.debug('fieldServiceEngg>>>'+ fieldServiceEngg);
         List<gii__ServiceTicketLine__c> servTicketLineTestActual =[select id , name, gii__Quantity__c,  gii__ServiceTicket__c,  gii__Product__c,
                                                               gii__FieldServiceEngineer__c , gii__FieldServiceEngineer__r.gii__Warehouse__c
                                                               from gii__ServiceTicketLine__c 
                                                               where id =:servTicketLineTest.id];
         system.debug('servTicketLineTestActual>>>'+ servTicketLineTestActual);
         

         //insert PO Object
         gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = objAccount.Id, gii__ShipTo__c = lstWarehouse[0].Id,gii__ServiceTicket__c=lstservTicket[0].Id);
         insert objPO;
          wrapper.isPurchaseOrderExists = false;
          wrapper.isLineDetailExits = false;
           wrapper.isSelected        =true;
          wrapper.serviceLine = servTicketLineTestActual[0];
         
         wrapperList.add(wrapper);
         String recordJson = JSON.serialize(wrapperList);
          System.debug('recordJson>>>'+recordJson);
         test.startTest();
          giic_CreatePurchaseOrder.createPoRecords(recordJson);
        test.stopTest();
     }
    
     @isTest static void testMethodCreatePoRecordsoth() {
        
         list< giic_CreatePurchaseOrder.ServiceWrapper> wrapperList = new list< giic_CreatePurchaseOrder.ServiceWrapper>();
         giic_CreatePurchaseOrder.ServiceWrapper wrapper = new giic_CreatePurchaseOrder.ServiceWrapper();
            
          list<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
         List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
        System.debug('lstservTicketLine >>'+lstservTicketLine);
         System.debug('lstservTicketLine[0]>>>'+lstservTicketLine[0]);
         
         gii__ServiceTicketLine__c servTicketLineTest = new gii__ServiceTicketLine__c();
         servTicketLineTest=lstservTicketLine[0];
       
         
         List<gii__Warehouse__c> lstWarehouse=giic_Test_DataCreationUtility.insertWarehouse();
          system.debug('lstLocations>>>'+ lstWarehouse);
         system.debug('lstLocations[0]>>>'+ lstWarehouse[0]);
         
         gii__FieldServiceEngineer__c fieldServiceEngg = new gii__FieldServiceEngineer__c();
         fieldServiceEngg.name ='CHRIS ORTHODOXOU';
         fieldServiceEngg.gii__Warehouse__c=lstWarehouse[0].id;
         insert fieldServiceEngg;
         
         servTicketLineTest.gii__FieldServiceEngineer__c=fieldServiceEngg.id;
         update servTicketLineTest;
         
         List<gii__Location__c> lstLocations = giic_Test_DataCreationUtility.insertLocations();
         system.debug('lstLocations>>>'+ lstLocations);
         system.debug('lstLocations[0]>>>'+ lstLocations[0]);
         
         
          List<gii__Location__c> locslst = [SELECT id,gii__Warehouse__c 
                                            FROM gii__Location__c 
                                            WHERE gii__Warehouse__c =:fieldServiceEngg.gii__Warehouse__c];
         system.debug('locslst>>>'+ locslst);
         //system.debug('lstLocations[0]>>>'+ lstLocations[0]);
         system.debug('servTicketLineTest>>>'+ servTicketLineTest);
          system.debug('fieldServiceEngg>>>'+ fieldServiceEngg);
         List<gii__ServiceTicketLine__c> servTicketLineTestActual =[select id , name, gii__Quantity__c,  gii__ServiceTicket__c,  gii__Product__c,
                                                               gii__FieldServiceEngineer__c , gii__FieldServiceEngineer__r.gii__Warehouse__c
                                                               from gii__ServiceTicketLine__c 
                                                               where id =:servTicketLineTest.id];
         system.debug('servTicketLineTestActual>>>'+ servTicketLineTestActual);
         
         Account objAccount = [SELECT Id from Account where name='Test Account'];

         //insert PO Object
         gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = objAccount.Id, gii__ShipTo__c = lstWarehouse[0].Id,gii__ServiceTicket__c=lstservTicket[0].Id);
         insert objPO;
         
          wrapper.isPurchaseOrderExists = true;
          wrapper.isLineDetailExits = false;
           wrapper.isSelected        =true;
          wrapper.serviceLine = servTicketLineTestActual[0];
         
         wrapperList.add(wrapper);
         String recordJson = JSON.serialize(wrapperList);
          System.debug('recordJson>>>'+recordJson);
         test.startTest();
          giic_CreatePurchaseOrder.createPoRecords(recordJson);
        test.stopTest();
     }
    
    /*@isTest
    static void testMethod1(){
        test.startTest();
          Account acc = JMS_TestDataFactory.createAccountByName('Test132T');
        	gii__ServiceTicket__c servTkt = new gii__ServiceTicket__c();
        	servTkt.gii__ServiceTicketStatus__c = 'Open';
        	servTkt.gii__Account__c = acc.Id;
        	servTkt.gii__ServiceDueDate__c = system.today().addDays(3);
        insert servTkt;
        gii__ServiceTicketLine__c serLine = new gii__ServiceTicketLine__c();
        serLine.gii__Quantity__c = 1;
        serLine.gii__ServiceTicket__c = servTkt.Id;
        insert serLine;
        
        giic_CreatePurchaseOrder.getServiceTicketLine(servTkt.Id);
        test.stopTest();
    } */
    
}