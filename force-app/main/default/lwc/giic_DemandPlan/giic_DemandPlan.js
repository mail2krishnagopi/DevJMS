import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import fetchProductData from '@salesforce/apex/giic_DemandPlanController.fetchProducts';
import saveRecord from '@salesforce/apex/giic_DemandPlanController.saveForeCastDetails';
import submitApproval from '@salesforce/apex/giic_DemandPlanController.submitForApproval';
import approveDFRec from '@salesforce/apex/giic_DemandPlanController.approveRecord';
import generateDO from '@salesforce/apex/giic_DemandPlanController.saveDO';
import rejectDFRec from '@salesforce/apex/giic_DemandPlanController.rejectRecord';
import reqForEditFPRec from '@salesforce/apex/giic_DemandPlanController.requestForEditApprovedFP';
import getBatchJobs from '@salesforce/apex/giic_DemandPlanController.getBatchJobStatus';
import getBatchJobsDP from '@salesforce/apex/giic_DemandPlanController.getBatchJobStatusDP';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import DEMANDFORECASTCYCLE_OBJECT from '@salesforce/schema/gii__DemandForecastCycle__c';
import removeRow from '@salesforce/apex/giic_DemandPlanController.del';
import runDemandOrderPlanBatch from '@salesforce/apex/giic_DemandPlanController.runDemandOrderPlanBatch';
const DELAY = 1000;

export default class giic_DemandPlan extends NavigationMixin(LightningElement) {

    @api cyclerecid;
    @api cycleobjname;
    planName;
    isForecast =  false;
    @track searchHeaderData = [];
    isLoaded = false;
    showProductData = false;
    showRecordMessage = false;
    showButtonGroup = false;
    foreCastLocal = false;
    showreqForEdit = false;
    showApproveReject = false;
    showSubmitApprovalButton = false;
    showAllButton = false;
    showApproveUpdatePlan = false;
    forecastPlanRegionView = false;
    isReadOnly = false;
    restoreVal = false;
    isApprovalShowInformation = false;
    showsubmit = false;
    isApprovalRejectRequest = false;
    isDemandPlanGeneration = false;
    demandPlan = false;
    showBVURec = false;
    isProdChecked = false;
    isProductModalOpen = false;
    showgenerateDO = false;
    rejectionReason = '';
    additionApprovalComment = '';
    indexval;
    BVUList = [];
    @track forecastData = [];
    @track batchProgressPercent=0;
    isBatchProcessed = false;
    jobProcessed;
    totalItemProcessed;
    failedJobs;
    isBatchProcessCompleted =false;
    isBatchProcessZero = false;


    connectedCallback(){
        this.restoreVal = true;
        this.planName = 'Demand Plan';
        this.isForecast = true;
    }

