import { LightningElement, track, wire, api } from "lwc";  
import findRecords from "@salesforce/apex/giic_ReusableLookupController.findRecords";  

export default class LwcLookup extends LightningElement {  
  @track recordsList;  
  @track searchKey = "";  
  @api selectedvalue;  
  @api selectedRecordId;  
  @api objectApiName;  
  @api iconName;  
  @api lookupLabel;  
  @track message;  
  @api isprod = false;
  @api filter;
  @api selectedMaxCapacity;
  @api selectedWeekNumber;
  @api displayApiName;

  connectedCallback(){
  }

  onLeave(event) {  
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {  
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedvalue = event.target.dataset.name;
   this.selectedMaxCapacity = event.target.dataset.maxcapacity;
   this.selectedWeekNumber = event.target.dataset.weeknumber;
   this.searchKey = "";  
   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) {  
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   this.getLookupResult();  
  }  
   
  removeRecordOnLookup(event) {  
   this.searchKey = "";  
   this.selectedvalue = null;  
   this.selectedRecordId = null;  
   this.recordsList = null;  
   this.onSeletedRecordUpdate();  
 }  
   
 getLookupResult() {  
   findRecords({ searchKey: this.searchKey, objectName : this.objectApiName ,
    isprod:this.isprod, filter:this.filter,displayApiName:this.displayApiName})  
    .then((result) => {  
      console.log('inreualbel');
     if (result.length===0) {  
       this.recordsList = [];  
       this.message = "No Records Found";  
      } else {  
        let tempResult = [];
        this.recordsList = result; 
        tempResult = JSON.parse(JSON.stringify(this.recordsList));
        for(let i=0;i<tempResult.length;i++){
          console.log('displayName-----'+tempResult.giic_DisplayApiName__c);
          if(tempResult[i].giic_DisplayApiName__c !=undefined){
            tempResult[i].Name = tempResult[i].giic_DisplayApiName__c;
            tempResult[i].Id = tempResult[i].Id;
            console.log('******'+tempResult[i].Name);
          }
        }
       this.recordsList = tempResult; 
       console.log('reult@@@'+JSON.stringify(this.recordsList));
       this.message = "";  
      }  
      this.error = undefined;  
    })  
    .catch((error) => {  
     this.error = error;  
     this.recordsList = undefined;  
    });  
  }  
   
  onSeletedRecordUpdate(){  
   const passEventr = new CustomEvent('recordselection', {  
     detail: { selectedRecordId: this.selectedRecordId, selectedvalue: this.selectedvalue,selectedMaxCapacity :this.selectedMaxCapacity,selectedWeekNumber : this.selectedWeekNumber }  
    });  
    this.dispatchEvent(passEventr);  
  }  
 }