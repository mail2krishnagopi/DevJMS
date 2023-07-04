import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import skuReport from '@salesforce/label/c.giic_SKUReportId';
import subcatoneReport from '@salesforce/label/c.giic_SubCat1ReportId';
import subcattwoReport from '@salesforce/label/c.giic_SubCat2ReportId';
import filterData from '@salesforce/apex/giic_CommonSearchFilterCtlr.searchFilterData';
import getRegionDFS from '@salesforce/apex/giic_CommonSearchFilterCtlr.getRegionDemandForecastSetup';

export default class Giic_commonSearchFilter extends NavigationMixin(LightningElement) {
    @api plancycleid;
    plancyclename;
    @api planname;
    @api objectname;
    @api searchresultdata;
    @api showSupplier = false;
    @api showSupplyPlan = false;
    legalEntityValue;
    warehouseValue;
    productionLine;
    productionLineId;
    supplier='';
    supplierId='';
    isModalOpen = false;
    noOfPeriod;
    asOfDate;
    isLoaded =false;
    @api validatefilter=false;
    @api filterlist=[];
    @api showfilterlist =[];
    @api hidefilters =[];
    @api requiredfilters =[];
    showCountry=false;
    showProductCategory=false;
    //showSupplier=false;
    showSearchText=false;
    showLegalEntity=false;
    showWarehouse=false;
    showSearchby=false;
    showNumberOfPeriod=false;
    showAsOfDate=false;
    @api forecastPlan = false;
    supplierValue;
    noOfSKUPeriod;
    @track warehouseValues = [];
    countryLegalEntitydata = [];
    @track countriesList = []
    @track legalEntitiesList = [];
    @track regiondata = [];
    lstRegionSelected = [];
    lstCountrySelected = [];
    lstLegalEntitySelected = [];
    lstWarehouseSelected = [];
    regioncountrydata = [];
    @track supplierData =[];
    @track lstSupplierSelected = [];
    @track productValue;
    @track productValueId;
    @track skuVal = '';
    region='';
    country = '';
    legalentity = '';
    @track subCategory2Val = '';
    @track subCategory1Val = '';
    @track lstProductGroupSelected = [];
    @track productGroups = [];
    @track wareName;
    @track wareRecordId;
    asOfDateVal;
    
    connectedCallback()
    {
        var today = new Date();
        this.asOfDate=today.getFullYear() + '-' + (today.getMonth()+1) +'-'+today.getDate();
        this.getFilterData();
    }

    handleRegionChange(event){
        this.lstRegionSelected = event.detail.value;
        this.getCountryData();
    }

    getCountryData(event){
        this.countriesList=[];
        if(this.lstRegionSelected){
            for(let key in this.regioncountrydata){
                for(let key1 in this.lstRegionSelected){
                    if(this.regioncountrydata[key].key == this.lstRegionSelected[key1]){
                        this.countriesList.push({label:this.regioncountrydata[key].value,value:this.regioncountrydata[key].value});
                    }
                }
            }
        }
    }
    handleCountryChange(event){        
        this.lstCountrySelected = event.detail.value;
        if(this.lstCountrySelected){
            this.getLegalEnity(event);
        }
    }

    getLegalEnity(){
        this.legalEntitiesList = [];
        this.lstLegalEntitySelected = [];
        if(this.lstCountrySelected.length){
            for(let key in this.countryLegalEntitydata){
                for(let k in this.lstCountrySelected){
                    if(this.countryLegalEntitydata[key].key == this.lstCountrySelected[k]){
                        for(let i in this.countryLegalEntitydata[key].value){
                            this.legalEntitiesList.push({label:this.countryLegalEntitydata[key].value[i],value:this.countryLegalEntitydata[key].value[i]});
                        }
                    }
                }
            }
        }
    }

    handleLegalEntitiesChange(event){
        this.lstLegalEntitySelected = event.target.value;
    }

    handleSupplierChange(event){
        this.lstSupplierSelected = event.target.value;
    }

