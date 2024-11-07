public without sharing class DynamicDataVisualizerController {
    @AuraEnabled(cacheable=true)
    public static List<DynamicDataSchema> getAllObjects(){
        try {
            List<DynamicDataSchema> objects = new List<DynamicDataSchema>();
            
            for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
                if(objTyp.getDescribe().isAccessible() && objTyp.getDescribe().isUpdateable() && objTyp.getDescribe().isQueryable()){
                    objects.add(new DynamicDataSchema(objTyp.getDescribe().getLabel(),objTyp.getDescribe().getName()));
                }
            }
            objects.sort();
            
            return objects; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } //No Need
    @AuraEnabled(cacheable=true)
    public static DataWrapper getParentObjectSchema(String objectName){
        try {
            DataWrapper dWrap = new DataWrapper();
            List<DynamicDataSchema> childRelationships = new List<DynamicDataSchema>();
            
            Schema.DescribeSObjectResult objSchema = Schema.getGlobalDescribe().get(objectName).getDescribe();
            
            dWrap = getObjectsSchemaDetails(objSchema);
            
            List<Schema.ChildRelationship> childsSchema = objSchema.getChildRelationships();
            
            Set<String> childRefs = new Set<String>();
            
            for(Schema.ChildRelationship child : childsSchema){
                if(child.getField().getDescribe().isAccessible() && child.getField().getDescribe().isUpdateable() && !childRefs.contains(String.valueOf(child.getField().getDescribe().getSObjectType()))){
                    childRefs.add(String.valueOf(child.getField().getDescribe().getSObjectType()));
                    childRelationships.add(new DynamicDataSchema(String.valueOf(child.getField().getDescribe().getSObjectType()),String.valueOf(child.getField().getDescribe().getSObjectType()), 
                                                                 String.valueOf(child.getField().getDescribe().getSobjectField())));
                }
            }
            
            childRelationships.sort();
            dWrap.childRelationships = childRelationships;
            
            return dWrap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static DataWrapper getChildObjectSchema(String objName){
        try {
            Schema.DescribeSObjectResult objSchema = Schema.getGlobalDescribe().get(objName).getDescribe();
            
            return getObjectsSchemaDetails(objSchema);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static DataWrapper getPicklistValues(String objName, string fieldName){
        try {
            DataWrapper dWrap = new DataWrapper();
            List<DynamicDataSchema> fields = new List<DynamicDataSchema>();
            
            Schema.DescribeFieldResult field = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe();
            
            List<Schema.PicklistEntry> picklistEntries = field.getPicklistValues();
            
            for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                fields.add(new DynamicDataSchema(picklistEntry.getLabel(),picklistEntry.getLabel()));
            }
            fields.sort();
            
            dWrap.fields = fields;
            return dWrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static DataWrapper getObjectsSchemaDetails(Schema.DescribeSObjectResult objSchema){
       
        DataWrapper dWrap = new DataWrapper();
        List<DynamicDataSchema> fields = new List<DynamicDataSchema>();
        List<DynamicDataSchema> fieldSet = new List<DynamicDataSchema>();
        List<DynamicDataSchema> picklist = new List<DynamicDataSchema>();
        List<DynamicDataSchema> textArea = new List<DynamicDataSchema>();
        
        
        for(Schema.SObjectField field : objSchema.fields.getMap().Values()){
            fields.add(new DynamicDataSchema(field.getDescribe().getLabel(),field.getDescribe().getName()));
            
            if(String.valueOf(field.getDescribe().getType()) == 'picklist'){
                picklist.add(new DynamicDataSchema(field.getDescribe().getLabel(),field.getDescribe().getName()));
            }
            if(String.valueOf(field.getDescribe().getType()) == 'textarea'){
                textArea.add(new DynamicDataSchema(field.getDescribe().getLabel(),field.getDescribe().getName()));
            }
        }
        
        for(Schema.FieldSet fieldSetObj :  objSchema.fieldsets.getMap().Values()){
            fieldSet.add(new DynamicDataSchema(fieldSetObj.getLabel(),fieldSetObj.getName()));
        }
        
        fields.sort();
        fieldSet.sort();
        picklist.sort();
        textArea.sort();
        
        dWrap.fields = fields;
        dWrap.fieldSets = fieldSet;
        dWrap.picklistFields = picklist;
        dWrap.textAreaFields = textArea;
        
        return dWrap;
    }
    
    @AuraEnabled
    public static DynamicResponseWrapper getRecordDetails(String settings, String recordId) {
        DynamicResponseWrapper response = new DynamicResponseWrapper(); 
        String customQueryFilter = '';
        try {
            DynamicDataWrapper wrapperObj = (DynamicDataWrapper) JSON.deserialize(settings, DynamicDataWrapper.class);
            response.status = 'success';
            Set<String> setOfFields = new Set<String>{'Id'};
            Set<String> soqlfFields = new Set<String>();
            String objectName = '';
            Boolean isChild = wrapperObj.showAsRelatedList;
            Boolean soqlContainsLimit = false;
            
            // Add fields to setOfFields based on whether it's child or parent
            if(isChild) {
                if (wrapperObj.selectedChildCompactFields != null && !wrapperObj.selectedChildCompactFields.isEmpty()) {
                    setOfFields.addAll(wrapperObj.selectedChildCompactFields);
                }
                if(wrapperObj.provideSOQLChildToggle && String.isNotBlank(wrapperObj.customChildSOQL)){
                    soqlContainsLimit = wrapperObj.customChildSOQL.contains('LIMIT');
                    Integer startIdx = wrapperObj.customChildSOQL.indexOf( 'SELECT') + 6;
                    Integer endingIdx =  wrapperObj.customChildSOQL.indexOf('FROM');
                    // get custom filter
                    if(wrapperObj.customChildSOQL.contains('WHERE')) {
                        customQueryFilter = wrapperObj.customChildSOQL.substringAfter('WHERE');
                    } else if(wrapperObj.customChildSOQL.contains('where')) {
                        customQueryFilter = wrapperObj.customChildSOQL.substringAfter('where');
                    }
                    for (String field : wrapperObj.customChildSOQL.substring(startIdx, endingIdx).split(',')) {
                        setOfFields.add(field.trim());
                    }
                    soqlfFields.addAll(setOfFields);
                    objectName = wrapperObj.customChildSOQL.substring(endingIdx+4,wrapperObj.customChildSOQL.length()).trim();
                    objectName = objectName.indexOf(' ') != -1 ? objectName.substring(0 ,objectName.indexOf(' ')).trim() : objectName;
                }else{
                    if (wrapperObj.selectedChildFields != null && !wrapperObj.selectedChildFields.isEmpty()) {
                        setOfFields.addAll(wrapperObj.selectedChildFields);
                    }
                    if(String.isNotBlank(wrapperObj.selectedChildFieldset)) setOfFields.addAll(DynamicSchemaService.getFieldSetFields(wrapperObj.selectedChild, wrapperObj.selectedChildFieldset));
                    if(String.isNotBlank(wrapperObj.selectedChildBadgeField)) setOfFields.add(wrapperObj.selectedChildBadgeField);
                    if(String.isNotBlank(wrapperObj.selectedChildPicklist)) setOfFields.add(wrapperObj.selectedChildPicklist);
                    if(String.isNotBlank(wrapperObj.selectedChildImageField)) setOfFields.add(wrapperObj.selectedChildImageField);
                    if(String.isNotBlank(wrapperObj.selectedChildImagePicklist)) setOfFields.add(wrapperObj.selectedChildImagePicklist);
                    if(String.isNotBlank(wrapperObj.selectedChildCardTitleField)) setOfFields.add(wrapperObj.selectedChildCardTitleField);
                    if(String.isNotBlank(wrapperObj.selectedChildCardTitleCaption)) setOfFields.add(wrapperObj.selectedChildCardTitleCaption);
                    objectName = wrapperObj.selectedChild;
                }
                
            } else {
                if (wrapperObj.selectedParentCompactFields != null && !wrapperObj.selectedParentCompactFields.isEmpty()) {
                    setOfFields.addAll(wrapperObj.selectedParentCompactFields);
                }
                if(wrapperObj.provideSOQLParentToggle && String.isNotBlank(wrapperObj.customParentSOQL)){
                    soqlContainsLimit = wrapperObj.customParentSOQL.contains('LIMIT');
                    Integer startIdx = wrapperObj.customParentSOQL.indexOf( 'SELECT') + 6;
                    Integer endingIdx =  wrapperObj.customParentSOQL.indexOf('FROM');
                    
                    // get custom filter
                    if(wrapperObj.customParentSOQL.contains('WHERE')) {
                        customQueryFilter = wrapperObj.customParentSOQL.substringAfter('WHERE');
                    } else if(wrapperObj.customParentSOQL.contains('where')) {
                        customQueryFilter = wrapperObj.customParentSOQL.substringAfter('where');
                    }
                    
                    for (String field : wrapperObj.customParentSOQL.substring(startIdx, endingIdx).split(',')) {
                        setOfFields.add(field.trim());
                    }
                    soqlfFields.addAll(setOfFields);
                    objectName = wrapperObj.customParentSOQL.substring(endingIdx+4,wrapperObj.customParentSOQL.length()).trim();
                    objectName = objectName.indexOf(' ') != -1 ? objectName.substring(0 ,objectName.indexOf(' ')) : objectName;
                } else {
                    if (wrapperObj.selectedParentFields != null && !wrapperObj.selectedParentFields.isEmpty()) {
                        setOfFields.addAll(wrapperObj.selectedParentFields);
                    }
                    
                    if(String.isNotBlank(wrapperObj.selectedParentFieldset)) setOfFields.addAll(DynamicSchemaService.getFieldSetFields(wrapperObj.selectedParent, wrapperObj.selectedParentFieldset));
                    if(String.isNotBlank(wrapperObj.selectedParentBadgeField)) setOfFields.add(wrapperObj.selectedParentBadgeField);
                    if(String.isNotBlank(wrapperObj.selectedParentPicklist)) setOfFields.add(wrapperObj.selectedParentPicklist);
                    if(String.isNotBlank(wrapperObj.selectedParentImageField)) setOfFields.add(wrapperObj.selectedParentImageField);
                    if(String.isNotBlank(wrapperObj.selectedParentImagePicklist)) setOfFields.add(wrapperObj.selectedParentImagePicklist);
                    if(String.isNotBlank(wrapperObj.selectedParentCardTitleField)) setOfFields.add(wrapperObj.selectedParentCardTitleField);
                    if(String.isNotBlank(wrapperObj.selectedParentCardTitleCaption)) setOfFields.add(wrapperObj.selectedParentCardTitleCaption);
                    objectName = wrapperObj.selectedParent;  
                }
            }
            Map<String, DynamicSchemaService.FieldsDataWrapper> apiNameWithDetailMap;
            Map<String, String> lookupFieldWithName;
            try{
                apiNameWithDetailMap = DynamicSchemaService.getFieldLabelApiNameMap(objectName);
                lookupFieldWithName =  DynamicSchemaService.getLookupNames(apiNameWithDetailMap,setOfFields);
                setOfFields.addAll(lookupFieldWithName.values());
            }
            catch(Exception e){
                System.debug('Error processing record: '  + e.getMessage() + e.getStackTraceString());
            }
            // Build the query string
            String queryString = 'SELECT ' + String.join(setOfFields,',') + ' FROM ' + objectName;
            
            if((wrapperObj.provideSOQLParentToggle || wrapperObj.provideSOQLParentToggle) && String.isNotBlank(customQueryFilter)) {
                queryString += ' WHERE ' + customQueryFilter;
            } else {
                if(isChild) {
                    if (String.isNotBlank(wrapperObj.parentId)) {
                        recordId = wrapperObj.parentId;
                    }
                    if(String.isNotBlank(recordId)){
                        queryString += ' WHERE ' + wrapperObj.parentRelationshipName + ' = :recordId';
                    }
                }  
                // Add ORDER BY and LIMIT clauses
                if(String.isNotBlank(wrapperObj.selectedParentOrderBy)) {
                    queryString += ' ORDER BY ' + wrapperObj.selectedParentOrderBy + ' ' + wrapperObj.selectedParentOrderByDir;   
                }
                if(!soqlContainsLimit) {
                    queryString += ' LIMIT ' + (String.isNotBlank(wrapperObj.selectedParentMaxRecordsCount) ? wrapperObj.selectedParentMaxRecordsCount : '10');
                }
            }
            System.debug(' ## String Query ## ' + queryString);
         
            
            //FLS CHECK BEFORE QUERY
            
            List<String> lstOfFieldsForCheck = new List<String>(setOfFields);
            SObjectType sObjTypeForCheck = ((SObject) Type.forName(objectName).newInstance())
                                  .getSObjectType();
            FLS_SecurityUtils.checkRead(sObjTypeForCheck, lstOfFieldsForCheck);
            

            // Execute the query and prepare the data
            List<sObject> records = Database.query(queryString);
            System.debug(' ## records ## ' + records);
            DynamicDataVisualizerService visualizerService = new DynamicDataVisualizerService(records, wrapperObj, apiNameWithDetailMap, soqlfFields , lookupFieldWithName);
            response.recordDataList = isChild ? visualizerService.prepareChildData() : visualizerService.prepareParentData();
        }
        catch(Exception e) {
            response.status = 'error';
            response.errorMsg = e.getMessage() + e.getStackTraceString();
        }
        return response;
    }
    
    public class DynamicResponseWrapper {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public List<DynamicRecordWrapper> recordDataList;
    }
    
    public class DataWrapper{
        @AuraEnabled
        public List<DynamicDataSchema> fields{get;set;}
        @AuraEnabled
        public List<DynamicDataSchema> fieldSets{get;set;}
        @AuraEnabled
        public List<DynamicDataSchema> picklistFields{get;set;}
        @AuraEnabled
        public List<DynamicDataSchema> textAreaFields{get;set;}
        @AuraEnabled
        public List<DynamicDataSchema> childRelationships{get;set;}
        public DataWrapper(){}
    }
    public class DynamicDataSchema implements Comparable{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String parentRelationshipName{get;set;}
        
        public DynamicDataSchema(String label, String name) {
            this.label = label;
            this.name = name;
        }
        public DynamicDataSchema(String label, String name, String parentRelationshipName) {
            this.label = label;
            this.name = name;
            this.parentRelationshipName = parentRelationshipName;
        }
        
        public Integer compareTo(Object selectOption) {
            DynamicDataSchema obj = (DynamicDataSchema) selectOption;
            if (label == obj.label) { return 0; } 
            if (label > obj.label) { return 1; }
            return -1;        
        }
    }
}