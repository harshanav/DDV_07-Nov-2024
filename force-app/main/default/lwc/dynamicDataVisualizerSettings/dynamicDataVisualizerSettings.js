import { LightningElement,api, wire, track } from 'lwc';
import allObjects from '@salesforce/apex/DynamicDataVisualizerController.getAllObjects';
import parentSchema from '@salesforce/apex/DynamicDataVisualizerController.getParentObjectSchema';
import childSchema from '@salesforce/apex/DynamicDataVisualizerController.getChildObjectSchema';
import picklistValues from '@salesforce/apex/DynamicDataVisualizerController.getPicklistValues';

export default class DynamicDataVisualizerSettings extends LightningElement {
    @track isLocalChange = false;
    @track allObjectsData = [];
    @track parentFields = [];
    @track parentFieldsets = [];
    @track childObjects = [];
    @track childFields = [];
    @track settings = {selectedParent : '',selectedParentPicklist : '',selectedParentFieldset : '',selectedParentFields : [],
        selectedChild : '', selectedChildPicklist : '', selectedChildFieldset : '', selectedChildFields : [],
        selectedParentImageField : '',selectedChildImageField : '',parentId : '', showAsRelatedList : false,
        recordTabToggle : false, parentBadgeFieldToggle : false, parentImageFieldToggle : false,
        childImageFieldToggle : false, parentPicklistValuesArr : [], selectedTitle : '', selectedTitleCaption : '', 
        selectedTitleLogo : '', selectedParentOrderBy : '', selectedParentMaxRecordsCount : '',
        selectedParentCardTitleField : '', selectedParentCardTitleCaption : '', 
        selectedChildOrderBy : '', selectedChildMaxRecordsCount : '', selectedChildCardTitleField : '', 
        selectedChildCardTitleCaption : '',selectedParentBadgeField : '', selectedChildBadgeField : '', 
        childBadgeFieldToggle : false, parentPicklists : [],
        childFieldsets : [], childPicklists : [], parentPiclistValues : [],
        picklistSelected : false, parentCurrentIndex : 0, parentTextAreaFields : [], childTextAreaFields : [],
        childPicklistValuesArr : [], childCurrentIndex : 0, childPiclistValues : [], selectedParentOrderByDir : 'ASC',
        childParentOrderByDir : 'ASC',titleToggle : false,provideSOQLParentToggle : false,customParentSOQL : '',
        provideSOQLChildToggle : false,customChildSOQL : '', parentImageBadgeFieldToggle : false,
        parentImageBadgeFieldIcon : '',selectedParentImagePicklist : '',childImageBadgeFieldToggle : false,
        childImageBadgeFieldIcon : '', selectedChildImagePicklist : '',parentImagePicklistValuesArr : [],
        childImagePicklistValuesArr : [], parentImagePiclistValues : [], childImagePicklistValues : [],
        parentImageCurrentIndex : 0, childImageCurrentIndex : 0, parentRelationshipName : '',selectedChildCompactFields : [],
        selectedParentCompactFields : [],childImagePiclistValues : []};
    
    spinnerClass = 'slds-show';
    orderByDir = [{label : 'ASC', value : 'ASC'}, {label : 'DESC', value : 'DESC'}];

    @api
    get inputVariables() {
      return this.settings;
    }
    set inputVariables(variables) {
        this.initializeSettings(variables);
    }

    @api
    get value() {
        return this.settings;
    }
    set value(val) {
        if(val && Object.values(val).length > 0){
            this.settings = JSON.parse(val);
            if(!this.isLocalChange){
                this.makeCall();
                this.isLocalChange = true;
            }
        }else{
            this.settings = this.settings;
            this.makeCall(); 
        }
    }

