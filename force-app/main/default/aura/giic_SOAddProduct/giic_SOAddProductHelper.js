({
    makedefaultstate: function(component, event, helper) {
        var cmp1 = component.find("searchprd");
        if (!$A.util.isUndefined(cmp1) && !$A.util.isEmpty(cmp1)) 
        {        
            setTimeout(function() {cmp1.focus();}, 1)
        }
        component.set("v.prodList", []);
        component.set('v.searchString', '');
    },
    
    getProductsData : function(component,event, helper) {
        
        this.showSpinner(component, event, helper);    
        var RowItemList = component.get("v.prodList");    
        var myarray = [];
        var validrequest = false;
        var prdqty = component.get('v.prdqty');         
        var searchString= component.get("v.searchString");
        console.log('searchString: '+ searchString );
        
        
        if(!$A.util.isUndefined(searchString) && !$A.util.isEmpty(searchString)) 
        {
            if(!$A.util.isUndefined(RowItemList) && !$A.util.isEmpty(RowItemList))
            {
                for(var i in RowItemList)
                {
                    if(RowItemList[i].prodCode == searchString)
                    {
                        component.set("v.Showspinner", false);
                        var toastEvent = $A.get("e.force:showToast");//Item shouldn't get duplicate on the order and it should pop up with the error "Item already existed on the order"
                        validrequest = false;
                        console.log('validrequest === '+validrequest);
                        toastEvent.setParams({                       
                            title: 'Error',
                            type: 'error',
                            message: $A.get("$Label.c.giic_ItemAlreadyExistedOnTheOrder")
                        });
                        toastEvent.fire();                        
                        break;                        
                    }	
                    else
                    {
                        validrequest = true;
                    }
                }
            }
            else
            {
                validrequest = true;
            }
            if(!$A.util.isUndefined(validrequest) && !$A.util.isEmpty(validrequest) && validrequest ==  true)
            {
                
                var action = component.get("c.searchProduct");
                action.setParams({
                    "searchString": component.get('v.searchString')
                });
                action.setCallback(this,function(response) {
                    var state = response.getState();
                    console.log('state'+ state);
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();  
                        // if (!$A.util.isUndefined(result) && !$A.util.isEmpty(result) && result.IsSuccess == true) 
                        //{
                        console.log('result' + result);
                        var lstProd = result.lstPRD;	
                        for (var i in lstProd) {
                            myarray.push({
                                'prodCode': lstProd[i].prodCode,
                                'prodDesc': lstProd[i].prodDesc,
                                'unitPrice': lstProd[i].unitPrice
                            });     
                        }
                        console.log('RowItemList'+ RowItemList);
                        myarray.push.apply(myarray, RowItemList);
                        console.log('myarray' + myarray);
                        component.set('v.prodList',myarray);
                        component.set('v.noresult',false);
                        
                        //}
                    }
                    else
                    {
                        component.set('v.noresult',true);
                    }
                    
                });
                $A.enqueueAction(action);
                this.hideSpinner(component, event, helper);
            }
        }
        else if($A.util.isUndefined(searchString) || $A.util.isEmpty(searchString) )
        {   
            component.set("v.Showspinner", false);
            console.log('Please enter a search string');
        }
    },
       
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method
        var getInputkeyWord = component.get("v.SearchKeyWord");
        component.set("v.Showspinner", true);
        var action = component.get("c.fetchProduct");
        console.log('getInputkeyWord' + getInputkeyWord);
        // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord
        });
        // set a callBack
        action.setCallback(this, function(response) {
            component.set("v.Showspinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found… message on screen.
                
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found…');
                } else {
                    component.set("v.Message", '');
                }
                
                // Set the boolean for hiding and showing the dropdown list and popup window
                var Ddlist = component.get("v.Dropdownlist");
                
                // set searchResult list with return value from server
                if(Ddlist == false){
                    
                    // set searched result to show in the table
                    component.set("v.SearchedResult", storeResponse);
                }
                
                else{
                    
                    component.set("v.listOfSearchRecords", storeResponse);
                    
                }
                
            }
            
        });
        // enqueue the Action
        $A.enqueueAction(action);
        
    },
    
    showSpinner: function(component, event, helper) {       
        component.set("v.Spinner", true);         
    },
    hideSpinner : function(component,event,helper){         
        component.set("v.Spinner", false);       
    },
      fireToast: function(component,event,helper,title,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({                   
            title: title,
            type: 'error',
            message: message
        });
        toastEvent.fire(); 
    }

})