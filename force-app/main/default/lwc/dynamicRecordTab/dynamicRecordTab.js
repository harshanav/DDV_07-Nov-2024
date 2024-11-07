import {LightningElement,api} from 'lwc';
import CustomStyle from '@salesforce/resourceUrl/CustomStyle';
import {loadStyle,loadScript} from 'lightning/platformResourceLoader';

export default class DynamicRecordTab extends LightningElement {
    @api recordDataList = [];
    isCSSLoaded = false;
    recordData;
    isSpinner = false;

    renderedCallback() {
        if (!this.isCSSLoaded) {
            Promise.all([
                loadStyle(this, CustomStyle),
                
            ])
            .then(() => {
                this.isCSSLoaded = true;
               // console.log('line 19',JSON.stringify(this.recordData));
                console.log("All CSS are loaded. perform any initialization function.");
            })
            .catch(error => {
                this.isCSSLoaded = false;
                console.log("Dynamic Record Tab failed to load the scripts", error);
            });
        }
    }

    openTab(event) {
       
        this.isSpinner = true;
        this.recordData = null;
        let indx = event.currentTarget.dataset.id;
        this.recordData = this.recordDataList[indx];
       
        let targetElement = event.currentTarget;
        //console.log('targetElement ', targetElement.className += " active");
        //targetElement.className += " active";
        // Declare all variables
        targetElement.classList.add('active');
        var i, tabcontent, tablinks;
        //targetElement.classList.toggle('active-tab');
        // Get all elements with class="tabcontent" and hide them
        tabcontent = this.template.querySelectorAll('.tabcontent');
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].style.display = "none";
        }
        // Get all elements with class="tablinks" and remove the class "active"
        tablinks = this.template.querySelectorAll(".tablinks");
        for (i = 0; i < tablinks.length; i++) {
            //tablinks[i].className = tablinks[i].className.replace(" active", "");
            if(targetElement == tablinks[i]){
                console.log('test');
                tablinks[i].classList.add('active');
            }
            else{
                tablinks[i].classList.remove('active-tab');
            }
            
             
        }
  
         targetElement.classList.toggle('active-tab');
         //targetElement.classList.toggle('active');
        
        if(targetElement.classList.contains('active-tab')){
           this.recordData = this.recordDataList[indx];
        }
        else{
              this.recordData = null;
        }
        setTimeout(() => {
            this.isSpinner = false;
        }, 1000);
    }
  
}