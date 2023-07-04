({
    onPageReferenceChanged: function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    doInit : function(component, event, helper) {
        console.log("Record Id:" + component.get("v.recordId"));
            var currentRecordId =  component.get("v.recordId");
            var recid;
        if(currentRecordId = '' || currentRecordId == undefined)
        {
        var pageRef = component.get("v.pageReference");
          recid = pageRef.state.c__recordId;
          console.log('recordId' + recid);
          component.set('v.recordId',recid);
        }           

    }
})