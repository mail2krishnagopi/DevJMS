({
    init : function(component, event, helper) {
        
        
        var eventHandler = function(response){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": $A.get("$Label.c.JMS_SpotFire_URL")
            });
            console.log('Utility Clicked! eventHandler response: ' + response);
            debugger;
            urlEvent.fire();
            debugger;
        };
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function(response){
            if(typeof response !=='undefined'){
                
                utilityAPI.getEnclosingUtilityId().then(function(utilityId){
                    
                    utilityAPI.onUtilityClick({ 
                        eventHandler: eventHandler 
                    }).then(function(result){
                        console.log('onUtilityClick: eventHandler result: ' + result);
                    }).catch(function(error){
                        console.log('onUtilityClick: eventHandler error: ' + error);
                    });                    
                })
                .catch(function(error){
                    console.log('do init: utilId error: ' + error);
                });
            }else{
                console.log('getAll Utility Info is undefined');
            }
        });
    }
})