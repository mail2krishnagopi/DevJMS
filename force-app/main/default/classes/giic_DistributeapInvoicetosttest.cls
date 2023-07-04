@isTest 
public class giic_DistributeapInvoicetoSTTest {
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    @isTest static void getServiceTicketLineTest(){
        
       // 
      
       
                List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
         List<gii__AssetReference__c> lstAssetReference = giic_Test_DataCreationUtility.insertAssetReference();
        List<gii__Product2Add__c> lstProd =  giic_Test_DataCreationUtility.insertProduct();
        
        //List<gii__APInvoice__c> lstApinv =  giic_Test_DataCreationUtility.createAPInvoice();
       
        gii__Product2Add__c thirdPartySerProduct = [select id from gii__Product2Add__c where Name =: 'Third Party Service' limit 1];
        system.debug('thirdPartySerProduct#####:: '+thirdPartySerProduct);
        list<gii__FieldServiceEngineer__c>  fseList = [select id ,gii__Warehouse__c ,
                                                       gii__Supplier__c from gii__FieldServiceEngineer__c ];
        system.debug('fseList#####:: '+fseList);
         List<gii__AccountAdd__c>  accntref =[select id , name ,gii__Account__c 
                                              from gii__AccountAdd__c
                                              where gii__Account__c != null];
        system.debug('accntref#####:: '+accntref);
        
        
         gii__APInvoice__c apinv = new gii__APInvoice__c();
        apinv.gii__SupplierDocument__c = 'Test';
        apinv.gii__DocumentDate__c = system.today();
        apinv.gii__DocumentAmount__c = 10;
        system.debug('Acc id::'+lstAccount[0].Id);
        apinv.gii__Supplier__c = lstAccount[0].Id;
        apinv.giic_Service_Ticket__c = lstservTicket[0].Id;
        apinv.gii__AccountReference__c =accntref[0].Id;
        apinv.giic_AP_Invoice_Status__c	= 'Draft';//Approved
        apinv.giic_Integration_Status__c ='Not Submitted';
        
        insert apinv;
        
        system.debug('apinv#####:: '+apinv);
        
          List<gii__ServiceTicketLine__c> lstservTicketLineQ = [select id ,gii__Quantity__c,
                                                               gii__TotalActualCost__c,
                                                               gii__ServiceTicket__c,
                                                               gii__AssetReference__r.gii__ProductSerial__c
                                                               from gii__ServiceTicketLine__c
                                                             where id =: lstservTicketLine[0].id];
        
        system.debug('lstservTicketLineQ#####:: '+lstservTicketLineQ);
        

      gii__PurchaseOrder__c purchaseOrder = new gii__PurchaseOrder__c();
        purchaseOrder.gii__ServiceTicket__c = lstservTicketLineQ[0].gii__ServiceTicket__c;
        purchaseOrder.gii__Supplier__c =fseList[0].gii__Supplier__c;
        purchaseOrder.gii__ShipTo__c = fseList[0].gii__Warehouse__c;
        insert purchaseOrder; 
         
       
        
        gii__PurchaseOrderLine__c purLine = new gii__PurchaseOrderLine__c();
        purLine.gii__ServiceTicketLine__c = lstservTicketLineQ[0].Id;
        purLine.gii__OrderQuantity__c = lstservTicketLineQ[0].gii__Quantity__c;
        //purLine.gii__NoChargeReason__c = 'Sample';
        purLine.gii__PurchaseOrder__c = purchaseOrder.Id;
        purLine.gii__ReceiptStatus__c	= 'Open';
        //purLine.gii__SalesOrder__c = serLine.giic_SalesOrder__c;
        purLine.gii__Product__c = thirdPartySerProduct.Id;
        purLine.gii__UnitPrice__c = 10;  //lstservTicketLineQ[0].gii__TotalActualCost__c;
        purLine.gii__UnitCost__c =   10; //lstservTicketLineQ[0].gii__TotalActualCost__c;
        //purLine.gii__SalesOrderLine__c = serLine.giic_SalesOrderLine__c;
        purLine.gii__ServiceTicket__c = lstservTicketLineQ[0].gii__ServiceTicket__c;
        // purLine.gii__ServiceTicketLine__c = lstservTicketLine[0].Id;
        insert purLine;
        
        gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c();
        // Set the record id of Purchase Order and receipt date;
        poReceipt.gii__PurchaseOrder__c = purchaseOrder.id; //Purchase order id which is required.
        poReceipt.gii__ReceiptDate__c   = System.today();
        
        insert poReceipt;
        
        
       gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
        poReceiptLine.gii__PurchaseOrderReceipt__c = poReceipt.id;
        poReceiptLine.gii__ShipTo__c = purLine.gii__ShipTo__c;
        poReceiptLine.gii__Product__c = purLine.gii__Product__c;
        poReceiptLine.giic_IntegrationStatus__c = 'Submitted';
        poReceiptLine.gii__ProductSerial__c = lstservTicketLine[0].gii__AssetReference__r.gii__ProductSerial__c;
        poReceiptLine.gii__Location__c = purLine.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
        poReceiptLine.gii__PurchaseOrderLine__c = purLine.Id; 
        system.debug('###'+poReceiptLine.gii__Location__c);
        poReceiptLine.gii__BuyingUMReceivedQuantity__c    = purLine.gii__OrderQuantity__c;
        // add line to the list
        insert poReceiptLine;
        
        
        
        
        test.startTest();
        giic_DistributeapInvoicetoServicetickets.getServiceTicketLine(apinv.id); //giic_Service_Ticket__c
        test.stopTest();
    }
    
