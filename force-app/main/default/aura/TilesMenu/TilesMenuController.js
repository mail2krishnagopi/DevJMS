({
    doInit : function(component, event, helper) {
        var action = component.get("c.getData");
        action.setParams({ "menuType" : "Tiles Menu" });
        //console.log(menuType);      
        // action.setParams({ "detailViewFSName" : DetailViewFSName }); 
        action.setCallback(this,function(response){            
            var state = response.getState();             
            if (component.isValid() && state === "SUCCESS") { 
                var mapResult = response.getReturnValue();
                component.set("v.WrapperList", mapResult.menus); 
            }  
        });
        $A.enqueueAction(action);
    },
    goToURL : function(component, event, helper) {
        var WrapperList = component.get("v.WrapperList");
        var index = event.currentTarget.id;
        var URL = WrapperList[index].URL;
        var TabType = WrapperList[index].TabType;
        var baseUrl = window.location.origin;
        // window.location = baseUrl+'/'+URL;
        
        if(TabType.toUpperCase() == 'SOBJECT'){
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": URL
            });
            homeEvent.fire();
        }else{            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({                
                "url": URL,
                "isredirect":true
            });
            urlEvent.fire(); 
        }        
    }
})