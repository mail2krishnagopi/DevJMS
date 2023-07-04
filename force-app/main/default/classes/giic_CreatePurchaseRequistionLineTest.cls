@isTest
public class giic_CreatePurchaseRequistionLineTest {

    @testSetup static void setup() {
       giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    @isTest static void testMethodSearchAddProduct() {
        
         List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();

        system.debug('lstProd >>>'+ lstProd); 
        List<gii__Product2Add__c> prodextList = [Select Id, Name,gii__ProductCode__c,gii__MaterialCost__c,gii__Description__c from gii__Product2Add__c Where id =: lstProd[0].id];
        system.debug('prodextList >>>'+ prodextList); 
         system.debug('prodextList[0].id >>>'+ prodextList[0].id); 
         system.debug('prodextList[0].Name >>>'+ prodextList[0].Name); 
        
        test.startTest();
        giic_CreatePurchaseRequistionLine.searchAddProduct(prodextList[0].id , '1','' );
         giic_CreatePurchaseRequistionLine.searchAddProduct('' , '1',prodextList[0].Name );
        giic_CreatePurchaseRequistionLine.searchAddProduct(prodextList[0].id , '1',prodextList[0].Name );
        test.stopTest();
    }
   
    @isTest static void testMethodcreatePurchaseReqLines() {
        
         list<giic_CreatePurchaseRequistionLine.PurchaseReqLineWrapper> wrapperList = new list< giic_CreatePurchaseRequistionLine.PurchaseReqLineWrapper>();
         giic_CreatePurchaseRequistionLine.PurchaseReqLineWrapper wrapper = new giic_CreatePurchaseRequistionLine.PurchaseReqLineWrapper();
           
         List<gii__Product2Add__c> lstProd = giic_Test_DataCreationUtility.insertProduct();
        List<gii__Warehouse__c> lstWarehouse = giic_Test_DataCreationUtility.insertWarehouse();

        system.debug('lstProd >>>'+ lstProd); 
        List<gii__Product2Add__c> prodextList = [Select Id, Name,gii__ProductCode__c,gii__MaterialCost__c,gii__Description__c from gii__Product2Add__c Where id =: lstProd[0].id];
        
        wrapper.objProdRef   = prodextList[0];
        wrapper.prodQty   = '2';
        wrapper.prodCost ='50';
        wrapperList.add(wrapper);
        
        gii__PurchaseRequisition__c insertPurchaseRequisition = new gii__PurchaseRequisition__c();
        insertPurchaseRequisition.gii__Description__c = 'testt ';
        insertPurchaseRequisition.CurrencyIsoCode ='USD';
        insertPurchaseRequisition.gii__ShipTo__c = lstWarehouse[0].id;
        
        insert insertPurchaseRequisition ;
        
      
        
        test.startTest();
       string purReqId  =insertPurchaseRequisition.id;
       string updQntVal ='2';
        giic_CreatePurchaseRequistionLine.createPurchaseReqLines(wrapperList ,purReqId ,updQntVal );
        
        gii__PurchaseRequisitionLine__c insertPurchaseRequisitionLine = new gii__PurchaseRequisitionLine__c();
        insertPurchaseRequisitionLine.gii__Product__c = prodextList[0].id;
        insertPurchaseRequisitionLine.gii__ShipTo__c = lstWarehouse[0].id;
        insertPurchaseRequisitionLine.gii__PurchaseRequisition__c  =insertPurchaseRequisition.id;
        insertPurchaseRequisitionLine.gii__OrderQuantity__c=1;
        insert insertPurchaseRequisitionLine ;
        
        giic_CreatePurchaseRequistionLine.createPurchaseReqLines(wrapperList ,purReqId,updQntVal );
      
        test.stopTest();
        
    }
}