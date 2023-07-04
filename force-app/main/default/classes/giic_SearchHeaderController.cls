/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : Class to create seacrh data for supply plan
Reviewer - Soni Jagdale
*************************************************************************************/

public with sharing class giic_SearchHeaderController {

    @AuraEnabled(cacheable = true)
    public static SearchHeaderWrapper getPlanData(String recId){
        SearchHeaderWrapper searchWrap = new SearchHeaderWrapper(); 
        searchWrap.mapRegionCountry = giic_CommonUtility.getRegionCountryMDT(); //get region,country and legal entities 
        searchWrap.mapCountryLegalEntry = giic_CommonUtility.getCountyLegalEntryMDT(); //Get legal entity from metadata
        searchWrap.mapLegalEntityWarehouse = giic_CommonUtility.getWarehouseforLegalEntity(); //Get warehouse for legal Entity from metadata
        searchWrap.lstProductGroups = [select Id, Name from gii__ProductGroup__c limit 15];
        searchWrap.lstSupplier = [select Id,Name from account where giic_SupplyPlan__c = true];
        searchWrap.asOfDate = [select id,name,gii__AsofDate__c from gii__SupplyPlanCycle__c where id =:recId].gii__AsofDate__c;
        return searchWrap;
    }

    //Wrapper Class to hold header data for search filter
    public class SearchHeaderWrapper{
        //Variables declared
        @AuraEnabled public Integer numOfPeriods;
        @AuraEnabled public String countryValue;
        @AuraEnabled public String legalEntityVal;
        @AuraEnabled public String productCategoryId;
        @AuraEnabled public String subCategory1;
        @AuraEnabled public String subCategory2;
        @AuraEnabled public String selectedWarehouseId;
        @AuraEnabled public Date asOfDate;
        @AuraEnabled public Map<String,List<String>> mapCountryLegalEntry;
        @AuraEnabled public Map<String,List<gii__Warehouse__c>> mapLegalEntityWarehouse;
        @AuraEnabled public Map<String,Map<String,List<String>>> mapRegionCountry;
        @AuraEnabled public list<gii__ProductGroup__c> lstProductGroups;
        @AuraEnabled public list<Account> lstSupplier;
        @AuraEnabled public String lstRegion;
        @AuraEnabled public String lstCountry;
        @AuraEnabled public String lstLegalEntity;
        @AuraEnabled public String lstWarehouse;
        @AuraEnabled public String lstProductGroup;
        @AuraEnabled public String supplier;
        public SearchHeaderWrapper(){
            numOfPeriods = 12;
            productCategoryId = '';
            asOfDate = System.today();
            selectedWarehouseId = '';
            mapCountryLegalEntry = new Map<String,List<String>>();
            mapLegalEntityWarehouse = new Map<String,List<gii__Warehouse__c>>();
            mapRegionCountry = new Map<String,Map<String,List<String>>>();
            lstProductGroups = new List<gii__ProductGroup__c>();
            lstSupplier = new List<Account>();
        }
    }
}