import { LightningElement, api } from 'lwc';

export default class DynamicSummaryComponent extends LightningElement {
    imageSrc = 'https://poc-2024-dev-ed.file.force.com/servlet/servlet.FileDownload?file=015GC00000IVy8U';
    starRating = '90';
    accountFields;
    quoteButton = 'Complete Quote';
    options = [{ label: 'Account Name', fieldName: 'Name',apiName: 1 },
    { label: 'Type', fieldName: 'Type', apiName: 2},
    { label: 'OwnerId', fieldName: 'OwnerId', apiName: 3},
    { label: 'Phone', fieldName: 'Phone', apiName: 4},
    { label: 'LastModifiedById', fieldName: 'LastModifiedById', apiName: 5},
    { label: 'actions', fieldName: 'action', apiName: 6}];

    handleComplete() {
       if(this.quoteButton == 'Complete Quote')
        this.quoteButton = 'Clicked';
        else if(this.quoteButton == 'Clicked')
        this.quoteButton = 'Complete Quote';
    }

    handleStar() {
    }
}