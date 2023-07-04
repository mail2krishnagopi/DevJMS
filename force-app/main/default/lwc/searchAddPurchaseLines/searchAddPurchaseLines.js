import { LightningElement,api,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import searchAddProduct from'@salesforce/apex/giic_CreatePurchaseRequistionLine.searchAddProduct';
import createPurchaseReqLines from'@salesforce/apex/giic_CreatePurchaseRequistionLine.createPurchaseReqLines';

export default class Giic_AddPurchaseOrderLines extends NavigationMixin(LightningElement) {

    @api productList = [];
    @api finallist = [];
    @api recid;

    
handleDeleteRow(event)
{
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
        console.log('this.finallist -> ' + this.finallist);
    
    let woId = this.finallist[rowindex].objProdRef.Id;
    let tempWrap = JSON.parse(JSON.stringify(this.finallist));
    let itemListdupe= [...tempWrap];
    let dellist= [];
    let finalOutList= [];
    
    
        console.log('this.tempWrap -> ' + tempWrap);
       // for(let i=0; i< tempWrap.length; ++i)
        //{
           // console.log('this.tempWrap -> ' + tempWrap[i]);
            if(woId == tempWrap[rowindex].objProdRef.Id)
            {
                dellist.push(tempWrap[rowindex]);
            }
    
     // }
      console.log('tempWrap.length' +tempWrap.length );
      
      if( tempWrap.length>=1){
        tempWrap.splice(rowindex, 1);
    }
    itemListdupe.splice(rowindex, 1);

    this.finalOutList =tempWrap;
    this.finallist = JSON.parse(JSON.stringify(this.finalOutList));

      console.log('this.finallist -> ' + JSON.parse(JSON.stringify(this.finalOutList)));

}


handleSave(event)
{
 console.log('From Footer'+ JSON.stringify(this.finallist) );

 //this.clickedButtonLabel = event.target.label;
//this.isLoading = true;
console.log('Handle createPurchaseReqLines');

createPurchaseReqLines({ 
    finalList : JSON.stringify(this.finalList),
    purReqId: this.recid
})
.then(result => {
    console.log('result' + result);  
    //this.isLoading = false;
    const event = new ShowToastEvent({
        title: 'Record created',
        message: 'Record  created',
        variant: 'success'
    });
   this.dispatchEvent(event);
    this.dispatchEvent(new CloseActionScreenEvent());
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: result,
            objectApiName: 'giic_WorkOrder__c',
            actionName: 'view'
        }
    });
    
    
    //window.location.reload();
})

.catch(error => {
    console.log('error'+ error);
   // this.isLoading = false;
    const event = new ShowToastEvent({
        title : 'Error',
        message : 'Error creatingHarvest Product . Please Contact System Admin',
        variant : 'error'
    });
    this.dispatchEvent(event);
});
}
}