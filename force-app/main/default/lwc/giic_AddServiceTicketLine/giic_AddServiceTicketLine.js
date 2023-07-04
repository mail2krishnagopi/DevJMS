import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import SERVICETICKETLINE_OBJECT from '@salesforce/schema/gii__ServiceTicketLine__c';
import PRIORITY from '@salesforce/schema/gii__ServiceTicketLine__c.giic_Priority__c';
import SITE_RECORD_FIELD from '@salesforce/schema/gii__AssetReference__c.gii__Site__r.Id';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import getParentRecordDetails from '@salesforce/apex/giic_AddServiceTicketLine.getParentRecordDetails';
import createServiceTicket from '@salesforce/apex/giic_AddServiceTicketLine.createServiceTicket';
import getAssetReferenceList from '@salesforce/apex/giic_AddServiceTicketLine.getAssetReferenceList';
import searchAssetReference from '@salesforce/apex/giic_AddServiceTicketLine.searchAssetReference';


//import cannotAssignFSEWithoutNewCert from '@salesforce/label/c.giic_CannotAssignFSEWithoutNewCert';// added  By himanshu

const fields = [SITE_RECORD_FIELD];
export default class Giic_AddServiceTicketLinefromSite extends NavigationMixin(LightningElement) {
    //@api recordId;
    @api recordid;
    @api objectApiName;
    @api objapiname;

    assetObjectType = false;
    priorityValue = 'Standard';
    priorityValues = [];
    @track isSelected = true;
    @track isChecked = true;
    @track assetRefData = [];
    @track type;
    @track resultValue;

    @track showModal = false;
    @track isLoading = false;

    @track assetReflist;

    @track parentRefData = [];
    siteRecordId;
    siteRecId;
    assetRecId;
    typeRecId;
    trouble;

    // added  By himanshu 
    //wrapperType
    @track Typemap = [];
    @track Troublemap = [];
    troubleVal;
    isLoadedAllData = false;
    newColumnName = 'trouble';
    isSavingRecord = false;
    isEmptyAssestRefList = false;
    // Expose the Custom labels to use in the component. 
    /* customLabel = {
         cannotAssignFSEWithoutNewCert,
     };*/

