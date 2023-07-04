import { LightningElement , api,wire,track} from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';

import getServiceTicketLine from'@salesforce/apex/giic_DistributeapInvoicetoServicetickets.getServiceTicketLine';
import createPoRecords from '@salesforce/apex/giic_DistributeapInvoicetoServicetickets.createPoRecords';
import APINVOICE_OBJECT from '@salesforce/schema/gii__APInvoice__c';

import NAME_FIELD from '@salesforce/schema/gii__APInvoice__c.Name';
import ACC_NAME from '@salesforce/schema/gii__APInvoice__c.gii__Supplier__r.Name';
import DOCUMENT_AMT from '@salesforce/schema/gii__APInvoice__c.gii__DocumentAmount__c';
import SUSP_AMT from  '@salesforce/schema/gii__APInvoice__c.gii__SuspenseAmount__c';
import USER_CURRENCY_FIELD from '@salesforce/schema/User.CurrencyIsoCode';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const fields = [NAME_FIELD,ACC_NAME,DOCUMENT_AMT];
export default class Giic_DistributeapInvoicetoServicetickets extends NavigationMixin(LightningElement) {
    @api recordid;
    @api recordIdOne;
    @api objectApiName;

    @track isSelected = true;
    @track isChecked = false;
    @track serTicLineData = [];
    @track resultValue;
    @track totSelAmt = 0;
    docAmt;
    susAmt;
    sustemamt;
    @track tollerPer = 0;
    @track tollamt = 0;
    

    @track showModal = false;
    @track isLoading = false;

    @track purchaseReflist;
    @track purchFinlist = [];

    dateval;
    haserror = false;
    @track porecid;
    

    
    @wire(getRecord, { recordId: '$recordid', fields })
    st;  
    get name() {
        console.log('@#@#1');
        return getFieldValue(this.st.data, NAME_FIELD);
    }
    get accName() {
        console.log('@#@#2');
        return getFieldValue(this.st.data, ACC_NAME);
    }
   /* get docAmt() {
        console.log('+++inside get docAmt');

        this.sustemamt = getFieldValue(this.st.data, DOCUMENT_AMT);
        console.log('temsusAamt' + this.sustemamt);
      
       /* this.sustemamt = temsusAamt;
        console.log('temsusAamt' + this.susAmt+  this.sustemamt );

        return getFieldValue(this.st.data, DOCUMENT_AMT);
       
    }
   /* get susAmt(){
        console.log('+++inside get susAmt');
        return getFieldValue(this.st.data, DOCUMENT_AMT);
    }
   */
   
    
  /*  @wire(getServiceTicketLine, {
        serTickId: '$recordid'})

        WireServiceTickLinesRecords({error, data}){
           // console.log('#@#@#@#');
    if(data){
          
        this.serTicLineData = data;
    }   

    }*/
    /*connectedCallback() {
     
       
        console.log('++inside connected callback'+   '$recordid');
    }
*/



    @wire(getServiceTicketLine, {
        apInvoiceId: '$recordid' })

    WireServiceTickLinesRecords({error, data}){
    if(data){
           console.log('success3'+ data); 
           console.log('assetReflist4' + this.sustemamt ); 
          
            var tempAFList = [];  
            for (var i = 0; i < data.length; i++) { 
                let tempRecord = Object.assign({}, data[i]);
                tempAFList.push(tempRecord);  
                this.tollerPer = tempRecord.tolerancePer;
                this.docAmt  = tempRecord.docAmount;
            }
            
            this.susAmt  = this.docAmt;
            this.sustemamt  = this.docAmt;
       // this.assetRefData = data;
        this.purchaseReflist = tempAFList;
        console.log('assetReflist5' + JSON.stringify(this.purchaseReflist));           
       
    }   

    }

  
handleSelectAll(event) {
    console.log('In handleSelectAll::::' + event.target.checked);
    //let tempWrap = JSON.parse(JSON.stringify(this.purchaseReflist));
    let tempWrap = JSON.parse(JSON.stringify(this.purchaseReflist));
    let tempTotAmt = this.totSelAmt;
        let tempSus = this.sustemamt;
    for(let i=0; i< tempWrap.length; ++i){
        tempWrap[i].isSelected = event.target.checked;
        console.log('Inner Loop0' + event.currentTarget.dataset.serviceid + tempWrap[i].serviceLine.Id );
        //if (event.currentTarget.dataset.serviceid == tempWrap[i].serviceLine.Id) {
            tempWrap[i].isSelected = event.target.checked;
            console.log('Inner Loop1' );
            if(tempWrap[i].isSelected){
            console.log('Inner Loop2' + tempTotAmt + ' --' + tempWrap[i].serviceLine.gii__UnvoucheredAmount__c);
            tempTotAmt = tempTotAmt+tempWrap[i].serviceLine.gii__UnvoucheredAmount__c;
            //console.log('tempWrap[i].isSelected::::' + tempWrap[i].isSelected);
            }else{
                tempTotAmt = tempTotAmt-tempWrap[i].serviceLine.gii__UnvoucheredAmount__c;
            }
       // }
        if(event.target.checked == true){
        this.isChecked = false;
        }
        if(event.target.checked == false){
        this.isChecked = true;
        }
    
        //console.log('tempWrap[i].isSelected::::' + tempWrap[i].isSelected);
    }
    this.susAmt = tempSus - tempTotAmt;
    console.log('#$#$12345 :: '+this.susAmt);
    console.log('#$#$123 :: '+tempTotAmt);
    this.totSelAmt = tempTotAmt;
    this.purchaseReflist = tempWrap;
    
    const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
    for (const toggleElement of toggleList) {
        toggleElement.checked = event.target.checked;
    }
    
    }

