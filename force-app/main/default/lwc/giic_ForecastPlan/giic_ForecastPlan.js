import { LightningElement,track,api } from 'lwc';
import fetchProductData from '@salesforce/apex/giic_forecastPlanController.fetchProducts';
import removeRow from '@salesforce/apex/giic_forecastPlanController.del';
import saveRecord from '@salesforce/apex/giic_forecastPlanController.saveForeCastDetails';
import submitApproval from '@salesforce/apex/giic_forecastPlanController.submitForApproval';
import approveDFRec from '@salesforce/apex/giic_forecastPlanController.approveRecord';
import rejectDFRec from '@salesforce/apex/giic_forecastPlanController.rejectRecord';
import reqForEditFPRec from '@salesforce/apex/giic_forecastPlanController.requestForEditApprovedFP';
import updateDOQty from '@salesforce/apex/giic_forecastPlanController.updateDemandOrderQty';
import getBatchJobs from '@salesforce/apex/giic_forecastPlanController.getBatchJobStatus';
import getReportId from '@salesforce/apex/giic_forecastPlanController.getReportId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class Giic_ForecastPlan extends NavigationMixin(LightningElement) {
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
    showDemandOrder = false;
    forecastPlanRegionView = false;
    inputReadOnly = false;
    restoreVal = false;
    isApprovalShowInformation = false;
    showsubmit = false;
    isApprovalRejectRequest = false;
    showBVURec = false;
    isProdChecked = false;
    isProductModalOpen = false;
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
        this.isForecast = true;
        this.restoreVal = true;
        this.planName = 'Forecast Plan';
    }

    getSearcHeaderData(event){
        let searchData = [];
        searchData = JSON.parse(JSON.stringify(event.detail.searchCompData));
        this.searchHeaderData = searchData;
        if(this.searchHeaderData){     
            this.isLoaded = true;
            fetchProductData({ filterWrapStr: JSON.stringify(searchData) })
            .then(result => {
                this.isLoaded = false;
                this.showProductData = true;
                this.forecastData = result;
                if(this.forecastData.prodWrap.length == 0){
                    this.showProductData = false;
                    this.showRecordMessage = true;
                    this.showButtonGroup = false;
                    this.foreCastLocal = false;
                    return;
                }else{
                    this.showRecordMessage = false;
                }

                if(this.searchHeaderData.isActive == false){
                    this.showSubmitApprovalButton = false;
                    this.showButtonGroup = true;
                    this.showAllButton = false;
                    this.foreCastLocal = false;
                    this.forecastPlanRegionView = true;
                    this.inputReadOnly = true;
                    this.showDemandOrder = false;
                    this.showApproveReject = false;
                    this.showreqForEdit = false;
                    this.showApproveUpdatePlan = false;
                    return;
                }

                this.showButtonGroup = true;
                this.foreCastLocal = true;
                this.showreqForEdit = false;
                this.showApproveReject = false;
                this.showAllButton = true;
                if(searchData.regionCheck){
                    this.showSubmitApprovalButton = true;
                    this.showreqForEdit = false;
                    this.showApproveReject = false;
                    this.showApproveUpdatePlan = false;
                    this.showDemandOrder = false;
                    this.forecastPlanRegionView = false;
                    this.inputReadOnly = false;
                }else{
                    this.showSubmitApprovalButton = false;
                    this.showAllButton = false;
                    this.foreCastLocal = false;
                    this.forecastPlanRegionView = true;
                    this.inputReadOnly = true;
                    this.showDemandOrder = false;
                    this.showApproveReject = false;
                    this.showreqForEdit = false;
                    this.showApproveUpdatePlan = false;

                }
                if(searchData.lstDFS.length == 1 && searchData.regionCheck){
                    if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Pending for Approval'){
                        this.showSubmitApprovalButton = false;
                        this.foreCastLocal = false;
                        this.showAllButton = false;
                        this.forecastPlanRegionView = true;
                        this.inputReadOnly = true;   
                        this.showreqForEdit = false;
                        this.showApproveUpdatePlan = false;
                        if(searchData.isApprover){
                            this.showApproveReject = true;
                            this.foreCastLocal = true;
                            this.forecastPlanRegionView = false;
                            this.inputReadOnly = false; 
                            this.showAllButton = true;
                        }
                    }else if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Approved'){
                        this.showSubmitApprovalButton = false;
                        this.foreCastLocal = false;
                        this.forecastPlanRegionView = true;
                        this.inputReadOnly = true;
                        this.showApproveReject = false;
                        if(searchData.regionCheck){
                            this.showreqForEdit = true;
                        }
                        this.showApproveUpdatePlan = false;
                        this.showAllButton = false;
                        if((searchData.lstDFS[0].giic_BatchStatus__c == undefined || searchData.lstDFS[0].giic_BatchStatus__c == 'Failed')){
                            this.showDemandOrder=true;
                        }else if(searchData.lstDFS[0].giic_BatchStatus__c == 'In Progress'){
                            this.showreqForEdit = false;
                        }
                    }else if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Request for update plan'){
                        this.foreCastLocal = false;
                        this.forecastPlanRegionView = true;
                        this.inputReadOnly = true;
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
                        this.showAllButton = true;
                        this.foreCastLocal = true;
                        this.showreqForEdit = false;
                        this.showApproveReject = false;
                        if(searchData.regionCheck){
                            if(searchData.lstDFS[0].giic_ApprovalStatus__c == 'Rejected'){
                                this.showSubmitApprovalButton = true;
                            }else{
                                this.showreqForEdit = true;
                                this.showAllButton = false;
                                this.foreCastLocal = false;
                                this.forecastPlanRegionView = true;
                                this.inputReadOnly = true;
                                this.showSubmitApprovalButton = false;
                            } 
                        }
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
        }
        else if(event.target.value == ''){
            this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].priority = 0;
        }
        else{
            Promise.resolve().then(() => {
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].priority = event.target.value;    
            });
        }
    }

    getPOPriority(event) {
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
        }
        else{
            Promise.resolve().then(() => {
                this.forecastData.prodWrap[event.currentTarget.dataset.indexvar].purposeOrderPriority = event.target.value;    
            });
        }
    }

    getProductPurpose(event) {
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

    getNotesValue(event){
        if(event.detail.value != ''){
            this.forecastData.prodWrap[event.currentTarget.dataset.id].prodNotes = event.target.value;    
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
            }
            else{
                this.forecastData.prodWrap[event.detail.indexvalue].periodQty[event.detail.periodkey] = event.detail.prodValue;
            }
        }
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
                // eslint-disable-next-line no-console
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error'
                }));
            });
        }
    }

    saveAndExit(event) {
        this.isLoaded = true;
        if (this.forecastData) {            
            saveRecord({ productSearch: JSON.stringify(this.forecastData),filterWrapper:JSON.stringify(this.searchHeaderData) })
            .then(result => {
                this.isLoaded = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: "Record has been saved successfully",
                    variant: 'success'
                }));
                return this.navigateToForecastCycleForecastPage(this.cyclerecid);
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

    backToRecord(event){
        return  this.navigateToForecastCycleForecastPage(this.cyclerecid);
      }

    navigateToForecastCycleForecastPage(cyclerecId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: cyclerecId,
                objectApiName: 'gii__DemandForecastCycle__c',
                actionName: 'view'
            }
        });
    }

    saveApprovalDetails(event){
        this.isApprovalShowInformation = false;
    }

    openProductModal(event) {
        this.isProductModalOpen = true;
    }

    closeProductModal(event) {
        this.isProductModalOpen = false; 
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
            submitApproval({ productSearch: JSON.stringify(tempForecastData), filterWrapperStr : JSON.stringify(this.searchHeaderData) })
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
                this.inputReadOnly = true;
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

    appoveForecast(event){
        this.isApprovalShowInformation = true;
    }

    closeApproveModal(event){
        this.isApprovalShowInformation = false;
    }

    closeApproveRejectModal(event){
        this.isApprovalRejectRequest = false;
    }
    
    approveForecastPlan(event){
        if(this.forecastData){
            this.forecastData.approvalComments = this.additionApprovalComment;
            let tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
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
                this.isApprovalShowInformation = false;
                this.forecastData = result;
                this.showAllButton = false;
                this.showreqForEdit = false;
                this.foreCastLocal = false;
                this.forecastPlanRegionView = true;
                this.inputReadOnly = true;
                this.showApproveReject = false;
                if(this.searchHeaderData.lstDFS[0].giic_ApprovalStatus__c == 'Approved' && this.searchHeaderData.regionCheck){
                    this.showDemandOrder = true;
                    this.showreqForEdit = true;
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

    rejectForecastPlan(event){
        if(this.forecastData){
            if(this.rejectionReason == '' || this.rejectionReason == null){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: "Please provide the reason to reject the forecast plan.",
                    variant: 'error'
                }));
                return;
            }else{
                this.forecastData.rejectionComments = this.rejectionReason;
                let tempForecastData = JSON.parse(JSON.stringify(this.forecastData));
                this.isLoaded = true;
                this.isApprovalShowInformation = false;
                rejectDFRec({dfcWrapper :JSON.stringify(this.forecastData),filterWrapperStr : JSON.stringify(this.searchHeaderData)})
                .then(result => {
                    this.isLoaded = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: "Record has been rejected successfully.",
                        variant: 'success'
                    }));
                    this.foreCastLocal = true;
                    this.showButtonGroup = true;
                    this.isApprovalShowInformation = false;
                    this.showAllButton = true;
                    this.showSubmitApprovalButton = true;
                    this.showApproveReject = false;
                    tempForecastData = result;
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
                this.forecastData = tempForecastData;
            }
        }
    }

    approveUpdateForecastPlan(event){
        if(this.forecastData){
            this.forecastData.approvalComments = this.additionApprovalComment;
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
                this.forecastPlanRegionView = false;
                this.inputReadOnly = false;
                this.showApproveReject = false;
                this.showSubmitApprovalButton = true;
                this.showApproveUpdatePlan = false;
                this.showDemandOrder = false;
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
                this.showButtonGroup = true;
                this.showAllButton = true;
                this.forecastData = result;
                this.showreqForEdit = false;
                this.foreCastLocal = true;
                this.forecastPlanRegionView = false;
                this.inputReadOnly = false;
                this.showApproveReject = false;
                this.showSubmitApprovalButton = true;
                this.showApproveUpdatePlan = false;
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

    reqForEdit(event){
        this.isLoaded = true;
        if(this.forecastData){
            this.showDemandOrder = false;
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
                this.showDemandOrder = false;
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

    approveRejectUpdatePlan(event){
        this.isApprovalRejectRequest = true;
    }

    generateDO(event) {
        this.isBatchProcessed = true;
        this.isBatchProcessCompleted =false;
        if(this.forecastData){
            this.showreqForEdit = true;
            updateDOQty({ productSearch: JSON.stringify(this.forecastData) ,filterWrapperStr : JSON.stringify(this.searchHeaderData)})
            .then(result => {
                this._interval = setInterval(() => {  
                    getBatchJobs().then(result =>{
                        let jobStatus =[];
                        jobStatus = result;
                        let totolJobItems=0;
                        let jobProcessedItems=0;
                        let percentCompleted =0;
                        let jobFailed =0;
                        let completedJobs =1;
                        this.isBatchProcessZero = false;
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

    navigateToLineStaging(event) {
        this[NavigationMixin.GenerateUrl]({
             type: 'standard__objectPage',
             attributes: {
                 objectApiName: 'gii__DemandForecastLineStaging__c',
                 actionName: 'home'
             },
             
         }).then(url => { window.open(url) });
     }

    closeModal(event) {
        this.isBatchProcessed = false;
    }

    exportReport(event){
        event.preventDefault();
        event.stopPropagation();
        let cycleId = this.searchHeaderData.planningCycleId;
        let region= this.searchHeaderData.setupRegion;
        let country = this.searchHeaderData.countryVal;
        let le = this.searchHeaderData.leVal;
        getReportId().then(result =>{
            var reportId = result;
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: '/lightning/r/Report/'+reportId+'/view?queryScope=userFolders&fv0='+cycleId+'&fv1='+region
                }
            }) .then(generatedUrl => {
                window.open(generatedUrl);
            });
        })
        //generate URL and op
 
    }

}