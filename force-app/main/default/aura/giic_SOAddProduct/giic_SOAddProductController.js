({
    //method for component load
    doInit : function(component, event, helper) {
        
        component.set("v.deleteRow",[]);
        component.set("v.prodList", []);
        component.set('v.errmsg',null);
        component.set('v.noresult',false);
        var cmp1 = component.find("searchprd");
        if (!$A.util.isUndefined(cmp1) && !$A.util.isEmpty(cmp1)) 
        {        
            //setTimeout(function() {cmp1.focus();}, )
            cmp1.focus();
        }
        var soid = component.get('v.recordId');
        console.log('soid' + soid);
        
    },
    handleqty: function(component, event, helper) {     
        helper.showSpinner(component, event, helper);
        var inp = component.get('v.prdqty');	    
        if(!$A.util.isUndefined(inp) && !$A.util.isEmpty(inp))
        {
            if(isNaN(inp))
            {
                component.set('v.prdqty', inp.substring(0, inp.length - 1));
            }
            else if(inp ==0)
            {
                component.set('v.prdqty',1);
            }
        }
        else
        {
            component.set('v.prdqty',1);
        }
        
        if(event.getParams().keyCode === 13) {	 
            //helper.searchaddproduct(component, event, helper);
            // var cmp1 = component.find("searchprd");            
            setTimeout(function() {cmp1.focus();}, 1)
            //component.set('v.searchString', '');
            component.set('v.prdqty', '1');
            
        }
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and
        // else close the lookup result List part.
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            
            // Calling Helper function
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        
    },
    SearchProduct : function (component, event, helper) {
        
        component.set("v.Dropdownlist" , false);
        
        $A.util.removeClass(component.find("ContactLookup"), "visibilityNO");
        $A.util.removeClass(component.find("popUpBackgroundId1"), "visibilityNO");
        
        component.set("v.cssStyle", ".forceStyle .viewport .oneHeader {z-index:0; }.slds-global-header_container {position: static;} .forceStyle.desktop .viewport{overflow:hidden}");
        component.set("v.Showspinner" , true);
        
        var action = component.get("c.getProduct");
        action.setCallback(this, function(data) {
            component.set("v.Showspinner" , false);
            component.set("v.SearchedResult", data.getReturnValue());
            console.log('Productname' + JSON.stringify(component.get("v.SearchedResult")));
        });
        
        $A.enqueueAction(action);
    },
    handleComponentEvent : function(component, event, helper) {
        
        // get the selected Contact record from the COMPONETN event
        var selectedProductGetFromEvent = event.getParam("selectedProductEvent");
        
        component.set("v.selectedRecord" , selectedProductGetFromEvent);
        console.log(component.get("v.selectedRecord"));
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget =component.find("lookupField") ;
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
        
    },
    searchAddProduct: function(component, event, helper) {
        helper.getProductsData(component,event,helper);
    },
    goBack: function(component, event, helper) { 
        // component.set('v.DeleteSOL',[]);
        //component.set('v.CancelSol',[]);
        var recId = component.get('v.recordId');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId,
            "slideDevName": "Detail"
        });
        navEvt.fire();
    },
    deleteRow: function(component, event, helper) {
        var Index = event.getSource().get("v.name"); 
        var operation=event.getSource().get("v.label");
        var RowItemList = component.get("v.prodList");
        var itemListdupe= [...RowItemList];
        var newLine;
        // var isNewOrder=component.get('v.isNewOrder');//DO-1007 
        var deleteSOline=component.get("v.deleteRow");
        var cancelSoline=component.get("v.CancelSol");
        console.log('RowItemList'+ Index + RowItemList[Index] + deleteSOline );
        console.log('RowItemList'+JSON.stringify(RowItemList[Index]));
        if(operation=='Del' && RowItemList.length>1){
            deleteSOline.push(RowItemList[Index]);	
            component.set("v.deleteRow",deleteSOline);
            
        }
        
        console.log('RowItemList.length' +RowItemList.length);
        if( RowItemList.length>1){
            RowItemList.splice(Index, 1);
        }
        itemListdupe.splice(Index, 1);
        component.set("v.prodList", RowItemList);
        var mylist = component.get("v.prodList");
        if( mylist.length==1 && itemListdupe.length==0){
            if(operation=='Del'){
                let msg=$A.get("$Label.c.giic_DeleteLines");
                helper.fireToast(component,event,helper,"Can Not Delete Last Line",msg);
            }
            
        }
    },
    handleqtychange: function(component, event, helper) {
        console.log('handleQtyChange Called');
        var classes=  event.getSource().get("v.class");
        var indexClassName=classes.split(" ")[0];
        var indexOfElementChanged = indexClassName.replace("MyIndex","");        
        var elementList = component.get("v.prodList");
        var changedItem = elementList[indexOfElementChanged];
        var prodQty = changedItem.prodQty;
        
        console.log('elementList' +elementList);  
        changedItem.prodQty = prodQty; 
        component.set("v.prodList",elementList );
    }
    
})