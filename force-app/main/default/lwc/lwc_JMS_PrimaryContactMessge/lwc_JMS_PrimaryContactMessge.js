import { LightningElement, wire, api } from 'lwc';
import isPrimaryContactExist from '@salesforce/apex/JMS_PrimaryContactController.isPrimaryContactExist';
import PrimaryContactExistLabel from '@salesforce/label/c.JMS_Primary_Contact_Exist';
import NoPrimaryContactExistLabel from '@salesforce/label/c.JMS_No_Primary_Contact_Exist';

export default class Lwc_JMS_PrimaryContactMessge extends LightningElement {
    
    //Properties
    @api recordId;
    noPrimaryContact = false;
    hasPrimaryContact = false;
    infoMessage = '';
    warningMessage = '';
    label = {
        PrimaryContactExistLabel,
        NoPrimaryContactExistLabel
    };
   
    //wire service to get data from apex
    @wire(isPrimaryContactExist,{accRecordId:'$recordId'})
    wiredclass({
        data, error
    }){
        if(data !== null && data !== undefined){
            let dataValue = JSON.parse(JSON.stringify(data));
            if(dataValue === true){
                this.hasPrimaryContact = true;
                this.infoMessage = PrimaryContactExistLabel;
            } else if(dataValue === false){
                this.noPrimaryContact = true;
                this.warningMessage = NoPrimaryContactExistLabel;
            }
        }else if(error){
            this.error = error;
            console.log('Error-->'+this.error);
        }
    
    }
    
}