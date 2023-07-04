({
        doInit : function(component, event, helper) {
          var recordId = component.get('v.recordId');//added
          if(recordId==null){//added if condition
            var pageRef = component.get("v.pageReference");
            var recid = pageRef.state.c__recordId;
            console.log('recordId' + recid);
            component.set('v.recordId',recid);
          }
          
       
             /* var navService = component.find("navService");
          
           var compDefinition = {
            componentDef: "c:giic_CreateHarvestLines",
            attributes: {
                recordId: component.get('v.recordId'),
              
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));

        var pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        }
    
        navService.navigate(pageReference);*/
        }
    })