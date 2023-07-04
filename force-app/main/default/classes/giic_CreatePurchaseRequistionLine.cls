/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class giic_CreatePurchaseRequistionLine {

    @AuraEnabled(cacheable=true)
    public static  List<PurchaseReqLineWrapper> searchAddProduct(String searchString,string qty, string searchbyName)
    {
        system.debug('List of Products searchKeyField'+searchString + qty + searchbyName);
       

        
        //Map<String,Object> mapresult = new Map<String,Object>();
        List<PurchaseReqLineWrapper> lstPRD = new List<PurchaseReqLineWrapper>();
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
                PurchaseReqLineWrapper objPLW = new PurchaseReqLineWrapper();
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
public static string createPurchaseReqLines(List<PurchaseReqLineWrapper> finalList, string purReqId,string updQntVal){
    system.debug('finallist::::'+finalList);
    system.debug('Record ID::::'+purReqId);
    List<gii__PurchaseRequisitionLine__c> prReqLineList = new  List<gii__PurchaseRequisitionLine__c>();
    Decimal updateQtyValue  = 0;
    /*Bhuv*/
    if(updQntVal!=Null && updQntVal != '')
    {
        updateQtyValue = Decimal.valueOf(updQntVal);
    }

/*
    Map<String,Object> allinputParam = new Map<String,Object>();
    allinputParam = (Map<String, Object>)JSON.deserializeUntyped(finalList);

    List<PurchaseReqLineWrapper> lstProd =   new List<PurchaseReqLineWrapper>();

    if(allinputParam.containsKey('prodList')){         
        lstPROD = (list<PurchaseReqLineWrapper>)System.JSON.deserialize((String) (Object) allinputParam.get('prodList'), list<PurchaseReqLineWrapper>.class);                       
    }

    system.debug('prReqLineList'+ lstPROD);*/
    Map<Id,gii__PurchaseRequisitionLine__c> purchReqLineIds = new Map<Id,gii__PurchaseRequisitionLine__c>();
    Boolean duplicatePurchReq = False;
    List<gii__PurchaseRequisitionLine__c> purchLineUpd = new List<gii__PurchaseRequisitionLine__c>();//Buv
    List<gii__PurchaseRequisitionLine__c> exisPurchReqLine = [SELECT Id,gii__Product__c,gii__OrderQuantity__c FROM gii__PurchaseRequisitionLine__c WHERE gii__PurchaseRequisition__c =: purReqId];
    for(gii__PurchaseRequisitionLine__c purReq : exisPurchReqLine){
        purchReqLineIds.put(purReq.gii__Product__c,purReq);
    }
    for(PurchaseReqLineWrapper prReqLineWrap : finalList)
    {
        gii__PurchaseRequisitionLine__c objPRLine = new gii__PurchaseRequisitionLine__c();
        if(purchReqLineIds.keyset().Contains(prReqLineWrap.objProdRef.id)){//Bhuv start for existing updating the quantity
            duplicatePurchReq = True;
            objPRLine.id = purchReqLineIds.get(prReqLineWrap.objProdRef.id).Id;
            objPRLine.gii__OrderQuantity__c = purchReqLineIds.get(prReqLineWrap.objProdRef.id).gii__OrderQuantity__c+updateQtyValue;
            purchLineUpd.add(objPRLine);
           // break;
        }else{//Bhuv end
       
        objPRLine.gii__Product__c = prReqLineWrap.objProdRef.id;
        objPRLine.gii__OrderQuantity__c = updateQtyValue;//Bhuv
        objPRLine.gii__PurchaseRequisition__c = purReqId;
        objPRLine.gii__UnitPrice__c	 =  prReqLineWrap.objProdRef.gii__MaterialCost__c;//Bub
        prReqLineList.add(objPRLine);
        }
    }

    system.debug('prReqLineList'+ prReqLineList);
    if(!duplicatePurchReq){
        Database.insert(prReqLineList);
    }else{
        Database.update(purchLineUpd);//Bhuv
        purReqId = 'Duplicate';
    }
return purReqId;
}


public class PurchaseReqLineWrapper
    { 
        @AuraEnabled
        public gii__Product2Add__c objProdRef{get;set;}

        @AuraEnabled public string prodQty{get;set;}

        @AuraEnabled public string prodCost{get;set;}
    

    }
}