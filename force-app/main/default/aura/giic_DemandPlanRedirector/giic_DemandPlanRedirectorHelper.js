({
    gotoPlan : function(component, event, helper) {
        var newEvent = $A.get("e.force:navigateToComponent");
        newEvent.setParams({
            componentDef: "c:giic_DemandPlanAction",
            componentAttributes: {
                cycleRecordId : component.get("v.recordId"),
                objectApiName : component.get("v.sObjectName")
            }
        });
        newEvent.fire();

    }
})