   /* handleSelectAll(event) {
        console.log('In handleSelectAll::::');
        let tempWrap = JSON.parse(JSON.stringify(this.purchaseReflist));
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
        
        }*/

    changeSelectHandler(event) {
        //console.log('----'+JSON.stringify(this.purchaseReflist));
        console.log('event'+event.currentTarget.dataset.serviceid );
       console.log('Total Amount' + this.totSelAmt );
       console.log('Suspense Amount' +  this.sustemamt);
        let tempWrap = this.purchaseReflist;
        let tempTotAmt = this.totSelAmt;
        let tempSus = this.sustemamt;
            for(let i=0; i< tempWrap.length; ++i){
            if (event.currentTarget.dataset.serviceid == tempWrap[i].serviceLine.Id) {
                tempWrap[i].isSelected = event.target.checked;
                if(tempWrap[i].isSelected){
                tempTotAmt = tempTotAmt+tempWrap[i].serviceLine.gii__UnvoucheredAmount__c;
                //console.log('tempWrap[i].isSelected::::' + tempWrap[i].isSelected);
                }else{
                    tempTotAmt = tempTotAmt-tempWrap[i].serviceLine.gii__UnvoucheredAmount__c;
                }
            }
        }
        console.log('Total Amount' + tempTotAmt + tempSus );
        let tempSusAmt =  tempSus - tempTotAmt;
    this.susAmt = tempSusAmt;
    //console.log('#$#$12345 :: '+this.susAmt);
    console.log('#$#$123 :: '+this.susAmt + tempTotAmt);
    this.totSelAmt = tempTotAmt;
    
    this.purchaseReflist = tempWrap;
    }

    
handleCreateServiceTicket(event) {
    let isForApproval = false;
    let haserror = false;

    console.log('#####:: '+this.sustemamt + this.tollerPer );
    console.log('##### :: total Unvouchered Amount '+this.totSelAmt);
    this.tollamt = (this.sustemamt - ((this.sustemamt * this.tollerPer)/100));
    console.log('#####:: '+this.tollamt);
   
    if(this.tollamt > this.totSelAmt ){
        isForApproval = true;
        /*const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Suspense Amount is more than threshold limit, AP invoice voucher distribution is submitted for approval ',
            variant: 'warning',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    */
    }
    console.log('----'+JSON.stringify(this.purchaseReflist));
    if(!haserror){
    for(let i=0;i< this.purchaseReflist.length;i++ ){
        console.log('###--> : '+this.purchaseReflist[i].isSelected);
       
        if(this.purchaseReflist[i].isSelected){
            this.purchFinlist.push(this.purchaseReflist[i]);
        }
    }
    console.log('haserror:: '+this.haserror);
    
   createPoRecords({recordJson:JSON.stringify(this.purchFinlist),apvirId : this.recordid,isForAppr : isForApproval }).then(response => {
        this.porecid = response;
        console.log('###: '+response);
     
       this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordid,
            objectApiName: this.objectApiName,
            actionName: 'view'
        }
    });
    console.log('---+'+this.porecid);

    });
   
}
}
    
    
    handleCancel(event) {   
        //Working near to complete
        //this.clickedButtonLabel = event.target.label;
        console.log('handleCancel');
       // alert(this.dateval);
       this.dispatchEvent(new CloseActionScreenEvent());
       
      }
      navigateToRecordPage() {
        console.log('recordId',this.recordid);
        window.open('/' + this.recordid, '_top');
}
}