public inherited sharing class DynamicDataVisualizerService {
    private List<sObject> records;
    private DynamicDataWrapper wrapperObj;
    private Map<String, DynamicSchemaService.FieldsDataWrapper> apiNameWithDetailMap;
    private Set<String> soqlFields;
    private Map<String, String> lookupFieldWithName;
    public DynamicDataVisualizerService(List<sObject> records, DynamicDataWrapper wrapperObj, Map<String, DynamicSchemaService.FieldsDataWrapper> apiNameWithDetailMap, Set<String> soqlFields , Map<String, String> lookupFieldWithName) {
        this.records = records;
        this.wrapperObj = wrapperObj;
        this.apiNameWithDetailMap = apiNameWithDetailMap;
        this.soqlFields = soqlFields;
        this.lookupFieldWithName = lookupFieldWithName;
    }
    
    // Prepare parent data
    public List<DynamicRecordWrapper> prepareParentData() {
        List<DynamicRecordWrapper> dynamicRecWrapList = new List<DynamicRecordWrapper>();
        Integer index = 0;
        
        for (sObject sob : records) {
            DynamicRecordWrapper dynamicRecWrap = new DynamicRecordWrapper();
            try {
                dynamicRecWrap = processRecord(sob, wrapperObj, apiNameWithDetailMap, soqlFields,lookupFieldWithName, index, true);
                dynamicRecWrapList.add(dynamicRecWrap);
                index++;
            } catch (Exception e) {
                System.debug('Error processing record: ' + sob + ' - ' + e.getMessage() + e.getStackTraceString());
            }
        }
        
        return dynamicRecWrapList;
    }
    
    // Prepare child data
    public List<DynamicRecordWrapper> prepareChildData() {
        List<DynamicRecordWrapper> dynamicRecWrapList = new List<DynamicRecordWrapper>();
        Integer index = 0;
        for(sObject sob:records){
            DynamicRecordWrapper dynamicRecWrap=new DynamicRecordWrapper();
            try {
                dynamicRecWrap = processRecord(sob, wrapperObj, apiNameWithDetailMap, soqlFields,lookupFieldWithName, index, false);
                dynamicRecWrapList.add(dynamicRecWrap);
                index++;
            } catch (Exception e) {
                System.debug('Error processing record: ' + sob + ' - ' + e.getMessage() + e.getStackTraceString());
            }
        }
        return dynamicRecWrapList;
    }
    
    // Process a single record
    private static DynamicRecordWrapper processRecord(sObject sob, DynamicDataWrapper wrapperObj, Map<String, DynamicSchemaService.FieldsDataWrapper> apiNameWithDetailMap, Set<String> soqlFields, Map<String, String> lookupFieldWithName , Integer index, Boolean isParent) {
        DynamicRecordWrapper dynamicRecWrap = new DynamicRecordWrapper();
        dynamicRecWrap.index = index;
        dynamicRecWrap.recordurl = '/' + String.valueOf(sob.get('Id'));
        dynamicRecWrap.badgeTitle = String.isNotBlank(isParent ? wrapperObj.selectedParentPicklist : wrapperObj.selectedChildPicklist) ? String.valueOf(sob.get(isParent ? wrapperObj.selectedParentPicklist : wrapperObj.selectedChildPicklist)) : ''; 
        dynamicRecWrap.showBadge = String.isNotBlank(dynamicRecWrap.badgeTitle) ? (isParent ? wrapperObj.parentBadgeFieldToggle : wrapperObj.childBadgeFieldToggle) : false;
        dynamicRecWrap.badgeColor = wrapperObj.getBadgeColor(isParent, dynamicRecWrap.badgeTitle);
        dynamicRecWrap.imageUrl =  String.isNotBlank(isParent ? wrapperObj.selectedParentImageField : wrapperObj.selectedChildImageField) ?  String.valueOf(sob.get(isParent ? wrapperObj.selectedParentImageField : wrapperObj.selectedChildImageField)) : '';
        dynamicRecWrap.showImage = String.isNotBlank(dynamicRecWrap.imageUrl) ? (isParent ? wrapperObj.parentImageFieldToggle : wrapperObj.childImageFieldToggle) : false;
        dynamicRecWrap.title = String.isNotBlank(isParent ? wrapperObj.selectedParentCardTitleField : wrapperObj.selectedChildCardTitleField) ? String.valueOf(sob.get(isParent ? wrapperObj.selectedParentCardTitleField : wrapperObj.selectedChildCardTitleField)) : '';
        dynamicRecWrap.titleCaption = String.isNotBlank(isParent ? wrapperObj.selectedParentCardTitleCaption : wrapperObj.selectedChildCardTitleCaption) ? String.valueOf(sob.get(isParent ? wrapperObj.selectedParentCardTitleCaption : wrapperObj.selectedChildCardTitleCaption)) :'';
        dynamicRecWrap.badgeImageTitle = String.isNotBlank(isParent ? wrapperObj.selectedParentImagePicklist : wrapperObj.selectedChildImagePicklist) ? String.valueOf(sob.get(isParent ? wrapperObj.selectedParentImagePicklist : wrapperObj.selectedChildImagePicklist)) : ''; 
        dynamicRecWrap.showBadgeImage = String.isNotBlank(dynamicRecWrap.badgeImageTitle) ? (isParent ? wrapperObj.parentImageBadgeFieldToggle : wrapperObj.childImageBadgeFieldToggle) : false;
        dynamicRecWrap.badgeImageIcon = String.isNotBlank(isParent ? wrapperObj.parentImageBadgeFieldIcon : wrapperObj.childImageBadgeFieldIcon) ? (isParent ? wrapperObj.parentImageBadgeFieldIcon : wrapperObj.childImageBadgeFieldIcon) : '';
        dynamicRecWrap.badgeImageColor =wrapperObj.getbadgeImageColor(isParent, dynamicRecWrap.badgeImageTitle);
        
        //populate compactLayout Fileds
        if((isParent ? wrapperObj.selectedParentCompactFields : wrapperObj.selectedChildCompactFields) != NULL){
            for (String field : isParent ? wrapperObj.selectedParentCompactFields: wrapperObj.selectedChildCompactFields) {
                DynamicRecordWrapper.FieldData fieldData = new DynamicRecordWrapper.FieldData();
                DynamicSchemaService.FieldsDataWrapper fieldDataWrap = apiNameWithDetailMap.get(field);
                fieldData.label = fieldDataWrap.labelName;
                if(fieldDataWrap.dataType.toString() == 'DATE') {
                    fieldData.value = String.valueOf(Date.valueOf(sob.get(field)));
                }
                else {
                    fieldData.value = String.valueOf(sob.get(field));
                }
                if(String.isNotBlank(lookupFieldWithName.get(field))){
                    List<String>  lookupFieldWithNameList = lookupFieldWithName.get(field).split('\\.');
                    if(sob.getSObject(lookupFieldWithNameList[0]) != NULL){
                        fieldData.label = lookupFieldWithNameList[0].endsWith('__r') ? fieldDataWrap.labelName + ' Name': lookupFieldWithNameList[0];
                        fieldData.value = String.valueOf(sob.getSObject(lookupFieldWithNameList[0]).get(lookupFieldWithNameList[1]));
                    }
                }
                
                dynamicRecWrap.compactDetails.add(fieldData);
                dynamicRecWrap.details.add(fieldData);
            }
        }
        
        if(soqlFields!= NULL && !soqlFields.isEmpty()){
            for (String field : soqlFields) {
                DynamicRecordWrapper.FieldData fieldData = new DynamicRecordWrapper.FieldData();
                fieldData.label = apiNameWithDetailMap.get(field).labelName;
                fieldData.value = String.valueOf(sob.get(field));
                if(String.isNotBlank(lookupFieldWithName.get(field))){
                    List<String>  lookupFieldWithNameList = lookupFieldWithName.get(field).split('\\.');
                    if(sob.getSObject(lookupFieldWithNameList[0]) != NULL){
                        fieldData.label = lookupFieldWithNameList[0].endsWith('__r') ? apiNameWithDetailMap.get(field).labelName + ' Name': lookupFieldWithNameList[0];
                        fieldData.value = String.valueOf(sob.getSObject(lookupFieldWithNameList[0]).get(lookupFieldWithNameList[1]));
                    }
                }
                
                dynamicRecWrap.details.add(fieldData);
            }
        }
        else if(String.isNotBlank(isParent ? wrapperObj.selectedParentFieldset : wrapperObj.selectedChildFieldset) && String.isNotBlank(isParent ? wrapperObj.selectedParent : wrapperObj.selectedChild)){
            for (String field : DynamicSchemaService.getFieldSetFields(isParent ? wrapperObj.selectedParent : wrapperObj.selectedChild, isParent ? wrapperObj.selectedParentFieldset : wrapperObj.selectedChildFieldset)) {
                DynamicRecordWrapper.FieldData fieldData = new DynamicRecordWrapper.FieldData();
                fieldData.label = apiNameWithDetailMap.get(field).labelName;
                fieldData.value = String.valueOf(sob.get(field));
                if(String.isNotBlank(lookupFieldWithName.get(field))){
                    List<String>  lookupFieldWithNameList = lookupFieldWithName.get(field).split('\\.');
                    if(sob.getSObject(lookupFieldWithNameList[0]) != NULL){
                        fieldData.label = lookupFieldWithNameList[0].endsWith('__r') ? apiNameWithDetailMap.get(field).labelName + ' Name': lookupFieldWithNameList[0];
                        fieldData.value = String.valueOf(sob.getSObject(lookupFieldWithNameList[0]).get(lookupFieldWithNameList[1]));
                    }
                }
                
                dynamicRecWrap.details.add(fieldData);
            }
        }else{
            if((isParent ? wrapperObj.selectedParentFields : wrapperObj.selectedChildFields) != NULL){
                for (String field : isParent ? wrapperObj.selectedParentFields : wrapperObj.selectedChildFields) {
                    DynamicRecordWrapper.FieldData fieldData = new DynamicRecordWrapper.FieldData();
                    fieldData.label = apiNameWithDetailMap.get(field).labelName;
                    fieldData.value = String.valueOf(sob.get(field));
                    if(String.isNotBlank(lookupFieldWithName.get(field))){
                        List<String>  lookupFieldWithNameList = lookupFieldWithName.get(field).split('\\.');
                        if(sob.getSObject(lookupFieldWithNameList[0]) != NULL){
                            
                            fieldData.label = lookupFieldWithNameList[0].endsWith('__r') ? apiNameWithDetailMap.get(field).labelName + ' Name': lookupFieldWithNameList[0];
                            fieldData.value = String.valueOf(sob.getSObject(lookupFieldWithNameList[0]).get(lookupFieldWithNameList[1]));
                        }
                    }
                    
                    dynamicRecWrap.details.add(fieldData);
                }
            }
        }
        return dynamicRecWrap;
    }
}