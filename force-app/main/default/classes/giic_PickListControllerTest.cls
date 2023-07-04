@IsTest
public class giic_PickListControllerTest {
    @testSetup static void setup() {
       // giic_Test_DataCreationUtility.getTestClassUser();
        giic_Test_DataCreationUtility.testSystemPolicyCreation();  
        
    }
    
    @isTest
    static void testPostMethod() {
        
        
        
        gii__Carrier__c oCarr1 = new gii__Carrier__c();
        oCarr1.Name = 'test222';
        oCarr1.gii__Description__c = 'test111';
        oCarr1.gii__NoChargeReason__c = 'Promotion';
        insert oCarr1;
        
        
        List<gii__Warehouse__c>  lstWarehouse = new List<gii__Warehouse__c>();
        gii__Warehouse__c objWarehouse = new gii__Warehouse__c();
        objWarehouse.Name='E & S - Washington - Wylie';  
        // objWarehouse.gii__WareHouseCountry__c ='USA';
        lstWarehouse.add(objWarehouse);
        
        gii__Warehouse__c objWarehouse2 = new gii__Warehouse__c();
        objWarehouse2.Name='E & S - JMS WESTMINSTER CO';  
        //objWarehouse2.gii__WareHouseCountry__c ='USA';
        lstWarehouse.add(objWarehouse2);  
        insert lstWarehouse;
        
        
        List<gii__Location__c> locList = new List<gii__Location__c>();
        gii__Location__c loc = new gii__Location__c();
        loc.name ='test';
        loc.gii__Warehouse__c =lstWarehouse[0].id;
        loc.gii__BinControlled__c = false  ;
        loc.giic_Picklist_Sequence__c  = 1 ;
        
        gii__Location__c loc1 = new gii__Location__c();
        loc1.name ='test1';
        loc1.gii__Warehouse__c =lstWarehouse[0].id;
        loc1.gii__BinControlled__c = true  ;
        loc1.giic_Picklist_Sequence__c  = 1 ;
        
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
        


        
        
        
    }
}