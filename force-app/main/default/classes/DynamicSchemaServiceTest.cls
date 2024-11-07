@isTest
public class DynamicSchemaServiceTest {
    @isTest
    static void testGetFieldLabelApiNameMap() {
        Test.startTest();
        Map<String, DynamicSchemaService.FieldsDataWrapper> result = DynamicSchemaService.getFieldLabelApiNameMap('Account');
        Test.stopTest();
        Assert.areNotEqual(null, result, 'Label-API name map should not be null');
        Assert.isTrue(result.size() > 0, 'Label-API name map should not be empty');
        
    }
    
    @isTest
    static void testGetFieldSetFields() {
        Test.startTest();
        List<String> result = DynamicSchemaService.getFieldSetFields('Account','AccountSource');
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Field set fields should not be null');
        
    }
    
    @isTest
    static void testGetLookupNames() {
        
        Map<String, DynamicSchemaService.FieldsDataWrapper> fieldMap = DynamicSchemaService.getFieldLabelApiNameMap('Contact');
        Set<String> lookupFields = new Set<String>{'AccountId'};
            
        Test.startTest();
        Map<String, String> lookupNames = DynamicSchemaService.getLookupNames(fieldMap, lookupFields);
        Test.stopTest();
        
        System.assertEquals('Account.Name', lookupNames.get('AccountId'), 'Lookup field should be "Account.Name"');
    }
    
}