import { LightningElement,api, wire } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import WORKORDER_OBJECT from '@salesforce/schema/gii__WorkOrder__c';
import WORKORDERSTAGE_OBJECT from '@salesforce/schema/gii__WorkOrderStaging__c';
import QUALITY from '@salesforce/schema/gii__WorkOrderStaging__c.giic_Quality__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

import WAREHOUSE_ID from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.Id';
import WAREHOUSE_NAME from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.Name';

import retrieveProductData from '@salesforce/apex/giic_CreateHarvestProduct.retrieveProductData';

const fields = [WAREHOUSE_ID,WAREHOUSE_NAME];
export default class SearchHarvestProduct extends LightningElement {
@api workorderrecordid;
@api objectApiName;
currentKeyValue;
searchKeyValue;
@api  warehouse;
@api  location;
@api   harvestdate;

qualityValue;
quantityValue;

renderTable = false;
workOrderList = [];
workOrderStagingList = [];
@api finalList = [];


connectedCallback(){
    console.log("Record ID" , this.workorderrecordid);
}


handleChangeProdName(event){
       this.currentKeyValue = event.target.value;
       if(event.target.value == '' ){
        this.renderTable = false;
        this.workOrderList = '';
       }
       else if(event.target.value != '' && this.workOrderList != ''){
        this.renderTable = true;
       }
         
  }

  handleProductSearch(){
   
     this.searchKeyValue = this.currentKeyValue;    
   
     console.log("searchKeyValue" + this.searchKeyValue);
  }


handleClearTable(){

    this.workOrderList = '';
    this.renderTable = false;

}
  handleQuantityChange(event){
    //this.quantityValue = event.target.value;
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
    let woId = this.workOrderList[rowindex].objHarvestRef.Id;
    let tempWrap = JSON.parse(JSON.stringify(this.workOrderList));
    console.log('this.woId -> ' + woId);
    for(let i=0; i< tempWrap.length; ++i)
    {
        if(woId == tempWrap[i].objHarvestRef.Id)
        {
            if(event.target.dataset.column == "quantity"){
                tempWrap[i].quantity = event.target.value;
                console.log( "quantity" + tempWrap[i].quantity);
              }
             
        }

    }
    this.workOrderList = tempWrap;

} 
handleQualityChange(event){
   //this.qualityValue = event.target.value;
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
    let woId = this.workOrderList[rowindex].objHarvestRef.Id;
    let tempWrap = JSON.parse(JSON.stringify(this.workOrderList));
    console.log('this.woId -> ' + woId);
    for(let i=0; i< tempWrap.length; ++i)
    {
        if(woId == tempWrap[i].objHarvestRef.Id)
        {
            if(event.target.dataset.column == "quality"){
                tempWrap[i].quality = event.target.value;
                console.log( "quality" + tempWrap[i].quality);
              }
             
        }
     

    }
    this.workOrderList = tempWrap;
} 
handleproductSerial(event){
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
    let woId = this.workOrderList[rowindex].objHarvestRef.Id;
    let tempWrap = JSON.parse(JSON.stringify(this.workOrderList));
    console.log('this.woId -> ' + woId);
    for(let i=0; i< tempWrap.length; ++i)
    {
        if(woId == tempWrap[i].objHarvestRef.Id)
        {
            if(event.target.dataset.column == "prodSerial"){
                tempWrap[i].prodSerial = event.target.value;
                console.log( "prodSerial" + tempWrap[i].prodSerial);
              }
             
        }
     

    }
    this.workOrderList = tempWrap;
} 

handlelotNumber(event){
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
    let woId = this.workOrderList[rowindex].objHarvestRef.Id;
    let tempWrap = JSON.parse(JSON.stringify(this.workOrderList));
    console.log('this.woId -> ' + woId);
    for(let i=0; i< tempWrap.length; ++i)
    {
        if(woId == tempWrap[i].objHarvestRef.Id)
        {
            if(event.target.dataset.column == "lotNumber"){
                tempWrap[i].lotNumber = event.target.value;
                console.log( "lotNumber" + tempWrap[i].lotNumber);
              }
             
        }
     

    }
    this.workOrderList = tempWrap;

}

  @wire(getObjectInfo, { objectApiName: WORKORDERSTAGE_OBJECT })
  workOrderIssueInfo;
  
