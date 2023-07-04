/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : Class to process all activities related to Forecast Plan
Review By : Vidya Chirlanchi
*************************************************************************************/

public with sharing class giic_forecastPlanController {
    public Static final String HEADER_DATEFORMAT = 'yy';

    /* Method name : fetchProducts
    * Description : this method will be used to fetch the products data
    * Return Type : DfcRecordWrapper
    * Parameter : JSON record as String
    */
    @AuraEnabled
    public static DfcRecordWrapper fetchProducts(String filterWrapStr){
        DfcRecordWrapper dataRecWrap = new DfcRecordWrapper();
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapStr, giic_FilterWrapper.class);
        
        try{
            if(!String.isEmpty(filterWrap.planningCycleId))
            {        
                if(!String.isEmpty(filterWrap.selectedWarehouse.Id)){
                    //getting warehouse records
                    dataRecWrap.selectedWarehouse = [select id, name from gii__Warehouse__c where id=:filterWrap.selectedWarehouse.Id];
                }
                
                dataRecWrap.selectSalesYear = [select id, name, gii__StartDate__c, giic_SKUPlanEndDate__c, gii__AllowRollingForecast__c,gii__SlushyZonePeriodCount__c,
                                gii__AllocationFrom__c, gii__AsofDate__c, gii__Period__c, gii__FrozenZonePeriodCount__c 
                                from gii__DemandForecastCycle__c where id=:filterWrap.planningCycleId];            
            }
            createWrapper(dataRecWrap,filterWrapStr);
        }catch (Exception e) {
            system.debug('error line'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
        return dataRecWrap;
    }

    /* Method name : allocationFrom
    * Description : this method wll be used to get the allocated date
    * Return Type : Date
    * Parameter : start Date, String as value of gii__AllocationFrom__c*/
    public static Date allocationFrom(Date dt, String allocationFrom){
        dt = dt.toStartOfMonth();
        if(allocationFrom != null && allocationFrom.containsIgnoreCase('Mid')){
            dt = dt.addDays(14);
        }
        return dt;
    }

    /* Method name : createWrapper
    * Description : This method will create the wrapper data to show on UI
    * Return Type : String
    * Parameter : DfcRecordWrapper
    */
    @AuraEnabled
    public static string createWrapper(DfcRecordWrapper recWrap, String filterWrapStr){

        /* Variable Declartion*/
        Integer pcount=1;
        Integer numOfPeriod;
        String soql = '';

        recWrap.allMonthsSort = new List<String>();
        recWrap.allPeriods = new List<String>();
        recWrap.allPeriodsMap = new Map<String, String>(); //contains the key as date and month-year as value
        recWrap.allPeriodsDisable= new Map<String, Boolean>(); //key = date
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapStr, giic_FilterWrapper.class);
        try{
            recWrap.startDate = filterWrap.asOfDate != null ? filterWrap.asOfDate.toStartOfMonth() : recWrap.selectSalesYear.gii__StartDate__c;//System.today().toStartOfMonth();
            recWrap.endDate =recWrap.startDate;
            Date today = recWrap.startDate;

            //preparing data for header based on month
            if(filterWrap.strReportingPeriod =='Monthly'){
                for(;recWrap.endDate<=recWrap.selectSalesYear.giic_SKUPlanEndDate__c;recWrap.endDate=recWrap.endDate.addMonths(1)){
                    recWrap.allMonthsSort.add(recWrap.endDate.format());
                    recWrap.allPeriods.add(recWrap.endDate.format());
                    DateTime dtTemp = datetime.newInstance(recWrap.endDate.year(), recWrap.endDate.month(),recWrap.endDate.day());
                    recWrap.allPeriodsMap.put(recWrap.endDate.format(), recWrap.monthKey.get(recWrap.endDate.month()) + '-' + dtTemp.format(HEADER_DATEFORMAT)); 
                    Date td = today.addMonths(recWrap.selectSalesYear.gii__FrozenZonePeriodCount__c != null? Integer.valueOf(recWrap.selectSalesYear.gii__FrozenZonePeriodCount__c) :0);
                    if((td >=recWrap.endDate && td <recWrap.endDate.addMonths(1)) || td <=recWrap.endDate)//if(td<=endDate)         
                    {
                        recWrap.allPeriodsDisable.put(recWrap.endDate.format(), false); //map tp store the disabled months
                    } 
                    else
                    { 
                        recWrap.allPeriodsDisable.put(recWrap.endDate.format(), true); //map tp store the disabled months
                    }
                    if(pcount == filterWrap.numOfPeriods){break;}
                    pcount++;
                }
            }
            /**Variable Declartion */
            List<ProductWrapper> lstProdWrapper = new List<ProductWrapper>();  
            recWrap.prodWrap =  new List<ProductWrapper>(); 
            List<gii__DemandForecast__c> allForecast = new List<gii__DemandForecast__c>();        
            DateTime dT1 = recWrap.startDate;
            DateTime dT2 = recWrap.endDate;
            String sDate = dT1.formatGMT('yyyy-MM-dd');
            String eDate = DT2.formatGMT('yyyy-MM-dd');
            String filterQuery = '';

            //adding where claues to query
            if(String.isNotBlank(filterWrap.lstRegion)){
                filterQuery +=' AND giic_Region__c IN '+filterWrap.lstRegion;
            }
            if(String.isNotBlank(filterWrap.lstCountry)){
                filterQuery += ' AND giic_Country__c IN '+filterWrap.lstCountry;
            }
            if(String.isNotBlank(filterWrap.lstLegalEntity)){
                filterQuery += ' AND giic_LegalEntity__c In '+filterWrap.lstLegalEntity;
            }
            if(String.isNotBlank(filterWrap.lstProductGroup)){
                filterQuery += ' AND gii__ProductReference__r.gii__ProductGroup__r.Name In '+filterWrap.lstProductGroup;
            }
            if(String.isNotBlank(filterWrap.selectedWarehouse.Id)){
                filterQuery += ' AND gii__Warehouse__c = ' + '\'' +filterWrap.selectedWarehouse.Id + '\'';
            }
            if(String.isNotBlank(filterWrap.searchProductName)){
                filterQuery += ' AND gii__ProductReference__c = ' + '\'' +filterWrap.searchProductName + '\'';
            }
            if(String.isNotBlank(filterWrap.subCategory1Value)){
                filterQuery += ' AND gii__ProductReference__r.gii__SubCategory1__c = ' + '\''  +filterWrap.subCategory1Value + '\'';
            }
            if(String.isNotBlank(filterWrap.subCategory2Value)){
                filterQuery += ' AND gii__ProductReference__r.gii__SubCategory2__c = ' + '\''  +filterWrap.subCategory2Value + '\'';
            }
            if(String.isNotBlank(filterWrap.skuVal)){
                List<String> keycs = filterWrap.skuVal.split('\\|');
                filterQuery += ' AND gii__ProductReference__r.gii__ProductCode__c IN ';
                filterQuery += ':keycs ';
            }

            soql =  'select id,giic_Region__c, gii__OpportunityName__c,name, gii__Warehouse__c,gii__Warehouse__r.Name,giic_Account__r.Name,giic_Account__c,giic_LegalEntity__c,giic_Country__c,gii__Warehouse__r.giic_LegalEntity__c,gii__ProductReference__r.gii__ProductStyle__r.name, gii__ProductInventory__c,giic_Priority__c,giic_Owner__r.Name,Owner.Name,'
            +'gii__ProductInventory__r.giic_DemandOrderRecord__c, giic_BusinessUnit__c,giic_Notes__c,giic_Purpose__c,gii__ForecastPriority__c,gii__PurposeOrderPriority__c,gii__PurposeOrder__c, '
            +'gii__ProductReference__c,gii__ProductReference__r.gii__SKUCode__c,gii__ProductReference__r.Name,gii__ProductReference__r.gii__SubCategory1__c,gii__ProductReference__r.gii__SubCategory2__c,gii__ProductInventory__r.gii__Product__r.name,gii__ProductReference__r.gii__ProductCode__c, '
            +'gii__ProductReference__r.gii__Family__c,gii__ProductReference__r.gii__StartofSales__c,gii__ProductReference__r.gii__EndofSales__c,gii__ProductReference__r.gii__ProductGroup__r.Name,gii__ProductReference__r.gii__ProductGroup__r.giic_FrozenZonePeriodCount__c,gii__ProductReference__r.gii__ProductGroup__r.giic_SlushyZonePeriodCount__c,gii__DemandForecastCycle__c,giic_Opportunity__r.Name,giic_Opportunity__r.Account.Name,giic_Opportunity__c,giic_Opportunity__r.XC_LegalEntity__c, '
            +'(select id, name, gii__CurrentQuantity__c,giic_ParentDemandForecastLine__c, giic_DemandForecastPriorModifyBy__r.Name,giic_DemandForecastPriorModifyDate__c,gii__PriorQuantity__c, gii__Date__c, gii__CurrentAmount__c, LastModifiedDate, LastModifiedBy.Name, giic_Prior_vs_Current__c from gii__DemandForecastLines__r '
            + ' where (gii__Date__c>= ' +sDate + ' and gii__Date__c<= ' +eDate + ' ) order by gii__Date__c)'
            +' from gii__DemandForecast__c '
            +' where gii__DemandForecastCycle__c =' + '\''+recWrap.selectSalesYear.id  
            + '\' ' + ' AND gii__ProductReference__r.gii__ProductReference__r.XC_ProductSubType__c !=' + '\''+System.Label.giic_ProductSparePart 
            + '\' '
            + filterQuery 
            +' Order By gii__ProductReference__r.gii__ProductStyle__r.name ASC NULLS LAST, '
            +'gii__ProductInventory__r.gii__Product__r.name NULLS Last ';//limit ' + PageSize + ' offset ' + PageNumber*PageSize;
            String sql = soql;
            allForecast = Database.query(sql);
            Map<String, ProductWrapper> fdHistory= new Map<String, ProductWrapper>();
            Decimal totalForecast = 0;
            Set<Id> dfIds = new Set<Id>(); //set to store all Demand Forecast Ids

            for(gii__DemandForecast__c df : allForecast){
                dfIds.add(df.id);
            }
            
            /**Adding BVU Records for Demand Forecast Products */
            Map<String,List<gii__BusinessValidationOutcome__c>> mapBVU = new Map<String,List<gii__BusinessValidationOutcome__c>>(); //key = demand forecast recid
            if(!dfIds.isEmpty()){
                for(gii__BusinessValidationOutcome__c objBVU : [select id,Name, giic_Demand_Forecast__r.Name,giic_Message__c from gii__BusinessValidationOutcome__c where giic_Demand_Forecast__c In :dfIds]){
                if(objBVU.giic_Demand_Forecast__c != null){
                        if(!mapBVU.containsKey(objBVU.giic_Demand_Forecast__c)){
                            mapBVU.put(objBVU.giic_Demand_Forecast__c, new List<gii__BusinessValidationOutcome__c>());
                        }
                        mapBVU.get(objBVU.giic_Demand_Forecast__c).add(objBVU); 
                    }
                }
            }
            
            //preparing forecast data for each demand forecast record
            for(gii__DemandForecast__c pi : allForecast)
            {
                ProductWrapper pw = new ProductWrapper();
                pw.prodRegion = pi.giic_Region__c;
                pw.productName = pi.gii__ProductReference__r.Name;
                pw.productstyle = pi.gii__ProductReference__r.gii__ProductStyle__r.name;
                pw.productSKU = pi.gii__ProductReference__r.gii__ProductCode__c;
                pw.productId = pi.gii__ProductReference__c;
                pw.productCode = pi.gii__ProductReference__r.gii__ProductCode__c;
                pw.productFamily = pi.gii__ProductReference__r.gii__Family__c;
                pw.productCategory = pi.gii__ProductReference__r.gii__ProductGroup__r.Name;
                pw.productSubcategory1 = pi.gii__ProductReference__r.gii__SubCategory1__c != null ? pi.gii__ProductReference__r.gii__SubCategory1__c : '';
                pw.productSubcategory2 = pi.gii__ProductReference__r.gii__SubCategory2__c != null ? pi.gii__ProductReference__r.gii__SubCategory2__c : '';
                pw.priority = pi.gii__ForecastPriority__c != null ? pi.gii__ForecastPriority__c : 0;
                pw.productOwner = pi.Owner.Name;
                pw.productBusinessUnit = pi.giic_BusinessUnit__c != null ? pi.giic_BusinessUnit__c : '';
                pw.productPurpose = pi.gii__PurposeOrder__c != null ? pi.gii__PurposeOrder__c : '';
                pw.oppName = pi.gii__OpportunityName__c != null ? pi.gii__OpportunityName__c : '';
                pw.purposeOrderPriority = pi.gii__PurposeOrderPriority__c != null ? pi.gii__PurposeOrderPriority__c : 0;
                pw.opportunityName = pi.giic_Opportunity__c != null ? pi.giic_Opportunity__r.Account.Name : (pi.giic_Account__c != null ? pi.giic_Account__r.Name : null);//pi.giic_Opportunity__r.Name;
                pw.legalEntity = pi.giic_LegalEntity__c;
                pw.warehouse = pi.gii__Warehouse__r.Name;
                pw.country = pi.giic_Country__c;
                pw.prodNotes = pi.giic_Notes__c != null ? pi.giic_Notes__c : '';
                pw.frozenCount = pi.gii__ProductReference__r.gii__ProductGroup__r.giic_FrozenZonePeriodCount__c != null ? pi.gii__ProductReference__r.gii__ProductGroup__r.giic_FrozenZonePeriodCount__c : 0;
                pw.slushyCount = pi.gii__ProductReference__r.gii__ProductGroup__r.giic_SlushyZonePeriodCount__c != null ? pi.gii__ProductReference__r.gii__ProductGroup__r.giic_SlushyZonePeriodCount__c : 0;
                pw.prodStartDate = pi.gii__ProductReference__r.gii__StartofSales__c;
                pw.prodEndDate = pi.gii__ProductReference__r.gii__EndofSales__c;
                if(mapBVU.containsKey(pi.id)){
                    pw.lstBVUMsgs = mapBVU.get(pi.id);
                }
                totalForecast = 0;
                pw.proForecast = new gii__DemandForecast__c (Id=pi.Id, gii__Warehouse__c=pi.gii__Warehouse__c,
                gii__ProductReference__c=pi.gii__ProductReference__c, gii__ProductInventory__c=pi.gii__ProductInventory__c,
                gii__DemandForecastCycle__c=pi.gii__DemandForecastCycle__c);
                pw.hasDO = (pi.gii__ProductInventory__r.giic_DemandOrderRecord__c != null && 
                            pi.gii__ProductInventory__r.giic_DemandOrderRecord__c>0?true:false);
                
                pw.periodQty = new Map<String,String>();
                pw.cellEdited = new Map<String,Boolean>();
                pw.idPeriodQty = new Map<String,Id>();
                pw.periodDisabled = new Map<String,Boolean>();
                pw.periodDFLine = new Map<String, gii__DemandForecastLine__c>();
                
                /* #START calculating frozen and slushy for each demand forecast line record*/
                Date selectedDate =  recWrap.startDate; //Give your date
                Date firstDate = selectedDate.toStartOfMonth();
                if(pw.frozenCount > 0){
                    for(Integer i=1;i<=pw.frozenCount;i++){
                        pw.zoneMap.put(firstDate.format(),'frozen');
                        firstDate = firstDate.addMonths(1);
                    }
                }    
                if(pw.slushyCount > 0){
                    for(Integer i=1;i<=pw.slushyCount;i++){
                        pw.zoneMap.put(firstDate.format(),'slushy');
                        firstDate = firstDate.addMonths(1);
                    } 
                }
                /** #END */

                for(String pkey : recWrap.allPeriods){
                    pw.periodQty.put(pkey, '0'); //initialise qty value of key with 0
                    pw.periodDFLine.put(pKey, new gii__DemandForecastLine__c());
                }
                integer count = 1;
                Date td;
                for(String pkey : recWrap.allPeriods){
                    if(count == 1){
                        td = Date.parse(pkey).addMonths(pw.frozenCount != null? Integer.valueOf(pw.frozenCount) - 1 :0);
                    }
                    count++;
                    if(td >= Date.parse(pkey))        
                    {
                        pw.periodDisabled.put(pkey, false); //map tp store the enabled months
                    } 
                    else
                    { 
                        pw.periodDisabled.put(pkey, true); //map to store the disabled months
                    }
                }
                for(gii__DemandForecastLine__c fd :  pi.gii__DemandForecastLines__r)
                {
                    if(fd.gii__CurrentQuantity__c != null){
                        totalForecast += fd.gii__CurrentQuantity__c;
                    }
                    Integer alcount=1;
                    Date alsd = fd.gii__Date__c;
                    if(filterWrap.strReportingPeriod =='Monthly'){
                        String pKey = allocationFrom(fd.gii__Date__c, recWrap.selectSalesYear.gii__AllocationFrom__c).format();
                        if(!pw.periodQty.containsKey(pKey)){pw.periodQty.put(pKey, '0');}                     
                        Integer qty = Integer.valueOf(pw.periodQty.get(pKey));
                        fd.gii__CurrentQuantity__c  = fd.gii__CurrentQuantity__c != null ? fd.gii__CurrentQuantity__c : 0; //added
                        pw.periodQty.put(pKey,String.valueOf(qty + fd.gii__CurrentQuantity__c));
                        pw.idPeriodQty.put(pKey, fd.Id);
                        pw.periodDFLine.put(pKey, fd);
                    }
                }
                pw.total = String.valueOf(totalForecast);
                for(integer i=0;i<recWrap.allPeriods.size();i++)
                {
                    if(!pw.periodQty.keyset().contains(recWrap.allPeriods[i]))
                    {
                        pw.periodQty.put(recWrap.allPeriods[i],'');
                    }
                    pw.cellEdited.put(recWrap.allPeriods[i],false);
                }
                lstProdWrapper.add(pw);
                recWrap.prodWrap = lstProdWrapper;

            }            
            if(recWrap.endDate < allocationFrom(recWrap.selectSalesYear.giic_SKUPlanEndDate__c, recWrap.selectSalesYear.gii__AllocationFrom__c)) {recWrap.hasNext = true;}
            else if (recWrap.endDate >= allocationFrom(recWrap.selectSalesYear.giic_SKUPlanEndDate__c, recWrap.selectSalesYear.gii__AllocationFrom__c)){recWrap.hasNext = false;}
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
        return null;
        
    }

    /* Method name : del
    * Description : this method will delete the records of demand forecast
    * Return Type : DfcRecordWrapper
    * Parameter : DfcRecordWrapper JSON as String
    */
    @AuraEnabled
    public static DfcRecordWrapper del(String productSearch,String filterWrapperStr){
        DfcRecordWrapper dataRecWrap = (DfcRecordWrapper)JSON.deserialize(productSearch,DfcRecordWrapper.class);
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapperStr, giic_FilterWrapper.class);
        List< String > lstProdInvId = new List< String >();
        List<gii__DemandForecast__c> lstForecast = new List< gii__DemandForecast__c>();
        List<ProductWrapper> listTProdWrapper = new List<ProductWrapper>();
        /** if checked is true in wrapper for a demand foreacst record */
        for(ProductWrapper w :dataRecWrap.prodWrap) {
            if(w.checked) {          
                if ( w.proForecast != null ){
                    lstProdInvId.add(w.proForecast.id);                    
                }
            } else {
                listTProdWrapper.add(w);
            }
        }
        
        lstForecast = [select id from gii__DemandForecast__c where id IN :lstProdInvId];
        try{
            if(lstForecast.size() > 0) {
                delete lstForecast;
                createWrapper(dataRecWrap,filterWrapperStr);
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
        return dataRecWrap;
    }

    /* Method name : saveForeCastDetails
    * Description : this method will insert or update the records of demand forecast
    * Return Type : DfcRecordWrapper
    * Parameter : DfcRecordWrapper JSON as String
    */
    @AuraEnabled
    public static DfcRecordWrapper saveForeCastDetails(String productSearch, String filterWrapper){
       
        DfcRecordWrapper dataRecWrap = (DfcRecordWrapper)JSON.deserialize(productSearch,DfcRecordWrapper.class);
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapper, giic_FilterWrapper.class);
        /**Variable Declartion */
        List<gii__DemandForecast__c> lstSelectedForecast = new List<gii__DemandForecast__c>();
        List<gii__DemandForecast__c> lstToUpdateDf =  new List<gii__DemandForecast__c>();
        Map<Id,gii__DemandForecast__c> dfMap = new Map<Id,gii__DemandForecast__c>();
        Map<String, Id> mpBizPlan = new Map<string, Id>();
        Date date1 = filterWrap.asOfDate;
        system.debug('filterWrap.numOfPeriods'+filterWrap.numOfPeriods);
        Date datetest = date1.addmonths(filterWrap.numOfPeriods);
        system.debug('datetest'+datetest);
        Date date2 = dataRecWrap.selectSalesYear.giic_SKUPlanEndDate__c;
        Integer numOfPeriod = date1.monthsBetween(date2);
        //getting business plan record for the demand forecast cycle
        system.debug('numOfPeriod -'+numOfPeriod);
        system.debug(' dataRecWrap.allPeriods[i]'+ dataRecWrap.allPeriods);
        for(gii__BusinessPlan__c bp :[Select Id, gii__DemandForecastCycle__c, gii__Date__c, gii__ProductReference__c
                from gii__BusinessPlan__c where gii__DemandForecastCycle__c = :dataRecWrap.selectSalesYear.Id and gii__Date__c!=null])
        {
            Date dt = bp.gii__Date__c;
            if(bp.gii__ProductReference__c != null){
                String bizKey = bp.gii__ProductReference__c + '-' + dt.month() +  + '-' + dt.year(); //key for mpBizPlan
                mpBizPlan.put(bizKey, bp.Id); 
            }  
        }

        for(ProductWrapper objProdWrap : dataRecWrap.prodWrap){
              lstSelectedForecast.add(objProdWrap.proForecast);  
        }
        for(gii__DemandForecast__c df : [select id,gii__OpportunityName__c,gii__ForecastPriority__c,giic_Notes__c,gii__PurposeOrderPriority__c,gii__PurposeOrder__c from gii__DemandForecast__c where id In:lstSelectedForecast]){
            dfMap.put(df.id,df);
        }

        List<gii__DemandForecastLine__c> lstChild = new List<gii__DemandForecastLine__c>();
        for(ProductWrapper objProdWrap : dataRecWrap.prodWrap)
        {
            /** Updating Demand Forecast record values */
            if(dfMap.containsKey(objProdWrap.proForecast.id)){
                system.debug('inside if --');
                gii__DemandForecast__c df = new gii__DemandForecast__c();
                df.gii__ForecastPriority__c = objProdWrap.priority != null ? objProdWrap.priority : dfMap.get(objProdWrap.proForecast.id).gii__ForecastPriority__c;
                df.gii__PurposeOrderPriority__c = objProdWrap.purposeOrderPriority != null ? objProdWrap.purposeOrderPriority : dfMap.get(objProdWrap.proForecast.id).gii__PurposeOrderPriority__c;
                df.gii__PurposeOrder__c = objProdWrap.productPurpose != null ? objProdWrap.productPurpose : dfMap.get(objProdWrap.proForecast.id).gii__PurposeOrder__c;
                df.gii__OpportunityName__c = objProdWrap.oppName != null ? objProdWrap.oppName : dfMap.get(objProdWrap.proForecast.id).gii__OpportunityName__c;
                df.Id = objProdWrap.proForecast.id;
                df.giic_Notes__c = objProdWrap.prodNotes != null ? objProdWrap.prodNotes :  dfMap.get(objProdWrap.proForecast.id).giic_Notes__c;
                lstToUpdateDf.add(df);
            }
            /** Updating and inserting demand forecast line */
             
            for(integer i=0;i<numOfPeriod;i++)
            {
                system.debug('inside if fr --');
                String periodKey = dataRecWrap.allPeriods[i];
                Map<String,String> periodQtyMap = objProdWrap.periodQty;
                Map<String,String> idPeriodQtyMap = objProdWrap.idPeriodQty;
                String periodQty = periodQtyMap.get(periodKey); 
                String idPeriodQty = idPeriodQtyMap.get(periodKey);
                Date fdDate ;
                try{
                    fdDate =date.parse(dataRecWrap.allPeriods[i]);
                }
                catch(exception e){
                    fdDate =date.valueOf(dataRecWrap.allPeriods[i]);
                }   
                if(periodQty != null && Decimal.valueOf(periodQty)>0 )
                {
                    gii__DemandForecastLine__c lineObj = new gii__DemandForecastLine__c();
                    lineObj.gii__Date__c=fdDate; 
                    lineObj.gii__CurrentQuantity__c = Decimal.valueOf(periodQty);    
                    lineObj.gii__DemandForecast__c=objProdWrap.proForecast.id;
                    String bizKey = objProdWrap.productId + '-' + fdDate.month() +  + '-' + fdDate.year();
                    if(mpBizPlan.containsKey(bizKey)) {lineObj.gii__BusinessPlan__c = mpBizPlan.get(bizKey);}
                    system.debug('inside if  periodQty--'+periodQty + 'objProdWrap.proForecast.id --'+objProdWrap.proForecast.id);
                    if(idPeriodQty != null)
                    {
                        lineObj.id=idPeriodQty;
                    }
                    /*if(filterWrap.lstDFS == null || filterWrap.lstDFS.isEmpty()){
                        lineObj.gii__PriorQuantity__c = Decimal.valueOf(periodQty);
                    }else if(!filterWrap.lstDFS.isEmpty() && filterWrap.lstDFS[0].giic_ApprovalStatus__c != giic_Constants.APPUPDATEPLAN && !filterWrap.lstDFS[0].giic_isCycleFirstRun__c){
                        lineObj.gii__PriorQuantity__c = objProdWrap.periodDFLine.get(periodKey).gii__CurrentQuantity__c;
                    } */
                    lstChild.add(lineObj);
                }else{
                if(periodQty == null || periodQty == '' || Decimal.valueOf(periodQty)==0){
                    if(idPeriodQty != null && !String.isBlank(idPeriodQty)){
                        gii__DemandForecastLine__c lineObj = new gii__DemandForecastLine__c(id=idPeriodQty, gii__CurrentQuantity__c=0);
                        String bizKey = objProdWrap.productId + '-' + fdDate.month() +  + '-' + fdDate.year();
                        if(mpBizPlan.containsKey(bizKey)){lineObj.gii__BusinessPlan__c = mpBizPlan.get(bizKey);}
                        lstChild.add(lineObj); 
                    }  
                }
                }         
            }
        }
        try{
            if(!lstToUpdateDf.isEmpty()){
                update lstToUpdateDf;
            }
            if(!lstChild.isEmpty()){
                upsert lstChild;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
        createWrapper(dataRecWrap,filterWrapper);
        return dataRecWrap;
    }

    /* Method name : submitForApproval
    * Description : This method will create/update and submit the record for approval of Demand Forecast setup
    * Return Type : DfcRecordWrapper
    * Parameter : DfcRecordWrapper JSON as String
    */
    @AuraEnabled
    public static DfcRecordWrapper submitForApproval(String productSearch, String filterWrapperStr){  
        DfcRecordWrapper dataRecWrap = (DfcRecordWrapper)JSON.deserialize(productSearch,DfcRecordWrapper.class);
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapperStr, giic_FilterWrapper.class);
        saveForeCastDetails(productSearch,filterWrapperStr);

        /**Variable Declaration */
        String region = filterWrap.setupRegion.replace('(','').replace(')','');
        gii__DemandForecastSetup__c objDFS = new gii__DemandForecastSetup__c();
        List<gii__DemandForecast__c> lstSelectedForecast = new List<gii__DemandForecast__c>();
        for(ProductWrapper objProdWrap : dataRecWrap.prodWrap){
              lstSelectedForecast.add(objProdWrap.proForecast);  
        }

        /** inserting and updating demand forecast setup record */
        if(filterWrap.lstDFS.isEmpty()){
            objDFS.giic_DemandForecastCycle__c = filterWrap.planningCycleId;
            objDFS.giic_RelatedTo__c = giic_Constants.FORECASTPLAN;
            objDFS.giic_ApprovalStatus__c = giic_Constants.PENDINGFORAPPROVAL;
            objDFS.giic_Region__c = region;
           insert objDFS;
        }else if(filterWrap.lstDFS[0].giic_ApprovalStatus__c == giic_Constants.APPUPDATEPLAN || filterWrap.lstDFS[0].giic_ApprovalStatus__c==giic_Constants.REJECTEDPLAN ){
            filterWrap.lstDFS[0].giic_ApprovalStatus__c = giic_Constants.PENDINGFORAPPROVAL;
            update filterWrap.lstDFS[0];
        }
        //getting demand forecast lines 
        List<gii__DemandForecastLine__c> lstDFL = new List<gii__DemandForecastLine__c>([select Name, gii__Date__c, gii__CurrentQuantity__c, gii__DemandForecast__c, 
                                     gii__DemandForecast__r.gii__ProductInventory__c,gii__DemandForecast__r.giic_Region__c,giic_DemandForecastSetup__c 
                                     from gii__DemandForecastLine__c
                                     where gii__DemandForecast__c in: lstSelectedForecast and gii__DemandForecast__r.giic_Region__c =:region ]);
        for(gii__DemandForecastLine__c objDFL : lstDFL){
            if(objDFS.id != null){
                objDFL.giic_DemandForecastSetup__c = objDFS.id;
            }else{
                objDFL.giic_DemandForecastSetup__c = filterWrap.lstDFS[0].id;
            }
        }
        try{
            if(lstDFL.size() > 0 && lstDFL !=null){
                update lstDFL;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
        //createWrapper(dataRecWrap,filterWrapperStr);
        return dataRecWrap;
    }

    /* Method name : approveRecord
    * Description : this method will Approve the record of Demand Forecast Setup
    * Return Type : DfcRecordWrapper
    * Parameter : DfcRecordWrapper JSON as String
    */
    @AuraEnabled
    public static DfcRecordWrapper approveRecord(String dfcWrapper,String filterWrapperStr){

        DfcRecordWrapper dataRecWrap = (DfcRecordWrapper)JSON.deserialize(dfcWrapper,DfcRecordWrapper.class);
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapperStr, giic_FilterWrapper.class);
        saveForeCastDetails(dfcWrapper,filterWrapperStr);
        String region = filterWrap.setupRegion.replace('(','').replace(')','');

        if(filterWrap.lstDFS[0].giic_ApprovalStatus__c == giic_Constants.REQUPDATEPLAN){
            List<gii__DemandForecastSetup__c> objDFSDP = [select id,giic_ApprovalStatus__c,giic_BatchStatus__c from gii__DemandForecastSetup__c where giic_Region__c =:region and giic_DemandForecastCycle__c = :filterWrap.planningCycleId and giic_RelatedTo__c = :giic_Constants.DEMANDPLAN];
            if(!objDFSDP.isEmpty()){
                for(gii__DemandForecastSetup__c dfs : objDFSDP){
                    dfs.giic_ApprovalStatus__c = '';
                    dfs.giic_BatchStatus__c = '';
                }
                update objDFSDP;
            }
        }

        giic_CommonUtility.approvePlan(filterWrap.planningCycleId,giic_Constants.FORECASTPLAN, dataRecWrap.approvalComments); //approve the record of Demand forecast Setup
        
        //createWrapper(dataRecWrap,filterWrapperStr);
        return dataRecWrap;
    }

    /* Method name : rejectRecord
    * Description : this method will Reject the record of Demand Forecast Setup
    * Return Type : DfcRecordWrapper
    * Parameter : DfcRecordWrapper JSON as String
    */
    @AuraEnabled
    public static DfcRecordWrapper rejectRecord(String dfcWrapper,String filterWrapperStr){

        DfcRecordWrapper dataRecWrap = (DfcRecordWrapper)JSON.deserialize(dfcWrapper,DfcRecordWrapper.class);
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapperStr, giic_FilterWrapper.class);
        saveForeCastDetails(dfcWrapper,filterWrapperStr);

        giic_CommonUtility.rejectPlan(filterWrap.planningCycleId,giic_Constants.FORECASTPLAN,dataRecWrap.rejectionComments); //Reject the record of Demand Forecast Setup

        //createWrapper(dataRecWrap);
        return dataRecWrap;
    }

    /* Method name : requestForEditApprovedFP
    * Description : this method will update the record of Demand Forecast Setup
    * Return Type : DfcRecordWrapper
    * Parameter : DfcRecordWrapper JSON as String
    */
    @AuraEnabled
    public static DfcRecordWrapper requestForEditApprovedFP(String productSearch,String filterWrapperStr){ 
        DfcRecordWrapper dataRecWrap = (DfcRecordWrapper)JSON.deserialize(productSearch,DfcRecordWrapper.class);
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapperStr, giic_FilterWrapper.class);
        try{
            for(gii__DemandForecastSetup__c objDFS : filterWrap.lstDFS){
                objDFS.giic_ApprovalStatus__c = giic_Constants.REQUPDATEPLAN;
                objDFS.giic_BatchStatus__c = '';
            }
            update filterWrap.lstDFS;
            createWrapper(dataRecWrap,filterWrapperStr);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
        return dataRecWrap;
    }

    /* Method name : updateDemandOrderQty
    * Description : this method will call batch to create or update Demand Order Quantity
    * Return Type : null
    * Parameter : DfcRecordWrapper JSON as String
    */
    @AuraEnabled
    public static void updateDemandOrderQty(String productSearch,String filterWrapperStr){  
        DfcRecordWrapper dataRecWrap = (DfcRecordWrapper)JSON.deserialize(productSearch,DfcRecordWrapper.class);
        giic_FilterWrapper filterWrap = (giic_FilterWrapper) JSON.deserialize(filterWrapperStr, giic_FilterWrapper.class);
        gii__DemandForecastSetup__c updateDemandForcastSetup=new gii__DemandForecastSetup__c();
        id demandPlanCycleID=filterWrap.lstDFS[0].giic_DemandForecastCycle__c;
        try{
            if(filterWrap.lstDFS[0].id!=null){
                updateDemandForcastSetup.id=filterWrap.lstDFS[0].id;
                updateDemandForcastSetup.giic_BatchStatus__c=giic_Constants.INPROGRESS;
                update updateDemandForcastSetup;
            }
            Id aprxJobId =  Database.executeBatch(new giic_UpdateDemandOrderQtyBatch(dataRecWrap.selectSalesYear.gii__StartDate__c,dataRecWrap.selectSalesYear.giic_SKUPlanEndDate__c,filterWrap.setupRegion,dataRecWrap.selectSalesYear.id),200);
            giic_BatchProgress__c jobstatus = new giic_BatchProgress__c();
            jobstatus.Name = aprxJobId; 
            jobstatus.giic_JobId__c = aprxJobId;
            jobstatus.giic_Status__c = giic_Constants.FORECASTPLANBATCHSTATUS;
            insert jobstatus;
        }catch(Exception e){
            system.debug('error line'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage().substringAfter('EXCEPTION,').substringBefore(': []'));
        }
    }

     /* Method name : getBatchJobStatus
    * Description : this method will return apex job id and delete completed job ids
    * Return Type : List<AsyncApexJob>
    * Parameter : null
    */
    @AuraEnabled
    public static List<AsyncApexJob> getBatchJobStatus(){
        List<String> batchStatusLst = new List<String>();
        List<giic_BatchProgress__c> batchStatusLstUpdated = new List<giic_BatchProgress__c>();
        List<giic_BatchProgress__c> batchStatusLstOld = new List<giic_BatchProgress__c>();
        List<AsyncApexJob> jobInfo = new List<AsyncApexJob>();
       for(giic_BatchProgress__c batchStatus :[Select giic_JobId__c from giic_BatchProgress__c where giic_Status__c=:giic_Constants.FORECASTPLANBATCHSTATUS]){
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

    /* Method name : getReportId
    * Description : this method will return report id
    * Return Type : String
    * Parameter : null
    */
    @AuraEnabled
    public static String getReportId(){
        return [SELECT Id,Name,DeveloperName FROM Report WHERE DeveloperName=:giic_Constants.EXPORTFP LIMIT 1].Id;
    }



    /** Wrapper class to hold demand forecast line data */
    public class ProductWrapper implements Comparable
    {
        @AuraEnabled public string productName;
        @AuraEnabled public string productstyle;
        @AuraEnabled public String productId;
        @AuraEnabled public String productSKU;
        @AuraEnabled public String productCode;
        @AuraEnabled public String productFamily;
        //@AuraEnabled public Decimal productCost;
        @AuraEnabled public gii__DemandForecast__c proForecast;
        @AuraEnabled public String total;
        //@AuraEnabled public String totalPrice;
        @AuraEnabled public Map<String, Boolean> periodDisabled;
        @AuraEnabled public Map<String, String> periodQty;
        //@AuraEnabled public Map<String, String> periodPrice;
        @AuraEnabled public Map<String, Id> idPeriodQty;
        @AuraEnabled public Map<String, Boolean> cellEdited;
        @AuraEnabled public Boolean checked ;
        @AuraEnabled public Boolean hasDO;
        @AuraEnabled public Map<String, gii__DemandForecastLine__c> periodDFLine;
        @AuraEnabled public String country;
        @AuraEnabled public String legalEntity;
        @AuraEnabled public String opportunityName;
        @AuraEnabled public String warehouse;
        @AuraEnabled public Decimal priority;
       // @AuraEnabled public Date requestedDeliveryDate;
        @AuraEnabled public String productCategory;
        @AuraEnabled public String productSubcategory1;
        @AuraEnabled public String productSubcategory2;
        @AuraEnabled public String productOwner;
        @AuraEnabled public String productBusinessUnit;
        @AuraEnabled public String productPurpose;
        @AuraEnabled public String prodNotes;
        @AuraEnabled public List<gii__BusinessValidationOutcome__c> lstBVUMsgs;
        @AuraEnabled public Decimal frozenCount;
        @AuraEnabled public Decimal slushyCount;
        @AuraEnabled public Date prodStartDate;
        @AuraEnabled public Date prodEndDate;
        @AuraEnabled public Map<String,String> zoneMap;
        @AuraEnabled public Decimal purposeOrderPriority;
        @AuraEnabled public String prodRegion;
        @AuraEnabled public String oppName;
        
        public ProductWrapper() {
            periodDFLine = new Map<String, gii__DemandForecastLine__c>();      
            lstBVUMsgs = new List< gii__BusinessValidationOutcome__c>(); 
            zoneMap = new Map<String,String>();
            productBusinessUnit = '';
            productPurpose = '';
            prodNotes = '';
            prodRegion='';
            oppName = '';
            checked = false;
        }

        
        public Integer compareTo(Object compareTo) {
            ProductWrapper compareToEmp = (ProductWrapper)compareTo;
            if (productstyle == compareToEmp.productstyle) {return 0;}
            if (productstyle > compareToemp.productstyle) {return 1;}
            return -1;
        }
    } 

     /** Wrapper class to hold demand forecast cycle and demand forecast related data */
    public class DfcRecordWrapper{
        @AuraEnabled public String forecastValue;
        @AuraEnabled public String strReportingPeriod;
        @AuraEnabled public Date asOfDate;
        @AuraEnabled public List<String> allMonths;
        @AuraEnabled public Map<Integer, String> monthKey;
        @AuraEnabled public List<String> allMonthsSort;
        @AuraEnabled public String planningCycleName;
        @AuraEnabled public gii__DemandForecast__c objForecast;
        @AuraEnabled public List<gii__DemandForecastSetup__c> lstDFS;
        @AuraEnabled public gii__DemandForecastCycle__c selectSalesYear;
        @AuraEnabled public Map<String,Boolean> allPeriodsDisable;
        @AuraEnabled public gii__ProductInventory__c objProdInventory;
        @AuraEnabled public gii__Warehouse__c selectedWarehouse;
        @AuraEnabled public gii__Product2Add__c objProd;
        @AuraEnabled public List<String> allPeriods;
        @AuraEnabled public Map<String, String> allPeriodsMap;
        @AuraEnabled public Boolean hasPrevious;
        @AuraEnabled public Boolean hasNext;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;    
        @AuraEnabled public List<ProductWrapper> prodWrap;
        @AuraEnabled public String searchProductId;
        @AuraEnabled public String countryValue;
        @AuraEnabled public String legalEntityVal;
        @AuraEnabled public Map<String,Map<String,List<String>>> mapRegionCountry;
        @AuraEnabled public Map<String,List<String>> mapCountryLegalEntry;
        @AuraEnabled public Map<String,List<gii__Warehouse__c>> mapLegalEntityWarehouse;
        @AuraEnabled public String approvalComments;
        @AuraEnabled public String rejectionComments;
        @AuraEnabled public Account oppAccount;
        @AuraEnabled public String productPurpose;
        @AuraEnabled public Date reqDeliveryDate;
        @AuraEnabled public String ownerId;
        @AuraEnabled public Boolean isApprover;
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
        @AuraEnabled public list<gii__ProductGroup__c> lstProductGroups;
       
        public DfcRecordWrapper(){
            searchProductId = '';
            rejectionComments = '';
            approvalComments = '';
            legalEntityVal = '';
            countryValue = '';
            productPurpose = '';
            ownerId = '';
            isApprover = false;
            objForecast = new gii__DemandForecast__c();
            objProdInventory = new gii__ProductInventory__c();
            selectedWarehouse = new gii__Warehouse__c();
            objProd = new gii__Product2Add__c();
            selectSalesYear = new gii__DemandForecastCycle__c();
            oppAccount = new Account();
            allMonthsSort = new List<String>();
            allPeriods = new List<String>();
            allPeriodsMap = new Map<String, String>();
            allPeriodsDisable= new Map<String, Boolean> ();
            lstDFS = new List<gii__DemandForecastSetup__c>();
            strReportingPeriod ='Monthly';
            asOfDate = System.today();
            reqDeliveryDate = System.today();
            mapRegionCountry = new Map<String,Map<String,List<String>>>();
            mapCountryLegalEntry = new Map<String,List<String>>();
            mapLegalEntityWarehouse = new Map<String,List<gii__Warehouse__c>>();
            allMonths = new List<String>
            {
                'January','February','March','April','May','June','July',
                'August','September','October', 'November','December'
            };
            allMonthsSort = new List<String> ();
            monthKey = new Map<Integer, String>
            {
                1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',
                8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'
            };
            lstProductGroups = new List<gii__ProductGroup__c>();
        }
    }

}