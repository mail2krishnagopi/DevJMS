({
	calPagination : function(component, event) {
		var totalResultSize = component.get("v.totalResultSize");
        var pageSize = component.get("v.pageSize");
        var pageArray = component.get("v.pageArray");   
        console.log('---totalResultSize='+ totalResultSize + '---pageSize='+ pageSize + '---pageArray='+ pageArray);
        pageArray = new Array();    
        component.set("v.currentPageIndex", 1); 
        if(totalResultSize != null && totalResultSize>0){
            var quotient = Math.floor(totalResultSize/pageSize);
            var remainder = totalResultSize%pageSize;
            console.log('---quotient='+ quotient + '---remainder='+ remainder);
            for(var index =1; index <= quotient; index++){
            	pageArray.push(index);    
            }
            if(remainder >0) pageArray.push(index); 
            component.set("v.pageArray", pageArray);  
            component.set("v.lastPageIndex", pageArray[pageArray.length-1]);            
            console.log('---pageArray='+ pageArray + '---' + component.get("v.lastPageIndex") + '---' + component.get("v.currentPageIndex")); 
        }	
	}
})