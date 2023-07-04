import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
export default class GetParentRecord extends NavigationMixin(LightningElement) {
@api recordId;
@api name;
/*
@wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }
    connectedCallback(){
        console.log("URL Parameters => ", this.currentPageReference.state);
    }
}*/
}