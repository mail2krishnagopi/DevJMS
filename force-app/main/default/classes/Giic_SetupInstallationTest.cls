@isTest 
public class Giic_SetupInstallationTest {
    
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    @isTest static void testMethodGetSalesOrderLines() {
        
        // List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        list<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        List<gii__SalesOrderLine__c> lstSOLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<gii__ServiceTicket__c> lstservTicket = giic_Test_DataCreationUtility.insertServTicket();
        List<gii__ServiceTicketLine__c> lstservTicketLine = giic_Test_DataCreationUtility.insertServTicketLine(lstservTicket);

        lstSOLine[0].gii__ServiceTicket__c = lstservTicket[0].id  ;
        lstSOLine[0].gii__ServiceTicketLine__c = lstservTicketLine[0].id ;
        update lstSOLine;
        lstservTicketLine[0].giic_SalesOrder__c = lstSalesOrder[0].id  ;
        lstservTicketLine[0].giic_SalesOrderLine__c = lstSOLine[0].id ;
        update lstservTicketLine;
        
        List<gii__SalesOrderLine__c> lstSOLine1 = [SELECT Id,Name,giic_Product__c,gii__SalesOrder__r.gii__Account__c,
                                                  gii__SalesOrder__r.giic_Site__c ,gii__SalesOrder__r.giic_Notes__c,
                                                  gii__Product__c,gii__Site__c, gii__UpdateAsset__c,
                                                  gii__SalesOrder__c,gii__OpenQuantity__c,
                                                  gii__SalesOrder__r.giic_Site__r.name,
                                                  gii__Product__r.giic_New_Certification_Training_Required__c,
                                                  gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c, 
                                                  gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.gii__Certification__c,
                                                  gii__Product__r.giic_Certification__c ,
                                                  gii__Product__r.gii__SerialControlled__c,
                                                  
                                                  gii__ServiceTicketLine__c
                                                  FROM gii__SalesOrderLine__c  ];
        
        lstSOLine1[0].gii__Product__r.gii__SerialControlled__c = true;
      //  lstSOLine1[0].gii__SalesOrder__c =lstSalesOrder[0].id;
    //     = 'Open';
        update lstSOLine1;
                      
        lstSOLine =lstSOLine1;
        system.debug('lstSOLine:::T:'+lstSOLine);
         system.debug('lstSOLine:t:::'+lstSOLine.size());
         system.debug('1:::T:'+lstSOLine[0].gii__Product__r.gii__SerialControlled__c);
        // system.debug('2:::T:'+lstSOLine[0].gii__LineStatus__c);
         //system.debug('3:::T:'+lstSOLine[0].gii__OpenQuantity__c);
         //system.debug('3:::T:'+lstSOLine[0].gii__ServiceTicketLine__c);

        
        
     //lstSOLine[0].gii__LineStatus__c ='Open';
 
     //lstSOLine[0].gii__Product__r.gii__SerialControlled__c = true;
        //update lstSOLine;
       
        test.startTest();
        Giic_SetupInstallation.getSalesOrderLines(lstSalesOrder[0].id);
        test.stopTest();
        
    }
    
    @isTest static void testMethodCreateServiceTicket() {
        
        list< Giic_SetupInstallation.salesOrderLineDetailWrapper> wrapperList = new list< Giic_SetupInstallation.salesOrderLineDetailWrapper>();
        Giic_SetupInstallation.salesOrderLineDetailWrapper wrapper = new Giic_SetupInstallation.salesOrderLineDetailWrapper();
        
        
        list<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        List<gii__SalesOrderLine__c> lstSOLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
        List<gii__Warehouse__c> lstWarehouse = giic_Test_DataCreationUtility.insertWarehouse();
        
        List<gii__SalesOrderLine__c> corrctList = [SELECT Id,Name ,giic_TransferOrderQty__c,
                                                   gii__SalesOrder__r.Id ,gii__Product__c,
                                                   gii__SalesOrder__r.name,
                                                   gii__Product__r.Id,giic_Product__c,
												   gii__SalesOrder__r.gii__Account__c,
                                                  gii__SalesOrder__r.giic_Site__c ,
												  gii__SalesOrder__r.giic_Notes__c,
                                                  gii__Site__c, gii__UpdateAsset__c,
                                                  gii__SalesOrder__c,gii__OpenQuantity__c,
                                                  gii__SalesOrder__r.giic_Site__r.name,
                                                  gii__Product__r.giic_New_Certification_Training_Required__c,
                                                  gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c, 
                                                  gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.gii__Certification__c,
                                                  gii__Product__r.giic_Certification__c ,
                                                  gii__Product__r.gii__SerialControlled__c
                                                  FROM gii__SalesOrderLine__c 
                                                   where id =: lstSOLine[0].id];
        
        list<gii__ServiceType__c> listServiceType = new list<gii__ServiceType__c>();
        listServiceType=[select id,name from gii__ServiceType__c where name='Installation'];  
        system.debug('listServiceType::'+listServiceType);
        if(listServiceType == null || listServiceType.size() == 0){
            gii__ServiceType__c insertServiceType= new gii__ServiceType__c();
            insertServiceType.name='Installation';
            listServiceType.add(insertServiceType);
            insert listServiceType;
        }
        system.debug('listServiceType::'+listServiceType);
        wrapper.isSelected =true;
        wrapper.objSOLine = corrctList[0];
        wrapperList.add(wrapper);
        Date requiredDate= System.today();
        
        test.startTest();
        Giic_SetupInstallation.createServiceTicket(wrapperList ,requiredDate );
        Giic_SetupInstallation.getSite(corrctList[0].id);
        test.stopTest();
    } 
    
}