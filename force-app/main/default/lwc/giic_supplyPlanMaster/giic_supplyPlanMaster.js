import { LightningElement,track,api,wire } from 'lwc';
import ResultData from '@salesforce/apex/giic_SupplyPlanController.getResultData';
import RecordData from '@salesforce/apex/giic_SupplyPlanController.searchFilterData';
import submitForApproval from '@salesforce/apex/giic_SupplyPlanController.submitForApproval';
import prepareCellHeader from '@salesforce/apex/giic_SupplyPlanController.prepareCellHeader';
import approveRecord from '@salesforce/apex/giic_SupplyPlanController.approveRecord';
import rejectRecord from '@salesforce/apex/giic_SupplyPlanController.rejectRecord';
import requestForEditApproved from '@salesforce/apex/giic_SupplyPlanController.requestForEditApproved';
import updateSupplyPlanNettingLines from '@salesforce/apex/giic_SupplyPlanController.updateSupplyPlanNettingLines';
import updateSPNLQuantity from '@salesforce/apex/giic_SupplyPlanController.updateSPNLQuantity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import SupplyPlanCycle_OBJECT from '@salesforce/schema/gii__SupplyPlanCycle__c';
import createProdPlan from '@salesforce/apex/giic_SupplyPlanController.createProductionPlan';
import getBatchJobs from '@salesforce/apex/giic_SupplyPlanController.getBatchJobStatus';
import getResetWeekBatchJobStatus from '@salesforce/apex/giic_SupplyPlanController.getResetWeekBatchJobStatus';
import getReportId from '@salesforce/apex/giic_SupplyPlanController.getReportId';
import closeQtyModal from '@salesforce/apex/giic_SupplyPlanController.closeQtyModal';
import { refreshApex } from '@salesforce/apex';
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class Giic_supplyPlanMaster extends NavigationMixin(LightningElement) {
    
    @api planCycleId;
    @api PlanYear;
    @api plantype;
    filterData;
    asOfstartdate;
    @track searchHeaderData = [];
    supplyData = [];
    supplyDataWrapperData = [];
    supplyPlanData = [];
    supplyPlanNettingLineData = [];
    showsupplyPlanData;
    showAllButton = false;
    supplyLocal = false;
    supplyPlanRegionView = false;
    showSaveButtons = false;
    showApproveReject = false;
    showSubmitApprovalButton = false;
    howApproveUpdatePlan = false;
    additionApprovalComment;
    rejectionReasonComment;
    isApprovalRejectRequest = false;
    showButtonGroup = false;
    isReadOnly = false;
    showreqForEdit = false;
    showApproveUpdatePlan = false;
    error;
    showprodPlan=false;
    isAnyChange=false;
    supplyqtyerror=false;
    showRecordMessage = false;
    region;
    regionLength;
    countryLength;
    LegalEntityLength;
    prodGroupLength;
    showsubmit = false;
    isLoaded = false;
    @track batchProgressPercent=0;
    isBatchProcessed = false;
    isBatchProcessZero = false;
    isWeekBatchProcessed = false;
    jobProcessed;
    totalItemProcessed;
    failedJobs;
    isBatchProcessCompleted =false;
    showExport = false;
    showQty = false;
    @track QtyData = [];
    superparentindexvar;
    monthindex;
    monthindexsup;
    accap=0;
    usedcap=0;
    wkname = '';
    
    connectedCallback(){
        this.plantype = 'Supply Plan Cycle';
        this.getSearchData(false);
    }
    
    getSearchData(flag,event){
        if(this.region == undefined){
            this.region = '';
        }
        RecordData({recId: this.planCycleId,region : this.region})
        .then((data) => {
            if (data) {
           
            this.filterData = data;
            this.PlanYear = data.objSupplyPlanCycle.Name;
            this.asOfstartdate = data.objSupplyPlanCycle.gii__AsofDate__c;
               if(flag) this.showPlanData(event);
            }
        })
    }

    getSearcHeaderData(event) {
        var flag = false;
        this.searchHeaderData = event.detail.searchCompData;
        this.regionLength = event.detail.searchCompData.lstRegion.length;
        this.countryLength = event.detail.searchCompData.lstCountry.length;
        this.LegalEntityLength = event.detail.searchCompData.lstLegalEntity.length;
        this.prodGroupLength = event.detail.searchCompData.lstProductGroup.length;
        if(event.detail.searchCompData.lstRegion.length == 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: "Please Select a Region",
                variant: 'error'
            }));
            return;
        }
        this.isLoaded = true;
        if(event.detail.searchCompData.lstRegion.length > 0){
            let regionNames = "(";
            for(var i = 0; i < event.detail.searchCompData.lstRegion.length; i++){
                if(i ==event.detail.searchCompData.lstRegion.length - 1){
                    regionNames += "'" + event.detail.searchCompData.lstRegion[i] + "')";
                }else{
                    regionNames += "'" + event.detail.searchCompData.lstRegion[i] + "',";
                }
            }
            this.searchHeaderData.lstRegion = regionNames;
        }else{  
            this.searchHeaderData.lstRegion = '';
        }
        if(this.regionLength == 1){
            for(var i = 0; i < this.searchHeaderData.lstRegion; i++){
                this.region = this.searchHeaderData.lstRegion[i];
            }
            this.region = this.searchHeaderData.lstRegion;
            this.searchHeaderData.setupRegion = this.region;
            if(this.searchHeaderData.setupRegion){
                this.getSearchData(false);
            }  
        }
        if(event.detail.searchCompData.lstCountry.length > 0){
            let countryNames = "(";
            for(var i = 0; i < event.detail.searchCompData.lstCountry.length; i++){
                if(i ==event.detail.searchCompData.lstCountry.length - 1){
                    countryNames += "'" + event.detail.searchCompData.lstCountry[i] + "')";
                }else{
                    countryNames += "'" + event.detail.searchCompData.lstCountry[i] + "',";
                }
            }
            this.searchHeaderData.lstCountry = countryNames;
        }else{
            this.searchHeaderData.lstCountry = '';
        }
        if(event.detail.searchCompData.lstLegalEntity.length > 0){
            let LENames = "(";
            for(var i = 0; i < event.detail.searchCompData.lstLegalEntity.length; i++){
                if(i ==event.detail.searchCompData.lstLegalEntity.length - 1){
                    LENames += "'" + event.detail.searchCompData.lstLegalEntity[i] + "')";
                }else{
                    LENames += "'" + event.detail.searchCompData.lstLegalEntity[i] + "',";
                }
            }
            this.searchHeaderData.lstLegalEntity = LENames;
        }else{
            this.searchHeaderData.lstLegalEntity = '';
        }
        if(event.detail.searchCompData.lstProductGroup.length > 0){
            let PGNames = "(";
            for(var i = 0; i < event.detail.searchCompData.lstProductGroup.length; i++){
                if(i ==event.detail.searchCompData.lstProductGroup.length - 1){
                    PGNames += "'" + event.detail.searchCompData.lstProductGroup[i] + "')";
                }else{
                    PGNames += "'" + event.detail.searchCompData.lstProductGroup[i] + "',";
                }
            }
            this.searchHeaderData.lstProductGroup = PGNames;
        }else{
            this.searchHeaderData.lstProductGroup = '';
        }
        if(event.detail.searchCompData.supplier.length > 0){
            let supplierNames = "(";
            for(var i = 0; i < event.detail.searchCompData.supplier.length; i++){
                if(i ==event.detail.searchCompData.supplier.length - 1){
                    supplierNames += "'" + event.detail.searchCompData.supplier[i] + "')";
                }else{
                    supplierNames += "'" + event.detail.searchCompData.supplier[i] + "',";
                }
            }
            this.searchHeaderData.supplier = supplierNames;
        }else{
            this.searchHeaderData.supplier = '';
        }

        //this.searchHeaderData.asOfDate = this.asOfstartdate;
        prepareCellHeader({filtersearch : JSON.stringify(this.filterData),searchHeaderData : JSON.stringify(this.searchHeaderData) })
        .then((result) => {
            this.supplyData = result;
        }).catch((error) => {
            this.error = error;
        });

        //this.showPlanData(event);
        this.getSearchData(true,event);
    }

    showPlanData(event){
        ResultData({filterWrapStr : JSON.stringify(this.filterData),searchHeaderData : JSON.stringify(this.searchHeaderData)})
        .then((result) => {
            this.isLoaded = false;
            this.showButtonGroup = false;
            this.supplyLocal = false;
            this.isReadOnly = false;
            this.showSubmitApprovalButton = false;
            this.showreqForEdit = true;
            this.showSaveButtons = true;
            this.showApproveReject = false;
            this.showApproveUpdatePlan = false;
            this.showprodPlan = false;
            this.showRecordMessage = false;
            this.showsupplyPlanData = false;
            if(result.length > 0){
                this.supplyDataWrapperData = result;
                if(this.regionLength > 1){
                    this.showButtonGroup = true;
                    this.supplyLocal = true;
                    this.isReadOnly = true;
                    this.showsupplyPlanData = true;
                    this.showSubmitApprovalButton = false;
                }else if(this.regionLength == 1){
                  if(this.filterData.objDemandForecastSetup == undefined ){
                        this.showButtonGroup = true;
                        this.showSubmitApprovalButton = true;
                        this.showExport = true;
                        this.showreqForEdit = true;
                        this.showsupplyPlanData = true;
                        this.supplyLocal = true;
                        this.isReadOnly = false;
                        this.showApproveUpdatePlan = false;
                        this.showSaveButtons = false;
                        this.showSubmitApprovalButton = true;
                        this.showExport = true;
                        this.showApproveReject = false;
                        this.showprodPlan = false;
                }else if(this.filterData.objDemandForecastSetup != null && this.filterData.objDemandForecastSetup.giic_ApprovalStatus__c == 'Pending for Approval'){
                        this.showprodPlan = false;
                        this.showButtonGroup = true;
                        this.showSubmitApprovalButton = false;
                        this.showsupplyPlanData = true;
                        this.supplyLocal = true;
                        this.isReadOnly = true;
                        this.showSaveButtons = true;
                        this.showreqForEdit = true;
                        this.showApproveUpdatePlan = false;
                        if(this.filterData.isApprover){
                            this.showApproveReject = true;
                            this.isReadOnly = false;
                            this.showSaveButtons = false;
                        }
                    }else if(this.filterData.objDemandForecastSetup != null && this.filterData.objDemandForecastSetup.giic_ApprovalStatus__c == 'Approved'){
                        this.showreqForEdit = false;
                        this.showSaveButtons = true;
                        this.isReadOnly = true;
                        this.showsupplyPlanData = true;
                        this.supplyLocal = true;
                        this.showButtonGroup = true;
                        this.showSubmitApprovalButton = false;
                        this.showreqForEdit = false;
                        this.showExport = true;
                        if(this.filterData.objDemandForecastSetup.giic_BatchStatus__c== undefined || this.filterData.objDemandForecastSetup.giic_BatchStatus__c=='' || this.filterData.objDemandForecastSetup.giic_BatchStatus__c=='Failed'){
                            this.showprodPlan = true; //Added by akash
                        }
                        else if(this.filterData.objDemandForecastSetup.giic_BatchStatus__c== 'In Progress'){
                            this.showreqForEdit = true;
                        }
                    }else if(this.filterData.objDemandForecastSetup != null && this.filterData.objDemandForecastSetup.giic_ApprovalStatus__c == 'Rejected'){
                        this.showSubmitApprovalButton = true;
                        this.showExport = true;
                        this.showreqForEdit = true;
                        this.isReadOnly = false;
                        this.showsupplyPlanData = true;
                        this.supplyLocal = true;
                        this.showButtonGroup = true;
                        this.showSaveButtons = false;
                    }else if(this.filterData.objDemandForecastSetup != null && this.filterData.objDemandForecastSetup.giic_ApprovalStatus__c == 'Reject for update plan'){
                        this.showSubmitApprovalButton = false;
                        this.showreqForEdit = false;
                        this.isReadOnly = true;
                        this.showsupplyPlanData = true;
                        this.supplyLocal = true;
                        this.showButtonGroup = true;
                        this.showSaveButtons = false;
                    }
                    else if(this.filterData.objDemandForecastSetup != null && this.filterData.objDemandForecastSetup.giic_ApprovalStatus__c == 'Request for update plan'){
                        this.showreqForEdit = true;
                        this.showButtonGroup = true;
                        this.showSaveButtons = true;
                        this.isReadOnly = true;
                        this.showsupplyPlanData = true;
                        this.supplyLocal = true;
                        this.showSubmitApprovalButton = false;
                        this.showreqForEdit = true;
                        if(this.filterData.isApprover){
                            this.showApproveUpdatePlan = true;
                        }
                    }else if(this.filterData.objDemandForecastSetup != null && this.filterData.objDemandForecastSetup.giic_ApprovalStatus__c == 'Approved for update plan'){
                        this.showButtonGroup = true;
                        this.showSubmitApprovalButton = true;
                        this.showreqForEdit = true;
                        this.showsupplyPlanData = true;
                        this.supplyLocal = true;
                        this.isReadOnly = false;
                        this.showApproveUpdatePlan = false;
                        this.showSaveButtons = false;
                        this.showApproveReject = false;
                        this.showprodPlan = false;
                    }
                }
            }else{
                this.showRecordMessage = true;
                this.showsupplyPlanData = false;
                this.showButtonGroup = false;
            }
            
          
             //Rajnish-16 dec
            /* var isLess;
            var styleColor;
            result.forEach(recordI => {
	        isLess = recordI.totalSupplyQuantity < recordI.totalDemandOrderQuantity;
	        styleColor = isLess ? 'background-color:red' : 'backrgound-color:none';
	        this.supplyDataWrapperData.push({"styleColor" : styleColor, "record" : recordI});
            })  */
            //  
        }).catch((error) => {
            this.error = error;
        });
    }

    exportSupplyPlan(event){

    }

    appoveForecast(event){

    }

    saveSupplyPlan(event){
        if (this.supplyPlanNettingLineData.length > 0) {
            for(let i = 0;i < this.supplyPlanNettingLineData.length;i++){
                let isDecimal = this.supplyPlanNettingLineData[i].orderQuantity % 1 != 0;
                if(this.supplyPlanNettingLineData[i].orderQuantity < 0 || isDecimal){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Please select correct order quantity",
                        variant: 'error'
                    }));
                    return false;
                }
            }
        }
        this.showQty = false;
        this.isLoaded = true;
        if(this.supplyPlanData.length > 0){
            updateSupplyPlanNettingLines({spnWrapperJSON: JSON.stringify(this.supplyPlanData),
                filterWrapStr : JSON.stringify(this.filterData)})
            .then((result) => {
                this.supplyPlanNettingLineData = [];
                
                if(result){
                   // this.supplyDataWrapperData = [];
                    this.supplyDataWrapperData = result;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: "Record has been saved successfully",
                        variant: 'success'
                    }));
                    this.isLoaded=false;
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Supply Plan Netting cannot be saved",
                        variant: 'error'
                    }));
                    this.isLoaded=false;
                }
            }).catch((error) => {
                this.isLoaded=false;
            });
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'info!',
                message: "Please change the data then save",
                variant: 'info'
            }));
            this.isLoaded=false;
        }
    }

    saveExitSupplyPlan(event){        
        if(this.supplyPlanNettingLineData.length > 0){
            for(let i = 0;i < this.supplyPlanNettingLineData.length;i++){
                let isDecimal = this.supplyPlanNettingLineData[i].orderQuantity % 1 != 0;
                if(this.supplyPlanNettingLineData[i].orderQuantity < 0 || isDecimal){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Please select correct order quantity",
                        variant: 'error'
                    }));
        
                    return false;
                }
            }
        }
        this.isLoaded=true;
        if(this.supplyPlanData.length > 0){
            updateSupplyPlanNettingLines({spnWrapperJSON: JSON.stringify(this.supplyPlanData),
                filterWrapStr : JSON.stringify(this.filterData)})
            .then((result) => {
                this.supplyPlanNettingLineData = [];
                if(result){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: "Record has been saved successfully",
                        variant: 'success'
                    }));
                    this.isLoaded=false;
                    this.navigateToSupplyPlanCycleForecastPage(this.planCycleId);
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Supply Plan Netting cannot be saved",
                        variant: 'error'
                    }));
                    this.isLoaded=false;
                }
            }).catch((error) => {
                console.log('error>>'+error);
                this.isLoaded=false;
            });
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'info!',
                message: "Please change the data then save",
                variant: 'info'
            }));
            this.isLoaded=false;
        }
        
    }

    navigateToSupplyPlanCycleForecastPage(supplyPlanCycleId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: supplyPlanCycleId,
                objectApiName: SupplyPlanCycle_OBJECT.objectApiName,
                actionName: 'view'
            }
        });        
    }

    submitRecordForApprovalModal(event){
        this.showsubmit = true;
    }

    closesubmitapprovalModal(event){
        this.showsubmit = false;
    }

    submitRecordForApproval(event){
        this.showsubmit = false;
        if(this.supplyPlanNettingLineData.length > 0){
            for(let i = 0;i < this.supplyPlanNettingLineData.length;i++){
                let isDecimal = this.supplyPlanNettingLineData[i].orderQuantity % 1 != 0;
                if(this.supplyPlanNettingLineData[i].orderQuantity < 0 || isDecimal){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Please select correct order quantity",
                        variant: 'error'
                    }));
        
                    return false;
                }
            }
        }
        this.isLoaded=true;
        this.filterData.regionName = this.region;
        submitForApproval({spnWrapperJSON: JSON.stringify(this.supplyDataWrapperData),
            nettingLinesStr : JSON.stringify(this.supplyPlanNettingLineData),
            filterWrapStr : JSON.stringify(this.filterData)})
        .then((result) => {
            this.supplyPlanNettingLineData = [];
            if(result){
                this.showSaveButtons = true;
                this.isReadOnly = true;
                this.showSubmitApprovalButton = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: "Request has been submitted Successfully",
                    variant: 'success'
                }));
                this.isLoaded=false;
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: "Request got failed",
                    variant: 'error'
                }));
                this.isLoaded=false;
            }
        }).catch((error) => {
            console.log('error>>'+error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error,
                variant: 'error'
            }));
            this.isLoaded=false;
        });
    }

    reqForEdit(event){
        this.isLoaded=true;
        this.showprodPlan = false;
        requestForEditApproved({filterWrapStr : JSON.stringify(this.filterData)})
            .then((result) => {
                if(result){
                    this.showreqForEdit = true;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: "Request has been submitted Successfully",
                        variant: 'success'
                    }));
                    this.isLoaded=false;
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Request got failed",
                        variant: 'error'
                    }));
                    this.isLoaded=false;
                }
                
               // this.supplyData = result;
            }).catch((error) => {
                console.log('error>>',error);
                this.error = error;
                this.isLoaded=false;
            });
    }

    approveRejectUpdatePlan(event){
        this.isApprovalRejectRequest = true;
    }

    backToRecord(event){
        this.navigateToSupplyPlanCycleForecastPage(this.planCycleId);
    }

    closeApproveModal(event){

    }

    getAprovalComment(event){
        this.additionApprovalComment = event.detail.value;
    }


    getRejectionReason(event){
        this.rejectionReasonComment = event.detail.value;
    }


    closeApproveRejectModal(event){
        this.isApprovalRejectRequest = false;
    }

    approveSupplyPlan(event){
        
        let commentVal = this.additionApprovalComment != null ? this.additionApprovalComment : '';        
        if(this.supplyPlanNettingLineData.length > 0){
            for(let i = 0;i < this.supplyPlanNettingLineData.length;i++){
                let isDecimal = this.supplyPlanNettingLineData[i].orderQuantity % 1 != 0;
                if(this.supplyPlanNettingLineData[i].orderQuantity < 0 || isDecimal){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Please select correct order quantity",
                        variant: 'error'
                    }));
        
                    return false;
                }
            }
        } 
        this.isLoaded=true;
        approveRecord({spnWrapperJSON : JSON.stringify(this.supplyDataWrapperData),
            filterWrapStr : JSON.stringify(this.filterData),
            comment : commentVal,isAnyRecordUpdate:this.isAnyChange,planCycleId:this.planCycleId})
            .then((result) => {
                this.isApprovalRejectRequest = false;
                if(result){
                    this.isReadOnly = true;
                    this.showreqForEdit = true;
                    this.showSaveButtons = true;
                    this.showApproveReject = false;
                    this.showApproveUpdatePlan = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: "Supply Plan has been Approved",
                        variant: 'success'
                    }));
                    this.isLoaded=false;
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Request got failed",
                        variant: 'error'
                    }));
                    this.isLoaded=false;
                }
               // this.supplyData = result;
            }).catch((error) => {
                console.log('error>>',error);
                this.error = error;
                this.isLoaded=false;
            });
    
    }

    rejectSupplyPlan(event){
        let commentVal = this.rejectionReasonComment != null ? this.rejectionReasonComment : '';
       
        if(commentVal != ''){
            rejectRecord({spnWrapperJSON : JSON.stringify(this.supplyDataWrapperData),
                filterWrapStr : JSON.stringify(this.filterData),
                comment : commentVal,isAnyRecordUpdate:this.isAnyChange})
                .then((result) => {
                    this.isApprovalRejectRequest = false;
                    if(result){
                        this.isReadOnly = false;
                        this.showreqForEdit = true;
                        this.showSaveButtons = false;
                        this.showApproveReject = false;
                        this.showApproveUpdatePlan = false;
                        this.showSubmitApprovalButton = true;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success!',
                            message: "Request has been Rejected",
                            variant: 'success'
                        }));
                    }else{
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error!',
                            message: "Request got failed",
                            variant: 'error'
                        }));
                    }
                   // this.supplyData = result;
                }).catch((error) => {
                    console.log('error>>',error);
                    this.error = error;
                });
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: "Please Provide the comment",
                variant: 'error'
            }));
        }
        
    }

    getWeekData(event) { 
        this.showQty = true;
        this.isReadOnly = false;
        this.superparentindexvar = parseInt(event.currentTarget.dataset.superparenrindexvar);    
        this.monthindex = parseInt(event.currentTarget.dataset.monthindex);
        this.monthindexsup = parseInt(event.currentTarget.dataset.monthindexsup);
        let data = JSON.parse(JSON.stringify(this.supplyDataWrapperData));
        this.QtyData = data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList;
    }

    closeQtyModal(event){
        this.showQty = false;
    }

    handleOrderValue(event){
        let splineindex = parseInt(event.currentTarget.dataset.spnlindex);
        let data = JSON.parse(JSON.stringify(this.supplyDataWrapperData));
        
        let oldOrderQty = data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList[splineindex]['orderQuantity'];
        let newOrderQty = (event.detail.value != '' ? parseInt(event.detail.value) : 0);
        if(oldOrderQty != newOrderQty){
            /*if(oldOrderQty > newOrderQty){
                let qty = oldOrderQty - newOrderQty;
                data[this.superparentindexvar]['totalSupplyQuantity'] = data[this.superparentindexvar]['totalSupplyQuantity'] - qty;
            }else{
                let qty = newOrderQty - oldOrderQty;
                data[this.superparentindexvar]['totalSupplyQuantity'] = data[this.superparentindexvar]['totalSupplyQuantity'] + qty;
            }*/
           
            data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList[splineindex]['orderQuantity'] = newOrderQty;
            data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList[splineindex]['isChanged'] = true;
        
            let nettinglinelength = data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList.length;
            let totalOrderQty = 0;
            for(let i=0;i<nettinglinelength;i++){
                totalOrderQty += data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList[i]['orderQuantity'];
            }
            //data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup]['supplyQuantityofMonth'] = totalOrderQty;
           // console.log('qwerwq' + data[superparentindexvar].supplyPlanNettingMonthList[monthindex]['demandOrderQuantityTotal']);
            /*if(data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup]['supplyQuantityofMonth'] > data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex]['demandOrderQuantityTotal']) {
                this.supplyqtyerror = true;
            }
            else {
                this.supplyqtyerror = false;
            }*/
            let isNotContain = true;
            if(this.supplyPlanNettingLineData.length > 0){
                for(let j=0;j<this.supplyPlanNettingLineData.length;j++){
                    if(this.supplyPlanNettingLineData[j].id == data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList[splineindex].id){
                        this.supplyPlanNettingLineData[j]['orderQuantity'] = parseInt(event.detail.value);
                        isNotContain = false;
                    }
                }

                if(isNotContain){
                    this.supplyPlanNettingLineData.push(data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList[splineindex]);
                }
            }else{
                this.supplyPlanNettingLineData.push(data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList[splineindex]);
            }
            

            this.supplyPlanData = data;
            this.supplyDataWrapperData = data;
            this.isAnyChange = true;
        }
        
    }

    handleNotesValue(event){
        let superparentindexvar = parseInt(event.currentTarget.dataset.superparenrindexvar);
        let oldNotesVal = this.supplyDataWrapperData[superparentindexvar]['notes'];

        let data = JSON.parse(JSON.stringify(this.supplyDataWrapperData));
        if(oldNotesVal != event.detail.value){
            data[superparentindexvar]['notes'] = event.detail.value;
            this.supplyPlanData = data;
            this.supplyDataWrapperData = data;
            this.isAnyChange = true;
        }

        
    }

    // isInputValid() {
    //     let isValid = true;
    //     let inputFields = this.template.querySelectorAll('.inputorder');
    //     inputFields.forEach(inputField => {
    //         if(!inputField.checkValidity()) {
    //             inputField.reportValidity();
    //             isValid = false;
    //         }
    //         this.contact[inputField.name] = inputField.value;
    //     });
    //     return isValid;
    // }

    createPP(event) {
        this.isBatchProcessed = false;
        if (this.supplyPlanNettingLineData) {
            this.filterData.regionName = this.region;
            createProdPlan({filterWrapStr : JSON.stringify(this.filterData)})
            .then(result => {
              this.showSaveButtons = true;
              this.showreqForEdit = true;
              this.showSubmitApprovalButton = false;
              this.showApproveReject = false;
              this.showApproveUpdatePlan = false;
              this.showButtonGroup = true;
              this.isBatchProcessed = true;
              this.isBatchProcessCompleted =false;
              this.jobProcessed =0;
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
               var isCompleted =false;
               if(jobStatus.length >0){
               for(let i=0;i<jobStatus.length;i++)
                {
                    totolJobItems =jobStatus.length;
                    if(jobStatus[i].Status =='Completed'){
                        jobProcessedItems = completedJobs++;     
                        isCompleted = true;                  
                      }
                    if(jobStatus[i].Status == 'Failed'){
                        jobFailed += jobStatus[i].NumberOfErrors; 
                    }
                }
                this.jobProcessed = jobProcessedItems;
                this.totalItemProcessed = totolJobItems;
                this.failedJobs = jobFailed;
                if(jobProcessedItems == 0 && isCompleted == true){
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
                console.log('error>>',error);
                this.error = error;
            });
        
            this.showprodPlan=false; 
        }
    }
    closeModal(event) {
        this.isBatchProcessed = false;
    }
    closeBatchModal(event){
        this.isWeekBatchProcessed = false;
        ResultData({filterWrapStr : JSON.stringify(this.filterData),searchHeaderData : JSON.stringify(this.searchHeaderData)})
        .then((result) => {
            if(result.length > 0){
                this.supplyDataWrapperData = result;
            }
        }).catch((error) => {
            console.log('error>>',error);
            this.error = error;
        });
        
    }
    exportReport(event){
        event.preventDefault();
        event.stopPropagation();
        let cycleId = this.planCycleId;
        let region= this.searchHeaderData.lstRegion;
        getReportId().then(result =>{
            var reportId = result;
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: '/lightning/r/Report/'+reportId+'/view?queryScope=userFolders&fv0='+cycleId+'&fv1='+region.substring(2,region.length-2)
                }
            }) .then(generatedUrl => {
                window.open(generatedUrl);
            });
        })
        //generate URL and op
 
    }
    saveSupplyPlanNettingLine(event){
        this.isWeekBatchProcessed = false;
        if (this.supplyPlanNettingLineData.length > 0) {
            for(let i = 0;i < this.supplyPlanNettingLineData.length;i++){
                let isDecimal = this.supplyPlanNettingLineData[i].orderQuantity % 1 != 0;
                if(this.supplyPlanNettingLineData[i].orderQuantity < 0 || isDecimal){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Please select correct order quantity",
                        variant: 'error'
                    }));
                    return false;
                }
            }
        }
        //this.showQty = false;
        this.isLoaded = true;
        if(this.supplyPlanData.length > 0){
            this.QtyData = this.supplyPlanNettingLineData;
            updateSPNLQuantity({spnlWrapperJSON: JSON.stringify(this.QtyData),
                filterWrapStr : JSON.stringify(this.filterData),searchHeaderData : JSON.stringify(this.searchHeaderData)})
            .then((result) => {
                this.supplyPlanNettingLineData = [];
                if(result){
                   // this.supplyDataWrapperData = [];
                    this.supplyDataWrapperData = result;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: "Record has been saved successfully",
                        variant: 'success'
                    }));
                    this.showQty = false;
                    this.isLoaded=false;
                    this.isWeekBatchProcessed = true;
                    this.isBatchProcessCompleted =false;
                    this.jobProcessedItems = false;
                    this.isBatchProcessZero =false;
                    this.jobProcessed = 0;
                    this._interval = setInterval(() => {  
                    getResetWeekBatchJobStatus().then(result =>{
                     let jobStatus =[];
                     jobStatus = result;
                     let totolJobItems=0;
                     let jobProcessedItems=0;
                     let percentCompleted =0;
                     let jobFailed =0;
                     let completedJobs =1;
                     if(jobStatus.length >0){
                     for(let i=0;i<jobStatus.length;i++)
                      {
                          totolJobItems =jobStatus.length;
                          if(jobStatus[i].Status =='Completed'){
                              jobProcessedItems = completedJobs++;                        
                            }
                          if(jobStatus[i].Status == 'Failed'){
                              jobFailed += jobStatus[i].NumberOfErrors; 
                          }
                      }
                      this.jobProcessed = jobProcessedItems;
                      this.totalItemProcessed = totolJobItems;
                      this.failedJobs = jobFailed;
                     
                      if(totolJobItems!=0 && jobProcessedItems!=0){
                        percentCompleted = jobProcessedItems/ totolJobItems * 100;
                        this.batchProgressPercent = percentCompleted;
                      }
                      if(jobProcessedItems == 0){
                          this.isBatchProcessZero = true;
                          this.batchProgressPercent === 100
                      }
                      if ( this.batchProgressPercent === 100 ) {
                            this.isBatchProcessCompleted = true;
                          clearInterval(this._interval);  
                      } 
                     }
                    }).catch((error) =>{
                        console.log('error=>'+JSON.stringify(error));
                    });
                   }, 2000);

                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: "Supply Plan Netting cannot be saved",
                        variant: 'error'
                    }));
                    this.isLoaded=false;
                }
            }).catch((error) => {
                //this.QtyData = data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList;;
                console.log('error34'+JSON.stringify(error));
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error'
                }));
                let data = JSON.parse(JSON.stringify(this.supplyDataWrapperData));
                this.QtyData = data[this.superparentindexvar].supplyPlanNettingMonthList[this.monthindex].supplyPlanNettingLineSupplierWarpperList[this.monthindexsup].spnlWrapperList;
                this.isLoaded=false;
            });
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'info!',
                message: "Please change the data then save",
                variant: 'info'
            }));
            this.isLoaded=false;
        }
    }

}