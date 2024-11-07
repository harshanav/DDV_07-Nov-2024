import { LightningElement,api } from 'lwc';
import CustomStyle from '@salesforce/resourceUrl/CustomStyle';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getRecordDetails from '@salesforce/apex/DynamicDataVisualizerController.getRecordDetails';

export default class DynamicDataVisualizer extends LightningElement {
    @api settings;
    @api recordId;
    settingData = {};
    opendSummaryidx = -1;
    recordDataList = [];
    permanentRecordDataList = [];

    renderedCallback() {
        Promise.all([
            loadStyle(this, CustomStyle),
        ])
        .then(() => {
            console.log("All CSS are loaded. perform any initialization function.");
            
        })
        .catch(error => {
            console.log("Dynamic Data Visualizer failed to load the scripts", error);

        });
    }

    connectedCallback() {
        console.log('Harsh test >> '+this.settings + ' :: ' + this.recordId);
        if (this.settings) {
            this.settingData = JSON.parse(this.settings);               

            getRecordDetails({
                "settings" : this.settings,
                "recordId" : this.recordId
            })
            .then(result => {
                if(result.status === 'success') {

                   this.recordDataList = JSON.parse(JSON.stringify(result.recordDataList));
   
                   this.recordDataList.forEach( (a) => {
                         a.details = a.details.filter((obj, index, self) =>
                            index === self.findIndex((t) => (
                                t.label === obj.label && t.value === obj.value
                            ))
                        );
                   });

                    this.permanentRecordDataList = JSON.parse(JSON.stringify(result.recordDataList));;
                }  
            })
            .catch(error => {
                console.log('error :: ' + JSON.stringify(error));
            });
        }
    }

    get showActionCard() {
        return !this.settingData.recordTabToggle;
    }

    get showLogo() {
        return this.settingData.selectedTitleLogo && this.settingData.selectedTitleLogo != '';
    }

    handleSearchChange(event) {
        const searchKey = event.target.value;
        if (searchKey.length < 2) {
            this.recordDataList = this.permanentRecordDataList;
            return;
        }
        let records = this.filterRecords(searchKey);
        this.recordDataList = records;
    }

    filterRecords(searchKey) {
        return this.permanentRecordDataList.filter((obj) => {
            console.log(obj);
            return Object.keys(obj).some(key => obj[key].toString().toLowerCase().includes(searchKey.toLowerCase()))
        });
    }
}