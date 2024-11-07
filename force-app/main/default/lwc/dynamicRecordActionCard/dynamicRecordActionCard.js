import {LightningElement,api} from 'lwc';
import CustomStyle from '@salesforce/resourceUrl/CustomStyle';
import jquery from '@salesforce/resourceUrl/jqueryLatest';
import {loadScript,loadStyle} from 'lightning/platformResourceLoader';

export default class DynamicRecordActionCard extends LightningElement {
    @api recordDataList;

    renderedCallback() {
        Promise.all([
            loadStyle(this, CustomStyle),
            loadScript(this, jquery),
        ])
        .then(() => {
            console.log("All scripts are loaded. perform any initialization function.");
        })
        .catch(error => {
            console.log("failed to load the scripts");
        });
    }

    toggleSection(event) {
        let targetElement = event.currentTarget;
        $(targetElement).addClass('test-100');
        let dropDown = $(targetElement).closest('.slds-accordion__list-item').find('.slds-accordion__content');
        $(dropDown).addClass('test-200');
        $(targetElement).closest('.slds-accordion').find('.slds-accordion__content').not(dropDown).slideUp();

        if ($(targetElement).hasClass('active')) {
            $(targetElement).removeClass('active');

        } else {
            $(targetElement).closest('.slds-accordion').find('.slds-accordion__section.active').removeClass('active');
            $(targetElement).addClass('active');
        }
        dropDown.stop(false, true).slideToggle();
        event.preventDefault();
        event.stopPropagation();
    }
    /* redirectToRecordUrL(event){
        let targetElement = event.currentTarget;
        let dropDown = $(targetElement).closest('.slds-accordion__list-item').find('.slds-accordion__content');
         $(targetElement).closest('.slds-accordion').find('.slds-accordion__content').slideUp();
        $(targetElement).closest('.slds-accordion').find('.slds-accordion__section.active').removeClass('active');
        dropDown.stop(false, false).slideToggle();
        event.preventDefault();
        let baseURL = window.location.origin;
        console.log(baseURL, 'baseURL');
        window.location.href= baseURL ;
        return false;
        
       
    }*/
}