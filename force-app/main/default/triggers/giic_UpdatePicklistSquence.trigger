trigger giic_UpdatePicklistSquence on gii__PickListDetail__c (after insert) {
    
    if((trigger.isInsert)&&(trigger.isAfter)){
        set<id>  setPkId = new set<id>();
        for(gii__PickListDetail__c  pkd : trigger.new){
            if(pkd.gii__PickList__c != null){
                setPkId.add(pkd.gii__PickList__c);
            }
        }
        
        if(setPkId.size() > 0){
            system.debug('setPkId>>'+setPkId);
            list<gii__PickList__c> listPKList = [select id , name from gii__PickList__c where id =:setPkId];
            system.debug('listPKList>>'+listPKList);
            
            list<String> returnResult =giic_PickListController.updatePicklistDetailsObj(listPKList);
            system.debug('returnResult>>'+returnResult);
        }
    }
    
    
}