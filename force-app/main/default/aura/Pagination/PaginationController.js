({
    doInit : function(component, event, helper) {
		console.log('::::::::::::::doInit --> -Start::::::::::::::');        
        helper.calPagination(component, event);
        console.log('::::::::::::::doInit --> -End::::::::::::::');
	},
    doReset : function(component, event, helper) {
		console.log('::::::::::::::doReset --> -Start::::::::::::::'+event.getParam("totalResultSize")); 
        var totalResultSize = event.getParam("totalResultSize"); 
        component.set("v.totalResultSize", totalResultSize);  
        helper.calPagination(component, event);
        console.log('::::::::::::::doReset --> -End::::::::::::::');
	},
    doPagination : function(component, event, helper) {                
        var pageindex = event.currentTarget.dataset.pageindex;
        var currentPageIndex = component.get("v.currentPageIndex");	
        console.log('---pageindex='+ pageindex);
        if(pageindex == "Prev"){ 
            component.set("v.currentPageIndex", (currentPageIndex-1));	
        }else if(pageindex == "Next"){ 
            component.set("v.currentPageIndex", (currentPageIndex+1));
        }else{            
            component.set("v.currentPageIndex", parseInt(pageindex));
        }        
        console.log('---currentPageIndex='+ component.get("v.currentPageIndex"));  
        var offset = (component.get("v.currentPageIndex") -1) * component.get("v.pageSize");
        console.log('---offset='+ offset); 
        
        var e = component.getEvent("fromPagination");//$A.get("e.GloviaLBDev1:giic_PaginationEvent");
        e.setParams({"offset": offset});
        e.fire();
    }
})