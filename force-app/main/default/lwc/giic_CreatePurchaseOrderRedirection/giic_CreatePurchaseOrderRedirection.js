import { LightningElement,api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';


export default class GiicCreatePruchaseOrderRedirection extends NavigationMixin(LightningElement) {
    @api recordId;

    @api invoke() {
        console.log(this.recordId);
        var compDefinition;
        compDefinition = {
            componentDef: "c:giic_CreatePurchaseOrder",
            attributes: {
                recordId : this.recordId
            }
        };
        console.log(compDefinition);
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
console.log(encodedCompDef);
        this[NavigationMixin.Navigate] ({
            type: 'standard_webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef,
            }
        });

    }
}