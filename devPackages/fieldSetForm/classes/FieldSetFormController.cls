public with sharing class FieldSetFormController {

  private static final String PERIOD = '.';
  private static final String SEMI_COLON = ';';
  private static final String TYPE_CHECKBOX = 'Checkbox';

  @AuraEnabled
  public static String getFieldsForFieldSet(
      SObject currentObject, String fieldSetName) {
    if (currentObject == null || String.isBlank(fieldSetName)) {
      return null;
    }

    Application_Display_Field_Logic__c currentVisibility;
    FieldSetField member;
    Schema.DescribeSObjectResult od =
      currentObject.getSObjectType().getDescribe();
    Schema.FieldSet fs = od.fieldsets.getMap().get(fieldSetName);
    Set<String> allFields = new Set<String>();
    Set<String> controllingFields = new Set<String>();
    List<Schema.FieldSetMember> fieldsToProcess =
      new List<Schema.FieldSetMember>();
    List<FieldSetField> members = new List<FieldSetField>();
    Map<String, Application_Display_Field_Logic__c> fvMap;

    for (Schema.FieldSetMember fsm : fs.getFields()) {
      if (isCompoundfield(fsm.getFieldPath()) ||
          !isFieldValid(od, fsm.getFieldPath())) {
        continue;
      }

      fieldsToProcess.add(fsm);
      allFields.add(fsm.getFieldPath());
    }

    fvMap = getFieldVisibilities(od, allFields);

    for (Schema.FieldSetMember fsm : fieldsToProcess) {
      member = new FieldSetField(fsm,
        getIsFieldEditable(od, fsm.getFieldPath(), currentObject.Id == null),
          od);

      currentVisibility = fvMap.get(fsm.getFieldPath());

      if (currentVisibility != null) {
        member.isVisibilityDependent = true;
        member.visibilityControllingValues = getValueOptions(currentVisibility);
        member.visibilityMatchType =
          currentVisibility.Controlling_Field_Match_Type__c;
        member.visibilityControllingField =
          currentVisibility.ControllingField_API__c;
        controllingFields.add(currentVisibility.ControllingField_API__c);
      }


      members.add(member);
    }

    for (FieldSetField fsf : members) {
      fsf.isVisiblityControlling = controllingFields.contains(fsf.fieldName);
    }

    return JSON.serialize(members);
  }

  @AuraEnabled
  public static String getDescribeInfoForObject(
      SObject currentObject) {
    if (currentObject == null) {
      return null;
    }

    return JSON.serialize(ObjectDescribeUtils.getDescribeInfoForObject(
      currentObject.getSObjectType().getDescribe().getName()));
  }

  private static Map<String, Application_Display_Field_Logic__c>
      getFieldVisibilities(Schema.DescribeSObjectResult od,
        Set<String> fieldNames) {
    Map<String, Application_Display_Field_Logic__c> fvMap =
      new Map<String, Application_Display_Field_Logic__c>();

    for (Application_Display_Field_Logic__c fv :
        [select Id,
                Name,
                ControllingField_API__c,
                DependentField_API__c,
                ControllingField_Value__c,
                Controlling_Field_Type__c,
                Controlling_Field_Match_Type__c
         from Application_Display_Field_Logic__c
         where (ControllingField_API__c in :fieldNames
           or DependentField_API__c in :fieldNames)
         and ControllingField_Object__c = :od.getName()]) {
      fvMap.put(fv.DependentField_API__c, fv);
    }

    return fvMap;
  }

  private static List<Object> getValueOptions(
      Application_Display_Field_Logic__c fv) {
    if (String.isBlank(fv.ControllingField_Value__c)) {
      return null;
    }

    String tempVal;
    List<String> splitList = fv.ControllingField_Value__c.split(SEMI_COLON);
    List<Object> trimmedList = new List<Object>();

    for (String cv : splitList) {
      tempVal = cv.trim().toLowerCase();

      if (fv.Controlling_Field_Type__c == TYPE_CHECKBOX) {
        trimmedList.add(Boolean.valueOf(tempVal));
      } else {
        trimmedList.add(tempVal);
      }
    }

    return trimmedList;
  }

  private static Boolean getIsFieldEditable(
      Schema.DescribeSObjectResult objectDescribe, String fieldName,
        Boolean isNew) {
    Schema.DescribeFieldResult fieldDescribe =
      objectDescribe.fields.getMap().get(fieldName).getDescribe();
    return (isNew) ? fieldDescribe.isCreateable() :
      fieldDescribe.isUpdateable();
  }

  private static Boolean isCompoundfield(String fieldName) {
    return fieldName.contains(PERIOD);
  }

  private static Boolean isFieldValid(
      Schema.DescribeSObjectResult objectDescribe, String fieldName) {
    Schema.SObjectField f = objectDescribe.fields.getMap().get(fieldName);
    
    return f != null;
  }
}