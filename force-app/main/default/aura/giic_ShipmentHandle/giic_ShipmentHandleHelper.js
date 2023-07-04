({
    sendShipment : function(component, event, helper) {
        

        
       /* var submitAction = component.get('c.sendShipmentDetails');
        submitAction.setParams({
            'shipmentId': component.get('v.recordId')
        });
        
        submitAction.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Inside submitAction callback function '+response.getReturnValue());
                var responseValue = response.getReturnValue();
                console.log('Response Value is'+responseValue);
                var toastEvent = $A.get("e.force:showToast");
                
                if (toastEvent) {
                    console.log("Toast event found");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Record was sent successfully."
                    });
                    toastEvent.fire();
                    console.log("Toast event fired");
                } else {
                    console.log("Toast event not found");
                }
                
            }
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
            
        });
        
        $A.enqueueAction(submitAction);
        */
    }
})