    @isTest static void createPoRecordsTest(){
        
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
         List<gii__AssetReference__c> lstAssetReference = giic_Test_DataCreationUtility.insertAssetReference();
        List<gii__Product2Add__c> lstProd =  giic_Test_DataCreationUtility.insertProduct();
        
        //List<gii__APInvoice__c> lstApinv =  giic_Test_DataCreationUtility.createAPInvoice();
       
        gii__Product2Add__c thirdPartySerProduct = [select id from gii__Product2Add__c where Name =: 'Third Party Service' limit 1];
        system.debug('thirdPartySerProduct#####:: '+thirdPartySerProduct);
        list<gii__FieldServiceEngineer__c>  fseList = [select id ,gii__Warehouse__c ,
                                                       gii__Supplier__c from gii__FieldServiceEngineer__c ];
        system.debug('fseList#####:: '+fseList);
         List<gii__AccountAdd__c>  accntref =[select id , name ,gii__Account__c 
                                              from gii__AccountAdd__c
                                              where gii__Account__c != null];
        system.debug('accntref#####:: '+accntref);
        
        
         gii__APInvoice__c apinv = new gii__APInvoice__c();
        apinv.gii__SupplierDocument__c = 'Test';
        apinv.gii__DocumentDate__c = system.today();
        apinv.gii__DocumentAmount__c = 10;
        system.debug('Acc id::'+lstAccount[0].Id);
        apinv.gii__Supplier__c = lstAccount[0].Id;
        apinv.giic_Service_Ticket__c = lstservTicket[0].Id;
        apinv.gii__AccountReference__c =accntref[0].Id;
        apinv.giic_AP_Invoice_Status__c	= 'Draft';//Approved
        apinv.giic_Integration_Status__c ='Not Submitted';
        
        insert apinv;
        
        system.debug('apinv#####:: '+apinv);
        
          List<gii__ServiceTicketLine__c> lstservTicketLineQ = [select id ,gii__Quantity__c,
                                                               gii__TotalActualCost__c,
                                                               gii__ServiceTicket__c,
                                                               gii__AssetReference__r.gii__ProductSerial__c
                                                               from gii__ServiceTicketLine__c
                                                             where id =: lstservTicketLine[0].id];
        
        system.debug('lstservTicketLineQ#####:: '+lstservTicketLineQ);
        

      gii__PurchaseOrder__c purchaseOrder = new gii__PurchaseOrder__c();
        purchaseOrder.gii__ServiceTicket__c = lstservTicketLineQ[0].gii__ServiceTicket__c;
        purchaseOrder.gii__Supplier__c =fseList[0].gii__Supplier__c;
        purchaseOrder.gii__ShipTo__c = fseList[0].gii__Warehouse__c;
        insert purchaseOrder; 
         
       
        
        gii__PurchaseOrderLine__c purLine = new gii__PurchaseOrderLine__c();
        purLine.gii__ServiceTicketLine__c = lstservTicketLineQ[0].Id;
        purLine.gii__OrderQuantity__c = lstservTicketLineQ[0].gii__Quantity__c;
        //purLine.gii__NoChargeReason__c = 'Sample';
        purLine.gii__PurchaseOrder__c = purchaseOrder.Id;
        purLine.gii__ReceiptStatus__c	= 'Open';
        //purLine.gii__SalesOrder__c = serLine.giic_SalesOrder__c;
        purLine.gii__Product__c = thirdPartySerProduct.Id;
        purLine.gii__UnitPrice__c = 10;  //lstservTicketLineQ[0].gii__TotalActualCost__c;
        purLine.gii__UnitCost__c =   10; //lstservTicketLineQ[0].gii__TotalActualCost__c;
        //purLine.gii__SalesOrderLine__c = serLine.giic_SalesOrderLine__c;
        purLine.gii__ServiceTicket__c = lstservTicketLineQ[0].gii__ServiceTicket__c;
        // purLine.gii__ServiceTicketLine__c = lstservTicketLine[0].Id;
        insert purLine;
        
        gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c();
        // Set the record id of Purchase Order and receipt date;
        poReceipt.gii__PurchaseOrder__c = purchaseOrder.id; //Purchase order id which is required.
        poReceipt.gii__ReceiptDate__c   = System.today();
        
        insert poReceipt;
        
        
       gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
        poReceiptLine.gii__PurchaseOrderReceipt__c = poReceipt.id;
        poReceiptLine.gii__ShipTo__c = purLine.gii__ShipTo__c;
        poReceiptLine.gii__Product__c = purLine.gii__Product__c;
        poReceiptLine.giic_IntegrationStatus__c = 'Submitted';
        poReceiptLine.gii__ProductSerial__c = lstservTicketLine[0].gii__AssetReference__r.gii__ProductSerial__c;
        poReceiptLine.gii__Location__c = purLine.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
        poReceiptLine.gii__PurchaseOrderLine__c = purLine.Id; 
        system.debug('###'+poReceiptLine.gii__Location__c);
        poReceiptLine.gii__BuyingUMReceivedQuantity__c    = purLine.gii__OrderQuantity__c;
        // add line to the list
        insert poReceiptLine;
        
         giic_DistributeapInvoicetoServicetickets.ServiceWrapper obj=new giic_DistributeapInvoicetoServicetickets.ServiceWrapper();
        obj.serviceLine=poReceiptLine;
        obj.tolerancePer=9;
        obj.isSelected=true;
        obj.docAmount=10;
       
           System.debug('obj >>'+obj);
          String recordJsonObj = JSON.serialize(obj);
         System.debug('recordJsonObj >>'+recordJsonObj);
      List<giic_DistributeapInvoicetoServicetickets.ServiceWrapper> serviceWrapList = new List<giic_DistributeapInvoicetoServicetickets.ServiceWrapper>();
         serviceWrapList.add(obj);
       
          String recordJson = JSON.serialize(serviceWrapList);
         System.debug('recordJson >>'+recordJson);


        
        test.startTest();
        giic_DistributeapInvoicetoServicetickets.createPoRecords(recordJson,apinv.id , true); //giic_Service_Ticket__c
        giic_DistributeapInvoicetoServicetickets.createPoRecords(recordJson,apinv.id , false); //giic_Service_Ticket__c

        test.stopTest();
    }
    