    getSearcHeaderData(event){
        let searchData = [];
        searchData = JSON.parse(JSON.stringify(event.detail.searchCompData));
        this.searchHeaderData = searchData;
        console.log('this.searchHeaderData =='+JSON.stringify(this.searchHeaderData));
        if(this.searchHeaderData){     
            this.isLoaded = true;
            fetchProductData({ filterWrapStr: JSON.stringify(searchData) })
            .then(result => {
                this.isLoaded = false;
                this.showProductData = true;
                this.forecastData = result;

                if(this.forecastData.prodWrap.length == 0){
                    this.showRecordMessage = true;
                    this.showProductData = false;
                    this.showButtonGroup = false;
                    this.foreCastLocal = false;
                    return;
                }else{
                    this.showRecordMessage = false;
                }

                if(this.searchHeaderData.isActive == false){
                    this.showSubmitApprovalButton = false;
                    this.showButtonGroup = true;
                    this.foreCastLocal = false;
                    this.showAllButton = false;
                    this.forecastPlanRegionView = true;
                    this.isReadOnly = true;  
                    this.showgenerateDO = false;
                    this.showApproveReject = false;
                    this.showApproveUpdatePlan = false;
                    this.showreqForEdit = false;
                    return;
                }

                this.showButtonGroup = true;
                this.foreCastLocal = true;
                this.showAllButton = true;
                this.showreqForEdit = false;
                this.showApproveReject = false;
                this.demandPlan = true;
                if(searchData.regionCheck){
                    this.showSubmitApprovalButton = true;
                    this.showgenerateDO = false;
                    this.showApproveReject = false;
                    this.showApproveUpdatePlan = false;
                    this.showreqForEdit = false;
                    this.forecastPlanRegionView = false;
                    this.isReadOnly = false;
                }else{
                    this.showSubmitApprovalButton = false;
                    this.foreCastLocal = false;
                    this.showAllButton = false;
                    this.forecastPlanRegionView = true;
                    this.isReadOnly = true;  
                    this.showgenerateDO = false;
                    this.showApproveReject = false;
                    this.showApproveUpdatePlan = false;
                    this.showreqForEdit = false;
                }
                if(searchData.lstDFS.length == 1 && searchData.regionCheck){
                    if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Pending for Approval'){
                        this.showSubmitApprovalButton = false;
                        this.foreCastLocal = false;
                        this.showAllButton = false;
                        this.forecastPlanRegionView = true;
                        this.isReadOnly = true;   
                        this.showreqForEdit = false;
                        this.showApproveUpdatePlan = false;
                        if(searchData.isApprover ){
                            this.showApproveReject = true;
                            this.showAllButton = true;
                            this.foreCastLocal = true;
                            this.forecastPlanRegionView = false;
                            this.forecastPlanRegionView = false;
                            this.isReadOnly = false;
                        }
                    }else if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Approved'){
                        this.showSubmitApprovalButton = false;
                        this.foreCastLocal = false;
                        this.forecastPlanRegionView = true;
                        this.isReadOnly = true;
                        this.showApproveReject = false;
                        if(searchData.regionCheck){
                            this.showreqForEdit = true;
                        }
                        this.showApproveUpdatePlan = false;
                        this.showAllButton = false;
                        if((searchData.lstDFS[0].giic_BatchStatus__c == undefined || searchData.lstDFS[0].giic_BatchStatus__c == 'Failed') && searchData.lstDFS[0].giic_DemandForecastCycle__r.gii__Active__c){
                            this.showgenerateDO=true;
                        }else if(searchData.lstDFS[0].giic_BatchStatus__c == 'In Progress'){
                            this.showreqForEdit = false;
                        }
                    }else if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Request for update plan'){
                        this.foreCastLocal = false;
                        this.forecastPlanRegionView = true;
                        this.isReadOnly = true;
                        this.showreqForEdit = false;
                        this.showAllButton = false;
                        this.showSubmitApprovalButton = false;
                        this.showApproveReject = false;
                        if(searchData.isApprover){
                            this.showApproveUpdatePlan = true;
                        }
                    }else if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Approved for update plan'){
                        this.foreCastLocal = true;
                        this.forecastPlanRegionView = false;
                        this.showSubmitApprovalButton = true;
                        this.showreqForEdit = false;
                        this.showAllButton = true;
                        this.showApproveReject = false;
                        this.showApproveUpdatePlan = false;
                        this.isReadOnly = false;
                    }else if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Rejected' || searchData.lstDFS[0].giic_ApprovalStatus__c == 'Reject for update plan'){
                        this.showButtonGroup = true;
                        this.foreCastLocal = true;
                        this.showreqForEdit = false;
                        this.showApproveReject = false;
                        this.demandPlan = true;
                        if(searchData.regionCheck){
                            if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Rejected'){
                                this.showSubmitApprovalButton = true;
                                this.showAllButton = true;
                            }else{
                                this.foreCastLocal = false;
                                this.showreqForEdit = true;
                                this.forecastPlanRegionView = true;
                                this.isReadOnly = true;
                                this.showAllButton = false;
                                this.showSubmitApprovalButton = false;
                            }
                        }
                    }else{
                        this.showgenerateDO = false;
                    }
                }                     
            })
            .catch((error) => {
                this.isLoaded = false;
                let errorMessage = ''
                if (error.body.message) {
                    errorMessage =error.body.message;
                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error'
                }));
            })

        }
    }
    
    getForePriority(event){
        let p = this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].priority;
        if(event.target.value.length > 6){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning!',
                message: "Forecast Priority can not be more than 6 digits.",
                variant: 'warning'
            }));
            Promise.resolve().then(() => {
                this.restoreVal =  false;
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].priority = p;
                this.restoreVal =  true;
            });
            return;
        }else if(event.target.value < 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning!',
                message: "Forecast Priority can not be negative.",
                variant: 'warning'
            }));
            Promise.resolve().then(() => {
                this.restoreVal =  false;
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].priority = p;
                this.restoreVal =  true;
            });
            return;
        }else if( event.target.value % 1 != 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning!',
                message: "Forecast Priority can not be decimal.",
                variant: 'warning'
            }));
            Promise.resolve().then(() => {
                this.restoreVal =  false;
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].priority = p;
                this.restoreVal =  true;
            });
            return;
        }else if(event.target.value == ''){
            this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].priority = 0;
        }else{
            Promise.resolve().then(() => {
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].priority = event.target.value;    
            });
        }
    }

    getPOPriority(event){
        let p = this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].purposeOrderPriority;
        if(event.target.value.length > 6){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning!',
                message: "Purpose Order Priority can not be more than 6 digits.",
                variant: 'warning'
            }));
            Promise.resolve().then(() => {
                this.restoreVal =  false;
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].purposeOrderPriority = p;
                this.restoreVal =  true;
            });
            return;
        }else if(event.target.value < 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning!',
                message: "Purpose Order Priority can not be negative.",
                variant: 'warning'
            }));
            Promise.resolve().then(() => {
                this.restoreVal =  false;
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].purposeOrderPriority = p;
                this.restoreVal =  true;
            });
            return;
        }else if( event.target.value % 1 != 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning!',
                message: "Purpose Order Priority can not be decimal.",
                variant: 'warning'
            }));
            Promise.resolve().then(() => {
                this.restoreVal =  false;
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].purposeOrderPriority = p;
                this.restoreVal =  true;
            });
            return;
        }else if(event.target.value == ''){
            this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].purposeOrderPriority = 0;
        }else{
            Promise.resolve().then(() => {
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].purposeOrderPriority = event.target.value;    
            });
        }
    }

    getProdPurpose(event){
        if(event.target.value != null){
            Promise.resolve().then(() => {
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].productPurpose = event.target.value;    
            });
        }
    }

    getOpportunityName(event){
        if(event.target.value != null){
            Promise.resolve().then(() => {
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].oppName = event.target.value;    
            });
        }
    }


    handleChild(event) {
        if(event.detail.prodValue){
            let isDecimal = event.detail.prodValue % 1 != 0;
            if(isDecimal){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: "Decimals are not allowed",
                    variant: 'error'
                }));
                return;
            }else{
                this.forecastData.prodWrap[event.detail.indexvalue].periodQty[event.detail.periodkey] = event.detail.prodValue;
                this.forecastData.prodWrap[event.detail.indexvalue].mapPLW[event.detail.periodkey].isEdited = true;
            }
        } 
    }

    closeApproveModal(event){
        this.isApprovalShowInformation = false;
    }

    closeApproveRejectModal(event){
        this.isApprovalRejectRequest = false;
    }

    getAprovalComment(event){
        this.additionApprovalComment = event.detail.value;
    }

    getRejectionReason(event){
        this.rejectionReason = event.detail.value;
    }

    showBVUList(event){
        this.indexval = event.currentTarget.dataset.indexvar;
        this.showBVURec = true;
        this.getBVURecord();
    }

    getBVURecord(event){
        this.BVUList = this.forecastData.prodWrap[this.indexval].lstBVUMsgs;
    }

    closeBVUModal(event){
        this.showBVURec = false;
    }

    getBVURecord(event){
        this.BVUList = this.forecastData.prodWrap[this.indexval].lstBVUMsgs;
    }

    appoveForecast(event){
        this.isApprovalShowInformation = true;
    }


    save(event) {
        this.isLoaded = true;
        let tempForecastData = [];
        if (this.forecastData) {
            tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
            saveRecord({ productSearch: JSON.stringify(tempForecastData),filterWrapper: JSON.stringify(this.searchHeaderData)})
            .then(result => {
                this.isLoaded = false;
                this.forecastData = result;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: "Record has been saved successfully",
                    variant: 'success'
                }));
            })
            .catch((error) => {
                this.isLoaded = false;
                let errorMessage = ''
                if (error.body.message) {
                    errorMessage =error.body.message;
                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error'

                }));
            })
        }
    }

    saveAndExit(event) {
        this.isLoaded = true;
        if (this.forecastData) {            
            saveRecord({ productSearch: JSON.stringify(this.forecastData),filterWrapper:JSON.stringify(this.searchHeaderData) })
            .then(result => {
                this.isLoaded = false;
                let forecastCycleId = this.cyclerecid;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: "Record has been saved successfully",
                    variant: 'success'
                }));
                return this.navigateToForecastCycleForecastPage(forecastCycleId);
            })
            .catch((error) => {
                this.isLoaded = false;
                let errorMessage = ''
                if (error.body.message) {
                    errorMessage =error.body.message;

                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error'

                }));
            })
        }
    }

    navigateToForecastCycleForecastPage(forecastCycleId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: forecastCycleId,
                objectApiName: DEMANDFORECASTCYCLE_OBJECT.objectApiName,
                actionName: 'view'
            }
        });
    }

    backToRecord(event){
      return  this.navigateToForecastCycleForecastPage(this.cyclerecid);
    }

    saveApprovalDetails(event){
        this.isApprovalShowInformation = false;
    }

    submitRecordForApprovalModal(event){
        this.showsubmit = true;
    }

    closesubmitapprovalModal(event){
        this.showsubmit = false;
    }

    submitRecordForApproval(event) {
        this.showsubmit = false;
        if(this.forecastData){                
            let tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
            this.isLoaded = true;
            submitApproval({ productSearch: JSON.stringify(tempForecastData),filterWrapperStr : JSON.stringify(this.searchHeaderData) })
            .then(result => {
                this.isLoaded = false;
                tempForecastData = result;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: "Record has been submitted for approval",
                    variant: 'success'
                }));
                this.forecastData = result;
                this.showAllButton = false;
                this.foreCastLocal = false;
                this.forecastPlanRegionView = true;
                this.isReadOnly = true;
                this.showSubmitApprovalButton = false;
                if(this.searchHeaderData.isApprover && this.searchHeaderData.regionCheck){
                    this.showApproveReject = true;
                }
            })
            .catch((error) => {
                this.isLoaded = false;
                let errorMessage = ''
                if (error.body.message) {
                    errorMessage =error.body.message;

                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error'

                }));
            })
        }
    }

    approveDemandPlan(event){
        if(this.forecastData){
            this.forecastData.approvalComments = this.additionApprovalComment;

            let tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
            let tempProdData = JSON.parse(JSON.stringify(tempForecastData.prodWrap));
            
            for (let key in tempProdData) {
                tempProdData[key].checked = true;
            }
            tempForecastData.prodWrap = tempProdData;
            this.isLoaded = true;
            this.isApprovalShowInformation = false;
            approveDFRec({dfcWrapper :JSON.stringify(tempForecastData),filterWrapperStr : JSON.stringify(this.searchHeaderData) })
            .then(result => {
                this.isLoaded = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success!',
                    message: "Record has been approved successfully.",
                    variant: 'success'
                }));
                if(this.searchHeaderData.lstDFS[0].giic_ApprovalStatus__c == 'Approved' && this.searchHeaderData.regionCheck){
                    this.showgenerateDO = true;
                }
                this.forecastData = result;
                this.showAllButton = false;
                this.showreqForEdit = false
                this.foreCastLocal = false;
                this.forecastPlanRegionView = true;
                this.isReadOnly = true;
                this.showApproveReject = false;
            })            
        }  
    }

    rejectDemandPlan(event){
        if(this.forecastData){
            if(this.rejectionReason == '' || this.rejectionReason == null){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: "Please provide the reason to reject the demand plan.",
                    variant: 'error'
                }));
                return;
            }else{
                this.forecastData.rejectionComments = this.rejectionReason;
                let tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
                this.isLoaded = true;
                this.isApprovalShowInformation = false;
                rejectDFRec({dfcWrapper :JSON.stringify(this.forecastData),filterWrapperStr : JSON.stringify(this.searchHeaderData) })
                .then(result => {
                    this.isLoaded = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: "Record has been rejected successfully.",
                        variant: 'success'
                    }));
                    this.isApprovalShowInformation = false;
                    this.showAllButton = true;
                    tempForecastData = result;
                })
                this.forecastData = tempForecastData;
            }
        }
    }

    createDemandOrder(event){
        this.isBatchProcessed = true;
        this.isBatchProcessCompleted =false;
        if(this.forecastData){
            let tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
            let tempProdData = JSON.parse(JSON.stringify(tempForecastData.prodWrap));
                for (let key in tempProdData) {
                    tempProdData[key].checked = true;
                 }
            tempForecastData.prodWrap = tempProdData;
            this.isLoaded = true;
            generateDO({productSearch :JSON.stringify(tempForecastData),filterWrapperStr : JSON.stringify(this.searchHeaderData) })
            .then(() => {
                this.isApprovalShowInformation = false;
                this.showAllButton = false;
                this.showreqForEdit = false;
                this.foreCastLocal = false;
                this.forecastPlanRegionView = true;
                this.isReadOnly = true;
                this.showApproveReject = false;
                this.showgenerateDO=false;
                this.isLoaded = false;
                this._interval = setInterval(() => {  
                    getBatchJobs().then(result =>{
                        let jobStatus =[];
                        jobStatus = result;
                        let totolJobItems=0;
                        let jobProcessedItems=0;
                        let percentCompleted =0;
                        let jobFailed =0;
                        this.isBatchProcessZero = false;
                        let completedJobs =1;
                        var isComplete = false;
                        if(jobStatus.length >0){
                            
                        for(let i=0;i<jobStatus.length;i++)
                         {
                             totolJobItems =jobStatus.length;
                             if(jobStatus[i].Status =='Completed'){
                                 jobProcessedItems = completedJobs++; 
                                 isComplete = true;
                               }
                             if(jobStatus[i].Status == 'Failed'){
                                 jobFailed += jobStatus[i].NumberOfErrors; 
                             }
                         }
                         this.jobProcessed = jobProcessedItems;
                         this.totalItemProcessed = totolJobItems;
                         this.failedJobs = jobFailed;
                         console.log('this.failedJobs---'+this.failedJobs);
                         if(jobProcessedItems == 0 && isComplete == true){
                            this.isBatchProcessZero = true;
                            this.batchProgressPercent === 100
                        }
                         if(totolJobItems!=0 && jobProcessedItems!=0){
                           
                           percentCompleted = jobProcessedItems/ totolJobItems * 100;
                           this.batchProgressPercent = percentCompleted;
                         }
                         if ( this.batchProgressPercent === 100 ) {
                               this.isBatchProcessCompleted = true;
                             clearInterval(this._interval);  
                         } 
                       
                        }
                    }).catch((error) =>{});
                }, 2000);
            }).catch((error) => {
                var errorMessage;
                console.log('error>>',error);
                if (error.body.message) {
                    errorMessage =error.body.message;
                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error'
                }));
                this.error = error;
            });
        }
    }

    approveUpdateForecastPlan(event){
        if(this.forecastData){
            this.forecastData.approvalComments = this.additionApprovalComment;
            this.forecastData.isApproveUpdate = true;
            let tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
            this.isLoaded = true;
            this.isApprovalRejectRequest = false;
            approveDFRec({dfcWrapper :JSON.stringify(tempForecastData),filterWrapperStr : JSON.stringify(this.searchHeaderData) })
            .then(result => {
                this.isLoaded = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success!',
                    message: "Request has been approved successfully.",
                    variant: 'success'
                }));
                this.isApprovalRejectRequest = false;
                this.forecastData = result;
                this.showAllButton = true;
                this.showreqForEdit = false;
                this.foreCastLocal = true;
                this.isReadOnly = false;
                this.forecastPlanRegionView = false;
                this.showApproveReject = false;
                this.showSubmitApprovalButton = true;
                this.showApproveUpdatePlan = false;
            })
        }
    }

    rejectUpdateForecastPlan(event){
        if(this.rejectionReason == '' || this.rejectionReason == null){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: "Please provide the reason to reject the request.",
                variant: 'error'
            }));
            return;
        }else{
            this.forecastData.rejectionComments = this.rejectionReason;
            this.isLoaded = true;
            this.isApprovalRejectRequest = false;
            rejectDFRec({dfcWrapper :JSON.stringify(this.forecastData),filterWrapperStr : JSON.stringify(this.searchHeaderData) })
            .then(result => {
                this.isLoaded = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: "Request has been rejected successfully.",
                    variant: 'success'
                }));
                this.isApprovalRejectRequest = false;
                this.showAllButton = false;
                this.forecastData = result;
                this.showreqForEdit = true;
                this.foreCastLocal = false;
                this.forecastPlanRegionView = true;
                this.inputReadOnly = true;
                this.showApproveReject = false;
                this.showSubmitApprovalButton = false;
                this.showApproveUpdatePlan = false;
                
            })
        }
    }

    reqForEdit(event){
        this.isLoaded = true;
        if(this.forecastData){
            this.showgenerateDO = false;
            reqForEditFPRec({productSearch :JSON.stringify(this.forecastData),filterWrapperStr : JSON.stringify(this.searchHeaderData) })
            .then(result => {
                this.isLoaded = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: "Request has been sent successfully.",
                    variant: 'success'
                }));
                this.forecastData = result;
                this.showreqForEdit = false;
                if(this.searchHeaderData.isApprover){
                    this.showApproveUpdatePlan = true;
                }
            })
        }
    }

    approveRejectUpdatePlan(event){
        this.isApprovalRejectRequest = true;
    }

    closeModal(event) {
        this.isBatchProcessed = false;
    }
    prodChecked(event) {
        let selectedRows = this.template.querySelectorAll('lightning-input');
        this.selectedProd = [];
        let tempForecastData = [];
        let tempProdData = [];
        tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
        tempProdData = JSON.parse(JSON.stringify(tempForecastData.prodWrap));
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === 'checkbox' && selectedRows[i].checked) {
                for (let key in tempProdData) {
                    if (tempProdData[key].productId == selectedRows[i].dataset.id && tempProdData[key].proForecast.Id == selectedRows[i].dataset.forecast && tempProdData[key].warehouse == selectedRows[i].dataset.ware ) {
                        tempProdData[key].checked = true;
                        this.isProdChecked = true;
                    }
                }
            } else if (selectedRows[i].type === 'checkbox' && !selectedRows[i].checked) {
                for (let key in tempProdData) {
                    if (tempProdData[key].productId == selectedRows[i].dataset.id && tempProdData[key].proForecast.Id == selectedRows[i].dataset.forecast  && tempProdData[key].warehouse == selectedRows[i].dataset.ware) {
                        tempProdData[key].checked = false;
                    } 
                }
            }
        }
        tempForecastData.prodWrap = tempProdData;
        this.forecastData = tempForecastData;       
    }

    removeProductLine(event) {
        let tempForecastData = [];
        let tempProdData = [];
        tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
        tempProdData = JSON.parse(JSON.stringify(tempForecastData.prodWrap));
        if (this.isProdChecked == false) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: "Select atleast one Product to delete",
                variant: 'error'
            }));
        } else {
            this.isLoaded = true;
            removeRow({ productSearch: JSON.stringify(this.forecastData),filterWrapperStr:JSON.stringify(this.searchHeaderData) })
            .then(result => {
                this.isLoaded = false;
                this.forecastData = result;
                if(this.forecastData.prodWrap.length == 0){
                    this.showAllButton = false;
                    this.showApproveReject = false;
                    this.showSubmitApprovalButton = false;
                    this.showreqForEdit = false;
                    this.showApproveUpdatePlan = false;
                    this.showDemandOrder = false;
                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: "Product line has been removed successfully.",
                    variant: 'success'
                }));
                //this.getSearcHeaderData(event);
            })
            .catch((error) => {
                this.isLoaded = false;
                let errorMessage = ''
                if (error.body.message) {
                    errorMessage =error.body.message;
                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error'

                }));
            })
        }
    }
    navigateToLineStaging(event) {
        this[NavigationMixin.GenerateUrl]({
             type: 'standard__objectPage',
             attributes: {
                 objectApiName: 'gii__DemandForecastLineStaging__c',
                 actionName: 'home'
             },
             
         }).then(url => { window.open(url) });
     }
     runDemandPlanBatch(event) {
        this.isBatchProcessed = true;
        this.isBatchProcessCompleted =false;
        if(this.forecastData){
            this.showreqForEdit = true;
            runDemandOrderPlanBatch({ productSearch: JSON.stringify(this.forecastData) ,filterWrapperStr : JSON.stringify(this.searchHeaderData)})
            .then(result => {
                this._interval = setInterval(() => {  
                    getBatchJobsDP().then(result =>{
                        let jobStatus =[];
                        jobStatus = result;
                        let totolJobItems=0;
                        let jobProcessedItems=0;
                        let percentCompleted =0;
                        let jobFailed = 0;
                        if(jobStatus.length >0){
                        for(let i=0;i<jobStatus.length;i++)
                         {
                             totolJobItems =jobStatus.length;
                             if(jobStatus[i].Status =='Completed'){
                                 jobProcessedItems += jobStatus[i].JobItemsProcessed; 
                                 console.log('jobProcessedItems' +jobProcessedItems);
                               }
                             if(jobStatus[i].Status == 'Failed'){
                                 jobFailed += jobStatus[i].NumberOfErrors; 
                             }
                         }
                         this.jobProcessed = jobProcessedItems;
                         this.totalItemProcessed = totolJobItems;
                         this.failedJobs = jobFailed;
                           
                         if(totolJobItems>0 && jobProcessedItems>=0 && jobFailed==0){
                           percentCompleted = ((jobProcessedItems==0?1:jobProcessedItems)/ (totolJobItems==0?1:totolJobItems)) * 100;
                             this.batchProgressPercent = percentCompleted;
                         }
                         if ( this.batchProgressPercent === 100 ) {
                               this.isBatchProcessCompleted = true;
                             clearInterval(this._interval);  
                         } 
                       
                        }
                       }).catch((error) =>{
                        
                       });
                    }, 2000);
            }).catch((error) => {
                var errorMessage;
                console.log('error>>',error);
                if (error.body.message) {
                    errorMessage =error.body.message;
                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error'
                }));
                this.error = error;
            });
            this.showDemandOrder=false;
        }
    }

}