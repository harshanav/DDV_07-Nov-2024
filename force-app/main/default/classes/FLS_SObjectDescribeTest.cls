@isTest
public class FLS_SObjectDescribeTest {
    
    static User setupTestUser(String profileName) {
        String uniqueness = DateTime.now()+':'+Math.random();
        try{
            throw new NullPointerException();
        }catch(Exception e){
            uniqueness += e.getStackTraceString(); //includes the top level test method name without having to pass it
        }
        Profile p = [SELECT id, Name FROM Profile WHERE Name = :profileName];
        User result = new User(
            username=UserInfo.getUserId()+'.'+uniqueness.HashCode()+'@'+UserInfo.getOrganizationId()+'.sfdcOrg',
            alias = 'testExec',
            email='apextests@example.com',
            emailencodingkey='UTF-8',
            lastname='Testing',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.Id,
            timezonesidkey='America/Los_Angeles'
        );
        INSERT result;
        return result;
    }
    
    @isTest
    static void getDescribeBadInput(){
        String nullStr = null; //having it as a string var makes for unambiguous selection of overloads
        Schema.SObjectType nullType = null;
        Schema.DescribeSObjectResult nullDescribe = null;
        SObject nullSObject = null;
        System.assertEquals(null, FLS_SObjectDescribe.getDescribe(nullStr),'Assert failed');
        System.assertEquals(null, FLS_SObjectDescribe.getDescribe(''),'Assert failed');
        System.assertEquals(null, FLS_SObjectDescribe.getDescribe(' '),'Assert failed');
        System.assertEquals(null, FLS_SObjectDescribe.getDescribe(nullType),'Assert failed');
        System.assertEquals(null, FLS_SObjectDescribe.getDescribe(nullDescribe),'Assert failed');
        System.assertEquals(null, FLS_SObjectDescribe.getDescribe(nullSObject),'Assert failed');
    }
   
    @isTest
    static void namespacedAttributeMapImplementations(){
        FLS_SObjectDescribe.GlobalDescribeMap gdm = FLS_SObjectDescribe.getGlobalDescribe();
        Schema.SObjectType accountObjType = gdm.get('AccOunT');
        System.assertEquals(accountObjType, Account.SobjectType,'Assert failed');
       
        FLS_SObjectDescribe acccountDescribe = FLS_SObjectDescribe.getDescribe(accountObjType);
        FLS_SObjectDescribe.FieldsMap fields = acccountDescribe.getFields();
        System.assert( fields.keySet().containsAll(acccountDescribe.getFieldsMap().keySet()) ,'Assert failed');
       
        System.assertEquals(fields.get('name'), Account.SObjectType.fields.name,'Assert failed'); //behavior of FieldsMap is tested in another method
        System.assertEquals(Schema.SObjectType.Account.fields.getMap().size(), fields.size(),'Assert failed');
       
        System.assertEquals(null, fields.get(null), 'Null input should result in null ouput.');
        System.assertEquals(null, fields.get(''), 'Invalid fieldname input should result in null ouput.');
    }
   
    @isTest
    static void fieldsMap(){
        String fakeNamespace = 'fflib_test';
        Map<String,Schema.SObjectField> fakeFieldData = new Map<String,Schema.SObjectField>{
            'name__c' => Contact.SObjectType.fields.name, //re-use standard field types since we can't mock them
                fakeNamespace+'__name__c' => Account.SObjectType.fields.name,
                fakeNamespace+'__otherField__c' => Account.SObjectType.fields.name,
                'createddate' => Contact.SObjectType.fields.CreatedDate
                };
        FLS_SObjectDescribe.FieldsMap fields = new FLS_SObjectDescribe.FieldsMap(fakeFieldData);
        fields.currentNamespace = fakeNamespace;
        System.assertEquals(true, fields.containsKey('name__c') ,'Assert failed');
        System.assertEquals(true, fields.containsKey(fakeNamespace.toUpperCase()+'__nAMe__c') ,'Assert failed');
        System.assert(fields.get('NAme__c') === fields.get(fakeNamespace+'__namE__c'),'Assert failed');
       
        System.assert(!fields.keySet(false).contains('otherField__c'),'Assert failed');
        System.assert(fields.keySet(false).contains(fakeNamespace+'__otherField__c'),'Assert failed');
       
        System.assert(fields.keySet(true).contains('otherField__c'),'Assert failed');
        System.assert(!fields.keySet(true).contains(fakeNamespace+'__otherField__c'),'Assert failed');
       
        fields.currentNamespace = 'someOtherNamespace';
        System.assertNotEquals(fields.get('name__C'), fields.get(fakeNamespace.capitalize()+'__nAme__c'),'Assert failed');
    }
   
    @isTest
    static void globalDescribeMap(){
        String fakeNamespace = 'fflib_test';
        Map<String,Schema.SObjectType> fakeFieldData = new Map<String,Schema.SObjectType>{
            'name__c' => Contact.SObjectType, //re-use stndard object types since we can't mock them
                fakeNamespace+'__name__c' => Account.SObjectType,
                'createddate' => Lead.SObjectType
                };
                    FLS_SObjectDescribe.GlobalDescribeMap gdm = new FLS_SObjectDescribe.GlobalDescribeMap(fakeFieldData);
        gdm.currentNamespace = fakeNamespace;
        System.assertEquals(true, gdm.containsKey('name__c') ,'Assert failed');
        System.assertEquals(true, gdm.containsKey(fakeNamespace+'__name__c') ,'Assert failed');
        System.assert(gdm.get('name__c') === gdm.get(fakeNamespace+'__name__c'),'Assert failed');
       
        gdm.currentNamespace = 'someOtherNamespace';
        System.assertNotEquals(gdm.get('name__c'), gdm.get(fakeNamespace+'__name__c'),'Assert failed');
    }
   
    @isTest //Tests all forms of the getDescribe static
    static void getAccountDescribes(){
        FLS_SObjectDescribe d = FLS_SObjectDescribe.getDescribe('Account');
        FLS_SObjectDescribe d2 = FLS_SObjectDescribe.getDescribe(Account.SObjectType);
        FLS_SObjectDescribe d3 = FLS_SObjectDescribe.getDescribe(Schema.SObjectType.Account);
        System.assertEquals('Account', d.getDescribe().getName(),'Assert failed');
        System.assert( (d === d2 && d2 === d3) ,'All three getDescribe calls should return the same cached instance.');
    }
   
    @isTest
    static void simpleAccountFieldDescribe(){
        FLS_SObjectDescribe d = FLS_SObjectDescribe.getDescribe(Account.SObjectType);
        Map<String,Schema.SObjectField> fields;
        for(integer i = 0; i < 10; i++){
            fields = d.getFieldsMap();
        }
        System.assertEquals(false,fields.isEmpty(),'Assert failed');
        System.assertEquals(Account.SObjectType, d.getSObjectType(),'Assert failed');
    }
   
   
    @isTest
    static void simpleAccountGetNameField(){
        FLS_SObjectDescribe d = FLS_SObjectDescribe.getDescribe(Account.SObjectType);
        Schema.SObjectField nameField = d.getNameField();
        System.assertEquals('Name', nameField.getDescribe().getName(),'Assert failed');
    }
   
    @isTest
    static void flushCache(){
        FLS_SObjectDescribe d = FLS_SObjectDescribe.getDescribe('Account');
        FLS_SObjectDescribe.flushCache();
        FLS_SObjectDescribe d2 = FLS_SObjectDescribe.getDescribe('Account');
        System.assert(d !== d2, 'Second object should be a fresh instance after a cache flush.');
    }
}