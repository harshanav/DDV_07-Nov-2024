public class DynamicRecordWrapper {
    @AuraEnabled
    public Integer index;
    @AuraEnabled
    public String recordurl;
    @AuraEnabled
    public Boolean showBadge;
    @AuraEnabled
    public String badgeTitle;
    @AuraEnabled
    public String badgeColor;
    @AuraEnabled
    public Boolean showImage;
    @AuraEnabled
    public String imageUrl;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String titleCaption;
    @AuraEnabled
    public Boolean showBadgeImage;
    @AuraEnabled
    public String badgeImageTitle;
    @AuraEnabled
    public String badgeImageIcon;
    @AuraEnabled
    public String badgeImageColor;
    @AuraEnabled
    public Boolean showDetails;
    @AuraEnabled
    public List<FieldData> details;
    @AuraEnabled
    public List<FieldData> compactDetails;

    public DynamicRecordWrapper() {
        this.showDetails = false;
        this.details = new List<FieldData>();
        this.compactDetails = new List<FieldData>();
    }
    
    public class FieldData {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    
}