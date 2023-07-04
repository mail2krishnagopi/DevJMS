({
    
    openAdvancedFilter : function(component, event, helper) { 
        helper.openAdvancedFilter();
    },
    closeAdvancedFilter : function(component, event, helper) { 
        helper.closeAdvancedFilter();
    },
    
    doInit : function(component, event, helper) { 
        var cmpParameters = component.get("v.cmpParameters");  
        if(cmpParameters != null && !$A.util.isEmpty(cmpParameters) && !$A.util.isUndefined(cmpParameters)){
            if(!$A.util.isEmpty(cmpParameters.totalItems) && !$A.util.isUndefined(cmpParameters.totalItems))component.set("v.totalItems", cmpParameters.totalItems);
            if(!$A.util.isEmpty(cmpParameters.purchaseOrder) && !$A.util.isUndefined(cmpParameters.purchaseOrder))component.set("v.purchaseOrder", cmpParameters.purchaseOrder);
            //if(!$A.util.isEmpty(cmpParameters.selectedRecord) && !$A.util.isUndefined(cmpParameters.selectedRecord))component.set("v.selectedRecord", cmpParameters.selectedRecord);
		}
        var searchText = component.find("searchKey").get("v.value");
        var offset = 0; 
        var sortBy = component.find("sortByOption").get("v.value");
        helper.OnLoadhelperMethod(component, event, searchText, offset, sortBy, component.get("v.alphaText"));
	},    
    advanceSearch : function(component, event, helper){
        var searchText = component.find("searchKey").get("v.value");
        console.log("searchText-->"+ searchText);
        var offset = 0;
        var sortBy = null;//Open this line for keysearch + advance search  //component.find("sortByOption").get("v.value");
        helper.advanceSearch(component, event, searchText, offset, sortBy, null); 
    }, 
    searchByAlphabet : function(component, event, helper){
        var searchText = '';//Open this line for keysearch + searchByAlphabet  // component.find("searchKey").get("v.value");
        console.log("searchText-->"+ searchText);
        var alphaText = event.currentTarget.dataset.abcd;
        component.set("v.alphaText", alphaText);        
        console.log("aplhaText-->"+ alphaText);
        var offset = 0;
        //component.set("v.currentAlpha", alphaText);
        helper.searchMethod(component, event, searchText, offset, alphaText);        
    },     
    doPagination : function(component, event, helper) {
        //var cmpParameters = component.get("v.cmpParameters"); 
        var offset = event.getParam("offset"); 
        var searchText = component.find("searchKey").get("v.value");
        var action = component.get("c.getAdvanceSearch");
        action.setParams({  
            "searchKey" : searchText,
            "offset"    : offset,
            "accountId" : component.get("v.accountId")
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("response"+JSON.stringify(response.getState()));
            if (state === "SUCCESS") {
                var returnItems = response.getReturnValue();
                console.log("response-->"+JSON.stringify(response.getReturnValue()));
                component.set("v.ProductWrapper", returnItems);
            }else{
                console.log("!!error!!"+state);
            }   
        });
        $A.enqueueAction(action);  
        //console.log('----------Product Search --cmpParameters='+cmpParameters.cmpName); 
        console.log('::::::::::::::ProductSearch - INIT - END::::::::::::::');
    },    
    cancelOrder : function(component, event, helper) {
        var accountId = component.get("v.accountId");
        window.location = "/"+accountId;
    },   
    makeProductFavoriteFromFav : function(component, event, helper){        
        var productList = component.get("v.favProductWrapper");
        var index = event.currentTarget.id;
        console.log('::::index='+ index);         
        if(productList[index].isFavProduct == false){
            productList[index].isFavProduct = true;                                
        }
        else{
            productList[index].isFavProduct = false;                                   
        }
        console.log("productlist[index].isFavProduct-->"+productList[index].isFavProduct); 
        helper.makeProductFavoriteHelper(component,event,productList);        
    },
    makeProductFavoriteFromTop : function(component, event, helper){        
        var productList = component.get("v.topProductWrapper");
        var index = event.currentTarget.id;
        console.log('::::index='+ index);         
        if(productList[index].isFavProduct == false){
            productList[index].isFavProduct = true;                                
        }
        else{
            productList[index].isFavProduct = false;                                   
        }
        console.log("productlist[index].isFavProduct-->"+productList[index].isFavProduct);         
        helper.makeProductFavoriteHelper(component,event,productList);        
    },
    makeProductFavoriteFromList : function(component, event, helper){        
        var productList = component.get("v.ProductWrapper");
        var index = event.currentTarget.id;
        console.log('::::index='+ index);         
        if(productList[index].isFavProduct == false){
            productList[index].isFavProduct = true;                                
        }
        else{
            productList[index].isFavProduct = false;                                   
        }
        console.log("productlist[index].isFavProduct-->"+productList[index].isFavProduct);         
        helper.makeProductFavoriteHelper(component,event,productList);        
    },  
    /* handleRangeChangeTop : function(component, event, helper){	
        var orderQty = event.getParam("value");
        console.log("::handleRangeChangeTop--orderQty:::"+orderQty);
    }, */
    addToCartList : function(component, event, helper){		     
        var index = event.currentTarget.dataset.index;    
        console.log(":::addToCart-id:::"+index);
        var accountId = component.get("v.accountId");
        console.log("accountId:::"+accountId);
        var orderQty = component.get("v.ProductWrapper")[parseInt(index)].OrderQuantity;
        console.log("orderQty:::"+orderQty);
        
        
        var productlist = component.get("v.ProductWrapper");            
        var action = component.get("c.addProductsToCart");
        action.setParams({  
            "productlist" : JSON.stringify(productlist),
            "accountId" : accountId
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("response"+JSON.stringify(response.getState()));
            if (state === "SUCCESS") {
                var returnItems = response.getReturnValue();
                console.log("response-->"+JSON.stringify(response.getReturnValue()));  
                if(orderQty > 0){
                    helper.itemAddedMessage();
                }
                var e = component.getEvent("DumpEvent");                
                e.fire();
            }else if (state == "ERROR"){
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
					helper.applycss3(component, event);
                }
            }else{
                console.log("!!error!!"+state);
            }  
        });
        $A.enqueueAction(action);          
    },
    
    addToCart : function(component, event, helper){	
        var index =   component.get("v.selectedProdIndex");      
        console.log(":::addToCart-id:::"+index);
        var accountId = component.get("v.accountId");
        console.log("accountId:::"+accountId);
        
        var productlist;
        if( component.get("v.selectedProdFrom")=="fp"){
            productlist = component.get("v.favProductWrapper");            
        }else{
            productlist = component.get("v.topProductWrapper");  
        }
        
        var orderQty = component.get("v.selProductWrapper").OrderQuantity;//component.get("v.selectedProdQty");
        console.log("addToCart-orderQty:::"+orderQty);
        productlist[index].OrderQuantity = orderQty;        
        
        if(orderQty > 0){
            productlist[index].addToCart = true;            
        }
        else{
            productlist[index].addToCart = false;                       
        }
        if( component.get("v.selectedProdFrom")=="fp"){
            component.set("v.favProductWrapper",productlist);            
        }else{
            component.set("v.topProductWrapper",productlist);  
        }
        
        var productlist1;
        if( component.get("v.selectedProdFrom")=="fp"){
            productlist1 = component.get("v.favProductWrapper");            
        }else{
            productlist1 = component.get("v.topProductWrapper");  
        }          
        var action = component.get("c.addProductsToCart");
        action.setParams({  
            "productlist" : JSON.stringify(productlist1),
            "accountId" : accountId
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("response"+JSON.stringify(response.getState()));
            if (state === "SUCCESS") {
                var returnItems = response.getReturnValue();
                console.log("response-->"+JSON.stringify(response.getReturnValue()));  
                component.set("v.selectedProdQty",0);
                if(orderQty > 0){
                    helper.itemAddedMessage();
                }
                var e = component.getEvent("DumpEvent");
                e.fire();
            }else if (state == "ERROR"){
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
					helper.applycss3(component, event);
                }
            }  
        });
        $A.enqueueAction(action);     
    },
    clearQty : function(component, event, helper){	
        component.set("v.selectedProdQty",0);
    },
    goHome : function(component, event, helper) {
        console.log('::::::::::::::HeaderComp - INIT - START::::::::::::::');
        window.location='giic_App.app?accId=' + component.get("v.accountId");     
        console.log('::::::::::::::HeaderComp - INIT - END::::::::::::::');        
    },
    onSortByChange : function(component, event, helper) {
        var sortBy = component.find("sortByOption").get("v.value"); 
        var searchText = component.find("searchKey").get("v.value");
        console.log("searchText-->"+ searchText);
        var offset = 0;
        helper.advanceSearch(component, event, searchText, offset, sortBy, null);
    },
   /* showSideBar : function(component, event, helper) {
        var sideBar = document.getElementById('sideBar');
        sideBar.setAttribute('class','cd-panel from-right is-visible');
        helper.applyCSS(component);
    },*/
    closeSidebar : function(component, event, helper) {
        var sideBar = document.getElementById('sideBar');
        sideBar.setAttribute('class','cd-panel from-right');
        helper.revertCssChange(component);
    },
    BackButton : function(component, event, helper) {
        var event = $A.get("e.c:NavigateToCmp");
        
        var goToHomePage = (component.get("v.nextStageNumber")-1) == 1;         
        if(goToHomePage)
            window.location = "/" + component.get("v.accountId");  
        else{
            var cmpParameters = component.get("v.cmpParameters");        
            if($A.util.isEmpty(cmpParameters) || $A.util.isUndefined(cmpParameters)){
                var cmpParameters = new Object();
            }
            cmpParameters.totalItems = component.get("v.totalItems");
            component.set("v.cmpParameters", cmpParameters);
            
            event.setParams({
                "accountId" : component.get("v.accountId"), 
                //"accountName" : component.get("v.accountName"),
                "cmpParameters" : component.get("v.cmpParameters"),
                "currentStageNumber": (component.get("v.nextStageNumber")-2),
              //  "selectedRecord" : component.get("v.selectedRecord")
            });
            event.fire(); 
        }
    },
    ContinueButton : function(component, event, helper) {
        var cmpParameters = component.get("v.cmpParameters");        
        if($A.util.isEmpty(cmpParameters) || $A.util.isUndefined(cmpParameters)){
            var cmpParameters = new Object();
        }
        cmpParameters.totalItems = component.get("v.totalItems");
        console.log('::cmpParameters::purchaseOrder'+JSON.stringify(component.get("v.purchaseOrder")));
        cmpParameters.purchaseOrder = component.get("v.purchaseOrder");
        component.set("v.cmpParameters", cmpParameters);
        
        var event = $A.get("e.c:NavigateToCmp");
        event.setParams({
            "accountId" : component.get("v.accountId"), 
            "accountName" : component.get("v.accountName"),            
            //"totalItems" : component.get("v.totalItems"),
            //"paymentMethodId" : component.get("v.paymentMethodId"),            
            //"selectedDealer" : component.get("v.selectedDealer"),
            "cmpParameters" : component.get("v.cmpParameters"),
            "currentStageNumber": component.get("v.nextStageNumber")
        });
        event.fire(); 
    },
    showSlider : function(component, event, helper) {
        var index = event.currentTarget.dataset.index; 
        var from = event.currentTarget.dataset.from;
        var productRow = document.getElementById(from + index);
        var prodIM = document.getElementById(from + 'im' + index);
        var prodIP = document.getElementById(from + 'ip' + index);
        
        productRow.setAttribute("style", "display:table-row;");
        prodIM.setAttribute("style", "display:table-row;");
        prodIP.setAttribute("style", "display:none;");
        helper.setSelectedProd(component, event);
    },
    hideSlider : function(component, event, helper) {    
        var index = event.currentTarget.dataset.index;    
        var from = event.currentTarget.dataset.from;
        var productRow = document.getElementById(from + index);
        var prodIM = document.getElementById(from + 'im' + index);
        var prodIP = document.getElementById(from + 'ip' + index);
        
        productRow.setAttribute("style", "display:none;");
        prodIM.setAttribute("style", "display:none;");
        prodIP.setAttribute("style", "display:table-row;");         
    },
    cancelFilter : function(component, event, helper) {        
        component.set("v.isAdSearch",false);  
      /*  var sideBar = document.getElementById('sideBar');
        sideBar.setAttribute('class','cd-panel from-right');*/
        var searchText = '';//component.find("searchKey").get("v.value");
        console.log("searchText-->"+ searchText);
        var offset = 0;
        var sortBy = component.find("sortByOption").get("v.value");
        /*********
        var prodFamily = component.get("v.prodFamily");
        var prodPackaging = component.get("v.prodPackaging");
        var prodTreatment = component.get("v.prodTreatment");        
        for(var index in prodFamily ){ prodFamily[index].isSelected = false; }
        for(var index in prodPackaging ){ prodPackaging[index].isSelected = false; }
        for(var index in prodTreatment ){ prodTreatment[index].isSelected = false; }
        component.set("v.prodFamily",prodFamily);
        component.set("v.prodPackaging",prodPackaging);
        component.set("v.prodTreatment",prodTreatment); 
        **************/
        var prodFilter = component.get("v.prodFilter");
        prodFilter.Family='';
        prodFilter.ProductCode='';
        prodFilter.MerchandiseType='';
        prodFilter.Size='';
        prodFilter.Color='';
        component.set("v.prodFilter",prodFilter); 
        helper.closeAdvancedFilter();
        helper.advanceSearch(component, event, searchText, offset, sortBy, null);         
     //   helper.revertCssChange(component);
    },
    applyFilter : function(component, event, helper) {        
        component.set("v.isAdSearch",true);       
       /* var sideBar = document.getElementById('sideBar');
        sideBar.setAttribute('class','cd-panel from-right');*/
        var searchText = '';//Open this line for keysearch + advance search  //component.find("searchKey").get("v.value");
        console.log("searchText-->"+ searchText);
        var offset = 0;
        var sortBy = component.find("sortByOption").get("v.value");
        helper.closeAdvancedFilter();
        helper.advanceSearch(component, event, searchText, offset, sortBy, null);        
     //   helper.revertCssChange(component);
    },
    hideFavProdSection :function(component, event, helper) { 
        var from = event.currentTarget.dataset.from;
        
        var el1 = document.getElementById("showFavProdUp");
        el1.setAttribute("style", "display:block;");
        
        var el2 = document.getElementById("showFavProdDown");
        el2.setAttribute("style", "display:none;");
        
        var el3 = document.getElementById("showFavProdUl");
        el3.setAttribute("style", "display:none;");
        
    },
    showFavProdSection:function(component, event, helper) { 
        var from = event.currentTarget.dataset.from;
        
        var el1 = document.getElementById("showFavProdUp");
        el1.setAttribute("style", "display:none;");
        
        var el2 = document.getElementById("showFavProdDown");
        el2.setAttribute("style", "display:block;");
        
        var el3 = document.getElementById("showFavProdUl");
        el3.setAttribute("style", "display:block;");
        
    },
    hideTopProdSection :function(component, event, helper) { 
        var from = event.currentTarget.dataset.from;
        
        var el1 = document.getElementById("showTopProdUp");
        el1.setAttribute("style", "display:block;");
        
        var el2 = document.getElementById("showTopProdDown");
        el2.setAttribute("style", "display:none;");
        
        var el3 = document.getElementById("showTopProdUl");
        el3.setAttribute("style", "display:none;");
        
    },
    showTopProdSection:function(component, event, helper) { 
        var from = event.currentTarget.dataset.from;
        
        var el1 = document.getElementById("showTopProdUp");
        el1.setAttribute("style", "display:none;");
        
        var el2 = document.getElementById("showTopProdDown");
        el2.setAttribute("style", "display:block;");
        
        var el3 = document.getElementById("showTopProdUl");
        el3.setAttribute("style", "display:block;");
        
    },
    changeQty :function(component, event, helper) { 
        var orderQty = event.currentTarget.value;
        console.log("::handleRangeChangeTop--orderQty:::"+orderQty);
        var index = event.currentTarget.dataset.index;    
        var from = event.currentTarget.dataset.from;
        var productlist;
        if( from == "fp"){
            productlist = component.get("v.favProductWrapper"); 
            productlist[index].OrderQuantity = orderQty;     
            component.set("v.favProductWrapper",productlist);
        }else if(from == "tp"){
            productlist = component.get("v.topProductWrapper");  
            productlist[index].OrderQuantity = orderQty;     
            component.set("v.topProductWrapper",productlist)
        }else if(from == "pw"){
            productlist = component.get("v.ProductWrapper");  
            productlist[index].OrderQuantity = orderQty;     
            component.set("v.ProductWrapper",productlist)
        }
    },
    removecss3 : function(cmp,event, helper){
       helper.removecss3(cmp, event);        
    },
})