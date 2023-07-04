import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import executeBatchCampTarget from '@salesforce/apex/JMS_ExecuteCampTargetStagingController.executeBatch';
import executeBatchBrokerCall from '@salesforce/apex/JMS_ExecuteCampTargetStagingController.executeBatchBrokerCall';
import ExecutionSuccessMsgLabel from '@salesforce/label/c.JMS_Execution_Success_Message';
import ExecutionErrorMsgLabel from '@salesforce/label/c.JME_Execution_Failure_Message';
import SuccessLabel from '@salesforce/label/c.JMS_Success';
import ErrorLabel from '@salesforce/label/c.JMS_Error';
import TitleLabel from '@salesforce/label/c.JMS_CampTarger_Broker_Call_Execution';
import BtnExecuteLabelCampTarget from '@salesforce/label/c.JMS_Campaign_Target';
import BtnExecuteLabelBrokerCall from '@salesforce/label/c.JMS_Execute_Broker_Call';


export default class Lwc_JMS_ExecuteCampTarStagingToSObject extends LightningElement {
    label={
        BtnExecuteLabelCampTarget,
        BtnExecuteLabelBrokerCall,
        TitleLabel
    };
   /* To execute batch from controller method , */
    fnControllerMethodCampTarger(event) {
        executeBatchCampTarget()
        .then(success => {
            this.fnShowNotification(SuccessLabel,ExecutionSuccessMsgLabel,SuccessLabel.toLowerCase());
        })
        .catch(error => {
            this.fnShowNotification(ErrorLabel,ExecutionErrorMsgLabel,ErrorLabel.toLowerCase());
        });
    }
     fnControllerMethodBrokerCall(event) {
        executeBatchBrokerCall()
        .then(success => {
            this.fnShowNotification(SuccessLabel,ExecutionSuccessMsgLabel,SuccessLabel.toLowerCase());
        })
        .catch(error => {
            this.fnShowNotification(ErrorLabel,ExecutionErrorMsgLabel,ErrorLabel.toLowerCase());
        });
    } 

    /* To display Success Error Message on Screen*/
    fnShowNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}