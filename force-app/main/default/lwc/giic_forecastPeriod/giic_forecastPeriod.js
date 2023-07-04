import { LightningElement, api, track } from 'lwc';

export default class ForecastPeriod extends LightningElement {

    @track mapValue;
    @api mapkey ;
    @api mapcollection = new Map();

    connectedCallback(){
        this.mapValue = this.mapcollection[this.mapkey];
    }
}