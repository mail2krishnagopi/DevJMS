@isTest 
public class giic_DemandOrderCreationTest {
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation(); 
        
    }
    @isTest static void createDemandOrderTest(){
        
         

        
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
                                                       gii__Product__r.gii__Service__c,gii__Product__r.Name,
                                                       gii__SupplyPlanEnabled__c
                                                       FROM gii__ProductInventory__c];
         List<gii__ProductInventory__c> updateRecord = new  List<gii__ProductInventory__c>();
        for( gii__ProductInventory__c pi : updateResult){
            pi.gii__SupplyPlanEnabled__c = true;
            updateRecord.add(pi);
        }
        update updateRecord;
        updateResult = updateRecord;
            
        System.debug('updateResult>>>'+updateResult);
        System.debug('updateResult.size()>>>'+updateResult.size());
        System.debug('updateResult[0].1>>>'+updateResult[0].gii__SupplyPlanEnabled__c);
        System.debug('updateResult[0].2>>>'+updateResult[0].giic_MaxQtyCalculated__c);
        System.debug('updateResult[0].3>>>'+updateResult[0].gii__Product__c);
        System.debug('updateResult[0].4>>>'+updateResult[0].gii__Product__r.gii__Family__c);
        System.debug('updateResult[0].5>>>'+updateResult[0].gii__Product__r.Name);
        System.debug('updateResult[0].6>>>'+updateResult[0].gii__Warehouse__c);
        System.debug('updateResult[0].7>>>'+updateResult[0].gii__Warehouse__r.Name);
        
        
        String combinedString = updateResult[0].gii__Product__r.gii__Family__c+ ' ' +updateResult[0].gii__Warehouse__r.Name;
        System.debug(combinedString);  // Output: Hello World
        giic_DemandForcast__mdt jmsIntAttr = new giic_DemandForcast__mdt(
            Label = combinedString
         );
       List<giic_DemandForcast__mdt>   demandOrderLst = [select MasterLabel from giic_DemandForcast__mdt];
                system.debug('demandOrderLst>>>>>>1234 '+demandOrderLst);
        
        test.startTest();
          giic_DemandOrderCreationBatch DOreationBatch = new giic_DemandOrderCreationBatch();
            DataBase.executeBatch(DOreationBatch); 
        
          // Create an instance of ApexPages.StandardSetController (or use a mock)
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(updateResult);
        
        // Instantiate the giic_HistoricalDemandQntCalBatchExecute class
        giic_DemandOrdCreationBatchExecute batchExecute = new giic_DemandOrdCreationBatchExecute(controller);
        PageReference result = batchExecute.runBatch();
      
        
        test.stopTest();
    }
}