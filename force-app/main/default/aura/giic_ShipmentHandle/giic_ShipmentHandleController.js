({
    
  
    handleUpdateRecord: function(component, event, helper) {
    var message = event.getParam("message");
    var isSuccess = event.getParam("isSuccess");
        console.log('This is from Como'+message);
        
        if (isSuccess) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        "title": "Success!",
        "message": message,
        "type": "success"
      });
      toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();      
    }
    },
    
    handleErrorRecord : function(component, event, helper) {
        var message = event.getParam("message");
         var isSuccess = event.getParam("isSuccess");
        console.log('Testing this'+message);
        
              var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        "title": "Error In Processing !",
        "message": message,
        "type": "error"
      });
      toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
        // Calling apex method
        // 
                    // Call Apex
             var action = component.get('c.updateErrorRecord');
            console.log('check this'+action);
                action.setParams({
            "shipment": component.get("v.recordId"),
            "message": message 
        });  
            console.log('action is'+action);
        $A.enqueueAction(action);
        
       $A.get('e.force:refreshView').fire(); 

    },
    
    handleMissingFields : function(component, event, helper) {
        var message = event.getParam("message");
         var isSuccess = event.getParam("isSuccess");
        console.log('Testing this'+message);
        
        var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        "title": "Error Generated",
        "message": message,
        "type": "error"
      });
      toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    }
    
})