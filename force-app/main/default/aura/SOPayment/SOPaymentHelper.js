({
    Init : function(component) { 
        var accountId  = component.get("v.accountId");
        var action = component.get("c.getPaymentDetails");
        action.setParams({  
            "accountId" : accountId,
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("--response--"+JSON.stringify(response.getState()));
            if (state === "SUCCESS") {
                var returnItems = response.getReturnValue();
                console.log("response-->"+JSON.stringify(returnItems));
                component.set("v.PayWrapper", returnItems);
                component.set("v.CardExpiryMonth", returnItems.ListExpiryMonth);
                
                var tabId = '';
                if(returnItems.DefaultPaymentMethod == $A.get("$Label.c.SOCreditCard")){
                    tabId = '0';
                }else if(returnItems.DefaultPaymentMethod == $A.get("$Label.c.SOInvoice")){
                    tabId = '1';
                }else if(returnItems.DefaultPaymentMethod == $A.get("$Label.c.SOCash")){
                    tabId = '2';
                }else{
                    tabId = '2';
                }
                console.log("!!tabId!!"+tabId);
                component.set("v.tabId", tabId);
              //  component.find("tabs").set("v.selectedTabId", tabId);
                component.set("v.mapAccRefFieldLables", returnItems.mapAccRefFieldLables);
                var cmpParameters = component.get("v.cmpParameters"); 
                console.log(':::cmpParameters--' + JSON.stringify(cmpParameters));
                if(cmpParameters != null && !$A.util.isEmpty(cmpParameters) && !$A.util.isUndefined(cmpParameters)){
                    if(!$A.util.isEmpty(cmpParameters.tabId) && !$A.util.isUndefined(cmpParameters.tabId))component.set("v.tabId", cmpParameters.tabId);
                    if(!$A.util.isEmpty(cmpParameters.PayWrapper) && !$A.util.isUndefined(cmpParameters.PayWrapper))component.set("v.PayWrapper", cmpParameters.PayWrapper);
                } 
            }else{
                console.log("!!error!!"+state);
            }   
        });
        $A.enqueueAction(action);  
    },
 
})