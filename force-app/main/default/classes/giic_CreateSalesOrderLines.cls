/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class giic_CreateSalesOrderLines {
    @AuraEnabled(cacheable=true)
    public static  List<SalesOrderLineWrapper> searchAddProduct(String searchString,string qty, string searchbyName)
    {
        system.debug('List of Products searchKeyField'+searchString + qty + searchbyName);
       

        
        //Map<String,Object> mapresult = new Map<String,Object>();
        List<SalesOrderLineWrapper> lstPRD = new List<SalesOrderLineWrapper>();
        List<gii__Product2Add__c> prodextList = new  List<gii__Product2Add__c>();
        if(searchString !='' && searchString !=null){
            system.debug('searchKeyField'+ searchString);
            prodextList = [Select Id, Name,gii__ProductCode__c,gii__MaterialCost__c,gii__Description__c from gii__Product2Add__c Where gii__ProductCode__c =: searchString];
        }
        else if(searchbyName !='' && searchbyName !=null){
            system.debug('searchKeyField'+ searchbyName);
            prodextList = [Select Id, Name,gii__ProductCode__c,gii__MaterialCost__c,gii__Description__c from gii__Product2Add__c Where Name =: searchbyName];
        }
       
        
        system.debug('List of Products search'+prodextList);
        if(prodextList.size()>0)
        {  
            for(gii__Product2Add__c obj : prodextList)
            {
                SalesOrderLineWrapper objPLW = new SalesOrderLineWrapper();
                objPLW.objProdRef = obj;               
                objPLW.prodQty = qty;
                objPLW.prodCost = String.valueof(obj.gii__MaterialCost__c);
                lstPRD.add(objPLW);
           
            }
            
        }
        system.debug('ReturnList' + lstPRD);
        return lstPRD;


    }

@AuraEnabled
public static string createSalesOrLines(List<SalesOrderLineWrapper> finalList, string salsOrdId,string updQntVal){
    system.debug('finallist::::'+finalList);
    system.debug('Record ID::::'+salsOrdId + updQntVal);
    Map<Id,gii__SalesOrderLine__c> prodRefIds = new Map<Id,gii__SalesOrderLine__c>();
    Boolean dupliProdinLine = False;
    Decimal updateQtyValue  = 0;
    /*Included below null check to fix defect - Gopi*/
    if(updQntVal!=Null && updQntVal != '')
    {
        updateQtyValue = Decimal.valueOf(updQntVal);
    }
    system.debug('Update Qty::'+ updateQtyValue);
    List<gii__SalesOrderLine__c> exisSoLine = [SELECT Id,gii__Product__c,gii__OrderQuantity__c FROM gii__SalesOrderLine__c WHERE gii__SalesOrder__c = : salsOrdId];
    for(gii__SalesOrderLine__c sol : exisSoLine){
        prodRefIds.put(sol.gii__Product__c,sol);
    }
    
    List<gii__SalesOrderLine__c> salsOrdList = new  List<gii__SalesOrderLine__c>();//Added by Bhuvana
    List<gii__SalesOrderLine__c> salsOrdUpdList = new  List<gii__SalesOrderLine__c>();
    for(SalesOrderLineWrapper salsOrdLineWrap : finalList)
    {
      
        gii__SalesOrderLine__c objSOLine = new gii__SalesOrderLine__c();
        //Changed by Bhuvana
        //
        System.debug('New PRD from List '+ salsOrdLineWrap.objProdRef.id);
        System.debug('prodRefIds' + prodRefIds);
        
        if(prodRefIds.keyset().contains(salsOrdLineWrap.objProdRef.id)){
            dupliProdinLine = true;
             system.debug('Duplicate Product' + dupliProdinLine);
            objSOLine.gii__OrderQuantity__c = prodRefIds.get(salsOrdLineWrap.objProdRef.id).gii__OrderQuantity__c+updateQtyValue;
            objSOLine.Id = prodRefIds.get(salsOrdLineWrap.objProdRef.id).Id;
            objSOLine.gii__UnitPrice__c	 = salsOrdLineWrap.objProdRef.gii__MaterialCost__c;
            salsOrdUpdList.add(objSOLine);           
        }else{    
             system.debug('Not Duplicate Product');
            objSOLine.gii__Product__c = salsOrdLineWrap.objProdRef.id;
            objSOLine.gii__OrderQuantity__c = updateQtyValue;
            objSOLine.gii__SalesOrder__c = salsOrdId; 
            objSOLine.gii__NoChargeReason__c = '';
            objSOLine.gii__UnitPrice__c	 = salsOrdLineWrap.objProdRef.gii__MaterialCost__c;
            salsOrdList.add(objSOLine);      
        }
        
    }

    system.debug('Duplicate Product' + dupliProdinLine);
    if(!dupliProdinLine ){
         system.debug('Duplicate Product' + salsOrdList);
        Database.insert(salsOrdList);       
    }else{//Added by Bhuvana
      
        Database.update(salsOrdUpdList);
        salsOrdId = 'Duplicate';
    }
return salsOrdId;
}


public class SalesOrderLineWrapper
    { 
        @AuraEnabled
        public gii__Product2Add__c objProdRef{get;set;}

        @AuraEnabled public string prodQty{get;set;}

        @AuraEnabled public string prodCost{get;set;}
    

    }
}