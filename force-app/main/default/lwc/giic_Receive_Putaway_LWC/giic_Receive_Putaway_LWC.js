import { LightningElement,api,wire,track} from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import MY_CUSTOM_OBJECT from '@salesforce/schema/gii__Location__c';
import FIELD1_FIELD from '@salesforce/schema/gii__Location__c.Name';
import { refreshApex } from '@salesforce/apex';
import headerMessage from '@salesforce/label/c.giic_Receive_and_Putaway_Screen_header_Message';
import searchOrderList from'@salesforce/apex/giic_RecieveandPutaway.searchOrderList';
import processSelectedRecords from'@salesforce/apex/giic_RecieveandPutaway.processSelectedRecords';
import getLoggedInUserDefaultWarehouse from '@salesforce/apex/giic_RecieveandPutaway.getLoggedInUserDefaultWarehouse';
import getIsLocationBinControlled from '@salesforce/apex/giic_RecieveandPutaway.getIsLocationBinControlled';

export default class Giic_Receive_Putaway_LWC extends NavigationMixin(LightningElement){
	@api finalList = [];
	@api finalListSerial = [];
	@api warehouseSearchValue;
	@api productSearchValue;
	@api supplierSearchValue;
	@api purchaseOrdValue;
	@api transferOrdValue;
	@api defaultWarehouseIdKey;
    @api warehouseSearchKey;
    @api productSearchKey;
    @api purchaseSearchkey;
    @api transferSearchkey;
	@api searchCriteria;
	@track selectedRecordIds = [];
	@track purchaseOrderLineRecordIds = [];
	@track locationRecordIds = [];
	@track locationBinRecordIds = [];
	@track quantityRecordIds = [];
	@track recivedQuantityRecordIds = [];
	@track wholeRecord = [];
	@track productSerialRecords = [];
	@track transferOrderLineRecordIds = [];
	@track transferOrderRecordIds = [];
	@track productRecordIds = [];
	@track locationBinMandatory = [];
	@track inputProductSerialValue = '';
	@track locationRecId;
	@track locationBinRecId;
    useOrgSearchKey = false;
	isChecked = true;
	showCard = false;
	showCardSerialControl = false;
    showSearch = false;
	tempList =[];
	tempListSerial =[];
    defaultWarehouseValue;
    error;
	message = {
		headerMessage,
	};
	
    handleWarehouseChange(event){
        if(event.detail.selectedRecord != undefined ){
			this.warehouseSearchValue = JSON.parse(JSON.stringify(event.detail.selectedRecord.Name));
        }
        else if(event.detail.selectedRecord == undefined ){
            this.warehouseSearchValue = '';
        }
    }
    
	handleProdChange(event){
        if(event.detail.selectedRecord != undefined ){
			this.productSearchValue = JSON.parse(JSON.stringify(event.detail.selectedRecord.Name));
        }
        else if(event.detail.selectedRecord == undefined ){
            this.productSearchValue = '';
        }
    }
    
	handleSupplierChange(event){
        if(event.detail.selectedRecord != undefined ){
			this.supplierSearchValue = JSON.parse(JSON.stringify(event.detail.selectedRecord.Name));
        }
        else if(event.detail.selectedRecord == undefined ){
            this.supplierSearchValue = '';
        }
    }
    
	handlePurchaseOrderChange(event){
		if(event.detail.selectedRecord != undefined ){
			this.purchaseOrdValue = JSON.parse(JSON.stringify(event.detail.selectedRecord.Name));
        }
        else if(event.detail.selectedRecord == undefined ){
            this.purchaseOrdValue = '';
        }
    }
   
	handleTransferOrderChange(event){
		if(event.detail.selectedRecord != undefined ){
			this.transferOrdValue = JSON.parse(JSON.stringify(event.detail.selectedRecord.Name));
        }
        else if(event.detail.selectedRecord == undefined ){
            this.transferOrdValue = '';
        }
    }
   
