({
    itemAddedMessage : function() {
        var element = document.getElementById("itemAddedMessage");
        element.style.display = "block";
        //var delay = parseFloat($A.get("$Label.c.addedToCartMessageTime") * 1000) / 30;
        var delay = 30;
        var messageTime = parseFloat($A.get("$Label.c.addedToCartMessageTime")) * 1000;
        var cutoff = 0;
        var op = 1; 
        var timer = setInterval(function () {
            //if (op <= 0.1){
            //    clearInterval(timer);
            //    element.style.display = "none";
            //}
            if(cutoff >= messageTime){
                clearInterval(timer);
                element.style.display = "none";
                console.log(cutoff);
            }
            element.style.opacity = op;
            element.style.filter = "alpha(opacity=" + op * 100 + ")";
            cutoff += delay;
            op -= op * 0.02;
        }, delay);        
    },
    /*itemAddedMessage : function(){
        var toastEvent = $A.get("e.force:showToast");
        console.log(parseFloat($A.get("$Label.c.addedToCartMessageTime")));
        var fadeOutTime = parseInt(parseFloat($A.get("$Label.c.addedToCartMessageTime")) * 1000);
        console.log(fadeOutTime);
        toastEvent.setParams({
            mode : "dismissable",
            message : $A.get("$Label.c.itemAddedToCartMessage"),
            type : "success",
            duration : fadeOutTime
        });
        toastEvent.fire();
        
    },*/
    openAdvancedFilter : function() { 
        var advFilterPanel = document.getElementById('advFilterPanel');
        advFilterPanel.setAttribute('class','is-visible');
    },
    closeAdvancedFilter : function() { 
        var advFilterPanel = document.getElementById('advFilterPanel');
        advFilterPanel.removeAttribute('class','is-visible');
    },
    applyCSS: function(component){
        component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:0} .forceStyle.desktop .viewport{overflow:hidden}");
    },
    revertCssChange: function(component){
        component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:5} .forceStyle.desktop .viewport{overflow:visible}");
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
    OnLoadhelperMethod : function(component, event, searchText , offset, sortBy, alphaText) {
        console.log(':::::::::::::OnLoadhelperMethod-START:::::');   
        var action = component.get("c.onLoad");
        action.setParams({  
            "searchKey" : searchText,
            "offset"    : offset,
            "alphaText"    : alphaText,
            "sortBy" : sortBy,
            "prodFilter":null,
            "accountId" : component.get("v.accountId")
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("::OnLoadhelperMethod--> response"+JSON.stringify(response.getState()));
            if (state === "SUCCESS") {
                var returnItems = response.getReturnValue();
                console.log("response-->"+JSON.stringify(response.getReturnValue()));
                
                component.set("v.ProductWrapper", returnItems.prodList);
                //console.log("ProductWrapper-->"+JSON.stringify(component.get("v.ProductWrapper")));
                console.log("ProductWrapper.length-->"+JSON.stringify(component.get("v.ProductWrapper").length));
                component.set("v.resultSize", returnItems.resultSize);                
                //console.log("resultSize-->"+component.get("v.resultSize"));
                component.set("v.prodFilter", returnItems.prodFilter);
                component.set("v.favProductWrapper", returnItems.favProdList);
                component.set("v.topProductWrapper", returnItems.topProdList); 
                component.set("v.totalItems", returnItems.totalItems);
                /*****
                component.set("v.prodFamily", returnItems.prodFamilyList);
                component.set("v.prodPackaging", returnItems.prodPackagingList);
                component.set("v.prodTreatment", returnItems.prodTreatmentList); 
                *****/
                //  component.set("v.selectedProd", returnItems.prodList[0]);
                var e = $A.get("e.c:PaginationEvent");
                e.setParams({"totalResultSize": component.get("v.resultSize")});
                e.fire();  
                
            }else if (state == "ERROR"){
                var errors = action.getError();
                console.log("::OnLoadhelperMethod--> errors-->"+ JSON.stringify(errors) + "--errors.length="+ errors.length);
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
            }else{
                console.log("::OnLoadhelperMethod--> !!error!!"+state);
            }   
        });
        $A.enqueueAction(action); 
        console.log(':::::::::::::OnLoadhelperMethod-END:::::');   
    },
    searchMethod : function(component, event, searchText , offset, alphaText) {        
        /******
        var prodFamily = component.get("v.prodFamily");
        var prodPackaging = component.get("v.prodPackaging");
        var prodTreatment = component.get("v.prodTreatment");
        *******/
        var prodFilter = component.get("v.prodFilter");
        var action = component.get("c.clickedOnSearch");
        action.setParams({  
            "searchKey" : searchText,
            "offset"    : offset,
            "alphaText"    : alphaText,
            "prodFilter" : JSON.stringify(prodFilter),
            //"prodFamily" : JSON.stringify(prodFamily),
            //"prodPackaging" : JSON.stringify(prodPackaging),
            //"prodTreatment" : JSON.stringify(prodTreatment),
            "accountId" : component.get("v.accountId")
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("response"+JSON.stringify(response.getState()));
            if (state === "SUCCESS") {
                var returnItems = response.getReturnValue();
                console.log("response-->"+JSON.stringify(response.getReturnValue()));
                component.set("v.ProductWrapper", returnItems.prodList);
                console.log("ProductWrapper-->"+JSON.stringify(component.get("v.ProductWrapper")));
                component.set("v.resultSize", returnItems.resultSize);                
                console.log("resultSize-->"+component.get("v.resultSize"));
                
                var e = $A.get("e.c:PaginationEvent");
                e.setParams({"totalResultSize": component.get("v.resultSize")});
                e.fire();                
            }else{
                console.log("::OnLoadhelperMethod--> !!error!!"+state);
            }   
        });
        $A.enqueueAction(action);  
    },
    makeProductFavoriteHelper : function(component,event,productList){
        var action = component.get("c.makeProductFavourite");
        action.setParams({  
            "productWrapper" : JSON.stringify(productList)
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("before--response"+JSON.stringify(response.getState()));
            if (state === "SUCCESS") {              
                var e = component.getEvent("DumpEvent");//$A.get("e.c:DumpEvent");               
                e.fire();                
            }else{
                console.log("!!error!!"+state);
            }   
        });
        $A.enqueueAction(action); 
    },
    advanceSearch : function(component, event, searchText, offset, sortBy, alphaText) {        
        /************
        var prodFamily = component.get("v.prodFamily");
        var prodPackaging = component.get("v.prodPackaging");
        var prodTreatment = component.get("v.prodTreatment");
        ************/
        var prodFilter = component.get("v.prodFilter");
        var isAdSearch = component.get("v.isAdSearch");
        var action = component.get("c.clickedOnSearch");
        if(isAdSearch){           
            action.setParams({  
                "searchKey" : searchText,
                "offset"    : offset,
                "alphaText"    : alphaText,
                "sortBy" : sortBy,
                "prodFilter": JSON.stringify(prodFilter),
                //"prodFamily" : JSON.stringify(prodFamily),
                //"prodPackaging" : JSON.stringify(prodPackaging),
                //"prodTreatment" : JSON.stringify(prodTreatment),
                "accountId" : component.get("v.accountId")
            });              
        }else{           
             action.setParams({  
                "searchKey" : searchText,
                "offset"    : offset,
                "alphaText"    : alphaText,
                "sortBy" : sortBy,
                "prodFilter": null,
                //"prodFamily" : null,
                //"prodPackaging" : null,
                //"prodTreatment" : null,
                "accountId" : component.get("v.accountId")
            });   
        }      
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("response"+JSON.stringify(response.getState()));
            if (state === "SUCCESS") {
                var returnItems = response.getReturnValue();
                console.log("response-->"+JSON.stringify(response.getReturnValue()));
                component.set("v.ProductWrapper", returnItems.prodList);
                console.log("ProductWrapper-->"+JSON.stringify(component.get("v.ProductWrapper")));
                component.set("v.resultSize", returnItems.resultSize);                
                console.log("resultSize-->"+component.get("v.resultSize"));      
                
                var e = $A.get("e.c:PaginationEvent");
                e.setParams({"totalResultSize": component.get("v.resultSize")});
                e.fire();                
            }else{
                console.log("!!error!!"+state);
            }   
        });
        $A.enqueueAction(action);  
    }, 
      setSelectedProd : function(component, event){		     
        var index = event.currentTarget.dataset.index;    
        console.log(":::index:setSelectedProd::"+index);  
        component.set("v.selectedProdIndex",parseInt(index)); 
        component.set("v.selectedProdFrom",event.currentTarget.dataset.from);
        
        var productlist;
        if( component.get("v.selectedProdFrom")=="fp"){
            productlist = component.get("v.favProductWrapper");            
        }else{
            productlist = component.get("v.topProductWrapper");  
        }
        //  component.set("v.selectedProdQty",productlist[index].OrderQuantity);
        
        component.set("v.selProductWrapper",productlist[index]);
 
    },

})