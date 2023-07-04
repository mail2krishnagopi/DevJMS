import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import executeBatch from '@salesforce/apex/JMS_ExecuteBatchNewTerrAssociation.executeBatch';
import ObjectTerrAssoSuccessMsgLabel from '@salesforce/label/c.JMS_Object_Territory_Association_Success_Msg';
import ObjectTerrAssoErrorMsgLabel from '@salesforce/label/c.JMS_Object_Territory_Association_Error_Msg';
import SuccessLabel from '@salesforce/label/c.JMS_Success';
import ErrorLabel from '@salesforce/label/c.JMS_Error';
import BtnExecuteLabel from '@salesforce/label/c.JMS_Btn_Execute';
import TitleLabel from '@salesforce/label/c.JMS_Update_New_Territory_Association';
import TerritoryModelTitleLabel from '@salesforce/label/c.JMS_Territory_Modal_Title';
import TerritoryModelMsgLabel from '@salesforce/label/c.JMS_Territory_Modal_Message';
import TerritoryCancelBtn from '@salesforce/label/c.JMS_Cancel';
import TerritoryProceedBtn from '@salesforce/label/c.JMS_Territory_Proceed_Btn';


export default class Lwc_JMS_ExecuteObjectTerritoryAssociation extends LightningElement {
    isModalOpen = false;
    label={
        BtnExecuteLabel,
        TitleLabel,
        TerritoryModelTitleLabel,
        TerritoryModelMsgLabel,
        TerritoryCancelBtn,
        TerritoryProceedBtn
    };
   /* To execute batch from controller method , */
    fnControllerMethod(event) {
        executeBatch()
        .then(success => {
            this.fnShowNotification(SuccessLabel,ObjectTerrAssoSuccessMsgLabel,SuccessLabel.toLowerCase());
        })
        .catch(error => {
            this.fnShowNotification(ErrorLabel,ObjectTerrAssoErrorMsgLabel,ErrorLabel.toLowerCase());
        });
    }

    /* To display Success Error Message on Screen*/
    fnShowNotification(title,message,variant) {
        this.isModalOpen = false;
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;    
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
   
}