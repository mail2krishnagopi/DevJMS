({
    doInit : function(component, event, helper) {
        var getStages = component.get("c.getPurchaseOrderSteps");
        getStages.setParams({  
            "processName" : component.get("v.processName")
        }); 
        var processName = component.get("v.processName");
        getStages.setParams({ processName : processName });
        getStages.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var mp = response.getReturnValue();
                var stages = mp.ProcessSteps;
                console.log(':::stages::'+JSON.stringify(stages));
                component.set("v.stages", stages);
                if(stages != null){
                    var cmpParameters = component.get("v.cmpParameters");
                    $A.createComponent($A.get("$Label.c.Namespace") + ":" + stages[0].Page_Name, {
                        "cmpParameters": cmpParameters,
                        "nextStageName": stages[1].Step_Name,
                        "nextStageNumber": 2
                    }, function(newCmp) {
                        if (component.isValid()) {
                            console.log('component created');
                            component.set("v.body", newCmp);
                        }
                    });
                }else{
                    alert('There was an error retrieving the stages for this page.');
                }                
            }
            else{
                alert("There was an error retrieving the stages for this page.");
            }
        })
        $A.enqueueAction(getStages); 
    },    
    NavigateComponent : function(component, event, helper) {
        var cmpParameters = event.getParam("cmpParameters");
        var accountId = event.getParam("accountId");
      //  var accountName = event.getParam("accountName");
        var currentStageNumber = event.getParam("currentStageNumber");
        console.log("::NavigateComponent --> currentStageNumber: " + currentStageNumber);
        var stages = component.get("v.stages");
        component.set("v.currentStageNumber", currentStageNumber);
        
        console.log("::NavigateComponent --> stages: " + JSON.stringify(stages));
        var nextStageName = "";
        if((stages.length-1) >= currentStageNumber) nextStageName = stages[currentStageNumber].Step_Name;
        var nextStageNumber = currentStageNumber+1;        
        var cmpName = $A.get("$Label.c.Namespace") + ":" + stages[currentStageNumber-1].Page_Name;
        
        $A.createComponent(cmpName, {
            
            "cmpParameters": cmpParameters,
            "accountId" : accountId,
           // "accountName" : accountName,
            "nextStageName": nextStageName,
            "nextStageNumber": nextStageNumber
        }, function(newCmp) {
            if (component.isValid()) {
                component.set("v.body", newCmp);
            }
        });
    }    
})