public with sharing class giic_SourcingGrpRuleConvert {

    public giic_SourcingGrpRuleConvert(ApexPages.StandardSetController controller) {

    }



    public giic_SourcingGrpRuleConvert() {

    }
    @AuraEnabled
    public static void convertSourciongGroupRule(){
        Set<String> setGroupNames = new Set<String>();
        Set<String> setWareHouseName = new Set<String>();
        Set<String> setSupplierName = new Set<String>();
        Map<String,gii__SourcingGroup__c> mapSurceGrp = new Map<String,gii__SourcingGroup__c>();
        List<giic_SourcingGroupRuleConversion__mdt> lstMetadata = new List<giic_SourcingGroupRuleConversion__mdt>();
        Map<String,gii__Warehouse__c> mapWarehouse = new Map<String,gii__Warehouse__c>();
        Map<String,gii__SourcingGroupRule__c> mapSourceRule = new Map<String,gii__SourcingGroupRule__c>();
        //Map<String, giic_SourcingGroupRuleConversion__mdt
        for(gii__SourcingGroup__c objSourceGrp : [Select id,name,(Select id,gii__SourcingType__c,gii__Supplier__r.name,gii__FromWarehouse__r.name,gii__TransferToWarehouse__r.name from gii__SourcingGroupRules__r) from gii__SourcingGroup__c]){
            mapSurceGrp.put(objSourceGrp.name,objSourceGrp);
            setGroupNames.add(objSourceGrp.name);
            for(gii__SourcingGroupRule__c objgroupRule :objSourceGrp.gii__SourcingGroupRules__r ){
                if(objgroupRule.gii__SourcingType__c =='Transfer From'){
                    String Name = objSourceGrp.name+objgroupRule.gii__TransferToWarehouse__r.name+objgroupRule.gii__FromWarehouse__r.name;
                    system.debug('setWareHouseName>>>>>2 '+Name);
                    mapSourceRule.put(Name,objgroupRule);
                   // setGroupNames.add('SourcingTo'+objgroupRule.gii__TransferToWarehouse__r.name);
                }else if(objgroupRule.gii__SourcingType__c == 'Purchase From'){
                    String Name = objSourceGrp.name+ objgroupRule.gii__Supplier__r.name;
                    mapSourceRule.put(Name,objgroupRule);
                    //setGroupNames.add('SourcingTo'+objgroupRule.gii__TransferToWarehouse__r.name);
                }
               
            }
        }
        for(giic_SourcingGroupRuleConversion__mdt objMetedata : [Select id,giic_InTransitLeadTime__c,giic_FromWarehouse__c,giic_ModeofTransport__c,giic_Share__c,giic_SourcingType__c,giic_Supplier__c,giic_TransferToWarehouse__c from giic_SourcingGroupRuleConversion__mdt]){
            setWareHouseName.add(objMetedata.giic_FromWarehouse__c);
            setWareHouseName.add(objMetedata.giic_TransferToWarehouse__c);
            setSupplierName.add(objMetedata.giic_Supplier__c);
            lstMetadata.add(objMetedata);
            
        }
        Map<String, gii__WarehouseNetwork__c> mapNetwork = new Map<String, gii__WarehouseNetwork__c>();
        for(gii__WarehouseNetwork__c objNetwork : [Select id,gii__FromWarehouse__r.name,gii__TransferToWarehouse__r.name from gii__WarehouseNetwork__c]){
            mapNetwork.put(objNetwork.gii__TransferToWarehouse__r.name+objNetwork.gii__FromWarehouse__r.name,objNetwork);
        }
        system.debug('setWareHouseName>>>>>0 '+mapNetwork.keySet());
        system.debug('setWareHouseName>>>>> '+setWareHouseName.size());
        system.debug('setWareHouseName>>>>>1 '+setWareHouseName);
        for(gii__Warehouse__c objWarehouse : [select id,name from gii__Warehouse__c where Name IN:setWareHouseName ]){
            system.debug('setWareHouseName>>>>>11 '+objWarehouse.name);
            mapWarehouse.put(objWarehouse.name,objWarehouse);
        }
        List<gii__SourcingGroup__c> lstGroupToInsert = new List<gii__SourcingGroup__c>();
        system.debug('setWareHouseName>>>>>110 '+mapSourceRule.keySet());
        system.debug('setWareHouseName>>>>>111 '+setGroupNames);
        for(giic_SourcingGroupRuleConversion__mdt objMetadata : lstMetadata){
            system.debug('setWareHouseName>>>>>21 '+mapSourceRule.containsKey('SourcingTo'+objMetadata.giic_TransferToWarehouse__c));
            system.debug('setWareHouseName>>>>>22 '+setGroupNames.contains('SourcingTo'+objMetadata.giic_TransferToWarehouse__c));
            if(!(mapSurceGrp.containsKey('SourcingTo'+objMetadata.giic_TransferToWarehouse__c) || setGroupNames.contains('SourcingTo'+objMetadata.giic_TransferToWarehouse__c))){
                setGroupNames.add('SourcingTo'+objMetadata.giic_TransferToWarehouse__c);
                gii__SourcingGroup__c objGroup = new gii__SourcingGroup__c(Name = 'SourcingTo'+objMetadata.giic_TransferToWarehouse__c,gii__Description__c = 'Sourcing To '+objMetadata.giic_TransferToWarehouse__c);
                lstGroupToInsert.add(objGroup);                  
            } 
        }
        if(lstGroupToInsert.size() > 0 ){
            try{
                insert lstGroupToInsert;
            }
            catch(Exception e){
                system.debug('error is due to '+e.getMessage());
            }
            for(gii__SourcingGroup__c obj : [Select id, name from gii__SourcingGroup__c]){
                mapSurceGrp.put(obj.Name,obj);
            }
        }
        Map<String, Account> mapAccount = new Map<String, Account>();
        for(Account objAcc : [Select id, name from Account where Name In: setSupplierName]){
            mapAccount.put(objAcc.Name,objAcc);
        }
        system.debug('setWareHouseName>>>>>4 '+lstGroupToInsert.size());
        system.debug('setWareHouseName>>>>>41 '+lstGroupToInsert);
        List<gii__SourcingGroupRule__c> lstSourceRuleToInsrt = new List<gii__SourcingGroupRule__c>();
        //List<giic_SourcingGroupRuleConversion__mdt> lstGroupMetaData = [Select id, giic_FromWarehouse__c,];
        for(giic_SourcingGroupRuleConversion__mdt objMetadatas : lstMetadata){
            if(!(mapSourceRule.containsKey('SourcingTo'+objMetadatas.giic_TransferToWarehouse__c+objMetadatas.giic_TransferToWarehouse__c+objMetadatas.giic_FromWarehouse__c) || mapSourceRule.containsKey('SourcingTo'+objMetadatas.giic_TransferToWarehouse__c+objMetadatas.giic_Supplier__c))){
                gii__SourcingGroupRule__c objRule = new gii__SourcingGroupRule__c();
                if(objMetadatas.giic_SourcingType__c == 'Transfer From'){
                    objRule.gii__FromWarehouse__c =  mapWarehouse.get(objMetadatas.giic_FromWarehouse__c).id;
                    objRule.gii__TransferToWarehouse__c = mapWarehouse.get(objMetadatas.giic_TransferToWarehouse__c).id;
                    objRule.gii__SourcingType__c = 'Transfer From';
                    objRule.gii__SourcingSequence__c = 1;
                    objRule.gii__ModeofTransport__c = 'Air';
                    objRule.gii__Share__c = 100;
                    objRule.gii__WarehouseNetwork__c = mapNetwork.get(objMetadatas.giic_TransferToWarehouse__c+objMetadatas.giic_FromWarehouse__c).id;
                    objRule.gii__SourcingGroup__c = mapSurceGrp.get('SourcingTo'+objMetadatas.giic_TransferToWarehouse__c).id;
                    lstSourceRuleToInsrt.add(objRule);
                }else{
                    objRule.gii__TransferToWarehouse__c = mapWarehouse.get(objMetadatas.giic_TransferToWarehouse__c).id;
                    objRule.gii__SourcingType__c = 'Purchase From';
                    objRule.gii__SourcingSequence__c = 1;
                    objRule.gii__ModeofTransport__c = 'Air';
                    objRule.gii__Share__c = 100;
                    objRule.gii__Supplier__c = mapAccount.get(objMetadatas.giic_Supplier__c).id;
                    objRule.gii__SourcingGroup__c = mapSurceGrp.get('SourcingTo'+objMetadatas.giic_TransferToWarehouse__c).id;
                    lstSourceRuleToInsrt.add(objRule);
                }
            }
        }
        system.debug('setWareHouseName>>>>>5 '+lstSourceRuleToInsrt.size());
        system.debug('setWareHouseName>>>>>51 '+lstSourceRuleToInsrt);
        if(lstSourceRuleToInsrt.size() > 0 ){
            try{
                insert lstSourceRuleToInsrt;
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Confirm, 'Successfull!!');
                ApexPages.addMessage(msg);
            }
            catch(Exception e){
            ApexPages.Message msgo = new ApexPages.Message(ApexPages.Severity.WARNING, 'Error Has Occured:-'+e.getMessage());
            ApexPages.addMessage(msgo);
                system.debug('error is due to '+e.getMessage());
            }
            
        }
    }
    public static void createAssignmentGroupRule(){
        /*List<gii__AssignmentGroup__c> lstAssGroup = [Select id,name from gii__AssignmentGroup__c where Name ='Parts-Assignment Group'];
        Set<String> setProd = new Set<String>{'0R0614'};//,'0R0617','6036408','6022408','6022501'
        List<Product2> lstProd = [Select id,name,Make__c from Product2 where recordtype.name = 'Product Support'  AND Make__c='CA' AND Name IN:setProd ];
        System.debug('lstProd>>>>>>> '+lstProd.size());
        System.debug('lstProd>>>>>>>1 '+lstProd);
        //Select id,gii__ProductReference__c, name,gii__ProductReference__r.name from gii__Product2Add__c where gii__ProductReference__r.recordtype.name = 'Product Support' limit 1000
        List<gii__Product2Add__c> lstProdRef = [Select id, name from gii__Product2Add__c where gii__ProductReference__c IN:lstProd];
        System.debug('lstProd>>>>>>>2 '+lstProdRef.size());
        System.debug('lstProd>>>>>>>3 '+lstProdRef); 
        Map<String,gii__AssignmentGroupRule__c> mapAssGroupRule = new Map<String,gii__AssignmentGroupRule__c>();
        for(gii__AssignmentGroupRule__c objAssGrp :[Select id,gii__Product__r.name,gii__TransferToWarehouse__r.name from gii__AssignmentGroupRule__c]){
            mapAssGroupRule.put(objAssGrp.gii__Product__r.name+objAssGrp.gii__TransferToWarehouse__r.name,objAssGrp);
        }
        List<gii__AssignmentGroupRule__c>lstAssGroupRule =new List<gii__AssignmentGroupRule__c>();

        for(gii__Product2Add__c objProd :lstProdRef ){
            if(!mapAssGroupRule.containsKey(objProd.Name+'Egypt')){
                gii__AssignmentGroupRule__c obj = new gii__AssignmentGroupRule__c(gii__Product__c =objProd.id,
                                                                                    gii__AssignmentGroup__c = 'a1f0E000002YY8zQAG',
                                                                                    gii__TransferToWarehouse__c = 'aDB0E0000004Ep0WAE',
                                                                                    gii__SourcingLevels__c = 'Global',
                                                                                    gii__ProductGroup__c = 'aAn0E0000004YMBSA2' );
                lstAssGroupRule.add(obj);
            
            }
        }
        if(lstAssGroupRule.size() > 0 ){
            try{
                insert lstAssGroupRule;
            }
            catch(Exception e){
                system.debug('error is due to '+e.getMessage());
            }
        }*/
        //List<gii__SourcingGroup__c> lstSourcGrp = [];
        Set<String> setMakeCode = new Set<String>();
        Set<String> setWarehouse = new Set<String>();
        Map<String,gii__SourcingGroup__c> mapSourcGrpAndMake = new Map<String,gii__SourcingGroup__c>();
        Map<String,gii__SourcingGroup__c> mapSourcGrp = new Map<String,gii__SourcingGroup__c>();
        Map<String,gii__SourcingGroup__c> mapSourcGrpAndWarehouse = new Map<String,gii__SourcingGroup__c>();
        for(gii__SourcingGroup__c objGroup : [Select id, name,(Select gii__FromWarehouse__c,gii__InTransitLeadTime__c,gii__ModeofTransport__c,gii__Share__c,gii__SourcingSequence__c,gii__SourcingType__c,gii__Supplier__c,gii__TransferToWarehouse__c,gii__WarehouseNetwork__c from gii__SourcingGroupRules__r) from gii__SourcingGroup__c]){
           system.debug('objGroup '+objGroup);
            if(objGroup.name.contains('-')){
             system.debug('objGroup>>>>>>>>>>>>4 '+objGroup);
                system.debug('Name>>>>>>>>>>>>1 '+objGroup.name);
                setMakeCode.add(objGroup.name.substringBefore('-'));
                setWarehouse.add(objGroup.name.substringBetween('-'));
                mapSourcGrpAndMake.put(objGroup.name.substringBefore('-'),objGroup);
                mapSourcGrpAndWarehouse.put(objGroup.name.substringBetween('-'),objGroup);
                mapSourcGrp.put(objGroup.name.substringBefore('-') +'-'+objGroup.name.substringBetween('-'),objGroup);
            }
        }
        system.debug('Name>>>>>>>>>>>>2 '+setMakeCode);
        system.debug('Name>>>>>>>>>>>>3 '+setWarehouse);
        /***Added for demo purpose only starts */
      //  Set<String> setProdName = new Set<String>{'1979322','P010400309-2','P010600543-1','1R0710','5674341','5678386','5680873','5984523','5984524'};
        List<gii__Product2Add__c> lstProduct = [Select id,gii__ProductReference__c from gii__Product2Add__c where gii__ProductReference__r.Make__c IN:setMakeCode];
         system.debug('lstProduct '+lstProduct );
       // List<gii__Warehouse__c> lstWarehouse = [Select id, name from gii__Warehouse__c where Name IN: setWarehouse];
       Map<String,List<gii__Warehouse__c>> mapWarehouseAndSorcGrp = new  Map<String,List<gii__Warehouse__c>>();
       for(gii__Warehouse__c objWarehouse : [Select id, name from gii__Warehouse__c where Name IN: setWarehouse]){
            if(mapSourcGrpAndWarehouse.containsKey(objWarehouse.name)){
                //mapWarehouseAndSorcGrp.put(objWarehouse.id,mapSourcGrpAndWarehouse.get(objWarehouse.name));
                if(mapWarehouseAndSorcGrp.containsKey(mapSourcGrpAndWarehouse.get(objWarehouse.name).name.substringBefore('-')) && mapWarehouseAndSorcGrp.get(mapSourcGrpAndWarehouse.get(objWarehouse.name).name.substringBefore('-')) != null) {
                    List<gii__Warehouse__c> lstWarehouse = mapWarehouseAndSorcGrp.get(mapSourcGrpAndWarehouse.get(objWarehouse.name).name.substringBefore('-'));
                    lstWarehouse.add(objWarehouse);
                    mapWarehouseAndSorcGrp.put(mapSourcGrpAndWarehouse.get(objWarehouse.name).name.substringBefore('-'),lstWarehouse); 
                }   
                else{
                    mapWarehouseAndSorcGrp.put(mapSourcGrpAndWarehouse.get(objWarehouse.name).name.substringBefore('-'), new List<gii__Warehouse__c> {objWarehouse});
                }
            }
        }
        system.debug('mapWarehouseAndSorcGrp'+mapWarehouseAndSorcGrp);
        Map<String,gii__AssignmentGroupRule__c> mapAssigRule = new Map<String,gii__AssignmentGroupRule__c>();
        for(gii__AssignmentGroupRule__c objAssignRule : [Select id, gii__Product__c,gii__SourcingGroup__c,gii__SourcingLevels__c,gii__TransferToWarehouse__c,gii__WarehouseNetwork__c from gii__AssignmentGroupRule__c where gii__AssignmentGroup__c='a1f0E000002YY8zQAG' LIMIT 100]){
            mapAssigRule.put(objAssignRule.gii__Product__c+'$'+objAssignRule.gii__TransferToWarehouse__c,objAssignRule);
        }
        system.debug('mapAssigRule'+mapAssigRule);
        List<gii__AssignmentGroupRule__c> lstAssRule = new List<gii__AssignmentGroupRule__c>();
        Map<String,String> mapProdAndSorcGrp = new  Map<String,String>();
        for(gii__Product2Add__c objProd :[Select id,gii__ProductReference__c,gii__ProductReference__r.Make__c from gii__Product2Add__c where gii__ProductReference__r.Make__c IN:setMakeCode LIMIT 200] ){
        system.debug('objProd '+objProd );
        system.debug('mapWarehouseAndSorcGrp'+mapWarehouseAndSorcGrp);
        system.debug('objProd.gii__ProductReference__r.Make__c'+objProd.gii__ProductReference__r.Make__c);
            if(mapWarehouseAndSorcGrp.containsKey(objProd.gii__ProductReference__r.Make__c)){
                for(gii__Warehouse__c objHouse :  mapWarehouseAndSorcGrp.get(objProd.gii__ProductReference__r.Make__c)){
                     system.debug('+++mapAssigRule'+mapAssigRule);
                     system.debug('+++objProd'+objProd.id+'$'+objHouse.id);
                    if(!mapAssigRule.containsKey(objProd.id+'$'+objHouse.id)){      
                        gii__AssignmentGroupRule__c objAssignRule = new gii__AssignmentGroupRule__c(gii__AssignmentGroup__c = 'a1f0E000002YY8zQAG',
                        gii__Product__c = objProd.id,
                        gii__TransferToWarehouse__c = objHouse.id,
                        gii__SourcingGroup__c = mapSourcGrp.get(objProd.gii__ProductReference__r.Make__c+'-'+objHouse.name).id,
                        gii__SourcingLevels__c = 'Global'
                        ); 
                        system.debug('+++objAssignRule'+objAssignRule);
                        lstAssRule.add(objAssignRule);
                    }
                }
            }
            if(mapSourcGrpAndMake.containsKey(objProd.gii__ProductReference__r.Make__c)){
                //mapProdAndSorcGrp.put(objProd.id,mapSourcGrpAndMake.get(objProd.gii__ProductReference__r.Make__c));
            }
        }
        system.debug('Name>>>>>>>>>>>>8 '+lstAssRule);
        system.debug('Name>>>>>>>>>>>>80 '+lstAssRule.size());
        if(lstAssRule.size() > 0){
            try{
                insert lstAssRule;
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Confirm, 'Successfull!!');
                ApexPages.addMessage(msg);
            }
            catch(exception e){
                system.debug('Error is due to '+e.getMessage());
                ApexPages.Message msgo = new ApexPages.Message(ApexPages.Severity.WARNING, 'Error Has Occured:-'+e.getMessage());
                ApexPages.addMessage(msgo);
            }
        }
        //List<gii__ProductInventory__c> lstProdInv = [Select id,gii__Product__c,gii__Warehouse__c from gii__ProductInventory__c where gii__Product__c IN:lstProduct AND gii__Warehouse__c IN:lstWarehouse];
        system.debug('Name>>>>>>>>>>>>4 '+lstProduct);
        system.debug('Name>>>>>>>>>>>>40 '+lstProduct.size());
      // system.debug('Name>>>>>>>>>>>>41 '+setProdName.size());
      //  system.debug('Name>>>>>>>>>>>>42 '+setProdName);
        
        
    }
}