     @isTest static void submitForApprovalTest(){
        
        List<gii__Warehouse__c> dcwarehouse =  giic_Test_DataCreationUtility.insertWarehouse();
        List<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);
         List<gii__AssetReference__c> lstAssetReference = giic_Test_DataCreationUtility.insertAssetReference();
        List<gii__Product2Add__c> lstProd =  giic_Test_DataCreationUtility.insertProduct();
        
        //List<gii__APInvoice__c> lstApinv =  giic_Test_DataCreationUtility.createAPInvoice();
       
        gii__Product2Add__c thirdPartySerProduct = [select id from gii__Product2Add__c where Name =: 'Third Party Service' limit 1];
        system.debug('thirdPartySerProduct#####:: '+thirdPartySerProduct);
        list<gii__FieldServiceEngineer__c>  fseList = [select id ,gii__Warehouse__c ,
                                                       gii__Supplier__c from gii__FieldServiceEngineer__c ];
        system.debug('fseList#####:: '+fseList);
         List<gii__AccountAdd__c>  accntref =[select id , name ,gii__Account__c 
                                              from gii__AccountAdd__c
                                              where gii__Account__c != null];
        system.debug('accntref#####:: '+accntref);
        
        
         gii__APInvoice__c apinv = new gii__APInvoice__c();
        apinv.gii__SupplierDocument__c = 'Test';
        apinv.gii__DocumentDate__c = system.today();
        apinv.gii__DocumentAmount__c = 10;
        system.debug('Acc id::'+lstAccount[0].Id);
        apinv.gii__Supplier__c = lstAccount[0].Id;
        apinv.giic_Service_Ticket__c = lstservTicket[0].Id;
        apinv.gii__AccountReference__c =accntref[0].Id;
        apinv.giic_AP_Invoice_Status__c	= 'Draft';//Approved
        apinv.giic_Integration_Status__c ='Not Submitted';
        
