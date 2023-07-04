trigger giic_PicklistDetailAFterInsert on gii__PickListDetail__c (after insert) {
   /* Set<Id> parentIds = new Set<Id>();
    for (gii__PickListDetail__c child : Trigger.new) {
        parentIds.add(child.gii__PickList__c);
    }
    List<gii__PickList__c> parentsToUpdate = new List<gii__PickList__c>();
    for (Id parentId : parentIds) {
        gii__PickList__c parent = new gii__PickList__c(Id = parentId);
        parent.giic_No_of_Child_Records__c = [SELECT COUNT() FROM gii__PickListDetail__c WHERE gii__PickList__c = :parentId];
        parentsToUpdate.add(parent);
    }
  //  update parentsToUpdate;*/
}