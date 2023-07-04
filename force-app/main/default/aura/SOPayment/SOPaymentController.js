({
    doInit : function(component, event, helper) {
        var d = new Date();
    	var n = d.getFullYear();
        var yearsArr = new Array();
        for(var yr= n; yr<= (n+10); yr++)
            yearsArr.push(""+yr);
        component.set("v.CardExpiryYears",yearsArr);
        helper.Init(component);   
        
    },
    handleChange: function(component, event, helper) {       
        var tabId = component.get("v.tabId");  
        console.log(':::tabId--' + JSON.stringify(tabId));
        component.find("tabs").set("v.selectedTabId", tabId);
    },
    onSelectChange : function(component, event, helper) {
        var SelectedCardType = component.find("CardType").get("v.value");
        var PayWrapper = component.get("v.PayWrapper"); 
        PayWrapper.SelectedCardType = SelectedCardType;
        component.set("v.PayWrapper", PayWrapper);
    },
    ContinueButton : function(component, event, helper) {
        var cmpParameters = component.get("v.cmpParameters");        
        if($A.util.isEmpty(cmpParameters) || $A.util.isUndefined(cmpParameters)){
            var cmpParameters = new Object();
        }
        var PayWrapper = component.get("v.PayWrapper");
        console.log(':::PayWrapper--' + JSON.stringify(PayWrapper));
        cmpParameters.PayWrapper = PayWrapper;
        var tabId = component.get("v.tabId");
        cmpParameters.tabId = tabId;
       
        if(tabId == '0'){
            PayWrapper.SelectedPaymentMethod = $A.get("$Label.c.SOCreditCard");
            if(PayWrapper.SelectedCardType == null || PayWrapper.SelectedCardType.trim() == ''){ component.find("CardType").set("v.errors", [{message: $A.get("$Label.c.SOPleaseSelect") + " "+ $A.get("$Label.c.SOCardType")}]); return;}
            else{component.find("CardType").set("v.errors", null);}
            if(PayWrapper.NameOnCard == null || PayWrapper.NameOnCard.trim() == ''){ component.find("NameOnCard").set("v.errors", [{message: $A.get("$Label.c.SOPleaseEnter") + " "+ $A.get("$Label.c.SONameOnCard")}]); return;}
            else{component.find("NameOnCard").set("v.errors", null);}
            if($A.util.isEmpty(PayWrapper.NumberOnCard)){ component.find("NumberOnCard").set("v.errors", [{message:  $A.get("$Label.c.SOPleaseEnter") + " "+ $A.get("$Label.c.SOCardNumber") }]); return; }
            else{component.find("NumberOnCard").set("v.errors", null);}
            if($A.util.isEmpty(PayWrapper.CVV)){ component.find("CVV").set("v.errors", [{message: $A.get("$Label.c.SOPleaseEnter") + " "+ $A.get("$Label.c.SOcvv")}]); return;}
            else{component.find("CVV").set("v.errors", null);}
            if($A.util.isEmpty(PayWrapper.ExpiryMonth)){ component.find("ExpiryMonth").set("v.errors", [{message: $A.get("$Label.c.SOPleaseSelect") + " "+ $A.get("$Label.c.SOExpiryMonth") }]); return;}
            else{component.find("ExpiryMonth").set("v.errors", null);}
            if($A.util.isEmpty(PayWrapper.ExpiryYear)){ component.find("ExpiryYear").set("v.errors", [{message: $A.get("$Label.c.SOPleaseSelect") + " "+ $A.get("$Label.c.SOExpiryYear") }]); return;}
            else{component.find("ExpiryYear").set("v.errors", null);}
        }
        if(tabId == '1'){
            PayWrapper.SelectedPaymentMethod = $A.get("$Label.c.SOInvoice");
            if($A.util.isEmpty(PayWrapper.BankName)){ component.find("BankName").set("v.errors", [{message: $A.get("$Label.c.SOPleaseEnter") + " "+ component.get("v.mapAccRefFieldLables").gii__BankName__c }]); return; }
            else{component.find("BankName").set("v.errors", null);}
            if($A.util.isEmpty(PayWrapper.BankAccNumber)){ component.find("BankAccNumber").set("v.errors", [{message: $A.get("$Label.c.SOPleaseEnter") + " "+ component.get("v.mapAccRefFieldLables").gii__BankAccountNumber__c }]); return; }
            else{component.find("BankAccNumber").set("v.errors", null);}
        }
        if(tabId == '2'){
            PayWrapper.SelectedPaymentMethod = $A.get("$Label.c.SOCash");                   
        } 
       
        component.set("v.PayWrapper", PayWrapper);
        console.log(':::PayWrapper--' + JSON.stringify(PayWrapper));
        component.set("v.cmpParameters", cmpParameters);
        
        var event = $A.get("e.c:NavigateToCmp");
        event.setParams({            
            "accountId" : component.get("v.accountId"),
            "cmpParameters" : component.get("v.cmpParameters"),
            "currentStageNumber": component.get("v.nextStageNumber")
        });
        event.fire();
    },
    GoBackButton : function(component, event, helper) {   
      //  console.log(component.get("v.selectedPaymentOption"));
        
        var cmpParameters = component.get("v.cmpParameters");        
        if($A.util.isEmpty(cmpParameters) || $A.util.isUndefined(cmpParameters)){
            var cmpParameters = new Object();
        }
        cmpParameters.PayWrapper = component.get("v.PayWrapper");
        cmpParameters.tabId = component.get("v.tabId");
       
        component.set("v.cmpParameters", cmpParameters);
        
        var event = $A.get("e.c:NavigateToCmp");
        event.setParams({  
            "cmpParameters" : component.get("v.cmpParameters"),
            "accountId" : component.get("v.accountId"),
            "currentStageNumber": (component.get("v.nextStageNumber")-2)
        });
        event.fire();        
    },
    CancelButton : function(component, event, helper) {
        var accountId = component.get("v.accountId");
        console.log("::::accountId:::"+accountId);
        window.location = "/"+accountId;      
    },
})