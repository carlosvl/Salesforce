public with sharing class LookupFieldController {

  private static final String LIKE_TEMPLATE = '%{0}%';
  private static final String COMMA = ',';
  private static final String SEARCH_QUERY =
    'select Id, Name {1} from {0} where Name like :likeTerm order by Name asc limit 100';
  private static final String GET_QUERY =
    'select Id, Name from {0} where Id = :objectId';

  @AuraEnabled
  public static List<SObject> getLookupSearchResults(String searchTerm,
      String objectType) {
    if (String.isBlank(searchTerm) || String.isBlank(objectType)) {
      return null;
    }

    String likeTerm = String.format(LIKE_TEMPLATE,
      new List<String> { searchTerm });
    String query = String.format(SEARCH_QUERY,
      new List<String> { objectType, getFieldListForFieldSet(objectType) });

    System.debug(query);

    return Database.query(query);
  }

  @AuraEnabled
  public static List<String> getFieldList(String objectName) {
    if (String.isBlank(objectName)) {
      return null;
    }

    Schema.DescribeSObjectResult od;
    Schema.FieldSet fs;
    LookupFieldSets__c fieldSetting = getFieldSettingForObject(objectName);
    List<String> fieldList = new List<String>();

    if (fieldSetting == null) {
      return null;
    }

    od = Schema.getGlobalDescribe().get(objectName).getDescribe();
    fs = od.fieldSets.getMap().get(fieldSetting.Field_Set_Name__c);

    if (fs == null) {
      return null;
    }

    for (Schema.FieldSetMember fsm : fs.getFields()) {
      fieldList.add(fsm.getFieldPath());
    }

    return fieldList;
  }

  @AuraEnabled
  public static String getLookupObjectById(Id objectId) {
    if (String.isBlank(objectId)) {
      return null;
    }

    return JSON.serialize(qutils.QueryUtils.queryObject(objectId));
  }

  private static String getFieldListForFieldSet(String objectName) {
    List<String> fieldList = getFieldList(objectName);

    if (fieldList == null || fieldList.isEmpty()) {
      return '';
    }

    return COMMA + String.join(fieldList, COMMA);
  }

  private static LookupFieldSets__c getFieldSettingForObject(
      String objectName) {
    return LookupFieldSets__c.getValues(objectName);
  }
}