public with sharing class giic_ProductInventoryTrgHandler {
    
    
    public  void createDemandOrder(List<gii__ProductInventory__c> allListProdInv){
        
        try{
           system.debug('allListProdInv>> '+ allListProdInv);
           system.debug('allListProdInv.size()>> '+ allListProdInv.size());
            set<id> setProdInvIdForQuery = new Set<id>();
            if(allListProdInv.size() > 0){
                for(gii__ProductInventory__c objInvnew : allListProdInv){ 
                    setProdInvIdForQuery.add(objInvnew.id);
                } 
            }
            //lstProdInv
            system.debug('setProdInvIdForQuery>> '+ setProdInvIdForQuery);
           system.debug('setProdInvIdForQuery.size()>> '+ setProdInvIdForQuery.size());
            list<gii__ProductInventory__c> lstProdInv= [SELECT id,ownerid,isdeleted,name,currencyisocode,createddate,createdbyid,lastmodifieddate,
                                                        lastmodifiedbyid,systemmodstamp,lastactivitydate,lastvieweddate,lastreferenceddate,
                                                        gii__binlocation__c,gii__consignmentreceiptquantity__c,gii__consumedquantity__c,
                                                        gii__intransitquantity__c,gii__lastcyclecountdate__c,gii__lastphysicalinventorydate__c,
                                                        gii__maximuminventoryquantity__c,gii__minimumorderquantity__c,
                                                        gii__nonstockpurchaseorderquantity__c,gii__nonstockworkorderquantity__c,
                                                        gii__orderpointquantity__c,gii__orderquantitymultiple__c,gii__primarylocationbin__c,
                                                        gii__primarylocation__c,gii__product__c,gii__purchaseorderquantity__c,
                                                        gii__purchasereceiptquantity__c,gii__rmadispositionquantity__c,
                                                        gii__rmaquantity__c,gii__returntosuppliershippedquantity__c,
                                                        gii__safetystockquantity__c,gii__salesorderquantity__c,
                                                        gii__serviceticketproductquantity__c,gii__shippedsummaryquantity__c,
                                                        gii__stockum__c,gii__supplyplanenabled__c,gii__transferinquantity__c,
                                                        gii__warehouse__c,gii__workordercompletedquantity__c,
                                                        gii__workorderissuedquantity__c,gii__workorderquantity__c,
                                                        gii__adjustmentquantity__c,gii__backorderquantity__c,gii__nonstockquantity__c,
                                                        gii__receiptsquantity__c,gii__reservequantity__c,gii__shippedquantity__c,
                                                        gii__transferoutquantity__c,gii__availablequantity__c,gii__fieldserviceengineername__c,
                                                        gii__onhandquantity__c,gii__orderpointtrigger__c,gii__productwarehouse__c,
                                                        gii__status__c,gii__totalonorder__c,gii__totalreceipt__c,gii__blockedquantity__c,
                                                        gii__onhandfromlocations__c,gii__onorderquantity__c,gii__restrictedquantity__c,
                                                        gii__supplyreserved__c,giic_oracleid__c,giic_productcode__c,giic_failurerate__c,
                                                        giic_leadtime__c,giic_shelftimeyear__c,giic_demandorderrecord__c,giic_12monthsdemand__c,
                                                        giic_safetydays__c,giic_dailyrunrate__c,giic_maxqtycalculated__c,giic_minqtycalculated__c,
                                                        giic_safetystockcalculated__c,giic_numberofmonth__c,giic_historicalso__c,giic_historicalto__c,
                                                        giic_historicalwo__c , gii__Product__r.gii__Service__c,
                                                        gii__Warehouse__r.name ,gii__Product__r.gii__Family__c FROM gii__ProductInventory__c 
                                                        where Id IN: setProdInvIdForQuery
                                                        AND gii__SupplyPlanEnabled__c =True
                                                        AND giic_MaxQtyCalculated__c  != Null
                                                        AND gii__Warehouse__r.name != Null
                                                        AND gii__Warehouse__c != Null
                                                        AND gii__Product__r.gii__Family__c != Null
                                                        AND gii__Product__c != Null ];
            
             system.debug('lstProdInv>> '+ lstProdInv);
           system.debug('lstProdInv.size()>> '+ lstProdInv.size());
            if(lstProdInv.size() > 0){
                Map<Id,sObject> mapSobj = new Map<Id,sObject>();
                Schema.SObjectType sObjectType;
                List<sObject> lstOrderToUpdate = new List<sObject>();
                //Adding code to execute this only for parts prod starts
                Set<Id> setProdRefId = new Set<Id>();
                Set<Id> setProdInvIds = new Set<Id>();
                Set<String> setMakeAndWarehouse = new Set<String>();
                Map<Id,Id> mapProdAndProdRefId = new Map<Id,Id>();
                Map<Id,Id> mapProdRefAndProdId = new Map<Id,Id>();
                set<Id> recidset = new set<Id>(); 
                Map<String,String> makeCodeWarehouseMap = new Map<String,String>();
                List<gii__ProductInventory__c> lstProdInvNew = new List<gii__ProductInventory__c>();
                List<gii__ProductInventory__c> lstProdInvNewrecs = new List<gii__ProductInventory__c>();
                List<gii__ProductInventory__c> listProdInvRecs = new List<gii__ProductInventory__c>();
                List<giic_DemandForcast__mdt> demandOrderLst = new List<giic_DemandForcast__mdt>();
                
                system.debug('lstProdInv>>>>>> '+lstProdInv);
                
                for(gii__ProductInventory__c objInv : lstProdInv){ 
                    setProdRefId.add(objInv.gii__Product__c);
                    setProdInvIds.add(objInv.id);
                }
             //   lstProdInvNewrecs = [select id,gii__Product__r.gii__ProductReference__r.Make__c,gii__Warehouse__r.name,gii__Product__r.gii__Family__c
             //                        ,gii__Product__c,gii__AvailableQuantity__c from gii__ProductInventory__c where id IN: setProdInvIds];
               lstProdInvNewrecs = [select id,gii__Warehouse__r.name,gii__Product__r.gii__Family__c
                                     ,gii__Product__c,gii__AvailableQuantity__c 
                                    from gii__ProductInventory__c where  id IN: setProdInvIds];
                system.debug('lstProdInvNewrecs>>>>>> '+lstProdInvNewrecs);
                //  system.debug('lstProdInvNewrecs>>>>>> '+lstProdInvNewrecs);
                for(gii__ProductInventory__c objInvRec :lstProdInvNewrecs){
                    //setMakeAndWarehouse.add(objInvRec.gii__Product__r.gii__ProductReference__r.Make__c +'_'+ objInvRec.gii__Warehouse__r.name);
                    setMakeAndWarehouse.add(objInvRec.gii__Product__r.gii__Family__c +'_'+ objInvRec.gii__Warehouse__r.name);
                }
                system.debug('setMakeAndWarehouse>>>>>> '+setMakeAndWarehouse);
                system.debug('lstProdInvNewrecs>>>>>> '+lstProdInvNewrecs);
                demandOrderLst = [select MasterLabel from giic_DemandForcast__mdt where MasterLabel IN: setMakeAndWarehouse];
                system.debug('demandOrderLst>>>>>> '+demandOrderLst);
                for(gii__ProductInventory__c objInvRec :lstProdInvNewrecs){
                    for(giic_DemandForcast__mdt demandOrderrec :demandOrderLst){
                        // if(demandOrderrec.MasterLabel == objInvRec.gii__Product__r.gii__ProductReference__r.Make__c +'_'+ objInvRec.gii__Warehouse__r.name){
                        if(demandOrderrec.MasterLabel == objInvRec.gii__Product__r.gii__Family__c +'_'+ objInvRec.gii__Warehouse__r.name){
                            recidset.add(objInvRec.id);
                        }
                    }
                }
                system.debug('recidset>>>>>> '+recidset);
                system.debug('setProdRefId>>>>>> '+ setProdRefId);
                list<gii__Product2Add__c>  listProdRef =[Select id,gii__ProductReference__c from gii__Product2Add__c where Id IN: setProdRefId];
                system.debug('listProdRef>>>>>> '+ listProdRef);
                for(gii__Product2Add__c objProdRef : [Select id,gii__ProductReference__c from gii__Product2Add__c where Id IN: setProdRefId]){
                    // commented by Himanshu  mapProdAndProdRefId.put(objProdRef.gii__ProductReference__c,objProdRef.id);
                    mapProdAndProdRefId.put(objProdRef.id,objProdRef.id); // added by Himanshu
                    //mapProdRefAndProdId.put(objProdRef.id,objProdRef.gii__ProductReference__c);
                }
                system.debug('mapProdAndProdRefId>>>>>> '+mapProdAndProdRefId);
                system.debug('mapProdAndProdRefId>>>>>>1 '+mapProdAndProdRefId.size());
                /*for(Product2 objProd : [Select id from Product2 where Id IN: mapProdAndProdRefId.keyset() AND  RecordType.Name = 'Product Support']){
mapProdRefAndProdId.put(mapProdAndProdRefId.get(objProd.id),objProd.id);
}
*/
                system.debug('mapProdAndProdRefId.keyset() '+mapProdAndProdRefId.keyset());
                system.debug('1223 '+[Select id from Product2 where Id IN: mapProdAndProdRefId.keyset()]);
                // commented by Jagadeesh 
                /*for(Product2 objProd : [Select id from Product2 where Id IN: mapProdAndProdRefId.keyset()]){
mapProdRefAndProdId.put(mapProdAndProdRefId.get(objProd.id),objProd.id);
}
*/
                system.debug('mapProdAndProdRefId>>>>>>2 '+mapProdRefAndProdId.size());
                system.debug('mapProdAndProdRefId>>>>>>3 '+mapProdRefAndProdId);
                for(gii__ProductInventory__c objInvNew : lstProdInv){
                    // if(mapProdRefAndProdId.containsKey(objInvNew.gii__Product__c)){
                    lstProdInvNew.add(objInvNew);
                    // }
                }
                
                system.debug('mapProdAndProdRefId>>>>>>4 '+lstProdInvNew);
                system.debug('mapProdAndProdRefId>>>>>>5 '+lstProdInvNew.size());
                //Adding code to execute this only for parts prod ends
                Map<id, gii__DemandOrder__c> mapProdInvAndDmdOrd = new Map<id, gii__DemandOrder__c>();
                List<gii__DemandOrder__c> demandOrderList = new List<gii__DemandOrder__c>();
                List<gii__DemandOrder__c> demandOrderListOne = new List<gii__DemandOrder__c>();
                system.debug('lstProdInvNew>>>>>>H '+lstProdInvNew);
                demandOrderList = [Select id, gii__ProductInventory__c,gii__DemandQuantity__c,gii__RequiredDate__c,gii__DemandForecastCycle__r.gii__AsofDate__c from gii__DemandOrder__c where gii__ProductInventory__c IN:lstProdInvNew ];
                system.debug('demandOrderList>>>>>>H '+demandOrderList);
                
                for(gii__DemandOrder__c objDemOrder : demandOrderList){
                    mapProdInvAndDmdOrd.put(objDemOrder.gii__ProductInventory__c,objDemOrder);
                }
                system.debug('mapProdInvAndDmdOrd>>>>>>H '+mapProdInvAndDmdOrd);
                // Map <String, Schema.SObjectField> tarInstance =  Schema.getGlobalDescribe().get('gii__DemandOrder__c').getDescribe().fields.getMap();
                List<giic_integrationWrapper> lstWrapper = giic_integrationWrapper.getWrapperList('gii__ProductInventory__c', 'gii__DemandOrder__c');
                Map<String,giic_integrationWrapper> mapIntWrapper = new Map<String,giic_integrationWrapper>();
                List<sObject> lstDemandOrder = new List<sObject>();
                List<gii__ProductInventory__c> lstProdInventory = new List<gii__ProductInventory__c>();
                for(gii__ProductInventory__c objProdInv : lstProdInvNew){
                    system.debug('Condition >>>>>1 '+objProdInv.id);
                    system.debug('Condition >>>>>2 '+objProdInv.gii__AvailableQuantity__c);
                    system.debug('Condition >>>>>3 '+objProdInv.giic_MinQtyCalculated__c);
                    if(recidset.contains(objProdInv.id)){
                        /* 
if((objProdInv.gii__AvailableQuantity__c + objProdInv.gii__InTransitQuantity__c + objProdInv.gii__PurchaseOrderQuantity__c) > objProdInv.giic_MinQtyCalculated__c){
//  objProdInv.gii__SupplyPlanEnabled__c = false;
objProdInv.gii__SafetyStockQuantity__c = objProdInv.giic_SafetyStockCalculated__c;
lstProdInventory.add(objProdInv);
} else if((objProdInv.gii__AvailableQuantity__c + objProdInv.gii__InTransitQuantity__c + objProdInv.gii__PurchaseOrderQuantity__c) < objProdInv.giic_MinQtyCalculated__c ){
//  objProdInv.gii__SupplyPlanEnabled__c = true;
objProdInv.gii__SafetyStockQuantity__c = objProdInv.giic_SafetyStockCalculated__c;
lstProdInventory.add(objProdInv);
} */  // Commented by Himahsu
                        objProdInv.gii__SafetyStockQuantity__c = objProdInv.giic_SafetyStockCalculated__c;
                        lstProdInventory.add(objProdInv);
                        //if(objProdInv.gii__AvailableQuantity__c > objProdInv.giic_MinQtyCalculated__c){
                        for(gii__DemandOrder__c objDemOrder : demandOrderList){
                            if(objDemOrder.gii__DemandForecastCycle__r.gii__AsofDate__c != null){
                                objDemOrder.gii__RequiredDate__c = objDemOrder.gii__DemandForecastCycle__r.gii__AsofDate__c.addDays(-2);
                                demandOrderListOne.add(objDemOrder);
                            }
                            // }// Commented by Himahsu
                            update demandOrderListOne;
                        }
                        system.debug('objProdInv>>>>>'+objProdInv.giic_MaxQtyCalculated__c);
                        sObject demandOrdInstanceToUpdate = Schema.getGlobalDescribe().get('gii__DemandOrder__c').newSObject();
                        sObject demandOrdInstance = Schema.getGlobalDescribe().get('gii__DemandOrder__c').newSObject();
                        //system.debug('tarInstance>>>>>> '+demandOrdInstance);
                        sObjectType = objProdInv.getSObjectType();
                        //system.debug('tarInstance>>>>>1 ' + sObjectType);
                        Map<String, Object> fieldsToValue = objProdInv.getPopulatedFieldsAsMap();
                        // system.debug('tarInstance>>>>>>>> 2'+fieldsToValue);
                        gii__DemandOrder__c objDemandOrder = new gii__DemandOrder__c();
                        system.debug('Condition >>>>>11 '+mapProdInvAndDmdOrd.containsKey(objProdInv.id));
                        //system.debug('Condition >>>>>11 '+mapProdInvAndDmdOrd.containsKey(objProdInv.id);
                        /*
if((!mapProdInvAndDmdOrd.containsKey(objProdInv.id) && 
(objProdInv.gii__AvailableQuantity__c < objProdInv.giic_MinQtyCalculated__c) )
|| (mapProdInvAndDmdOrd.containsKey(objProdInv.id) && 
mapProdInvAndDmdOrd.get(objProdInv.id).gii__RequiredDate__c.month() != Date.today().month() && 
(objProdInv.gii__AvailableQuantity__c < objProdInv.giic_MinQtyCalculated__c))){
*/// Commented by Himahsu
                        if((!mapProdInvAndDmdOrd.containsKey(objProdInv.id)  )
                           || (mapProdInvAndDmdOrd.containsKey(objProdInv.id) && 
                               mapProdInvAndDmdOrd.get(objProdInv.id).gii__RequiredDate__c.month() != Date.today().month()
                              )){
                                  for (giic_integrationWrapper wrapperInstance : lstWrapper) {
                                      if(fieldsToValue.containsKey(wrapperInstance.sourceField)){
                                          if(wrapperInstance.sourceField =='giic_MaxQtyCalculated__c' ){
                                              Decimal quantity = (Decimal)fieldsToValue.get('giic_MaxQtyCalculated__c');
                                              system.debug('objProdInv>>>>>2 '+quantity);
                                              demandOrdInstance.put('gii__DemandQuantity__c',(Integer)quantity.round());
                                          }else{
                                              demandOrdInstance.put(wrapperInstance.targetField, fieldsToValue.get(wrapperInstance.sourceField));
                                          }
                                      }
                                  }
                                  demandOrdInstance.put('gii__RequiredDate__c',system.today());
                                  demandOrdInstance.put('gii__ProductInventory__c',objProdInv.id);
                                 // demandOrdInstance.put('gii__Type__c','Forecast');
                                  demandOrdInstance.put('gii__UnitPrice__c',1);
                                  //demandOrdInstance.put('CurrencyIsoCode','USD');
                                  lstDemandOrder.add(demandOrdInstance);
                                  system.debug('tarInstance>>>>>>>>3 '+lstDemandOrder);
                              }else{
                                  for(giic_integrationWrapper wrapperInstance : lstWrapper) {
                                      if(mapProdInvAndDmdOrd.containsKey(objProdInv.id) && mapProdInvAndDmdOrd.get(objProdInv.id).gii__RequiredDate__c.month() == Date.today().month()){
                                          demandOrdInstanceToUpdate.put('id',mapProdInvAndDmdOrd.get(objProdInv.id).id);
                                          Decimal quantity = (Decimal)fieldsToValue.get('giic_MaxQtyCalculated__c');
                                          system.debug('objProdInv>>>>>2 '+quantity);
                                          demandOrdInstanceToUpdate.put('gii__DemandQuantity__c',(Integer)quantity.round());
                                          //mapProdInvAndDmdOrd.get(objProdInv.id).gii__DemandQuantity__c = Decimal.valueOf();
                                          // system.debug('tarInstance>>>>>>>>5 '+demandOrdInstanceToUpdate);
                                          // system.debug('tarInstance>>>>>>>>51 '+fieldsToValue.get('giic_MaxQtyCalculated__c'));
                                          demandOrdInstanceToUpdate.put('gii__RequiredDate__c',system.today());
                                          lstOrderToUpdate.add(demandOrdInstanceToUpdate);
                                      }
                                  }
                                  
                                  system.debug('tarInstance>>>>>>>>6'+lstOrderToUpdate);
                              }
                        
                        //gii__DemandOrder__c objDemandOrder = new gii__DemandOrder__c(gii__Product__c = objProdInv.gii__Product__c,
                        
                        if(lstOrderToUpdate.size() > 0 ){
                            for(sobject obj : lstOrderToUpdate){
                                mapSobj.put(obj.id,obj);
                            }
                        }                                                         //    gii__ProductInventory__c = objProdInv.id );
                    }
                } 
                
                //List<List<gii__DemandOrder__c>> lstDmdOrderLst = new List<List<gii__DemandOrder__c>>();
                // lstDmdOrderLst.add(lstDemandOrder);
                // lstDmdOrderLst.add(lstOrderToUpdate);
                system.debug('Condition >>>>>4 '+lstDemandOrder);
                system.debug('Condition >>>>>5 '+lstOrderToUpdate);
                system.debug('Condition >>>>>6 '+mapSobj);
                
            system.debug('lstDemandOrder>>In>>l.. '+ lstDemandOrder);
            system.debug('lstDemandOrder.size()>>l.. '+ lstDemandOrder.size());
            system.debug('lstOrderToUpdate>>Up>>l.. '+ lstOrderToUpdate);
            system.debug('lstOrderToUpdate.size()>>l.. '+ lstOrderToUpdate.size());
            system.debug('mapSobj>>up>l.. '+ mapSobj);
            system.debug('mapSobj.size()>>l.. '+ mapSobj.size());
             system.debug('lstProdInventory>>Up>>l.. '+ lstProdInventory);
            system.debug('lstProdInventory.size()>>l.. '+ lstProdInventory.size());
                
                if(lstDemandOrder.size() > 0){
                    insert lstDemandOrder;
                     system.debug('lstDemandOrder>>Insert Done>>l.. '+ lstDemandOrder);
                }
                /*
if(lstOrderToUpdate.size() > 0){
update lstOrderToUpdate;

}*/
                   // added by himanshu => below we are updating the  Demand Record
                if(mapSobj.size() > 0){
                    update mapSobj.values();
                    system.debug('mapSobj.values()>>Update Done>>l.. '+ mapSobj.values());
                }
                if(lstProdInventory.size() > 0){
                    update lstProdInventory;
                    system.debug('lstProdInventory>>Update Done>>l.. '+ lstProdInventory);
                }
                
                //.add(obj.id,obj);
                
                //return lstDmdOrderLst;
            } 
        }
        catch(exception e){
            system.debug('Demand Order creation failed due to '+e.getMessage());
            
        }
        //return null;
        
    }
}