({
    doInit : function(component, event, helper) {
        var action = component.get("c.getData");
        // action.setParams({ "detailViewFSName" : DetailViewFSName }); 
        action.setCallback(this,function(response){            
            var state = response.getState();             
            if (component.isValid() && state === "SUCCESS") {                
                var returnItems = response.getReturnValue();
                console.log(returnItems);                
                component.set("v.RecentlyViewed", returnItems); 
            }  
        });
        $A.enqueueAction(action);
    },
    redirectTo : function(component, event, helper) {
        var RecentlyViewed = component.get("v.RecentlyViewed");
        var index = event.currentTarget.id;
        var Id = RecentlyViewed[index].Id;
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({                
            "recordId": Id                
        });
        urlEvent.fire(); 
    }
})