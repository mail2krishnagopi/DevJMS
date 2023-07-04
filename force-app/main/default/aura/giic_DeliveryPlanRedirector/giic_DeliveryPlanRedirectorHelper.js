({
    gotoDeliveryPlan : function(component, event, helper) {
        var newEvent = $A.get("e.force:navigateToComponent");
        newEvent.setParams({
            componentDef: "c:giic_DeliveryPlanAction",
            componentAttributes: {
                supplyPlanRecordId : component.get("v.recordId"),//'aFE0D000000006iWAA',
                objectApiName : component.get("v.sObjectName") //'gii__SupplyPlanCycle__c' 
            }
        });
        newEvent.fire();

    }
})