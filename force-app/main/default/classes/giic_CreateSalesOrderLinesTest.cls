// note rewrite or one by one uncomment teh method and resolve the error this class
@isTest
public class giic_CreateSalesOrderLinesTest {
    
     @testSetup static void setup() {
       giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    
   /* 
    @isTest static void testMethodSearchAddProduct() {
        
         List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
       
        system.debug('lstProd >>>'+ lstProd); 
        //List<gii__Product2Add__c> prodextList = [Select Id, Name,gii__ProductCode__c,gii__MaterialCost__c,gii__Description__c from gii__Product2Add__c Where id =: lstProd[0].id];
     //   system.debug('prodextList >>>'+ prodextList); 
       //  system.debug('prodextList[0].id >>>'+ prodextList[0].id); 
       //  system.debug('prodextList[0].Name >>>'+ prodextList[0].Name); 
        
        test.startTest();
        giic_CreateSalesOrderLines.searchAddProduct(lstProd[0].id , '1','' );
         giic_CreateSalesOrderLines.searchAddProduct('' , '1',lstProd[0].Name );
       // giic_CreateSalesOrderLines.searchAddProduct(lstProd[0].id , '1',lstProd[0].Name );
        test.stopTest();
    }
   
     @isTest static void testMethodCreateSalesOrLines() {
         
          list<giic_CreateSalesOrderLines.SalesOrderLineWrapper> wrapperList = new list< giic_CreateSalesOrderLines.SalesOrderLineWrapper>();
         giic_CreateSalesOrderLines.SalesOrderLineWrapper wrapper = new giic_CreateSalesOrderLines.SalesOrderLineWrapper();
           
        // List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
         List<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
         system.debug('lstSalesOrder >>>'+ lstSalesOrder); 
        List<gii__SalesOrderLine__c> soLineToInsert = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
       // List<gii__SalesOrderLine__c> exisSoLine = [SELECT Id,gii__Product__c FROM gii__SalesOrderLine__c WHERE id = : soLineToInsert[0].id];
       // String lstProdId=exisSoLine[0].gii__Product__c;
       // system.debug('lstProdId >>>'+ lstProdId); 
       // List<gii__Product2Add__c> prodextList = [Select Id, Name,gii__ProductCode__c,gii__MaterialCost__c,gii__Description__c from gii__Product2Add__c Where id =: lstProdId];
        List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
       
         wrapper.objProdRef   = lstProd[0];
         wrapper.prodQty   = '2';
        wrapper.prodCost ='50';
        wrapperList.add(wrapper);
        
         test.startTest();
         giic_CreateSalesOrderLines.createSalesOrLines(wrapperList ,lstSalesOrder[0].id ,'10' );
        
         test.stopTest();
     }*/

    /*
     Added by Rohan
     @isTest static void testMethodCreateSalesOrLines1() {
         
          list<giic_CreateSalesOrderLines.SalesOrderLineWrapper> wrapperList = new list< giic_CreateSalesOrderLines.SalesOrderLineWrapper>();
         giic_CreateSalesOrderLines.SalesOrderLineWrapper wrapper = new giic_CreateSalesOrderLines.SalesOrderLineWrapper();
           
        // List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
         List<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
         system.debug('lstSalesOrder >>>'+ lstSalesOrder); 
        List<gii__SalesOrderLine__c> soLineToInsert = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<gii__SalesOrderLine__c> exisSoLine = [SELECT Id,gii__Product__c FROM gii__SalesOrderLine__c WHERE id = : soLineToInsert[0].id];
        String lstProdId=exisSoLine[0].gii__Product__c;
        system.debug('lstProdId >>>'+ lstProdId); 
        List<gii__Product2Add__c> prodextList = [Select Id, Name,gii__ProductCode__c,gii__MaterialCost__c,gii__Description__c from gii__Product2Add__c Where id =: lstProdId];
        
        wrapper.objProdRef   = prodextList[0];
        wrapper.prodQty   = '2';
        wrapper.prodCost ='50';
        wrapperList.add(wrapper);
        
         test.startTest();
         giic_CreateSalesOrderLines.createSalesOrLines(wrapperList ,lstSalesOrder[0].id ,'10' );
         giic_CreateSalesOrderLines.createSalesOrLines(wrapperList ,null ,'' );
         test.stopTest();
     }
*/
}