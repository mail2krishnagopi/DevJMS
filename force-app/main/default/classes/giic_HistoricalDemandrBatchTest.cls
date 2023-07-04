@isTest 
public class giic_HistoricalDemandrBatchTest {
  @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation(); 
      
    }
    @isTest static void getThequantityCountTest(){
        
        List<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        List<gii__SalesOrderLine__c> lstSalesOrderLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
       
      List<gii__ProductInventory__c> updateResult=  [select id,gii__Product__r.gii__ProductReference__r.Make__c,
                                         gii__Warehouse__r.name,gii__Product__r.gii__Family__c,
                                         gii__Product__c,gii__AvailableQuantity__c,
                                         giic_MinQtyCalculated__c,gii__InTransitQuantity__c,
                                         gii__PurchaseOrderQuantity__c, giic_SafetyStockCalculated__c,
                                         giic_MaxQtyCalculated__c,giic_NumberOfMonth__c,  
                                         giic_12MonthsDemand__c, giic_HistoricalSO__c, 
									     giic_HistoricalTO__c, giic_HistoricalWO__c ,
                                          gii__Product__r.gii__Service__c,gii__Product__r.Name
                                          
                                         FROM gii__ProductInventory__c];
        System.debug('updateResult>>>'+updateResult);
         System.debug('updateResult.size()>>>'+updateResult.size());
        System.debug('updateResult[0].1>>>'+updateResult[0].gii__Warehouse__c);
         System.debug('updateResult[0].2>>>'+updateResult[0].gii__Product__c);
         System.debug('updateResult[0].3>>>'+updateResult[0].giic_NumberOfMonth__c);
         System.debug('updateResult[0].4>>>'+updateResult[0].gii__Product__r.gii__Service__c);
         System.debug('updateResult[0].5>>>'+updateResult[0].gii__Product__r.Name);
         System.debug('updateResult[0].6>>>'+updateResult[0].gii__Warehouse__r.Name);
        

        gii__WorkOrder__c  wo = new gii__WorkOrder__c();
        wo.gii__Product__c =updateResult[0].gii__Product__c;
        wo.gii__ProductInventory__c =updateResult[0].id;
        wo.gii__Warehouse__c =updateResult[0].gii__Warehouse__c;
        wo.gii__OrderQuantity__c  = 1 ;
        wo.gii__DueDate__c   =system.today()+5 ;
        insert wo;
         System.debug('wo>>>'+wo);
        
        test.startTest();
          giic_HistoricalDemandQntCalHandlerBatch HDQCalHandlerBatch = new giic_HistoricalDemandQntCalHandlerBatch();
            DataBase.executeBatch(HDQCalHandlerBatch); 
        
          // Create an instance of ApexPages.StandardSetController (or use a mock)
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(updateResult);
        
        // Instantiate the giic_HistoricalDemandQntCalBatchExecute class
        giic_HistoricalDemandQntCalBatchExecute batchExecute = new giic_HistoricalDemandQntCalBatchExecute(controller);
        PageReference result = batchExecute.runBatch();
      
        
        test.stopTest();
        //list<gii__ProductInventory__c> lstPI=giic_Test_DataCreationUtility.insertProductInventory();
    }
}