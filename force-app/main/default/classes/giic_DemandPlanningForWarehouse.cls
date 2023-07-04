/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-31-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class giic_DemandPlanningForWarehouse implements Database.Batchable < sObject >,Database.stateful,Schedulable {
    public Map<id,Decimal> prodtoTol = new Map<Id,Decimal>();
    public Map<Id,gii__ProductInventory__c> prodInv = new Map<Id,gii__ProductInventory__c>();
    public Map<String,string> whrsIdsToToCre = new Map<String,string>();
    //public List<String> lstWarehouse = Label.giic_DcWarehouses.split(',');//Wylie and Manifold Warehouse
    public List<String> lstWarehouse = new List<string>();
    public Database.QueryLocator start(Database.BatchableContext BC) {
        List<gii__Warehouse__c> excludeWhs = [Select Id,Name From gii__Warehouse__c Where gii__WarehouseGroup__r.Name = 'Distribution Center'];
        for(gii__Warehouse__c exWh : excludeWhs){
				  lstWarehouse.add(exWh.Name);     
        }
        // String query =' select id,Name,gii__Product__c,gii__Warehouse__c,gii__Warehouse__r.Name, gii__BinLocation__c , gii__Product__r.gii__PrimarySupplier__c from gii__ProductInventory__c where gii__Warehouse__r.Name NOT IN:lstWarehouse';
    String query ='select id,Name from gii__Warehouse__c where Name NOT IN:lstWarehouse ';//All Warehouses except Wylie and Manifold
       //String query ='select id,Name from gii__Warehouse__c where Id= \'a5c3C0000003g9pQAA\' ';
       // List<string> testWarehouse= new List<string>{'E & S - JMS Warehouse','E & S - JMS Wh'};       
       //String query ='select id,Name from gii__Warehouse__c where Name IN :testWarehouse';//adding this for testing      
        system.debug('+++query'+query);   
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List < gii__Warehouse__c > scope) {
        Set<Id> whrsIds = new Set<Id>();
        for(gii__Warehouse__c whrs : scope){
            whrsIds.add(whrs.Id);
        }
        system.debug('+++whrsIds'+whrsIds);
       // whrsIdsToToCre = new Set<String>();
        //whrsIds-To collect the warehouse ID's
        
        List<gii__ProductInventory__c> lstProdInvToProc = new List<gii__ProductInventory__c>();
        prodInv = new Map<Id,gii__ProductInventory__c>( [Select Id,Name,gii__Product__c,gii__Product__r.giic_DefaultReplenishmentWarehouse__c,gii__OrderPointQuantity__c,gii__Warehouse__c,gii__AvailableQuantity__c,gii__TotalOnOrder__c,gii__MinimumOrderQuantity__c,gii__OrderQuantityMultiple__c FROM gii__ProductInventory__c WHERE gii__Warehouse__c IN :  whrsIds AND gii__Product__r.gii__Service__c = false ]); //except service products
        //prodInv = new Map<Id,gii__ProductInventory__c>([Select Id,Name,gii__Product__c,gii__Product__r.giic_DefaultReplenishmentWarehouse__c,gii__OrderPointQuantity__c,gii__Warehouse__c,gii__AvailableQuantity__c,gii__TotalOnOrder__c,gii__MinimumOrderQuantity__c,gii__OrderQuantityMultiple__c FROM gii__ProductInventory__c WHERE Id = 'a313C000000Fgq4QAC' ]);
          system.debug('+++prodInv'+prodInv);
        for(gii__ProductInventory__c prdInvTo :  prodInv.values()){
            Decimal suggQntVal = 0;
            Decimal totQuntyAv = prdInvTo.gii__AvailableQuantity__c + prdInvTo.gii__TotalOnOrder__c;
            //check if eligible to creata TO and TOL
            if(totQuntyAv < prdInvTo.gii__OrderPointQuantity__c){
                Decimal minQntChk = prdInvTo.gii__OrderPointQuantity__c - totQuntyAv;
                Integer reminderVal = 0;
                if(prdInvTo.gii__OrderQuantityMultiple__c > 0){
                    reminderVal = Math.mod(Integer.valueOf(minQntChk),Integer.valueOf(prdInvTo.gii__OrderQuantityMultiple__c));
                }
                if(minQntChk >= prdInvTo.gii__MinimumOrderQuantity__c && reminderVal == 0 ){
                    suggQntVal = minQntChk;
                }else if(minQntChk >= prdInvTo.gii__MinimumOrderQuantity__c && reminderVal > 0){
                    suggQntVal = gettoqntity(prdInvTo,minQntChk);
                }else if(minQntChk < prdInvTo.gii__MinimumOrderQuantity__c && reminderVal == 0 && prdInvTo.gii__OrderQuantityMultiple__c == 0){
                    suggQntVal =  prdInvTo.gii__MinimumOrderQuantity__c;
                }else if(minQntChk < prdInvTo.gii__MinimumOrderQuantity__c && reminderVal == 0){
                    suggQntVal = gettoqntity(prdInvTo,prdInvTo.gii__MinimumOrderQuantity__c);
                }else if(minQntChk < prdInvTo.gii__MinimumOrderQuantity__c && reminderVal > 0){
                    suggQntVal = gettoqntity(prdInvTo,prdInvTo.gii__MinimumOrderQuantity__c);
                }
               // if(suggQntVal > 0 && prdInvTo.gii__Product__r.giic_DefaultReplenishmentWarehouse__c != null){//null point 
                if(suggQntVal > 0){ 
                	prodtoTol.put(prdInvTo.Id,suggQntVal);//Map of productInv,suggestedQTy
                    system.debug('#####'+prdInvTo);
                    system.debug('#####'+prdInvTo.gii__Product__r.giic_DefaultReplenishmentWarehouse__c);
                    whrsIdsToToCre.put(prdInvTo.gii__Warehouse__c+'#'+prdInvTo.gii__Product__r.giic_DefaultReplenishmentWarehouse__c,prdInvTo.gii__Product__r.giic_DefaultReplenishmentWarehouse__c);// Set of Warehouses for which TO needs to be created
                    //converted set to map wh and make that to combnation of wh and defalut replenishment
                }
            }
        }
        
     system.debug('+++prodtoTol'+prodtoTol);    
        system.debug('+++whrsIdsToToCre'+whrsIdsToToCre);
    }
    public void finish(Database.BatchableContext BC) {
        List<Account>accID=[select id, name from Account where Name =:Label.giic_JMS_E_S_US_Account];//JMS Internal account used in TO creation
        List<gii__Warehouse__c> warhsfrom = [select id,Name from gii__Warehouse__c where Name IN:lstWarehouse]; //Wylie Warehouse
           // create list for Transfer Order 
        List<gii__TransferOrder__c> listTransferOrder = new List<gii__TransferOrder__c>();
        Map<string,Id>TransferOrderWhr =new Map<string,Id>();
        Map<string,List<string>> prodDef = new Map<string,List<string>>();
        for(string whrsId : whrsIdsToToCre.keyset()){
            gii__TransferOrder__c TransferOrder = new gii__TransferOrder__c();
            TransferOrder.gii__Account__c =accID[0].id; 
            //Account Id which is required. AccountId;
            TransferOrder.gii__OrderDate__c = System.today();
            system.debug('#$#$#$::'+whrsId);
            TransferOrder.gii__TransferToWarehouse__c  = whrsId.split('#')[0];//added values from map -what ever getting from set added the combination 
            TransferOrder.gii__FromWarehouse__c = whrsId.split('#')[1];
            //Add to the list for Transfer Order 
            listTransferOrder.add(TransferOrder);
        }
       system.debug('+++listTransferOrder'+listTransferOrder);
        // insert Transfer Order 
        if(listTransferOrder.Size()>0){
            Insert listTransferOrder;
            Set<Id> trsId = new Set<Id>();
           
                for(gii__TransferOrder__c trnsOrd : listTransferOrder){//make that to combnation of wh(from and To) and defalut replenishment
                    TransferOrderWhr.put(trnsOrd.gii__TransferToWarehouse__c+'#'+trnsOrd.gii__FromWarehouse__c,trnsOrd.Id);// Map of TO Warehouse, TO ID
            }
        
            // create list for Transfer Order Line
            Map<String,string> defReplTrsId = new Map<String,string>();
            List<gii__TransferOrderLine__c> listTOLine = new List<gii__TransferOrderLine__c>();
             for(string prdInvId : prodtoTol.keyset()){ //Iterate over Map of productInv,suggestedQTy
                 // create  Transfer Order Line sObject and populate its required fields
                gii__TransferOrderLine__c TOLine = new gii__TransferOrderLine__c();
                TOLine.gii__TransferOrder__c =TransferOrderWhr.get(prodInv.get(prdInvId).gii__Warehouse__c+'#'+prodInv.get(prdInvId).gii__Product__r.giic_DefaultReplenishmentWarehouse__c); //TransferOrdId; //TO Id which is required.//getting combination of from and TO
                TOLine.gii__Product__c = prodInv.get(prdInvId).gii__Product__c;//Product which is required.
                TOLine.gii__Quantity__c = prodtoTol.get(prdInvId); 
                listTOLine.add(TOLine);
            }
              system.debug('+++listTOLine'+listTOLine);
            if(listTOLine.size() > 0){
                insert listTOLine;
                system.debug('###::'+listTOLine);
            }
        }
    }
     
  //gettoqntity- Method to calculate the suggested quantity according to given inputs
  
    public static Decimal gettoqntity(gii__ProductInventory__c prdInvTo,Decimal minQntChk ){
        Decimal suggQntVal = 0;
        Integer reminderVal = 0;
        Decimal reminderValdou = 0;
        if(prdInvTo.gii__OrderQuantityMultiple__c > 0){
        reminderVal = Math.mod(Integer.valueOf(minQntChk),Integer.valueOf(prdInvTo.gii__OrderQuantityMultiple__c));//Math.mod to get the reminder value
        reminderValdou = minQntChk / prdInvTo.gii__OrderQuantityMultiple__c;//
        }
       Decimal totQuntyAvtd = prdInvTo.gii__AvailableQuantity__c + prdInvTo.gii__TotalOnOrder__c;
         Decimal minQntChkMinval = prdInvTo.gii__OrderPointQuantity__c - totQuntyAvtd;
        Decimal multiVal = Math.rint(reminderValdou);
     
        suggQntVal = multiVal * prdInvTo.gii__OrderQuantityMultiple__c;
        if(suggQntVal < prdInvTo.gii__MinimumOrderQuantity__c || suggQntVal < minQntChkMinval ){//If suggested quantity value is less than minimum value we are incrementing here.
           
            suggQntVal = (multiVal+1) * prdInvTo.gii__OrderQuantityMultiple__c;
        }
        system.debug('##suggQntVal:'+suggQntVal);
        return suggQntVal;
    }
    
    public void execute(SchedulableContext sc){  
        giic_DemandPlanningForWarehouse objSchBatch = new giic_DemandPlanningForWarehouse ();
        String schCorn= System.label.giic_TransOrderBatchCronExp;
        System.schedule('Create TO & TOL Batch', schCorn , objSchBatch);
        
    }
}