  @wire(getPicklistValues,
    {
        recordTypeId: '$workOrderIssueInfo.data.defaultRecordTypeId',
        fieldApiName: QUALITY
    }
    )wiredQualityData( { error, data } ) {
        console.log('QUALITY'+ QUALITY);
        if (data) {                           
            console.log( 'Data received from Quality Picklist Field ' + JSON.stringify( data.values ) );
            this.qualityValues = data.values;
            console.log( 'QualityValues are ' + JSON.stringify( this.qualityValues) );
        } else if ( error ) {
            console.log('QUALITY'+ QUALITY);
            console.error( 'Error in Quality picklist field', JSON.stringify( error ) );
        }
        }


  
   dataNotFound;
  @wire (retrieveProductData,{keySearch:'$searchKeyValue'})
  wireRecord({data,error}){
    console.log("data" + data + this.workorderrecordid);
      if(data){           
          this.workOrderList = data;
          this.renderTable = true;
          this.error = undefined;
          this.dataNotFound = '';
          if(this.workOrderList == ''){
              this.dataNotFound = 'false';
          }
          console.log("data" + data);

         }else{
             this.error = error;
             this.data=undefined;
         }
  }

  

  handleSelectAll(event) {
    console.log('In handleSelectAll::::');
    let tempWrap = JSON.parse(JSON.stringify(this.workOrderList));
    for(let i=0; i< tempWrap.length; ++i){
        tempWrap[i].isSelected = event.target.checked;
        if(event.target.checked == true){
        this.isChecked = false;
        }
        if(event.target.checked == false){
        this.isChecked = true;
        }
    
        console.log('tempWrap[i].isSelected::::' + tempWrap[i].isSelected);
    }
    this.workOrderList = tempWrap;
    
    const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
    for (const toggleElement of toggleList) {
        toggleElement.checked = event.target.checked;
    }
    
    }
    changeSelectHandler(event) {
        let rowindex = event.target.dataset.rowindex;
        console.log('this.rowindex -> ' + rowindex);
        let woId = this.workOrderList[rowindex].objHarvestRef.Id;
        let tempWrap = JSON.parse(JSON.stringify(this.workOrderList));
        console.log('this.woId -> ' + woId);
        console.log('this.tempWrap -> ' + tempWrap);
        console.log('this.tempWrap -> ' + tempWrap);
        this.isChecked = true;
        for(let i=0; i< tempWrap.length; ++i)
        {
            console.log('this.tempWrap -> ' + tempWrap[i].objHarvestRef.Id);
            if(woId == tempWrap[i].Id)
            {
                if(event.target.dataset.column == "isSelected"){
                    tempWrap[i].isSelected = event.target.checked;
                    }
            }
            if (tempWrap[i].isSelected == true){
                    this.isChecked = false;
                }
        }
        this.workOrderList = tempWrap;
        console.log('this.assetRefData -> ' + this.workOrderList);
    }
    handleSelectRow(event){
        let rowindex = event.target.dataset.rowindex;
        //let prdSerial = this.template.querySelector(".outter_container");
      //  let prdSerialbyId = this.template(".prodSerialcmp");
        //console.log('prdSerial'+ prdSerial);
        console.log('this.rowindex -> ' + rowindex);
        console.log('this.workOrderList -> ' + this.workOrderList);
        let woId = this.workOrderList[rowindex].objHarvestRef.Id;
        let tempORGWrap = JSON.parse(JSON.stringify(this.workOrderList));
        let tempFinalWrap = JSON.parse(JSON.stringify(this.finalList));
      
        console.log('this.tempORGWrap -> ' + tempORGWrap);
        console.log('this.tempFinalWrap -> ' + tempFinalWrap);
        for(let i=0; i< tempORGWrap.length; ++i)
        {
            if(woId == tempORGWrap[i].objHarvestRef.Id)
            {
                console.log('######prodSerial  '+tempORGWrap[i].prodSerial);
                if(tempORGWrap[i].objHarvestRef.gii__SerialControlled__c == true && (tempORGWrap[i].prodSerial == undefined || tempORGWrap[i].prodSerial == ''))
                {
                  
                   
                    
                    console.log('Prod Serial is mandatory'+tempORGWrap[i].prodSerial);
                    const event = new ShowToastEvent({
                         message: 'Prod Serial is mandatory if the product is serialized',
                         variant: 'error'
                     });
                    this.dispatchEvent(event);
                   // alert("Prod Serial is mandatory if the product is serialized");
                   // prdSerial.setCustomValidity("Prod Serial is mandatory if the product is serialized");
                   
                }
                else{
                    this.workOrderStagingList.push(tempORGWrap[i]);
                    console.log('tempORGWrap[i].objHarvestRef.Id'+ tempORGWrap[i].objHarvestRef.Name);

                }
              
            }
    
      }
      //this.workOrderStagingList =this.tempValue;
     // prdSerial.reportValidity();
      this.finalList= JSON.parse(JSON.stringify(this.workOrderStagingList));
     // console.log('this.workOrderStagingList -> ' + JSON.createParser(this.workOrderStagingList));
      console.log('this.workOrderStagingList -> ' + JSON.parse(JSON.stringify(this.workOrderStagingList)));
      console.log('this.workOrderStagingList -> ' + JSON.stringify(this.workOrderStagingList));
     
     
      
    }

}