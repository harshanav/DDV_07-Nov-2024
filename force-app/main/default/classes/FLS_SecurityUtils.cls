/**
* @description Utility class for handling Field-Level Security (FLS) and CRUD (Create, Read, Update, Delete) checks in Salesforce.
*/
public with sharing class FLS_SecurityUtils {
    @testVisible 
    private Enum OperationType { CREATE, READ, MODIFY, DEL } //UPDATE and DELETE are reserved words
    /**
* @description Custom exception class for security-related issues.
*/
    public virtual class SecurityException extends Exception {
        protected OperationType moperation;
        protected Schema.SObjectType mobjectType;
    }
    /**
* @description Exception for CRUD-related security issues.
*/    
    public class CrudException extends SecurityException {
        
        private CrudException(OperationType operation, Schema.SObjectType objectType) {
            this.moperation = operation;
            this.mobjectType = objectType;
            if(operation == OperationType.CREATE) {
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + '  not insertable.');
            }      
            else if(operation == OperationType.READ) {
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + '  not readable.');
            }               
            else if(operation == OperationType.MODIFY) {
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + '  not updateable.');
            }             
            else if(operation == OperationType.DEL) {
                this.setMessage('Security error, ' + objectType.getDescribe().getLabel() + '  not deletable.');
            }           
            
            this.setMessage(
                String.format(
                    this.getMessage(),
                    new List<String>{
                        objectType.getDescribe().getName()
                            } 
                )
            );
        }
    }
    /**
* @description Exception for FLS-related security issues.
*/
    public class FlsException extends SecurityException {
        private Schema.SObjectField mfieldToken;
        
        private FlsException(OperationType operation, Schema.SObjectType objectType, Schema.SObjectField fieldToken) {
            this.moperation = operation;
            this.mobjectType = objectType;
            this.mfieldToken = fieldToken;
            if(operation == OperationType.CREATE) {
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + ' not insertable.');
            }
            else if(operation == OperationType.READ) {
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + '  not readable.');
            }
            else if(operation == OperationType.MODIFY) {
                this.setMessage('Security error, ' + fieldToken.getDescribe().getLabel() + ' on ' + objectType.getDescribe().getLabel() + '  not updateable.');
            }
            
            this.setMessage(
                String.format(
                    this.getMessage(),
                    new List<String>{
                        objectType.getDescribe().getName(),
                            fieldToken.getDescribe().getName()
                            }
                )
            );
        }
    }
    
    public static boolean bYPASSINTERNALFLSANDCRUD = false;
    /**
		* @description Checks whether the specified fields can be inserted for the given SObjectType.
		* @param objType The Salesforce SObjectType on which the insertion is being checked.
		* @param fieldNames The list of field names to be checked for insertability.
	*/
    public static void checkInsert(SObjectType objType, List<String> fieldNames) {
        checkObjectIsInsertable(objType);
        for (String fieldName : fieldNames) {
            checkFieldIsInsertable(objType, fieldName);
        }
    }
    /**
 		* @description Overloaded method to check whether the specified SObjectFields can be inserted for the given SObjectType.
 		* @param objType The Salesforce SObjectType on which the insertion is being checked.
 		* @param fieldTokens The list of SObjectFields to be checked for insertability.
 	*/    
    public static void checkInsert(SObjectType objType, List<SObjectField> fieldTokens) {
        checkObjectIsInsertable(objType);
        for (SObjectField fieldToken : fieldTokens) {
            checkFieldIsInsertable(objType, fieldToken);
        }
    }
    /**
 		* @description Checks whether the specified fields can be read for the given SObjectType.
 		* @param objType The Salesforce SObjectType on which the read operation is being checked.
 		* @param fieldNames The list of field names to be checked for readability.
 	*/
    public static void checkRead(SObjectType objType, List<String> fieldNames) {
        checkObjectIsReadable(objType);
        for (String fieldName : fieldNames) {
            checkFieldIsReadable(objType, fieldName);
        }
    }
    /**
 		* @description Checks whether the specified SObjectFields can be read for the given SObjectType.
 		* @param objType The Salesforce SObjectType on which the read operation is being checked.
 		* @param fieldTokens The list of SObjectFields to be checked for readability.
 	*/    
    public static void checkRead(SObjectType objType, List<SObjectField> fieldTokens) {
        checkObjectIsReadable(objType);
        for (SObjectField fieldToken : fieldTokens) {
            checkFieldIsReadable(objType, fieldToken);
        }
    }
    /**
 		* @description Checks whether the specified fields can be updated for the given SObjectType.
 		* @param objType The Salesforce SObjectType on which the update operation is being checked.
 		* @param fieldNames The list of field names to be checked for updateability.
 	*/
    public static void checkUpdate(SObjectType objType, List<String> fieldNames) {
        checkObjectIsUpdateable(objType);
        for (String fieldName : fieldNames) {
            checkFieldIsUpdateable(objType, fieldName);
        }
    }
    /**
 		* @description Overloaded method to check whether the specified SObjectFields can be updated for the given SObjectType.
 		* @param objType The Salesforce SObjectType on which the update operation is being checked.
 		* @param fieldTokens The list of SObjectFields to be checked for updateability.
 	*/    
    public static void checkUpdate(SObjectType objType, List<SObjectField> fieldTokens) {
        checkObjectIsUpdateable(objType);
        for (SObjectField fieldToken : fieldTokens) {
            checkFieldIsUpdateable(objType, fieldToken);
        }
    }
    /**
 		* @description Checks whether the specified field can be inserted for the given SObjectType.
 		* @param objType The Salesforce SObjectType on which the insertion is being checked.
 		* @param fieldName The name of the field to be checked for insertability.
 	*/
    public static void checkFieldIsInsertable(SObjectType objType, String fieldName) {
        if(fls_SObjectDescribe.getDescribe(objType).getFieldsMap().containsKey(fieldName)) {
            checkFieldIsInsertable(objType, fls_SObjectDescribe.getDescribe(objType).getField(fieldName));
        }
    }
    /**
 * @description Checks whether the specified SObjectField can be inserted for the given SObjectType.
 * @param objType The Salesforce SObjectType on which the insertion is being checked.
 * @param fieldToken The SObjectField to be checked for insertability.
 */
    public static void checkFieldIsInsertable(SObjectType objType, SObjectField fieldToken) {
        checkFieldIsInsertable(objType, fieldToken.getDescribe());
    }
    /**
 * @description Checks whether the specified DescribeFieldResult indicates insertability for the given SObjectType.
 * @param objType The Salesforce SObjectType on which the insertion is being checked.
 * @param fieldDescribe The DescribeFieldResult representing the field to be checked.
 * @throws FlsException Thrown if the field is not insertable.
 */
    public static void checkFieldIsInsertable(SObjectType objType, DescribeFieldResult fieldDescribe) {
        if (bYPASSINTERNALFLSANDCRUD) {
            return;
        }
        if (!fieldDescribe.isCreateable()) {
            throw new FlsException(OperationType.CREATE, objType, fieldDescribe.getSObjectField());
        }
    }
    /**
 * @description Checks whether the specified field can be read for the given SObjectType.
 * @param objType The Salesforce SObjectType on which the read operation is being checked.
 * @param fieldName The name of the field to be checked for readability.
 */
    public static void checkFieldIsReadable(SObjectType objType, String fieldName) {
        if(fls_SObjectDescribe.getDescribe(objType).getFieldsMap().containsKey(fieldName)) {
            checkFieldIsReadable(objType, fls_SObjectDescribe.getDescribe(objType).getField(fieldName));
        }
    }
    /**
 * @description Checks whether the specified SObjectField can be read for the given SObjectType.
 * @param objType The Salesforce SObjectType on which the read operation is being checked.
 * @param fieldToken The SObjectField to be checked for readability.
 */
    public static void checkFieldIsReadable(SObjectType objType, SObjectField fieldToken) {
        checkFieldIsReadable(objType, fieldToken.getDescribe());
    }
    /**
* @description Checks whether the specified DescribeFieldResult indicates readability for the given SObjectType.
* @param objType The Salesforce SObjectType on which the read operation is being checked.
* @param fieldDescribe The DescribeFieldResult representing the field to be checked.
* @throws FlsException Thrown if the field is not readable.
*/
    public static void checkFieldIsReadable(SObjectType objType, DescribeFieldResult fieldDescribe) {
        if (bYPASSINTERNALFLSANDCRUD) {
            return;
        }
        if (!fieldDescribe.isAccessible()) {
            throw new FlsException(OperationType.READ, objType, fieldDescribe.getSObjectField());
        }
    }
    /**
 * @description Checks whether the specified field can be updated for the given SObjectType.
 * @param objType The Salesforce SObjectType on which the update operation is being checked.
 * @param fieldName The name of the field to be checked for updateability.
 */
    public static void checkFieldIsUpdateable(SObjectType objType, String fieldName) {
        if(fls_SObjectDescribe.getDescribe(objType).getFieldsMap().containsKey(fieldName)) {
            checkFieldIsUpdateable(objType, fls_SObjectDescribe.getDescribe(objType).getField(fieldName)); 
        }
    }
    /**
 * @description Checks whether the specified SObjectField can be updated for the given SObjectType.
 * @param objType The Salesforce SObjectType on which the update operation is being checked.
 * @param fieldToken The SObjectField to be checked for updateability.
 */
    public static void checkFieldIsUpdateable(SObjectType objType, SObjectField fieldToken) {
        checkFieldIsUpdateable(objType, fieldToken.getDescribe());
    }
    /**
 * @description Checks whether the specified DescribeFieldResult indicates updateability for the given SObjectType.
 * @param objType The Salesforce SObjectType on which the update operation is being checked.
 * @param fieldDescribe The DescribeFieldResult representing the field to be checked.
 * @throws FlsException Thrown if the field is not updateable.
 */
    public static void checkFieldIsUpdateable(SObjectType objType, DescribeFieldResult fieldDescribe) {
        if (bYPASSINTERNALFLSANDCRUD) {
            return;
        }
        if (!fieldDescribe.isUpdateable()) {
            throw new FlsException(OperationType.MODIFY, objType, fieldDescribe.getSObjectField());
        }
    }
    /**
 * @description Checks whether the specified SObjectType can be inserted.
 * @param objType The Salesforce SObjectType to be checked for insertability.
 */
    public static void checkObjectIsInsertable(SObjectType objType) {
        if (bYPASSINTERNALFLSANDCRUD) {
            return;
        }
        if (!objType.getDescribe().isCreateable()) {
            throw new CrudException(OperationType.CREATE, objType);
        }
    }
    /**
 * @description Checks whether the specified SObjectType can be read.
 * @param objType The Salesforce SObjectType to be checked for readability.
 */
    public static void checkObjectIsReadable(SObjectType objType) {
        if (bYPASSINTERNALFLSANDCRUD) {
            return;
        }
        if (!objType.getDescribe().isAccessible()) {
            throw new CrudException(OperationType.READ, objType);
        }
    }
    /**
 * @description Checks whether the specified SObjectType can be updated.
 * @param objType The Salesforce SObjectType to be checked for updateability.
 */
    public static void checkObjectIsUpdateable(SObjectType objType) {
        if (bYPASSINTERNALFLSANDCRUD) {
            return;
        }
        if (!objType.getDescribe().isUpdateable()) {
            throw new CrudException(OperationType.MODIFY, objType);
        }
    }
    /**
 * @description Checks whether the specified SObjectType can be deleted.
 * @param objType The Salesforce SObjectType to be checked for deletability.
 */
    public static void checkObjectIsDeletable(SObjectType objType) {
        if (bYPASSINTERNALFLSANDCRUD) {
            return;
        }
        if (!objType.getDescribe().isDeletable()) {
            throw new CrudException(OperationType.DEL, objType);
        }
    }
    
}