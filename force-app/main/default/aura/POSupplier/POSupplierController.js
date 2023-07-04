({
    doInit : function(component, event, helper) {
        var cmpParameters = component.get("v.cmpParameters");  
        var purchaseOrder = null;
        if(cmpParameters != null && !$A.util.isEmpty(cmpParameters) && !$A.util.isUndefined(cmpParameters)){
            if(!$A.util.isEmpty(cmpParameters.purchaseOrder) && !$A.util.isUndefined(cmpParameters.purchaseOrder)){
                component.set("v.purchaseOrder", cmpParameters.purchaseOrder);
                purchaseOrder = JSON.stringify(cmpParameters.purchaseOrder);
            }
        }
        
        console.log("PurchaseOrder : " + JSON.stringify(purchaseOrder));
        
        var action = component.get("c.getFieldSet");
        action.setParams({purchaseOrder : purchaseOrder});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.fieldSet", response.getReturnValue());
                console.log("fieldSet : " + JSON.stringify(response.getReturnValue()));
            }
            else{
                alert("There was an error retrieving the field set. State : " + state);
            }
        })

        $A.enqueueAction(action);
        
    },  
    cancelOrder : function(component, event, helper) {
        var accountId = component.get("v.accountId");
        window.location = "/"+accountId;
    }, 
    BackButton : function(component, event, helper) {
        var event = $A.get("e.GloviaLBDev1:giic_NavigateToCmp");
        var goToHomePage = component.get("v.currentStageNumber") == 1; 
        
        if(goToHomePage)
            window.location = "/" + component.get("v.accountId");  
        else{
            event.setParams({
                "cmpName" : "c:" + component.get("v.stages")[component.get("v.currentStageNumber") - 2].Page_Name,
                "accountId" : component.get("v.accountId"), 
                "accountName" : component.get("v.accountName")
            });
            event.fire(); 
        }
    }, 
    ContinueButton : function(component, event, helper) {
        var isValid = true;
        var accountObj = null;
        var fieldSet = component.get("v.fieldSet");
        var purchaseOrder = component.get("v.purchaseOrder");
        var accountId = '';
        var errorMessage = '';
        
        if(purchaseOrder == null){
            purchaseOrder = new Object();
        }
        for(var i = 0; i < fieldSet.length; i++){
            if(fieldSet[i].value != '' && fieldSet[i].value != undefined){
                if(fieldSet[i].type == "DATE"){
                    purchaseOrder[fieldSet[i].fieldPath] = fieldSet[i].value;
                }
                else{
                    if(fieldSet[i].fieldPath == "gii__Supplier__c"){
                        console.log("continueButton1");
                        accountId = fieldSet[i].value;
                        component.set("v.accountId", accountId);
                    }
                    purchaseOrder[fieldSet[i].fieldPath] = fieldSet[i].value;
                }
            }
            else{
                if(fieldSet[i].isRequired){
                    console.log("continueButton2");
                    errorMessage += 'Field ' + fieldSet[i].label + ' is required.\n';
                    isValid = false;
                }
            }            
        }
        console.log("purchaseOrder stringified" + JSON.stringify(purchaseOrder));
        
        if(isValid){                       
            var cmpParameters = component.get("v.cmpParameters");        
            if($A.util.isEmpty(cmpParameters) || $A.util.isUndefined(cmpParameters)){
                var cmpParameters = new Object();
            }
            
            cmpParameters.purchaseOrder = purchaseOrder;
            component.set("v.cmpParameters", cmpParameters);
            
            var event = $A.get("e.c:NavigateToCmp");
            event.setParams({
                "accountId" : accountId,
                "cmpParameters" : component.get("v.cmpParameters"),
                "nextStageName":  component.get("v.nextStageName"),
                "currentStageNumber": component.get("v.nextStageNumber")
            });
            event.fire(); 
        }
        else{
             var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "message": errorMessage
                        });
                        toastEvent.fire();
             //   alert(errorMessage);
        }
            
        
    },

    updatePriceBook : function(component, event, helper){
        var selectedItem = event.currentTarget;
        var lookupField = selectedItem.dataset.field;
        if(lookupField == "gii__Supplier__c"){
            var supplierId = selectedItem.dataset.value;
            var action = component.get("c.getPriceBook");
            action.setParams({selectedAccountId : supplierId});
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var fieldSet = component.get("v.fieldSet");
                    for(var i = 0; i < fieldSet.length; i++){
                        if(fieldSet[i].fieldPath == "gii__PriceBookName__c"){
                            fieldSet[i].value = response.getReturnValue();
                            break;
                        }
                    }
                    component.set("v.fieldSet", fieldSet);
                }
                else{
                    alert("There was an error retrieving the price book name.");
                }
            })
            $A.enqueueAction(action);
        }
    }
})