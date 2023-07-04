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
    applycss3 : function(cmp,event){
        cmp.set("v.newDealer", 
                      {'sobjectType': 'Account',
                       'ParentId': '',
                       'Name': '',
                       'ShippingStreet': '',
                       'ShippingCity': '', 
                       'ShippingState': '',
                       'ShippingCountry': '',
                       'ShippingPostalCode': '',
                       'Phone': ''                        
                      });
        var cmpTarget = cmp.find('Modalbox3');
        var cmpBack = cmp.find('MB-Back');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    applycss4 : function(cmp,event){
        cmp.set("v.newDealer", 
                      {'sobjectType': 'Account',
                       'ParentId': '',
                       'Name': '',
                       'ShippingStreet': '',
                       'ShippingCity': '', 
                       'ShippingState': '',
                       'ShippingCountry': '',
                       'ShippingPostalCode': '',
                       'Phone': '' 
                      });
        var cmpTarget = cmp.find('Modalbox4');
        var cmpBack = cmp.find('MB-Back');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    removecss1 : function(component, event, helper){
        helper.removecss1(component, event);        
    },
    removecss2 : function(component, event, helper){
        helper.removecss2(component, event);        
    }, 
    removecss3 : function(component, event, helper){
        helper.removecss3(component, event);     
    }, 
     removecss4 : function(component, event, helper){
        helper.removecss4(component, event);     
    }, 
    doInit : function(component, event, helper) {
        console.log('::::::::::::::PlaceOrder - INIT - START::::::::::::::');
        //console.log('paymentMethod --> ' + component.get("v.paymentMethod"));
        console.log(':::cmpParameters='+ component.get("v.cmpParameters"));
        helper.getDealerAccounts(component);       
    }, 
    filterRecords: function(component,event,helper){
        var searchText = component.find("searchKey").get("v.value");
        helper.getFilterAccounts(component, searchText);
    },
     onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");      
        var forOpen = component.find("searchRes");        
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        console.log('getInputkeyWord:::'+getInputkeyWord);
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    clear :function(component,event,heplper){
        component.set("v.selectedDealer", null );
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
     handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONENT event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        console.log("Selected supplier record : " + JSON.stringify(selectedAccountGetFromEvent));
         
      //   helper.getDealerAccounts(component);
        component.set("v.selectedDealer", selectedAccountGetFromEvent );
        //component.set("v.selectedPriceBook", selectedAccountGetFromEvent)
    
     /*   var cmpParameters = component.get("v.cmpParameters");
         if($A.util.isEmpty(cmpParameters) || $A.util.isUndefined(cmpParameters)){
            var cmpParameters = new Object();
        }
   
        component.set("v.cmpParameters", cmpParameters); */
         
     
      
         var forclose = component.find("lookup-pill");
         $A.util.addClass(forclose, 'slds-show');
         $A.util.removeClass(forclose, 'slds-hide');
         
         var forclose = component.find("searchRes"); 
         $A.util.addClass(forclose, 'slds-is-close');
         $A.util.removeClass(forclose, 'slds-is-open');
         
         var lookUpTarget = component.find("lookupField");
         $A.util.addClass(lookUpTarget, 'slds-hide');
         $A.util.removeClass(lookUpTarget, 'slds-show'); 
         
    },
    onSelect: function(component, event, helper) { 
         console.log('onSelect-->');
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.record;        
        component.set("v.selectedDealer",null); 
        var selectedDealer = component.get("v.dealerList")[index];
        console.log('selectedDealer-->' + JSON.stringify(selectedDealer));
        component.set("v.selectedDealer",selectedDealer); 
        console.log('selectedDealer-->' + JSON.stringify(component.get("v.selectedDealer")));
      /*  var calTotalAmt = component.get('c.calTotalAmt');
        $A.enqueueAction(calTotalAmt);*/
    },    
    /* editDealerShipAdd : function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.record;
        var selectedDealer = component.get("v.dealerList")[index];
        console.log('selectedDealer-->' + JSON.stringify(selectedDealer));
        component.set("v.editDealerInfo",selectedDealer); 
        var calTotalAmt = component.get('c.calTotalAmt');
        $A.enqueueAction(calTotalAmt);
    },*/
    saveDistributerAcc : function(component, event, helper) { 
        var from = event.currentTarget.dataset.from;
        console.log("from-->"+from);
        helper.editDistributerAccount(component, event , from); 
        
        
    }, 
    /*  saveDealerAcc : function(component, event, helper) {  
        helper.editDealerAccount(component);     
    }, */
    calTotalAmt : function(component, event, helper) {  
        var destributor = component.get("v.destributor");
        var lstProd = destributor.prodList;
        var totalAmt = 0;
        for (var i = 0; i < lstProd.length; i++) {
            totalAmt += (lstProd[i].UnitPrice * lstProd[i].OrderQuantity);
        }
        var selectedDealer = component.get("v.selectedDealer");
        totalAmt = totalAmt + (totalAmt * parseInt(selectedDealer.TaxAmt)/100);
        var discount = component.get("v.discount");
        totalAmt = totalAmt - (totalAmt * parseInt(discount)/100); 
        totalAmt = Math.round(totalAmt);
        component.set("v.totalAmt",totalAmt);
        var percentAmt = component.get("v.percentAmt");
        var percentPayAmt = (totalAmt*percentAmt)/100;
        component.set("v.percentPayAmt",percentPayAmt);
    },
    changePayMethod : function(component, event, helper) {
        var event = $A.get("e.c:NavigateToCmp");
        event.setParams({
            "cmpName" : "GloviaLBDev1:Payment1",
            "accountId" : component.get("v.accountId"),
            "accountName" : component.get("v.accountName"),
            "totalItems" : component.get("v.totalItems"),
            "selectedDealer" : component.get("v.selectedDealer")
        });
        event.fire();
    },
    editBillAdd : function(component, event, helper) {
        var from = event.currentTarget.dataset.from;
        console.log("from-->"+from);
        var selectedDealer = component.get("v.selectedDealer");
        if(selectedDealer.BillingStreet == null || selectedDealer.BillingStreet.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Street"); return; }
        if(selectedDealer.BillingCity == null || selectedDealer.BillingCity.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter City"); return; }
        if(selectedDealer.BillingState == null || selectedDealer.BillingState.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter State"); return; }
        if(selectedDealer.BillingCountry == null || selectedDealer.BillingCountry.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Country"); return; }
        if(selectedDealer.BillingPostalCode == null || selectedDealer.BillingPostalCode.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter PostalCode"); return; }
        
        helper.editDistributerAccount(component, event, from);
    },
    editShipAdd : function(component, event, helper) {
        var from = event.currentTarget.dataset.from;
        console.log("from-->"+from);
        var selectedDealer = component.get("v.selectedDealer");
        if(selectedDealer.ShippingStreet == null || selectedDealer.ShippingStreet.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Street"); return false; }
        if(selectedDealer.ShippingCity == null || selectedDealer.ShippingCity.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter City"); return; }
        if(selectedDealer.ShippingState == null || selectedDealer.ShippingState.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter State"); return; }
        if(selectedDealer.ShippingCountry == null || selectedDealer.ShippingCountry.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Country"); return; }
        if(selectedDealer.ShippingPostalCode == null || selectedDealer.ShippingPostalCode.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter PostalCode"); return; }
        
        helper.editDistributerAccount(component, event, from);
    },
    saveNewDealerAcc : function(component, event, helper) {
        var from = event.currentTarget.dataset.from;
        console.log("from-->"+from);
        helper.saveNewDealerAcc(component, event, from);
    },
    saveNewAcc: function(component, event, helper) {
        var from = event.currentTarget.dataset.from;
        console.log("from-->"+from);
        helper.saveNewAcc(component, event, from);
    },
     backButton : function(component, event, helper) {
        var cmpParameters = component.get("v.cmpParameters");        
        if($A.util.isEmpty(cmpParameters) || $A.util.isUndefined(cmpParameters)){
            var cmpParameters = new Object();
        }
        cmpParameters.selectedDealer = component.get("v.selectedDealer");
        component.set("v.cmpParameters", cmpParameters);
        
        var event = $A.get("e.c:NavigateToCmp");
        event.setParams({                
            "accountId" : component.get("v.accountId"),        
            "cmpParameters" : component.get("v.cmpParameters"),
            "currentStageNumber": (component.get("v.nextStageNumber")-2)
        });
        event.fire();
    },  
    ContinueButton : function(component, event, helper) {
       
        var cmpParameters = component.get("v.cmpParameters");        
        if($A.util.isEmpty(cmpParameters) || $A.util.isUndefined(cmpParameters)){
            var cmpParameters = new Object();
        }
        cmpParameters.selectedLookUpRecord = component.get("v.selectedLookUpRecord");
        component.set("v.cmpParameters", cmpParameters);
        var selectedDealer = component.get("v.selectedDealer");
        
        var event = $A.get("e.c:NavigateToCmp");
        event.setParams({            
            "accountId" : selectedDealer != null ? selectedDealer.Id : '' ,
            "cmpParameters" : component.get("v.cmpParameters"),
			"currentStageNumber": component.get("v.nextStageNumber")
        });
        event.fire();         
    },
    CancelButton : function(component, event, helper) {
        var accountId = component.get("v.accountId");
        console.log("::::accountId:::"+accountId);
        window.location = "/"+accountId;        
    },        
})