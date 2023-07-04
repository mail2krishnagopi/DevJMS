@isTest(SeeAllData=true) 
public class giic_generatePDFLabelControllerTest {
   /* @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }*/
    @isTest static void getServiceTicketLineTest(){
        // giic_Test_DataCreationUtility.testSystemPolicyCreation();   
       /* List<gii__PickListDetail__c> picklistDetails = new List<gii__PickListDetail__c>();
        
        List<Account> lstAccount=giic_Test_DataCreationUtility.insertConsumerAccount();
        List<gii__Warehouse__c> lstWarehouse=giic_Test_DataCreationUtility.insertWarehouse();
        List<gii__Product2Add__c> lstProd=giic_Test_DataCreationUtility.insertProduct();
        
        List<gii__Carrier__c> lstCarrier=giic_Test_DataCreationUtility.createCarrier();
        
        List<gii__Location__c> locList = new List<gii__Location__c>();
        gii__Location__c loc = new gii__Location__c();
        loc.name ='test111111';
        loc.gii__Warehouse__c =lstWarehouse[0].id;
        loc.gii__BinControlled__c = false  ;
        loc.giic_Picklist_Sequence__c  = 12 ;
        
        gii__Location__c loc1 = new gii__Location__c();
        loc1.name ='test222222';
        loc1.gii__Warehouse__c =lstWarehouse[0].id;
        loc1.gii__BinControlled__c = true  ;
        loc1.giic_Picklist_Sequence__c  = 13 ;
        
        locList.add(loc);
        locList.add(loc1);
        insert locList;
        
        List<gii__LocationBin__c> locBinList = new List<gii__LocationBin__c>();
        gii__LocationBin__c locBin = new gii__LocationBin__c();
        locBin.name ='01B001';
        locBin.gii__Location__c =locList[1].id;
        
        gii__LocationBin__c locBin1 = new gii__LocationBin__c();
        locBin1.name ='01B001';
        locBin1.gii__Location__c =locList[1].id;
        
        locBinList.add(locBin);
        locBinList.add(locBin1);
        insert locBinList;
        
         List<gii__SalesOrder__c> lstSalesOrder = giic_Test_DataCreationUtility.insertSalesOrder();
        List<gii__SalesOrderLine__c> lstSalesOrderLine = giic_Test_DataCreationUtility.insertSOLine(lstSalesOrder);
         
        List<gii__InventoryReserve__c> listIR  = [ select id , name,gii__Product__c,
                                                   gii__Location__c ,gii__LocationBin__c 
                                                  from gii__InventoryReserve__c ];
        listIR[0].gii__Location__c =locList[0].id;
        update listIR;
        system.debug('listIR#####:: '+listIR);
        system.debug('listIR#####::size '+listIR.size());

        gii__PickList__c  pkl = new gii__PickList__c();
        pkl.gii__PicklistSequence__c   = 10 ;
        pkl.gii__SalesOrder__c   = lstSalesOrder[0].id ;
        pkl.gii__Product__c   = lstProd[0].id ; 
        pkl.gii__Status__c ='Created';
        insert pkl;
*/
        
        list<gii__PickList__c> pkllist = [select id from gii__PickList__c limit 1 ];
            system.debug('pkllist#####:: '+pkllist);
        List<gii__PickListDetail__c> picklistDetailList =[select id,name,gii__Product__r.giic_Picklist_Detail_Barcode_Image__c,
		giic_Picklist_Detail_Barcode_Image__c,gii__Product__r.gii__Description__c,
		gii__Product__r.gii__PrimarySupplier__r.name,gii__SalesOrder__r.name,
		gii__TransferOrder__r.name from gii__PickListDetail__c where gii__PickList__r.id= :pkllist[0].id];
        List<ID> recordIds = new List<ID>();
        for(gii__PickListDetail__c eachPickDetail:picklistDetailList){
            recordIds.add(eachPickDetail.id);                
        }
         String idsParam = String.join(recordIds, ',');
        
        // Set the 'ids' parameter on the current page
        //Test.setCurrentPageReference(new PageReference());
        
         ApexPages.currentPage().getParameters().put('ids', idsParam);
        Test.startTest();
        // Instantiate the controller
        giic_generatePDFLAbelController controller = new giic_generatePDFLAbelController();
        Test.stopTest();
    }
}