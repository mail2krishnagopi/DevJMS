/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : Class to process all activities related to Search Filter
Reviewer - Akash Garg
*************************************************************************************/
public with sharing class giic_CommonSearchFilterCtlr {

    /* Method Name : searchFilterData
     * Description : creates giic_FilterWrapper from filters and supply plan cycle record
     * Return Type : giic_FilterWrapper
     * Parameter : supply plan cycle record Id,Object Name
     */
    @AuraEnabled
    public static giic_FilterWrapper searchFilterData(String recId, String objectApiName) {

        //variable declaration
        giic_FilterWrapper filterWrap = new giic_FilterWrapper();
        try {
            if (recId != null && objectApiName != null) {
                if (objectApiName == giic_Constants.SUPPLYPLANCYCLE) {
                    // query DFS record for production plan
                    gii__SupplyPlanCycle__c spcRecord = [SELECT Id, Name, gii__AsofDate__c, gii__AssignmentGroup__c, gii__BusinessHours__c, gii__CountryPriority__c,
                        gii__CreateCPO__c, gii__Description__c, gii__ForecastPriority__c, gii__MonthsSKU__c, gii__MonthsSubCategory1__c,
                        gii__MonthsSubCategory2__c, gii__PlanningHorizon__c, gii__Product__c, gii__ProfitPriority__c, gii__PurposeOrderPriority__c,
                        gii__RevenuePriority__c, gii__ReviewTime__c, OwnerId FROM gii__SupplyPlanCycle__c where id =: recId LIMIT 1
                    ];
                    if (spcRecord != null) {
                        filterWrap.planningCycleId = recId;
                        filterWrap.planningCycleName = spcRecord.Name;
                        filterWrap.numOfPeriods = Integer.valueOf(spcRecord.gii__PlanningHorizon__c);
                        filterWrap.asOfDate = spcRecord.gii__AsofDate__c;
                        filterWrap.strReportingPeriod = giic_Constants.WEEKLY;
                    }
                }else if(objectApiName == giic_Constants.DEMANDPLANCYCLE){
                    gii__DemandForecastCycle__c dfsRecord = [select id, gii__Active__c,giic_NoofMonthofSKU__c,name, gii__StartDate__c, gii__EndDate__c, gii__AllowRollingForecast__c,
                                gii__AllocationFrom__c, gii__AsofDate__c, gii__Period__c, gii__FrozenZonePeriodCount__c,gii__SlushyZonePeriodCount__c
                                from gii__DemandForecastCycle__c where id=:recId limit 1];
                    if(dfsRecord != null){
                        filterWrap.planningCycleId = recId;
                        filterWrap.planningCycleName = dfsRecord.Name;
                        //filterWrap.numOfPeriods = 12;
                        filterWrap.numOfPeriods = Integer.ValueOf(dfsRecord.giic_NoofMonthofSKU__c);
                        filterWrap.noOfSkU = dfsRecord.giic_NoofMonthofSKU__c;
                        filterWrap.asOfDate = dfsRecord.gii__AsofDate__c;
                        filterWrap.strReportingPeriod = giic_Constants.MONTHLTY;
                        filterWrap.startDate = dfsRecord.gii__StartDate__c;
                        filterWrap.isActive = dfsRecord.gii__Active__c;
                    }
                }
                filterWrap.mapRegionCountry = giic_CommonUtility.getRegionCountryMDT();
                filterWrap.lstProductGroups = [select id, name from gii__ProductGroup__c limit 15];
                filterWrap.lstAccout = [select id,name from Account where giic_SupplyPlan__c=true limit 20];
            }
        } catch (Exception e) {
            System.debug('Exception:' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
        return filterWrap;
    }

    /* Method Name : getRegionDemandForecastSetup
     * Description : get Region related Demand Forecast Setup for Production plan,Supply Plan,Demand Plan Record  
     * Return Type : List<gii__DemandForecastSetup__c>
     * Parameter : Demand forecast setup record Id,Object Name,Region,filterWrapper
     */
    @AuraEnabled(cacheable = true)
    public static giic_FilterWrapper getRegionDemandForecastSetup(String recId, String objectApiName,String filterWrapStr) {
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapStr, giic_FilterWrapper.class);
        String region = filterWrap.setupRegion;
        if(recId != null && objectApiName != null && region !=null) {
            filterWrap.isApprover = giic_CommonUtility.isLoggedInUserApprover(recId,filterWrap.planName,region);
            filterWrap.lstDFS = giic_CommonUtility.getDemandForecastSetup(recId,filterWrap.planName,region);
        }
        return filterWrap;
    }
}