import { LightningElement,api,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';

import WAREHOUSE_ID from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.Id';
import WAREHOUSE_NAME from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.Name';
import LOCATION_ID from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.giic_DefaultHarvestLocation__r.Id';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import createHarvestProducts from '@salesforce/apex/giic_CreateHarvestProduct.createHarvestProducts';
const fields = [WAREHOUSE_ID,WAREHOUSE_NAME,LOCATION_ID];
export default class ShowselectedHarvestProduct extends NavigationMixin(LightningElement) {

@api  finallist=[];
@api  warehouse;
@api  location;
@api  harvestdate;
@api  workorderrecordid;


connectedCallback(){
    console.log("Record ID" , this.workorderrecordid);
}

@wire(getRecord, { recordId: '$workorderrecordid', fields })
wo; 

get warehouseId() {
return getFieldValue(this.wo.data, WAREHOUSE_ID);
}
get warehouseName() {
    return getFieldValue(this.wo.data, WAREHOUSE_NAME);
    }
get locationId() {
    return getFieldValue(this.wo.data, LOCATION_ID);
}


handleSave(event)
{
 console.log('From Footer'+ JSON.stringify(this.finallist) + this.locationId+ this.warehouseId);

 //this.clickedButtonLabel = event.target.label;
//this.isLoading = true;
console.log('handleCreateHarvestProduct');

createHarvestProducts({ 
    finallist : JSON.stringify(this.finallist),
    workorderId: this.workorderrecordid
})
.then(result => {
    console.log('result' + result);  
    //this.isLoading = false;
    const event = new ShowToastEvent({
        title: 'Harvest Product created',
        message: 'Harvest Product  created',
        variant: 'success'
    });
   this.dispatchEvent(event);
    this.dispatchEvent(new CloseActionScreenEvent());
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: result,
            objectApiName: 'giic_WorkOrder__c',
            actionName: 'view'
        }
    });
    
    
    //window.location.reload();
})

.catch(error => {
    console.log('error'+ error);
   // this.isLoading = false;
    const event = new ShowToastEvent({
        title : 'Error',
        message : 'Error creatingHarvest Product . Please Contact System Admin',
        variant : 'error'
    });
    this.dispatchEvent(event);
});
}
handleDeleteRow(event)
{
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
        console.log('this.finallist -> ' + this.finallist);
    
    let woId = this.finallist[rowindex].objHarvestRef.Id;
    let tempWrap = JSON.parse(JSON.stringify(this.finallist));
    let itemListdupe= [...tempWrap];
    let dellist= [];
    let finalOutList= [];
    
    
        console.log('this.tempWrap -> ' + tempWrap);
       // for(let i=0; i< tempWrap.length; ++i)
        //{
           // console.log('this.tempWrap -> ' + tempWrap[i]);
            if(woId == tempWrap[rowindex].objHarvestRef.Id)
            {
                dellist.push(tempWrap[rowindex]);
            }
    
     // }
      console.log('tempWrap.length' +tempWrap.length );
      
      if( tempWrap.length>=1){
        tempWrap.splice(rowindex, 1);
    }
    itemListdupe.splice(rowindex, 1);

    this.finalOutList =tempWrap;
    this.finallist = JSON.parse(JSON.stringify(this.finalOutList));

      console.log('this.finallist -> ' + JSON.parse(JSON.stringify(this.finalOutList)));

}
handleBack(event){
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.workorderrecordid,
            objectApiName: 'giic_WorkOrder__c',
            actionName: 'view'
        }
    });

}
}