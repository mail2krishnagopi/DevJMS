import { LightningElement , api,wire,track} from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';

import getServiceTicketLine from'@salesforce/apex/giic_CreatePurchaseOrder.getServiceTicketLine';
import createPoRecords from '@salesforce/apex/giic_CreatePurchaseOrder.createPoRecords';
import SERVICETICKET_OBJECT from '@salesforce/schema/gii__ServiceTicket__c';

import NAME_FIELD from '@salesforce/schema/gii__ServiceTicket__c.Name';
import ACC_NAME from '@salesforce/schema/gii__ServiceTicket__c.gii__Account__r.Name';
import DATE_CLOSED from '@salesforce/schema/gii__ServiceTicket__c.gii__DateTimeClosed__c';

//import NAME_FIELD from '@salesforce/schema/gii__ServiceTicket__c.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const fields = [NAME_FIELD,ACC_NAME,DATE_CLOSED];
export default class Giic_CreatePurchaseOrder extends NavigationMixin(LightningElement) {
    
    @api recordid;
    @api recordIdOne;
    @api objectApiName;

    @track isSelected = true;
    @track isChecked = false;
    @track serTicLineData = [];
    @track resultValue;

    @track showModal = false;
    @track isLoading = false;

    @track purchaseReflist;
    @track purchFinlist = [];

    dateval;
    haserror = false;
    @track porecid;

    @wire(getObjectInfo, { objectApiName: SERVICETICKET_OBJECT })
    serviceTicketLineInfo;

    @wire(getRecord, { recordId: '$recordid', fields })
    st; 
    get name() {
        return getFieldValue(this.st.data, NAME_FIELD);
    }
    get accName() {
        return getFieldValue(this.st.data, ACC_NAME);
    }
    get dateTimeClosed() {
        return getFieldValue(this.st.data, DATE_CLOSED);
    }

    get ordDate(){
       /* if(this.dateval == undefined){
            this.dateval = new Date().toISOString().substring(0,10);
        }
        return this.dateval;*/
        return getFieldValue(this.st.data, DATE_CLOSED);
    }
    changeDate(event){
        this.dateval = event.target.value;
    }

    /*connectedCallback(){
        var today = new Date();
        this.ordDate=today.toISOString();
        console.log(today.toISOString())
        let formatter = new Intl.DateTimeFormat('en', {
            year: "numeric" ,
            month: "numeric",
            day: "numeric",      
        })
        this.ordDate= formatter.format(today);
        console.log('ordDate'+ this.ordDate);
    }*/





    @wire(getServiceTicketLine, {
        serTickId: '$recordid'})

        WireServiceTickLinesRecords({error, data}){
    if(data){
            console.log('success' + data);

        this.serTicLineData = data;
    }   

    }
    connectedCallback() {
        console.log('----------',this.recordId);
    }

    @wire(getServiceTicketLine, {
        serTickId: '$recordid' })

    WireServiceTickLinesRecords({error, data}){
    if(data){
            console.log('success'+ data); 
            console.log('assetReflist' + this.purchaseReflist);           
            var tempAFList = [];  
            for (var i = 0; i < data.length; i++) { 
                let tempRecord = Object.assign({}, data[i]);
                tempAFList.push(tempRecord);  
            }

       // this.assetRefData = data;
        this.purchaseReflist = tempAFList;
        console.log('assetReflist' + this.purchaseReflist);           
       
    }   

    }

handleCreateServiceTicket(event) {
    
    console.log('----'+JSON.stringify(this.purchaseReflist));
    for(let i=0;i< this.purchaseReflist.length;i++ ){
        console.log('###--> : '+this.purchaseReflist[i].isSelected);
        if(this.purchaseReflist[i].isLineDetailExits == true && this.purchaseReflist[i].isSelected == true){
            console.log('inside loop');
            this.haserror = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Purchase Order Line is already created for the selected Service Ticket Line',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(event);
            break;
        }
        if(this.purchaseReflist[i].isSelected){
            this.purchFinlist.push(this.purchaseReflist[i]);
        }
    }
    console.log('haserror:: '+this.haserror);
    if(!this.haserror){
        this.isLoading = true;
    createPoRecords({recordJson:JSON.stringify(this.purchFinlist)}).then(response => {
        this.porecid = response;
        console.log('###: '+response);
        if(response == 'Error No Location for Warehouse'){
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'PO cannot be created as there is no location to receive',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(event);
        }else{
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: response,
                    objectApiName: 'gii__PurchaseOrder__c',
                    actionName: 'view'
                }
            });
        }
       // window.open('/' + this.recordid, '_top');
    }).catch(error =>{
        this.isLoading = false;

    });
   
    console.log('---+'+this.porecid);
}
}

changeSelectHandler(event) {
    //console.log('----'+JSON.stringify(this.purchaseReflist));
    console.log('event'+event.currentTarget.dataset.serviceid);
    let tempWrap = this.purchaseReflist;
        for(let i=0; i< tempWrap.length; ++i){
        if (event.currentTarget.dataset.serviceid == tempWrap[i].serviceLine.Id) {
            tempWrap[i].isSelected = event.target.checked;
            console.log('tempWrap[i].isSelected::::' + tempWrap[i].isSelected);
        }
}
console.log('#$#$ :: '+JSON.stringify(tempWrap));
this.purchaseReflist = tempWrap;
}

handleSelectAll(event) {
console.log('In handleSelectAll::::');
//let tempWrap = JSON.parse(JSON.stringify(this.serTicLineData));
let tempWrap = this.purchaseReflist;
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
this.purchaseReflist = tempWrap;

const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
for (const toggleElement of toggleList) {
    toggleElement.checked = event.target.checked;
}

}

handleCancel(event) {   
    //Working near to complete
    //this.clickedButtonLabel = event.target.label;
    console.log('handleCancel');
   // alert(this.dateval);
   this.dispatchEvent(new CloseActionScreenEvent());
   this[NavigationMixin.Navigate]({
    type: 'standard__recordPage',
    attributes: {
        recordId: this.recordid,
        objectApiName: this.objectApiName,
        actionName: 'view'
    }
});
   
  }
  navigateToRecordPage() {
        console.log('recordId',this.recordid);
        window.open('/' + this.recordid, '_top');
}
/*showToast() {
    const event = new ShowToastEvent({
        title: 'Success',
        message: 'Purchase Order Record {0} Created --{1}-- !!!!',
        messageData : [
           
            {
                url : 'https://df4000002drcjeae--dev.sandbox.lightning.force.com/'+this.porecid,
                lable : '--here--'
            }, 
        ],
        variant: 'success',
        mode: 'sticky'
    });
    this.dispatchEvent(event);
}*/
}