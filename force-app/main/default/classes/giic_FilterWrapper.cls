/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : Filter Wrapper Class
*************************************************************************************/
public with sharing class giic_FilterWrapper {
        //Variables Declared
        @AuraEnabled public String planningCycleId;
        @AuraEnabled public String planningCycleName;
        @AuraEnabled public String strReportingPeriod;
        @AuraEnabled public Integer numOfPeriods;
        @AuraEnabled public Date asOfDate;
        @AuraEnabled public gii__DemandForecastSetup__c objDemandForecastSetup;
        @AuraEnabled public Map<String,List<String>> mapCountryLegalEntry;
        @AuraEnabled public Map<String,List<gii__Warehouse__c>> mapLegalEntityWarehouse;
        @AuraEnabled public String searchtext;
        @AuraEnabled public gii__Warehouse__c selectedWarehouse;
        @AuraEnabled public String countryValue;
        @AuraEnabled public String legalEntityVal;
        @AuraEnabled public String productCategory;
        @AuraEnabled public String supplier;
        @AuraEnabled public boolean isApprover;
        @AuraEnabled public boolean productionPlanEditable;
        @AuraEnabled public list<gii__ProductGroup__c> lstProductGroups;
        @AuraEnabled public list<Account> lstAccout;
        @AuraEnabled public Map<String,Map<String,List<String>>> mapRegionCountry;
        @AuraEnabled public String lstRegion;
        @AuraEnabled public String lstCountry;
        @AuraEnabled public String lstLegalEntity;
        @AuraEnabled public String lstWarehouse;
        @AuraEnabled public String lstProductGroup;
        @AuraEnabled public String lstAccount;
        @AuraEnabled public String setupRegion;
        @AuraEnabled public String subCategory1Value;
        @AuraEnabled public String subCategory2Value;
        @AuraEnabled public String skuVal;
        @AuraEnabled public String searchProductName;
        @AuraEnabled public boolean regionCheck;
        @AuraEnabled public boolean supplierCheck;
        @AuraEnabled public String warehouse;
        @AuraEnabled public String productValue;
        @AuraEnabled public String productionLine;
        @AuraEnabled public String planName;
        @AuraEnabled public List<gii__DemandForecastSetup__c> lstDFS;
        @AuraEnabled public String searchSupplierName;
        @AuraEnabled public String objectAPIName;
        @AuraEnabled public Date startDate;
        @AuraEnabled public String countryVal;
        @AuraEnabled public String leVal;
        @AuraEnabled public List<Report> lstReports;
        @AuraEnabled public boolean isActive;
        @AuraEnabled public Decimal noOfSkU;
        //Constructor
        public giic_FilterWrapper()
        {
            numOfPeriods = 12;
            isActive = false;
            mapCountryLegalEntry= new Map<String,List<String>>();
            mapLegalEntityWarehouse = new Map<String,List<gii__Warehouse__c>>();
            selectedWarehouse =new gii__Warehouse__c();
            lstProductGroups = new List<gii__ProductGroup__c>();
            lstAccout = new List<Account>();
            mapRegionCountry = new Map<String,Map<String,List<String>>>();
            lstDFS = new List<gii__DemandForecastSetup__c>();
            planningCycleName='';
            strReportingPeriod='Monthly';
            isApprover = false;
            productionPlanEditable= false;
            regionCheck = false;
            supplierCheck = false;
            lstReports = new List<Report>();
        }
}