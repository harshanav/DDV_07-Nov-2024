@isTest
public class FLS_SecurityUtilsTest {
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
        Insert result;
        
        return result;
    }
    @isTest
    static void readonlyFieldAccess() {
        
        
        User testUser = setupTestUser('Read Only');
        System.runAs(testUser){
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkFieldIsInsertable(Account.SObjectType, 'naMe');
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assert(ex instanceof FLS_SecurityUtils.FlsException, 'Expected an FlsException, got '+ex.getTypeName());
                }
                
                
            }
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assertEquals(null, ex, 'Read only profile should be able to read Contact.LastName');
                    
                }
            }
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkFieldIsUpdateable(Lead.SObjectType, 'cOMPANY');
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assert(ex instanceof FLS_SecurityUtils.FlsException, 'Expected an FlsException, got '+ex.getTypeName());
                }
                
            }
            
            FLS_SecurityUtils.bYPASSINTERNALFLSANDCRUD = true;
            { //no exceptions, despite no rights
                FLS_SecurityUtils.checkFieldIsInsertable(Account.SObjectType, 'naMe');
                FLS_SecurityUtils.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
                FLS_SecurityUtils.checkFieldIsUpdateable(Lead.SObjectType, 'cOMPANY');
            }
        }
        
        
        
    }
    
    @isTest
    static void readonlyObjectAccess() {
        
        User testUser = setupTestUser('Read Only');
        System.runAs(testUser){
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkObjectIsInsertable(Account.SObjectType);
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assert(ex instanceof FLS_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
                }
                
            }
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkObjectIsReadable(Contact.SObjectType);
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assertEquals(null, ex, 'Read only profile should be able to read Contact');
                }
                
            }
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkObjectIsUpdateable(Lead.SObjectType);
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead');
                    System.assert(ex instanceof FLS_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
                }
                
            }
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkObjectIsDeletable(Opportunity.SObjectType);
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assert(ex instanceof FLS_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
                }
                
            }
            
            FLS_SecurityUtils.bYPASSINTERNALFLSANDCRUD = true;
            { //no exceptions, despite no rights
                FLS_SecurityUtils.checkObjectIsInsertable(Account.SObjectType);
                FLS_SecurityUtils.checkObjectIsReadable(Contact.SObjectType);
                FLS_SecurityUtils.checkObjectIsUpdateable(Lead.SObjectType);
                FLS_SecurityUtils.checkObjectIsDeletable(Opportunity.SObjectType);
            }
        }
        
    }
    
    @isTest
    static void readonlyObjectAndFieldAccess() {
        
        User testUser = setupTestUser('Read Only');
        System.runAs(testUser){
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkInsert(
                        Account.SObjectType,
                        new List<String>{
                            'Name',
                                'ParentId',
                                'ownerId'
                                }
                    );
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assert(ex instanceof FLS_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
                }
                
            }
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkRead(
                        Contact.SObjectType,
                        new List<String>{
                            'LastName',
                                'accountId',
                                'ownerId'
                                }
                    );
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assertEquals(null, ex, 'Read only profile should be able to read Contact');
                }
                
            }
            {
                FLS_SecurityUtils.SecurityException ex;
                try{
                    FLS_SecurityUtils.checkUpdate(
                        Lead.SObjectType,
                        new List<String>{
                            'LastName',
                                'FirstNAMe',
                                'cOMPANY'
                                }
                    );
                }catch(FLS_SecurityUtils.SecurityException e){
                    ex = e;
                    System.assert(ex instanceof FLS_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
                }
                
            }
            
            FLS_SecurityUtils.bYPASSINTERNALFLSANDCRUD = true;
            { //no exceptions, despite no rights
                FLS_SecurityUtils.checkInsert(
                    Account.SObjectType,
                    new List<String>{
                        'Name',
                            'Type',
                            'ownerId'
                            }
                );
                FLS_SecurityUtils.checkRead(
                    Contact.SObjectType,
                    new List<String>{
                        'LastName',
                            'accountId',
                            'ownerId'
                            }
                );
                FLS_SecurityUtils.checkUpdate(
                    Lead.SObjectType,
                    new List<String>{
                        'LastName',
                            'FirstNAMe',
                            'cOMPANY'
                            }
                );
            }
        }
    }
    
    @isTest
    static void sysadminObjectAndFieldAccess() {
        User testUser = setupTestUser('System Administrator');
        System.assertEquals(testUser.alias,'testExec','alias should be same');
        System.runAs(testUser){
            FLS_SecurityUtils.checkInsert(
                Account.SObjectType,
                new List<Schema.SObjectField>{
                    Account.SObjectType.fields.Name,
                        Account.SObjectType.fields.ParentId,
                        Account.SObjectType.fields.ownerId
                        }
            );
            FLS_SecurityUtils.checkRead(
                Contact.SObjectType,
                new List<Schema.SObjectField>{
                    Contact.SObjectType.fields.LastName,
                        Contact.SObjectType.fields.accountId,
                        Contact.SObjectType.fields.ownerId
                        }
            );
            FLS_SecurityUtils.checkUpdate(
                Lead.SObjectType,
                new List<Schema.SObjectField>{
                    Lead.SObjectType.fields.LastName,
                        Lead.SObjectType.fields.FirstNAMe,
                        Lead.SObjectType.fields.cOMPANY
                        }
            );
        }
    }
}