        insert apinv;
        
        system.debug('apinv#####:: '+apinv);
        
          List<gii__ServiceTicketLine__c> lstservTicketLineQ = [select id ,gii__Quantity__c,
                                                               gii__TotalActualCost__c,
                                                               gii__ServiceTicket__c,
                                                               gii__AssetReference__r.gii__ProductSerial__c
                                                               from gii__ServiceTicketLine__c
                                                             where id =: lstservTicketLine[0].id];
        
        system.debug('lstservTicketLineQ#####:: '+lstservTicketLineQ);
        

      gii__PurchaseOrder__c purchaseOrder = new gii__PurchaseOrder__c();
        purchaseOrder.gii__ServiceTicket__c = lstservTicketLineQ[0].gii__ServiceTicket__c;
        purchaseOrder.gii__Supplier__c =fseList[0].gii__Supplier__c;
        purchaseOrder.gii__ShipTo__c = fseList[0].gii__Warehouse__c;
        insert purchaseOrder; 
         
       
        
        gii__PurchaseOrderLine__c purLine = new gii__PurchaseOrderLine__c();
        purLine.gii__ServiceTicketLine__c = lstservTicketLineQ[0].Id;
        purLine.gii__OrderQuantity__c = lstservTicketLineQ[0].gii__Quantity__c;
        //purLine.gii__NoChargeReason__c = 'Sample';
        purLine.gii__PurchaseOrder__c = purchaseOrder.Id;
        purLine.gii__ReceiptStatus__c	= 'Open';
        //purLine.gii__SalesOrder__c = serLine.giic_SalesOrder__c;
        purLine.gii__Product__c = thirdPartySerProduct.Id;
        purLine.gii__UnitPrice__c = 10;  //lstservTicketLineQ[0].gii__TotalActualCost__c;
        purLine.gii__UnitCost__c =   10; //lstservTicketLineQ[0].gii__TotalActualCost__c;
        //purLine.gii__SalesOrderLine__c = serLine.giic_SalesOrderLine__c;
        purLine.gii__ServiceTicket__c = lstservTicketLineQ[0].gii__ServiceTicket__c;
        // purLine.gii__ServiceTicketLine__c = lstservTicketLine[0].Id;
        insert purLine;
        
        gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c();
        // Set the record id of Purchase Order and receipt date;
        poReceipt.gii__PurchaseOrder__c = purchaseOrder.id; //Purchase order id which is required.
        poReceipt.gii__ReceiptDate__c   = System.today();
        
        insert poReceipt;
        
        
       gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
        poReceiptLine.gii__PurchaseOrderReceipt__c = poReceipt.id;
        poReceiptLine.gii__ShipTo__c = purLine.gii__ShipTo__c;
        poReceiptLine.gii__Product__c = purLine.gii__Product__c;
        poReceiptLine.giic_IntegrationStatus__c = 'Submitted';
        poReceiptLine.gii__ProductSerial__c = lstservTicketLine[0].gii__AssetReference__r.gii__ProductSerial__c;
        poReceiptLine.gii__Location__c = purLine.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
        poReceiptLine.gii__PurchaseOrderLine__c = purLine.Id; 
        system.debug('###'+poReceiptLine.gii__Location__c);
        poReceiptLine.gii__BuyingUMReceivedQuantity__c    = purLine.gii__OrderQuantity__c;
        // add line to the list
        insert poReceiptLine;
        
      
        
        test.startTest();
        giic_DistributeapInvoicetoServicetickets.submitForApproval(apinv.id ); 
        test.stopTest();
    }
    
}