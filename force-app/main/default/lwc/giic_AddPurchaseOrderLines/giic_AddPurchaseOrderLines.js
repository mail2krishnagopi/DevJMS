import { LightningElement,api,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import searchAddProduct from'@salesforce/apex/giic_CreatePurchaseRequistionLine.searchAddProduct';
import createPurchaseReqLines from'@salesforce/apex/giic_CreatePurchaseRequistionLine.createPurchaseReqLines';


export default class Giic_AddPurchaseOrderLines extends NavigationMixin(LightningElement) {

    @api recid;
    @api productList = [];
    @api finalList = [];
    tempList =[];
    loadChildCmp = false;
   // prodRecValue;
   
   qtyValue = 1;
    searchKey;
    connectedCallback(){
    }
    renderedCallback() {
        let prodCodeField = this.template.querySelector(".prodCode");
        setTimeout(() => {
            prodCodeField.focus()
        }, 3000);  
        
       

    }
    handleChangeProdCode(event){
        //if(event.target.value != '' || event.target.value != undefined){
        this.currentKeyValue = event.target.value;
       // }
    }

    handleKeyCodeEvent(event) {
        if (event.keyCode == 13) {
           console.log('KeyPress event invoked');
           this.currentKeyValue = event.target.value;
           this.validatehandleProductSearch(event);
       }
    }
    handleKeyQtyEvent(event) {
        if (event.keyCode == 13) {
           console.log('KeyPress event invoked');
           this.qtyValue = event.target.value;
           this.validatehandleProductSearch(event);
       }
    }
    handleQuantityChange(event){
    this.qtyValue = event.target.value;    
  
 }
 handleProdSelected(event){
    console.log('Selected Record Value on Parent Component is ' +event.detail.selectedRecord);
    if(event.detail.selectedRecord != undefined ){
        console.log('Selected Record Value on Parent Component inside ' +event.detail.selectedRecord);
     console.log('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord)+  JSON.stringify(event.detail.selectedRecord.Id));
    this.prodRecSearchValue = JSON.parse(JSON.stringify(event.detail.selectedRecord.Name));
    console.log('prodRecSearchValue'+ this.prodRecSearchValue);
    this.validatehandleProductSearch(event);
    }
}
validatehandleProductSearch(event){
    this.searchKeyValue = this.currentKeyValue;      
    console.log("searchKeyValue" + this.searchKeyValue + this.qtyValue);
    console.log('finalList' +  this.finalList + this.finalList.length); 
    let prodCodeField1 = this.template.querySelector(".prodCode");
    let existingrecord = 0;
   
   if((this.searchKeyValue== '' || this.searchKeyValue == undefined) && (this.prodRecSearchValue == '' || this.prodRecSearchValue == undefined))
    {
        console.log("prodCodeField1" + prodCodeField1);       
       // prodCodeField1.setCustomValidity("Please input prod code to search");
        const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Please input prod code to search',
            variant: 'warning',
         });
        this.dispatchEvent(event);
    }
    else if(this.finalList.length>0)
    {
        let tempWrap = JSON.parse(JSON.stringify(this.finalList));
        for(let i=0; i< tempWrap.length; ++i) {
            if(this.searchKeyValue != '' && this.searchKeyValue != undefined){
            if(this.searchKeyValue == tempWrap[i].objProdRef.gii__ProductCode__c)
            {
                existingrecord +=1;
            }
            }else if(this.prodRecSearchValue != '' && this.prodRecSearchValue != undefined)
            {
                if(this.prodRecSearchValue == tempWrap[i].objProdRef.Name)
            {
                existingrecord +=1;
            }
            }

        }
        if(existingrecord >0)
        {
            //prodCodeField1.setCustomValidity("Product already present in the added List");
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Product already present in the added List',
                variant: 'error',
             });
            this.dispatchEvent(event);
        }
        else{
            this.handleProductSearch(event);
        }
    }
    else{
        this.handleProductSearch(event);
    }

