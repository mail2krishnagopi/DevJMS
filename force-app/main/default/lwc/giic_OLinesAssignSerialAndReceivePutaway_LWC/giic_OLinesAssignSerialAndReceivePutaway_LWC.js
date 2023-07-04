import { LightningElement, wire, track, api} from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import processSelectedRecords from '@salesforce/apex/giic_RecieveandPutaway.processSelectedRecords';
import getReceiptQueueforTOL from '@salesforce/apex/giic_RecieveandPutaway.getReceiptQueueforTOL';
import getPOLineQuantity from '@salesforce/apex/giic_RecieveandPutaway.getPOLineQuantity';
import getIsLocationBinControlled from '@salesforce/apex/giic_RecieveandPutaway.getIsLocationBinControlled';

export default class Giic_OLinesAssignSerialAndReceivePutaway_LWC extends NavigationMixin(LightningElement) {
    @track itemList = [];
    @track locationRecIdSC;
	@track locationBinRecIdSC;
	@track selectedRecordIdsSC = [];
	@track purchaseOrderLineRecordIdsSC = [];
	@track quantityRecordIdsSC = [];
	@track locationRecordIdsSC = [];
	@track locationBinRecordIdsSC = [];
	@track transferOrderRecordIdsSC = [];
	@track transferOrderLineRecordIdsSC = [];
	@track productRecordIdsSC = [];
	@track recivedQuantityRecordIdsSC = [];
    @api selectedLine;
    @api productSearchKey;
	@api warehouseSearchKey;
    @api productSerial = [];
	@api receiptQueueforTOL = [];
	@api poLineQuantity = [];
	recivedQuantity = 0;
	tempDataList = [];
	locationBinMandatory = false;
	
    @wire(CurrentPageReference)
    createProductSerialList() {
		this.itemList = [];
        this.receiptQueueforTOL = [];
        this.tempDataList = [];
		this.selectedControlledLine = JSON.parse(JSON.stringify(this.selectedLine));
		if(this.selectedControlledLine.transferOrderLineId != null && this.selectedControlledLine.transferOrderLineId != '' && this.selectedControlledLine.transferOrderLineId != undefined){
			let toLineId = this.selectedControlledLine.transferOrderLineId;
            getReceiptQueueforTOL({
				transferOrderLine: toLineId
			})
			.then(result => {
				if(result){
					let tempWrapRQ = JSON.parse(JSON.stringify(result)); 
					for(let i=0; i < tempWrapRQ.length; ++i)
					{
                       this.tempDataList.push(tempWrapRQ[i].ProductSerialName);
					}
					this.receiptQueueforTOL = JSON.parse(JSON.stringify(this.tempDataList));
					this.tempDataList = [];
					this.itemList = [];
					for(let i=1;i<=this.receiptQueueforTOL.length;i++){
						this.itemList.push(i);
					}
				}
			});
		}
		else if(this.selectedControlledLine.purchaseOrderLineId != null && this.selectedControlledLine.purchaseOrderLineId != '' && this.selectedControlledLine.purchaseOrderLineId != undefined){
			let poLineId = this.selectedControlledLine.purchaseOrderLineId;
            getPOLineQuantity({
				purchaseOrderLine: poLineId
			})
			.then(result => {
				if(result){
					let tempWrapRQ = JSON.parse(JSON.stringify(result)); 
					for(let i=0; i < tempWrapRQ.length; ++i)
					{
                       this.tempDataList.push(tempWrapRQ[i].receivedQuantity);
					}
					this.poLineQuantity = JSON.parse(JSON.stringify(this.tempDataList));
					this.tempDataList = [];
					this.itemList = [];
					for(let i=1;i<=this.poLineQuantity[0];i++){
						this.itemList.push(i);
					}
				}
			});
		}
    }

    handleLocationChangeSerialControlled(event){
		if(event.detail.selectedRecord != undefined ){
			this.locationRecIdSC = JSON.parse(JSON.stringify(event.detail.selectedRecord.Id));   
			this.selectedControlledLine.locationId = this.locationRecIdSC;
			getIsLocationBinControlled({
				locId: this.selectedControlledLine.locationId
			})
			.then(result => {
				if(result){
					this.locationBinMandatory = true;
					this.dispatchEvent(new ShowToastEvent({
						title: 'Error',
						message: 'Location Bin is Mandatory. Please enter value before Proceeding',
						variant: 'error',
						mode: 'sticky'
					}));
				}
				else{
					this.locationBinMandatory = false;
				}
			});
		}
		if(event.detail.selectedRecord == undefined ){
			this.locationRecIdSC = '';
			this.selectedControlledLine.locationId = '';
			this.locationBinMandatory = false
		}
	}
 
	handleLocationBinChangeSerialControlled(event){
		if(event.detail.selectedRecord != undefined ){
			this.locationBinRecIdSC = JSON.parse(JSON.stringify(event.detail.selectedRecord.Id));   
			this.selectedControlledLine.locationBinId = this.locationBinRecIdSC;
		}
		if(event.detail.selectedRecord == undefined ){
			this.locationBinRecIdSC = '';
			this.selectedControlledLine.locationBinId = '';
		}
	}

