public class giic_HistoricalDemandQntCalHandler {
    
    
    public  void getThequantityCount(List<gii__ProductInventory__c> lstProdInv){
        
        system.debug('lstProdInv>> '+ lstProdInv);
        try{
            
            if(lstProdInv.size() > 0){
                set<id> setProdInvIdForQuery = new Set<id>();
                for(gii__ProductInventory__c objInvnew : lstProdInv){ 
                    setProdInvIdForQuery.add(objInvnew.id);
                }
                
                Set<String> setWarehouseId = new Set<String>();
                Set<String> setProdId = new Set<String>();
                Set<String> setProdInvId = new Set<String>();
                Map<String,gii__ProductInventory__c> mapProdAndProdInv = new Map<String,gii__ProductInventory__c>();
                List<gii__ProductInventory__c> updateResult =new List<gii__ProductInventory__c>();
                
                //   Map<Id,List<gii__SalesOrderLine__c>> mapProdAndlistOfSOL = new Map<id,List<gii__SalesOrderLine__c>>();
                Map<Id,List<gii__TransferOrder__c >> mapProdAndlistOfTOL = new Map<Id,List<gii__TransferOrder__c >>();
                //   Map<Id,List<gii__WorkOrder__c>> mapProdAndlistOfWO = new Map<Id,List<gii__WorkOrder__c>>();
                
                
                Map<Id,Decimal> mapProdAndQntOfSOL = new Map<id,Decimal>();
                Map<Id,Decimal> mapProdAndQntOfTOL = new Map<Id,Decimal>();
                Map<Id,Decimal> mapProdAndQntOfWO = new Map<Id,Decimal>();                
                list<gii__ProductInventory__c> allListProdInv= [SELECT id,ownerid,isdeleted,name,currencyisocode,createddate,createdbyid,lastmodifieddate,
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
                                                                giic_historicalwo__c , gii__Product__r.gii__Service__c FROM gii__ProductInventory__c 
                                                                where Id IN: setProdInvIdForQuery
                                                                AND gii__Product__r.gii__Service__c =false];
                //lstProdInv.addAll(lstProdInvForQuer )
                system.debug('allListProdInv>> '+ allListProdInv);
                system.debug('allListProdInv.size()>> '+ allListProdInv.size());
                if(allListProdInv.size() > 0){
                    for(gii__ProductInventory__c objInv : allListProdInv){ 
                        system.debug(' objInv.gii__Product__c>> '+  objInv.gii__Product__c);
                        system.debug(' objInv.gii__Product__r.gii__Service__c>> '+  objInv.gii__Product__r.gii__Service__c);
                        if( objInv.gii__Warehouse__c != null &&
                           objInv.gii__Product__c != null &&
                           objInv.gii__Product__r.gii__Service__c == false &&
                           objInv.giic_NumberOfMonth__c != null){
                               setProdId.add(objInv.gii__Product__c);
                               setWarehouseId.add(objInv.gii__Warehouse__c);
                               setProdInvId.add(objInv.id);
                               
                               mapProdAndProdInv.put(objInv.gii__Product__c,objInv);
                           }
                        
                    }
                    system.debug('setProdId>> '+ setProdId);
                    system.debug('setProdId.size()>> '+ setProdId.size());
                    system.debug('setWarehouseId>> '+ setWarehouseId);
                    system.debug('setWarehouseId.size()>> '+ setWarehouseId.size());
                    system.debug('setProdInvId>> '+ setProdInvId);
                    system.debug('setProdInvId.size()>> '+ setProdInvId.size());
                    if(setProdId.size() > 0 && setWarehouseId.size() > 0 && setProdInvId.size() > 0){
                        
                        list<gii__SalesOrderLine__c> listOfSOL = [Select id,gii__OrderQuantity__c,gii__ScheduledDate__c,
                                                                  gii__ProductInventory__r.giic_NumberOfMonth__c ,
                                                                  gii__Product__c from gii__SalesOrderLine__c 
                                                                  where gii__Warehouse__c IN: setWarehouseId 
                                                                  AND gii__Product__c IN:setProdId
                                                                  AND gii__ProductInventory__c IN: setProdInvId 
                                                                 ];
                        /* list<gii__TransferOrderLine__c> listOfTOL  = [select id , gii__Product__c ,
gii__Warehouse__c ,gii__Quantity__c,
gii__RequiredDate__c ,CreatedDate 
from gii__TransferOrderLine__c 
where gii__Warehouse__c IN: setWarehouseId 
AND gii__Product__c IN:setProdId ];*/
                        List<gii__ReceiptQueue__c>  listRQ =[select id , gii__InTransitWarehouse__c,
                                                             gii__ProductInventorySequence__c,
                                                             gii__ProductInventorySequence__r.giic_NumberOfMonth__c,
                                                             gii__TransferOrder__c ,gii__TransferOrderLine__c,
                                                             gii__TransferOrderLine__r.gii__Warehouse__c,
                                                             gii__TransferOrderLine__r.gii__Product__c,
                                                             gii__TransferOrderLine__r.gii__RequiredDate__c,
                                                             gii__TransferOrderLine__r.CreatedDate ,
                                                             gii__TransferOrderLine__r.gii__Quantity__c
                                                             from gii__ReceiptQueue__c
                                                             where gii__TransferOrderLine__c != null
                                                             AND  ( gii__TransferOrderLine__r.gii__Quantity__c != null 
                                                                   OR gii__TransferOrderLine__r.gii__Quantity__c != 0 ) 
                                                             AND  gii__TransferOrderLine__r.gii__Warehouse__c  IN: setWarehouseId 
                                                             AND gii__TransferOrderLine__r.gii__Product__c IN:setProdId
                                                             AND gii__ProductInventorySequence__c  IN: setProdInvId];
                        
                        list<gii__WorkOrder__c> listOfWO = [Select id,gii__OrderQuantity__c,gii__ScheduleStartDate__c,
                                                            gii__StartDate__c,
                                                            gii__ProductInventory__r.giic_NumberOfMonth__c ,
                                                            gii__Product__c from gii__WorkOrder__c 
                                                            where gii__Warehouse__c IN: setWarehouseId 
                                                            AND gii__Product__c IN:setProdId
                                                            AND gii__ProductInventory__c IN: setProdInvId 
                                                           ];
                        system.debug('listOfSOL>> '+ listOfSOL);
                        system.debug('listOfSOL.size()>> '+ listOfSOL.size());
                        system.debug('listRQ>> '+ listRQ);
                        system.debug('listRQ.size()>> '+ listRQ.size());
                        system.debug('listOfWO>> '+ listOfWO);
                        system.debug('listOfWO.size()>> '+ listOfWO.size());
                        // this for SOL
                        if(listOfSOL.size() > 0){
                            mapProdAndQntOfSOL = getSOLThequantityCount(listOfSOL);
                            system.debug('mapProdAndQntOfSOL>>1 '+ mapProdAndQntOfSOL);
                            system.debug('mapProdAndQntOfSOL.size()>1> '+ mapProdAndQntOfSOL.size());
                        }
                        
                        // this for WO
                        if(listOfWO.size() > 0){
                            mapProdAndQntOfWO = getWOThequantityCount(listOfWO);
                            system.debug('mapProdAndQntOfWO>>1 '+ mapProdAndQntOfWO);
                            system.debug('mapProdAndQntOfWO.size()>>1 '+ mapProdAndQntOfWO.size());
                            
                        }
                        // this for TOL
                        if(listRQ.size() > 0){
                            mapProdAndQntOfTOL = getTOLThequantityCount(listRQ);
                            system.debug('mapProdAndQntOfTOL>>1 '+ mapProdAndQntOfTOL);
                            system.debug('mapProdAndQntOfTOL.size()>>1 '+ mapProdAndQntOfTOL.size());
                        }
                        
                        system.debug('mapProdAndQntOfWO Key set>> '+ mapProdAndQntOfWO.keySet());
                        system.debug('mapProdAndQntOfSOL key set>> '+ mapProdAndQntOfSOL.keySet());
                        system.debug('mapProdAndQntOfTOL>>key set '+ mapProdAndQntOfTOL.keySet());
                        for(gii__ProductInventory__c objInv : allListProdInv){ 
                            decimal qntSOL =0.0;
                            decimal qntWO =0.0;
                            decimal qntTO =0.0;
                            system.debug('objInv>> '+ objInv.id);
                            // system.debug('contains SOL>>2 '+ (mapProdAndQntOfSOL.containsKey(objInv.gii__Product__c)));
                            if(mapProdAndQntOfSOL.containsKey(objInv.gii__Product__c)){
                                system.debug('vlaue SO'+ mapProdAndQntOfSOL.get(objInv.gii__Product__c)); 
                                qntSOL =mapProdAndQntOfSOL.get(objInv.gii__Product__c);
                                objInv.giic_HistoricalSO__c =qntSOL;
                            }else{
                                objInv.giic_HistoricalTO__c =qntSOL;
                            }
                            
                            //system.debug('contains WO>>2 '+ (mapProdAndQntOfWO.containsKey(objInv.gii__Product__c)));
                            if(mapProdAndQntOfWO.containsKey(objInv.gii__Product__c)){
                                system.debug('vlaue WO'+ mapProdAndQntOfWO.get(objInv.gii__Product__c));
                                qntWO =mapProdAndQntOfWO.get(objInv.gii__Product__c);
                                objInv.giic_HistoricalWO__c =qntWO;
                            }else{
                                objInv.giic_HistoricalTO__c =qntWO;
                            }
                            
                            // system.debug('contains TOL>>2 '+ (mapProdAndQntOfTOL.containsKey(objInv.gii__Product__c)));
                            if(mapProdAndQntOfTOL.containsKey(objInv.gii__Product__c)){
                                system.debug('vlaue TOL'+ mapProdAndQntOfTOL.get(objInv.gii__Product__c));
                                qntTO =mapProdAndQntOfTOL.get(objInv.gii__Product__c);
                                objInv.giic_HistoricalTO__c =qntTO;
                            }else{
                                objInv.giic_HistoricalTO__c =qntTO;
                            }
                            
                            objInv.giic_12MonthsDemand__c =qntSOL + qntWO + qntTO;
                             objInv.gii__OrderPointQuantity__c =objInv.giic_MaxQtyCalculated__c;
                            
                            updateResult.add(objInv);
                        }
                        
                        system.debug('updateResult>>1 '+ updateResult);
                        system.debug('updateResult.size()>>1 '+ updateResult.size());
                        if(updateResult.size() > 0){
                            update updateResult;
                        }
                        
                    }
                }
            }
        }
        catch(exception e){
            system.debug('Demand Order creation failed due to '+e.getMessage());
            
        }
        
    }
    
    
    public static  Map<Id,Decimal> getTOLThequantityCount(List<gii__ReceiptQueue__c>  listRQ){
        Map<Id,Decimal> mapProdAndQntOfTOLTest = new Map<id,Decimal>();
        Map<Id,Decimal> mapProdAndQntOfTOL = new Map<id,Decimal>();
        // !st id means product invenrory and 2nd id means gii__TransferOrderLine__c
        Map<Id,list<Id>> mapProdAndlistOfTOl = new  Map<Id,list<Id>>();
        system.debug('listRQ>> '+ listRQ);
        
        
        for(gii__ReceiptQueue__c objRQLine : listRQ ){
            
            Integer numberOfMonth = Integer.ValueOf(objRQLine.gii__ProductInventorySequence__r.giic_NumberOfMonth__c);
            Datetime todayDate = System.now();
            DateTime newTodayDate = todayDate.addMonths(-numberOfMonth);
            system.debug('numberOfMonth>> '+ numberOfMonth);
            system.debug('todayDate>> '+ todayDate);
            system.debug('newTodayDate>> '+ newTodayDate);
            system.debug('objSaleLine.gii__RequiredDate__c >> '+ objRQLine.gii__TransferOrderLine__r.gii__RequiredDate__c );
            system.debug('con11 >> '+ (objRQLine.gii__TransferOrderLine__r.gii__RequiredDate__c >= newTodayDate) );
            if(objRQLine.gii__TransferOrderLine__r.gii__RequiredDate__c >= newTodayDate){
                
                
                system.debug('WO Conats>> '+ (!mapProdAndlistOfTOl.containsKey(objRQLine.gii__ProductInventorySequence__c)));
                
                if(!mapProdAndlistOfTOl.containsKey(objRQLine.gii__ProductInventorySequence__c)){
                    mapProdAndlistOfTOl.put(objRQLine.gii__ProductInventorySequence__c ,new list<id>());
                    
                }
                mapProdAndlistOfTOl.get(objRQLine.gii__ProductInventorySequence__c).add(objRQLine.gii__TransferOrderLine__c);
                
                if(!mapProdAndQntOfTOLTest.containsKey(objRQLine.gii__TransferOrderLine__r.gii__Product__c)){
                    mapProdAndQntOfTOLTest.put(objRQLine.gii__TransferOrderLine__r.gii__Product__c, objRQLine.gii__TransferOrderLine__r.gii__Quantity__c);
                }else{
                    decimal Count = mapProdAndQntOfTOLTest.get(objRQLine.gii__TransferOrderLine__r.gii__Product__c);
                    decimal Count2  =Count + objRQLine.gii__TransferOrderLine__r.gii__Quantity__c;
                    mapProdAndQntOfTOLTest.put(objRQLine.gii__TransferOrderLine__r.gii__Product__c, Count2);
                }
                
                
                
                
            }
        }
        system.debug('mapProdAndQntOfTOLTest>> '+ mapProdAndQntOfTOLTest);
        system.debug('mapProdAndQntOfTOLTest.keySet()>> '+ mapProdAndQntOfTOLTest.keySet());
        
        
        return mapProdAndQntOfTOLTest;
    }
    public static  Map<Id,Decimal> getWOThequantityCount(list<gii__WorkOrder__c>  listOfWO){
        
        Map<Id,Decimal> mapProdAndQntOfWOTest = new Map<id,Decimal>();
        Map<Id,Decimal> mapProdAndQntOfWO = new Map<id,Decimal>();
        Map<Id,List<gii__WorkOrder__c>> mapProdAndlistOfWO = new Map<id,List<gii__WorkOrder__c>>();
        system.debug('listOfSOL>> '+ listOfWO);
        
        for(gii__WorkOrder__c objWOLine : listOfWO ){
            
            Integer numberOfMonth = Integer.ValueOf(objWOLine.gii__ProductInventory__r.giic_NumberOfMonth__c);
            Datetime todayDate = System.now();
            DateTime newTodayDate = todayDate.addMonths(-numberOfMonth);
            system.debug('numberOfMonth>> '+ numberOfMonth);
            system.debug('todayDate>> '+ todayDate);
            system.debug('newTodayDate>> '+ newTodayDate);
            system.debug('objSaleLine.gii__ScheduleStartDate__c >> '+ objWOLine.gii__ScheduleStartDate__c );
            system.debug('objSaleLine.gii__StartDate__c >> '+ objWOLine.gii__StartDate__c );
            system.debug('con11 >> '+ (objWOLine.gii__StartDate__c >= newTodayDate) );
            if(objWOLine.gii__StartDate__c >= newTodayDate){
                system.debug('WO Conats>> '+ (!mapProdAndlistOfWO.containsKey(objWOLine.gii__ProductInventory__c)));
                
                if(!mapProdAndlistOfWO.containsKey(objWOLine.gii__ProductInventory__c)){
                    mapProdAndlistOfWO.put(objWOLine.gii__ProductInventory__c ,new list<gii__WorkOrder__c>());
                    
                }
                mapProdAndlistOfWO.get(objWOLine.gii__ProductInventory__c).add(objWOLine);
                
                if(!mapProdAndQntOfWOTest.containsKey(objWOLine.gii__Product__c)){
                    mapProdAndQntOfWOTest.put(objWOLine.gii__Product__c, objWOLine.gii__OrderQuantity__c);
                }else{
                    decimal Count = mapProdAndQntOfWOTest.get(objWOLine.gii__Product__c);
                    decimal Count2  =Count + objWOLine.gii__OrderQuantity__c;
                    mapProdAndQntOfWOTest.put(objWOLine.gii__Product__c, Count2);
                }
                
                
                
                
            }
        }
        system.debug('mapProdAndQntOfWOTest>> '+ mapProdAndQntOfWOTest);
        system.debug('mapProdAndQntOfWOTest.keySet()>> '+ mapProdAndQntOfWOTest.keySet());
        system.debug('mapProdAndlistOfWO>> '+ mapProdAndlistOfWO);
        system.debug('mapProdAndlistOfWO.keySet()>> '+ mapProdAndlistOfWO.keySet());
        /* if(mapProdAndlistOfWO.size() > 0){
for(id pdIn : mapProdAndlistOfWO.keySet()){
list<gii__WorkOrder__c>  listOfWOValue = mapProdAndlistOfWO.get(pdIn);
decimal CountQnt;
for(gii__WorkOrder__c WOValue : listOfWOValue ){
CountQnt  =CountQnt + WOValue.gii__OrderQuantity__c;
}
mapProdAndQntOfWO.put(pdIn, CountQnt);
}
}

system.debug('mapProdAndQntOfWO>> '+ mapProdAndQntOfWO);
system.debug('mapProdAndQntOfWO.keySet()>> '+ mapProdAndQntOfWO.keySet());*/
        
        
        return mapProdAndQntOfWOTest;      // mapProdAndQntOfWO;
        
    }
    
