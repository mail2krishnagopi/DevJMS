// note rewrite or one by one uncomment teh method and resolve the error this class

@isTest 
public class Giic_CreateTransferOrderTest {
    
    
    @testSetup static void setup() {
       giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    @isTest static void testMethodForgetDCWarehouse() {
        
         string str =Label.giic_DCWarehouse;
        
        List<gii__Warehouse__c> lstWarehouseTemp = giic_Test_DataCreationUtility.insertWarehouse();
        lstWarehouseTemp[0].name=str;
        update lstWarehouseTemp;
      //  
        test.startTest();
        Giic_CreateTransferOrder.getDCWarehouse();
        test.stopTest();

    }
    
   
     @isTest static void testMethodForgetSalesOrderLines() {
         
        list<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        List<gii__SalesOrderLine__c> lstSOLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);

         test.startTest();
          Giic_CreateTransferOrder.getSalesOrderLines(lstSalesOrder[0].id);
        test.stopTest();
     }
    
     @isTest static void testMethodForcreateTransferOrder() {
         list< Giic_CreateTransferOrder.salesOrderLineDetailWrapper> wrapperList = new list< Giic_CreateTransferOrder.salesOrderLineDetailWrapper>();
         Giic_CreateTransferOrder.salesOrderLineDetailWrapper wrapper = new Giic_CreateTransferOrder.salesOrderLineDetailWrapper();

          list<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        List<gii__SalesOrderLine__c> lstSOLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);

          List<gii__Warehouse__c> lstWarehouse = giic_Test_DataCreationUtility.insertWarehouse();
         
         List<gii__SalesOrderLine__c> corrctList = [SELECT Id,Name ,giic_TransferOrderQty__c,gii__SalesOrder__c, gii__SalesOrder__r.gii__Account__c,gii__SalesOrder__r.Id ,gii__Product__c, gii__Product__r.Id FROM gii__SalesOrderLine__c where id =: lstSOLine[0].id];
         
         wrapper.isSelected =true;
         wrapper.objSOLine = corrctList[0];
         
         gii__Warehouse__c objWarehouse2 = new gii__Warehouse__c();
          objWarehouse2.Name='JMS - wylie CO'; 
         insert objWarehouse2;
         
         wrapperList.add(wrapper);
         Date requiredDate= System.today();
         test.startTest();
          Giic_CreateTransferOrder.createTransferOrder(wrapperList,lstWarehouse[0].id,objWarehouse2.id,requiredDate);
        test.stopTest();
         
     }
}