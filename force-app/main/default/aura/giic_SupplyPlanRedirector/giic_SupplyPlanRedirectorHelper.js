({

    getSupplyRecord : function(component,event,helper) {
        var action = component.get('c.getSPCData'); 
        action.setParams({
            "recId" : component.get('v.recordId') 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var res = a.getReturnValue();
                component.set('v.spcData', res);
                console.log('data is --' +component.get('v.spcData'));
                var val =  component.get('v.spcData');
                if(val == false){
                    helper.callBatch(component,event,helper);
                }else{
                    var newEvent = $A.get("e.force:navigateToComponent");
                    newEvent.setParams({
                        componentDef: "c:giic_SupplyPlanAction",
                        componentAttributes: {
                            supplyPlanRecordId : component.get("v.recordId")
                        }
                    });
                    newEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

    callBatch: function(component,event,helper) {
        console.log('in doinit');
        var action = component.get("c.executeBatchjob");
        action.setParams({  
            recId: component.get("v.recordId")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state 1 is --- '+state);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The Job has been successfully initiated."
                });
                toastEvent.fire();

                if (state === "SUCCESS"){
                    
                    var interval = setInterval($A.getCallback(function () {
                        console.log('state 2 is --- ');
                        var jobStatus = component.get("c.getBatchJobStatus");
                        if(jobStatus != null){
                            jobStatus.setParams({recId: component.get("v.recordId")});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                console.log('state'+state);
                                if (state === "SUCCESS"){
                                    console.log('state 3 is --- '+state);
                                    /*var job=[];
                                    var totolJobItems=0;
                                    var jobProcessedItems = 0;
                                    var percentCompleted = 0;
                                    var jobFailed=0;*/
                                    var processedPercent = 0;
                                    var mp = jobStatusResponse.getReturnValue(); 
                                    var job = mp.jobInfo;
                                    console.log('mp -'+JSON.stringify(mp));
                                    var spc = mp.SPC;
                                    //component.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    console.log('job+++'+JSON.stringify(job));
                                    console.log('spc is ---'+spc);
                                    /*if(job.length > 0){
                                     for(let i=0;i<job.length;i++){
                                            totolJobItems = job.length;
                                            if(job[i].Status =='Completed'){
                                                jobProcessedItems += job[i].JobItemsProcessed;                        
                                            }
                                            if(jobStatus[i].Status == 'Failed'){
                                                jobFailed += jobStatus[i].NumberOfErrors; 
                                            }
                                        }
                                        component.set('v.failed',jobFailed);
                                          if(totolJobItems!=0 && jobProcessedItems!=0){
                                               percentCompleted = jobProcessedItems/ totolJobItems * 100;
                  							component.set('v.progress',processedPercent);
                                    }
                                    
                                    var progress = component.get('v.progress');
                                    console.log('progress'+progress);
                                    component.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                    
                                    }*/
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    }
                                    var progress = component.get('v.progress');
                                    component.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                    if(spc || progress == 100){
                                        clearInterval(interval);
                                        component.set('v.isBatchProcessed',true);
                                        console.log('inside if --');
                                        var newEvent = $A.get("e.force:navigateToComponent");
                                        newEvent.setParams({
                                            componentDef: "c:giic_SupplyPlanAction",
                                            componentAttributes: {
                                                supplyPlanRecordId : component.get("v.recordId")
                                            }
                                        });
                                        newEvent.fire();
                                    }
                                }
                            });
                            $A.enqueueAction(jobStatus);
                        }
                    }), 2000);
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    // gotoSupplyPlan : function(component, event, helper) {
    //     var newEvent = $A.get("e.force:navigateToComponent");
    //     newEvent.setParams({
    //         componentDef: "c:giic_SupplyPlanAction",
    //         componentAttributes: {
    //             supplyPlanRecordId : component.get("v.recordId")
    //         }
    //     });
    //     newEvent.fire();

    // }
})