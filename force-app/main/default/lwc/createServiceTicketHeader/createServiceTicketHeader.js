import { LightningElement,api, wire } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import WORKORDER_OBJECT from '@salesforce/schema/gii__WorkOrder__c';
import NAME_FIELD from '@salesforce/schema/gii__WorkOrder__c.Name';
import PRODUCT_ID from '@salesforce/schema/gii__WorkOrder__c.gii__Product__r.Id';
import PRODUCT_NAME from '@salesforce/schema/gii__WorkOrder__c.gii__Product__r.Name';
import WAREHOUSE_ID from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.Id';
import WAREHOUSE_NAME from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.Name';
import LOCATION_ID from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.giic_DefaultHarvestLocation__r.Id';

import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';


const fields = [NAME_FIELD,PRODUCT_ID,PRODUCT_NAME,WAREHOUSE_ID,WAREHOUSE_NAME,LOCATION_ID];
export default class CreateServiceTicketHeader extends LightningElement {

@api workorderrecordid;
@api objectApiName;

@api harvestDate;
workOrderRecordId;
renderedId = false;


connectedCallback(){
    var today = new Date();
    this.date=today.toISOString();
    console.log(today.toISOString())
    let formatter = new Intl.DateTimeFormat('en', {
        year: "numeric" ,
        month: "numeric",
        day: "numeric",      
    })
    this.harvestDate= formatter.format(today);
    console.log('harvestDate'+ this.harvestDate);
}

renderedCallback() {
    if(!this.renderedId && this.productId){
    this.renderedId = true;
    console.log("Record ID" , this.productId,this.warehouseId);
    }
}


@wire(getRecord, { recordId: '$workorderrecordid', fields })
wo; 
get name() {
return getFieldValue(this.wo.data, NAME_FIELD);
}

get productId() {
return getFieldValue(this.wo.data, PRODUCT_ID);
}
get productName() {
    return getFieldValue(this.wo.data, PRODUCT_NAME);
    }
get warehouseId() {
return getFieldValue(this.wo.data, WAREHOUSE_ID);
}
get warehouseName() {
    return getFieldValue(this.wo.data, WAREHOUSE_NAME);
    }
get locationId() {
    return getFieldValue(this.wo.data, LOCATION_ID);
}
}