    navigateToSKUReport(event) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/Report/'+skuReport+'/view?queryScope=userFolders&fv0='+this.plancycleid+'&fv1='+this.lstRegionSelected
            }
        }) .then(generatedUrl => {
            window.open(generatedUrl);
        });
        // this[NavigationMixin.GenerateUrl]({
        //      type: 'standard__recordPage',
        //      attributes: {
        //          recordId: skuReport,
        //          objectApiName: 'Report',
        //          actionName: 'view'
        //      },
             
        //  }).then(url => { window.open(url) });
     }
      
     navigateToSubCatOneReport(event) {
        // if(this.lstRegionSelected.length > 0){
        //     console.log('this.lstRegionSelected.length'+this.lstRegionSelected);
        // }
        // return;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/Report/'+subcatoneReport+'/view?queryScope=userFolders&fv0='+this.plancycleid+'&fv1='+this.lstRegionSelected
            }
        }) .then(generatedUrl => {
            window.open(generatedUrl);
        });
        //  this[NavigationMixin.GenerateUrl]({
        //       type: 'standard__recordPage',
        //       attributes: {
        //           recordId:  subcatoneReport,
        //           objectApiName: 'Report',
        //           actionName: 'view'
        //       },
              
        //   }).then(url => { window.open(url) });
      }
 
     navigateToSubCatTwoReport(event) {
         // event.stopPropagation();
         this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/Report/'+subcattwoReport+'/view?queryScope=userFolders&fv0='+this.plancycleid+'&fv1='+this.lstRegionSelected
            }
        }) .then(generatedUrl => {
            window.open(generatedUrl);
        });
        //   this[NavigationMixin.GenerateUrl]({
        //       type: 'standard__recordPage',
        //       attributes: {
        //           recordId:  subcattwoReport,
        //           objectApiName: 'Report',
        //           actionName: 'view'
        //       },
              
        //   }).then(url => { window.open(url) });
      }
     
    
    handleClick(event) {
        this.isModalOpen = true;
    }

    closeModal(event) {
        this.isModalOpen = false;
    }
    
    getFilterData(event)
    {
        filterData({recId : this.plancycleid,objectApiName : this.objectname})
        .then(data => {
            this.searchresultdata = data;
            for(let region in data.mapRegionCountry){
                this.regiondata.push({
                    label:region,
                    value:region
                });
                for(let key1 in data.mapRegionCountry[region]){
                   this.regioncountrydata.push({                       
                       key:region,
                       value:key1
                    });
                    for(let k in data.mapRegionCountry[region][key1]){
                        this.countryLegalEntitydata.push({key:key1,value:data.mapRegionCountry[region][key1]});
                        break;
                    }
                }
            }

            for(let prod in data.lstProductGroups){
                this.productGroups.push({
                    label:data.lstProductGroups[prod].Name,
                    value:data.lstProductGroups[prod].Name
                })
            }
            for(let supp in data.lstAccout){
                this.supplierData.push({
                    label:data.lstAccout[supp].Name,
                    value:data.lstAccout[supp].Id
                })
            }
            
            this.plancyclename = this.searchresultdata.planningCycleName;
            this.asOfDateVal = data.startDate;
            this.asOfDate= data.asOfDate;
            this.noOfPeriod = this.searchresultdata.numOfPeriods;   
            this.noOfSKUPeriod = this.searchresultdata.noOfSkU;
        })
        .catch(error => {
            // eslint-disable-next-line no-console
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'Error occured',
                variant: 'error'
            }));
        });
    }

    handleWarehouseChange(event){
        this.warehouseValue = event.detail.value;
    }

    onProductionLineSelection(event){
        this.productionLine = event.detail.selectedvalue;
        this.productionLineId = event.detail.selectedRecordId;
    }

    onProdSelection(event){
        this.productValue = event.detail.selectedvalue;
        this.productValueId = event.detail.selectedRecordId;
    }

    onSupplierSelection(event){
        this.supplierId = event.detail.selectedRecordId;
        this.supplierValue = event.detail.selectedvalue;
    }
    onWareSelection(event){
        this.wareName = event.detail.selectedvalue;
        this.wareRecordId = event.detail.selectedRecordId;
    }
    getSKUValue(event){
        this.skuVal = event.detail.value;
    }

    getSubCat2Value(event){
        this.subCategory2Val = event.detail.value;
    }

    getSubCat1Value(event){
        this.subCategory1Val = event.detail.value;
    }

    onCategorySelection(event){
        this.lstProductGroupSelected = event.target.value;
    }

    submitDetails(event) {
        this.isModalOpen = false;
        if(this.searchresultdata){
            this.searchPlan();
        }
    }

    getPeriodValue(event) {
        this.noOfPeriod = event.detail.value;
    }

    
    getAsofDate(event){
        this.asOfDate = event.target.value;
    }

    resetModal(event){
        this.lstProductGroupSelected = [];
        this.wareName = '';
        this.productValue = '';
        this.skuVal = '';
        this.noOfPeriod = this.searchresultdata.numOfPeriods;
        this.subCategory2Val = '';
        this.subCategory1Val = '';
        this.asOfDate = this.asOfDateVal;
    }

    searchPlan(event) {
        let dataToSearch = [];
        dataToSearch = JSON.parse(JSON.stringify(this.searchresultdata));
 
        if(this.lstRegionSelected.length == 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: "Please Select a Region",
                variant: 'error'
            }));
            return;
        }
        if(this.asOfDate < this.asOfDateVal){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'As of Date cannot be less than Start Date',
                variant: 'error'
            }));
            this.asOfDate = this.asOfDateVal;
            return;
        }else if(this.asOfDate == '' || this.asOfDate == undefined){
            this.asOfDate = this.asOfDateVal;
        }
        this.isLoaded =true;
          
        dataToSearch.regionCheck = false;
        dataToSearch.setupRegion = '';
        dataToSearch.isApprover = false;
        dataToSearch.lstDFS = [];
        dataToSearch.isValidation = false;
        if (dataToSearch) {
            dataToSearch.forecastValue = this.forecastYear;
            dataToSearch.selectedWarehouse.Id = this.wareRecordId;
            dataToSearch.searchProductName = this.productValueId;
            dataToSearch.subCategory1Value = this.subCategory1Val;
            dataToSearch.subCategory2Value = this.subCategory2Val;
            dataToSearch.skuVal = this.skuVal;                
            dataToSearch.numOfPeriods = this.noOfPeriod;
            dataToSearch.asOfDate = this.asOfDate;
            dataToSearch.planName = this.planname;
            dataToSearch.searchSupplierName = this.supplierId;
            dataToSearch.productionLine = this.productionLine;

            if(this.lstRegionSelected.length > 0){
                let regionNames = "(";
                for(var i = 0; i < this.lstRegionSelected.length; i++){
                    if(i ==this.lstRegionSelected.length - 1){
                        regionNames += "'" + this.lstRegionSelected[i] + "')";
                    }else{
                        regionNames += "'" + this.lstRegionSelected[i] + "',";
                    }
                }
                dataToSearch.lstRegion = regionNames;
            }
            
            if(this.lstRegionSelected.length == 1){
                for(var i = 0; i < this.lstRegionSelected.length; i++){
                    this.region = this.lstRegionSelected[i];
                }
                dataToSearch.setupRegion = this.region;
                dataToSearch.regionCheck = true;
            }

            if(this.lstCountrySelected.length > 0){
                let countryNames = "(";
                for(var i = 0; i < this.lstCountrySelected.length; i++){
                    if(i ==this.lstCountrySelected.length - 1){
                        countryNames += "'" + this.lstCountrySelected[i] + "')";
                    }else{
                        countryNames += "'" + this.lstCountrySelected[i] + "',";
                    }
                }
                dataToSearch.lstCountry = countryNames;
            }
            else{
                dataToSearch.lstCountry = '';
            }

            if(this.lstCountrySelected.length == 1){
                for(var i = 0; i < this.lstCountrySelected.length; i++){
                    this.country = this.lstCountrySelected[i];
                }
                dataToSearch.countryVal = this.country;
            }

            if(this.lstLegalEntitySelected.length > 0){
                let LENames = "(";
                for(var i = 0; i < this.lstLegalEntitySelected.length; i++){
                    if(i ==this.lstLegalEntitySelected.length - 1){
                        LENames += "'" + this.lstLegalEntitySelected[i] + "')";
                    }else{
                        LENames += "'" + this.lstLegalEntitySelected[i] + "',";
                    }
                }
                dataToSearch.lstLegalEntity = LENames;
            }
            else{
                dataToSearch.lstLegalEntity = '';
            }

            if(this.lstLegalEntitySelected.length == 1){
                for(var i = 0; i < this.lstLegalEntitySelected.length; i++){
                    this.country = this.lstLegalEntitySelected[i];
                }
                dataToSearch.leVal = this.legalentity;
            }

            if(this.lstProductGroupSelected.length > 0){
                let PGNames = "(";
                for(var i = 0; i < this.lstProductGroupSelected.length; i++){
                    if(i ==this.lstProductGroupSelected.length - 1){
                        PGNames += "'" + this.lstProductGroupSelected[i] + "')";
                    }else{
                        PGNames += "'" + this.lstProductGroupSelected[i] + "',";
                    }
                }
                dataToSearch.lstProductGroup = PGNames;
            }else{
                dataToSearch.lstProductGroup = '';
            }
            if(this.lstWarehouseSelected.length > 0){
                let WHNames = "(";
                for(var i = 0; i < this.lstWarehouseSelected.length; i++){
                    if(i ==this.lstWarehouseSelected.length - 1){
                        WHNames += "'" + this.lstWarehouseSelected[i] + "')";
                    }else{
                        WHNames += "'" + this.lstWarehouseSelected[i] + "',";
                    }
                }
                dataToSearch.lstWarehouse = WHNames;
            }
            else{
                dataToSearch.lstWarehouse = '';
            }

            if(this.lstSupplierSelected.length > 0){
                let supplierNames = "(";
                for(var i = 0; i < this.lstSupplierSelected.length; i++){
                    if(i ==this.lstSupplierSelected.length - 1){
                        supplierNames += "'" + this.lstSupplierSelected[i] + "')";
                    }else{
                        supplierNames += "'" + this.lstSupplierSelected[i] + "',";
                    }
                }
                dataToSearch.lstAccount = supplierNames;
            }            
        }
        this.searchresultdata = dataToSearch;
        
        getRegionDFS({recId : this.plancycleid,objectApiName : this.objectname,filterWrapStr :JSON.stringify(dataToSearch)})
        .then(data => {     
            this.isLoaded =false;      
            this.searchresultdata = JSON.parse(JSON.stringify(data));
            const selectEvent  = new CustomEvent('searchchange', {
                // detail contains only primitives
                detail: { 
                    searchCompData : this.searchresultdata
                }
            });
            this.dispatchEvent(selectEvent);
        })
        .catch(error => {
            // eslint-disable-next-line no-console
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'Error occured',
                variant: 'error'
            }));
        });
        
        

        
        
    }
}