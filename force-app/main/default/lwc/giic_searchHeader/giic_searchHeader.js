import { LightningElement,track,api,wire } from 'lwc';
import setupData from '@salesforce/apex/giic_SearchHeaderController.getPlanData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Giic_searchHeader extends LightningElement {
    
    @track countryName;
    @track countryRecordId;
    @track legalEntities = [];
    @track legalEntityValue;
    @track productGroup;
    @track productGroupId;
    @track isModalOpen = false;
    @track noOfPeriod;
    @api asofdate;
    @api planname;
    @api searchresultdata =[];
    @api recordid;
    @api cyclename;
    @track isLoaded =false;
    @track countryList = [];
    @track warehouseList = [];
    @track warehouseValues = [];
    @track countryLegalEntities = [];
    @track warehouseValue;
    @track lstRegionSelected = [];
    @track lstCountrySelected = [];
    @track lstLegalEntitySelected = [];
    @track countryLegalEntitydata = [];
    @track countriesList = []
    @track legalEntitiesList = [];
    @track showsubmit = false;
    @track showRecordMessage = false;
    @track productValue;
    @track productValueId;
    @track skuVal = '';
    @track subCategory2Value = '';
    @track subCategory1Value = '';
    @track productGroups = [];
    @track supplierGroups = [];
    @track lstProductGroupSelected = [];
    @track lstSupplierSelected = [];
    @track wareName;
    @track wareRecordId;
    @track regiondata = [];
    @track regioncountrydata = [];
    @track countryLegaldata = [];
    @track supplierValue;
    @track supplierValueId;
    asofdateVal;

    connectedCallback(){
        var today = new Date();        
        this.noOfPeriod=12; 
        this.getSetupData();
    }

    getSetupData(event){
        let tempWareList = [];
        console.log('this.recordid --'+this.recordid);
        setupData({recId : this.recordid})
        .then(data => {
            this.searchresultdata = data;
            for(let key in data.mapCountryLegalEntry){
                this.countryLegalEntities.push({key: key, value: data.mapCountryLegalEntry[key]});
                tempWareList.push({label:key, value: key});
            }

            if(tempWareList){
                this.countryList = tempWareList;
            }
           
            for(let ware in data.mapLegalEntityWarehouse){
                this.warehouseList.push({key: ware, value :data.mapLegalEntityWarehouse[ware]})
            }
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

            for(let supp in data.lstSupplier){
                this.supplierGroups.push({
                    label:data.lstSupplier[supp].Name,
                    value:data.lstSupplier[supp].Id
                })
            }
            this.asofdateVal = data.asOfDate;


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

    handleRegionChange(event){
        this.lstRegionSelected = event.detail.value;
        if(this.lstRegionSelected){
            this.getCountryData();
        }
        
        if(this.lstRegionSelected.length == 0){
            Promise.resolve().then(() => {
                this.countriesList = [];
                this.legalEntitiesList = [];
                this.lstCountrySelected = [];
                this.lstLegalEntitySelected = [];
            });
        }
    }

    getCountryData(event){
        this.countriesList=[];
        this.lstLegalEntitySelected = [];
        if(this.lstRegionSelected){
            for(let key in this.regioncountrydata){
                for(let key1 in this.lstRegionSelected){
                    if(this.regioncountrydata[key].key == this.lstRegionSelected[key1]){
                        this.countriesList.push({label:this.regioncountrydata[key].value,value:this.regioncountrydata[key].value});
                    }
                }
            }
        }else{
            Promise.resolve().then(() => {
                this.lstLegalEntitySelected = [];
                this.lstWarehouseSelected = [];
                this.legalEntitiesList = [];
            });
        }
    }

    handleCountryChange(event){        
        this.lstCountrySelected = event.detail.value;
        if(this.lstCountrySelected){
            this.getLegalEnity(event);
        }else{
            Promise.resolve().then(() => {
                this.legalEntitiesList = [];
                this.lstLegalEntitySelected = [];
            });
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

    onWareSelection(event){
        this.wareName = event.detail.selectedvalue;
        this.wareRecordId = event.detail.selectedRecordId;
    }


    getPeriodValue(event) {
        this.noOfPeriod = event.detail.value;
    }

    
    getAsofDate(event){
        this.asofdateVal = event.target.value;
    }

    onProdSelection(event){
        this.productValue = event.detail.selectedvalue;
        this.productValueId = event.detail.selectedRecordId;
    }
    
    onSupplierSelection(event){
        this.lstSupplierSelected = event.target.value;
    }

    onCategotySelection(event){
        this.lstProductGroupSelected = event.target.value;
    }

    getSKUValue(event){
        this.skuVal = event.detail.value;
    }

    getSubCat2Value(event){
        this.subCategory2Value = event.detail.value;
    }

    getSubCat1Value(event){
        this.subCategory1Value = event.detail.value;
    }

    handleClick(event) {
        this.isModalOpen = true;
    }

    closeModal(event) {
        this.isModalOpen = false;
    }

    resetModal(event){
        this.productValue = '';
        this.productValueId =  '';
        this.skuVal = '';
        this.subCategory2Value = '';
        this.subCategory1Value = '';
        this.lstSupplierSelected = [];
        this.lstProductGroupSelected = [];
        this.asofdateVal = this.asofdate;
    }

    searchPlan(event) {
        this.isSearchComplete = true;
        this.isLoaded =true;
        let dataToSearch = [];        
        dataToSearch = JSON.parse(JSON.stringify(this.searchresultdata));;

        if (dataToSearch) {
            dataToSearch.selectedWarehouseId = this.wareRecordId;
            dataToSearch.strReportingPeriod = this.PeriodValue;
            dataToSearch.productCategoryId = this.productGroupId;
            dataToSearch.strFilterBy = this.searchByValues;
            dataToSearch.numOfPeriods = this.noOfPeriod;
            dataToSearch.asOfDate = this.asofdateVal;
            dataToSearch.searchProductName = this.productValueId;
            dataToSearch.subCategory1 = this.subCategory1Value;
            dataToSearch.subCategory2 = this.subCategory2Value;
            dataToSearch.skuCode = this.skuVal;
            dataToSearch.searchSupplierName = this.supplierValueId;
            dataToSearch.lstRegion = this.lstRegionSelected;
            dataToSearch.lstCountry = this.lstCountrySelected;
            dataToSearch.lstLegalEntity = this.lstLegalEntitySelected;
            dataToSearch.lstProductGroup = this.lstProductGroupSelected;
            dataToSearch.supplier = this.lstSupplierSelected;
        }
        this.searchresultdata = dataToSearch;
        this.isLoaded =false;
        
        const selectEvent  = new CustomEvent('searchchange', {
            // detail contains only primitives
            detail: { 
                searchCompData : this.searchresultdata
            }
        });
        this.dispatchEvent(selectEvent); 
        
    }

    submitDetails(event) {
        this.isModalOpen = false;
        if(this.searchresultdata){
           this.searchPlan();
        }
    }


}