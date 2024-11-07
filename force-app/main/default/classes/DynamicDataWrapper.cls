public inherited sharing class DynamicDataWrapper {
    public String selectedParent;
    public String selectedParentPicklist;
    public String selectedParentFieldset;
    public List<String> selectedParentFields;
    public String selectedChild;
    public String selectedChildPicklist;
    public String selectedChildFieldset;
    public List<String> selectedChildFields;
    public String selectedParentImageField;
    public String selectedChildImageField;
    public String parentId;
    public Boolean showAsRelatedList;
    public Boolean recordTabToggle;
    public Boolean parentBadgeFieldToggle;
    public Boolean parentImageFieldToggle;
    public Boolean childImageFieldToggle;
    public List<DynamicBadgeValues> parentPicklistValuesArr;
    public String selectedTitle;
    public String selectedTitleCaption;
    public String selectedTitleLogo;
    public String selectedParentFilterCondition;
    public String selectedParentOrderBy;
    public String selectedParentOrderByDir;
    public String selectedParentMaxRecordsCount;
    public String selectedParentCardTitleField;
    public String selectedParentCardTitleCaption;
    public String selectedChildFilterCondition;
    public String selectedChildOrderBy;
    public String selectedChildMaxRecordsCount;
    public String selectedChildCardTitleField;
    public String selectedChildCardTitleCaption;
    public String selectedParentBadgeField;
    public String selectedChildBadgeField;
    public String parentRelationshipName;
    public Boolean childBadgeFieldToggle;
    public Boolean picklistSelected;
    public Integer parentCurrentIndex;
    public List<DynamicBadgeValues> childPicklistValuesArr;
    public Integer childCurrentIndex;
    public Boolean parentImageBadgeFieldToggle;
    public String parentImageBadgeFieldIcon;
    public List<DynamicBadgeValues> parentImagePicklistValuesArr;
    public String selectedParentImagePicklist;
    public Boolean childImageBadgeFieldToggle;
    public String childImageBadgeFieldIcon;
    public List<DynamicBadgeValues> childImagePicklistValuesArr;
    public String selectedChildImagePicklist;
    public String customParentSOQL;
    public String customChildSOQL;
    public List<String> selectedParentCompactFields;
    public List<String> selectedChildCompactFields;
    public Boolean provideSOQLParentToggle;
    public Boolean provideSOQLChildToggle;
    
    public String getBadgeColor(Boolean isParent, String picklistValue){
        if(String.isNotBlank(picklistValue)){
            for(DynamicBadgeValues dynamincBdgeVal : (isParent ? parentPicklistValuesArr : childPicklistValuesArr)){
                if(dynamincBdgeVal.selectedValue == picklistValue){
                    return 'background:'+dynamincBdgeVal.selectedColor; 
                }
            } 
        }
        return 'background:#d3d3d3'; // By default light grey
    }
    
    public String getbadgeImageColor(Boolean isParent, String picklistValue){
        if(String.isNotBlank(picklistValue)){
            for(DynamicBadgeValues dynamincBdgeVal : (isParent ? parentImagePicklistValuesArr : childImagePicklistValuesArr)){
                if(dynamincBdgeVal.selectedValue == picklistValue){
                    return 'background:'+dynamincBdgeVal.selectedColor; 
                }
            } 
        }
        
        return 'background:#d3d3d3'; // Bydefault light grey
    }
    
    public class DynamicBadgeValues {
        public String selectedValue;
        public String selectedColor;
    }
}