import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { createRecord } from "lightning/uiRecordApi";

import SALESORDERLINE_OBJECT from '@salesforce/schema/gii__SalesOrderLine__c';
import getSalesOrderLines from '@salesforce/apex/Giic_SetupInstallation.getSalesOrderLines';
import createserviceticket from '@salesforce/apex/Giic_SetupInstallation.createServiceTicket';
import getSalesOrderRecord from '@salesforce/apex/Giic_SetupInstallation.getSite';
export default class Giic_SetupInstallation extends NavigationMixin(LightningElement) {

  @api recordId;
  @api recid;
  @track isChecked = true;
  value = [];
  objectApiName = SALESORDERLINE_OBJECT.objectApiName;
  @track sollist;
  @track site;
  isLoading = false;
  // added by himanshu
  defaultCurrentRecordSiterecord;
  //isRendering = false;
  isSiteAttached = false;
  //@track empty = false;


  // Added by himansh

  connectedCallback() {
    console.log('recordId>>>>' + this.recordId);
    console.log('recid>>>' + this.recid);
  }
/* Below renderedCallback method assigning the default sales order id into sollist*/
  /*renderedCallback() {
    console.log();
    console.log('this.sollis::::' + this.sollist);
    if (this.isRendering === false)
      if (this.sollist != undefined || this.sollist != null) {
        console.log('this.sollis::::' + this.sollist);
        console.log('Json:::' + JSON.parse(JSON.stringify(this.sollist)));
        let tempWrap = JSON.parse(JSON.stringify(this.sollist));
        console.log('tempWrap[i]::::' + tempWrap);
        console.log('tempWrap[i]:.length:::' + tempWrap.length);
        if (tempWrap.length > 0) {
          for (let j = 0; j < tempWrap.length; j++) {
            console.log('sollist[i]:objSOLine:::' + tempWrap[j].objSOLine);
            console.log('sollist[i]::objSOLine::' + tempWrap[j].objSOLine);
            console.log('sollist[i]::::site' + tempWrap[j].objSOLine.gii__Site__c);
            tempWrap[j].objSOLine.gii__Site__c = this.defaultCurrentRecordSiterecord;
            console.log('sollist[i]::::site' + tempWrap[j].objSOLine.gii__Site__c);
          }
          this.isRendering = true;
          this.sollist = tempWrap;
        }
      }
    //return this.sollist;
  }*/
  


  /* Below method getting the current page sales order record */
  @wire(getSalesOrderRecord, { soId: '$recid' })
  wireSalesOrderRecord({ error, data }) {
    if (data) {
      console.log(data);
      this.defaultCurrentRecordSiterecord = data;
      this.isSiteAttached = true;
      console.log(this.defaultCurrentRecordSiterecord);
    } else {
      this.isSiteAttached = false;
      console.log(error);
    }
  }
// Ended by himanshu

  @wire(getSalesOrderLines, { soId: '$recid' })
  WireContactRecords({ error, data }) {
    if (data) {
      console.log('+++record id' + this.recid);
      //this.sollist = data;
      console.log('+++sollist' + this.sollist);
      this.error = undefined;
      //geturl
      var tempOppList = [];
      for (var i = 0; i < data.length; i++) {
        console.log('data[i]::::' + data[i]);
        let tempRecord = Object.assign({}, data[i]); //cloning object  
        tempRecord.recordLink = "/" + tempRecord.objSOLine.Id;
        console.log('tempRecord::::' + tempRecord);
        console.log('tempRecord::::' + tempRecord.objSOLine.giic_Product__c);
        console.log('tempRecord::::' + tempRecord.objSOLine.gii__SalesOrder__r.giic_Site__c);
       // console.log('tempRecord::giic_Site__Name::' + tempRecord.objSOLine.gii__SalesOrder__r.giic_Site__r.Name);

        tempOppList.push(tempRecord);

      }
      this.sollist = tempOppList;
      console.log('this.sollist' + JSON.stringify(this.sollist));
      //console.log('this.sollist::::'+this.sollist[0].objSOLine.giic_Product__c);
    } else {
      this.error = error;
      this.sollist = undefined;
    }
  }
  /*columns = [
   {  
       label: "Line Number",  
       fieldName: "recordLink",  
       type: "url",  
       typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" }  
      },
   { label: 'Product', fieldName: 'giic_Product__c',editable: true },
   { label: 'Site', fieldName: 'gii__Site__c',editable: true },
   { label: 'Update Asset', fieldName: 'gii__UpdateAsset__c',type:'boolean',editable: true }
   ];
  */
  dateval;


