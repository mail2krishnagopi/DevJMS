import { LightningElement, api, wire , track} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import fetchData from '@salesforce/apex/giic_ShipmentHelper.fetchData';
import sendShipmentDetails from '@salesforce/apex/giic_ShipmentHelper.sendShipmentDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Giic_IntegrationButton extends LightningElement {

    @api recordId;
    carrierName;
    shipmentRecord;
    @api responseMessage;
    @track showSpinner = false;
    

    @wire(fetchData, { recordId: '$recordId' })
    wiredFetchData({ error, data }) {
        if (data) {
            this.shipmentRecord = data;
            console.log('This is the record',this.shipmentRecord);

            this.carrierName = this.shipmentRecord.giic_ShipmentCarrier__r.Name;
            console.log('Record is',this.shipmentRecord.giic_ShipmentCarrier__r.Name);

              /*  if (this.carrierName != 'PLS') {
                    this.callApexforPLS(this.recordId);
                }*/
                this.callApexforShipment(this.shipmentRecord);
        } 
        
        else if (error) {
            const errorMessage = error.body.message;
     /*   const event = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error'
        });
        this.dispatchEvent(event); */

        const evt = new CustomEvent('fieldsMissing', {
            detail: {
                message: errorMessage,
                isSuccess: false // set to false since the request was not successful
            }
        });
        this.dispatchEvent(evt);
        }
        
    }



    connectedCallback() {
        console.log('Record ID:', this.recordId);
    }

   callApexforShipment(recordId){
    console.error('Check record id here',this.recordId +  this.shipmentRecord);
    this.showSpinner = true;

    sendShipmentDetails({shipmentInfo : this.shipmentRecord})
    .then(response  => {
        // handle response
        this.showSpinner = false;
        console.log('Response:', response);
        this.responseMessage = response;
    /*    const event  = new ShowToastEvent({
            title: 'Success',
            message:  this.responseMessage,
            variant: 'success'
        });
        this.dispatchEvent(event ); */

        const evt = new CustomEvent('updateRecord', {
  detail: {
    message: this.responseMessage,
    isSuccess: true // set to true if the response is successful
  }
});

// dispatch the event to the parent Aura component
this.dispatchEvent(evt);
    })
    .catch(error => {
        // handle error
        this.showSpinner = false;
        console.error('Error is', error);
        this.responseMessage = 'Error is: ' + error.body.message;
    /*    const event  = new ShowToastEvent({
            title: 'Error',
            message: this.responseMessage,
            variant: 'error'
        });
        this.dispatchEvent(event ); */

        const evt = new CustomEvent('errorRecord', {
            detail: {
                message: error.body.message,
                isSuccess: false // set to false since the request was not successful
            }
        });
        this.dispatchEvent(evt);
        
    });

   }


}