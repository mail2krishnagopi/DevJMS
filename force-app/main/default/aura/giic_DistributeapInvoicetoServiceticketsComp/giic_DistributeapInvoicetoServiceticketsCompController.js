({
	    doInit : function(component, event, helper) {
          var recordId = component.get('v.recordId');//added
          console.log('Hello World' + recordId);
          if(recordId==null){//added
            var pageRef = component.get("v.pageReference");
            var recid = pageRef.state.c__recordId;
            console.log('recordId' + recid);
            component.set('v.recordId',recid);
          }
          
       
        }
})