    handleSearch(event){
		//if(this.warehouseSearchValue !== undefined && this.warehouseSearchValue !== null && this.warehouseSearchValue !== '' && ((this.purchaseOrdValue !== undefined && this.purchaseOrdValue !== null && this.purchaseOrdValue !== '' && (this.transferOrdValue === undefined || this.transferOrdValue === null || this.transferOrdValue  === '')) || (this.transferOrdValue !== undefined && this.transferOrdValue !== null && this.transferOrdValue  !== '' && (this.purchaseOrdValue === undefined || this.purchaseOrdValue === null || this.purchaseOrdValue === '')))){
        if((this.purchaseOrdValue !== undefined && this.purchaseOrdValue !== null && this.purchaseOrdValue !== '' && (this.transferOrdValue === undefined || this.transferOrdValue === null || this.transferOrdValue  === '')) || (this.transferOrdValue !== undefined && this.transferOrdValue !== null && this.transferOrdValue  !== '' && (this.purchaseOrdValue === undefined || this.purchaseOrdValue === null || this.purchaseOrdValue === ''))){
			this.searchErrorMessage = '';
			this.mandatroySearchFields = false;
			this.finalList = [];
			this.isLoading = true;
			this.locationBinMandatory = [];
			searchOrderList({            
				warehouseKeyValue: this.warehouseSearchValue,
				productKeyValue:this.productSearchValue,
				supplierKeyValue:this.supplierSearchValue,
				purchaseOrderValue:this.purchaseOrdValue,
				transferOrderValue: this.transferOrdValue,
				pageOnLoad: 'false'
					})
					.then(result => {
						let tempORGWrap = JSON.parse(JSON.stringify(result)); 
						for(let i=0; i< tempORGWrap.length; ++i)
						{
							if(tempORGWrap[i].serialproductChecked === false){
								this.tempList.push(tempORGWrap[i]);
							}
							else{
								this.tempListSerial.push(tempORGWrap[i]);
							}
						}
						this.finalList= JSON.parse(JSON.stringify(this.tempList));
						this.finalListSerial = JSON.parse(JSON.stringify(this.tempListSerial));
						this.isLoading = false;
                        if(this.finalList.length > 0){
							this.showCard = true;
						}
						else{
							this.showCard = false;
						}
						if(this.finalListSerial.length > 0){
							this.showCardSerialControl = true;
						}else{
							this.showCardSerialControl = false;
						}
						this.tempList = [];
						this.tempListSerial = [];
						this.productSearchValue= '';
                        if(this.showCard === false && this.showCardSerialControl === false){
							this.dispatchEvent(new ShowToastEvent({
								title: 'Search Result',
								message: 'No matching records found', 
								variant: 'warning',
								mode: 'sticky'
							}));
						}
					});
		}
		else{
			this.isLoading = false;
			this.showCard = false;
			this.showCardSerialControl = false;
			/*this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please provide Purchase Order or Transfer Order along with Warehouse to search', 
                variant: 'error',
                mode: 'sticky'
            }));*/
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please provide Purchase Order or Transfer Order to search', 
                variant: 'error',
                mode: 'sticky'
            }));
		}
    }

    handleSort(event) {
        const fieldName = event.target.dataset.sort;
		const sortDirection = this.sortDirection === 'asc' ? 1 : -1;
		this.finalList = this.finalList.sort((a, b) => {
			if (a[fieldName] < b[fieldName]) return -1 * sortDirection;
			if (a[fieldName] > b[fieldName]) return sortDirection;
			return 0;
		});
		this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
	}

    handleSelectAll(event) {
        let tempWrap = JSON.parse(JSON.stringify(this.finalList));
        for(let i=0; i< tempWrap.length; ++i){
            tempWrap[i].isSelected = event.target.checked;
            if(event.target.checked == true){
				this.isChecked = false;
            }
            if(event.target.checked == false){
				this.isChecked = true;
            }
        }
        this.finalList = tempWrap;
		const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
        for (const toggleElement of toggleList) {
            toggleElement.checked = event.target.checked;
        }
    }

	changeSelectHandler(event) {
        let rowindex = event.target.dataset.rowindex;
		let purOrdId = this.finalList[rowindex].purchaseOrderId;
		let purOrdLineId = this.finalList[rowindex].purchaseOrderLineId;
		let quantityRecord = this.finalList[rowindex].quantity;
		let recivedQuantityRecord = this.finalList[rowindex].receivedQuantity;
		let locationRecord =  this.finalList[rowindex].locationId;
		let locationBinRecord =  this.finalList[rowindex].locationBinId;
		let serialprodChecked = this.finalList[rowindex].serialproductChecked;
		let transferOrderRecord = this.finalList[rowindex].transferOrderId;
		let transferOrderLineRecord = this.finalList[rowindex].transferOrderLineId;
		let productRecord = this.finalList[rowindex].productId;
		let prodSerial = this.finalList[rowindex].productSerialVal;
		let wholeRecordID = this.finalList[rowindex];
		if (event.target.checked) {
			if(locationRecord !== undefined && locationRecord !== null && locationRecord  !== '' && (!this.locationBinMandatory.includes(locationRecord) || (this.locationBinMandatory.includes(locationRecord) && locationBinRecord !== undefined && locationBinRecord !== null && locationBinRecord  !==''))){
				/*if(serialprodChecked == true && purOrdLineId != null && purOrdLineId != ''){
					if(prodSerial !== undefined && prodSerial !== null && prodSerial  !== '' ){
						this.selectedRecordIds.push(purOrdId);
						this.purchaseOrderLineRecordIds.push(purOrdLineId);
						this.locationRecordIds.push(locationRecord);
						this.quantityRecordIds.push(quantityRecord);
						this.recivedQuantityRecordIds.push(recivedQuantityRecord);
						this.locationBinRecordIds.push(locationBinRecord);
						this.transferOrderLineRecordIds.push(transferOrderLineRecord);
						this.transferOrderRecordIds.push(transferOrderRecord);
						this.productSerialRecords.push(prodSerial); 
						this.productRecordIds.push(productRecord);
						this.errorMessage = ''; 
					}
					else {
						this.dispatchEvent(new ShowToastEvent({
							title: 'Error',
							message: 'Product Serial is Required For Serial Controlled Product. Please uncheck and enter Product Serial before Proceeding', 
							variant: 'error',
							mode: 'sticky'
						}));
					}
				}
				else {*/
					this.selectedRecordIds.push(purOrdId);
					this.purchaseOrderLineRecordIds.push(purOrdLineId);
					this.locationRecordIds.push(locationRecord);
					this.quantityRecordIds.push(quantityRecord);
					this.recivedQuantityRecordIds.push(recivedQuantityRecord);
					this.locationBinRecordIds.push(locationBinRecord);
					this.transferOrderLineRecordIds.push(transferOrderLineRecord);
					this.transferOrderRecordIds.push(transferOrderRecord);
					this.productSerialRecords.push(prodSerial); 
					this.productRecordIds.push(productRecord);
					this.errorMessage = ''; 
				//}
			}
			else if(locationRecord === undefined || locationRecord === null || locationRecord  === ''){
				this.dispatchEvent(new ShowToastEvent({
					title: 'Error',
					message: 'Location is Mandatory. Please uncheck and enter values before Proceeding', 
					variant: 'error',
					mode: 'sticky'
				}));
			}
			else if((locationRecord !== undefined && locationRecord !== null && locationRecord  !== '') && this.locationBinMandatory.includes(locationRecord) && (locationBinRecord === undefined || locationBinRecord === null || locationBinRecord  ==='')){
				this.dispatchEvent(new ShowToastEvent({
					title: 'Error',
					message: 'Location Bin is Mandatory. Please uncheck and enter values before Proceeding', 
					variant: 'error',
					mode: 'sticky'
				}));
			}
			/*  if(locationRecord !== undefined && locationRecord !== null && locationRecord  !== '' && locationBinRecord !== undefined && locationBinRecord !== null && locationBinRecord  !=='')
			{
				if(serialprodChecked == true ){
					if(inputField !== undefined && inputField !== null && inputField  !== '' ){
						this.productSerialRecords.push(inputField);    
						this.errorMessage = ''; 
					}
					else {
						this.errorMessage = 'Product Serial is Required For Serial Controlled Product. Please uncheck and enter Product Serial before Proceeding';
					}
				}
				else {
					this.productSerialRecords = this.productSerialRecords.filter(id => id !== inputField);
				}
				this.selectedRecordIds.push(purOrdId);
				this.purchaseOrderLineRecordIds.push(purOrdLineId);
				this.locationRecordIds.push(locationRecord);
				this.quantityRecordIds.push(quantityRecord);
				this.locationBinRecordIds.push(locationBinRecord);
				this.transferOrderLineRecordIds.push(transferOrderLineRecord);
				this.transferOrderRecordIds.push(transferOrderRecord);
			}
			else {
				this.selectedRecordIds = this.selectedRecordIds.filter(id => id !== purOrdId);
				this.purchaseOrderLineRecordIds = this.purchaseOrderLineRecordIds.filter(id => id !== purOrdLineId);
				this.locationRecordIds = this.locationRecordIds.filter(id => id !== locationRecord);
				this.quantityRecordIds = this.quantityRecordIds.filter(id => id !== quantityRecord);
				this.locationBinRecordIds = this.locationBinRecordIds.filter(id => id !== locationBinRecord);
				this.transferOrderLineRecordIds = this.transferOrderLineRecordIds.filter(id => id !== transferOrderLineRecord);
				this.transferOrderRecordIds = this.transferOrderRecordIds.filter(id => id !== transferOrderRecord);
				this.errorMessage = 'Location and Location Bin Are Required to Proceed';
			} */
		}
		else {
			this.errorMessage = '';
			this.selectedRecordIds = this.selectedRecordIds.filter(id => id !== purOrdId);
			this.purchaseOrderLineRecordIds = this.purchaseOrderLineRecordIds.filter(id => id !== purOrdLineId);
			this.locationRecordIds = this.locationRecordIds.filter(id => id !== locationRecord);
			this.quantityRecordIds = this.quantityRecordIds.filter(id => id !== quantityRecord);
			this.recivedQuantityRecordIds = this.recivedQuantityRecordIds.filter(id => id !== recivedQuantityRecord);
			this.locationBinRecordIds = this.locationBinRecordIds.filter(id => id !== locationBinRecord);
			this.productSerialRecords = this.productSerialRecords.filter(id => id !== prodSerial);
			this.transferOrderLineRecordIds = this.transferOrderLineRecordIds.filter(id => id !== transferOrderLineRecord);
			this.transferOrderRecordIds = this.transferOrderRecordIds.filter(id => id !== transferOrderRecord);
			this.productRecordIds = this.productRecordIds.filter(id => id !== productRecord)
		}
		/*  if(serialprodChecked == true ){
			if(inputField !== undefined && inputField !== null && inputField  !== '' ){
				this.selectedRecordIds.push(purOrdId);
				this.wholeRecord.push(wholeRecordID);
				//console.log('This is whole Record'+this.wholeRecord);
				this.errorMessage = '';
			}
			else {
				//console.log('Check this message');
				this.errorMessage = 'Product Serial is Required For Serial Controlled Product. Please uncheck and enter Product Serial before Proceeding';
			}
		}
		else {
			this.selectedRecordIds.push(purOrdId);
			this.purchaseOrderLineRecordIds.push(purOrdLineId);
			this.locationRecordIds.push(locationRecord);
			this.quantityRecordIds.push(quantityRecord);
			//console.log('This is quanitu'+this.quantityRecordIds);
			this.wholeRecord.push(wholeRecordID);
			//console.log('This is whole Record'+this.wholeRecord);
			this.errorMessage = '';
		}
		} else {
			this.errorMessage = '';
			this.selectedRecordIds = this.selectedRecordIds.filter(id => id !== purOrdId);
			this.purchaseOrderLineRecordIds = this.purchaseOrderLineRecordIds.filter(id => id !== purOrdLineId);
			this.locationRecordIds = this.locationRecordIds.filter(id => id !== locationRecord);
			this.quantityRecordIds = this.quantityRecordIds.filter(id => id !== quantityRecord);
			this.wholeRecord = this.wholeRecord.filter(id => id !== wholeRecordID);
		} */
		let tempWrap = JSON.parse(JSON.stringify(this.finalList));
		this.isChecked = true;
		for(let i=0; i< tempWrap.length; ++i)
		{
			if(purOrdId == tempWrap[i].purchaseOrderId)
			{
				if(event.target.dataset.column == "isSelected"){
					tempWrap[i].isSelected = event.target.checked;
				}
			}
			if (tempWrap[i].isSelected == true){
				this.isChecked = false;
			}
		}
		this.finalList = tempWrap;
	}
	
	handleLocationChange(event){
		let rowindex = event.target.dataset.rowindex;
		if(event.detail.selectedRecord != undefined ){
			this.locationRecId = JSON.parse(JSON.stringify(event.detail.selectedRecord.Id));   
			this.finalList[rowindex].locationId = this.locationRecId;
			getIsLocationBinControlled({
				locId: this.finalList[rowindex].locationId
			})
			.then(result => {
				if(result){
					let tempORGWrap = JSON.parse(JSON.stringify(result));
                    for(let i=0; i< tempORGWrap.length; i++)
					{
                        if(!this.locationBinMandatory.includes(tempORGWrap[i])){
						    this.locationBinMandatory.push(tempORGWrap[i]); 
                        }
					}
                    this.dispatchEvent(new ShowToastEvent({
						title: 'Error',
						message: 'Location Bin is Mandatory. Please enter value before Proceeding',
						variant: 'error',
						mode: 'sticky'
					}));
				}
			});
		}
		if(event.detail.selectedRecord == undefined ){
			this.locationRecId = '';
		}
	}
 
	handleLocationBinChange(event){
		let rowindex = event.target.dataset.rowindex;
		if(event.detail.selectedRecord != undefined ){
			this.locationBinRecId = JSON.parse(JSON.stringify(event.detail.selectedRecord.Id));   
			this.finalList[rowindex].locationBinId = this.locationBinRecId;
		}
		if(event.detail.selectedRecord == undefined ){
			this.locationBinRecId = '';
		}
	}

	handleProductSerialChange(event){
		let rowindex = event.target.dataset.rowindex;
		this.inputProductSerialValue = event.target.value;
		this.finalList[rowindex].productSerialVal = this.inputProductSerialValue;
	}

	handleButtonClick() {
        if(this.selectedRecordIds.length > 0) {
        	let locationDataError = false;
			let quantityDataError = false;
			let locationBinDataError = false;
			for(let i=0;i< this.selectedRecordIds.length;i++){
        		if(this.locationRecordIds[i] === undefined || this.locationRecordIds[i] === null || this.locationRecordIds[i]  === ''){
					locationDataError = true;
					break;
				}
				else if(this.locationRecordIds[i] !== undefined && this.locationRecordIds[i] !== null && this.locationRecordIds[i]  !== '' && this.locationBinMandatory.includes(this.locationRecordIds[i]) && (this.locationBinRecordIds[i] === undefined || this.locationBinRecordIds[i] === null || this.locationBinRecordIds[i] ==='')){
					locationBinDataError = true;
					break;
				}
				else if(parseInt(this.recivedQuantityRecordIds[i], 10) > parseInt(this.quantityRecordIds[i], 10) || this.recivedQuantityRecordIds[i] === '' || this.recivedQuantityRecordIds[i] === undefined || this.recivedQuantityRecordIds[i] === null || parseInt(this.recivedQuantityRecordIds[i], 10) === 0){
					quantityDataError = true;
					break;
				}
			}
			if(locationDataError === true){
				this.dispatchEvent(new ShowToastEvent({
					title: 'Error',
					message: 'Location is Mandatory. Please uncheck and enter values before Proceeding', 
					variant: 'error',
					mode: 'sticky'
				}));
			}
			else if(locationBinDataError === true){
				this.dispatchEvent(new ShowToastEvent({
					title: 'Error',
					message: 'Location Bin is Mandatory. Please uncheck and enter values before Proceeding', 
					variant: 'error',
					mode: 'sticky'
				}));
			}
			else if(quantityDataError === true){
				this.dispatchEvent(new ShowToastEvent({
					title: 'Error',
					message: 'Please verify Received Quantity, it cannot be more than Order Quantity', 
					variant: 'error',
					mode: 'sticky'
				}));
			}
			else{
				processSelectedRecords ({ 
					purchaseOrder : this.selectedRecordIds,
					purchaseOrderLine : this.purchaseOrderLineRecordIds,
					Quantity : this.quantityRecordIds,
					Location : this.locationRecordIds,
					LocationBin : this.locationBinRecordIds,
					productSerial : this.productSerialRecords,
					transferOrder : this.transferOrderRecordIds,
					transferOrderLine : this.transferOrderLineRecordIds,
					productRecords : this.productRecordIds,
					recivedQuantity : this.recivedQuantityRecordIds,
					serialControlledPage: false
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
					}, 5000);
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
		else{
			this.dispatchEvent(new ShowToastEvent({
				title: 'Error',
				message: 'Location is Mandatory. Please uncheck and enter values before Proceeding', 
				variant: 'error',
				mode: 'sticky'
			}));
		}
	}

	handleproductSerial(event){
		/*let rowindex = event.target.dataset.rowindex;
		let poId = this.finalList[rowindex].purchaseOrderId;
		let tempWrap = JSON.parse(JSON.stringify(this.finalList));
		for(let i=0; i< tempWrap.length; ++i)
		{
			if(poId == tempWrap[i].purchaseOrderId)
			{
				if(event.target.dataset.column == "prodSerial"){
					tempWrap[i].prodSerial = event.target.value;
				}
            }
		}
		this.finalList = tempWrap;*/
	}

    @wire(getLoggedInUserDefaultWarehouse)
    defaultWarehouse({error, data}){
		this.isLoading = true;
		this.showCard = true;
		this.showCardSerialControl = true;
		this.locationBinMandatory = [];
		if(this.searchCriteria !== undefined && this.searchCriteria !== null && this.searchCriteria !==''){
            this.useOrgSearchKey = true;
        }
		if(data && this.useOrgSearchKey === false){
			this.defaultWarehouseValue = data[0].defaultWareHouseId;
			this.warehouseSearchValue = data[0].defaultWareHouseName;
			this.useOrgSearchKey = false;
			this.showSearch = true;
            if(this.warehouseSearchValue !== undefined && this.warehouseSearchValue !== null && this.warehouseSearchValue !==''){
				this.finalList = [];
				searchOrderList({            
					warehouseKeyValue: this.warehouseSearchValue,
					productKeyValue:this.productSearchValue,
					supplierKeyValue:this.supplierSearchValue,
					purchaseOrderValue:this.purchaseOrdValue,
					transferOrderValue: this.transferOrdValue,
					pageOnLoad: 'true'
				})
				.then(result => {
					this.onPageLoadSearchResult(result);
				});
			}
        }   
        else if(this.useOrgSearchKey === true){
			if(this.warehouseSearchKey !== undefined && this.warehouseSearchKey !== null && this.warehouseSearchKey !==''){
				this.defaultWarehouseValue = this.searchCriteria.warehouseId;
				this.warehouseSearchValue = this.searchCriteria.warehouseName;
			}
			if(this.productSearchKey !== undefined && this.productSearchKey !== null && this.productSearchKey !==''){
				this.productSearchIdKey = this.searchCriteria.productId;
				this.productSearchValue = this.searchCriteria.productName;
			}
			this.purchaseSearchIdkey = this.searchCriteria.purchaseOrderId;
			this.purchaseOrdValue = this.searchCriteria.purchaseOrderName;
			this.transferSearchIdkey = this.searchCriteria.transferOrderId;
			this.transferOrdValue = this.searchCriteria.transferOrderName;
			this.useOrgSearchKey = false;
			this.showSearch = true;
			//if(this.warehouseSearchValue !== undefined && this.warehouseSearchValue !== null && this.warehouseSearchValue !=='' && ((this.purchaseOrdValue !== undefined && this.purchaseOrdValue !== null && this.purchaseOrdValue !== '') || (this.transferOrdValue !== undefined && this.transferOrdValue !== null && this.transferOrdValue  !== ''))){
            if((this.purchaseOrdValue !== undefined && this.purchaseOrdValue !== null && this.purchaseOrdValue !== '') || (this.transferOrdValue !== undefined && this.transferOrdValue !== null && this.transferOrdValue  !== '')){
                this.finalList = [];
                searchOrderList({            
                    warehouseKeyValue: this.warehouseSearchValue,
                    productKeyValue:this.productSearchValue,
                    supplierKeyValue:this.supplierSearchValue,
                    purchaseOrderValue:this.purchaseOrdValue,
                    transferOrderValue: this.transferOrdValue,
                    pageOnLoad: 'false'
                })
                .then(result => {
                    this.onPageLoadSearchResult(result);
                });
            }
            this.isLoading = false;
		}
        else if(data === null) {
			this.isLoading = false;
			this.showCard = false;
			this.showCardSerialControl = false;
            this.defaultWarehouseValue = '';
            this.warehouseSearchValue = '';
			this.productSearchIdKey = '';
			this.productSearchValue = '';
			this.purchaseSearchIdkey = '';
			this.purchaseOrdValue = '';
			this.transferSearchIdkey = '';
			this.transferOrdValue = '';
			this.useOrgSearchKey = false;
            this.showSearch = true;
        }
    }

    navigateToSerialControlled(event) {
        let rowindex = event.target.dataset.rowindex;
        let cmpDef = {
			componentDef: "c:giic_OLinesAssignSerialAndReceivePutaway_LWC",
			attributes: {
				//Value param pass to the next lwc component
                warehouseSearchKey: this.warehouseSearchValue,
                productSearchKey: this.productSearchValue,
				selectedLine: this.finalListSerial[rowindex]
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

    validateReceivedQuantity(event){
        let rowindex = event.target.dataset.rowindex;
        if(this.recivedQuantityRecordIds.length > 0){
            if(this.purchaseOrderLineRecordIds.length > 0 && this.finalList[rowindex].purchaseOrderLineId !== undefined){
                let polIndex = this.purchaseOrderLineRecordIds.indexOf(this.finalList[rowindex].purchaseOrderLineId);
                this.recivedQuantityRecordIds[polIndex] = event.target.value;
            }
            else if(this.transferOrderLineRecordIds.length > 0 && this.finalList[rowindex].transferOrderLineId !== undefined){
                let tolIndex = this.transferOrderLineRecordIds.indexOf(this.finalList[rowindex].transferOrderLineId);
                this.recivedQuantityRecordIds[tolIndex] = event.target.value;
            }
        }
		this.finalList[rowindex].receivedQuantity = event.target.value;
        if(parseInt(event.target.value, 10) > parseInt(this.finalList[rowindex].quantity, 10) || event.target.value === '' || event.target.value === undefined || event.target.value === null || parseInt(event.target.value, 10) === 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please verify Received Quantity, it cannot be more than Order Quantity', 
                variant: 'error',
                mode: 'sticky'
            }));
        }
    }
	
	onPageLoadSearchResult(result){
		let tempORGWrap = JSON.parse(JSON.stringify(result)); 
		for(let i=0; i< tempORGWrap.length; i++)
		{
			if(tempORGWrap[i].serialproductChecked === false){
				this.tempList.push(tempORGWrap[i]); 
			}
			else{
				this.tempListSerial.push(tempORGWrap[i]);
			}        
		}
		this.finalList= JSON.parse(JSON.stringify(this.tempList));
		this.finalListSerial = JSON.parse(JSON.stringify(this.tempListSerial));	
		if(this.finalList.length > 0){
			this.showCard = true;
		}
		else{
			this.showCard = false;
		}
		if(this.finalListSerial.length > 0){
			this.showCardSerialControl = true;
		}else{
			this.showCardSerialControl = false;
		}		
		this.searchErrorMessage = '';
		this.mandatroySearchFields = false;
		this.isLoading = false;
		this.tempList = [];
		this.tempListSerial = [];
	}
}