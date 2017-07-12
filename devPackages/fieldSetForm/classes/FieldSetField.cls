public with sharing class FieldSetField {

  private static final String SELECT_ONE_OPTION = '-- Select One --';

  @AuraEnabled
  public String fieldName { get; set; }

  @AuraEnabled
  public String fieldLabel { get; set; }

  @AuraEnabled
  public Boolean isEditable { get; set; }

  @AuraEnabled
  public Boolean required { get; set; }

  @AuraEnabled
  public String type { get; set; }

  @AuraEnabled
  public Integer scale { get; set; }

  @AuraEnabled
  public String helpText { get; set; }

  @AuraEnabled
  public Integer maxLength { get; set; }

  @AuraEnabled
  public Boolean isDependent { get; set; }

  @AuraEnabled
  public String controllingField { get; set; }

  @AuraEnabled
  public String visibilityControllingField { get; set; }

  @AuraEnabled
  public Boolean isVisibilityDependent { get; set; }

  @AuraEnabled
  public Boolean isVisible { get; set; }

  @AuraEnabled
  public Boolean isVisiblityControlling { get; set; }

  @AuraEnabled
  public String visibilityMatchType { get; set; }

  @AuraEnabled
  public Object defaultValue { get; set; }

  @AuraEnabled
  public String referenceObject { get; set; }

  @AuraEnabled
  public List<Object> visibilityControllingValues { get; set; }

  @AuraEnabled
  public List<CustomSelectOption> options { get; set; }

  public FieldSetField(Schema.FieldSetMember fsm, Boolean isEditable,
      Schema.DescribeSObjectResult objectDescribe) {
    Schema.DescribeFieldResult fd =
      objectDescribe.fields.getMap().get(fsm.getFieldPath()).getDescribe();
    this.scale = fd.getScale();
    this.fieldName = fsm.getFieldPath();
    this.fieldLabel = fsm.getLabel();
    this.isEditable = isEditable;
    this.required = fsm.getDBRequired() || fsm.getRequired();
    this.type = '' + fsm.getType();
    this.helpText = getHelpText(fsm.getFieldPath(), objectDescribe, fd);
    this.maxLength = getMaxLength(fsm.getFieldPath(), objectDescribe, fd);
    this.isVisibilityDependent = false;
    this.isVisible = true;
    this.isVisiblityControlling = false;

    setDependencyInfo(objectDescribe, fd);

    if ((fsm.getType() == Schema.DisplayType.Picklist ||
        fsm.getType() == Schema.DisplayType.MultiPicklist) &&
          !this.isDependent) {
      this.options = getPicklistValues(this.fieldName, objectDescribe,
        fsm.getType() == Schema.DisplayType.Picklist);

      for (CustomSelectOption cso : this.options) {
        if (cso.isDefault) {
          this.defaultValue = cso.value;
        }
      }
    } else if (fsm.getType() == Schema.DisplayType.Reference) {
      this.referenceObject = getReferenceObjectName(fd);
    }
  }

  private List<CustomSelectOption> getPicklistValues(String fieldName,
      Schema.DescribeSObjectResult od, Boolean addEmptyOption) {
    Map<String, List<CustomSelectOption>> optionMap =
      getSelectOptionsForFieldAndObject(od,
        new List<String> { fieldName }, addEmptyOption);

    return optionMap.get(fieldName);
  }

  private String getHelpText(String fieldName,
      Schema.DescribeSObjectResult od, Schema.DescribeFieldResult fd) {
    return fd.getInlineHelpText();
  }

  private Integer getMaxLength(String fieldName,
      Schema.DescribeSObjectResult od, Schema.DescribeFieldResult fd) {
    return fd.getLength();
  }

  private String getReferenceObjectName(Schema.DescribeFieldResult fd) {
    return fd.getReferenceTo()[0].getDescribe().getName();
  }

  private void setDependencyInfo(Schema.DescribeSObjectResult od,
      Schema.DescribeFieldResult fd) {
    this.isDependent = fd.isDependentPicklist();

    if (this.isDependent) {
      this.controllingField = fd.getController().getDescribe().getName();
    }
  }



  public static Map<String, List<CustomSelectOption>>
      getSelectOptionsForFieldAndObject(
        Schema.DescribeSObjectResult objectDescribe, List<String> fieldNames) {
    return getSelectOptionsForFieldAndObject(
      objectDescribe, fieldNames, true);
  }

  public static Map<String, List<CustomSelectOption>>
      getSelectOptionsForFieldAndObject(
        Schema.DescribeSObjectResult objectDescribe, List<String> fieldNames,
          Boolean addEmptyOption) {
    if (objectDescribe == null || fieldNames == null || fieldNames.isEmpty()) {
      return null;
    }

    Schema.DescribeFieldResult fd;
    Schema.SObjectField field;
    List<CustomSelectOption> options;
    Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
    Map<String, List<CustomSelectOption>> optionMap =
      new Map<String, List<CustomSelectOption>>();

    for (String fn : fieldNames) {
      field = fieldMap.get(fn);

      if (field == null) {
        continue;
      }

      fd = field.getDescribe();
      options = new List<CustomSelectOption>();

      if (addEmptyOption) {
        options.add(new CustomSelectOption('', SELECT_ONE_OPTION, false));
      }

      for (Schema.PicklistEntry ple : fd.getPicklistValues()) {
        options.add(new CustomSelectOption(ple.getValue(), ple.getLabel(),
          ple.isDefaultValue()));
      }

      optionMap.put(fn, options);
    }

    return optionMap;
  }
}