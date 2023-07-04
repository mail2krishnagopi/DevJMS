import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const DELAY = 1000;

export default class ForecastPeriodInput extends LightningElement {
    @api periodkey;
    @api productdata = {};
    @api indexvalue;
    /*@api forecastby;*/
    @api reportingperiod;
    @api zonedata = new Map();
    prodValue;
    @track isProdEditable = false;
    @api allperiodsdisable = new Map();
    @api showdemanddata = false;
    @api showsparepartdata = false;
    @api forecastplan = false;
    @api forecast;
    @track dfLine;
    @track showHistroy = false;
    @track iconName;
    @track iconVariant;
    @track hoverText;
    @api readonlydata;
    @api readableqty;
    @track avalQty = 0;
    @track safetyROP = 0.00;
    @track avalDO = 0;
    @track forecastQuantity = 0;
    @track DemandPlan;
    @track frozenZone = false;
    @track slushyZone = false;
    @track noZone = false;
    @track sparedata;
    @track minOrderQuantity = 0;
    @track shelfTime =0.00;
    @track leadTimeYear = 0.00;
    @track leadTimeMonth = 0.00;
    @track failureRate = 0.00;
    @track station;
    @track noOfInstalledStations = 0;
    @track avalQty =0;
    @track avgLeadTime = 0.00;
    @track safeStock = 0.00;
    @track maxLevel = 0.00;
    @track annDemand = 0.00;
    @track avalQty = 0.0;


    get prodValue(){
        return this.prodValue;
    }

    set prodValue(value){
        this.prodValue = value;
    }

    connectedCallback() {
        this.initialiseData();
    }

