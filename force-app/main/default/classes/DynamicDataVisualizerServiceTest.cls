@isTest
public class DynamicDataVisualizerServiceTest {
    
    @testSetup
    static void setup() {
        // Create test data
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;
        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;
        
    }
    
    @isTest
    static void testPrepareParentData() {
        // Retrieve test data
        List<Account> accounts = [SELECT Id, Name FROM Account];
        
        DynamicDataWrapper wrapperObj = new DynamicDataWrapper();
        // wrapperObj.selectedParentPicklist = 'Name';
        wrapperObj.parentBadgeFieldToggle = true;
        wrapperObj.parentImageFieldToggle = true;
        wrapperObj.selectedParentImageField = 'Name';
        wrapperObj.selectedParentCardTitleField = 'Name';
        wrapperObj.selectedParentCardTitleCaption = 'Name';
        wrapperObj.parentImageBadgeFieldToggle = true;
        // wrapperObj.parentImageBadgeFieldIcon = 'icon';
        wrapperObj.selectedParentCompactFields = new List<String>{'Name'};
        wrapperObj.selectedParentFields = new List<String>{'Name'};
                
        Map<String, DynamicSchemaService.FieldsDataWrapper> apiNameWithDetailMap = DynamicSchemaService.getFieldLabelApiNameMap('Contact');
        Set<String> soqlFields = new Set<String>{};
        Map<String, String> lookupFieldWithName = new Map<String, String>();
        
        DynamicDataVisualizerService service = new DynamicDataVisualizerService(
            new List<Account>(accounts), 
            wrapperObj, 
            apiNameWithDetailMap, 
            soqlFields, 
            lookupFieldWithName
        );
        
        List<DynamicRecordWrapper> parentData = service.prepareParentData();
    }
    
    @isTest
    static void testPrepareChildData() {
        List<Account> accounts = [SELECT Id, Name ,CreatedById FROM Account];
        
        DynamicDataWrapper wrapperObj = new DynamicDataWrapper();
        //wrapperObj.selectedChildPicklist = 'Name';
        //wrapperObj.selectedParentPicklist = 'Name';
        wrapperObj.childBadgeFieldToggle = true;
        wrapperObj.childImageFieldToggle = true;
        wrapperObj.selectedChildImageField = 'Name';
        wrapperObj.selectedChildCardTitleField = 'Name';
        wrapperObj.selectedChildCardTitleCaption = 'Name';
        wrapperObj.childImageBadgeFieldToggle = true;
       //wrapperObj.childImageBadgeFieldIcon = 'icon';
        wrapperObj.selectedChildCompactFields = new List<String>{'Name'};
        wrapperObj.selectedChildFields = new List<String>{'Name'};
                
         Map<String, DynamicSchemaService.FieldsDataWrapper> apiNameWithDetailMap = DynamicSchemaService.getFieldLabelApiNameMap('Contact');
        Set<String> soqlFields = new Set<String>{'Name','CreatedById'};
        Set<String> lookupFields = new Set<String>{'CreatedById'};
        Map<String, String> lookupFieldWithName = DynamicSchemaService.getLookupNames(apiNameWithDetailMap, lookupFields);
        
        DynamicDataVisualizerService service = new DynamicDataVisualizerService(
            new List<Account>(accounts), 
            wrapperObj, 
            apiNameWithDetailMap, 
            soqlFields, 
            lookupFieldWithName
        );
        
        List<DynamicRecordWrapper> childData = service.prepareChildData();
    }
    
    @isTest
    static void testPrepareChildDataFieldSet() {
        List<Account> accounts = [SELECT Id, Name ,CreatedById FROM Account];
        
        DynamicDataWrapper wrapperObj = new DynamicDataWrapper();
        // wrapperObj.selectedChildPicklist = 'Rating';
        wrapperObj.childBadgeFieldToggle = true;
        wrapperObj.selectedChild = 'Account';
        wrapperObj.selectedChildFieldset = 'test';
        wrapperObj.childImageFieldToggle = true;
        wrapperObj.selectedChildImageField = 'Name';
        wrapperObj.selectedChildCardTitleField = 'Name';
        wrapperObj.selectedChildCardTitleCaption = 'Name';
        wrapperObj.childImageBadgeFieldToggle = true;
        //wrapperObj.childImageBadgeFieldIcon = 'icon';
        wrapperObj.selectedChildCompactFields = new List<String>{'Name'};
        wrapperObj.selectedChildFields = new List<String>{'Name'};

        DynamicDataWrapper.DynamicBadgeValues wapper = new DynamicDataWrapper.DynamicBadgeValues();
        List<DynamicDataWrapper.DynamicBadgeValues> wapperList = new List<DynamicDataWrapper.DynamicBadgeValues>();
        wapper.selectedValue = 'Test';
        wapperList.add(wapper);
        wapper.selectedColor = 'Test';
        wapperList.add(wapper);
        wrapperObj.childPicklistValuesArr = wapperList;
        wrapperObj.childImagePicklistValuesArr = wapperList;
        
        Map<String, DynamicSchemaService.FieldsDataWrapper> apiNameWithDetailMap = DynamicSchemaService.getFieldLabelApiNameMap('Contact');
        Set<String> soqlFields = new Set<String>{};
        Set<String> lookupFields = new Set<String>{'CreatedById'};
        Map<String, String> lookupFieldWithName = DynamicSchemaService.getLookupNames(apiNameWithDetailMap, lookupFields);
        
        DynamicDataVisualizerService service = new DynamicDataVisualizerService(
            new List<Account>(accounts), 
            wrapperObj, 
            apiNameWithDetailMap, 
            soqlFields, 
            lookupFieldWithName
        );
        
        List<DynamicRecordWrapper> childData = service.prepareChildData();
        wrapperObj.getBadgeColor(false, 'Test');
		wrapperObj.getbadgeImageColor(false, 'Test');
    }
}