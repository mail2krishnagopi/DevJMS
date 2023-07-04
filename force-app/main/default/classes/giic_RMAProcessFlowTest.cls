@isTest
public class giic_RMAProcessFlowTest {
       public static List<Account> lstAccount{get;set;}
       public static List<gii__AssetReference__c> lstAssetReference;
       public static List<gii__Site__c>  lstSite;
    
    @testSetup static void setup() {
        giic_Test_DataCreationUtility.getTestClassUser();
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
       //giic_Test_DataCreationUtility.insertSite();

        //giic_Test_DataCreationUtility.insertAssetReference();
    }

    @isTest 
    public static void initiateRMAProcessTest(){
        

            Account objAccount = new Account();
            //objAccount.RecordTypeId = recortTypeId;
            objAccount.OwnerId = UserInfo.getUserId();
            objAccount.Name = 'Test Account';
            objAccount.BillingStreet = '8 Clement Drive';
            objAccount.BillingCountry = 'United States';
            objAccount.BillingState = 'Ohio';
            objAccount.BillingPostalCode = '08083';
            //objAccount.BillingState = 'New Jersey';
            objAccount.BillingCity = 'Somerdale'; 
            // objAccount.BillingStreet = '8 Clement Drive';  
            objAccount.ShippingStreet = '8 Clement Drive';
            objAccount.ShippingCountry = 'United States';
            objAccount.ShippingPostalCode = '08083';
            //objAccount.ShippingState = 'New Jersey';
            objAccount.ShippingCity = 'Somerdale'; 
            objAccount.ShippingState = 'Ohio';
            objAccount.ShippingStreet = '8 Clement Drive';
        //lstAccount.add(objAccount);
        //objAccount.JMS_Skip_Standard_Account_Duplicate_Rule__c = true;
          
         insert objAccount;
        
        gii__Site__c siteD = new 	gii__Site__c();
        siteD.name='test';
        siteD.gii__Account__c = objAccount.Id;
        //lstSite.add(siteD);
        insert siteD ;
        
                 Product2 objpro = new Product2(Name = 'Sel Pro PD Dry 32#-Dog',
                                       IsActive = true,
                                       ProductCode = '18325',
                                       Family = 'Beverage'
                                      );
        insert objpro;
        
        List<gii__Product2Add__c> lstProd = [SELECT Id, gii__LotControlled__c, gii__SellingUnitofMeasure__c, 
                   gii__SellingUnitofMeasure__r.Name,gii__StockingUnitofMeasure__c, 
                   gii__StockingUnitofMeasure__r.name, gii__ProductReference__c, 
                   gii__ProductReference__r.Name, gii__NonStock__c, gii__ProductReference__r.ProductCode, 
                   gii__ProductReference__r.Family, gii__Style__c  from gii__Product2Add__c 
                   WHERE gii__ProductReference__c = :objpro.Id];
        
                gii__AssetReference__c assetD = new 	gii__AssetReference__c();
        assetD.name='test';
        assetD.gii__Site__c= siteD.id;
        assetD.gii__ProductReference__c= lstProd[0].id;
        assetD.gii__Account__c= objAccount.Id ;
        //lstAssetReference.add(assetD);
        insert assetD;
        
        System.debug('hhh ' + objAccount);
        System.debug('hhh ' + siteD);
        // lstSite[0].gii__AssetReference__c=lstAssetReference[0].id;
        //lstSite.add(lstSite[0]);
        //pupdate lstSite;

        system.debug('updated Site list');
         List<gii__ServiceTicket__c>lstSerTicket=new List<gii__ServiceTicket__c>();
        //lstSerTicket=giic_Test_DataCreationUtility.insertServTicket();
        
        gii__ServiceTicket__c  servTicket = new gii__ServiceTicket__c();
        servTicket.gii__Country__c='United States';
        servTicket.gii__Account__c=objAccount.id;
        servTicket.gii__ServiceDueDate__c = system.today().addDays(3);
        insert servTicket ;
        
        List<gii__ServiceTicketLine__c>lstSerTicketLine=new List<gii__ServiceTicketLine__c>();
        //lstSerTicketLine= giic_Test_DataCreationUtility.insertServTicketLine(lstSerTicket);
        
        gii__ServiceTicketLine__c servTicketLine = new gii__ServiceTicketLine__c();
        servTicketLine.gii__Quantity__c = 1;
        servTicketLine.gii__ServiceTicket__c = servTicket.Id;
        servTicketLine.gii__Product__c = lstProd[0].id;
        lstSerTicketLine.add(servTicketLine);
        insert lstSerTicketLine;
        lstSerTicketLine[0].gii__Site__c=siteD.id;
        lstSerTicketLine[0].gii__AssetReference__c=assetD.id;
        //lstSerTicketLine.add(lstSerTicketLine[0]);
        update lstSerTicketLine;
        
System.debug('lstSerTicketLine');
        System.debug(lstSerTicketLine);
        Test.startTest();
        giic_RMAProcessFlow.initiateRMAProcess(lstSerTicketLine);
        Test.stopTest();
    }
}