    initializeSettings(variables){
        if(variables && variables.length > 0){
            const param = variables.find(({ name }) => name === "settings");
            this.settings = param && JSON.parse(param.value) || this.settings;
            if(!this.isLocalChange){
                this.makeCall();
                this.isLocalChange = true;
            }
        }else{
            this.makeCall();    
        }
    }
    makeCall(){
        allObjects()
        .then(result =>{
            let tempObject = [];
            JSON.parse(JSON.stringify(result)).forEach(item => {
                tempObject.push({label : item.label, value :item.name});
            })
            this.allObjectsData = tempObject;
            if(this.settings.selectedParent !== null){
                console.log('Selected parent >>'+this.settings.selectedParent);
                this.getSelectedParentSchema();
            }
            if(this.settings.selectedChild !== null){
                this.getChildObjectSchema();
            }
        })
        .catch(error => {
            console.log(error);
        })
        .finally(() => {
            this.spinnerClass = 'slds-hide';
        })
    }    
    get isParentSelected(){
        return !this.settings.showAsRelatedList && this.settings.selectedParent !== '';
    }
    get hasParentAndManuallySelectionIsOff(){
        return this.isParentSelected && !this.settings.provideSOQLParentToggle;
    }
    get hasParentAndManuallySelectionIsOn(){
        return this.isParentSelected && this.settings.provideSOQLParentToggle;
    }
    get isChildSelected(){
        return this.settings.showAsRelatedList && this.settings.selectedChild !== '';
    }
    get hasChildAndManuallySelectionIsOff(){
        return this.isChildSelected && !this.settings.provideSOQLChildToggle;
    }
    get hasChildAndManuallySelectionIsOn(){
        return this.isChildSelected && this.settings.provideSOQLChildToggle;
    }
    get showWhenChildBadgeIsOn(){
        return this.settings.showAsRelatedList && this.settings.childBadgeFieldToggle;
    }
    get showParentsImageField(){
        return !this.settings.showAsRelatedList && this.settings.parentImageFieldToggle;
    }
    get showChildsImageField(){
        return this.settings.showAsRelatedList && this.settings.childImageFieldToggle;
    }
    get showParentsBadgeField(){
        return !this.settings.showAsRelatedList && this.settings.parentBadgeFieldToggle;
    }
    get showChildsBadgeField(){
        return this.settings.showAsRelatedList && this.settings.childBadgeFieldToggle;
    }
    get showParentImagePicklistFieldOptions(){
        return !this.settings.showAsRelatedList && this.settings.parentImageBadgeFieldToggle;
    }
    get showChildImagePicklistFieldOptions(){
        return this.settings.showAsRelatedList && this.settings.childImageBadgeFieldToggle;
    }
    get showPicklistValuesColorSelection(){
        return (this.showParentsBadgeField && this.settings.selectedParentPicklist != '' && this.settings.parentBadgeFieldToggle) || 
                (this.showChildsBadgeField && this.settings.selectedChildPicklist != '' && this.settings.childBadgeFieldToggle);
    }
    get showImagePicklistValuesColorSelection(){
        return (this.showParentImagePicklistFieldOptions &&  this.settings.selectedParentImagePicklist != '' && this.settings.parentImageBadgeFieldToggle) || 
                (this.showChildImagePicklistFieldOptions && this.settings.selectedChildImagePicklist != '' && this.settings.childImageBadgeFieldToggle);
    }
    get piclistValues(){
        if(!this.settings.showAsRelatedList && this.settings.selectedParentPicklist != ''){
            return this.settings.parentPiclistValues;
        }else if(this.settings.showAsRelatedList && this.settings.selectedChildPicklist != ''){
            return this.settings.childPiclistValues;
        }else{
            return [];
        }
    }
    get imagePiclistValues(){
        if(!this.settings.showAsRelatedList && this.settings.selectedParentImagePicklist != ''){
            return this.settings.parentImagePiclistValues;
        }else if(this.settings.showAsRelatedList && this.settings.selectedChildImagePicklist != ''){
            return this.settings.childImagePiclistValues;
        }else{
            return [];
        }
    }
    get selectedPicklistValuesArr(){
        if(!this.settings.showAsRelatedList && this.settings.selectedParentPicklist != ''){
            return this.settings.parentPicklistValuesArr;
        }else if(this.settings.showAsRelatedList && this.settings.selectedChildPicklist != ''){
            return this.settings.childPicklistValuesArr;
        }else{
            return [];
        }
    }
    get selectedImagePicklistValuesArr(){
        if(!this.settings.showAsRelatedList && this.settings.selectedParentImagePicklist != ''){
            return this.settings.parentImagePicklistValuesArr;
        }else if(this.settings.showAsRelatedList && this.settings.selectedChildImagePicklist != ''){
            return this.settings.childImagePicklistValuesArr;
        }else{
            return [];
        }
    }
    get dynamicParentPlaceHolder(){
        return 'Select ' + this.settings.selectedParent + ' Fields';
    }
    get dynamicChildPlaceHolder(){
        return 'Select ' + this.settings.selectedChild + ' Fields';
    }
    get parentChildAddButtonVisibility(){
        return (this.showParentsBadgeField && this.settings.selectedParentPicklist != '' && this.settings.parentBadgeFieldToggle && this.settings.parentPicklistValuesArr.length < this.settings.parentPiclistValues.length) || 
                (this.showChildsBadgeField && this.settings.selectedChildPicklist != '' && this.settings.childBadgeFieldToggle && this.settings.childPicklistValuesArr.length < this.settings.childPiclistValues.length);
    }
    get parentChildImageAddButtonVisibility(){
        return (this.showParentImagePicklistFieldOptions &&  this.settings.selectedParentImagePicklist != '' && this.settings.parentImageBadgeFieldToggle && this.settings.parentImagePicklistValuesArr.length < this.settings.parentImagePiclistValues.length) || 
                (this.showChildImagePicklistFieldOptions && this.settings.selectedChildImagePicklist != '' && this.settings.childImageBadgeFieldToggle && this.settings.childImagePicklistValuesArr.length < this.settings.childImagePiclistValues.length);
    }
    handleSettingChange(evt){
        if(evt.target.type === 'toggle'){
            this.settings[evt.target.dataset.id] = evt.target.checked;
        }else{
            this.settings[evt.target.dataset.id] = evt.target.value;
        }
        this.fireSettingsChangeEvent();
    }
    handleParentChange(evt){
        this.spinnerClass = 'slds-show';
        this.settings.selectedParent !== evt.target.value && this.resetParentRelatedSettings();
        this.settings.selectedParent = evt.target.value;
        console.log('check >>'+this.settings.selectedParent);

         this.getSelectedParentSchema();


       
    } 
    resetParentRelatedSettings(){
        this.settings.selectedParentPicklist = '';
        this.settings.selectedParentFieldset = '';
        this.settings.selectedParentFields = [];
        this.settings.selectedChild = '';
        this.settings.selectedParentImageField = '';
        this.settings.parentId = '';
        this.settings.showAsRelatedList = false;
        this.settings.parentBadgeFieldToggle = false;
        this.settings.parentImageFieldToggle = false;
        this.settings.parentPicklistValuesArr = [];
        this.settings.selectedParentOrderBy = '';
        this.settings.selectedParentMaxRecordsCount = '';
        this.settings.selectedParentCardTitleField = '';
        this.settings.selectedParentCardTitleCaption = '';
        this.settings.selectedParentBadgeField = '';
        this.parentFields = [];
        this.parentFieldsets = [];
        this.settings.parentPicklists = [];
        this.settings.parentPiclistValues = [];
        this.settings.picklistSelected = false;
        this.settings.parentCurrentIndex = 0;
        this.settings.parentTextAreaFields = [];
        this.settings.selectedParentOrderByDir = 'ASC';
        this.settings.provideSOQLParentToggle = false;
        this.settings.customParentSOQL = '';
        this.settings.parentImageBadgeFieldToggle = false;
        this.settings.parentImageBadgeFieldIcon = '';
        this.settings.selectedParentImagePicklist = '';
        this.settings.parentImagePicklistValuesArr = [];
        this.settings.parentImagePiclistValues = [];
        this.settings.parentImageCurrentIndex = 0;
        this.childObjects = [];
        this.settings.selectedParentCompactFields = [];
        this.resetChildRelatedSettings();
    }   
    resetChildRelatedSettings(){
        this.settings.selectedChildPicklist = '';
        this.settings.selectedChildFieldset = '';
        this.settings.selectedChildFields = [];
        this.settings.selectedChildImageField = '';
        this.settings.childImageFieldToggle = false;
        this.settings.selectedChildOrderBy = '';
        this.settings.selectedChildMaxRecordsCount = '';
        this.settings.selectedChildCardTitleField = '';
        this.settings.selectedChildCardTitleCaption = '';
        this.settings.selectedChildBadgeField = '';
        this.settings.childBadgeFieldToggle = false;
        this.childFields = [];
        this.settings.childFieldsets = [];
        this.settings.childPicklists = [];
        this.settings.childTextAreaFields = [];
        this.settings.childPicklistValuesArr = [];
        this.settings.childCurrentIndex = 0;
        this.settings.childPiclistValues = [];
        this.settings.childParentOrderByDir = 'ASC';
        this.settings.provideSOQLChildToggle = false;
        this.settings.customChildSOQL = '';
        this.settings.childImageBadgeFieldToggle = false;
        this.settings.childImageBadgeFieldIcon = '';
        this.settings.selectedChildImagePicklist = '';
        this.settings.childImagePicklistValuesArr = [];
        this.settings.childImagePicklistValues = [];
        this.settings.childImageCurrentIndex = 0;
        this.settings.parentRelationshipName = '';
        this.settings.selectedChildCompactFields = [];
        this.settings.childImagePiclistValues = [];
        this.fireSettingsChangeEvent();
    }
    getSelectedParentSchema(){
        this.spinnerClass = 'slds-show';
        let newparent = this.settings.selectedParent;
        parentSchema({objectName : this.settings.selectedParent})
        .then(result =>{

            let tempFields = [],tempFieldset = [], tempPicklists = [], tempchilds = [], tempTextArea =[];

            let tempResult = JSON.parse(JSON.stringify(result));
            tempResult.fields && tempResult.fields.forEach(item => {
                tempFields.push({label : item.label, value :item.name});
            });
            tempResult.fieldSets && tempResult.fieldSets.forEach(item => {
                tempFieldset.push({label : item.label, value :item.name});
            });
            tempResult.picklistFields && tempResult.picklistFields.forEach(item => {
                tempPicklists.push({label : item.label, value :item.name});
            });
            tempResult.childRelationships && tempResult.childRelationships.forEach(item => {
                tempchilds.push({label : item.label, value : item.name, parentRelationshipName : item.parentRelationshipName});
            });
            tempResult.textAreaFields && tempResult.textAreaFields.forEach(item => {
                tempTextArea.push({label : item.label, value :item.name});
            });
            this.settings.selectedParent =  newparent;
            this.parentFields = tempFields;
            this.parentFieldsets = tempFieldset;
            this.settings.parentPicklists = tempPicklists;
            this.childObjects = tempchilds;
            this.settings.parentTextAreaFields = tempTextArea;
            this.fireSettingsChangeEvent();
            console.log('Selected parent >>'+JSON.stringify(this.settings));

        })
        .catch(error => {
            console.log('Harsh', error);
        })
        .finally(() => {
            this.spinnerClass = 'slds-hide';
        })
    }

