@isTest
public class DynamicDataVisualizerControllerTest {
    @isTest
    static void testGetAllObjects(){
        
        Test.startTest();
        List<DynamicDataVisualizerController.DynamicDataSchema> result = DynamicDataVisualizerController.getAllObjects();
        Test.stopTest();
        
        Assert.areNotEqual(result, null, 'Result should not be null');
        Assert.isTrue(result.size() > 0, 'Result should contain some objects');
    }
    
    @isTest
    static void testGetParentObjectSchema(){
        
        Test.startTest();
        DynamicDataVisualizerController.DataWrapper result = DynamicDataVisualizerController.getParentObjectSchema('Account');
        Test.stopTest();
        
        Assert.areNotEqual(result, null, 'Result should not be null');
        Assert.isTrue(result.fields.size() > 0, 'Result should contain some Fields');
    }
    
    @isTest
    static void testGetChildObjectSchema(){
        
        Test.startTest();
        DynamicDataVisualizerController.DataWrapper result = DynamicDataVisualizerController.getChildObjectSchema('Account');
        Test.stopTest();
        
        Assert.areNotEqual(result, null, 'Result should not be null');
        Assert.isTrue(result.fields.size() > 0, 'Result should contain some objects');
    }
    
    @isTest
    static void testGetPicklistValues(){
        
        Test.startTest();
        DynamicDataVisualizerController.DataWrapper result = DynamicDataVisualizerController.getPicklistValues('Account','AccountSource');
        Test.stopTest();
        
        Assert.areNotEqual(result, null, 'Result should not be null');
        Assert.isTrue(result.fields.size() > 0, 'Result should contain some picklist values');
    }
    
    @isTest
    static void testGetRecordDetailsParent() {
        
        Account parent1 = new Account(Name = 'Parent 1', Industry = 'Technology', Website = 'www.parent1.com', Type = 'Customer');
        insert parent1;
        String settings = '{"selectedParent": "Account", "selectedParentPicklist": "Rating", "selectedParentFieldset": "Example", "selectedParentFields": ["Description", "Name"], "selectedChild": "", "selectedChildPicklist": "", "selectedChildFieldset": "", "selectedChildFields": [], "selectedParentImageField": "Image__c", "selectedChildImageField": "", "parentId": "", "showAsRelatedList": false, "recordTabToggle": false, "parentBadgeFieldToggle": true, "parentImageFieldToggle": true, "childImageFieldToggle": false, "parentPicklistValuesArr": [ { "_id": 0, "selectedValue": "Cold", "selectedColor": "#DA7F7F" }, { "_id": 1, "selectedValue": "Hot", "selectedColor": "#70E49A" }, { "_id": 2, "selectedValue": "Warm", "selectedColor": "#D9E472" } ], "selectedTitle": "Quick Fiber", "selectedTitleCaption": "", "selectedTitleLogo": "", "selectedParentOrderBy": "LastModifiedDate", "selectedParentMaxRecordsCount": "10", "selectedParentCardTitleField": "Name", "selectedParentCardTitleCaption": "Description", "selectedChildOrderBy": "", "selectedChildMaxRecordsCount": "", "selectedChildCardTitleField": "", "selectedChildCardTitleCaption": "", "selectedParentBadgeField": "", "selectedChildBadgeField": "", "childBadgeFieldToggle": false, "parentFields": [ { "label": "Account Description", "value": "Description" }, { "label": "Account Fax", "value": "Fax" }, { "label": "Account ID", "value": "Id" }, { "label": "Account Name", "value": "Name" } ], "childFields": [], "childFieldsets": [], "childPicklists": [], "parentPiclistValues": [ { "label": "Cold", "value": "Cold" }, { "label": "Hot", "value": "Hot" }, { "label": "Warm", "value": "Warm" } ], "picklistSelected": false, "parentCurrentIndex": 3, "parentTextAreaFields": [ { "label": "Account Description", "value": "Description" }, { "label": "Billing Street", "value": "BillingStreet" }, { "label": "Image", "value": "Image__c" }, { "label": "Shipping Street", "value": "ShippingStreet" } ], "childTextAreaFields": [], "childPicklistValuesArr": [], "childCurrentIndex": 0, "childPiclistValues": [], "selectedParentOrderByDir": "DESC", "childParentOrderByDir": "ASC", "titleToggle": true, "provideSOQLParentToggle": false, "customParentSOQL": "", "provideSOQLChildToggle": false, "customChildSOQL": "", "parentImageBadgeFieldToggle": true, "parentImageBadgeFieldIcon": "utility:activity", "selectedParentImagePicklist": "Type", "childImageBadgeFieldToggle": false, "childImageBadgeFieldIcon": "", "selectedChildImagePicklist": "", "parentImagePicklistValuesArr": [ { "_id": 0, "selectedValue": "Installation Partner", "selectedColor": "#EDB7B7" }, { "_id": 1, "selectedValue": "Customer - Channel", "selectedColor": "#CFEDB5" } ], "childImagePicklistValuesArr": [], "parentImagePiclistValues": [ { "label": "Channel Partner / Reseller", "value": "Channel Partner / Reseller" }, { "label": "Customer - Channel", "value": "Customer - Channel" }, { "label": "Customer - Direct", "value": "Customer - Direct" }, { "label": "Installation Partner", "value": "Installation Partner" }, { "label": "Other", "value": "Other" }, { "label": "Prospect", "value": "Prospect" }, { "label": "Technology Partner", "value": "Technology Partner" } ], "childImagePicklistValues": [], "parentImageCurrentIndex": 2, "childImageCurrentIndex": 0, "parentRelationshipName": "", "selectedChildCompactFields": [], "selectedParentCompactFields": [ "Name", "AccountNumber" ], "childImagePiclistValues": [] }';
        String recordId = parent1.id;
        
        Test.startTest();
        DynamicDataVisualizerController.DynamicResponseWrapper result = DynamicDataVisualizerController.getRecordDetails(settings, recordId);
        Test.stopTest();
        
        System.assert(result != null, 'Result should not be null');
    }
    
