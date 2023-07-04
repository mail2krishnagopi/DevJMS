({
	goToURL : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({                
            "url": "/new-sales-order",
            "isredirect":true
        });
        urlEvent.fire(); 	
	}
})