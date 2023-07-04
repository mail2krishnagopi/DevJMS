({
	
selectProduct : function(component, event, helper){
// get the selected Product from list
var getSelectProduct = component.get("v.selectedProduct");

// call the event
var compEvent = component.getEvent("selectedProductEvent");
console.log("getselectedProduct"+ JSON.stringify(getSelectProduct));

// set the Selected contact to the event attribute.
compEvent.setParams({"contactByEvent" : getSelectProduct });

// fire the event
compEvent.fire();
},
})