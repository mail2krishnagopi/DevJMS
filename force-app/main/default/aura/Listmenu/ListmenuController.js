({
    doInit : function(component, event, helper) {
        var toggleText = component.find("text");
        $A.util.toggleClass(toggleText, "toggle");
        var url = window.location;
        var action = component.get("c.getData");
        action.setParams({ "menuType" : "List Menu",
                         	"url" : JSON.stringify(url)
                         });        
        action.setCallback(this,function(response){            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                               
                var mapResult = response.getReturnValue();
                console.log("mapResult:::::" + JSON.stringify(mapResult));
                component.set("v.WrapperList", mapResult.menus); 
                component.set("v.SelectedTab", mapResult.SelectedTab); 
                component.set("v.UrlPathPrefix", mapResult.UrlPathPrefix);
              //  helper.getTabValue(component);                              
            }
            else {
                console.log("Failed with state: " + state);
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
                "url": URL                
            });
            urlEvent.fire(); 
        }        
    },
    toggle : function(component, event, helper) {       
        var toggleText = component.find("text");
        $A.util.toggleClass(toggleText, "toggle");
    },
    goToHomeURL : function(component, event, helper) { 
        console.log("hi");
        var path = component.get("v.UrlPathPrefix"); 
        var hasPrefix = path.split("/")[0] == "null" ? false : true;
        console.log(path);
        if(hasPrefix){ 
            window.location.href = "/"+ path;
        }
        else{ 
            window.location.href = "/";
        }
            console.log("Page path is " + window.location.pathname);
        /*
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({                
            "url": "/"               
        });
        urlEvent.fire();
        */
    }
    
})