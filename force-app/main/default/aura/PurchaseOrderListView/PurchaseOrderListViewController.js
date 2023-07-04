({
	goToURL : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({                
            "url": "/new-purchase-order",
            "isredirect":true
        });
        urlEvent.fire(); 	
	}
})