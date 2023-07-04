/*----------------------------------------------------------------------------
Version : 1.0
Created Date : 13 Dec 2021
Function : this class will be used to store the Constant values
*************************************************************************************/
Public with sharing class giic_Constants
{   
    public static String OrgHierarchyTbl = 'gii__WorkOrderAssemblyScrapStaging__c';
    FINAL static public string STYLEFILTER = 'gii__ProductStyle__r.name';
    FINAL static public string SIZEFILTER = 'gii__Size__c';
    FINAL static public string COLORFILTER = 'gii__Color__r.name';
    FINAL static public string FAMILYFILTER = 'gii__Family__c';
    FINAL static public string SUPPLYPLANCYCLE = 'gii__SupplyPlanCycle__c';
    FINAL static public string DEMANDPLANCYCLE = 'gii__DemandForecastCycle__c';    
    FINAL static public string FORECASTPLAN = 'Forecast Plan';
    public static string SOSTATUSCANCELLED = 'Cancelled';
    FINAL static public string INPROGRESS = 'In Progress';
    FINAL static public string DEMANDPLAN = 'Demand Plan';
    FINAL static public string SUPPLYPLAN = 'Supply Plan';
    FINAL static public string SPAREPLAN = 'Spareparts Forecast Plan';
    FINAL static public string PRODUCTIONPLAN = 'Production Plan';
    FINAL static public string DELIVERYPLAN = 'Delivery Plan';
    FINAL static public string PENDINGFORAPPROVAL = 'Pending for Approval';
    FINAL static public string APPROVED = 'Approved';
    FINAL static public string MONTHLTY = 'Monthly';
    FINAL static public string WEEKLY = 'Weekly';
    FINAL static public string PENDING = 'Pending';
    FINAL static public String REQUPDATEPLAN = 'Request for update plan';
    FINAL static public String APPUPDATEPLAN = 'Approved for update plan';
    FINAL static public String REJUPDATEPLAN = 'Reject for update plan';
    FINAL static public String APPROVERQUEUENAME = 'giic_Forecast_Plan_Approver_Level1';
    FINAL static public String LASTAPPROVERQUEUENAME = 'giic_GloviaForecastPlanApprover_Level_2';
    FINAL static public String APPROVERQUEUENAME_DEMANDPLAN = 'giic_Glovia_Demand_Plan_Approver_Level_1';
    FINAL static public String LASTAPPROVERQUEUENAME_DEMANDPLAN ='giic_Glovia_Demand_Plan_Approver_Level_2';
    FINAL static public String APPROVERQUEUENAME_PRODUCTIONPLAN = 'giic_GloviaProductionPlanApproverLevel1';
    FINAL static public String LASTAPPROVERQUEUENAME_PRODUCTIONPLAN = 'giic_GloviaProductionPlanApproverLevel2';
    FINAL static public String PRODUCTIONPLANREQUESTFOREDIT_APPROVALPROCESSNAME='Production Plan Update Approval Process';
    FINAL static public String QUEUE = 'Queue';
    FINAL static public String CPO = 'CPO';
    FINAL static public String CENTRAL = 'Central';
    FINAL static public String COMPLETED = 'Completed';
    FINAL static public String FAILED = 'Failed';
    FINAL static public String FORECAST = 'Forecast';
    Final Static public String HEADER_DATEFORMAT = 'yy';
    //Rajnish Added
    FINAL static public String REJECTEDPLAN = 'Rejected';
    FINAL static public String FORECASTPLANBATCHSTATUS = 'forecastPlan'; 
    FINAL static public String DEMANDPLANBATCHSTATUS = 'demandPlan';
    FINAL static public String SPAREPLANBATCHSTATUS = 'sparePlan';
    FINAL static public String PRODUCTIONPLANBATCHSTATUS = 'prodPlan';
    FINAL static public String DELIVERYPLANBATCHSTATUS = 'deliveryPlan';
    FINAL static public String RESETWEEKBATCHSTATUS = 'resetWeekBatch';
    FINAL static public String COMMUNITYNAME = 'Enel_x_Partner_Community1';
    FINAL static public String EXPORTPP = 'giic_Export_Production_Plan_Dcd';
    FINAL static public String EXPORTDP = 'giic_Export_Delivery_Plan_jo6';
    FINAL static public String EXPORTFP = 'giic_Export_Forecast_Plan1';
    FINAL static public String EXPORTSP = 'giic_Export_SparePart_Plan1';
    FINAL static public String EXPORTSKUREPORT = 'giic_Forecast_SKU_Report';
    FINAL static public String EXPORTSC1 = 'giic_Req9ForecastSubcategory1';
    FINAL static public String EXPORTSC2 = 'giic_Req9ForecastSubcategory2';
    FINAL static public String COMMUNITYNAMEBG = 'Enel_X_Partner_Community_B2B_G1';
    FINAL static public String EXPORTSPC = 'giic_Export_Supply_Plan_d0Q';
    FINAL static public String REQFORZENUPDATEPLAN = 'Pending For Frozen Approval';
    FINAL static public String APPFORZENUPDATEPLAN = 'Approved For Frozen';
    FINAL static public String REJFORZENUPDATEPLAN = 'Rejected For Frozen';
    /********PROMOTION***********/
     FINAL static public String PROMOCODE = '*****';
    FINAL static public String SOIDS = '****';
    FINAL static public String PROMOFREQTYPE_MONTHLY = '******';
    FINAL static public String PROMOFREQTYPE_QUARTERLY = '******';
    FINAL static public String PROMOFREQTYPE_YEARLY = '******';
    FINAL static public String DROPSHIPADDIONTALCHARGE = '******';
    FINAL static public String USERROLECSR = '******';
    FINAL static public String USERROLESALESREP = '******';
    FINAL static public String USERROLESEDI = '******';
    FINAL static public String USERROLEALL = '******';
    FINAL static public String DROPSHIPPROMO = '******';
    FINAL static public String SHIPPINGPROMO = '******';
    FINAL static public String PROMOTION = '******';
    FINAL static public String ACHPROMOTYPE = '******';
    public static final String DROP_AUTHORIZATION = 'Drop Authorization';
    public static final String ACCEPTED = 'Accepted';
    public static final String REJECTED = 'Rejected';
    FINAL static public string SOLI_CANCEL = 'Cancelled';
    FINAL static public string SOSTATUSOPEN ='Open';
    public static final String CALCULATE_TAX = 'Calculate Tax';
    FINAL static public string SOSTATUSINPROGRESS ='In Progress';
    FINAL static public string SALESORDER = 'SalesOrder';
    
    public static Boolean firstRunForWOIS = true;
    public static Boolean firstRunForPP = true;
    
    

}