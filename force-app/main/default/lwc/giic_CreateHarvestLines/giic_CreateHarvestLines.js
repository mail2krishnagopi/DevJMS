import { LightningElement, api, wire,track} from 'lwc';
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import WORKORDER_OBJECT from '@salesforce/schema/gii__WorkOrder__c';
import NAME_FIELD from '@salesforce/schema/gii__WorkOrder__c.Name';
import PRODUCT_ID from '@salesforce/schema/gii__WorkOrder__c.gii__Product__r.Id';
import WAREHOUSE_ID from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.Id';
import WAREHOUSE_NAME from '@salesforce/schema/gii__WorkOrder__c.gii__Warehouse__r.Name';


const fields = [NAME_FIELD,PRODUCT_ID,WAREHOUSE_ID,WAREHOUSE_NAME];
export default class Giic_CreateHarvestLine extends NavigationMixin( LightningElement ){
   
@api recordId;
@api recid;
@api objectApiName;
renderedId = false;
@api name;


connectedCallback(){
    console.log("Record ID" , this.recid);
}


@wire(getRecord, { recordId: '$recordId', fields })
wo; 
get name() {
return getFieldValue(this.wo.data, NAME_FIELD);
}

get productId() {
return getFieldValue(this.wo.data, PRODUCT_ID);
}
get warehouseId() {
return getFieldValue(this.wo.data, WAREHOUSE_ID);
}
get warehousename() {
    return getFieldValue(this.wo.data, WAREHOUSE_NAME);
    }

}