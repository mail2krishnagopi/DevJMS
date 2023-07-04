({
    onPageReferenceChanged: function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    doInit: function(component, event, helper) {
        
        console.log('Aura Component Loaded');        
         
           // Retrieve the record ID from the page URL parameter
           var recordId = component.get("v.pageReference").state.c__recordId;
            console.log("Record Id:", recordId);
                       
            // Set the new record ID in the component attribute
            component.set('v.recordId', recordId);
         
          
        }       
       
       
}

)