/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : Batch Class to create/update Demand Order
Reviewer - Soni Jagdale
*************************************************************************************/

public class giic_CreateDOBatch implements Database.Batchable<sObject>, Database.Stateful {
 
    //Variable declaration
    public String dfcRecId;
    public integer count = 0;
    public boolean isSparePart;
    public string region = '';
    public String planName;
    String WhereCondition = '';
    //Constructor
    public giic_CreateDOBatch(String dfcId,Boolean sparePart, String regionName, String planname) {
        system.debug('sparePart'+sparePart);
        this.dfcRecId = dfcId;
        this.isSparePart = sparePart;
        if(String.isNotBlank(regionName)){
            this.region = regionName.replace('(','').replace(')','').replaceAll('\'','');
        }
        this.planName = planname;
    }

    /* Method name : start
    * Description : Start method which will return all approved demand forecast lines for demand plan
    * Return Type : Database.QueryLocator
    * Parameter : Database.BatchableContext 
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        //get all demand forecast lines
        if(isSparePart){
            WhereCondition += ' and gii__DemandForecast__r.giic_Region__c ='+'\''+region+'\''+ ' And giic_Station__c!=null '; 
        }else{
            WhereCondition += ' And giic_Station__c=null'; 
        }
        string query='select Name, gii__Date__c, gii__CurrentQuantity__c,gii__DemandForecast__r.gii__DemandForecastCycle__c, gii__DemandForecast__c,giic_DemandForecastSetup__c,giic_DemandForecastSetup__r.giic_ApprovalStatus__c,gii__DemandForecast__r.gii__ProductInventory__c,giic_DemandPlanCurrentQuantity__c,gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c,gii__DemandForecast__r.giic_Region__c,gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c,giic_DemandPlanPriorQuantity__c,gii__DemandForecast__r.gii__ForecastPriority__c,gii__DemandForecast__r.gii__PurposeOrderPriority__c,gii__DemandForecast__r.gii__PurposeOrder__c,gii__DemandForecast__r.giic_Opportunity__c,gii__DemandForecast__r.giic_Opportunity__r.AccountId,gii__DemandForecast__r.giic_Account__c,gii__DemandForecast__r.giic_Account__r.Name,giic_PrevDFLKey__c,giic_ParentDemandForecastLine__c,giic_ParentDemandForecastLine__r.gii__DemandForecast__c from gii__DemandForecastLine__c '
                        +'Where (((giic_DemandPlanCurrentQuantity__c > 0 OR giic_DemandPlanPriorQuantity__c >0 ) and giic_DemandForecastPlanSetup__r.giic_ApprovalStatus__c ='+'\''+giic_Constants.APPROVED+'\''+' and giic_DemandForecastPlanSetup__r.giic_RelatedTo__c = '+'\''+giic_Constants.DEMANDPLAN+'\''+') OR (gii__DemandForecast__r.gii__ProductReference__r.gii__ProductReference__r.XC_ProductSubType__c='+'\''+System.Label.giic_ProductSparePart+'\''+' and (gii__CurrentQuantity__c>0 OR gii__PriorQuantity__c > 0) and giic_DemandForecastSetup__r.giic_ApprovalStatus__c ='+'\''+giic_Constants.APPROVED+'\''+'  and giic_DemandForecastSetup__r.giic_RelatedTo__c = '+'\''+giic_Constants.SPAREPLAN +'\''+')) and  gii__DemandForecast__r.gii__DemandForecastCycle__c='+'\''+dfcRecId+'\'' 
                        +WhereCondition ;  
        system.debug('query is ---'+query);           
        return Database.getQueryLocator(query);
        /* return Database.getQueryLocator([select Name, gii__Date__c, gii__CurrentQuantity__c,gii__DemandForecast__r.gii__DemandForecastCycle__c, gii__DemandForecast__c, giic_DemandForecastSetup__c,giic_DemandForecastSetup__r.giic_ApprovalStatus__c,
                                     gii__DemandForecast__r.gii__ProductInventory__c,giic_DemandPlanCurrentQuantity__c,
                                     gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c,gii__DemandForecast__r.giic_Region__c,gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c,giic_DemandPlanPriorQuantity__c,
                                     gii__DemandForecast__r.gii__ForecastPriority__c,gii__DemandForecast__r.gii__PurposeOrderPriority__c,
                                     gii__DemandForecast__r.gii__PurposeOrder__c,gii__DemandForecast__r.giic_Opportunity__c,gii__DemandForecast__r.giic_Opportunity__r.AccountId,gii__DemandForecast__r.giic_Account__c,gii__DemandForecast__r.giic_Account__r.Name,
                                     giic_PrevDFLKey__c,giic_ParentDemandForecastLine__c,giic_ParentDemandForecastLine__r.gii__DemandForecast__c
                                     from gii__DemandForecastLine__c
                                     where (((giic_DemandPlanCurrentQuantity__c > 0 OR giic_DemandPlanPriorQuantity__c >0 )and giic_DemandForecastSetup__r.giic_ApprovalStatus__c = :giic_Constants.APPROVED and giic_DemandForecastSetup__r.giic_RelatedTo__c = :giic_Constants.DEMANDPLAN ) OR 
                                     (gii__DemandForecast__r.gii__ProductReference__r.gii__ProductReference__r.XC_ProductSubType__c= :System.Label.giic_ProductSparePart and (gii__CurrentQuantity__c>0 OR gii__PriorQuantity__c > 0)   and giic_DemandForecastSetup__r.giic_RelatedTo__c = :giic_Constants.SPAREPLAN )) and  gii__DemandForecast__r.gii__DemandForecastCycle__c=:dfcRecId and gii__DemandForecast__r.giic_Region__c =:region and (isSparePart?giic_Station__c!=null:giic_Station__c==null)]);
    */ 
    }

    /* Method name : execute
    * Description : execute method will create and update the demand orders
    * Return Type : void
    * Parameter : List<gii__DemandForecastLine__c>
    */
    public void execute(Database.BatchableContext bc, List<gii__DemandForecastLine__c> scope){
        system.debug('scope is'+scope);
        system.debug('scope is'+scope.size());
        //declaring variables
        Map<String, gii__DemandOrder__c> mapFCDetailDO = new Map<String, gii__DemandOrder__c>(); //key = id of demand forecast line
        List<gii__DemandOrder__c> lstDOsToUpsert = new List<gii__DemandOrder__c>();
        Set<id> prevDFLids = new Set<id>();
        Map<String,gii__DemandForecastLine__c> mapPrevKeys = new Map<String,gii__DemandForecastLine__c>();
        for(gii__DemandForecastLine__c dfl : scope){
            prevDFLids.add(dfl.Id);
            if(dfl.giic_ParentDemandForecastLine__c != null){
                prevDFLids.add(dfl.giic_ParentDemandForecastLine__c);
                mapPrevKeys.put(dfl.giic_ParentDemandForecastLine__c,dfl);
            }
        }
        system.debug('prevDFLids --->' +prevDFLids);
        system.debug('mapPrevKeys --->' +mapPrevKeys);
        
        try{
            for(gii__DemandOrder__c doRec :[select Name, gii__ProductInventory__c, gii__Product__c, gii__UnitPrice__c, 
                gii__Warehouse__c, gii__Type__c, gii__DemandQuantity__c,giic_DemandOrderPriorQuantity__c, gii__DemandForecast__c,
                gii__DemandForecastLine__c, gii__DemandForecastLine__r.giic_DemandPlanPriorQuantity__c,
                gii__Revenue__c,giic_Cogs__c,gii__Profit__c,gii__ForecastPriority__c,gii__PurposeOrder__c,gii__PurposeOrderPriority__c,
                gii__DemandForecastLine__r.gii__Date__c, gii__DemandForecastLine__r.gii__DemandForecast__c,gii__DemandForecastLine__r.giic_PrevDFLKey__c,
                gii__DemandForecastLine__r.giic_ParentDemandForecastLine__c
                from gii__DemandOrder__c 
                where (gii__DemandForecastLine__c in: prevDFLids)
                and gii__Type__c=:giic_Constants.FORECAST and gii__DemandForecastLine__c != null])
                {
                    mapFCDetailDO.put(doRec.gii__DemandForecastLine__c, doRec);
                }
                system.debug('mapFCDetailDO ==='+mapFCDetailDO);
                system.debug('mapFCDetailDO ==='+mapFCDetailDO.size());
            //creating and updating demand orders
            for(gii__DemandForecastLine__c fcd: scope)
            {
                system.debug('fcd --' +fcd.id);
                if(mapFCDetailDO.containsKey(fcd.id)){
                    //updating demand order for demand plan
                    system.debug('inside if');
                    gii__DemandOrder__c doRec = mapFCDetailDO.get(fcd.id);
                    doRec.gii__RequiredDate__c = fcd.gii__Date__c;
                    Decimal newQty = fcd.giic_DemandPlanCurrentQuantity__c;
                    Decimal newQty1 = fcd.gii__CurrentQuantity__c;
                    if(doRec.gii__DemandQuantity__c != newQty && isSparePart == false){
                        doRec.gii__DemandQuantity__c = newQTY;  
                        doRec.gii__Revenue__c = newQty * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0);
                        doRec.giic_Cogs__c = newQty * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0);
                        doRec.gii__Profit__c = (newQty * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0)) - (newQty * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0));
                        doRec.giic_DemandOrderPriorQuantity__c = fcd.giic_DemandPlanPriorQuantity__c != null ? fcd.giic_DemandPlanPriorQuantity__c : 0;
                    }
                    //updating demand order for spare parts
                    if(doRec.gii__DemandQuantity__c != newQty1 && isSparePart){
                        doRec.gii__DemandQuantity__c = newQty1;  
                        doRec.gii__Revenue__c = newQty1 * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0);
                        doRec.giic_Cogs__c = newQty1 * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0);
                        doRec.gii__Profit__c = (newQty1 * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0)) - (newQty1 * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0));
                    }
                    doRec.gii__ForecastPriority__c = (fcd.gii__DemandForecast__r.gii__ForecastPriority__c != doRec.gii__ForecastPriority__c) ? fcd.gii__DemandForecast__r.gii__ForecastPriority__c : doRec.gii__ForecastPriority__c;
                    doRec.gii__PurposeOrder__c = (fcd.gii__DemandForecast__r.gii__PurposeOrder__c != doRec.gii__PurposeOrder__c) ? fcd.gii__DemandForecast__r.gii__PurposeOrder__c : doRec.gii__PurposeOrder__c;
                    doRec.gii__PurposeOrderPriority__c = (fcd.gii__DemandForecast__r.gii__PurposeOrderPriority__c != doRec.gii__PurposeOrderPriority__c) ? fcd.gii__DemandForecast__r.gii__PurposeOrderPriority__c : doRec.gii__PurposeOrderPriority__c;
                    
                    lstDOsToUpsert.add(doRec);
                }else if(mapPrevKeys.containsKey(fcd.giic_ParentDemandForecastLine__c)){
                    system.debug('inside else if');
                    gii__DemandOrder__c doRec = mapFCDetailDO.get(fcd.giic_ParentDemandForecastLine__c);
                    system.debug('doRec ---'+doRec);
                    doRec.giic_DemandOrderPriorQuantity__c = doRec.gii__DemandQuantity__c;
                    doRec.gii__DemandForecastLine__c = fcd.id;
                    doRec.gii__DemandForecast__c = fcd.gii__DemandForecast__c;
                    doRec.gii__DemandForecastCycle__c = fcd.gii__DemandForecast__r.gii__DemandForecastCycle__c;
                    doRec.gii__RequiredDate__c = fcd.gii__Date__c;
                    Decimal newQty = fcd.giic_DemandPlanCurrentQuantity__c;
                    Decimal newQty1 = fcd.gii__CurrentQuantity__c;
                    if(doRec.gii__DemandQuantity__c != newQty && isSparePart == false){
                        system.debug('inside if of do');
                        doRec.gii__DemandQuantity__c = newQTY;  
                        doRec.gii__Revenue__c = newQty * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0);
                        doRec.giic_Cogs__c = newQty * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0);
                        doRec.gii__Profit__c = (newQty * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0)) - (newQty * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0));
                        //doRec.giic_DemandOrderPriorQuantity__c = fcd.giic_DemandPlanPriorQuantity__c != null ? fcd.giic_DemandPlanPriorQuantity__c : 0;
                    }
                    //updating demand order for spare parts
                    if(doRec.gii__DemandQuantity__c != newQty1 && isSparePart){
                        system.debug('inside if of do spare');
                        doRec.gii__DemandQuantity__c = newQty1;  
                        doRec.gii__Revenue__c = newQty1 * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0);
                        doRec.giic_Cogs__c = newQty1 * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0);
                        doRec.gii__Profit__c = (newQty1 * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0)) - (newQty1 * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0));
                    }
                    doRec.gii__ForecastPriority__c = (fcd.gii__DemandForecast__r.gii__ForecastPriority__c != doRec.gii__ForecastPriority__c) ? fcd.gii__DemandForecast__r.gii__ForecastPriority__c : doRec.gii__ForecastPriority__c;
                    doRec.gii__PurposeOrder__c = (fcd.gii__DemandForecast__r.gii__PurposeOrder__c != doRec.gii__PurposeOrder__c) ? fcd.gii__DemandForecast__r.gii__PurposeOrder__c : doRec.gii__PurposeOrder__c;
                    doRec.gii__PurposeOrderPriority__c = (fcd.gii__DemandForecast__r.gii__PurposeOrderPriority__c != doRec.gii__PurposeOrderPriority__c) ? fcd.gii__DemandForecast__r.gii__PurposeOrderPriority__c : doRec.gii__PurposeOrderPriority__c;
                    
                    lstDOsToUpsert.add(doRec);
                }
                else{
                    system.debug('inside else');
                    //creating new demand order for spare parts
                    if(isSparePart){
                        gii__DemandOrder__c doObj = new gii__DemandOrder__c(
                            gii__DemandQuantity__c = fcd.gii__CurrentQuantity__c,
                            gii__Revenue__c = (fcd.gii__CurrentQuantity__c!=null?fcd.gii__CurrentQuantity__c:0) * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0),
                            giic_Cogs__c = (fcd.gii__CurrentQuantity__c!=null?fcd.gii__CurrentQuantity__c:0) * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0),
                            gii__Profit__c = ((fcd.gii__CurrentQuantity__c != null ? fcd.gii__CurrentQuantity__c : 0) * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c != null ? fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c : 0)) - ((fcd.gii__CurrentQuantity__c != null ? fcd.gii__CurrentQuantity__c : 0) * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c != null ? fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c : 0)),
                            gii__ProductInventory__c =fcd.gii__DemandForecast__r.gii__ProductInventory__c,
                            gii__RequiredDate__c = fcd.gii__Date__c,
                            gii__DemandForecastLine__c = fcd.Id,
                            gii__DemandForecast__c = fcd.gii__DemandForecast__c,
                            gii__DemandForecastCycle__c = fcd.gii__DemandForecast__r.gii__DemandForecastCycle__c,
                            gii__Type__c = giic_Constants.FORECAST,
                            gii__Account__c = fcd.gii__DemandForecast__r.giic_Account__c != null ? fcd.gii__DemandForecast__r.giic_Account__c : null,
                            gii__ForecastPriority__c = fcd.gii__DemandForecast__r.gii__ForecastPriority__c != null ? fcd.gii__DemandForecast__r.gii__ForecastPriority__c : 0,  
                            gii__PurposeOrder__c = fcd.gii__DemandForecast__r.gii__PurposeOrder__c != null ? fcd.gii__DemandForecast__r.gii__PurposeOrder__c : '',
                            gii__PurposeOrderPriority__c = fcd.gii__DemandForecast__r.gii__PurposeOrderPriority__c!=null ? fcd.gii__DemandForecast__r.gii__PurposeOrderPriority__c : 0,
                            giic_Region__c = fcd.gii__DemandForecast__r.giic_Region__c
                        );
                        lstDOsToUpsert.add(doObj);
                    }else{
                        //creating demand orders for demand plan
                        gii__DemandOrder__c doObj = new gii__DemandOrder__c(
                            gii__DemandQuantity__c = fcd.giic_DemandPlanCurrentQuantity__c,
                            gii__Revenue__c = (fcd.giic_DemandPlanCurrentQuantity__c!=null?fcd.giic_DemandPlanCurrentQuantity__c:0) * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c:0),
                            giic_Cogs__c = (fcd.giic_DemandPlanCurrentQuantity__c!=null?fcd.giic_DemandPlanCurrentQuantity__c:0) * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c!=null?fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c:0),
                            gii__Profit__c = ((fcd.giic_DemandPlanCurrentQuantity__c != null ? fcd.giic_DemandPlanCurrentQuantity__c : 0) * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c != null ? fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__MSRP__c : 0)) - ((fcd.giic_DemandPlanCurrentQuantity__c != null ? fcd.giic_DemandPlanCurrentQuantity__c : 0) * (fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c != null ? fcd.gii__DemandForecast__r.gii__ProductReference__r.gii__COGS__c : 0)),
                            giic_DemandOrderPriorQuantity__c = fcd.giic_DemandPlanPriorQuantity__c,
                            gii__ProductInventory__c =fcd.gii__DemandForecast__r.gii__ProductInventory__c,
                            gii__RequiredDate__c = fcd.gii__Date__c,
                            gii__DemandForecastLine__c = fcd.Id,
                            gii__DemandForecast__c = fcd.gii__DemandForecast__c,
                            gii__DemandForecastCycle__c = fcd.gii__DemandForecast__r.gii__DemandForecastCycle__c,
                            gii__Type__c = giic_Constants.FORECAST,
                            gii__Account__c = fcd.gii__DemandForecast__r.giic_Account__c != null ? fcd.gii__DemandForecast__r.giic_Account__c : null,
                            gii__ForecastPriority__c = fcd.gii__DemandForecast__r.gii__ForecastPriority__c != null ? fcd.gii__DemandForecast__r.gii__ForecastPriority__c : 0,  
                            gii__PurposeOrder__c = fcd.gii__DemandForecast__r.gii__PurposeOrder__c != null ? fcd.gii__DemandForecast__r.gii__PurposeOrder__c : '',
                            gii__PurposeOrderPriority__c = fcd.gii__DemandForecast__r.gii__PurposeOrderPriority__c!=null ? fcd.gii__DemandForecast__r.gii__PurposeOrderPriority__c : 0,
                            giic_Region__c = fcd.gii__DemandForecast__r.giic_Region__c
                        );
                        lstDOsToUpsert.add(doObj);
                    }
                }
            }
            if(lstDOsToUpsert!=null && lstDOsToUpsert.size()>0){
                upsert lstDOsToUpsert;
                count++;
            }
        }catch(Exception e){
            List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
             giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'CreateDOBatch',dfcRecId,true);
            insert errorLogs;
            system.debug('Unable to create/update the demand order'+e.getLineNumber());
        } 
    }

    /* Method name : finish
    * Description : finish method will update the demand forecast setup record
    * Return Type : void
    * Parameter : Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){ 
        List<gii__DemandForecastSetup__c> updateDFSList= new List<gii__DemandForecastSetup__c>();
        if(String.isNotBlank(region)){
            updateDFSList = [select id,giic_BatchStatus__c from gii__DemandForecastSetup__c where giic_DemandForecastCycle__c=:dfcRecId and giic_RelatedTo__c=:planName and giic_Region__c =:region limit 1];
        }else{
            updateDFSList = [select id,giic_BatchStatus__c from gii__DemandForecastSetup__c where giic_DemandForecastCycle__c=:dfcRecId and giic_RelatedTo__c=:planName];
        }
        //gii__DemandForecastSetup__c updateDFS=new gii__DemandForecastSetup__c();
        //updating DFS batch status field
        if(!updateDFSList.isEmpty()){
            for(gii__DemandForecastSetup__c dfs : updateDFSList){
                //if(count>0 ){
                    dfs.giic_BatchStatus__c=giic_Constants.COMPLETED;
                //}else{
                  //  dfs.giic_BatchStatus__c='';
                //}
            }
        }
        try{
            if(!updateDFSList.isEmpty()){
                update updateDFSList;
            }
        }catch(Exception e){
             List<gii__ErrorLog__c> errorLogs=new List<gii__ErrorLog__c>();
            giic_CommonUtility.collectErrorLog(errorLogs,e.getMessage(),'giic_CreateDOBatch',dfcRecId,true);
            insert errorLogs;
            system.debug('Unable to update the demand forecast setup record'+e);
        }
    } 
}