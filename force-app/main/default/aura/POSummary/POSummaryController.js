({
     applycss1 : function(cmp,event){
        var cmpTarget = cmp.find('Modalbox1');
        var cmpBack = cmp.find('MB-Back');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    applycss2 : function(cmp,event){
        var cmpTarget = cmp.find('Modalbox2');
        var cmpBack = cmp.find('MB-Back');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    }, 
    removecss1 : function(cmp,event, helper){
        helper.removecss1(cmp, event);        
    },   
    removecss2 : function(cmp,event, helper){
       helper.removecss2(cmp, event);        
    },   
    removecss3 : function(cmp,event, helper){
       helper.removecss3(cmp, event);        
    },  
    doInit : function(component, event, helper) { 
        var cmpParameters = component.get("v.cmpParameters");        
       if(!($A.util.isEmpty(cmpParameters) && $A.util.isUndefined(cmpParameters))){
            if(!$A.util.isEmpty(cmpParameters.selectedDealer) && !$A.util.isUndefined(cmpParameters.selectedDealer))component.set("v.selectedDealer", cmpParameters.selectedDealer);
            if(!$A.util.isEmpty(cmpParameters.paymentMethod) && !$A.util.isUndefined(cmpParameters.paymentMethod))component.set("v.paymentMethod", cmpParameters.paymentMethod);
           if(!$A.util.isEmpty(cmpParameters.purchaseOrder) && !$A.util.isUndefined(cmpParameters.purchaseOrder))component.set("v.purchaseOrder", cmpParameters.purchaseOrder);
         //   if(!$A.util.isEmpty(cmpParameters.paymentMethodId) && !$A.util.isUndefined(cmpParameters.paymentMethodId))component.set("v.paymentMethodId", cmpParameters.paymentMethodId);
        }
        
        helper.getDealerAccounts(component,cmpParameters);            
    },
    ShowDetails: function(component, event, helper) {  
    	var record = event.currentTarget.dataset.record; 
        console.log(':::::::record:::::'+ record);
        var recordId = document.getElementById('section'+record);
        console.log(':::::::class:::::'+ recordId.getAttribute("class"));
        
        if(recordId.getAttribute("class") == 'slds-accordion__section'){
            recordId.setAttribute("class", "slds-accordion__section slds-is-open");
        }else if(recordId.getAttribute("class") == null){
            recordId.setAttribute("class", "slds-accordion__section slds-is-open");
        }else{
            recordId.setAttribute("class", "slds-accordion__section");   
        }
         
        
    },
    onSelect: function(component, event, helper) {       
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.record;
        var selectedDealer = component.get("v.dealerList")[index];
        console.log('selectedDealer-->' + JSON.stringify(selectedDealer));
        component.set("v.selectedDealer",selectedDealer); 
        var calTotalAmt = component.get('c.calTotalAmt');
        $A.enqueueAction(calTotalAmt);
    },   
   
    saveDistributerAcc : function(component, event, helper) {  
        var from = event.currentTarget.dataset.from;
        console.log("from-->"+from);
    }, 
    calTotalAmt : function(component, event, helper) {  
        var destributor = component.get("v.destributor");
        var lstProd = destributor.prodList;
        var totalAmt = 0;
        var totalAddproducts = 0;
        
        for (var i = 0; i < lstProd.length; i++) {
            lstProd[i].OrderQuantity = Math.floor(lstProd[i].OrderQuantity);
            totalAmt += (lstProd[i].UnitPrice * lstProd[i].OrderQuantity);
            totalAddproducts += (lstProd[i].UnitPrice * lstProd[i].OrderQuantity);
        }
        helper.updateCart(component, event, lstProd);        
        var selectedDealer = component.get("v.selectedDealer");
        totalAmt = totalAmt;// + (totalAmt * parseInt(selectedDealer.TaxAmt)/100);
        var discount = component.get("v.discount");
        console.log("discount : " + discount);
        
        if(isNaN(discount) || discount == null){
            discount = 0;
            component.set("v.discount", 0);
        }
        else if(discount > 100 || discount < 0){
            discount = 0;
            component.set("v.discount", 0);
            alert("Please enter a value between 0 and 100");
        }
        
        totalAmt = totalAmt - (totalAmt * parseInt(discount)/100); 
        totalAmt = Math.round(totalAmt);
        console.log("totalAmount : " + totalAmt);
        component.set("v.totalAmtWithoutDisc",totalAddproducts);
        component.set("v.totalAmt",totalAmt);
        //not applicable to PO
        var percentAmt = component.get("v.percentAmt");
        var percentPayAmt = (totalAmt*percentAmt)/100;
        component.set("v.percentPayAmt",percentPayAmt);
        component.set("v.destributor", destributor);
        
    }, 
    selectFullPayment : function(component, event, helper) {      
        var percentPay = component.find("percentPay");
        percentPay.set("v.value",false);
        var customPay = component.find("customPay");
        customPay.set("v.value",false);
        component.set("v.selectedPayMethod","fullPay");        
    },
    selectPercentPayment : function(component, event, helper) {
        var fullPay = component.find("fullPay");
        fullPay.set("v.value",false);
        var customPay = component.find("customPay");
        customPay.set("v.value",false); 
        component.set("v.selectedPayMethod","percentPay"); 
    },
    selectCustomPayment : function(component, event, helper) {
        var fullPay = component.find("fullPay");
        fullPay.set("v.value",false);
        var percentPay = component.find("percentPay");
        percentPay.set("v.value",false); 
        component.set("v.selectedPayMethod","customPay"); 
    },
    removeFromCart : function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.record;
        var selectedProduct = component.get("v.destributor.prodList")[index];
        console.log('selectedProduct-->' + JSON.stringify(selectedProduct));
        helper.removeFromCart(selectedProduct, component);
    },
    cancelOrder : function(component, event, helper) {
        var accountId = component.get("v.accountId");
        window.location = "/"+accountId; 
    },
    placeOrder : function(component, event, helper) {        
        helper.placeOrderHelper(component, event); 
    },
    placePurchaseOrder : function(component, event, helper) {     
        helper.placePurchaseOrderHelper(component, event); 
    }, 
    changePayMethod : function(component, event, helper) {
        var event = $A.get("e.GloviaLBDev1:giic_NavigateToCmp");
        event.setParams({
            "cmpName" : "GloviaLBDev1:giic_Payment_v2",
            "accountId" : component.get("v.accountId"),
            "accountName" : component.get("v.accountName")  
        });
        event.fire();
    },
    goHome : function(component, event, helper) {
        console.log('::::::::::::::HeaderComp - INIT - START::::::::::::::');
        window.location='giic_App.app?accId=' + component.get("v.accountId");     
        console.log('::::::::::::::HeaderComp - INIT - END::::::::::::::');        
    },
    backButton : function(component, event, helper) {
        var event = $A.get("e.c:NavigateToCmp");
        event.setParams({            
            "accountId" : component.get("v.accountId"),           
            "cmpParameters" : component.get("v.cmpParameters"),
			"currentStageNumber": (component.get("v.nextStageNumber")-2)          
        });
        event.fire();
    },
    makeEditable: function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.record;
        var prodList = component.get("v.destributor.prodList");
        prodList[index].isEditable = true;
        component.set("v.destributor.prodList",prodList);
    },
    makeNonEditable: function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.record;
        var prodList = component.get("v.destributor.prodList");
        prodList[index].isEditable = false;
        component.set("v.destributor.prodList",prodList);
    }
})