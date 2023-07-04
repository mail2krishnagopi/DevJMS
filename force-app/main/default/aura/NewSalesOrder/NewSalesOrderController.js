({
    doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        var getStages = component.get("c.getStages");
        getStages.setParams({ processName : component.get("v.processName") });
        getStages.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var mp = response.getReturnValue();
                var stages = mp.ProcessSteps;
                //   var UserInfo = mp.UserInfo;
                var isExternalUser = mp.isExternalUser;
                //var accountId = '';
                //if(isExternalUser)  accountId = mp.accountId;
                //component.set("v.accountId", accountId);
                component.set("v.stages", stages);
                console.log('::NSO---> stages::::'+JSON.stringify(stages));
                component.set("v.isExternalUser", isExternalUser);              
                
                var cmpParameters = event.getParam("cmpParameters");
                $A.createComponent($A.get("$Label.c.Namespace") + ":" + stages[0].Page_Name, {
                    "processName" : component.get("v.processName"),
                    //"accountId": component.get("v.accountId"),
                    "isExternalUser" : component.get("v.isExternalUser"),
                    //  "accountName": UserInfo.Name,
                    "nextStageName": stages[1].Step_Name,
                    "nextStageNumber": 2,
                    "cmpParameters": cmpParameters
                }, function(newCmp) {
                    if (component.isValid()) {
                        console.log('component created');
                        component.set("v.body", newCmp);
                    }
                });
                
            }else if (state == "ERROR"){
                var errors = action.getError();
                console.log("::OnLoadhelperMethod--> errors-->"+ JSON.stringify(errors) + "--errors.length="+ errors.length);
                if (errors != null && errors.length>0) {                    
                    if (errors[0] && errors[0].message) {                        
                        // Replace div body with the dynamic component
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "error",
                            "title": "ERROR!",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    } else if (errors[0] && errors[0].pageErrors) {
                        // DML Error
                        // （This sample code is corner-cutting. It does not consider the errors in multiple records and fields.）
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "error",
                            "title": "ERROR!",
                            "message": errors[0].pageErrors[0].message
                        });
                        toastEvent.fire();
                    }
                }
            }else{
                alert("There was an error retrieving the stages for this page.");
            }
        })
        $A.enqueueAction(getStages); 
    },    
    NavigateComponent : function(component, event, helper) {
        console.log("::NavigateComponent::::");
        var processName = component.get("v.processName");
        var cmpParameters = event.getParam("cmpParameters");
        //var cmpName = event.getParam("cmpName");
        var accountId = event.getParam("accountId");
        if(accountId == null || accountId.trim() ==''){ 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "error",
                "title": "ERROR!",
                "message": "Please Select Customer."
            });
            toastEvent.fire();
            return; 
        }
        //var accountName = event.getParam("accountName");
        //var paymentMethod = event.getParam("paymentMethod");
        //var paymentMethodId = event.getParam("paymentMethodId");
        //var prodFamily = event.getParam("prodFamily");
        //var prodPackaging = event.getParam("prodPackaging");
        //var prodTreatment = event.getParam("prodTreatment");
        //var searchKey = event.getParam("searchKey");
        //var totalItems = event.getParam("totalItems");
        //var selectedDealer = event.getParam("selectedDealer");        
        var currentStageNumber = event.getParam("currentStageNumber");
        component.set("v.currentStageNumber", currentStageNumber);
        console.log("::NavigateComponent --> currentStageNumber: " + currentStageNumber);
        
        
        var stages = component.get("v.stages");
        console.log("::NavigateComponent --> stages: " + JSON.stringify(stages));
        var nextStageName = "";
        if((stages.length-1) >= currentStageNumber) nextStageName = stages[currentStageNumber].Step_Name;
        var nextStageNumber = currentStageNumber + 1;  
        console.log("::NavigateComponent --> nextStageNumber=" + nextStageNumber);
        var cmpName = $A.get("$Label.c.Namespace") + ":" + stages[currentStageNumber-1].Page_Name;
        console.log("::NavigateComponent --> nextStageName=" + nextStageName);
        $A.createComponent(cmpName, {
            "processName" : processName,
            "cmpParameters": cmpParameters,
            "accountId" : accountId,
            //"accountName" : accountName,  
            //"paymentMethod" : paymentMethod,
            //"paymentMethodId" : paymentMethodId,
            //"searchKey" : searchKey,
            //"prodFamily" : prodFamily,
            //"prodPackaging" : prodPackaging,
            //"prodTreatment" : prodTreatment,
            //"totalItems" : totalItems,
            //"selectedDealer" : selectedDealer,            
            "nextStageName": nextStageName,
            "nextStageNumber": nextStageNumber,
            "isExternalUser" : component.get("v.isExternalUser")
        }, function(newCmp) {
            if (component.isValid()) {
                component.set("v.body", newCmp);
            }
        });
    }    
})