    @isTest
    static void testGetRecordDetailsChild() {
        
        Account parent1 = new Account(Name = 'Parent 1', Industry = 'Technology', Website = 'www.parent1.com', Type = 'Customer');
        insert parent1;
        String recordId = parent1.id;
        String settings= '{"selectedParent":"Account","selectedParentPicklist":"Rating","selectedParentFieldset":"Example","selectedParentFields":["Description","Name"],"selectedChild":"","selectedChildPicklist":"Rating","selectedChildFieldset":"","selectedChildFields":["Description","Name"],"selectedParentImageField":"","selectedChildImageField":"","parentId":"","showAsRelatedList":true,"recordTabToggle":false,"parentBadgeFieldToggle":true,"parentImageFieldToggle":true,"childImageFieldToggle":false,"parentPicklistValuesArr":[{"_id":0,"selectedValue":"Cold","selectedColor":"#DA7F7F"},{"_id":1,"selectedValue":"Hot","selectedColor":"#70E49A"},{"_id":2,"selectedValue":"Warm","selectedColor":"#D9E472"}],"selectedTitle":"Quick Fiber","selectedTitleCaption":"","selectedTitleLogo":"","selectedParentOrderBy":"LastModifiedDate","selectedParentMaxRecordsCount":"10","selectedParentCardTitleField":"Name","selectedParentCardTitleCaption":"Description","selectedChildOrderBy":"","selectedChildMaxRecordsCount":"","selectedChildCardTitleField":"","selectedChildCardTitleCaption":"","selectedParentBadgeField":"","selectedChildBadgeField":"","childBadgeFieldToggle":false,"parentFields":[],"childFields":[],"childFieldsets":[],"childPicklists":[],"parentPiclistValues":[{"label":"Cold","value":"Cold"},{"label":"Hot","value":"Hot"},{"label":"Warm","value":"Warm"}],"picklistSelected":false,"parentCurrentIndex":3,"parentTextAreaFields":[{"label":"Account Description","value":"Description"},{"label":"Billing Street","value":"BillingStreet"},{"label":"Image","value":"Image__c"},{"label":"Shipping Street","value":"ShippingStreet"}],"childTextAreaFields":[],"childPicklistValuesArr":[],"childCurrentIndex":0,"childPiclistValues":[],"selectedParentOrderByDir":"DESC","childParentOrderByDir":"ASC","titleToggle":true,"provideSOQLParentToggle":false,"customParentSOQL":"","provideSOQLChildToggle":false,"customChildSOQL":"","parentImageBadgeFieldToggle":true,"parentImageBadgeFieldIcon":"utility:activity","selectedParentImagePicklist":"Type","childImageBadgeFieldToggle":false,"childImageBadgeFieldIcon":"","selectedChildImagePicklist":"","parentImagePicklistValuesArr":[{"_id":0,"selectedValue":"Installation Partner","selectedColor":"#EDB7B7"},{"_id":1,"selectedValue":"Customer - Channel","selectedColor":"#CFEDB5"}],"childImagePicklistValuesArr":[],"parentImagePiclistValues":[{"label":"Channel Partneler"},{"label":"Customer - Channel","value":"Customer - Channel"},{"label":"Customer - Direct","value":"Customer - Direct"},{"label":"Installation Partner","value":"Installation Partner"},{"label":"Other","value":"Other"},{"label":"Prospect","value":"Prospect"},{"label":"Technology Partner","value":"Technology Partner"}],"childImagePicklistValues":[],"parentImageCurrentIndex":2,"childImageCurrentIndex":0,"parentRelationshipName":"","selectedChildCompactFields":[],"selectedParentCompactFields":["Name","AccountNumber"],"childImagePiclistValues":[]}';        
        Test.startTest();
        DynamicDataVisualizerController.DynamicResponseWrapper result = DynamicDataVisualizerController.getRecordDetails(settings, recordId);
        Test.stopTest();
        
        System.assert(result != null, 'Result should not be null');
    }
    
}