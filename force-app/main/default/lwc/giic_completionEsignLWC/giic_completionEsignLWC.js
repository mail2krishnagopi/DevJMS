import { LightningElement, api,wire,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
//import sResource from '@salesforce/resourceUrl/signature';
import getServiceTicketLineList from'@salesforce/apex/giic_completeEsign.getServiceTicketLineList';
import saveSignature from '@salesforce/apex/giic_completeEsign.saveSignature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

let isMousePressed, 
isDotFlag = false,
prevX = 0,
currX = 0,
prevY = 0,
currY = 0;            

let penColor = "#000000"; 
let lineWidth = 1.5;     

let canvas, ctx; //storing canvas context
let dataURL,convertedDataURI; //holds image data

export default class Giic_completionEsignLWC extends NavigationMixin(LightningElement) {
@api recordid;
@track isLoading = false;
@track stlList;
@api signedBy;
@track isChecked = true;
@api fileName;
@api headerText='Use Draw sign for Custom E-Signature';

donotload = false;
drawing = false;
lastX =0;
lastY =0;


get containerClass() {
if (this.isPhone()) {
    return 'slds-p-horizontal_small';
} else {
    return 'slds-p-horizontal_medium';
}
}

isPhone() {
return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
}




@wire(getServiceTicketLineList, {
recId: '$recordid' 
})

WireServiceTicketLineRecords({error, data}){
if(data){
console.log('success'+ data); 
var tempList = [];  
for (var i = 0; i < data.length; i++) { 
let tempRecord = Object.assign({}, data[i]);
tempList.push(tempRecord);  
}
console.log('tempList ' + tempList);
//let tempWrap = JSON.parse(JSON.stringify(this.tempAFList));
/*for(let i=0; i< tempList.length; ++i)
{
   console.log('Asset REF :' + tempList[i]?.objSTLRef?.gii__AssetReference__r?.Name);
   if(tempList[i]?.objSTLRef?.gii__AssetReference__r?.Name == undefined)
   {
    console.log('if statement');   
   tempList[i].objSTLRef.gii__AssetReference__r.Name = " ";
   }
}
*/

this.stlList = tempList;
//console.log('tempWrap ' + tempWrap);
console.log('stlList' + JSON.stringify(this.stlList));     

}   
}

handleSelectAll(event) {
console.log('In handleSelectAll::::');
let tempWrap = JSON.parse(JSON.stringify(this.stlList));
console.log('tempWrap'+ tempWrap);
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
this.stlList = tempWrap;
console.log('Selected sTL Records' + this.stlList);
const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
for (const toggleElement of toggleList) {
toggleElement.checked = event.target.checked;
}

}

changeSelectHandler(event) {
let rowindex = event.target.dataset.rowindex;
console.log('this.rowindex -> ' + rowindex);


let stlId = this.stlList[rowindex].objSTLRef.Id;
console.log('this.stlId -> ' + stlId);
let tempWrap = JSON.parse(JSON.stringify(this.stlList));

console.log('this.tempWrap -> ' + tempWrap);


this.isChecked = true;
for(let i=0; i< tempWrap.length; ++i)
{
console.log('this.tempWrap -> ' + tempWrap[i].objSTLRef.Id);
if(stlId == tempWrap[i].objSTLRef.Id)
{
if(event.target.dataset.column == "isSelected"){
tempWrap[i].isSelected = event.target.checked;
}
}
if (tempWrap[i].isSelected == true){
this.isChecked = false;
}
}
this.stlList = tempWrap;
console.log('Selected sTL Records ==> ' + JSON.stringify(this.stlList));

}


saveSignature(e)
{
dataURL = canvas.toDataURL("image/jpg");
//convert that as base64 encoding
convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");

console.log('this.recordid', this.recordid +' ' + this.fileName );
this.isLoading = true;
saveSignature({signElement: convertedDataURI,recId : this.recordid,stlSelectedList :this.stlList,signedBy :this.fileName })
.then(result => {
    this.isLoading = false;
console.log('result' + result); 
const event = new ShowToastEvent({
title: 'Success',
message: 'Signature saved in STL',
variant: 'success',
});
this.dispatchEvent(event);
this.dispatchEvent(new CloseActionScreenEvent());
this[NavigationMixin.Navigate]({
type: 'standard__recordPage',
attributes: {
recordId: this.recordid,
objectApiName: 'gii__ServiceTicket__c',
actionName: 'view'
}

});

})
.catch(error => {
    this.isLoading = false;
//show error message
console.log('Error :', error);
this.dispatchEvent(
new ShowToastEvent({
title: 'Error uploading signature',
//message: error.body.message,
variant: 'error',
}),
);
});
}


renderedCallback() {
canvas = this.template.querySelector('.signature-canvas');
ctx = canvas.getContext('2d');
ctx.lineCap = 'round';
this.addEvents();
/*canvas.addEventListener('touchstart', this.handleTouchStart.bind(this));
canvas.addEventListener('touchmove', this.handleTouchMove.bind(this));
canvas.addEventListener('touchend', this.handleTouchEnd.bind(this));
canvas.addEventListener('touchcancel', this.handleTouchEnd.bind(this));*/
}

addEvents() {
canvas.addEventListener('mousemove', this.handleMouseMove.bind(this));
canvas.addEventListener('mousedown', this.handleMouseDown.bind(this));
canvas.addEventListener('mouseup', this.handleMouseUp.bind(this));
canvas.addEventListener('mouseout', this.handleMouseOut.bind(this));
canvas.addEventListener("touchstart", this.handleTouchStart.bind(this));
canvas.addEventListener("touchmove", this.handleTouchMove.bind(this));
canvas.addEventListener("touchend", this.handleTouchEnd.bind(this));
}

handleTouchStart(event) {
event.preventDefault();
this.drawing = true;
const touch = event.touches[0];
this.lastX = touch.clientX - canvas.offsetLeft;
this.lastY = touch.clientY - canvas.offsetTop;

/*ctx.beginPath();

ctx.moveTo(
    event.touches[0].clientX - this.canvas.getBoundingClientRect().left,
    event.touches[0].clientY - this.canvas.getBoundingClientRect().top
);
*/


}

handleTouchMove(event) {
event.preventDefault();
if(this.drawing) {
    const touch = event.touches[0];
    const currentX = touch.clientX - canvas.offsetLeft;
    const currentY = touch.clientY - canvas.offsetTop;

    ctx.beginPath();
    ctx.moveTo(this.lastX, this.lastY);
    ctx.lineTo(currentX, currentY);
    ctx.stroke();

    this.lastX = currentX;
    this.lastY = currentY;
}
/*if (this.isDrawing) {
    ctx.lineTo(
        event.touches[0].clientX - canvas.getBoundingClientRect().left,
        event.touches[0].clientY - canvas.getBoundingClientRect().top
    );
    ctx.stroke();
}*/
}

handleTouchEnd(event) {
event.preventDefault();
this.drawing = false;
}

handleClearClick() {
ctx.clearRect(0, 0, canvas.width, canvas.height);
}

handleMouseMove(event){
if (isMousePressed) {
this.setupCoordinate(event);
this.redraw();
}     
}    
handleMouseDown(event){
event.preventDefault();
this.setupCoordinate(event);           
isMousePressed = true;
isDotFlag = true;
if (isDotFlag) {
this.drawDot();
isDotFlag = false;
}     
}    
handleMouseUp(event){
isMousePressed = false;      
}
handleMouseOut(event){
isMousePressed = false;      
}
signIt(e)
{
var signText = e.detail.value;
this.fileName=signText;
ctx.font = "30px GreatVibes-Regular";
this.handleClearClick(e);
ctx.fillText(signText, 30, canvas.height/2);
}


setupCoordinate(eventParam){
    const clientRect = canvas.getBoundingClientRect();
    prevX = currX;
    prevY = currY;
    currX = eventParam.clientX -  clientRect.left;
    currY = eventParam.clientY - clientRect.top;
    }
    
    redraw() {
    ctx.beginPath();
    ctx.moveTo(prevX, prevY);
    ctx.lineTo(currX, currY);
    ctx.strokeStyle = penColor;
    ctx.lineWidth = lineWidth;        
    ctx.closePath(); 
    ctx.stroke(); 
    }
    drawDot(){
    ctx.beginPath();
    ctx.fillStyle = penColor;
    ctx.fillRect(currX, currY, lineWidth, lineWidth); 
    ctx.closePath();
    }
}