public class DynamicDataTableConfigCtrl {
 
    public DynamicDataTableConfigCtrl() {
 
    }
 
    public static List<String> getSObjects() {
         
        Set<String> sobjects = new Set<String>();
 
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            if(objTyp.getDescribe().isAccessible() && objTyp.getDescribe().isUpdateable() && objTyp.getDescribe().isQueryable()){
                sobjects.add(objTyp.getDescribe().getName());
            }
        }
        return new List<String>(sobjects);
    }
}