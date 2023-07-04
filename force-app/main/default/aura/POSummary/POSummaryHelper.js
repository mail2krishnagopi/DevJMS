({
    removecss1 : function(cmp,event){
        var cmpTarget = cmp.find('Modalbox1');
        var cmpBack = cmp.find('MB-Back');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');        
    },   
    removecss2 : function(cmp,event){
        var cmpTarget = cmp.find('Modalbox2');
        var cmpBack = cmp.find('MB-Back');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');        
    }, 
    applycss3 : function(cmp,event){
        var cmpTarget = cmp.find('Modalbox3');
        //var cmpBack = cmp.find('MB-Back');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        //$A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    removecss3 : function(cmp,event){
        var cmpTarget = cmp.find('Modalbox3');
        //var cmpBack = cmp.find('MB-Back');
        //$A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');        
    },
    getDealerAccounts : function(component) {
        console.log('::::::::::::::PlaceOrder - HELPER - getDealerAccounts - START::::::::::::::');
        console.log("cmpParameters In summary helper::::"+JSON.stringify(component.get("v.purchaseOrder").gii__ShipTo__c));
        var accountId = component.get("v.accountId");
        var action = component.get("c.getInfo");
        action.setParams({ "accountId" : accountId,
                          "wareHouseId" : component.get("v.purchaseOrder").gii__ShipTo__c
                         });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
                if(responseValue != null){
                   
                    component.set("v.destributor", responseValue.parentAcc);
                    component.set("v.warehouseName", responseValue.parentAcc.warehouseName);
                        //  component.set("v.selectedDealer", responseValue.lstChild[0]);
                        component.set("v.dealerList", responseValue.lstChild);
                        
                        var totalAmt = 0;
                        console.log("::::::responseValue.parentAcc.prodList.length:::::::::::="+responseValue.parentAcc.prodList);
                        for (var i = 0; i < responseValue.parentAcc.prodList.length; i++) {
                            totalAmt += (responseValue.parentAcc.prodList[i].UnitPrice * responseValue.parentAcc.prodList[i].OrderQuantity);
                        }
                    	console.log('totalAmt::::'+totalAmt);
                    	component.set("v.totalAmtWithoutDisc",totalAmt);
                        var selectedDealer = component.get("v.selectedDealer");
                        totalAmt = totalAmt;// + (totalAmt * parseInt(selectedDealer.TaxAmt)/100);
                        component.set("v.totalAmt",totalAmt);
                        var percentAmt = component.get("v.percentAmt");
                        var percentPayAmt = (totalAmt*percentAmt)/100;
                        component.set("v.percentPayAmt",percentPayAmt);
                  
                }
            } 
            else{
                console.log("::::::error:::::::::::="+state);
            } 
        });
        $A.enqueueAction(action);
        console.log('::::::::::::::PlaceOrder - HELPER - getDealerAccounts - END::::::::::::::');        
    },
    removeFromCart : function(selectedProduct , component) {
        console.log('::::::::::::::PlaceOrder - HELPER - removeFromCart - START::::::::::::::');
        console.log('accountId:::'+accountId+'****'+JSON.stringify(selectedProduct));
        var accountId = component.get("v.accountId");
        var action = component.get("c.removeProductFromCart");
        
        action.setParams({ "accountId" : accountId,
                          "selectedProduct" : JSON.stringify(selectedProduct)});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
                if(responseValue != null){
                    component.set("v.destributor", responseValue.parentAcc);
                   
                        component.set("v.selectedDealer", responseValue.lstChild[0]);
                        component.set("v.dealerList", responseValue.lstChild);
                        
                        var totalAmt = 0;
                        for (var i = 0; i < responseValue.parentAcc.prodList.length; i++) {
                            totalAmt += (responseValue.parentAcc.prodList[i].UnitPrice * responseValue.parentAcc.prodList[i].OrderQuantity);
                        }
                    	console.log('totalAmt:::'+totalAmt);
                    	component.set("v.totalAmtWithoutDisc",totalAmt);
                        
                    	var discount = component.get("v.discount");
                        totalAmt = totalAmt - (totalAmt * parseInt(discount)/100); 
                        totalAmt = Math.round(totalAmt);
                     	component.set("v.totalAmt",totalAmt);
                        var percentAmt = component.get("v.percentAmt");
                        var percentPayAmt = (totalAmt*percentAmt)/100;
                        component.set("v.percentPayAmt",percentPayAmt);
                  
                }
            } 
            else{
                console.log("::::::error:::::::::::="+state);
            } 
        });
        $A.enqueueAction(action);
        console.log('::::::::::::::PlaceOrder - HELPER - removeFromCart - END::::::::::::::');
    },
    placePurchaseOrderHelper :function (component, event){
        var accountId = component.get("v.accountId");              
        var destributor = component.get("v.destributor");
        var dealerList = component.get("v.dealerList"); 
        console.log(':::::accountId = ' + accountId); 
        console.log(':::::destributor = ' + JSON.stringify(destributor)); 
        console.log(':::::dealerList = ' + JSON.stringify(dealerList)); 
        var action = component.get("c.purchaseOrderWithLines");
        action.setParams({ "accountId" : accountId,
                          "destributor" : JSON.stringify(destributor),
                          "dealerList" : JSON.stringify(dealerList)
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state-->'+state);
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ responseValue);
                
            } 
        });
        $A.enqueueAction(action);  
    },
    placeOrderHelper : function(component, event) {               
        var accountId = component.get("v.accountId");              
        var paymentMethod = component.get("v.paymentMethod");
        var paymentMethodId = component.get("v.paymentMethodId");        
        var destributor = component.get("v.destributor");
        var selectedDealer = component.get("v.selectedDealer");
        var discount = component.get("v.discount");        
        var selectedPayMethod = component.get("v.selectedPayMethod"); 
        var totalAmt = component.get("v.totalAmt");
        var percentAmt = component.get("v.percentAmt");
        var percentPayAmt = component.get("v.percentPayAmt");
        var customPayAmt = component.get("v.customPayAmt"); 
        console.log(':::::accountId = ' + accountId); 
        console.log(':::::paymentMethod = ' + paymentMethod); 
        console.log(':::::paymentMethodId = ' + paymentMethodId); 
        console.log(':::::destributor = ' + JSON.stringify(destributor)); 
        console.log(':::::selectedDealer = ' + JSON.stringify(selectedDealer)); 
        console.log(':::::discount = ' + discount); 
        console.log(':::::selectedPayMethod = ' + selectedPayMethod); 
        console.log(':::::totalAmt = ' + totalAmt); 
        console.log(':::::percentAmt = ' + percentAmt); 
        console.log(':::::percentPayAmt = ' + percentPayAmt); 
        console.log(':::::customPayAmt = ' + customPayAmt); 
        
        var action = component.get("c.purchaseOrderWithLines");
        action.setParams({ "accountId" : accountId,
                          //"paymentMethod" : paymentMethod,
                          //"paymentMethodId" : paymentMethodId,
                          "destributor" : JSON.stringify(destributor),
                          "discount" : discount,                          
                          "selectedPayMethod" : selectedPayMethod,                          
                          "totalAmt" : totalAmt,
                          "percentAmt" : percentAmt,
                          "percentPayAmt" : percentPayAmt,
                          "customPayAmt" : customPayAmt
                         });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state-->'+state);
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ responseValue);
                //if(responseValue == 'SUCCESS'){
                    //alert('Your Order is Placed Successfully...!');   
                    var accountId = component.get("v.accountId");
                    window.location = "/"+ responseValue.UrlPathPrefix + responseValue.recordId;
                /*}else{
                    alert('Please Check the Info and Try again...!');     
                }*/
            } else if (state == "ERROR"){
                var errors = action.getError();
                console.log("errors-->"+ JSON.stringify(errors) + "--errors.length="+ errors.length);
                if (errors != null && errors.length>0) {                    
                    if (errors[0] && errors[0].message) {                        
                        // Replace div body with the dynamic component
                        component.set("v.ErrorMsg", errors[0].message);
                    } else if (errors[0] && errors[0].pageErrors) {
                        // DML Error
                        // （This sample code is corner-cutting. It does not consider the errors in multiple records and fields.）
                        component.set("v.ErrorMsg", errors[0].pageErrors[0].message);
                    }
					this.applycss3(component, event);
                }
            }
        });
        $A.enqueueAction(action);      
    },
    
    updateCart: function(component, event, lstProd){
        console.log('::::::::::::::PlaceOrder - HELPER - addToCart - START::::::::::::::');
        var accountId = component.get("v.accountId");
        //var destributor = component.get("v.destributor");
        //var lstProd = destributor.prodList;
        var action = component.get("c.addProductsToCart");
        action.setParams({  
            "productlist" : JSON.stringify(lstProd),
            "accountId" : accountId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
            } else if (state == "ERROR"){
                var errors = action.getError();
                console.log("errors-->"+ JSON.stringify(errors) + "--errors.length="+ errors.length);
                if (errors != null && errors.length>0) {                    
                    if (errors[0] && errors[0].message) {                        
                        // Replace div body with the dynamic component
                        component.set("v.ErrorMsg", errors[0].message);
                    } else if (errors[0] && errors[0].pageErrors) {
                        // DML Error
                        // （This sample code is corner-cutting. It does not consider the errors in multiple records and fields.）
                        component.set("v.ErrorMsg", errors[0].pageErrors[0].message);
                    }
                    this.applycss3(component, event);
                }
            }
                else{
                    console.log("::::::error:::::::::::="+state);
                } 
        });
        $A.enqueueAction(action);
        console.log('::::::::::::::PlaceOrder - HELPER - addToCart - END::::::::::::::');
    },
    
})