  get dateValue() {
    if (this.dateval == undefined) {
      this.dateval = new Date().toISOString().substring(0, 10);
    }
    return this.dateval;
  }

  changedate(event) {
    this.dateval = event.target.value;
  }

  handleCreateServiceTicket(event) {
    //this.clickedButtonLabel = event.target.label;
    console.log('handleCreateServiceTicket');
    this.isLoading = true;
    var validatePage = false;
    for (var i = 0; i < this.sollist.length; i++) {
      console.log('sollist[i]::::' + this.sollist[i].isSelected);
    //  console.log('sollist[i]::::' + this.sollist[i].objSOLine.Id);
      console.log('sollist[i]::::site' + this.sollist[i].objSOLine.gii__SalesOrder__r.giic_Site__c);
      console.log('sollist[i]::::' + this.sollist[i].objSOLine.gii__UpdateAsset__c);
      //console.log('sollist[i]::::site' + this.sollist[i].objSOLine.gii__Site__c);

      // added by himanshu
      if ((this.sollist[i].isSelected == true && (this.sollist[i].objSOLine.gii__SalesOrder__r.giic_Site__c == null || this.sollist[i].objSOLine.gii__SalesOrder__r.giic_Site__c == undefined))) {
        validatePage = true;
        this.isLoading = false;

      } else {
        validatePage = false;
      }// end by himanshu
    }

    if (validatePage == false) {  // added by Himanshu 
      createserviceticket({
        solList: JSON.stringify(this.sollist),
        Serviceduedate: this.dateval
      }).then(result => {
        console.log('result' + result);
        this.isLoading = false;
        const event = new ShowToastEvent({
          title: 'Service Ticket created',
          message: 'Service Ticket created',
          variant: 'success'
        });
        this.dispatchEvent(event);
        this.dispatchEvent(new CloseActionScreenEvent());
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: result,
            objectApiName: 'gii__ServiceTicket__c',
            actionName: 'view'
          }

        });



      })

        .catch(error => {
          const event = new ShowToastEvent({
            title: 'Error',
            message: 'Error creating Service Ticket . Please Contact System Admin',
            variant: 'error'
          });
          this.dispatchEvent(event);
        });
    } else {// added by Himanshu 

      const evt = new ShowToastEvent({
        title: 'Error',
        message: 'Please select a Site inorder to create the Service Ticket',
        variant: 'error'
      });
      this.dispatchEvent(evt);
    } // ended by Himanshu 

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
        recordId: this.recid,
        objectApiName: this.objectApiName,
        actionName: 'view'
      }
    });

  }


  changeHandler(event) {
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
    let solid = this.sollist[rowindex].objSOLine.Id;
    // let tempWrap = this.sollist;
    let tempWrap = JSON.parse(JSON.stringify(this.sollist));
    console.log('this.solid -> ' + solid);
    console.log('this.tempWrap -> ' + tempWrap);
    this.isChecked = true;
    for (let i = 0; i < tempWrap.length; ++i) {


      if (solid == tempWrap[i].objSOLine.Id) {
        console.log('this.tempWrap[i].objSOLine.gii__UpdateAsset__c -> ' + tempWrap[i].objSOLine.gii__UpdateAsset__c);
        //   tempWrap[i].objSOLine.gii__UpdateAsset__c = true;
        console.log('this.tempWrap[i].objSOLine.gii__UpdateAsset__c2 -> ' + tempWrap[i].objSOLine.gii__UpdateAsset__c);



        if (event.target.dataset.column == "isSelected") {
          tempWrap[i].isSelected = event.target.checked;
        }
        /*  else if(event.target.dataset.column == "Site"){
            tempWrap[i].objSOLine.gii__Site__c = JSON.parse(JSON.stringify(event.detail.selectedRecord.Id));
          }*/
        else if (event.target.dataset.column == "UpdateAsset") {
          tempWrap[i].objSOLine.gii__UpdateAsset__c = event.target.checked;
        }
      }
      if (tempWrap[i].isSelected == true) {
        this.isChecked = false;
      }
    }
    //  alert(this.isChecked);
    this.sollist = tempWrap;
    console.log('this.sollist -> ' + this.sollist);

    console.log('rowindex' + rowindex);
    console.log('event' + event);
    console.log('event' + event.target);
    console.log('event' + event.target.dataset);
    console.log('event' + event.target.dataset.column);
    /*console.log('event'+event.target.dataset.rowindex);
    if(event.target.dataset.column == "isSelected"){
      this.sollist[rowindex].isSelected = event.target.checked;
    }
    else if(event.target.dataset.column == "Site"){
      this.sollist[rowindex].objSOLine.gii__Site__c = event.target.value;
    }
    else if(event.target.dataset.column == "UpdateAsset"){
      this.sollist[rowindex].objSOLine.gii__UpdateAsset__c = event.target.checked;
    }
    */
  }

  handleSelectAll(event) {
    console.log('In handleSelectAll::::');
    let tempWrap = JSON.parse(JSON.stringify(this.sollist));
    for (let i = 0; i < tempWrap.length; ++i) {
      tempWrap[i].isSelected = event.target.checked;
      if (event.target.checked == true) {
        this.isChecked = false;
      }
      if (event.target.checked == false) {
        this.isChecked = true;
      }

      console.log('tempWrap[i].isSelected::::' + tempWrap[i].isSelected);
    }
    this.sollist = tempWrap;
    //this.sollist[0].isSelected = true;
    //this.sollist[0] = {        ...this.sollist[0].objSOLine,        isSelected: true}
    const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
    for (const toggleElement of toggleList) {
      toggleElement.checked = event.target.checked;
    }

  }

  lookupRecord(event) {
    // this.site = event.detail;
    console.log('this.defaultCurrentRecordSiterecord' + this.defaultCurrentRecordSiterecord);
    if (event.detail.selectedRecord != undefined) {
      console.log('Selected Record Value on Parent Component is ' + JSON.stringify(event.detail.selectedRecord) + JSON.stringify(event.detail.selectedRecord.Id));
      this.siteRecId = JSON.parse(JSON.stringify(event.detail.selectedRecord.Id));
      let rowindex = event.target.dataset.rowindex;
      let solid = this.sollist[rowindex].objSOLine.Id;
      let tempWrap = JSON.parse(JSON.stringify(this.sollist));
      //console.log('json'+JSON.stringify(event.detail.selectedRecord));
      for (let i = 0; i < tempWrap.length; ++i) {
        if (solid == tempWrap[i].objSOLine.Id) {
          tempWrap[i].objSOLine.gii__SalesOrder__r.giic_Site__c = this.siteRecId;

        }
      }
      // alert(this.site.selectedRecord.Id);
      this.sollist = tempWrap;
    }
    /* added by Himanshu 
     added this logic for removing the site from sollist if site is selected and after 
    the we are removing.*/
    else {
      // console.log('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord)+  JSON.stringify(event.detail.selectedRecord.Id));
      let rowindex = event.target.dataset.rowindex;
      let solid = this.sollist[rowindex].objSOLine.Id;
      let tempWrap = JSON.parse(JSON.stringify(this.sollist));
      for (let i = 0; i < tempWrap.length; ++i) {
        if (solid == tempWrap[i].objSOLine.Id && (tempWrap[i].objSOLine.gii__SalesOrder__r.giic_Site__c != null || tempWrap[i].objSOLine.gii__SalesOrder__r.giic_Site__c != undefined)) {
          tempWrap[i].objSOLine.gii__SalesOrder__r.giic_Site__c = null;

        }
      }
      this.sollist = tempWrap;
    } // End By Himanshu
  }
}