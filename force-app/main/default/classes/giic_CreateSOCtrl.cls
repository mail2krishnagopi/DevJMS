/*****************************************************************************************************************
* Purpose    : The purpose of this class to handle New Sales Order Creation from Sales Quote.  
*              
* *******************************************************/
public class giic_CreateSOCtrl {
    
    
    @AuraEnabled
    public static List<gii__Product2Add__c> fetchProduct(String searchKeyWord)
    {
        String searchKey = searchKeyWord + '%';
        List<gii__Product2Add__c> returnList = new List<gii__Product2Add__c>();
        List<gii__Product2Add__c> prodList = [Select Id, Name from gii__Product2Add__c Where Name Like  : searchKey];
        for (gii__Product2Add__c prod: prodList) {
            returnList.add(prod);
        }
        return returnList;
    }
    @AuraEnabled
    public static List<gii__Product2Add__c> getProduct(String searchKeyWord)
    {
        List<gii__Product2Add__c> returnList = new List<gii__Product2Add__c>();
        List<gii__Product2Add__c> prodList = [Select Id, Name from gii__Product2Add__c Where LastModifiedDate != NULL ORDER BY LastModifiedDate DESC LIMIT 5];
        system.debug('List of Products'+prodList);
        return prodList;
    }
    @AuraEnabled
    public static  Map<String,Object> searchProduct(String searchString)
    {
        
        system.debug('List of Products searchKeyField'+searchString);
        Map<String,Object> mapresult = new Map<String,Object>();
        list<ProductLineWrapper> lstPRD = new list<ProductLineWrapper>();
        List<gii__Product2Add__c> prodextList = new  List<gii__Product2Add__c>();
        if(searchString !='' && searchString !=null && searchString.trim() != ''){
            system.debug('searchKeyField'+searchString);
            prodextList = [Select Id, Name,gii__ProductCode__c,gii__MaterialCost__c,gii__Description__c from gii__Product2Add__c Where gii__ProductCode__c =: searchString];
        }
        system.debug('List of Products search'+prodextList);
        if(prodextList.size()>0)
        {  
            for(gii__Product2Add__c obj : prodextList)
            {
                ProductLineWrapper objPLW = new ProductLineWrapper();
                objPLW.prodCode = obj.gii__ProductCode__c;
                objPLW.prodDesc = obj.gii__Description__c;
                objPLW.unitPrice = obj.gii__MaterialCost__c;
                lstPRD.add(objPLW);
                mapresult.put('lstPRD',lstPRD);
            }
            
        }
        return mapresult;
    }
    @AuraEnabled
    public static Map<String,Object> saveSalesOrderLine(string data)
    {
        Map<String,Object> allinputParam = new Map<String,Object>();
        allinputParam = (Map<String, Object>)JSON.deserializeUntyped(data);
        Savepoint sp = Database.setSavepoint();
        Map<String,Object> mapresult = new Map<String,Object>();
        mapresult.put('IsSuccess',false);   
        String soId ;
        List<ProductLineWrapper> lstPROD = new List<ProductLineWrapper>();
        if(allinputParam.containsKey('prodList')){         
            lstPROD = (list<ProductLineWrapper>)System.JSON.deserialize((String) (Object) allinputParam.get('prodList'), list<ProductLineWrapper>.class);                       
        }
        if(allinputParam.containsKey('soId')){         
            soId = (String) allinputParam.get('soId');
        }
        set<Id> setProductRefIds=new set<Id>();
        for(ProductLineWrapper obj : lstPROD){
            setProductRefIds.add(obj.prodId);
        }
        
        map<Id,gii__Product2Add__c> mapProdRef =new map<Id,gii__Product2Add__c>([Select Id, Name, gii__ProductCode__c, 
                                                                                 gii__SellingUnitofMeasure__c, gii__SellingUnitofMeasure__r.Name , 
                                                                                 gii__StockingUnitofMeasure__c, gii__StockingUnitofMeasure__r.Name 
                                                                                 From gii__Product2Add__c where id in :setProductRefIds]);
        
        list<gii__SalesOrder__c> lstSalesOrder=[select id,gii__RequiredDate__c from gii__SalesOrder__c where id=:soId];
        map<Id,gii__SalesOrderLine__c> mapSalesOrderLines=new map<id,gii__SalesOrderLine__c>();
        boolean isUpdateFlag=false;
        
        if(!lstSalesOrder.isEmpty()){
            mapSalesOrderLines=new map<id,gii__SalesOrderLine__c>(lstSalesOrder[0].gii__SalesOrder__r);
        }
        
        if(lstPROD.size()>0)
        {
            List<gii__SalesOrderLine__c> lstSOL = new List<gii__SalesOrderLine__c>();
            for(ProductLineWrapper obj : lstPROD)
            { 
                gii__SalesOrderLine__c objSOL = new gii__SalesOrderLine__c();
                objSOL.gii__Product__c = obj.prodId;
                objSOL.gii__OrderQuantity__c = obj.prodQty;
                lstSOL.add(objSOL);
            }
        }
        return mapresult; 
    }
    public Class ProductLineWrapper
    {  
        @auraEnabled  public String prodCode;
        @auraEnabled  public String prodId;
        @auraEnabled  public String prodDesc;
        @auraEnabled  public Decimal prodQty;
        @auraEnabled  public Decimal unitPrice;
        public ProductLineWrapper()
        {
            prodCode ='';
            prodDesc ='';
            unitPrice = 0.00;
        }
    }
    
}