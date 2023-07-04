import { LightningElement, api, wire , track} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CARRIER_NAME from '@salesforce/schema/gii__Shipment__c.gii__SalesOrder__r.gii__Carrier__r.Name';
import fetchData from '@salesforce/apex/giic_ShipmentHelper.fetchData';
import sendShipmentDetails from '@salesforce/apex/giic_ShipmentHelper.sendShipmentDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [CARRIER_NAME];
export default class Giic_GenerateShippingLabel extends LightningElement {

    @api recordId;
    
    shipmentRecord;

    @wire(getRecord, { recordId: '$recordId', fields })
    shipment;

    get carrierName() {
        return getFieldValue(this.gii__Shipment__c.data, CARRIER_NAME);
      //  console.log('carrierName' + this.carrierName);
    }

    connectedCallback() {
        console.log('Record ID:', this.recordId);
    }

    renderedCallback() {
       // console.log('carrierName' + this.carrierName);
       console.log('Record ID:', this.recordId);
    
    }

}