    backToSearchPage(){
        this.itemList = [];
        this.locationRecIdSC = ''
	    this.locationBinRecIdSC = '';
        this.selectedControlledLine = '';
        let cmpDef = {
			componentDef: "c:giic_Receive_Putaway_LWC",
			attributes: {
				//Value param pass to the next lwc component
				warehouseSearchKey: this.warehouseSearchKey,
				productSearchKey: this.productSearchKey,
				searchCriteria: this.selectedLine
            }
        };
		let encodedDef = btoa(JSON.stringify(cmpDef));
		this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedDef
            }
        });
    }
	
	captureProductSerial(event){
        let rowindex = event.target.dataset.rowindex;
		let duplicateFound = false;
		if(this.productSerial.length > 1 && event.target.value != null && event.target.value != undefined && event.target.value != ''){
			duplicateFound = false;
			duplicateFound = this.duplicateCheckProductSerial(this.productSerial, event.target.dataset.rowindex, event.target.value);
		}
		
		if(duplicateFound === false){
			this.productSerial[rowindex] = event.target.value;
		}
		else{
			this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please verify Product Serial, duplicate product serial entered '+event.target.value, 
                variant: 'error',
                mode: 'sticky'
            }));
		}
    }
	
	validateAndProcessData(){
		if(this.selectedControlledLine.locationId === null || this.selectedControlledLine.locationId === undefined || this.selectedControlledLine.locationId === '' ){
			this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Location is Mandatory. Please enter value before Proceeding',
				variant: 'error',
				mode: 'sticky'
			}));
		}
		else if((this.selectedControlledLine.locationBinId === null || this.selectedControlledLine.locationBinId === undefined || this.selectedControlledLine.locationBinId === '') && this.locationBinMandatory === true){
			this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Location Bin is Mandatory. Please enter value before Proceeding',
				variant: 'error',
				mode: 'sticky'
			}));
		}
		else if(this.productSerial.length === 0 || this.validateProductSerialCount(this.productSerial) === true){
			this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Product Serial is Required For Serial Controlled Product. Please enter Product Serial before Proceeding', 
                variant: 'error',
                mode: 'sticky'
            }));
		}
        else{
			let invalidPSVals = [];
			if(this.selectedControlledLine.transferOrderLineId != null && this.selectedControlledLine.transferOrderLineId != '' && this.selectedControlledLine.transferOrderLineId != undefined && this.productSerial.length > 0){
				invalidPSVals = [];
				if(this.receiptQueueforTOL.length > 0){
					let validPS = false;
					for(let i=0;i<this.productSerial.length;i++){
						if(this.productSerial[i] != null && this.productSerial[i] != '' && this.productSerial[i] != undefined){
							validPS = false;
							for(let j=0;j<this.receiptQueueforTOL.length;j++){
								if(this.productSerial[i] == this.receiptQueueforTOL[j]){
									validPS = true;
								}
							}
							if(!validPS){
								invalidPSVals.push(this.productSerial[i]);
							}
						}
					}
				}
			}
            if(invalidPSVals.length > 0){
				this.dispatchEvent(new ShowToastEvent({
					title: 'Error',
					message: 'Product Serial '+invalidPSVals+' does not match with Receipt Queue', 
					variant: 'error',
					mode: 'sticky'
				}));
			}
            else{
				this.selectedRecordIdsSC.push(this.selectedControlledLine.purchaseOrderId);
				this.purchaseOrderLineRecordIdsSC.push(this.selectedControlledLine.purchaseOrderLineId);
				this.quantityRecordIdsSC.push(this.selectedControlledLine.quantity);
				this.locationRecordIdsSC.push(this.selectedControlledLine.locationId);
				this.locationBinRecordIdsSC.push(this.selectedControlledLine.locationBinId);
				this.productRecordIdsSC.push(this.selectedControlledLine.productId);
				this.transferOrderLineRecordIdsSC.push(this.selectedControlledLine.transferOrderLineId);
				this.transferOrderRecordIdsSC.push(this.selectedControlledLine.transferOrderId);
				this.recivedQuantityRecordIdsSC.push(this.recivedQuantity);
				processSelectedRecords ({ 
					purchaseOrder : this.selectedRecordIdsSC,
					purchaseOrderLine : this.purchaseOrderLineRecordIdsSC,
					Quantity : this.quantityRecordIdsSC,
					Location : this.locationRecordIdsSC,
					LocationBin : this.locationBinRecordIdsSC,
					productSerial : this.productSerial,
					transferOrder : this.transferOrderRecordIdsSC,
					transferOrderLine : this.transferOrderLineRecordIdsSC,
					productRecords : this.productRecordIdsSC,
					recivedQuantity : this.recivedQuantityRecordIdsSC,
                    serialControlledPage: true
				})
				.then(() => {
					const toastEvent = new ShowToastEvent({
						title: 'Success',
						message: 'Selected records processed successfully',
						variant: 'success'
					});
					this.dispatchEvent(toastEvent);
					setTimeout(() => {
						location.reload();
					}, 4000);
				})
				.catch(error => {
					const toastEvent = new ShowToastEvent({
						title: 'Error',
						message: 'Records Could Not Be Processed. Please check the error ' + error.body.message,
						variant: 'error'
					});
					this.dispatchEvent(toastEvent);
					setTimeout(() => {
						location.reload();
					}, 10000);
				});
			}
		}
    }
	
	duplicateCheckProductSerial(pdArr, arrIndex, indexVal)
	{
		let resultToReturn = false;
		for (let i = 0; i < pdArr.length; i++){ 
            if(i !== parseInt(arrIndex, 10)){
                if (pdArr[i] === indexVal){
					resultToReturn = true;
					break;
                }
            }
        }
		return resultToReturn;
	}
	
	validateProductSerialCount(pdArr)
	{
		let resultToReturn = true;
		this.recivedQuantity = 0;
		for (let i = 0; i < pdArr.length; i++){ 
            if (pdArr[i] !== '' && pdArr[i] !== null && pdArr[i] !== undefined ){
				resultToReturn = false;
				this.recivedQuantity++;
            }
		}
		return resultToReturn;
	}
}