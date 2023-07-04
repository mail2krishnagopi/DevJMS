/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : Class to process all activities related to Supply Plan
Reviewer : Akash Garg
*************************************************************************************/

public with sharing class giic_SupplyPlanController {
    
    public Static final String HEADER_DATEFORMAT = 'yy';
    public static boolean isApprove = false; 
    
    /* Method name : searchFilterData
    * Description : This method will get the supply plan cycle & demand forecast setup record data
    * Return Type : FilterWrapper
    * Parameter : Supply Plan Cycle Record ID
    */
    @AuraEnabled
    public static FilterWrapper searchFilterData(String recId, String region){
        FilterWrapper filterWrap = new FilterWrapper();
        String regionNme = '';
        try {
           
            if(recId != null){ // checking supply plan cycle Id
                if(String.isNotBlank(region)){
                    regionNme = region.replace('(','').replace(')','').replaceAll('\'','');
                } 
                List<gii__SupplyPlanCycle__c> spcList = [SELECT Id,Name,gii__AsofDate__c,gii__AssignmentGroup__c,gii__BusinessHours__c,gii__CountryPriority__c,
                                                         gii__CreateCPO__c,gii__Description__c,gii__ForecastPriority__c,gii__MonthsSKU__c,gii__MonthsSubCategory1__c,
                                                         gii__MonthsSubCategory2__c,gii__PlanningHorizon__c,gii__Product__c,gii__ProfitPriority__c,gii__PurposeOrderPriority__c,
                                                         gii__RevenuePriority__c,gii__ReviewTime__c,OwnerId FROM gii__SupplyPlanCycle__c where id=:recId LIMIT 1];
                if(!spcList.isEmpty()){
                    filterWrap.objSupplyPlanCycle = spcList[0];
                    List<gii__DemandForecastSetup__c> dfSetupList =  giic_CommonUtility.getDemandForecastSetup(recId,giic_Constants.SUPPLYPLAN,regionNme);
                    filterWrap.objDemandForecastSetup = (!dfSetupList.isEmpty() ? dfSetupList[0] : null);
                    filterWrap.isApprover = giic_CommonUtility.isLoggedInUserApprover(recId,giic_Constants.SUPPLYPLAN,regionNme);
                }
                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return filterWrap;
    }   
    
    /* Method name : getResultData
    * Description : This method will return the result of supply plan netting and netting lines
    * Return Type : List<supplyPlanNettingWrapper> 
    * Parameter : JSON string of FilterWrapper,  JSON string of SearchHeaderWrapper
    */
    @AuraEnabled(cacheable=true)
    public static List<SupplyPlanNettingWrapper> getResultData(String filterWrapStr,string searchHeaderData){
        FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filterWrapStr,FilterWrapper.class);
        
        SearchHeaderWrapper searchHeaderWrap= (SearchHeaderWrapper) JSON.deserialize(searchHeaderData,SearchHeaderWrapper.class);
        
        List<MapWrapper> cellHeader = prepareCellHeader(filterWrapStr,searchHeaderData);
        List<SupplyPlanNettingWrapper> spnwList = prepareCellRow(filterWrap,cellHeader,searchHeaderData);
        
        return spnwList;
    }
    
    /* Method name : prepareCellHeader
* Description : This method will prepare the header of the table columns
* Return Type : List<MapWrapper> 
* Parameter : JSON string of FilterWrapper,  JSON string of SearchHeaderWrapper
*/
    @AuraEnabled(cacheable=true)
    public static List<MapWrapper> prepareCellHeader(String filtersearch,string searchHeaderData)
    {
        
        
        List<MapWrapper> cellHeader =new List<MapWrapper>(); // contains the list of table's header cell accoding to number of months
        try{
            FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filtersearch,FilterWrapper.class);
            
            SearchHeaderWrapper searchHeaderWrap= (SearchHeaderWrapper) JSON.deserialize(searchHeaderData,SearchHeaderWrapper.class);
            date startDate = searchHeaderWrap.asOfDate != null ? searchHeaderWrap.asOfDate.toStartOfMonth() : System.today().toStartOfMonth();
            Integer noOfperiod = searchHeaderWrap.numOfPeriods - 1;
            date endDate = startDate.addmonths(noOfperiod);//date endDate = filterWrap.gii__EndDate__c;
            //  Map<String,Object> dtRangeMap = new Map<String,Object>();
            if(filterWrap.strReportingPeriod =='Monthly')
            {
                for(;startDate<=endDate;startDate=startDate.addMonths(1))
                {
                    MapWrapper cellWrap = new MapWrapper();
                    cellWrap.key = getCellKey(startDate,new Map<String,Object>());
                    DateTime dtTemp = datetime.newInstance(startDate.year(), startDate.month(),startDate.day());
                    cellWrap.value =  cellWrap.monthKey.get(startDate.month()) + '-' + dtTemp.format(HEADER_DATEFORMAT);
                    cellWrap.monthKey=null;
                    cellHeader.add(cellWrap);
                }
                
            }
        }catch(Exception e){
            System.debug('Exception:'+e);
            System.debug('Exception line:'+e.getLineNumber());
        }
        return cellHeader;
    }
    
    /* Method name : prepareDateKeyCell
* Description : This method will store the month start date as key and value as a supply plan for that month
* Return Type : Map<String,List<supplyPlanNettingMonth>>  
* Parameter : Date,  JSON string of SearchHeaderWrapper
*/
    @AuraEnabled
    public static Map<String,List<SupplyPlanNettingMonth>> prepareDateKeyCell(Date startDate,SearchHeaderWrapper searchHeaderWrap){
        // key = the AsofDate's month
        Map<String,List<SupplyPlanNettingMonth>> supplyPlanNettingLineWrapperMap = new Map<String,List<SupplyPlanNettingMonth>>();
        supplyPlanNettingLineWrapperMap.put(startDate.format(),new List<SupplyPlanNettingMonth>());
        for(integer i = 1;i < searchHeaderWrap.numOfPeriods; i++){
           
            supplyPlanNettingLineWrapperMap.put(startDate.addMonths(i).format(),new List<SupplyPlanNettingMonth>());
        }
        
        return supplyPlanNettingLineWrapperMap;
    }
    
    /* Method name : prepareCellRow
* Description : This method will prepare Supply Plan Netting data and its all related Netting Line data in the list of wrapper.
* Return Type : List<supplyPlanNettingWrapper> 
* Parameter : FilterWrapper JSON, list of  MapWrapper, JSON string of SearchHeaderWrapper
*/
    @AuraEnabled
    public static List<SupplyPlanNettingWrapper> prepareCellRow(FilterWrapper searchFilterStr, List<MapWrapper> cellHeader,string searchHeaderData)
    {
        
        List<SupplyPlanNettingWrapper> spnWList = new List<SupplyPlanNettingWrapper>(); // carry the list of Supply Plan Netting Records
        
        try{
            SearchHeaderWrapper searchHeaderWrap= (SearchHeaderWrapper) JSON.deserialize(searchHeaderData,SearchHeaderWrapper.class); // it contains the values of search filter
           
            Date asofDate = searchHeaderWrap.asOfDate  != null ? searchHeaderWrap.asOfDate .toStartOfMonth() : System.today().toStartOfMonth();
            Integer noOfperiod = searchHeaderWrap.numOfPeriods - 1;
            Date asofEndDate = AsofDate.addmonths(noOfperiod);
            Map<String,ResultWrapper> rowResultMap = new Map<String,ResultWrapper>();
            DateTime dT1 = DateTime.newInstance(asofDate.year(), asofDate.month(), asofDate.day());
            DateTime dT2 = DateTime.newInstance(asofEndDate.year(), asofEndDate.month(), asofEndDate.day());
            
            String sDate = dT1.formatGMT('yyyy-MM-dd');
            String eDate = DT2.formatGMT('yyyy-MM-dd');
            
            String soqlNettingLineWhereCondition = '';
            
            
            // making where condition for Supply plan Netting records
            if(String.isNotBlank(searchHeaderWrap.lstRegion)){
                soqlNettingLineWhereCondition +=' AND giic_Region__c IN '+searchHeaderWrap.lstRegion;
            }
            if(String.isNotBlank(searchHeaderWrap.lstCountry)){
                soqlNettingLineWhereCondition += ' AND giic_Country__c IN '+searchHeaderWrap.lstCountry;
            }
            if(String.isNotBlank(searchHeaderWrap.lstLegalEntity)){
                soqlNettingLineWhereCondition += ' AND giic_LegalEntity__c In '+searchHeaderWrap.lstLegalEntity;
            }
            if(String.isNotBlank(searchHeaderWrap.lstProductGroup)){
                soqlNettingLineWhereCondition += ' AND gii__Product__r.gii__ProductGroup__r.Name In '+searchHeaderWrap.lstProductGroup;
            }
            
            if(String.isNotBlank(searchHeaderWrap.searchProductName)){
                soqlNettingLineWhereCondition += ' AND gii__Product__c = ' + '\'' +searchHeaderWrap.searchProductName + '\'';
            }
            if(String.isNotBlank(searchHeaderWrap.subCategory1)){
                soqlNettingLineWhereCondition += ' AND gii__Product__r.gii__SubCategory1__c = ' + '\''  +searchHeaderWrap.subCategory1 + '\'';
            }
            if(String.isNotBlank(searchHeaderWrap.subCategory2)){
                soqlNettingLineWhereCondition += ' AND gii__Product__r.gii__SubCategory2__c = ' + '\''  +searchHeaderWrap.subCategory2 + '\'';
            }
            if(String.isNotBlank(searchHeaderWrap.skuCode)){
                List<String> keycs = searchHeaderWrap.skuCode.split('\\|');
                soqlNettingLineWhereCondition += ' AND gii__Product__r.gii__ProductCode__c IN ';
                soqlNettingLineWhereCondition += ':keycs ';
            }
            if(String.isNotBlank(searchHeaderWrap.supplier)){
                soqlNettingLineWhereCondition += ' AND gii__Supplier__c IN ' +searchHeaderWrap.supplier; 
            }
            
            String soqlNettingWhereCondition = '';
            if(String.isNotBlank(searchHeaderWrap.selectedWarehouseId)){
               
                soqlNettingWhereCondition += ' AND '+(' gii__TransferToWarehouse__c ='+'\''+searchHeaderWrap.selectedWarehouseId+'\''); 
            }
            
            
            String soql =  'SELECT gii__buyingUnitofMeasure__c,gii__cpoQuantity__c,gii__leadTime__c,gii__make__c,gii__maximumInventoryQuantity__c,gii__onHandQuantity__c,gii__productCategory__c,gii__productDescription__c,gii__productReference__c,gii__productReference__r.Name,gii__productReference__r.gii__ProductCode__c,gii__productReference__r.giic_Status__c,gii__productReference__r.gii__StandardPrice__c,gii__purchaseOrderQuantity__c,gii__safetyStockQuantity__c,gii__skuCode__c,gii__SupplyPlanCycle__c,gii__TransferToWarehouse__c,giic_Notes__c,gii__TransferToWarehouse__r.Name,Id,Name,OwnerId,gii__productReference__r.gii__ProductGroup__r.Name,gii__productReference__r.gii__ProductGroup__c,gii__productReference__r.gii__MSRP__c,gii__productReference__r.gii__COGS__c,'
                +'(SELECT giic_WeekNumber__c,gii__Product__r.gii__ProductCode__c,giic_SupplierName__c,gii__WeeklyCapacity__r.gii__ActualCapacity__c,giic_LeftOverQuantity__c,giic_WeeklyCapacityUtilizedhour__c,gii__ProductionRateHour__c,giic_WeeklyCapacityUtilizedhour__r.giic_UsedCapacityProductCategory__c,giic_WeeklyCapacityUtilizedhour__r.giic_UsedCapacityProductionLine__c,gii__WeeklyCapacity__c,gii__WeeklyCapacity__r.Name,gii__Address__c,gii__AssignmentGroup__c,gii__AvailabletoSell__c,gii__buyingUnitofMeasure__c,gii__DemandForecastLine__c,gii__DemandOrderDate__c,giic_DemandOrderQuantity__c,gii__DemandOrder__c,gii__DemandOrder__r.gii__DemandQuantity__c,gii__FromWarehouse__r.Name, gii__ExpectedEndofProductionDate__c,gii__ForecastPurpose__c,gii__InTransitleadTime__c,gii__NewDate__c,gii__NewQuantity__c,gii__OnHand__c,gii__OrderQuantity__c,gii__OrderType__c,gii__OriginalDueDate__c,gii__OriginalQuantity__c,gii__PastDueSupply__c,giic_PriorOrderQuantity__c,gii__productCategory__c,gii__productDescription__c,gii__ProductInventory__c,gii__ProductionleadTime__c,gii__ProductionLine__c,gii__Product__c,gii__PurchaseOrderLine__c,gii__PurchaseOrder__c,gii__safetyStockQuantity__c,gii__Share__c,gii__skuCode__c,gii__SourcingGroupRule__c,gii__SourcingSequence__c,gii__SuggestedDockDate__c,gii__SuggestedDueDate__c,gii__SuggestedStartDate__c,giic_Country__c,gii__SupplierList__c,gii__Supplier__c,gii__SupplyPlanCycle__c,gii__SupplyPlanNetting__c,gii__TransferToWarehouse__c,gii__FromWarehouse__c,gii__TransferToWarehouse__r.Name,gii__WarehouseNetwork__c,Id,Name,LastModifiedDate FROM gii__SupplyPlanNettingLines__r'
                + ' where (gii__DemandOrder__c != NULL AND gii__OrderType__c ='+'\''+giic_Constants.CPO+'\''+') AND  (gii__SuggestedStartDate__c >= '+sDate+' AND gii__SuggestedStartDate__c <= ' +eDate+ ' ) '+soqlNettingLineWhereCondition+' ORDER BY gii__SuggestedStartDate__c ASC)'
                +' FROM gii__SupplyPlanNetting__c '
                +' where gii__SupplyPlanCycle__c =' + '\''+searchFilterStr.objSupplyPlanCycle.Id+'\''+soqlNettingWhereCondition 
                +' ';
            
           
            String sql = soql;
            List<gii__SupplyPlanNetting__c> spnList = Database.query(sql);
            
            
            for(gii__SupplyPlanNetting__c spn : spnList)
            {
              
                SupplyPlanNettingWrapper spnWrapper = new SupplyPlanNettingWrapper();
                if(spn.gii__SupplyPlanNettingLines__r.size() > 0){
                    
                    
                   
                    spnWrapper.status = 'Active';
                    spnWrapper.msrp = (spn.gii__productReference__c != null ? spn.gii__productReference__r.gii__MSRP__c : 0);
                    spnWrapper.productStatus = (spn.gii__productReference__c != null ? spn.gii__productReference__r.giic_Status__c : '');
                    spnWrapper.buyingUnitofMeasure = spn.gii__buyingUnitofMeasure__c; 
                    spnWrapper.cpoQuantity = spn.gii__cpoQuantity__c; 
                    //  spnWrapper.demandOrderQuantity = spn.giic_DemandOrderQuantity__c; 
                    spnWrapper.leadTime = spn.gii__leadTime__c; 
                    spnWrapper.make = spn.gii__make__c; 
                    spnWrapper.maximumInventoryQuantity = spn.gii__maximumInventoryQuantity__c; 
                    spnWrapper.onHandQuantity = spn.gii__onHandQuantity__c; 
                    spnWrapper.productCategory = (spn.gii__productReference__c != null ? (spn.gii__productReference__r.gii__ProductGroup__c != null ? spn.gii__productReference__r.gii__ProductGroup__r.Name : '') : ''); 
                    spnWrapper.productDescription = spn.gii__productDescription__c; 
                    spnWrapper.productReference = (spn.gii__productReference__c != null ? spn.gii__productReference__r.Name : ''); 
                    spnWrapper.purchaseOrderQuantity = spn.gii__purchaseOrderQuantity__c; 
                    spnWrapper.safetyStockQuantity = spn.gii__safetyStockQuantity__c; 
                    spnWrapper.skuCode = spn.gii__productReference__r.gii__ProductCode__c;//spn.gii__skuCode__c; 
                    spnWrapper.supplyPlanCycle = spn.gii__SupplyPlanCycle__c; 
                    spnWrapper.transferToWarehouse = (spn.gii__TransferToWarehouse__c != null ? spn.gii__TransferToWarehouse__r.Name : ''); 
                    spnWrapper.id = spn.Id; 
                    spnWrapper.name = spn.Name; 
                    spnWrapper.ownerId = spn.OwnerId;
                    spnWrapper.notes = (spn.giic_Notes__c != null ? spn.giic_Notes__c : '');
                    spnWrapper.rowSpanofSPN = (spn.getSObjects('gii__SupplyPlanNettingLines__r') != null ? spn.getSObjects('gii__SupplyPlanNettingLines__r').size() : 0);
                    spnWrapper.totalCOGS = (spn.gii__productReference__c != null ? spn.gii__productReference__r.gii__COGS__c : 0);
                    
                   
                    
                    //key = supplier
                    Map<String,SupplyPlanNettingLineSupplierWarpper> spnlCountryMap = new Map<String,SupplyPlanNettingLineSupplierWarpper>();
                    //key = warehouse
                    Map<String,SupplyPlanNettingLineSupplierWarpper> spnlWareHouseMap = new Map<String,SupplyPlanNettingLineSupplierWarpper>();
                    Map<String, Set<String>> doqMap = new Map<String, Set<String>>();
                    //key = date format
                    Map<String,List<SupplyPlanNettingMonth>> supplyPlanNettingMonthWarpperMap = prepareDateKeyCell(dT1.date(),searchHeaderWrap);
                    
                    String checkDate = '';
                    decimal doqConcate = 0;
                    //List<supplyPlanNettingMonth> supplyPlanNettingMonthBlankList = new List<supplyPlanNettingMonth>();
                    List<SupplyPlanNettingLineSupplierWarpper> supplyPlanNettingLineSupplierWarpperList = new List<SupplyPlanNettingLineSupplierWarpper>();
                    // Integer SupplyPlanNettingLinesCount = (spn.getSObjects('gii__SupplyPlanNettingLines__r') != null ? spn.getSObjects('gii__SupplyPlanNettingLines__r').size() : 0);
                    Integer count = 0;
                    Integer rowspanCount = 0;
                    Date startDateStore = dT1.date();
                    boolean isFirstRun = true;
                    
                    //key = date format
                    Map<String,SupplyPlanNettingMonth> supplyPlanNettingMonthMap = new Map<String, SupplyPlanNettingMonth>();
                    for(MapWrapper mw : cellHeader){
                        
                        SupplyPlanNettingMonth spnMObj = new SupplyPlanNettingMonth();
                        spnMObj.keyDate = mw.key;
                        spnMObj.demandOrderQuantityTotal = 0;
                        spnMObj.rowspanforDemandOrderQty = 0;
                        
                        spnWrapper.supplyPlanNettingMonthList.add(spnMObj);
                        supplyPlanNettingMonthMap.put(mw.key, spnMObj);
                    }
                    
                    Set<String> allDOIds = new Set<String>();
                    for(gii__SupplyPlanNettingLine__c spnl : spn.getSObjects('gii__SupplyPlanNettingLines__r')){
                        count +=1;
                       
                        spnWrapper.totalSupplyQuantity += (spnl.gii__OrderQuantity__c != null ? spnl.gii__OrderQuantity__c : 0);
                       
                        if( spnl.gii__SuggestedStartDate__c == null )  {continue;}
                        
                        String spnlMonthKey = spnl.gii__SuggestedStartDate__c.toStartOfMonth().format();
                        if(supplyPlanNettingMonthWarpperMap.containsKey(spnlMonthKey)){
                           
                            rowspanCount +=1;
                            //get DO/Month
                            SupplyPlanNettingMonth spnMObj = supplyPlanNettingMonthMap.get(spnlMonthKey); //new supplyPlanNettingMonth();
                           
                            //Step-1: Supplier List
                            // checking the supplier in Netting Line record
                            if(spnl.giic_SupplierName__c != null && spnl.giic_SupplierName__c != ''){  
                                String supplierKey = spnl.giic_SupplierName__c + spnlMonthKey;
                                giic_SupplyPlanController.getSupplierDetails(spnlCountryMap,supplierKey,spnl,spnMObj,searchFilterStr);
                               
                            }
                            ///
                            else if(spnl.gii__FromWarehouse__c != null && spnl.giic_SupplierName__c == null){ // checking the Warehouse in Netting Line record
                                String transferKey = spnl.gii__FromWarehouse__c + spnlMonthKey;
                                giic_SupplyPlanController.getTransferWarehouseDetails(spnlWareHouseMap,transferKey,spnl,spnMObj,searchFilterStr);
                                
                            } 
                            ///
                            else if(spnl.giic_SupplierName__c == null && spnl.gii__FromWarehouse__c == null){ 
                               
                                String supplierKey = spnlMonthKey;
                                giic_SupplyPlanController.getSupplierDetailswarehouse(spnlCountryMap,supplierKey,spnl,spnMObj,searchFilterStr);
                                
                            }
                           
                            /// Transfer case
                            
                            
                            String doKey = spnlMonthKey;
                            if(!allDOIds.contains(spnl.gii__DemandOrder__c)){ // checking demand order on Netting Line
                                giic_SupplyPlanController.getTotalDemandOrder(doqMap,spnlMonthKey,spnMObj,spnl,doKey,spnWrapper);
                                
                                allDOIds.add(spnl.gii__DemandOrder__c);
                            }
                        }
                        checkDate = spnl.gii__SuggestedStartDate__c.toStartOfMonth().format();
                        
                        
                    }
                    spnWList.add(spnWrapper);
                }
                
                
            }
            
           
        }catch(Exception e){
            System.debug('Exception:'+e);
            System.debug('Exception Line:'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
        return spnWList;
        
    }
    
    /* Method name : updateSupplyPlanNettingLines
* Description : This method will update the Supply plan netting & Netting Line data of the each row
* Return Type : List<supplyPlanNettingWrapper> 
* Parameter : String list of supplyPlanNettingWrapper JSON, JSON String of FilterWrapper
*/
    @AuraEnabled 
    public static List<SupplyPlanNettingWrapper> updateSupplyPlanNettingLines(String spnWrapperJSON,String filterWrapStr,string dfsId){
        FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filterWrapStr,FilterWrapper.class);
        boolean isSuccess = false;
        List<SupplyPlanNettingWrapper> spnWrapperList;
        try{
            spnWrapperList = (List<SupplyPlanNettingWrapper>) JSON.deserialize(spnWrapperJSON,List<SupplyPlanNettingWrapper>.class);
           
            
            List<gii__SupplyPlanNetting__c> supplyPlanNettingList = new List<gii__SupplyPlanNetting__c>();
            List<gii__SupplyPlanNettingLine__c> supplyPlanNettingListUpdate = new List<gii__SupplyPlanNettingLine__c>();
            
            for(SupplyPlanNettingWrapper spnWrapper : spnWrapperList){
                gii__SupplyPlanNetting__c spn = new gii__SupplyPlanNetting__c();
                spn.id = spnWrapper.Id;
                spn.giic_Notes__c = spnWrapper.Notes;
                supplyPlanNettingList.add(spn);
                for(SupplyPlanNettingMonth spnMonth : spnWrapper.supplyPlanNettingMonthList){
                    for(SupplyPlanNettingLineSupplierWarpper spnlCWrapper : spnMonth.supplyPlanNettingLineSupplierWarpperList){
                        for(SupplyPlanNettingLineWrapper spnlWrapper : spnlCWrapper.spnlWrapperList){
                           
                            
                            gii__SupplyPlanNettingLine__c spnl = new gii__SupplyPlanNettingLine__c();
                            spnl.id = spnlWrapper.Id;
                            system.debug('isApprove ---'+isApprove);
                            if(isApprove){
                                spnl.giic_DemandForecastSetup__c = dfsId;
                            }
                            spnl.gii__OrderQuantity__c = spnlWrapper.orderQuantity;
                           if(filterWrap.objDemandForecastSetup != null && spnlWrapper.isChanged && filterWrap.objDemandForecastSetup.giic_isCycleFirstRun__c == false){  // Allowing to update prior value before first approval
                                spnl.giic_PriorOrderQuantity__c = spnlWrapper.orderQuantity;
                            }else if(filterWrap.objDemandForecastSetup != null && spnlWrapper.isChanged && filterWrap.objDemandForecastSetup.giic_isCycleFirstRun__c == true){ // Stopping to update prior value after first approval
                                spnlWrapper.tooltipString = 'Prior Quantity: '+spnlWrapper.priorOrderQuantity+', Modified Date: '+spnlWrapper.lastModifiedDate;
                                spnlWrapper.arrowType =   (spnlWrapper.orderQuantity > spnlWrapper.priorOrderQuantity ? 'utility:arrowup' : 'utility:arrowdown');   
                                spnlWrapper.isArrowVisible = (spnlWrapper.orderQuantity != spnlWrapper.priorOrderQuantity ? true : false);                  
                            }
                            if(filterWrap.objDemandForecastSetup == null){
                                spnl.giic_PriorOrderQuantity__c = spnlWrapper.orderQuantity;
                            }
                            supplyPlanNettingListUpdate.add(spnl);
                        }
                    }   
                }
            } 
            
            
            if(!supplyPlanNettingListUpdate.isEmpty()){
                update supplyPlanNettingListUpdate;  
            }
            
            if(!supplyPlanNettingList.isEmpty()){
                update supplyPlanNettingList;
            }
            isSuccess = true;
        }catch(Exception e){
            isSuccess = false;
            System.debug('Exception:'+e);
            System.debug('Exception Line:'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return spnWrapperList;
    }
    
    
    
    /**get Demand Forecast Setup for Demand Forecast Record 
public static List<gii__DemandForecastSetup__c> getDemandForecastSetup(String DFRecId){

List<gii__DemandForecastSetup__c> demandForecastSetupList = [select id,giic_DemandForecastCycle__c, giic_RelatedTo__c,giic_ApprovalStatus__c,giic_isCycleFirstRun__c,giic_Supply_Plan_Cycle__c  from gii__DemandForecastSetup__c
where giic_Supply_Plan_Cycle__c =: DFRecId and giic_RelatedTo__c= :giic_Constants.SUPPLYPLAN];

return demandForecastSetupList;
}*/
    
    /* Method name : submitForApproval
    * Description : This method will create/update and submit the record for approval of Demand Forecast setup
    * Return Type : List<supplyPlanNettingWrapper>
    * Parameter : JSON String of FilterWrapper,supplyPlanNettingWrapper
    */
    @AuraEnabled
    public static List<SupplyPlanNettingWrapper> submitForApproval(String spnWrapperJSON, String nettingLinesStr, String filterWrapStr){ 
        FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filterWrapStr,FilterWrapper.class);
        String region = filterWrap.regionName.replace('(','').replace(')','');
       
        string dfsetupId;       
        boolean isRejected = false;
        List<SupplyPlanNettingWrapper> spnWrapperList;
        
        try{
            //spnWrapperList = updateSupplyPlanNettingLines(spnWrapperJSON,filterWrapStr);
            
            gii__DemandForecastSetup__c objDFS = new gii__DemandForecastSetup__c();
            
            // check demand forecast setup availability to update Approval status
            if(filterWrap.objDemandForecastSetup == null){
               
                objDFS.giic_Supply_Plan_Cycle__c = filterWrap.objSupplyPlanCycle.Id;
                objDFS.giic_RelatedTo__c = giic_Constants.SUPPLYPLAN;
                objDFS.giic_ApprovalStatus__c = giic_Constants.PENDINGFORAPPROVAL;
                objDFS.giic_Region__c = region.replaceAll('\'','');
                insert objDFS;
                if(objDFS!=null)
                {
                    dfsetupId=objDFS.id;
                }
            }else if(filterWrap.objDemandForecastSetup != null && (filterWrap.objDemandForecastSetup.giic_ApprovalStatus__c == giic_Constants.APPUPDATEPLAN || filterWrap.objDemandForecastSetup.giic_ApprovalStatus__c == giic_Constants.REJECTEDPLAN)){
                filterWrap.objDemandForecastSetup.giic_ApprovalStatus__c = giic_Constants.PENDINGFORAPPROVAL;
                update filterWrap.objDemandForecastSetup;
            }
            isApprove = true;
            spnWrapperList = updateSupplyPlanNettingLines(spnWrapperJSON,filterWrapStr,dfsetupId);
            isRejected = true;
        }catch(Exception e){
            System.debug('Exception:'+e);
            System.debug('Exception Line:'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
        return spnWrapperList;
    }
    
    /* Method name : approveRecord
    * Description : This method will approve the record of Demand Forecast setup
    * Return Type : boolean
    * Parameter : JSON String of FilterWrapper,supplyPlanNettingWrapper,String,Boolean
    */
    @AuraEnabled
    public static boolean approveRecord(String spnWrapperJSON,String filterWrapStr,String comment,boolean isAnyRecordUpdate,String planCycleId){
        boolean isApproved = false;
        List<SupplyPlanNettingWrapper> spnWrapperList = new List<SupplyPlanNettingWrapper>();
        try{
            FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filterWrapStr,FilterWrapper.class);
           
            
            // Updating supply plan netting & netting lines
            if(isAnyRecordUpdate){
                spnWrapperList = updateSupplyPlanNettingLines(spnWrapperJSON,filterWrapStr,'');
            }
            
            String recordId = filterWrap.objDemandForecastSetup.id;
            Set<Id> dfsIds = new Set<Id>();
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            List<gii__DemandForecastSetup__c> dfsLst = [select id,giic_Supply_Plan_Cycle__c,giic_RelatedTo__c from gii__DemandForecastSetup__c where giic_Supply_Plan_Cycle__c=: planCycleId AND giic_RelatedTo__c= :giic_Constants.SUPPLYPLAN] ;
            if(!dfsLst.isEmpty()){
                for(gii__DemandForecastSetup__c dfs : dfsLst){
                    dfsIds.add(dfs.Id);
                }
                    
                List<ProcessInstanceWorkitem> workItemLst = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :dfsIds AND ProcessInstance.Status =:giic_Constants.PENDING];
                if(!workItemLst.isEmpty()){   
                for(ProcessInstanceWorkitem workItem : workItemLst){    
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkitemId(workItem.Id);
                    req.setAction('Approve');
                    req.setcomments(comment);
                    requests.add(req);
                    }
                }
            }
            if(requests.size()>0){
              Approval.ProcessResult[] processResults = Approval.process(requests);
           }
           isApproved = true;
        }catch(Exception e){
            System.debug('Exception:'+e);
            System.debug('Exception Line:'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
        return isApproved;
    } 
    
    /* Method name : rejectRecord
    * Description : This method will reject the record of Demand Forecast setup
    * Return Type : boolean
    * Parameter : JSON String of FilterWrapper,supplyPlanNettingWrapper,String,Boolean
    */
    @AuraEnabled
    public static boolean rejectRecord(String spnWrapperJSON,String filterWrapStr,String comment,boolean isAnyRecordUpdate){
        boolean isRejected = false;
        try{
            FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filterWrapStr,FilterWrapper.class);
            
            // Updating supply plan netting & netting lines
            if(isAnyRecordUpdate){
                updateSupplyPlanNettingLines(spnWrapperJSON,filterWrapStr,'');
            }
            
            String recordId = filterWrap.objDemandForecastSetup.id;
            Set<Id> dfsIds = new Set<Id>();
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            List<gii__DemandForecastSetup__c> dfsLst = [select id,giic_Supply_Plan_Cycle__c,giic_RelatedTo__c from gii__DemandForecastSetup__c where giic_Supply_Plan_Cycle__c=: filterWrap.objSupplyPlanCycle.id AND giic_RelatedTo__c= :giic_Constants.SUPPLYPLAN] ;
            if(!dfsLst.isEmpty()){
                for(gii__DemandForecastSetup__c dfs : dfsLst){
                    dfsIds.add(dfs.Id);
                }
                for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :dfsIds and ProcessInstance.Status =:giic_Constants.PENDING]){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkitemId(workItem.Id);
                    req.setAction('Reject');
                    req.setcomments(comment);
                    requests.add(req);
                }
            }
            Approval.ProcessResult[] processResults = Approval.process(requests);
            isRejected = true;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        return isRejected;
    }
    
    /* Method name : requestForEditApproved
    * Description : this methid will update the record of Demand Forecast Setup
    * Return Type : boolean
    * Parameter : FilterWrapper JSON as String
    */
    @AuraEnabled
    public static boolean requestForEditApproved(String filterWrapStr){ 
        boolean isRejected = false;
        try{
            FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filterWrapStr,FilterWrapper.class);
            
            if(filterWrap.objDemandForecastSetup != null){
                gii__DemandForecastSetup__c objDFS = filterWrap.objDemandForecastSetup;
                objDFS.giic_ApprovalStatus__c = giic_Constants.REQUPDATEPLAN;
                
                update objDFS;
                isRejected = true;
            }
            
            
        }catch(Exception e){
            System.debug('Exception Line:'+e.getLineNumber());
            System.debug('Exception:'+e);
            throw new AuraHandledException(e.getMessage());
        }
        return isRejected;
    } 
    
    /* Method name : getRowKey
    * Description : this method will get the key of each row
    * Return Type : String
    * Parameter : String
    */
    public static String getRowKey(String rowkey)
    {
        return rowkey;
    }
    
    /* Method name : getCellKey
    * Description : this method will get the key of each cell
    * Return Type : String
    * Parameter : Date, Map<String,Object>
    */
    public static String getCellKey(Date dt,Map<String,Object> dtRangeMap)
    {
        String cellkey ='';
        if(dtRangeMap.containsKey(dt.format())){
            DateRangeWrapper dateWrap = (DateRangeWrapper)dtRangeMap.get(dt.format());
           
            cellkey = dateWrap.cellkey;
        }else{
            cellkey = dt.format();
        }
        return  cellkey;
    }
    
    /* Method name : getCellHeaderValue
    * Description : this method will get the cell header value
    * Return Type : String
    * Parameter : Date
    */ 
    public static String getCellHeaderValue(Date dt)
    {
        return  dt.format();
    }
    
    public class ResultWrapper{
        @AuraEnabled public String prodName;
        @AuraEnabled public String supplierName;
        @AuraEnabled public Map<String,Object> cellsMap;
        @AuraEnabled public List<MapWrapper> cellsDataList;
    }
    
    public class DateRangeWrapper{
        @AuraEnabled public String dateValue;
        @AuraEnabled public String dateRange;
        @AuraEnabled public String  cellkey;
    }
    
    public class MapWrapper{
        @AuraEnabled public String key;
        @AuraEnabled public Object value;
        public Map<Integer, String> monthKey; 
        public MapWrapper(){
            monthKey = new Map<Integer, String>
            {
                1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',
                    8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'
                    };
                        }
    }
    
    public class FilterWrapper{
        
        @AuraEnabled public String planningCycleName;
        @AuraEnabled public Integer numOfPeriods;
        @AuraEnabled public String strReportingPeriod;
        @AuraEnabled public Boolean isApprover;
        @AuraEnabled public gii__SupplyPlanCycle__c objSupplyPlanCycle;
        @AuraEnabled public gii__DemandForecastSetup__c objDemandForecastSetup;
        @AuraEnabled public Date asOfDate;
        @AuraEnabled public string regionName;
        
        public FilterWrapper()
        {
            isApprover = false;
            objSupplyPlanCycle = new gii__SupplyPlanCycle__c();
            objDemandForecastSetup = new gii__DemandForecastSetup__c();
            numOfPeriods=6;
            planningCycleName='';
            strReportingPeriod='Monthly';
        }
        
    }
    
    public class ProuductionPlanResultWrapper{
        @AuraEnabled public Map<String,ResultWrapper> rowResultMap;
        @AuraEnabled public List<MapWrapper> cellsHeaderList;
        
        public ProuductionPlanResultWrapper()
        {
            rowResultMap = new Map<String,ResultWrapper>();
            cellsHeaderList = new List<MapWrapper>();
            
        }
    }
    
    
    
    public class SupplyPlanNettingWrapper{
        @AuraEnabled public String buyingUnitofMeasure;
        @AuraEnabled public decimal cpoQuantity;
        @AuraEnabled public decimal demandOrderQuantity;
        @AuraEnabled public decimal totalDemandOrderQuantity;
        @AuraEnabled public decimal totalSupplyQuantity;
        @AuraEnabled public decimal leadTime;
        @AuraEnabled public boolean make;
        @AuraEnabled public decimal maximumInventoryQuantity;
        @AuraEnabled public decimal onHandQuantity;
        @AuraEnabled public String productCategory;
        @AuraEnabled public String productDescription;
        @AuraEnabled public String productReference;
        @AuraEnabled public decimal purchaseOrderQuantity;
        @AuraEnabled public decimal safetyStockQuantity;
        @AuraEnabled public String skuCode;
        @AuraEnabled public String supplyPlanCycle;
        @AuraEnabled public decimal totalCOGS;
        @AuraEnabled public decimal msrp;
        @AuraEnabled public String productStatus;
        @AuraEnabled public String status;
        @AuraEnabled public String supplyNotes;
        @AuraEnabled public String transferToWarehouse;
        @AuraEnabled public String notes;
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String ownerId;
        @AuraEnabled public integer rowSpanofSPN;
        @AuraEnabled public List<supplyPlanNettingMonth> supplyPlanNettingMonthList;
        //  @AuraEnabled public Map<string,decimal> demandOrderQuantityMap;
        @AuraEnabled public Map<String,List<SupplyPlanNettingLineSupplierWarpper>> spnlcWrapperMap;
        //  @AuraEnabled public Map<String,List<supplyPlanNettingLineWrapper>> supplyPlanNettingLineWrapperListMap;
        
        public SupplyPlanNettingWrapper(){
            buyingUnitofMeasure = '';
            cpoQuantity = 0;
            demandOrderQuantity = 0;
            totalDemandOrderQuantity = 0;
            leadTime = 0;
            make = false;
            maximumInventoryQuantity = 0;
            onHandQuantity = 0;
            productCategory = '';
            productDescription = '';
            productReference = null;
            purchaseOrderQuantity = 0;
            safetyStockQuantity = 0;
            totalSupplyQuantity = 0;
            totalCOGS = 0;
            msrp = 0;
            productStatus = '';
            status = '';
            supplyNotes = '';
            notes = '';
            skuCode = '';
            supplyPlanCycle = '';
            transferToWarehouse = '';
            id = '';
            name = '';
            ownerId = '';
            rowSpanofSPN = 0;
            supplyPlanNettingMonthList = new List<supplyPlanNettingMonth>();
            //  demandOrderQuantityMap = new Map<string,decimal>();
            spnlcWrapperMap = new Map<String,List<SupplyPlanNettingLineSupplierWarpper>>();
            //  supplyPlanNettingLineWrapperListMap = new Map<String,List<supplyPlanNettingLineWrapper>>();
        }
    }
    
    public class SupplyPlanNettingMonth{
        @AuraEnabled public String keyDate; 
        @AuraEnabled public List<SupplyPlanNettingLineSupplierWarpper>  supplyPlanNettingLineSupplierWarpperList;
        @AuraEnabled public decimal demandOrderQuantityTotal;
        @AuraEnabled public integer rowspanforDemandOrderQty;
        
        public SupplyPlanNettingMonth(){
            keyDate = '';
            demandOrderQuantityTotal = 0;
            supplyPlanNettingLineSupplierWarpperList = new List<supplyPlanNettingLineSupplierWarpper>();
            rowspanforDemandOrderQty = 1;
        }
    }
    
    public class SupplyPlanNettingLineSupplierWarpper{
        @AuraEnabled public String supplierId;
        @AuraEnabled public integer weekNumber;
        @AuraEnabled public String supplierCountry;
        @AuraEnabled public decimal supplyQuantityofMonth;
        @AuraEnabled public String supplierWarehouse;
        @AuraEnabled public decimal orderQuantityWarehouse;
        @AuraEnabled public List<SupplyPlanNettingLineWrapper> spnlWrapperList;
        
        public SupplyPlanNettingLineSupplierWarpper(){
            supplierCountry = '';
            supplyQuantityofMonth = 0;
            supplierWarehouse = '';
            orderQuantityWarehouse = 0;
            spnlWrapperList = new List<SupplyPlanNettingLineWrapper>();
        }
    }
    
    
    public class SupplyPlanNettingLineWrapper{
        
        @AuraEnabled public integer weekNumber;
        @AuraEnabled public String suggestedStartDate;
        @AuraEnabled public String keyStartDate;
        @AuraEnabled public boolean isChanged;
        @AuraEnabled public decimal orderQuantity;
        @AuraEnabled public String id;
        @AuraEnabled public String name; 
        @AuraEnabled public String demandForcastSetupId;
        @AuraEnabled public String supplyPlanNettingId;
        @AuraEnabled public String supplyPlanCycleId;
        @AuraEnabled public decimal priorOrderQuantity;
        @AuraEnabled public String lastModifiedDate;
        @AuraEnabled public String tooltipString;
        @AuraEnabled public String arrowType;
        @AuraEnabled public boolean isArrowVisible;
        @AuraEnabled public gii__SupplyPlanNettingLine__c spnlDetail{get;set;}
        
        public SupplyPlanNettingLineWrapper(){
            isChanged = false;
            tooltipString = '';
            arrowType = 'utility:arrowup';
            isArrowVisible = false;
        }
    }
    
    public class SearchHeaderWrapper{
        
        @AuraEnabled public Integer numOfPeriods{get;set;}
        @AuraEnabled public String filterQueryPart{get;set;}
        @AuraEnabled public String countryValue{get;set;}
        @AuraEnabled public String legalEntityVal{get;set;}
        @AuraEnabled public String productCategoryId{get;set;}
        @AuraEnabled public String selectedOpportunity{get;set;}
        @AuraEnabled public String selectedWarehouseId{get;set;}
        @AuraEnabled public Date asOfDate{get;set;}
        @AuraEnabled public String lstRegion;
        @AuraEnabled public String lstCountry;
        @AuraEnabled public String lstLegalEntity;
        @AuraEnabled public String lstWarehouse;
        @AuraEnabled public String lstProductGroup;
        @AuraEnabled public String setupRegion;
        @AuraEnabled public String subCategory1;
        @AuraEnabled public String subCategory2;
        @AuraEnabled public String skuCode;
        @AuraEnabled public String searchProductName;
        @AuraEnabled public String supplier;
        @AuraEnabled public list<gii__ProductGroup__c> lstProductGroups;
        
    }

    /* Method name : createProductionPlan
    * Description : this method will call batch which will create production plan records
    * Return Type : String of FilterWrapper
    * Parameter : void
    */ 
    @AuraEnabled
    public static void createProductionPlan(String filterWrapStr){  
        try{
            List<gii__DemandForecastSetup__c> updateDemandForcastSetuplst=new List<gii__DemandForecastSetup__c>();

            FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filterWrapStr,FilterWrapper.class);
            id supplyPlanCycleID=filterWrap.objDemandForecastSetup.giic_Supply_Plan_Cycle__c;
            String region = filterWrap.regionName.replace('(','').replace(')','').replaceAll('\'','');
            List<gii__DemandForecastSetup__c> dfSetupList =  giic_CommonUtility.getDemandForecastSetup(supplyPlanCycleID,giic_Constants.SUPPLYPLAN,'');
            if(!dfSetupList.isEmpty()){
                for(gii__DemandForecastSetup__c dfs :dfSetupList){
                    gii__DemandForecastSetup__c updateDemandForcastSetup=new gii__DemandForecastSetup__c();

                updateDemandForcastSetup.id = dfs.id;
                updateDemandForcastSetup.giic_BatchStatus__c='In Progress';
                updateDemandForcastSetupLst.add(updateDemandForcastSetup);
                //update updateDemandForcastSetup;
                }
                if(updateDemandForcastSetupLst.size()>0){
                    update updateDemandForcastSetupLst;
                }
            }
            Id batchJobId = Database.executeBatch(new giic_ResetProductionPlanBatch(supplyPlanCycleID,region));
            AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :batchJobId];
            giic_BatchProgress__c jobstatus = new giic_BatchProgress__c();
            jobstatus.Name = batchJobId; 
            jobstatus.giic_JobId__c = batchJobId;
            jobstatus.giic_Status__c=giic_Constants.PRODUCTIONPLANBATCHSTATUS;
            insert jobstatus;
        }
        catch(Exception e) {
            System.debug('Exception:' + e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Method name : getBatchJobStatus
    * Description : this method will return batch job status
    * Return Type : List<AsyncApexJob>
    * Parameter : none
    */ 
    @AuraEnabled
    public static List<AsyncApexJob> getBatchJobStatus(){
        List<String> batchStatusLst = new List<String>();
        List<giic_BatchProgress__c> batchStatusLstUpdated = new List<giic_BatchProgress__c>();
        List<giic_BatchProgress__c> batchStatusLstOld = new List<giic_BatchProgress__c>();
        List<AsyncApexJob> jobInfo = new List<AsyncApexJob>();
       for(giic_BatchProgress__c batchStatus :[Select giic_JobId__c from giic_BatchProgress__c where giic_Status__c=:giic_Constants.PRODUCTIONPLANBATCHSTATUS]){
            batchStatusLst.add(batchStatus.giic_JobId__c);
            batchStatusLstOld.add(batchStatus);
        }

        jobInfo = [SELECT Id,Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id IN : batchStatusLst];
        for(AsyncApexJob asynJob : jobInfo){
            for(giic_BatchProgress__c batchSt : batchStatusLstOld){
                if(batchSt.giic_JobId__c == asynJob.Id && asynJob.Status==giic_Constants.COMPLETED){
                    giic_BatchProgress__c batchJob = new giic_BatchProgress__c();
                    batchJob.Id = batchSt.Id;
                    batchStatusLstUpdated.add(batchJob);
                }
            }
        }
        if(batchStatusLstUpdated.size()>0){

            delete batchStatusLstUpdated;
        }
        return jobInfo;
    }
    
    public static void getSupplierDetails(Map<String,SupplyPlanNettingLineSupplierWarpper> spnlCountryMap, string supplierKey,gii__SupplyPlanNettingLine__c spnl,SupplyPlanNettingMonth spnMObj,FilterWrapper searchFilterStr){
        if(spnlCountryMap.get(supplierKey) != null){
            spnlCountryMap.get(supplierKey).supplyQuantityofMonth += spnl.gii__OrderQuantity__c;
            spnlCountryMap.get(supplierKey).supplierId = spnl.gii__SupplierList__c;
           
            SupplyPlanNettingLineWrapper spnlWrapper = new SupplyPlanNettingLineWrapper();
            spnlWrapper.Id = spnl.Id;
            spnlWrapper.supplyPlanCycleId = searchFilterStr.objSupplyPlanCycle.Id;
            //spnlWrapper.demandForcastSetupId = (searchFilterStr.objDemandForecastSetup != null ? searchFilterStr.objDemandForecastSetup.Id : '');
            spnlWrapper.orderQuantity = spnl.gii__OrderQuantity__c;
            spnlWrapper.weekNumber = Integer.valueOf(spnl.giic_WeekNumber__c);
            spnlWrapper.spnlDetail = spnl;
            spnlWrapper.suggestedStartDate = spnl.gii__SuggestedStartDate__c.format();
            spnlWrapper.keyStartDate = spnl.gii__SuggestedStartDate__c.toStartOfMonth().format();
            spnlWrapper.priorOrderQuantity = spnl.giic_PriorOrderQuantity__c != null ? spnl.giic_PriorOrderQuantity__c : 0;
            spnlWrapper.tooltipString = 'Prior Quantity: '+spnlWrapper.priorOrderQuantity+', Modified Date: '+spnl.lastModifiedDate.format();
            spnlWrapper.arrowType = (spnl.gii__OrderQuantity__c > spnl.giic_PriorOrderQuantity__c ? 'utility:arrowup' : 'utility:arrowdown');
            spnlWrapper.isArrowVisible = (spnl.gii__OrderQuantity__c != spnl.giic_PriorOrderQuantity__c ? true : false);
            spnlWrapper.lastModifiedDate = spnl.lastModifiedDate.format();
            
            spnlCountryMap.get(supplierKey).spnlWrapperList.add(spnlWrapper);
           
            
        }else if(spnl.giic_SupplierName__c != null && spnl.giic_SupplierName__c != ''){
            SupplyPlanNettingLineSupplierWarpper spnlCwrapper = new SupplyPlanNettingLineSupplierWarpper();
            spnlCwrapper.supplierCountry = spnl.giic_SupplierName__c;
            spnlCwrapper.supplyQuantityofMonth = spnl.gii__OrderQuantity__c;
            spnlCwrapper.supplierId = spnl.gii__SupplierList__c;
           
            
            SupplyPlanNettingLineWrapper spnlWrapper = new SupplyPlanNettingLineWrapper();
            spnlWrapper.Id = spnl.Id;
            spnlWrapper.supplyPlanCycleId = searchFilterStr.objSupplyPlanCycle.Id;
            //spnlWrapper.demandForcastSetupId = (searchFilterStr.objDemandForecastSetup != null ? searchFilterStr.objDemandForecastSetup.Id : '');
            spnlWrapper.orderQuantity = spnl.gii__OrderQuantity__c;
            spnlWrapper.weekNumber = Integer.valueOf(spnl.giic_WeekNumber__c);
            spnlWrapper.spnlDetail = spnl;
            spnlWrapper.suggestedStartDate = spnl.gii__SuggestedStartDate__c.format();
            spnlWrapper.keyStartDate = spnl.gii__SuggestedStartDate__c.toStartOfMonth().format();  
            spnlWrapper.priorOrderQuantity = spnl.giic_PriorOrderQuantity__c != null ? spnl.giic_PriorOrderQuantity__c : 0;
            spnlWrapper.tooltipString = 'Prior Quantity: '+spnlWrapper.priorOrderQuantity+', Modified Date: '+spnl.lastModifiedDate.format();
            spnlWrapper.arrowType =   (spnl.gii__OrderQuantity__c > spnl.giic_PriorOrderQuantity__c ? 'utility:arrowup' : 'utility:arrowdown');   
            spnlWrapper.isArrowVisible = (spnl.gii__OrderQuantity__c != spnl.giic_PriorOrderQuantity__c ? true : false);  
            spnlWrapper.lastModifiedDate = spnl.lastModifiedDate.format();                
            
            spnlCwrapper.spnlWrapperList.add(spnlWrapper);
            
            spnlCountryMap.put(supplierKey,spnlCwrapper);
            
            //add Supplier into DO/Month
            
            spnMObj.supplyPlanNettingLineSupplierWarpperList.add(spnlCwrapper);
        }
    }
     
    public static void getTransferWarehouseDetails(Map<String,SupplyPlanNettingLineSupplierWarpper> spnlWareHouseMap,string transferKey,gii__SupplyPlanNettingLine__c spnl,SupplyPlanNettingMonth spnMObj,FilterWrapper searchFilterStr){
        if(spnlWareHouseMap.get(transferKey) != null){
           
            spnlWareHouseMap.get(transferKey).supplyQuantityofMonth += spnl.gii__OrderQuantity__c;
            spnlWareHouseMap.get(transferKey).orderQuantityWarehouse += spnl.gii__OrderQuantity__c;
            spnlWareHouseMap.get(transferKey).supplierId = spnl.gii__FromWarehouse__c;
            
            SupplyPlanNettingLineWrapper spnlWrapper = new SupplyPlanNettingLineWrapper();
            spnlWrapper.id = spnl.Id;
            spnlWrapper.supplyPlanCycleId = searchFilterStr.objSupplyPlanCycle.Id;
            //spnlWrapper.demandForcastSetupId = (searchFilterStr.objDemandForecastSetup != null ? searchFilterStr.objDemandForecastSetup.Id : '');
            spnlWrapper.orderQuantity = spnl.gii__OrderQuantity__c;
            spnlWrapper.weekNumber = Integer.valueOf(spnl.giic_WeekNumber__c);
            spnlWrapper.spnlDetail = spnl;
            // spnlWrapper.SuggestedStartDate = spnl.gii__SuggestedStartDate__c.format();                            
            
            spnlWareHouseMap.get(transferKey).spnlWrapperList.add(spnlWrapper);                       
            
        }else if(spnl.gii__FromWarehouse__c != null && (spnl.giic_SupplierName__c == null || spnl.giic_SupplierName__c == '')){
           
            SupplyPlanNettingLineSupplierWarpper spnlCwrapper = new SupplyPlanNettingLineSupplierWarpper();
            spnlCwrapper.supplierWarehouse = spnl.gii__TransferToWarehouse__r.Name;
            spnlCwrapper.supplierCountry = spnl.gii__FromWarehouse__r.Name;
            //spnlCwrapper.weekNumber = Integer.valueOf(spnl.giic_WeekNumber__c);
            spnlCwrapper.supplyQuantityofMonth = spnl.gii__OrderQuantity__c;
            spnlCwrapper.orderQuantityWarehouse = spnl.gii__OrderQuantity__c;
            spnlCwrapper.supplierId = spnl.gii__FromWarehouse__c;
            SupplyPlanNettingLineWrapper spnlWrapper = new SupplyPlanNettingLineWrapper();
            spnlWrapper.id = spnl.Id;
            spnlWrapper.supplyPlanCycleId = searchFilterStr.objSupplyPlanCycle.Id;
            //spnlWrapper.demandForcastSetupId = (searchFilterStr.objDemandForecastSetup != null ? searchFilterStr.objDemandForecastSetup.Id : '');
            spnlWrapper.orderQuantity = spnl.gii__OrderQuantity__c;
            spnlWrapper.weekNumber = Integer.valueOf(spnl.giic_WeekNumber__c);
            spnlWrapper.spnlDetail = spnl;
            spnlCwrapper.spnlWrapperList.add(spnlWrapper);
            spnlWareHouseMap.put(transferKey,spnlCwrapper);
            
            //add Supplier into DO/Month
            spnMObj.supplyPlanNettingLineSupplierWarpperList.add(spnlCwrapper);
        }
    }
    public static void getSupplierDetailswarehouse(Map<String,SupplyPlanNettingLineSupplierWarpper> spnlCountryMap,string supplierKey,gii__SupplyPlanNettingLine__c spnl,SupplyPlanNettingMonth spnMObj,FilterWrapper searchFilterStr){
        if(spnlCountryMap.get(supplierKey) != null){
           
            spnlCountryMap.get(supplierKey).supplyQuantityofMonth += spnl.gii__OrderQuantity__c;
            spnlCountryMap.get(supplierKey).supplierId = spnl.gii__SupplierList__c;
            SupplyPlanNettingLineWrapper spnlWrapper = new SupplyPlanNettingLineWrapper();
            spnlWrapper.id = spnl.Id;
            spnlWrapper.supplyPlanCycleId = searchFilterStr.objSupplyPlanCycle.Id;
            //spnlWrapper.demandForcastSetupId = (searchFilterStr.objDemandForecastSetup != null ? searchFilterStr.objDemandForecastSetup.Id : '');
            spnlWrapper.orderQuantity = spnl.gii__OrderQuantity__c;
            spnlWrapper.weekNumber = Integer.valueOf(spnl.giic_WeekNumber__c);
            spnlWrapper.spnlDetail = spnl;
            spnlWrapper.suggestedStartDate = spnl.gii__SuggestedStartDate__c.format();
            spnlWrapper.keyStartDate = spnl.gii__SuggestedStartDate__c.toStartOfMonth().format();
            spnlWrapper.priorOrderQuantity = spnl.giic_PriorOrderQuantity__c != null ? spnl.giic_PriorOrderQuantity__c : 0;
            spnlWrapper.tooltipString = 'Prior Quantity: '+spnlWrapper.priorOrderQuantity+', Modified Date: '+spnl.lastModifiedDate.format();
            spnlWrapper.arrowType = (spnl.gii__OrderQuantity__c > spnl.giic_PriorOrderQuantity__c ? 'utility:arrowup' : 'utility:arrowdown');
            spnlWrapper.isArrowVisible = (spnl.gii__OrderQuantity__c != spnl.giic_PriorOrderQuantity__c ? true : false);
            spnlWrapper.lastModifiedDate = spnl.lastModifiedDate.format();
            spnlCountryMap.get(supplierKey).spnlWrapperList.add(spnlWrapper);
            
        }else if(spnl.giic_SupplierName__c == null ){
           
            SupplyPlanNettingLineSupplierWarpper spnlCwrapper = new SupplyPlanNettingLineSupplierWarpper();
            //spnlCwrapper.supplierCountry = '';
            spnlCwrapper.supplyQuantityofMonth = spnl.gii__OrderQuantity__c;
            spnlCwrapper.supplierId = spnl.gii__SupplierList__c;
            SupplyPlanNettingLineWrapper spnlWrapper = new SupplyPlanNettingLineWrapper();
            spnlWrapper.id = spnl.Id;
            spnlWrapper.supplyPlanCycleId = searchFilterStr.objSupplyPlanCycle.Id;
            //spnlWrapper.demandForcastSetupId = (searchFilterStr.objDemandForecastSetup != null ? searchFilterStr.objDemandForecastSetup.Id : '');
            spnlWrapper.orderQuantity = spnl.gii__OrderQuantity__c;
            spnlWrapper.weekNumber = Integer.valueOf(spnl.giic_WeekNumber__c);
            spnlWrapper.spnlDetail = spnl;
            spnlWrapper.suggestedStartDate = spnl.gii__SuggestedStartDate__c.format();
            spnlWrapper.keyStartDate = spnl.gii__SuggestedStartDate__c.toStartOfMonth().format();  
            spnlWrapper.priorOrderQuantity = spnl.giic_PriorOrderQuantity__c != null ? spnl.giic_PriorOrderQuantity__c : 0;
            spnlWrapper.tooltipString = 'Prior Quantity: '+spnlWrapper.priorOrderQuantity+', Modified Date: '+spnl.LastModifiedDate.format();
            spnlWrapper.arrowType =   (spnl.gii__OrderQuantity__c > spnl.giic_PriorOrderQuantity__c ? 'utility:arrowup' : 'utility:arrowdown');   
            spnlWrapper.isArrowVisible = (spnl.gii__OrderQuantity__c != spnl.giic_PriorOrderQuantity__c ? true : false);  
            spnlWrapper.LastModifiedDate = spnl.LastModifiedDate.format();                
            spnlCwrapper.spnlWrapperList.add(spnlWrapper);
            spnlCountryMap.put(supplierKey,spnlCwrapper);
            
            //add Supplier into DO/Month
            
            spnMObj.supplyPlanNettingLineSupplierWarpperList.add(spnlCwrapper);
            //
        }
    }
    public static void getTotalDemandOrder(Map<String, Set<String>> doqMap,string spnlMonthKey,SupplyPlanNettingMonth spnMObj,gii__SupplyPlanNettingLine__c spnl,string doKey,SupplyPlanNettingWrapper spnWrapper){
        if(!doqMap.containsKey(spnlMonthKey)){                            
            spnMObj.demandOrderQuantityTotal = (spnMObj.demandOrderQuantityTotal == null ? 0 : spnMObj.demandOrderQuantityTotal)+ (spnl.giic_DemandOrderQuantity__c != null ? spnl.giic_DemandOrderQuantity__c : 0);
            doqMap.put(doKey, new Set<String>{spnl.gii__DemandOrder__c}); 
            spnWrapper.totalDemandOrderQuantity += (spnl.giic_DemandOrderQuantity__c != null ? spnl.giic_DemandOrderQuantity__c : 0); 
        }else{
            Set<String> doSet = doqMap.get(spnlMonthKey);
            if(!doSet.contains(spnl.gii__DemandOrder__c)){
                spnMObj.demandOrderQuantityTotal = (spnMObj.demandOrderQuantityTotal == null ? 0 : spnMObj.demandOrderQuantityTotal)+ (spnl.giic_DemandOrderQuantity__c != null ? spnl.giic_DemandOrderQuantity__c : 0);
                doSet.add(spnl.gii__DemandOrder__c) ;  
                spnWrapper.totalDemandOrderQuantity += (spnl.giic_DemandOrderQuantity__c != null ? spnl.giic_DemandOrderQuantity__c : 0); 
            }
        }
    }
      /* Method name : getReportId
    * Description : this method will return report id
    * Return Type : String
    * Parameter : null
    */
    @AuraEnabled
    public static String getReportId(){
        return [SELECT Id,Name,DeveloperName FROM Report WHERE DeveloperName=:giic_Constants.EXPORTSPC LIMIT 1].Id;
    }
    public static void createDOUsedQtyRecord(List<gii__SupplyPlanNettingLine__c> listSPNLine){
        Map<string,Decimal> spnlUsedHourbyPLMap=new Map<string,Decimal>();
        Map<String,gii__PaymentStaging__c> mapofPS=new Map<String,gii__PaymentStaging__c>();
        List<gii__PaymentStaging__c> listPaymentStaging=new List<gii__PaymentStaging__c>();
        for(gii__SupplyPlanNettingLine__c spnl:listSPNLine){
            if(!mapofPS.containsKey(spnl.giic_WeekCapacityCategoryKey__c)){
                system.debug('spnl.giic_WeekCapacityCategoryKey__c'+spnl.giic_WeekCapacityCategoryKey__c);
                system.debug('spnl.giic_UsedCapacityHour__c'+spnl.giic_UsedCapacityHour__c);
                system.debug('spnl.giic_WeekCapacityProductionLineKey__c'+spnl.giic_WeekCapacityProductionLineKey__c);
                    gii__PaymentStaging__c ps=new gii__PaymentStaging__c();
                    ps.giic_WeekCapacityCategoryKey__c=spnl.giic_WeekCapacityCategoryKey__c;
                    ps.giic_UsedCapacityProductCategory__c=spnl.giic_UsedCapacityHour__c;
                    ps.giic_WeekCapacityProductionLineKey__c=spnl.giic_WeekCapacityProductionLineKey__c;
                    ps.giic_SupplyPlanCycle__c = spnl.gii__SupplyPlanCycle__c;
                if(!spnlUsedHourbyPLMap.containsKey(spnl.giic_WeekCapacityProductionLineKey__c)){
                    spnlUsedHourbyPLMap.put(spnl.giic_WeekCapacityProductionLineKey__c,spnl.giic_UsedCapacityHour__c);
                   }
                else{
                    spnlUsedHourbyPLMap.put(spnl.giic_WeekCapacityProductionLineKey__c,spnlUsedHourbyPLMap.get(spnl.giic_WeekCapacityProductionLineKey__c)+(spnl.giic_UsedCapacityHour__c==null?0:spnl.giic_UsedCapacityHour__c));
                 }
               mapofPS.put(spnl.giic_WeekCapacityCategoryKey__c,ps);
                listPaymentStaging.add(ps);
            }
            else{
               mapofPS.get(spnl.giic_WeekCapacityCategoryKey__c).giic_UsedCapacityProductCategory__c+=(spnl.giic_UsedCapacityHour__c==null?0:spnl.giic_UsedCapacityHour__c);
                spnlUsedHourbyPLMap.put(spnl.giic_WeekCapacityProductionLineKey__c,spnlUsedHourbyPLMap.get(spnl.giic_WeekCapacityProductionLineKey__c)+(spnl.giic_UsedCapacityHour__c==null?0:spnl.giic_UsedCapacityHour__c));
             }
         }
       
        if(listPaymentStaging.size()>0){
            Map<string,gii__PaymentStaging__c> paymentStagingMap=new Map<string,gii__PaymentStaging__c>();
            set<string> plset=new set<string>();
            
            for(gii__PaymentStaging__c pslist: [select id,giic_WeekCapacityCategoryKey__c,giic_UsedCapacityProductCategory__c,giic_UsedCapacityProductionLine__c,giic_WeekCapacityProductionLineKey__c from gii__PaymentStaging__c where giic_WeekCapacityProductionLineKey__c in: spnlUsedHourbyPLMap.keySet()]){
                paymentStagingMap.put(pslist.giic_WeekCapacityCategoryKey__c,pslist);
                if(spnlUsedHourbyPLMap.containsKey(pslist.giic_WeekCapacityProductionLineKey__c)){
                    spnlUsedHourbyPLMap.put(pslist.giic_WeekCapacityProductionLineKey__c,spnlUsedHourbyPLMap.get(pslist.giic_WeekCapacityProductionLineKey__c)+(pslist.giic_UsedCapacityProductCategory__c));
                    //plset.add(pslist.giic_WeekCapacityProductionLineKey__c);
                }
            }
           for(gii__PaymentStaging__c psl:listPaymentStaging){
               if(paymentStagingMap.containsKey(psl.giic_WeekCapacityCategoryKey__c)){
                   psl.giic_UsedCapacityProductCategory__c+=paymentStagingMap.get(psl.giic_WeekCapacityCategoryKey__c).giic_UsedCapacityProductCategory__c;
                   
                   paymentStagingMap.remove(psl.giic_WeekCapacityCategoryKey__c);
               }
               
                if(spnlUsedHourbyPLMap.containsKey(psl.giic_WeekCapacityProductionLineKey__c)){
                    psl.giic_UsedCapacityProductionLine__c=spnlUsedHourbyPLMap.get(psl.giic_WeekCapacityProductionLineKey__c);
                }              
                
            }
            for(gii__PaymentStaging__c psl: paymentStagingMap.values()){
                if(spnlUsedHourbyPLMap.containsKey(psl.giic_WeekCapacityProductionLineKey__c)){
                    psl.giic_UsedCapacityProductionLine__c=spnlUsedHourbyPLMap.get(psl.giic_WeekCapacityProductionLineKey__c);
                }   
            }
            List<gii__PaymentStaging__c> paymentStaginglist=new List<gii__PaymentStaging__c>(paymentStagingMap.values());
            listPaymentStaging.addAll(paymentStaginglist);
            upsert listPaymentStaging giic_WeekCapacityCategoryKey__c;
        }
        for(gii__SupplyPlanNettingLine__c spnl:listSPNLine){
           if(mapofPS.containsKey(spnl.giic_WeekCapacityCategoryKey__c)) {
               spnl.giic_WeeklyCapacityUtilizedhour__c= mapofPS.get(spnl.giic_WeekCapacityCategoryKey__c).id;
            }
        }
        if(listSPNLine.size()>0){
            update listSPNLine;
        }
    }
    
    /* Method name : updateSupplyPlanNettingLines
* Description : This method will update the Supply plan netting & Netting Line data of the each row
* Return Type : List<supplyPlanNettingWrapper> 
* Parameter : String list of supplyPlanNettingWrapper JSON, JSON String of FilterWrapper
*/
    @AuraEnabled 
    public static List<SupplyPlanNettingWrapper> updateSPNLQuantity(String spnlWrapperJSON,String filterWrapStr,string searchHeaderData){

        FilterWrapper filterWrap= (FilterWrapper) JSON.deserialize(filterWrapStr,FilterWrapper.class);
        system.debug('filterWrap.planningCycleId --'+filterWrap.objSupplyPlanCycle.Id);
        boolean isLeftQty = false;
        boolean isSuccess = false;
        List<SupplyPlanNettingLineWrapper> spnlWrapperList;
        Map<string,Decimal> plLeftOver=new Map<string,Decimal>();
        Map<string,Decimal> plspnlUsed=new Map<string,Decimal>();
        List<SupplyPlanNettingWrapper> spnwList = new List<SupplyPlanNettingWrapper>();
        try{
            spnlWrapperList = (List<SupplyPlanNettingLineWrapper>) JSON.deserialize(spnlWrapperJSON,List<SupplyPlanNettingLineWrapper>.class);
           
            List<gii__SupplyPlanNettingLine__c> supplyPlanNettingListUpdate = new List<gii__SupplyPlanNettingLine__c>();
            List<gii__SupplyPlanNettingLine__c> spnlList = new List<gii__SupplyPlanNettingLine__c>();
            set<string> spnlids=new set<string>();
            for(SupplyPlanNettingLineWrapper spnlWrapper : spnlWrapperList){
                spnlids.add(spnlWrapper.Id);
            }
            Map<id,gii__SupplyPlanNettingLine__c> spnlMap=new map<id,gii__SupplyPlanNettingLine__c>([select id,giic_LeftOverQuantity__c,gii__Account__c,gii__CapacityPerWeek__c,gii__DemandForecastLine__c,gii__DemandOrder__c,gii__OrderQuantity__c,gii__OrderType__c,gii__Product__c,gii__ProductCategory__c,gii__ProductionLine__c,giic_ProductionLine__c,gii__ProductionRateHour__c,gii__Sequence__c,gii__Supplier__c,gii__SupplierList__c,giic_SupplierName__c,gii__SupplyPlanCycle__c,giic_UsedCapacityHour__c,giic_WeekCapacityCategoryKey__c,giic_WeekCapacityProductionLineKey__c,gii__WeeklyCapacity__c,giic_WeekNumber__c from gii__SupplyPlanNettingLine__c where id in:spnlids]);
            for(SupplyPlanNettingLineWrapper spnlWrapper : spnlWrapperList){
                gii__SupplyPlanNettingLine__c spnl = new gii__SupplyPlanNettingLine__c();
                spnl.id = spnlWrapper.Id;
                gii__SupplyPlanNettingLine__c spnlDetail =spnlMap.get(spnl.id);
                //spnl.gii__OrderQuantity__c = spnlWrapper.orderQuantity;
                if(!plLeftOver.containsKey(spnlDetail.giic_WeekCapacityProductionLineKey__c)){
                plLeftOver.put(spnlDetail.giic_WeekCapacityProductionLineKey__c,spnlDetail.giic_LeftOverQuantity__c);
                }
                system.debug('spnlWrapper.orderQuantity --'+spnlWrapper.orderQuantity);
                system.debug('spnlDetail.gii__OrderQuantity__c --'+spnlDetail.gii__OrderQuantity__c);
                if(spnlWrapper.orderQuantity>spnlDetail.gii__OrderQuantity__c){
                    decimal diff=spnlWrapper.orderQuantity-spnlDetail.gii__OrderQuantity__c;
                    if(!plspnlUsed.containsKey(spnlDetail.giic_WeekCapacityProductionLineKey__c)){
                    plspnlUsed.put(spnlDetail.giic_WeekCapacityProductionLineKey__c,diff);
                    }
                    else{
                        plspnlUsed.put(spnlDetail.giic_WeekCapacityProductionLineKey__c,plspnlUsed.get(spnlDetail.giic_WeekCapacityProductionLineKey__c)+diff);
                    }
                }
                spnl.gii__OrderQuantity__c = spnlWrapper.orderQuantity;  
                supplyPlanNettingListUpdate.add(spnl);
                spnlList.add(spnlDetail);   
            }
            for(string plKey: plLeftOver.keySet()){
                if(plLeftOver.get(plKey)< plspnlUsed.get(plKey)){
                   // isLeftQty = true;
                    //throw new AuraHandledException('Quantity can not be more than the Left Over Quantities ' +plLeftOver.get(plKey));
                    throw new giic_SupplyChainException('Quantity can not be more than the Left Over Quantity ' +plLeftOver.get(plKey));
                }
            }
            
            if(!supplyPlanNettingListUpdate.isEmpty()){
                system.debug('supplyPlanNettingListUpdate' +supplyPlanNettingListUpdate);
                update supplyPlanNettingListUpdate;
                //updateSPNL(spnlids);
                //spnwList=getResultData(filterWrapStr,searchHeaderData);
                Id apexJobId = Database.executeBatch(new giic_ResetWeeklyCapacityUtilize(filterWrap.objSupplyPlanCycle.Id),200);
                giic_BatchProgress__c jobstatus = new giic_BatchProgress__c();
                jobstatus.Name = apexJobId; 
                jobstatus.giic_JobId__c = apexJobId;
                jobstatus.giic_Status__c=giic_Constants.RESETWEEKBATCHSTATUS;
                insert jobstatus;
            }
            
            
            isSuccess = true;
        }catch(Exception e){
            isSuccess = false;
            System.debug('Exception:'+e);
            System.debug('Exception Line:'+e.getLineNumber());
           /* if(isLeftQty){
                throw new AuraHandledException('Quantity can not be more than the Left Over Quantity');
            }else{
                throw new giic_SupplyChainException(e.getMessage());
            }*/
            throw new AuraHandledException(e.getmessage());
        }
        return spnwList;
    }
    @AuraEnabled
    public static List<AsyncApexJob> getResetWeekBatchJobStatus(){
        List<String> batchStatusLst = new List<String>();
        List<giic_BatchProgress__c> batchStatusLstUpdated = new List<giic_BatchProgress__c>();
        List<giic_BatchProgress__c> batchStatusLstOld = new List<giic_BatchProgress__c>();
        List<AsyncApexJob> jobInfo = new List<AsyncApexJob>();
       for(giic_BatchProgress__c batchStatus :[Select giic_JobId__c from giic_BatchProgress__c where giic_Status__c=:giic_Constants.RESETWEEKBATCHSTATUS]){
            batchStatusLst.add(batchStatus.giic_JobId__c);
            batchStatusLstOld.add(batchStatus);
        }

        jobInfo = [SELECT Id,Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id IN : batchStatusLst];
        for(AsyncApexJob asynJob : jobInfo){
            for(giic_BatchProgress__c batchSt : batchStatusLstOld){
                if(batchSt.giic_JobId__c == asynJob.Id && asynJob.Status==giic_Constants.COMPLETED){
                    giic_BatchProgress__c batchJob = new giic_BatchProgress__c();
                    batchJob.Id = batchSt.Id;
                    batchStatusLstUpdated.add(batchJob);
                }
            }
        }
        if(batchStatusLstUpdated.size()>0){

            delete batchStatusLstUpdated;
        }
        return jobInfo;
    }
    /****
    @future
    public static void updateSPNL(Set<string> spnlids){
        List<gii__SupplyPlanNettingLine__c> spnldata=[select id,giic_LeftOverQuantity__c,gii__Account__c,gii__CapacityPerWeek__c,gii__DemandForecastLine__c,gii__DemandOrder__c,gii__OrderQuantity__c,gii__OrderType__c,gii__Product__c,gii__ProductCategory__c,gii__ProductionLine__c,giic_ProductionLine__c,gii__ProductionRateHour__c,gii__Sequence__c,gii__Supplier__c,gii__SupplierList__c,giic_SupplierName__c,gii__SupplyPlanCycle__c,giic_UsedCapacityHour__c,giic_WeekCapacityCategoryKey__c,giic_WeekCapacityProductionLineKey__c,gii__WeeklyCapacity__c,giic_WeekNumber__c from gii__SupplyPlanNettingLine__c where id in:spnlids];
                createDOUsedQtyRecord(spnldata);
    }
    ****/
    @AuraEnabled(cacheable=true)
    public static List<SupplyPlanNettingWrapper> closeQtyModal(String filterWrapStr,string searchHeaderData){
        List<SupplyPlanNettingWrapper> spnwList = new List<SupplyPlanNettingWrapper>();
        spnwList=getResultData(filterWrapStr,searchHeaderData);       
        return spnwList;
    }
}