    @wire(getObjectInfo, { objectApiName: SERVICETICKETLINE_OBJECT })
    serviceTicketLineInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$serviceTicketLineInfo.data.defaultRecordTypeId',
        fieldApiName: PRIORITY
    }) wiredPriorityData({ error, data }) {
        if (data) {
            console.log('Data received from Priority Picklist Field ' + JSON.stringify(data.values));
            this.priorityValues = data.values;
            console.log('priorityValues are ' + JSON.stringify(this.priorityValues));
        } else if (error) {
            console.error('Error in Priority picklist field', JSON.stringify(error));
        }
    }

    @wire(getParentRecordDetails, {
        recId: '$recordid'

    })
    WireParentRecordDetails({ error, data }) {
        console.log('data');
        if (data) {
            console.log('success from parent' + data);
            console.log('data');
            //this.objectApiName = data;
            console.log('this.objectApiName' + data.objApiName);
            console.log('this.objectApiName' + data.recordId);
            this.objapiname = data.objApiName;
            if (data.objApiName == 'gii__AssetReference__c') {
                this.siteRecordId = data.recordId;
                this.assetObjectType = true;
            }
        }

    }

    @wire(getAssetReferenceList, {
        recId: '$recordid'

    })
    WireAssetReferenceRecords({ error, data }) {
        if (data) {

            console.log('success >>' + data);
            let sizeofdata = data.length;
            if (sizeofdata > 0) {
                this.isEmptyAssestRefList = true;
                console.log('sizeofdata >>>' + sizeofdata);
                //console.log('assetReflist' + this.assetReflist);           
                var tempAFList = [];
                for (var i = 0; i < data.length; i++) {
                    let tempRecord = Object.assign({}, data[i]);

                    tempAFList.push(tempRecord);

                }
                console.log('tempAFList' + tempAFList);
                // this.assetRefData = data;


                this.assetReflist = tempAFList;
                console.log('assetReflist' + JSON.stringify(this.assetReflist));

                // added by hiumanshu
                this.assetReflist = data.map(record => ({
                    ...record,
                    trouble: ''
                }));

                console.log('assetReflist111' + JSON.stringify(this.assetReflist));
                let asstId = this.assetReflist[0].trouble;
                console.log('this.asstId -> ' + asstId);
                // ended by hmansu

            }
        }

    }
    viewRecord(event) {
        // Navigate to Account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "gii__Site__c",
                "actionName": "view"
            },

        });
    }
    handleSelectAll(event) {
        console.log('In handleSelectAll::::');
        let tempWrap = JSON.parse(JSON.stringify(this.assetReflist));
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
        this.assetReflist = tempWrap;

        const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
        for (const toggleElement of toggleList) {
            toggleElement.checked = event.target.checked;
        }

    }


    handleCreateServiceTicket(event) {
        //this.clickedButtonLabel = event.target.label;
        this.isLoading = true;
        var isvalidate = false;
        this.isChecked = false;
        this.isSavingRecord = true;
        console.log('handleCreateServiceTicket');
        console.log('this.Typemap>>>>>' + this.Typemap);
        console.log('JSON.stringify( this.Typemap', JSON.stringify(this.Typemap));

        console.log('this.Troublemap>>>>>' + this.Troublemap);
        console.log('JSON.stringify( this.Troublemap', JSON.stringify(this.Troublemap));

        // added by himanshu
        // below code it is used for validate the  type fieled if Row is selected and type is null then we are showing the error.

        for (var i = 0; i < this.assetReflist.length; i++) {
            console.log('t:isSelected:::' + this.assetReflist[i].isSelected);
            console.log('tobjAssetRef.id)::::' + this.assetReflist[i].objAssetRef.Id);
            if (this.assetReflist[i].isSelected === true) {
                if (this.Typemap.length > 0) {
                    let hasAssestId = this.Typemap.some(obj => obj.assestId === this.assetReflist[i].objAssetRef.Id);
                    console.log('hasAssestId>>>>>' + hasAssestId);
                    if (hasAssestId === false) {
                        isvalidate = true;
                        this.isLoading = false;
                        this.isSavingRecord = false;
                        break;
                    }
                } else {
                    isvalidate = true;
                    this.isLoading = false;
                    this.isSavingRecord = false;
                    break;
                }


            }
        }
        //Manogna Start- To check if priority is selected 
        /* console.log('+++priority'+this.priority);
         if(this.priorityValue==null || this.priorityValue=='' || this.priorityValue=='undefined'){
             isvalidate = true;
         }
         //Manogna End*/
        if (isvalidate == false) { // End by himanshu


            createServiceTicket({
                    assetRefList: JSON.stringify(this.assetReflist),
                    priority: this.priorityValue,
                    type: this.typeRecId,
                    trouble: this.trouble,
                    objName: this.objectApiName,
                    typeWrapperlist: JSON.stringify(this.Typemap), // added by himanshu
                    troubleWrapperlist: JSON.stringify(this.Troublemap), // added by himanshu
                })
                .then(result => {
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
                console.log('error' + error);
                this.isLoading = false;
                this.isSavingRecord = false;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error Creating Service ticket, please reach out to sys admin', // added  By himanshu
                    variant: 'error'
                });
                this.dispatchEvent(event);
            });
        } else { // added by himanshu
            this.isLoading = false;
            this.isSavingRecord = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select Type in order to create the Service Ticket Line',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } // End by himanshu
    }


    changeSelectHandler(event) {
        let rowindex = event.target.dataset.rowindex;
        console.log('this.rowindex -> ' + rowindex);
        let asstId = this.assetReflist[rowindex].objAssetRef.Id;
        let tempWrap = JSON.parse(JSON.stringify(this.assetReflist));
        console.log('this.asstId -> ' + asstId);
        console.log('this.tempWrap -> ' + tempWrap);
        console.log('this.tempWrap -> ' + tempWrap);
        this.isChecked = true;
        for (let i = 0; i < tempWrap.length; ++i) {
            console.log('this.tempWrap -> ' + tempWrap[i].id);
            if (asstId == tempWrap[i].objAssetRef.Id) {
                if (event.target.dataset.column == "isSelected") {
                    tempWrap[i].isSelected = event.target.checked;
                }
            }
            if (tempWrap[i].isSelected == true) {
                this.isChecked = false;
            }

        }
        this.assetReflist = tempWrap;
        console.log('this.assetRefData -> ' + this.assetReflist);
    }

    handlePriorityChange(event) {
            this.priorityValue = event.target.value;
        }
        /*
        handleTypechange(event){
            console.log(JSON.stringify(event.detail.selectedRecord));
    
    
            if(event.detail.selectedRecord != undefined ){
            this.typeRecId = event.detail.selectedRecord.Id;
          
            }
            if(event.detail.selectedRecord == undefined ){
                this.typeRecId = '';
               
            }
        } 
        */
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
                objectApiName: this.objapiname,
                actionName: 'view'
            }
        });


    }
    handleSearch(event) {
        console.log('handleSearch' + this.objapiname + this.siteRecId + this.assetRecId);
        if (this.siteRecId == undefined || this.siteRecId == '') {
            if (this.objapiname == 'gii__Site__c') {
                this.siteRecId = this.recordid;
            } else if (this.objapiname == 'gii__AssetReference__c') {
                this.siteRecId = this.siteRecordId;
            }
        }
        if (this.assetRecId == undefined || this.assetRecId == '') {
            if (this.objapiname == 'gii__AssetReference__c') {
                this.assetRecId = this.recordid;
            }
        }

        console.log('handleSearch' + this.siteRecId + this.assetRecId);
        searchAssetReference({
                siteRecId: this.siteRecId,
                assetRecId: this.assetRecId,

            })
            .then(result => {
                console.log('result' + JSON.stringify(result));
                var tempAFList = [];
                for (var i = 0; i < result.length; i++) {
                    let tempRecord = Object.assign({}, result[i]);
                    tempAFList.push(tempRecord);

                }
                this.assetReflist = tempAFList;
                console.log('assetReflist' + JSON.stringify(this.assetReflist));
            })

    }
    handleSiteChange(event) {
        console.log(event.detail.selectedRecord + this.siteRecId);
        if (event.detail.selectedRecord != undefined) {
            console.log('Selected Record Value on Parent Component is ' + JSON.stringify(event.detail.selectedRecord) + JSON.stringify(event.detail.selectedRecord.Id));
            this.siteRecId = JSON.parse(JSON.stringify(event.detail.selectedRecord.Id));
        }
        if (event.detail.selectedRecord == undefined) {
            this.siteRecId = '';
        }

    }
    handleTypeChange(event) {

        console.log('###>>>', JSON.stringify(event.detail.selectedRecord));
        // console.log(JSON.stringify(event.detail.selectedRecord.Id));

        let rowindex = event.target.dataset.rowindex;
        console.log('this.rowindex -> ' + rowindex);
        let asstId = this.assetReflist[rowindex].objAssetRef.Id;
        console.log('this.asstId -> ' + asstId);
        let tempWrap = JSON.parse(JSON.stringify(this.Typemap));

        console.log('this.tempWrap -> ' + tempWrap);


        if (event.detail.selectedRecord != undefined) {
            this.typeRecId = event.detail.selectedRecord.Id;

            let matchAnyvalue = false;

            //  already some value are added
            console.log('this.tempWrap -> length' + tempWrap.length);


            if (tempWrap.length > 0) {
                console.log('inside length');
                for (let i = 0; i < tempWrap.length; i++) {
                    // if data are available then updating the same value
                    if (asstId == tempWrap[i].assestId) {
                        tempWrap[i].typeOfId = this.typeRecId;
                        matchAnyvalue = true;
                        console.log('inside if');
                    }
                }
                this.Typemap = tempWrap;
                // if data are not  available then creating the new data
                if (matchAnyvalue == false) {
                    let obj = new Object();
                    obj.assestId = asstId;
                    obj.typeOfId = this.typeRecId;
                    this.Typemap.push(obj);

                }
                // if we are adding the value
            } else {
                let obj = new Object();
                obj.assestId = asstId;
                obj.typeOfId = this.typeRecId;
                this.Typemap.push(obj);
            }

            console.log('this.Typemap-> ' + this.Typemap);
            console.log(JSON.stringify(this.Typemap));

        }
        if (event.detail.selectedRecord == undefined) {
            this.typeRecId = '';
            if (tempWrap.length > 0) {
                for (let i = 0; i < tempWrap.length; ++i) {
                    // if we are updating the value
                    if (asstId == tempWrap[i].assestId) {
                        console.log('>.', i);
                        console.log('tempWrap-> ' + JSON.stringify(tempWrap));
                        tempWrap.splice(i, 1);
                        console.log('tempWrap-> >>' + JSON.stringify(tempWrap));
                        //tempWrap[i].typeOfId = '';
                        //tempWrap[i].splice(i, 1)
                        //tempWrap[i].splice(i, 1)
                    }
                }
                this.Typemap = tempWrap;
            }
            console.log('this.Typemap-> ' + this.Typemap);
            console.log(JSON.stringify(this.Typemap));
        }

        // console.log('this.Typemap-> ' + this.Typemap);
        //     console.log(JSON.stringify(this.Typemap));
    }





    handleAssetChange(event) {
        console.log(event.detail.selectedRecord + this.assetRecId);
        if (event.detail.selectedRecord != undefined) {
            console.log('Selected Record Value on Parent Component is ' + JSON.stringify(event.detail.selectedRecord) + JSON.stringify(event.detail.selectedRecord.Id));
            this.assetRecId = JSON.parse(JSON.stringify(event.detail.selectedRecord.Id));
        }
        if (event.detail.selectedRecord == undefined) {
            this.assetRecId = '';
        }

    }



    handletroubleChange(event) {

        console.log('###' + event.detail.selectedRecord);
        console.log('###11122' + JSON.stringify(event.detail.selectedRecord));
        console.log('###111333' + this.trouble);

        let rowindex = event.target.dataset.rowindex;
        //console.log('this.rowindex -> ' + rowindex);

        //const rowIndex = event.currentTarget.dataset.rowindex;
        console.log('rowindex' + rowindex);
        const columnName = event.currentTarget.dataset.column;
        console.log('columnName' + columnName);

        let asstId = this.assetReflist[rowindex].objAssetRef.Id;
        console.log('this.asstId -> ' + asstId);
        let tempWrap = JSON.parse(JSON.stringify(this.Troublemap));
        console.log('tempWrap -> ' + tempWrap);
        console.log('###122' + event.detail.selectedRecord);
        console.log('###333' + JSON.stringify(event.detail.selectedRecord));



        if (event.target.value != undefined) {
            this.trouble = event.target.value;

            let newTroubleValue = event.target.value;
            console.log('newTroubleValue' + newTroubleValue);
            this.assetReflist[rowindex].columnName = newTroubleValue;
            let matchAnyvalue = false;

            //  already some value are added
            console.log('this.tempWrap -> length' + tempWrap.length);


            if (tempWrap.length > 0) {
                console.log('inside length');
                for (let i = 0; i < tempWrap.length; i++) {
                    // if data are available then updating the same value
                    if (asstId == tempWrap[i].assestId) {
                        tempWrap[i].troubleVal = newTroubleValue;
                        matchAnyvalue = true;
                        console.log('inside if');
                    }
                }
                this.Troublemap = tempWrap;
                // if data are not  available then creating the new data
                if (matchAnyvalue == false) {
                    let obj = new Object();
                    obj.assestId = asstId;
                    obj.troubleVal = newTroubleValue;
                    this.Troublemap.push(obj);

                }
                // if we are adding the value
            } else {
                let obj = new Object();
                obj.assestId = asstId;
                obj.troubleVal = newTroubleValue;
                this.Troublemap.push(obj);
            }

            console.log('this.Troublemap-> ' + this.Troublemap);
            console.log(JSON.stringify(this.Troublemap));

        }
        if (event.target.value == undefined) {
            this.trouble = '';
            let newTroubleValue = '';
            this.assetReflist[rowindex].columnName = newTroubleValue;
            if (tempWrap.length > 0) {
                for (let i = 0; i < tempWrap.length; ++i) {
                    // if we are updating the value
                    if (asstId == tempWrap[i].assestId) {
                        console.log('>.', i);
                        console.log('tempWrap-> ' + JSON.stringify(tempWrap));
                        tempWrap.splice(i, 1);
                        console.log('tempWrap-> >>' + JSON.stringify(tempWrap));
                        //tempWrap[i].typeOfId = '';
                        //tempWrap[i].splice(i, 1)
                        //tempWrap[i].splice(i, 1)
                    }
                }
                this.Troublemap = tempWrap;
            }
            console.log('this.Troublemap-> ' + this.Troublemap);
            console.log(JSON.stringify(this.Troublemap));
        }

        console.log('this.Troublemap-> ' + this.Troublemap);
        console.log(JSON.stringify(this.Troublemap));

    }

}