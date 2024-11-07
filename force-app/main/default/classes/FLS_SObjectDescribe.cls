/**
 * @description A class for describing SObjects with a focus on handling field-level security.
 * It provides methods to retrieve information about SObjects, their fields, and field sets.
 * The class uses lazy loading and caching mechanisms for improved performance.
 */
public with sharing class FLS_SObjectDescribe {
    //internal implementation details
    private Schema.SObjectType token;
    private Schema.SObjectField nameField;
    private Schema.DescribeSObjectResult describe { //lazy load - keep this leightweight until we need more data
        get{
            if(describe == null) {
                describe = token.getDescribe();
            }
            return describe;
        }
        set;
    }
    private Map<String,Schema.SObjectField> fields {
        get{
            if(fields == null) {
                fields = describe.fields.getMap();
            }
            return fields;
        }
        set;
    }
    private Map<String,Schema.FieldSet> fieldSets {
        get{
            if(fieldSets == null) {
                fieldSets = describe.fieldSets.getMap();
            }
            return fieldSets;
        }
        set;
    }
    private FieldsMap wrappedFields {
        get{
            if(wrappedFields == null) {
                wrappedFields = new FieldsMap(this.fields);
            }
            return wrappedFields;
        }
        set;
    }

    private fls_SObjectDescribe(Schema.SObjectType token) {    
        if(token == null) {
            throw new InvalidDescribeException('Invalid SObject type: null');
        }
        if(instanceCache.containsKey( String.valueOf(token) )) {
            throw new DuplicateDescribeException(token + ' is already in the describe cache');
        }
        this.token = token;
        instanceCache.put( String.valueOf(token).toLowerCase() , this);
    }

    //public instace methods
    /**
     * @description Returns the Schema.SObjectType this FLS_SObjectDescribe instance is based on.
     *
     * @return The Schema.SObjectType.
     */
    public Schema.SObjectType getSObjectType() {
        return token;
    }
     /**
     * @description A shorthand for calling getField(name, true).
     * @param name The name of the field.
     * @return The Schema.SObjectField.
     */
    public Schema.SObjectField getField(String name) {
        return this.getField(name, true);
    }
    /**
     * @description Provides a simplified shorthand for calling #getFields and getting the provided field.
     * It handles finding the correct SObjectField for relationship notation.
     * @param fieldName The name of the field.
     * @param implyNamespace Indicates whether to imply the namespace.
     * @return The Schema.SObjectField.
     */
    public Schema.SObjectField getField(String fieldName, boolean implyNamespace) {
        Schema.SObjectField result = wrappedFields.get( 
            (fieldName.endsWithIgnoreCase('__r') ? //resolve custom field cross-object (__r) syntax
            (fieldName.removeEndIgnoreCase('__r')+'__c') :
            fieldName),
            implyNamespace
        ); 
        if(result == null) {
            result = wrappedFields.get(fieldName+'Id', implyNamespace); //in case it's a standard lookup in cross-object format
        }
        return result;
    }
    /**
     * @description Returns the field where isNameField() is true (if any); otherwise returns null.
     *
     * @return The Schema.SObjectField representing the name field.
     */
    public Schema.SObjectField getNameField() {
        if(nameField == null) {
            for(Schema.SObjectField field : wrappedFields.values()) {
                if(field.getDescribe().isNameField()) {
                    nameField = field;
                    break;
                }
            }
        }
        return nameField;
    }
    /**
     * @description Returns the raw Schema.DescribeSObjectResult that an FLS_SObjectDescribe instance wraps.
     *
     * @return The Schema.DescribeSObjectResult.
     */
    public Schema.DescribeSObjectResult getDescribe() {
        return describe;
    }
    
    /**
 * @description Gets a map of SObject fields.
 *
 * @return A map containing SObject fields, where the key is the field name.
 */
    /**
     * @return This method returns the raw data and provides no namespace handling.
     * @description Due to this, __use of this method is discouraged__ in favor of getFields(). 
    **/
    public Map<String,Schema.SObjectField> getFieldsMap() {
        return fields;
    }
    /**
 * @description Gets an instance of FieldsMap, which is a wrapper for the SObject fields map.
 *
 * @return An instance of FieldsMap.
 */
    public FieldsMap getFields(){
        return wrappedFields;
    }
    /**
 * @description Gets a map of field sets associated with the SObject.
 *
 * @return A map containing field sets, where the key is the field set name.
 */
    public Map<String,Schema.FieldSet> getFieldSetsMap() {
        return fieldSets;
    }
	/**
 * @description Singleton cache to store the raw global describe map of SObject types.
 */
    private static Map<String,Schema.SObjectType> rawGlobalDescribe {
        get{
            if(rawGlobalDescribe == null) {
                rawGlobalDescribe = Schema.getGlobalDescribe();
            }
            return rawGlobalDescribe;
        }
        set;
    }
    /**
 * @description Singleton cache to store an instance of GlobalDescribeMap, which is a wrapper for the raw global describe map.
 */
    private static GlobalDescribeMap wrappedGlobalDescribe {
        get{
            if(wrappedGlobalDescribe == null) {
                wrappedGlobalDescribe = new GlobalDescribeMap(rawGlobalDescribe);
            }
            return wrappedGlobalDescribe;
        }
        set;
    }
    
    /**
 * @description Singleton cache to store instances of fls_SObjectDescribe based on SObject names.
 */
    /**
     * @description This is used to cache fls_SObjectDescribe instances as they're consutrcted
     * to prevent repeatedly re-constructing the same type.
     * These instances are not guaranteed to be, but typically will be, unique per sObject type due to the presence of flushCache.
    **/
    private static Map<String,fls_SObjectDescribe> instanceCache {get{
            if(instanceCache == null) {
                instanceCache = new Map<String,fls_SObjectDescribe>();
            }
            return instanceCache;
        } 
        set;
    }
    /**
 * @description Gets an instance of fls_SObjectDescribe based on the SObject name.
 * 
 * @param sObjectName The name of the SObject.
 * @return An instance of fls_SObjectDescribe corresponding to the SObject name.
 */
    public static fls_SObjectDescribe getDescribe(String sObjectName) {
        if(String.isBlank(sObjectName)) {
            return null;
        }
        fls_SObjectDescribe result = instanceCache.get(sObjectName.toLowerCase());
        if(result == null) {
            Schema.SObjectType token = wrappedGlobalDescribe.get(sObjectName.toLowerCase());
            if(token == null) {
                result = null;
            }
            else {
                result = new fls_SObjectDescribe(token);
            }
        }
        return result;
    }
    /**
 * @description Gets an instance of fls_SObjectDescribe based on the SObjectType token.
 * 
 * @param token The SObjectType token.
 * @return An instance of fls_SObjectDescribe corresponding to the SObjectType token.
 */
    public static fls_SObjectDescribe getDescribe(Schema.SObjectType token) {
        if(token == null) {
            return null;
        }
        fls_SObjectDescribe result = instanceCache.get(String.valueOf(token).toLowerCase());
        if(result == null) {
            result = new fls_SObjectDescribe(token);      
        }
        return result;
    }
    
    /**
 * @description Gets or creates an instance of fls_SObjectDescribe based on a native DescribeSObjectResult.
 * 
 * @param nativeDescribe The native DescribeSObjectResult to base the fls_SObjectDescribe instance on.
 * @return An instance of fls_SObjectDescribe.
 */
    public static fls_SObjectDescribe getDescribe(Schema.DescribeSObjectResult nativeDescribe) {
        if(nativeDescribe == null) {
            return null;
        }
        fls_SObjectDescribe result = instanceCache.get(nativeDescribe.getName().toLowerCase());
        if(result == null) {
            result = new fls_SObjectDescribe(nativeDescribe.getSobjectType());        
        }
        return result;
    }
    /**
 * @description Gets or creates an instance of fls_SObjectDescribe based on an SObject instance.
 * 
 * @param instance The SObject instance to base the fls_SObjectDescribe instance on.
 * @return An instance of fls_SObjectDescribe.
 */
    public static fls_SObjectDescribe getDescribe(SObject instance) {
        if(instance == null) {
            return null;
        }
        return getDescribe(instance.getSobjectType());
    }
	/**
 * @description Gets the raw global describe map. 
 * 
 * @return A map containing SObjectType information for all global objects.
 */
    /*returns the same results as the native method, just with caching built in to avoid limits*/
    public static Map<String,SObjectType> getRawGlobalDescribe() {
        return rawGlobalDescribe;
    }
    /**
 * @description Gets the global describe map with caching.
 * 
 * @return An instance of GlobalDescribeMap containing SObjectType information for all global objects.
 */
    public static GlobalDescribeMap getGlobalDescribe() {
        return wrappedGlobalDescribe;
    }
    /**
 * @description Flushes the cache, clearing rawGlobalDescribe and instanceCache.
 * Useful when working in heap space-constrained environments.
 */
    //Useful when working in heap space constrained environments. 
    //Existing references to SObjectDescribe instances will continue to work.
    public static void flushCache() {
        rawGlobalDescribe = null;
        instanceCache = null;
    }


    /**
     * @description This class handles emulating a Map<String,Object>'s non-mutating instance methods and helps navigate the complex topic of
     * handling implicit namespace behavior like pre-APIv29 did, while also allowing fully qualified references.
     * Note that this requires the API version of fls_SObjectDescribe to be 29 or higher to function properly.
     *
     * Due to the lack of language support for covariant return types sublasses are responsible for implementing the get methods.
     * A minimal implementation of these would be a cast and returning getObject's result.
    **/
    private abstract class NamespacedAttributeMap {
        @testVisible
        protected String currentNamespace;
        protected Map<String,Object> values;
		/**
     * @description Constructor for NamespacedAttributeMap.
     * 
     * @param values A map of key-value pairs to initialize the map.
     */
        protected NamespacedAttributeMap(Map<String,Object> values) {
            //namespace detection courtesey http://salesforce.stackexchange.com/a/28977/60
            currentNamespace = fls_SObjectDescribe.class.getName().substringBefore('fls_SObjectDescribe').removeEnd('.').toLowerCase();
            this.values = values;
        }
        /**
     * @description No-args constructor to allow subclasses with different constructor signatures.
     */
        //A no-args constructor to allow subclasses with different contructor signatures
        protected NamespacedAttributeMap() {
            this(new Map<String,Object>());
        }
        /**
     * @description Virtual method to get an object from the map based on the specified name.
     * 
     * @param name The name of the object.
     * @return The object corresponding to the name.
     */
        protected virtual Object getObject(String name) {
            return this.getObject(name, true);
        }
        /**
     * @description Virtual method to get an object from the map based on the specified name and implyNamespace flag.
     * 
     * @param name The name of the object.
     * @param implyNamespace A boolean flag indicating whether to imply the namespace.
     * @return The object corresponding to the name.
     */
        protected virtual Object getObject(String name, Boolean implyNamespace){
            if(name == null) {
            	//short-circuit lookup logic since null can't possibly be a valid field name, and it saves us null checking
                return null;
            }
            String preferredValue = ((implyNamespace ? currentNamespace+'__' : '') + name).toLowerCase();
            if(values.containsKey(preferredValue)) {
                return values.get(preferredValue);
            }else if(implyNamespace) {
                return values.get(name.toLowerCase());
            }else {
                return null;
            }
        }
        /**
     * @description Virtual method to check if the map contains a key.
     * 
     * @param name The name of the key.
     * @return True if the map contains the key, false otherwise.
     */
        public virtual Boolean containsKey(String name) {
            return this.containsKey(name, true);
        }
        /**
     * @description Virtual method to check if the map contains a key based on the specified name and implyNamespace flag.
     * 
     * @param name The name of the key.
     * @param implyNamespace A boolean flag indicating whether to imply the namespace.
     * @return True if the map contains the key, false otherwise.
     */
        public virtual Boolean containsKey(String name, Boolean implyNamespace) {
            if(name == null) {
             	//short-circuit lookup logic since null can't possibly be a valid field name, and it saves us null checking
                return null;
            }
            String preferredValue = ((implyNamespace ? currentNamespace+'__' : '') + name).toLowerCase();
            return (
                values.containsKey(preferredValue) ||
                implyNamespace && values.containsKey(name.toLowerCase())
            );
        }
		/**
     * @description Virtual method to get the size of the map.
     * 
     * @return The size of the map.
     */
        public virtual Integer size() {
            return values.size();
        }
        /**
     * @description Virtual method to get the key set of the map with an option to imply the namespace.
     * @param implyNamespace A boolean flag indicating whether to imply the namespace.
     * @return The key set of the map.
     */
        public virtual Set<String> keySet() {
            return this.keySet(false);
        }
        /**
 * @description Returns the key set of the map with an option to imply the namespace.
 * @param implyNamespace A boolean flag indicating whether to imply the namespace when forming the key set.
 * @return The key set of the map.
 */
        public virtual Set<String> keySet(Boolean implyNamespace) {
            if(implyNamespace) {
                Set<String> result = new Set<String>();
                for(String key:values.keySet()) {
                    result.add(
                        key.removeStartIgnoreCase(currentNamespace+'__')
                    );
                }
                return result;
            }else{
                return values.keySet();
            }
        }
    }

    /**
 * @description NamespacedAttributeMap is a utility class that extends the standard Map<String, Object> class
 * to provide additional functionality for handling namespaced attributes. This class is designed
 * to work with Salesforce metadata, particularly Schema.SObjectType and Schema.SObjectField instances.
 * It helps manage and retrieve these instances while considering the potential presence of namespaces.
 * 
 * This class includes methods to retrieve objects (e.g., Schema.SObjectType, Schema.SObjectField) by name
 * and with an option to imply the namespace. It also provides a method to get a list of values from the map.
 *
 * Example usage:
 * ```
 * // Create a NamespacedAttributeMap for Schema.SObjectType instances
 * Map<String, Schema.SObjectType> sObjectTypesMap = new Map<String, Schema.SObjectType>();
 * NamespacedAttributeMap sObjectTypesAttributeMap = new NamespacedAttributeMap(sObjectTypesMap);
 * 
 * // Retrieve an SObjectType with or without implying the namespace
 * Schema.SObjectType myObjectType = sObjectTypesAttributeMap.get('MyObject__c');
 * Schema.SObjectType myObjectTypeWithNamespace = sObjectTypesAttributeMap.get('MyObject__c', true);
 * 
 * // Get a list of all SObjectType values
 * List<Schema.SObjectType> allObjectTypes = sObjectTypesAttributeMap.values();
 * ```
 * 
 * Note: This comment is a general description and may need adjustment based on the specific implementation
 * of your NamespacedAttributeMap class.
 */
    public class FieldsMap extends NamespacedAttributeMap {
        @testVisible
        private FieldsMap(Map<String,Schema.SObjectField> values) {
            super(values);
        }
        /**
 * @description Gets the Schema.SObjectField for the given field name.
 *
 * @param name The name of the field.
 * @return The Schema.SObjectField.
 */
        public Schema.SObjectField get(String name) {
            return this.get(name, true);
        }
         /**
 * @description Gets the Schema.SObjectField for the given field name.
 *
 * @param name             The name of the field.
 * @param implyNamespace  If true, implies the namespace in the field name.
 * @return The Schema.SObjectField.
 */
        public Schema.SObjectField get(String name, Boolean implyNamespace) {
            return (Schema.SObjectField) this.getObject(name, implyNamespace);
        }
        /**
 * @description Gets a list of Schema.SObjectField values from the map.
 *
 * @return List of Schema.SObjectField values.
 */
        public List<Schema.SObjectField> values() {
            return (List<Schema.SObjectField>) values.values();
        }

    }
    /**
 * @description The base class for attribute maps with namespace support.
 */
    public class GlobalDescribeMap extends NamespacedAttributeMap {
        /**
     * @description Constructor for GlobalDescribeMap.
     *
     * @param values A map containing Schema.SObjectType values.
     */
        @testVisible
        private GlobalDescribeMap(Map<String,Schema.SObjectType> values) {
            super(values);
        }
        /**
 * @description Gets the Schema.SObjectType corresponding to the specified name.
 *
 * @param name The name of the Schema.SObjectType.
 * @return The Schema.SObjectType.
 */
        public Schema.SObjectType get(String name) {
            return this.get(name, true);
        }
        /**
 * @description Gets the Schema.SObjectType corresponding to the specified name.
 *
 * @param name             The name of the Schema.SObjectType.
 * @param implyNamespace   A boolean indicating whether to imply the namespace in the lookup.
 * @return The Schema.SObjectType.
 */
        public Schema.SObjectType get(String name, Boolean implyNamespace) {
            return (Schema.SObjectType) this.getObject(name, implyNamespace);
        }
        /**
 * @description Gets the list of Schema.SObjectType values.
 *
 * @return The list of Schema.SObjectType values.
 */
        public List<Schema.SObjectType> values() {
            return (List<Schema.SObjectType>) values.values();
        }
    }
/**
 * @description The abstract base class for custom exceptions with descriptive information.
 */
    public abstract class DescribeException extends Exception{}
    /**
 * @description Custom exception class indicating an attempt to create a duplicate instance of DescribeException.
 */
    public class DuplicateDescribeException extends DescribeException{} 
    /**
 * @description Custom exception class indicating an invalid operation or attempt related to DescribeException.
 */
    public class InvalidDescribeException extends DescribeException{}
}