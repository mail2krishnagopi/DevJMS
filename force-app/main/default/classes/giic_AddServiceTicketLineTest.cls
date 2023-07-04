@isTest
public class giic_AddServiceTicketLineTest {
    
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.testSystemPolicyCreation();   
    }
    
    @isTest static void testMethodGetParentRecordDetails() {
        
        list<gii__AssetReference__c> lstAssetReference = giic_Test_DataCreationUtility.insertAssetReference();
         list<gii__Site__c> lstSite = giic_Test_DataCreationUtility.insertSite();
         list<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        
        test.startTest();
        giic_AddServiceTicketLine.getParentRecordDetails(lstAssetReference[0].id);
        giic_AddServiceTicketLine.getParentRecordDetails(lstSite[0].id);
        giic_AddServiceTicketLine.getParentRecordDetails(lstAccount[0].id);
        test.stopTest();
        
        
    }
   
    @isTest static void testMethodCreateServiceTicket() {
        
        list< giic_AddServiceTicketLine.assetReferenceWrapper> wrapperList = new list< giic_AddServiceTicketLine.assetReferenceWrapper>();
         giic_AddServiceTicketLine.assetReferenceWrapper wrapper = new giic_AddServiceTicketLine.assetReferenceWrapper();
          
        
         list<gii__AssetReference__c> lstAssetReference = giic_Test_DataCreationUtility.insertAssetReference();
        
         system.debug('lstAssetReference >>:-- '+lstAssetReference[0]); 
        system.debug('lstAssetReference >>:-- '+lstAssetReference[0].id); 
        
        wrapper.prodCode = '12345';
        wrapper.objApiName = 'gii__AssetReference__c';
        wrapper.isSelected   = true;
        wrapper.objAssetRef = lstAssetReference[0];
        
        wrapperList.add(wrapper);
        gii__ServiceType__c  insertServiceType = new gii__ServiceType__c();
        insertServiceType.name ='testt';
        insert insertServiceType ;
        
        String priority ='Critical';
        String ServiceType =  insertServiceType.id;
        String trouble  = 'yest';
        String objName ='gii__AssetReference__c';
        
        list< giic_AddServiceTicketLine.typeWrapperClass> typewrapperList = new list< giic_AddServiceTicketLine.typeWrapperClass>();
         giic_AddServiceTicketLine.typeWrapperClass typeWrapper = new giic_AddServiceTicketLine.typeWrapperClass();
          typeWrapper.typeOfId   =insertServiceType.id ;
         typeWrapper.assestId = lstAssetReference[0].id;
         typewrapperList.add(typeWrapper);
        
        list<giic_AddServiceTicketLine.troubleWrapperClass> troublewrapperList = new list< giic_AddServiceTicketLine.troubleWrapperClass>();
         giic_AddServiceTicketLine.troubleWrapperClass troubleWrapper = new giic_AddServiceTicketLine.troubleWrapperClass();
         troubleWrapper.troubleVal   = 'tess';
        troubleWrapper.assestId = lstAssetReference[0].id;
         troublewrapperList.add(troubleWrapper);
        
       
        system.debug('wrapperList >>:-- '+wrapperList); 
         test.startTest();
        giic_AddServiceTicketLine.createServiceTicket(wrapperList,priority ,ServiceType ,trouble,objName ,typeWrapperlist ,troubleWrapperlist );
         
        test.stopTest();
        
        
    }
    
    @isTest static void testMethodGetAssetReferenceList() {
        
        list<gii__AssetReference__c> lstAssetReference = giic_Test_DataCreationUtility.insertAssetReference();
         list<gii__Site__c> lstSite = giic_Test_DataCreationUtility.insertSite();
         list<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        
        test.startTest();
        giic_AddServiceTicketLine.getAssetReferenceList(lstAssetReference[0].id);
        giic_AddServiceTicketLine.getAssetReferenceList(lstSite[0].id);
        giic_AddServiceTicketLine.getAssetReferenceList(lstAccount[0].id);
        test.stopTest();
        
        
    }
 
    @isTest static void testMethodSearchAssetReferencet() {
        
        list<gii__AssetReference__c> lstAssetReference = giic_Test_DataCreationUtility.insertAssetReference();
         list<gii__Site__c> lstSite = giic_Test_DataCreationUtility.insertSite();
        // list<Account> lstAccount = giic_Test_DataCreationUtility.insertConsumerAccount();
        
        system.debug('lstAssetReference>>>>'+ lstAssetReference);
        system.debug('lstSite>>>>'+ lstSite);
       
        
        test.startTest();
        giic_AddServiceTicketLine.searchAssetReference(lstAssetReference[0].id,lstSite[0].id);
        giic_AddServiceTicketLine.searchAssetReference('',lstSite[0].id);
        giic_AddServiceTicketLine.searchAssetReference(lstAssetReference[0].id,'');
        test.stopTest();
        
        
    }
     @isTest static void testMethodParentRecordWrapper() {
         
         test.startTest();
         list< giic_AddServiceTicketLine.parentRecordWrapper> wrapperList = new list< giic_AddServiceTicketLine.parentRecordWrapper>();
         giic_AddServiceTicketLine.parentRecordWrapper wrapper = new giic_AddServiceTicketLine.parentRecordWrapper();
         list<gii__AssetReference__c> lstAssetReference = giic_Test_DataCreationUtility.insertAssetReference();
         
         wrapper.objApiName ='gii__AssetReference__c';
         wrapper.recordId = lstAssetReference[0].id;
         
         test.stopTest();
     }
    
}