prodCodeField1.reportValidity();
    
}

 handleProductSearch(event){
   
    this.searchKeyValue = this.currentKeyValue;      
    console.log("searchKeyValue" + this.searchKeyValue + this.qtyValue);
    console.log('finalList' +  this.finalList + this.finalList.length); 
    let prodCodeField1 = this.template.querySelector(".prodCode");
  
   
        searchAddProduct({ 
    searchString: this.searchKeyValue,
    searchbyName : this.prodRecSearchValue,
    qty: this.qtyValue
        })
.then(result => {
    console.log('result' +JSON.stringify(result));   
  
    console.log("loadChildCmp" + this.loadChildCmp);
    this.searchKeyValue = '';
    this.currentKeyValue = '';
    let prodCodeField = this.template.querySelector(".prodCode");
    if(prodCodeField.value != ''){
    prodCodeField.value ='';
    }
    let prodQtyField = this.template.querySelector(".prodQty");
    if(prodCodeField.value != '1'){
    prodQtyField.value ='1';
    }
    let prodNameField = this.template.querySelector(".prodName");
    if(prodNameField.value != ''){
    prodNameField.value ='';
    }
    let tempORGWrap = JSON.parse(JSON.stringify(result));  
    this.tempList = this.finalList;
    for(let i=0; i< tempORGWrap.length; ++i)
    {
        this.tempList.push(tempORGWrap[i]);
        
    }
    console.log('finalList' + this.tempList); 
   
    this.finalList= JSON.parse(JSON.stringify(this.tempList));
    if(this.finalList.length>0)
    {
        this.loadChildCmp = true;
    }
     console.log("loadChildCmp" + this.loadChildCmp +  this.searchKeyValue);
    console.log('finalList' + this.finalList +  this.finalList.length); 
   
})
.catch(error => {
    console.log('error'+ error);
   // this.isLoading = false;
    const event = new ShowToastEvent({
        title : 'Error',
        message : 'Error creating Purchase Requistion Lines. Please Contact System Admin',
        variant : 'error'
    });
    this.dispatchEvent(event);
});


     
 
}

handleDeleteRow(event)
{
    let rowindex = event.target.dataset.rowindex;
    console.log('this.rowindex -> ' + rowindex);
        console.log('this.finallist -> ' + this.finalList);
    
    let woId = this.finalList[rowindex].objProdRef.Id;
    let tempWrap = JSON.parse(JSON.stringify(this.finalList));
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
    this.finalList = JSON.parse(JSON.stringify(this.finalOutList));

      console.log('this.finalList -> ' + JSON.parse(JSON.stringify(this.finalOutList)));

}


handleSave(event)
{
 console.log('From Footer'+ JSON.stringify(this.finallist) );

 //this.clickedButtonLabel = event.target.label;
//this.isLoading = true;
console.log('Handle createPurchaseReqLines');
console.log('this.qtyValue' + this.qtyValue);
//Added by Bhuvana quantity to apex
createPurchaseReqLines({ 
    finalList : JSON.stringify(this.finalList),
    purReqId: this.recid,
    updQntVal : this.qtyValue 
})
.then(result => {
    console.log('result' + result);  
    //this.isLoading = false;
    //Added by Bhuvana for sucess update message
    if(result != 'Duplicate'){
        const event = new ShowToastEvent({
            title: 'Record created',
            message: 'Record  created',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }else{
        const event = new ShowToastEvent({
            title: 'Record Updated',
            message: 'Record  Updated',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }
  //Added by Bhuvana
   this.dispatchEvent(event);
    this.dispatchEvent(new CloseActionScreenEvent());
    //Added by Bhuvana for navigation after success
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recid,
            objectApiName: 'gii__PurchaseRequisition__c',
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
        message : 'Error creating Purchase Requistion Lines. Please Contact System Admin',
        variant : 'error'
    });
    this.dispatchEvent(event);
});
}
handleBack(){//Added by Bhuvana for cancel button
    console.log('@#@# : '+this.workorderrecordid);
    this.dispatchEvent(new CloseActionScreenEvent());
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recid,
            objectApiName: 'gii__PurchaseRequisition__c',
            actionName: 'view'
        }
    });
}
}