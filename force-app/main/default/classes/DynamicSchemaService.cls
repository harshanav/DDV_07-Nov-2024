public inherited sharing class DynamicSchemaService {
    
    public static Map<String,FieldsDataWrapper> getFieldLabelApiNameMap(String objectName) {
        Map<String,FieldsDataWrapper> apiNameWithDetailMap = new Map<String,FieldsDataWrapper>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        List<fieldsDataWrapper> fieldsDataWrapList = new List<fieldsDataWrapper>();
        for (String fieldName : fieldMap.keySet()) {
            fieldsDataWrapper fieldsDataWrpr = new fieldsDataWrapper();
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            fieldsDataWrpr.labelName = fieldDescribe.getLabel();
            fieldsDataWrpr.apiName = fieldDescribe.getName();
            fieldsDataWrpr.dataType = fieldDescribe.getType();
            if (fieldDescribe.getType() == Schema.DisplayType.Reference) {
               fieldsDataWrpr.relationshipName = fieldDescribe.getRelationshipName();
            }
            apiNameWithDetailMap.put(fieldDescribe.getName() ,fieldsDataWrpr);
        }
        
        return apiNameWithDetailMap;
    }
    
    public static Map<String,String> getLookupNames( Map<String,FieldsDataWrapper> apiNameWithDetailMap , Set<String> setOfFields ){
        Map<String, String> lookupFieldWithName = new Map<String, String>();
        for(String field:setOfFields){
            if(apiNameWithDetailMap.containsKey(field) && apiNameWithDetailMap.get(field).dataType == Schema.DisplayType.Reference){
                if(String.isNotBlank(apiNameWithDetailMap.get(field).relationshipName)){
                    lookupFieldWithName.put(field, apiNameWithDetailMap.get(field).relationshipName +'.Name');                    
                }  
            }
        }
        
        return lookupFieldWithName;
    }
    
    public static List<String> getFieldSetFields(String objectName, String fieldSetName) {
        List<String> fieldSetFields = new List<String>();
        
        try {
            Schema.FieldSet fieldSet = Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap().get(fieldSetName);
            if (fieldSet != null) {
                for (Schema.FieldSetMember field : fieldSet.getFields()) {
                    fieldSetFields.add(field.getFieldPath());
                }
            } else {
                System.debug('Field set ' + fieldSetName + ' not found on object ' + objectName);
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        
        return fieldSetFields;
    }
    
    public class FieldsDataWrapper {
        public String labelName;
        public String apiName;
        public Object dataType;
        public String relationshipName;
    }
    
}