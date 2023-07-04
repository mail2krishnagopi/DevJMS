import { LightningElement,api} from 'lwc';

export default class CreateHarvestProductFooter extends LightningElement {

@api finallist = [];

handleSave(event)
{
 console.log('From Footer'+ JSON.stringify(this.finallist));
}

}