    public static  Map<Id,Decimal> getSOLThequantityCount(list<gii__SalesOrderLine__c>  listOfSOL){
        Map<Id,Decimal> mapProdAndQntOfSOLTest = new Map<id,Decimal>();
        Map<Id,Decimal> mapProdAndQntOfSOL = new Map<id,Decimal>();
        Map<Id,List<gii__SalesOrderLine__c>> mapProdAndlistOfSOL = new Map<id,List<gii__SalesOrderLine__c>>();
        system.debug('listOfSOL>> m'+ listOfSOL);
        for(gii__SalesOrderLine__c objSaleLine : listOfSOL ){
            
            Integer numberOfMonth = Integer.ValueOf(objSaleLine.gii__ProductInventory__r.giic_NumberOfMonth__c);
            Datetime todayDate = System.now();
            DateTime newTodayDate = todayDate.addMonths(-numberOfMonth);
            system.debug('numberOfMonth>> '+ numberOfMonth);
            system.debug('todayDate>> '+ todayDate);
            system.debug('newTodayDate>> '+ newTodayDate);
            system.debug('objSaleLine.gii__ScheduledDate__c >> '+ objSaleLine.gii__ScheduledDate__c );
            system.debug('con11 >> '+ (objSaleLine.gii__ScheduledDate__c >= newTodayDate) );
            if(objSaleLine.gii__ScheduledDate__c >= newTodayDate){
                system.debug('SOL Conats>> '+ (!mapProdAndlistOfSOL.containsKey(objSaleLine.gii__ProductInventory__c)));
                
                if( (!mapProdAndlistOfSOL.containsKey(objSaleLine.gii__ProductInventory__c))){
                    mapProdAndlistOfSOL.put(objSaleLine.gii__ProductInventory__c ,new list<gii__SalesOrderLine__c>());
                    // mapProdAndQntOfSOL.put(objSaleLine.gii__ProductInventory__c ,0.0);
                }
                mapProdAndlistOfSOL.get(objSaleLine.gii__ProductInventory__c).add(objSaleLine);
                
                
                if(!mapProdAndQntOfSOLTest.containsKey(objSaleLine.gii__Product__c)){
                    mapProdAndQntOfSOLTest.put(objSaleLine.gii__Product__c, objSaleLine.gii__OrderQuantity__c);
                }else{
                    decimal Count = mapProdAndQntOfSOLTest.get(objSaleLine.gii__Product__c);
                    decimal Count2  =Count + objSaleLine.gii__OrderQuantity__c;
                    mapProdAndQntOfSOLTest.put(objSaleLine.gii__Product__c, Count2);
                }
                
                
            }
        }
        system.debug('mapProdAndlistOfSOL>> '+ mapProdAndlistOfSOL);
        system.debug('mapProdAndlistOfSOL.keySet()>> '+ mapProdAndlistOfSOL.keySet());
        system.debug('mapProdAndQntOfSOLTest>> '+ mapProdAndQntOfSOLTest);
        system.debug('mapProdAndQntOfSOLTest.keySet()>> '+ mapProdAndQntOfSOLTest.keySet());
        /* if(mapProdAndlistOfSOL.size() > 0){
for(id pdIn : mapProdAndlistOfSOL.keySet()){
list<gii__SalesOrderLine__c>  listOfSOlValue = mapProdAndlistOfSOL.get(pdIn);
decimal CountQnt;
for(gii__SalesOrderLine__c SOlValue : listOfSOlValue ){
CountQnt  =CountQnt + SOlValue.gii__OrderQuantity__c;
}
mapProdAndQntOfSOL.put(pdIn, CountQnt);
}
}
system.debug('mapProdAndQntOfSOL>> '+ mapProdAndQntOfSOL);
system.debug('mapProdAndQntOfSOL.keySet()>> '+ mapProdAndQntOfSOL.keySet());*/
        return mapProdAndQntOfSOLTest;   //mapProdAndQntOfSOL;
    }
    
    
   
    
}