public with sharing class giic_CreateHarvestProduct {

    @AuraEnabled(cacheable=true)
    public static List<harvestProductWrapper> retrieveProductData(string keySearch){     
        
        String searchKey = '%' + keySearch + '%';
        
        List<gii__Product2Add__c> prodList = [Select Id, Name, gii__ProductCode__c,gii__SerialControlled__c, gii__LotControlled__c from gii__Product2Add__c Where Name Like  : searchKey or gii__ProductCode__c Like  : searchKey];
        system.debug('prodList ='+ prodList);
        //return prodList;
    
        List<harvestProductWrapper> lstwrpHarvestProd = new List<harvestProductWrapper>();
        
        for(gii__Product2Add__c obj: prodList)
        {
            harvestProductWrapper wrpHPLine = new harvestProductWrapper();
            wrpHPLine.objHarvestRef = obj; 
            wrpHPLine.quality = '';
            wrpHPLine.quantity = '';
            wrpHPLine.prodSerial = '';
            wrpHPLine.lotNumber = '';
            //wrpHPLine.Warehouse = this.Warehouse;
            //wrpHPLine.location = this.location;
            // wrpHPLine.harvestDate = this.harvestDate;
            lstwrpHarvestProd.add(wrpHPLine);   
        }
        return lstwrpHarvestProd;      
    
    
    }
    
    @AuraEnabled
    public static string createHarvestProducts(List<harvestProductWrapper> finallist, string workorderId){
        system.debug('finallist::::'+finallist);
        system.debug('workorderId::::'+workorderId);
    
        gii__WorkOrder__c wo = [Select Id, gii__OrderQuantity__c,
        gii__Product__c, gii__Product__r.Name,
        gii__Warehouse__c, gii__Warehouse__r.Name, 
        gii__Warehouse__r.gii__DefaultReceivingLocation__c,
        gii__Warehouse__r.giic_DefaultHarvestLocation__c,
        gii__Warehouse__r.giic_DefaultHarvestLocation__r.id,
        gii__Warehouse__r.gii__DefaultIssueLocation__r.Name,
        gii__Warehouse__r.gii__DefaultReceivingLocation__r.Name, 
        gii__Warehouse__r.gii__DefaultRMADispositionLocation__r.Name
        from gii__WorkOrder__c where Id = :workorderId]; 
    
        /* List<gii__WorkOrderIssue__c> woIssueList= [select id,gii__Component__c,gii__IssueQuantity__c,
        gii__ProductSerial__c,gii__SerialControlled__c,gii__IssueQuantity__c,gii__Warehouse__c,gii__Location__c from gii__WorkOrderIssue__c where gii__WorkOrder__c =: workorderId];
        system.debug('woIssueList' + woIssueList);*/
    
        list<gii__WorkOrderStaging__c> lstWorkOrderStaging = new list<gii__WorkOrderStaging__c>();
        List<gii__ProductSerial__c> lstPrdSer = new List<gii__ProductSerial__c>();
       
        for(HarvestProductWrapper harPrd : finalList ){
            if(harPrd.objHarvestRef.gii__SerialControlled__c == true)
            {
            gii__ProductSerial__c prdSer = new gii__ProductSerial__c();
            system.debug('****'+ harPrd.prodSerial + harPrd.objHarvestRef.Id);
          
            system.debug('****'+ harPrd.prodSerial + harPrd.objHarvestRef.Id);
            prdSer.Name = 'harPrd.prodSerial';
            prdSer.gii__Product__c = harPrd.objHarvestRef.Id;
            //prdSer.gii__WorkOrderId__c = workorderId;
            lstPrdSer.add(prdSer);
            }
        }
        if(!lstPrdSer.isEmpty()){
            system.debug('prod Serial Size'+lstPrdSer.size());
            insert lstPrdSer;
        }

        Map<string,gii__ProductSerial__c> prodSerialMap = new  Map<string,gii__ProductSerial__c>();
      //  prodSerial = [select id,gii__Product__c from  gii__ProductSerial__c order by CreatedDate desc limit 1];
        for(gii__ProductSerial__c pi : 
                [select id,gii__Product__c,gii__Product__r.gii__SerialControlled__c from  gii__ProductSerial__c order by CreatedDate desc limit 1])              
            {
                String key = '' + pi.gii__Product__c; 
                prodSerialMap.put(key, pi);
            }
            system.debug('**prodSerialMap VAl'+ prodSerialMap.keySet()+ prodSerialMap);


        for(harvestProductWrapper harProdWrap : finallist)
        {

            gii__WorkOrderStaging__c workOrderStage = new gii__WorkOrderStaging__c();
            workOrderStage.giic_Component__c = harProdWrap.objHarvestRef.id;
            workOrderStage.giic_Warehouse__c= wo.gii__Warehouse__c;
            workOrderStage.giic_Location__c= wo.gii__Warehouse__r.giic_DefaultHarvestLocation__c;
            workOrderStage.giic_Quality__c = harProdWrap.quality;
            workOrderStage.giic_WorkOrder__c=wo.id;
            workOrderStage.giic_Quantity__c= Decimal.valueOf(harProdWrap.quantity);  
            lstWorkOrderStaging.add(workOrderStage);
        }
        system.debug('lstWorkOrderStaging:--'+lstWorkOrderStaging);
        // insert lstWorkOrderStaging;      
        Map<String, gii__WorkOrderStaging__c> woIssuesMap = new Map<String, gii__WorkOrderStaging__c>();
        Set<String> prodIds = new Set<String>();
        Set<String> whIds = new Set<String>();
        Set<String> locIds = new Set<String>();
        for(gii__WorkOrderStaging__c ln :lstWorkOrderStaging){
        String key = '' + ln.giic_Component__c + ln.giic_Warehouse__c;     
        prodIds.add(ln.giic_Component__c);
        whIds.add(ln.giic_Warehouse__c);
        locIds.add(ln.giic_Location__c);
        woIssuesMap.put(key, ln); 
        }
       
        system.debug('**woIssuesMap VAl'+ woIssuesMap.keySet()+ woIssuesMap);

    
        Map<String, gii__ProductInventory__c> piMap = new Map<String, gii__ProductInventory__c>();
            for(gii__ProductInventory__c pi : 
                [Select Id, gii__Product__c, gii__Warehouse__c, gii__PrimaryLocation__c From gii__ProductInventory__c  
                    Where gii__Product__c  in :prodIds  and gii__Warehouse__c in :whIds                   
                ])
            {
                String key = '' + pi.gii__Product__c + pi.gii__Warehouse__c ; 
                piMap.put(key, pi);
            }
            system.debug('**piMap VAl'+ piMap.keySet()+ piMap);
            Map<String, gii__ProductInventoryQuantityDetail__c> piqdMap = new Map<String, gii__ProductInventoryQuantityDetail__c>();
            for(gii__ProductInventoryQuantityDetail__c piqd : 
                [Select Id, gii__Location__c, gii__MovableQuantity__c,
                    gii__Blockedquantity__c, gii__OnHandquantity__c,  
                    gii__Product__c, gii__ProductLot__r.gii__Restricted__c,
                    gii__ProductLot__c, gii__Warehouse__c, gii__Available__c, 
                    gii__LotRestricted__c, gii__ProductInventory__c, 
                    gii__ProductInventorybyLocation__c, gii__ProductSerial__c, 
                    gii__ReservedQuantity__c, gii__RestrictedQuantity__c
                    From gii__ProductInventoryQuantityDetail__c  
                    Where gii__Product__c in :prodIds and gii__Warehouse__c in :whIds
                    and gii__Location__c in :locIds
                 
                ])
            {
                String key = '' + piqd.gii__Product__c + piqd.gii__Warehouse__c; 
                piqdMap.put(key, piqd);
            }
            system.debug('**piqdMap VAl'+ piqdMap.keySet()+ piqdMap);
    
            List<gii__ProductInventory__c> pisNew= new List<gii__ProductInventory__c>();
            for (String key : woIssuesMap.keySet()){
                gii__WorkOrderStaging__c woi = woIssuesMap.get(key);
                
                String piKey = '' + woi.giic_Component__c + woi.giic_Warehouse__c;
                system.debug('**Value'+piMap.get(piKey));
                gii__ProductInventory__c pi = piMap.get(piKey);
                if(pi == null){
                    pi = new gii__ProductInventory__c(
                        gii__Product__c = woi.giic_Component__c,
                        gii__Warehouse__c = woi.giic_Warehouse__c ,
                        gii__PrimaryLocation__c = woi.giic_Location__c);
    
                   
                    pisNew.add(pi);
                    piMap.put(piKey, pi);
                }
            }
            system.debug('**PI Val'+ pisNew);
            if(!pisNew.isEmpty()) insert pisNew;
    
            List<gii__ProductInventoryQuantityDetail__c> piqds= new List<gii__ProductInventoryQuantityDetail__c>();
            Map<String, gii__WorkOrderStaging__c> woISmap = new Map<String, gii__WorkOrderStaging__c>();
            for (String key : woIssuesMap.keySet()){
                gii__WorkOrderStaging__c woi = woIssuesMap.get(key);
                gii__ProductInventoryQuantityDetail__c piqd = piqdMap.get(key);
                gii__ProductSerial__c prdSerial = prodSerialMap.get(woi.giic_Component__c);
                system.debug('Existing piqd' + piqd);
               //  system.debug('prdSerial.gii__Product__r.gii__SerialControlled__c != true>>' + (prdSerial.gii__Product__r.gii__SerialControlled__c != true));
                 if(prdSerial== null)
               {
                system.debug('Serial Controlled Product  ' + prdSerial.gii__Product__r.gii__SerialControlled__c);
                    system.debug('piqd == null>>>  ' + (piqd == null));
                if(piqd == null){
                    String piKey = '' + woi.giic_Component__c + woi.giic_Warehouse__c;
                    system.debug('piKey>> ' + piKey);
                    gii__ProductInventory__c pi = piMap.get(piKey);
                      system.debug('pi>>> ' + pi);
                    piqd = new gii__ProductInventoryQuantityDetail__c(
                        gii__ProductInventory__c = pi.Id,
                        gii__Product__c = woi.giic_Component__c,
                        gii__Warehouse__c = woi.giic_Warehouse__c,
                        gii__Location__c = woi.giic_Location__c
                       );
                      //  gii__OnHandquantity__c  = woi.giic_Quantity__c
                }
                   system.debug('piqd != null>>>  ' + (piqd != null));
                if(piqd != null){        
                             
                   piqd.gii__OnHandquantity__c = 
                        (piqd.gii__OnHandquantity__c!= null ? piqd.gii__OnHandquantity__c :0) 
                        + woi.giic_Quantity__c; // (Stocking UM)

                        system.debug('gii__OnHandquantity__c'+  piqd.gii__OnHandquantity__c);
                        if(piqd.gii__OnHandquantity__c!= null)
                        {
                            piqd.gii__OnHandquantity__c =piqd.gii__OnHandquantity__c+woi.giic_Quantity__c; 
                        }
                        else if(piqd.gii__OnHandquantity__c!= null)
                        {
                            piqd.gii__OnHandquantity__c = woi.giic_Quantity__c;
                        }
                       // piqd.gii__OnHandquantity__c = woi.giic_Quantity__c;
                        piqd.gii__Blockedquantity__c = 0.00; 
    
                    gii__WorkOrderStaging__c wostage = new gii__WorkOrderStaging__c(
                        giic_WorkOrder__c = wo.Id,
                        giic_Component__c = piqd.gii__Product__c,
                        giic_Warehouse__c = piqd.gii__Warehouse__c,
                        //Location__c = piqd.gii__Location__c,
                        giic_Quantity__c = woi.giic_Quantity__c,
                        giic_Quality__c = woi.giic_Quality__c
                    );
                    woISmap.put(piqd.gii__Product__c, wostage);
                    piqds.add(piqd);  
                    system.debug('**woISmapLIstVAl'+ woISmap);
                }
            }
            
            
           if(prdSerial!=null && prdSerial.gii__Product__r.gii__SerialControlled__c == true)
            {
                system.debug('Serial Controlled Product' +prdSerial.gii__Product__r.gii__SerialControlled__c);
                //if(piqd == null){
                    String piKey = '' + woi.giic_Component__c + woi.giic_Warehouse__c;
                    gii__ProductInventory__c pi = piMap.get(piKey);
                    piqd = new gii__ProductInventoryQuantityDetail__c(
                        gii__ProductInventory__c = pi.Id,
                        gii__Product__c = woi.giic_Component__c,
                        gii__Warehouse__c = woi.giic_Warehouse__c,
                        gii__Location__c = woi.giic_Location__c,
                        gii__ProductSerial__c = prdSerial.id);
                      //  gii__OnHandquantity__c  = woi.giic_Quantity__c
                //}
                if(piqd != null){
                    piqd.gii__OnHandquantity__c = woi.giic_Quantity__c;
                    gii__WorkOrderStaging__c wostage = new gii__WorkOrderStaging__c(
                        giic_WorkOrder__c = wo.Id,
                        giic_Component__c = piqd.gii__Product__c,
                        giic_Warehouse__c = piqd.gii__Warehouse__c,
                        //Location__c = piqd.gii__Location__c,
                        giic_Quantity__c = woi.giic_Quantity__c,
                        giic_Quality__c = woi.giic_Quality__c
                    );
                    woISmap.put(piqd.gii__Product__c, wostage);
                    piqds.add(piqd);  
                    system.debug('**woISmapLIstVAl'+ woISmap);
            }

            }
        }
    
            // create input parameters for inventory adjustment creation for location
        gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails QuantityDetailsObj
                = new gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails();
            
            QuantityDetailsObj.listProductInventoryQuantityDetails = piqds;
            QuantityDetailsObj.AdjustmentDate = system.today();                                         
            QuantityDetailsObj.AdjustmentReason = 'harvest products';  
            
            // call the createInventoryAdjustments method
            gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult ResultObj
            = gii.InventoryAdjustmentforLocation.CreateInventoryAdustments(QuantityDetailsObj);   
        
        //Debug to print the result object
        system.debug(ResultObj); 
        List<gii__InventoryAdjustment__c> listInventoryAdjustment = new List<gii__InventoryAdjustment__c>();
        if(ResultObj.listInventoryAdjustment != null){
            listInventoryAdjustment.addAll(ResultObj.listInventoryAdjustment);
        }
        
        if(ResultObj.Exceptions != null) {
            if (ResultObj.Exceptions.size() > 0) {
                List<String> ErrorMsgList = new List<String>();
                for(gii.InventoryAdjustmentforLocation.GOMException e :ResultObj.Exceptions) { 
                  //  ErrorMsgList.add(e.getMessage());
                }
                if(ErrorMsgList.size()>0){
                    system.debug(ErrorMsgList);
                  //  throw new CustomException(ErrorMsgList[0]); 
                }
        
            }  
        }

        system.debug('listInventoryAdjustment'+ listInventoryAdjustment);
        List<gii__WorkOrderStaging__c> hpList = new List<gii__WorkOrderStaging__c>();
        for(gii__InventoryAdjustment__c ia :listInventoryAdjustment){
            system.debug('**Final value'+woISMap.get(ia.gii__Product__c));
            gii__WorkOrderStaging__c wois = woISMap.get(ia.gii__Product__c); 
    
            wois.giic_InventoryAdjustment__c = ia.Id;
    
            hpList.add(wois);
        }
        system.debug('**HP'+hpList );
        insert hpList;
              
    
        return wo.id;
    
        // Exception Handling
      
              
             
        
    
    }
    
            
    public class harvestProductWrapper{
        
        @AuraEnabled
        public Boolean isSelected{get;set;}
        
        @AuraEnabled
        public gii__Product2Add__c objHarvestRef{get;set;}
        
        @AuraEnabled public String quality{get;set;}
        @AuraEnabled public String quantity{get;set;}
        @AuraEnabled public String Warehouse{get;set;}
        @AuraEnabled public String Location{get;set;}
        @AuraEnabled public String harvestDate{get;set;}
        @AuraEnabled public String prodSerial{get;set;}
        @AuraEnabled public String lotNumber{get;set;}
        
    
    }
        
        
    }