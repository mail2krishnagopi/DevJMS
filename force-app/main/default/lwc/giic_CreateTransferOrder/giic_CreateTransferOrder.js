import { LightningElement } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import getSalesOrderLines from '@salesforce/apex/Giic_CreateTransferOrder.getSalesOrderLines';
import createTransferOrder from '@salesforce/apex/Giic_CreateTransferOrder.createTransferOrder';
import getDCWarehouse from '@salesforce/apex/Giic_CreateTransferOrder.getDCWarehouse';
import TRANSFERORDER_OBJECT from '@salesforce/schema/gii__TransferOrder__c';
import SALESORDER_OBJECT from '@salesforce/schema/gii__SalesOrder__c';
import REQUIREDDATE_FIELD from '@salesforce/schema/gii__SalesOrder__c.gii__RequiredDate__c';
import SoWarehouse_FIELD from '@salesforce/schema/gii__SalesOrder__c.gii__Warehouse__r.Id';
import WAREHOUSE_ID from '@salesforce/schema/gii__SalesOrder__c.gii__Warehouse__c';

const fields = [REQUIREDDATE_FIELD,SoWarehouse_FIELD,WAREHOUSE_ID];

export default class Giic_CreateTransferOrder extends NavigationMixin(LightningElement) {
   @api recordId;
   @api recid;
   objectApiName=TRANSFERORDER_OBJECT.objectApiName;
   objapiname=SALESORDER_OBJECT.objectApiName;
   @track fromwarehouse;
    towarehouse=SoWarehouse_FIELD;
    @api towarehouse;
   requireddate=REQUIREDDATE_FIELD;
   warehouseId=WAREHOUSE_ID;
   @track sollist;
   @api requireddate;
   @api warehouseId;
   @track warehouse;

    @wire (getSalesOrderLines,{soId: '$recid'}) WireContactRecords({error, data}){
    if(data){
        console.log('+++record id'+this.recid);
        //this.sollist = data;
        console.log('+++sollist'+this.sollist);
        this.error = undefined;
        //geturl
        var tempOppList = [];  
        for (var i = 0; i < data.length; i++) {  
            console.log('data[i]::::'+data[i]);
            let tempRecord = Object.assign({}, data[i]); //cloning object  
            tempRecord.recordLink = "/" + tempRecord.objSOLine.Id; 
            console.log('tempRecord::::'+tempRecord);
            console.log('tempRecord::::'+tempRecord.objSOLine.giic_Product__c);
            tempOppList.push(tempRecord);  
        }  
        this.sollist = tempOppList;  
        //call dc warehouse method start
        getDCWarehouse()
          .then(result => {
                  console.log('result' + result);
                  this.fromwarehouse=result;  
            })
          .catch(error => {
              console.log('error'+ error);
              const event = new ShowToastEvent({
                  title : 'Error',
                  message : 'Error fetching DC Warehouse. Please Contact System Admin',
                  variant : 'error'
              });
              this.dispatchEvent(event);
          });
        //call dc warehouse method end
    }else{
        this.error = error;
        this.sollist = undefined;
    }
   }
     
      @wire(getRecord, { recordId: '$recid', fields }) so; 
      get towarehouse() {
        console.log('+++so'+this.so.data);
        console.log('+++towarehouse'+JSON.stringify(getFieldValue(this.so.data, SoWarehouse_FIELD)));
        return getFieldValue(this.so.data, SoWarehouse_FIELD);
      }
      get requireddate() {
        console.log('+++so'+this.so);
        console.log('+++REQUIREDDATE_FIELD'+REQUIREDDATE_FIELD);
          return getFieldValue(this.so.data, REQUIREDDATE_FIELD);
      }
      get warehouseId() {
        console.log('+++so'+this.so.data);
        console.log('+++towarehouse'+JSON.stringify(getFieldValue(this.so.data,  WAREHOUSE_ID)));
        return getFieldValue(this.so.data, WAREHOUSE_ID);
     }

