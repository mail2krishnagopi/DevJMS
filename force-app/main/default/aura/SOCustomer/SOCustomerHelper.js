({
    getFilterAccounts: function(component, searchText) {         
        var isExternalUser = component.get("v.isExternalUser");
        var action = component.get("c.getFilterAccounts");
        action.setParams({"searchText" : searchText});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
                
                
                if(responseValue != null){
                    console.log("responseValue.lstChild-->"+ JSON.stringify(responseValue.lstChild));
                  //  component.set("v.destributor", responseValue.parentAcc);
                    if(isExternalUser){
                        if(responseValue.lstChild.length > 0){   
                            var selectedDealer = component.get("v.selectedDealer");
                            console.log('selectedDealer-->'+selectedDealer);
                            if(selectedDealer == null){
                                component.set("v.selectedDealer", responseValue.lstChild[0]);
                                console.log('selectedDealer-->'+ JSON.stringify(component.get("v.selectedDealer")));
                            } 
                            component.set("v.dealerList", responseValue.lstChild);
                            
                            var accountId = component.get("v.accountId");
                            var dealerList = component.get("v.dealerList");
                            console.log('accountId --> ' + accountId);
                            
                            if(accountId != null){
                                for(var i = 0; i < dealerList.length; i++) {
                                    if(dealerList[i].Id == accountId){
                                        component.set("v.selectedDealer", dealerList[i]);
                                    }                
                                }            
                            }                          
                            
                            
                        }else{
                            //  component.set("v.isDealerError", true);
                            //  component.set("v.errorMsg", "Dealer Not Found...!");                    
                        }
                    }else{                         
                        var cmpParameters = component.get("v.cmpParameters");        
                        if(cmpParameters != null && !$A.util.isEmpty(cmpParameters) && !$A.util.isUndefined(cmpParameters)){
                            if(!$A.util.isEmpty(cmpParameters.selectedLookUpRecord) && !$A.util.isUndefined(cmpParameters.selectedLookUpRecord))component.set("v.selectedLookUpRecord", cmpParameters.selectedLookUpRecord);
                           // console.log('::selectedLookUpRecord:::' + cmpParameters.selectedLookUpRecord.Name); 
                        }                            
                    }
                }
            } 
            else{
                console.log("::::::error:::::::::::="+state);
            } 
        });
        $A.enqueueAction(action);
    },
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
              
        var action = component.get("c.fetchAccounts");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'objectName' : component.get("v.objectAPIName")           
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('::storeResponse:::' + JSON.stringify(storeResponse));
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    getDealerAccounts : function(component) {
        console.log('::::::::::::::PlaceOrder - HELPER - getDealerAccounts - START::::::::::::::');
        var accountId = component.get("v.selectedLookUpRecord").Id;
        var isExternalUser = component.get("v.isExternalUser");
        
        var action = component.get("c.getInfo");
        action.setParams({"accountId" : accountId,
                          "isExternalUser" : isExternalUser                         
                         });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
                
                
                if(responseValue != null){
                    component.set("v.mapAccFieldLables", responseValue.mapAccFieldLables);
                    console.log("responseValue.lstChild-->"+ JSON.stringify(responseValue.lstChild));
                    console.log("Selected Dealer-->"+ JSON.stringify(component.get("v.selectedDealer")));
                    component.set("v.destributor", responseValue.parentAcc);
                    if(isExternalUser){
                        if(responseValue.lstChild.length > 0){   
                            var selectedDealer = component.get("v.selectedDealer");
                            console.log('selectedDealer-->'+selectedDealer);
                            if(selectedDealer == null){
                                component.set("v.selectedDealer", responseValue.lstChild[0]);
                                console.log('selectedDealer-->'+ JSON.stringify(component.get("v.selectedDealer")));
                            } 
                            component.set("v.dealerList", responseValue.lstChild);
                            
                            var accountId = component.get("v.accountId");
                            var dealerList = component.get("v.dealerList");
                            console.log('accountId --> ' + accountId);
                            
                            if(accountId != null){
                                for(var i = 0; i < dealerList.length; i++) {
                                    if(dealerList[i].Id == accountId){
                                        component.set("v.selectedDealer", dealerList[i]);
                                    }                
                                }            
                            }                          
                            
                            
                        }else{
                            //  component.set("v.isDealerError", true);
                            //  component.set("v.errorMsg", "Dealer Not Found...!");                    
                        }
                    }else{    
                         console.log('In isExternalUser False  --> ');
                        var cmpParameters = component.get("v.cmpParameters");        
                        if(cmpParameters != null && !$A.util.isEmpty(cmpParameters) && !$A.util.isUndefined(cmpParameters)){
                            if(!$A.util.isEmpty(cmpParameters.selectedLookUpRecord) && !$A.util.isUndefined(cmpParameters.selectedLookUpRecord))
                            {
                                var compEvent = component.getEvent("oSelectedAccountEvent");
                                compEvent.setParams({"recordByEvent" : cmpParameters.selectedLookUpRecord });  
                                compEvent.fire();
                            }
                        }                            
                    }
                }
            } 
            else{
                console.log("::::::error:::::::::::="+state);
            } 
        });
        $A.enqueueAction(action);
        console.log('::::::::::::::PlaceOrder - HELPER - getDealerAccounts - END::::::::::::::');        
    },
    editDistributerAccount : function(component , event, from) {
        console.log('::::::::::::::PlaceOrder - HELPER - editDistributerAccount - START::::::::::::::');
        var selectedDealer = component.get("v.selectedDealer");
        
        var action = component.get("c.editDistributorAccount");
        action.setParams({ "destributorAcc" : selectedDealer });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
                if(responseValue != null){                    
                    component.set("v.selectedDealer", selectedDealer);
                } 
                else{
                    console.log("::::::error:::::::::::="+state);
                }
                
                if(from == "s"){
                    this.removecss1(component , event);
                }else if(from == "b"){
                    this.removecss2(component , event);
                }                    
            }
        });
        $A.enqueueAction(action);
        console.log('::::::::::::::PlaceOrder - HELPER - editDistributerAccount - END::::::::::::::');     
    },    
    /*  editDealerAccount : function(component) {
        console.log('::::::::::::::PlaceOrder - HELPER - editDealerAccount - START::::::::::::::');
        var dealerAcc = component.get("v.editDealerInfo");
        var action = component.get("c.editDealerAccount");
        action.setParams({ "dealerAcc" : dealerAcc });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
                if(responseValue.length > 0){   
                    component.set("v.selectedDealer", responseValue[0]);
                    component.set("v.dealerList", responseValue);
                }else{
                    component.set("v.isDealerError", true);
                    component.set("v.errorMsg", "Dealer Not Found...!");                    
                } 
            }
        });
        $A.enqueueAction(action);
        console.log('::::::::::::::PlaceOrder - HELPER - editDealerAccount - END::::::::::::::');     
    },*/
    saveNewDealerAcc :  function(component, event, from) {  
        var newDealer = component.get("v.newDealer");
        
        if(newDealer.Name == null || newDealer.Name.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Name"); return; }
        if(newDealer.ShippingStreet == null || newDealer.ShippingStreet.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Street"); return; }
        if(newDealer.ShippingCity == null || newDealer.ShippingCity.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter City"); return; }
        if(newDealer.ShippingState == null || newDealer.ShippingState.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter State"); return; }
        if(newDealer.ShippingCountry == null || newDealer.ShippingCountry.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Country"); return; }
        if(newDealer.ShippingPostalCode == null || newDealer.ShippingPostalCode.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter PostalCode"); return; }
        if(newDealer.Phone == null || newDealer.Phone.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Phone Number"); return; }
        
        
        var accountId = component.get("v.selectedLookUpRecord").Id;
        var isExternalUser = component.get("v.isExternalUser");
        // newDealer.ParentId = accountId;
        var action = component.get("c.addNewDealer");
        action.setParams({ "newDealer" : newDealer,
                          "accountId" : accountId,
                          "isExternalUser"  : isExternalUser                       
                         });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                //alert('New Address Added Successfully...!');   
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
                if(responseValue != null){
                    console.log("responseValue.lstChild-->"+ JSON.stringify(responseValue.lstChild));
                    component.set("v.destributor", responseValue.parentAcc);
                    component.set("v.dealerErrorMsg", "");
                    if(isExternalUser){
                        if(responseValue.lstChild.length > 0){   
                            component.set("v.selectedDealer", responseValue.lstChild[0]);
                            component.set("v.dealerList", responseValue.lstChild);
                            
                            var totalAmt = 0;
                            for (var i = 0; i < responseValue.parentAcc.prodList.length; i++) {
                                totalAmt += (responseValue.parentAcc.prodList[i].UnitPrice * responseValue.parentAcc.prodList[i].OrderQuantity);
                            }
                            var selectedDealer = component.get("v.selectedDealer");
                            totalAmt = totalAmt + (totalAmt * parseInt(selectedDealer.TaxAmt)/100);
                            component.set("v.totalAmt",totalAmt);
                            var percentAmt = component.get("v.percentAmt");
                            var percentPayAmt = (totalAmt*percentAmt)/100;
                            component.set("v.percentPayAmt",percentPayAmt);
                        }else{
                            component.set("v.isDealerError", true);
                            component.set("v.errorMsg", "Dealer Not Found...!");                    
                        }
                    }
                }
                if(from == "n"){
                    this.removecss3(component , event);
                } 
            } 
            else{
                console.log("::::::error:::::::::::="+state);
            } 
        });
        $A.enqueueAction(action); 
    },
    saveNewAcc:  function(component, event, from) {  
        var newDealer = component.get("v.newDealer");
        
        if(newDealer.Name == null || newDealer.Name.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Name"); return; }
        if(newDealer.ShippingStreet == null || newDealer.ShippingStreet.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Street"); return; }
        if(newDealer.ShippingCity == null || newDealer.ShippingCity.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter City"); return; }
        if(newDealer.ShippingState == null || newDealer.ShippingState.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter State"); return; }
        if(newDealer.ShippingCountry == null || newDealer.ShippingCountry.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Country"); return; }
        if(newDealer.ShippingPostalCode == null || newDealer.ShippingPostalCode.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter PostalCode"); return; }
        if(newDealer.Phone == null || newDealer.Phone.trim() ==''){ component.set("v.isReqMissing",true);component.set("v.reqErrorMsg","Please enter Phone Number"); return; }
        
        var accountId = component.get("v.selectedLookUpRecord").Id;
        var isExternalUser = component.get("v.isExternalUser");
        // newDealer.ParentId = accountId;
        var action = component.get("c.addNewAcc");
        action.setParams({ "newDealer" : newDealer });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){                                 
                //alert('New Address Added Successfully...!');   
                var responseValue = response.getReturnValue();
                console.log("responseValue-->"+ JSON.stringify(responseValue));
                if(responseValue != null){
                    console.log(':::newDealer:::' + responseValue);
                    component.set("v.selectedDealer", responseValue );
                    var compEvent = component.getEvent("oSelectedAccountEvent");
                    compEvent.setParams({"recordByEvent" : responseValue });  
                    compEvent.fire();
                }
                if(from == "n"){
                    this.removecss4(component , event);
                } 
            } 
            else{
                console.log("::::::error:::::::::::="+state);
            } 
        });
        $A.enqueueAction(action); 
    },
    removecss1 : function(cmp,event){
        cmp.set("v.isReqMissing",false);
        cmp.set("v.reqErrorMsg",""); 
        var cmpTarget = cmp.find('Modalbox1');
        var cmpBack = cmp.find('MB-Back');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');  
        this.getDealerAccounts(cmp);
    },
    removecss2 : function(cmp,event){
        cmp.set("v.isReqMissing",false);
        cmp.set("v.reqErrorMsg","");
        var cmpTarget = cmp.find('Modalbox2');
        var cmpBack = cmp.find('MB-Back');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        this.getDealerAccounts(cmp);
    },
    removecss3 : function(cmp,event){
        cmp.set("v.isReqMissing",false);
        cmp.set("v.reqErrorMsg","");
        var cmpTarget = cmp.find('Modalbox3');
        var cmpBack = cmp.find('MB-Back');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');        
    },
    removecss4 : function(cmp,event){
        cmp.set("v.isReqMissing",false);
        cmp.set("v.reqErrorMsg","");
        var cmpTarget = cmp.find('Modalbox4');
        var cmpBack = cmp.find('MB-Back');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');        
    }
})