    handleCheckboxChange(evt){
        this.settings.showAsRelatedList = evt.target.checked;
        this.fireSettingsChangeEvent();
    }
    handleFieldsChange(evt){
        if(evt.detail.selectedOptions && evt.detail.selectedOptions.length > 0){
            let tempSelectedValues = [];
            evt.detail.selectedOptions.forEach(item => {
                tempSelectedValues.push(item.value);
            });
            this.settings[evt?.target?.dataset?.id] = tempSelectedValues;
            this.fireSettingsChangeEvent();
        }
    }

    handleParentPicklistChange(evt){
        this.spinnerClass = 'slds-show';
        this.settings.selectedParentPicklist = evt.target.value;
        this.settings.parentPicklistValuesArr = [];
        this.getPicklistValues(this.settings.selectedParent,this.settings.selectedParentPicklist,'parent');
    }
    handleParentImagePicklistChange(evt){
        this.spinnerClass = 'slds-show';
        this.settings.selectedParentImagePicklist = evt.target.value;
        this.settings.parentImagePicklistValuesArr = [];
        this.getPicklistValues(this.settings.selectedParent,this.settings.selectedParentImagePicklist,'parentImage');
    }
    handleChildPicklistChange(evt){
        this.spinnerClass = 'slds-show';
        this.settings.selectedChildPicklist = evt.target.value;
        this.settings.childPicklistValuesArr = [];
        this.getPicklistValues(this.settings.selectedChild,this.settings.selectedChildPicklist,'child');
    }
    handleChildImagePicklistChange(evt){
        this.spinnerClass = 'slds-show';
        this.settings.selectedChildImagePicklist = evt.target.value;
        this.settings.childImagePicklistValuesArr = [];
        this.getPicklistValues(this.settings.selectedChild,this.settings.selectedChildImagePicklist,'childImage');
    }
    getPicklistValues(obj, field, forRefs){
        picklistValues({objName : obj,fieldName :field})
        .then(result => {
            let tempValues=[];
            let tempResult =  JSON.parse(JSON.stringify(result));
            tempResult.fields && tempResult.fields.forEach(item => {
                tempValues.push({label : item.label, value :item.name});
            })
            if(forRefs === 'parent'){
                this.settings.parentPiclistValues= tempValues;
            }else if(forRefs === 'child'){
                this.settings.childPiclistValues= tempValues;
            }else if(forRefs === 'parentImage'){
                this.settings.parentImagePiclistValues= tempValues;
            }else if(forRefs === 'childImage'){
                this.settings.childImagePiclistValues= tempValues;
            }
            this.fireSettingsChangeEvent();
        })
        .catch(error => {

        })
        .finally(() => {
            this.spinnerClass = 'slds-hide';
        });
    }
    handleChildChange(evt){
        this.spinnerClass = 'slds-show';
        this.settings.selectedChild !== evt.target.value && this.resetChildRelatedSettings();
        this.settings.selectedChild = evt.target.value;
        this.childObjects.forEach(item => {
            if(item.value === evt.target.value){
                this.settings.parentRelationshipName = item.parentRelationshipName;
                return;
            }
        });
        this.getChildObjectSchema();
    }
    getChildObjectSchema(){
        childSchema({objName : this.settings.selectedChild})
        .then(result =>{
            let tempFields = [],tempFieldset = [], tempPicklists = [], tempTextArea=[];

            let tempResult = JSON.parse(JSON.stringify(result));
            tempResult.fields && tempResult.fields.forEach(item => {
                tempFields.push({label : item.label, value :item.name});
            });
            tempResult.fieldSets && tempResult.fieldSets.forEach(item => {
                tempFieldset.push({label : item.label, value :item.name});
            });
            tempResult.picklistFields && tempResult.picklistFields.forEach(item => {
                tempPicklists.push({label : item.label, value :item.name});
            });
            tempResult.textAreaFields && tempResult.textAreaFields.forEach(item => {
                tempTextArea.push({label : item.label, value :item.name});
            });
            this.childFields = tempFields;
            this.settings.childFieldsets = tempFieldset;
            this.settings.childPicklists = tempPicklists;
            this.settings.childTextAreaFields = tempTextArea;
            this.fireSettingsChangeEvent();
        })
        .catch(error => {
            console.log(error);
        })
        .finally(() => {
            this.spinnerClass = 'slds-hide';
        })
    }
    handleAddButton(){
        if(!this.settings.showAsRelatedList){
            let tempPicklistArr = {_id : this.settings.parentCurrentIndex, selectedValue : '', selectedColor : ''};
            this.settings.parentPicklistValuesArr.push(tempPicklistArr);
            this.settings.parentCurrentIndex++;
        }else{
            let tempPicklistArr = {_id : this.settings.childCurrentIndex, selectedValue : '', selectedColor : ''};
            this.settings.childPicklistValuesArr.push(tempPicklistArr);
            this.settings.childCurrentIndex++;
        }
        this.fireSettingsChangeEvent();
    }
    handleImageAddButton(){
        if(!this.settings.showAsRelatedList){
            let tempPicklistArr = {_id : this.settings.parentImageCurrentIndex, selectedValue : '', selectedColor : ''};
            this.settings.parentImagePicklistValuesArr.push(tempPicklistArr);
            this.settings.parentImageCurrentIndex++;
        }else{
            let tempPicklistArr = {_id : this.settings.childImageCurrentIndex, selectedValue : '', selectedColor : ''};
            this.settings.childImagePicklistValuesArr.push(tempPicklistArr);
            this.settings.childImageCurrentIndex++;
        }
        this.fireSettingsChangeEvent();
    }
    handlePicklistFieldValueChange(evt){
        if(!this.settings.showAsRelatedList){
            this.settings.parentPicklistValuesArr.forEach(item => {
                if(evt.target.name === item._id){
                    item.selectedValue = evt.target.value;
                }
            });
        }else{
            this.settings.childPicklistValuesArr.forEach(item => {
                if(evt.target.name === item._id){
                    item.selectedValue = evt.target.value;
                }
            });
        }
        this.fireSettingsChangeEvent();
    }
    handleImagePicklistFieldValueChange(evt){
        if(!this.settings.showAsRelatedList){
            this.settings.parentImagePicklistValuesArr.forEach(item => {
                if(evt.target.name === item._id){
                    item.selectedValue = evt.target.value;
                }
            });
        }else{
            this.settings.childImagePicklistValuesArr.forEach(item => {
                if(evt.target.name === item._id){
                    item.selectedValue = evt.target.value;
                }
            });
        }
        this.fireSettingsChangeEvent();
    }
    handleColorChange(evt){
        if(!this.settings.showAsRelatedList){
            this.settings.parentPicklistValuesArr.forEach(item => {
                if(evt.target.name === item._id){
                    item.selectedColor = evt.target.value;
                }
            });
        }else{
            this.settings.childPicklistValuesArr.forEach(item => {
                if(evt.target.name === item._id){
                    item.selectedColor = evt.target.value;
                }
            });
        }
        this.fireSettingsChangeEvent();
    }
    handleImageColorChange(evt){
        if(!this.settings.showAsRelatedList){
            this.settings.parentImagePicklistValuesArr.forEach(item => {
                if(evt.target.name === item._id){
                    item.selectedColor = evt.target.value;
                }
            });
        }else{
            this.settings.childImagePicklistValuesArr.forEach(item => {
                if(evt.target.name === item._id){
                    item.selectedColor = evt.target.value;
                }
            });
        }
        this.fireSettingsChangeEvent();
    }
    handleBadgeDeleteFieldValue(evt){
        if(this.showParentsBadgeField && this.settings.selectedParentPicklist != '' && this.settings.parentBadgeFieldToggle){
            this.settings.parentPicklistValuesArr.splice(this.settings.parentPicklistValuesArr.findIndex(a => a.id ===  evt.target.dataset.id) , 1)
        }else{
            this.settings.childPicklistValuesArr.splice(this.settings.childPicklistValuesArr.findIndex(a => a.id ===  evt.target.dataset.id) , 1)
        }
    }
    handleImageDeleteFieldValue(evt){
        if(this.showParentImagePicklistFieldOptions &&  this.settings.selectedParentImagePicklist != '' && this.settings.parentImageBadgeFieldToggle){
            this.settings.parentImagePicklistValuesArr.splice(this.settings.parentImagePicklistValuesArr.findIndex(a => a.id ===  evt.target.dataset.id) , 1)
        }else{
            this.settings.childImagePicklistValuesArr.splice(this.settings.childImagePicklistValuesArr.findIndex(a => a.id ===  evt.target.dataset.id) , 1)
        }
    }
    fireSettingsChangeEvent(){
        this.isLocalChange = true;
        console.log('Setting value: ', JSON.stringify(this.settings));
        this.dispatchEvent(new CustomEvent("valuechange", {detail: {value: JSON.stringify(this.settings)}}));

        const valueChangedEvent = new CustomEvent("configuration_editor_input_value_changed", {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail: {
            name: "settings",
            newValue : JSON.stringify(this.settings),
            newValueDataType: "String",
            },
        });
        this.dispatchEvent(valueChangedEvent);
    }
}