    handleSelectAll(event) {
        console.log('In handleSelectAll::::');
        let tempWrap = JSON.parse(JSON.stringify(this.sollist));
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
        this.sollist = tempWrap;
        const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
        for (const toggleElement of toggleList) {
            toggleElement.checked = event.target.checked;
        }
       
      }
  changeHandler(event){
    console.log('+++inside changeHandler'+event.target.name);
    console.log('+++inside changeHandler value'+event.target.value);

  }
  handleChange(event) {
    console.log('+++inside handle change'+event.target.name);
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
    console.log('+++handle change'+event.target.dataset.column);
    if(event.target.name=='Required Date'){
      console.log('+++selected required date'+event.target.value);
      this.requireddate = event.target.value;
    }
    else if(event.target.dataset.column == "isSelected" || event.target.dataset.column=='transferOrderQty'){
      console.log('+++selected checkbox and transfer order qty'+event.target.value);
      let solid = this.sollist[rowindex].objSOLine.Id;
      // let tempWrap = this.sollist;
       let tempWrap = JSON.parse(JSON.stringify(this.sollist));
       console.log('this.solid -> ' + solid);
       console.log('this.tempWrap -> ' + tempWrap);
       this.isChecked = true;
       for(let i=0; i< tempWrap.length; ++i)
       {
           if(solid == tempWrap[i].objSOLine.Id)
           {
            
               if(event.target.dataset.column == "isSelected"){
                 tempWrap[i].isSelected = event.target.checked;
               }
               else if(event.target.dataset.column == "transferOrderQty"){
                 tempWrap[i].objSOLine.giic_TransferOrderQty__c = event.target.value;//Assign to transfer order qty field
               }
           }
           if (tempWrap[i].isSelected == true){
             this.isChecked = false;
           }
       }
   
       this.sollist = tempWrap;
       console.log('this.sollist -> ' + this.sollist);
   
   console.log('rowindex'+rowindex);
   console.log('event'+event);
   console.log('event'+event.target);
   console.log('event'+event.target.dataset);
   console.log('event'+event.target.dataset.column);
    }
    
  }
   handleSuccess(e) {
        // Close the modal window and display a success toast
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Transfer Order Record Updated!',
                variant: 'success'
            })
        );
   }
   closeAction() {
		this.dispatchEvent(new CloseActionScreenEvent());
   }
    
    lookupFromWarehouseRecord(event){
      console.log('+++inside lookup record name'+event.detail.selectedRecord);
      if(event.detail.selectedRecord!=undefined){
        console.log('+++inside lookup record value'+event.detail.selectedRecord.Id + JSON.stringify(event.detail.selectedRecord.Id));
        this.fromwarehouse=event.detail.selectedRecord.Id;
      }
    }
    lookupToWarehouseRecord(event){
       console.log('+++inside lookup record name'+event.detail.selectedRecord);
        if(event.detail.selectedRecord!=undefined){
          console.log('+++inside lookup record value'+event.detail.selectedRecord.Id + JSON.stringify(event.detail.selectedRecord.Id));
          this.towarehouse=event.detail.selectedRecord.Id;
        }        
    }     
    handleCreateTransferOrder(event){
         console.log('+++inside handleCreateTransferOrder method');
         createTransferOrder({ 
          solList : JSON.stringify(this.sollist),
          fromWarehouse : this.fromwarehouse,
          toWarehouse : this.towarehouse,
          requiredDate : this.requireddate
      })
      .then(result => {
          const event = new ShowToastEvent({
              title: 'Transfer Order created',
              message: 'Transfer Order created',
              variant: 'success'
          });
          this.dispatchEvent(event);
          this.dispatchEvent(new CloseActionScreenEvent());
         // window.location.reload();
         this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: result,
              objectApiName: 'gii__TransferOrder__c',
              actionName: 'view'
          }
          });
      })
      .catch(error => {
          const event = new ShowToastEvent({
              title : 'Error',
              message : 'Error creating Transfer Order. Please Contact System Admin',
              variant : 'error'
          });
          this.dispatchEvent(event);
      });
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
            objectApiName: this.objapiname,
            actionName: 'view'
        }
    });
    }
}