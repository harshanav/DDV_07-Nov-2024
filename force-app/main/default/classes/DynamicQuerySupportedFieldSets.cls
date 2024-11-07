global class DynamicQuerySupportedFieldSets extends VisualEditor.DynamicPickList{
 
    List<String> sObjects = new List<String>();
 
    public DynamicQuerySupportedFieldSets() {
        this.sObjects = new List<String>{'Account Name', 'Account NUmber', 'Email', 'Account Type'};
    }
     
    global override VisualEditor.DataRow getDefaultValue(){
        return new VisualEditor.DataRow(sObjects[0], sObjects[0]);
    }
    global override VisualEditor.DynamicPickListRows getValues() {
 
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        for (String sobj : sObjects) {
            VisualEditor.DataRow tempVal = new VisualEditor.DataRow(sobj, sobj);
            values.addRow(tempVal);
        }
        return values;
    }
}