    @api loadData(){
        window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
                this.initialiseData();
            }, DELAY);
        
    }

   initialiseData(){
        this.prodValue = '';
        this.frozenZone = false;
        this.slushyZone = false;
        this.noZone = false;
        this.prodValue = this.productdata.periodQty[this.periodkey];
        if(this.showdemanddata == true){
            this.avalQty = this.productdata.mapPLW[this.periodkey].totalAvailQty;
            this.safetyROP =  this.productdata.mapPLW[this.periodkey].safetyStockQuantity;
            this.avalDO = this.productdata.mapPLW[this.periodkey].availableforDemandOrder;
            this.forecastQuantity = this.productdata.mapPLW[this.periodkey].currentQty;
            this.DemandPlan = 'Demand Order Qty';
        }else if(this.showsparepartdata == true){
            this.minOrderQuantity = this.productdata.mapPLW[this.periodkey].minOrderQuantity;
            this.shelfTime = (this.productdata.mapPLW[this.periodkey].shelfTime).toFixed(2);
            this.leadTimeYear = (this.productdata.mapPLW[this.periodkey].leadTimeYear).toFixed(2);
            this.leadTimeMonth = (this.productdata.mapPLW[this.periodkey].leadTimeMonth).toFixed(2);
            this.failureRate = (this.productdata.mapPLW[this.periodkey].failureRate).toFixed(2);
            this.station = this.productdata.mapPLW[this.periodkey].station;
            this.noOfInstalledStations = this.productdata.mapPLW[this.periodkey].noOfInstalledStations;
            this.annDemand = this.productdata.mapPLW[this.periodkey].annualDemand;
            this.avgLeadTime = (this.productdata.mapPLW[this.periodkey].avgDemandDuringleadTime).toFixed(2);
            this.safeStock = this.productdata.mapPLW[this.periodkey].safetyStock;
            this.maxLevel = (this.productdata.mapPLW[this.periodkey].maxLevel).toFixed(2);
            this.avalQty = this.productdata.mapPLW[this.periodkey].avalQty;
            this.sparedata = 'Forecast Qty';
        }else{
            this.forecastplan = true;
        }
    
        if(this.forecastplan == true){
            if(this.productdata.zoneMap){
                if(this.productdata.zoneMap[this.periodkey] == 'frozen'){
                    this.frozenZone = true;
                }else if(this.productdata.zoneMap[this.periodkey] == 'slushy'){
                    this.slushyZone = true;
                }else{
                    this.noZone = true;
                }
            }else{
                this.noZone = true;
            }
        }
        if(this.showdemanddata == true && this.forecast != 'undefined' && this.productdata.periodDFLine && this.productdata.periodDFLine[this.periodkey].Id){
            this.dfLine = this.productdata.periodDFLine[this.periodkey];
            if(this.dfLine.giic_PriorDemandvsCurrent_Demand__c && this.dfLine.giic_PriorDemandvsCurrent_Demand__c != 'Equal' && this.dfLine.giic_ParentDemandForecastLine__c){
                this.showHistroy = true;
                this.iconName = this.dfLine.giic_PriorDemandvsCurrent_Demand__c == 'Greater' ? 'utility:arrowup': 'utility:arrowdown';
                this.iconVariant = this.dfLine.giic_PriorDemandvsCurrent_Demand__c  == 'Greater'?'success': 'error';
                this.hoverText = 'Prior Demand Quantity : '+ this.dfLine.giic_DemandPlanPriorQuantity__c +', Modified by: '+
                this.dfLine.giic_DemandPlanPriorModifyBy__r.Name +', Modified Date : '+ this.dfLine.giic_DemandPlanPriorModifyDate__c.split('T')[0];
            }
        }
        else if(this.forecastplan == true && this.forecast != 'undefined' && this.productdata.periodDFLine && this.productdata.periodDFLine[this.periodkey].Id){
            this.dfLine = this.productdata.periodDFLine[this.periodkey];
            if(this.dfLine.giic_Prior_vs_Current__c && this.dfLine.giic_Prior_vs_Current__c != 'Equal' && this.dfLine.giic_ParentDemandForecastLine__c){
                this.showHistroy = true;
                this.iconName = this.dfLine.giic_Prior_vs_Current__c == 'Greater' ? 'utility:arrowup': 'utility:arrowdown';
                this.iconVariant = this.dfLine.giic_Prior_vs_Current__c  == 'Greater'?'success': 'error';
                this.hoverText = 'Prior Quantity : '+ this.dfLine.gii__PriorQuantity__c +', Modified by: '+
                this.dfLine.giic_DemandForecastPriorModifyBy__r.Name +', Modified Date : '+ this.dfLine.giic_DemandForecastPriorModifyDate__c.split('T')[0];
            }
        }else if(this.showsparepartdata == true && this.forecast != 'undefined' && this.productdata.periodDFLine && this.productdata.periodDFLine[this.periodkey].Id){
            this.dfLine = this.productdata.periodDFLine[this.periodkey];
            if(this.dfLine.giic_Prior_vs_Current__c && this.dfLine.giic_Prior_vs_Current__c != 'Equal' && this.dfLine.giic_ParentDemandForecastLine__c){
                this.showHistroy = true;
                this.iconName = this.dfLine.giic_Prior_vs_Current__c == 'Greater' ? 'utility:arrowup': 'utility:arrowdown';
                this.iconVariant = this.dfLine.giic_Prior_vs_Current__c  == 'Greater'?'success': 'error';
                this.hoverText = 'Prior Quantity : '+ this.dfLine.gii__PriorQuantity__c +', Modified by: '+
                this.dfLine.giic_DemandForecastPriorModifyBy__r.Name +', Modified Date : '+ this.dfLine.giic_DemandForecastPriorModifyDate__c.split('T')[0];
            }
        }
        if(this.readonlydata == true ){
            this.isProdEditable = true;
        }else{
            this.isProdEditable = (!(this.productdata.periodDisabled[this.periodkey]) || this.allperiodsdisable[this.periodkey]) ? true : false;
        }
        
    }

    getProdValue(event){
        event.preventDefault();
        this.prodValue = event.detail.value;

        if(this.prodValue < 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: "Value should be greater than 0",
                variant: 'error'
            }));
            return;
        }else{
        //added delay to stop sending multiple inputs
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            const selectEvent  = new CustomEvent('child', {
                // detail contains only primitives
                detail: { 
                    prodValue: this.prodValue, 
                    indexvalue: this.indexvalue,
                    periodkey: this.periodkey,
                    forecastby: this.forecastby
                }
            });
            this.dispatchEvent(selectEvent );
        }, DELAY);
        }
      
    }
}