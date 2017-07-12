global with sharing class QueryUtils {

  private static final String ID_FIELD = 'Id';
  private static final String SEARCH_QUERY_TEMPLATE =
    'select {0} from {1} where {2} {3}';
  private static final String QUERY_ALL_TEMPLATE = 'select {0} from {1} {2}';
  private static final String QUERY_TEMPLATE =
    'select {0} from {1} where {2} in :objectIds {3}';
  private static final String ORDER_BY_TEMPLATE = 'order by {0} {1}';
  private static final String AND_TEMPLATE = 'and {0}';
  private static final String COMPARISON_TEMPLATE = '{0} like \'\'%{1}%\'\'';
  private static final String ORDER_BY_ASC = 'asc';
  private static final String FIELD_SEPARATOR = ',';
  private static final String SPACE = ' ';

  global static List<SObject> searchObject(Schema.SObjectType objectType,
    String orderByField, String orderByDirection,
      Map<String, String> searchTerms, Set<String> additionalFields) {
    if (objectType == null || searchTerms == null || searchTerms.isEmpty()) {
      return null;
    }

    String fieldNames = getFieldNames(objectType, additionalFields);
    String query = String.format(SEARCH_QUERY_TEMPLATE, new List<String> {
      fieldNames, objectType.getDescribe().getName(),
        generateComparisonString(searchTerms),
          generateOrderByString(orderbyField, orderByDirection) });

    System.debug(query);

    return Database.query(query);
  }

  global static List<SObject> queryAll(Schema.SObjectType objectType,
      Set<String> additionalFields, String orderByField,
        String orderByDirection) {
    if (objectType == null) {
      return null;
    }

    String fieldNames = getFieldNames(objectType, additionalFields);
    String query = String.format(QUERY_ALL_TEMPLATE, new List<String> {
      fieldNames, objectType.getDescribe().getName(),
        generateOrderByString(orderByField, orderByDirection) });

    System.debug(query);

    return Database.query(query);
  }

  global static SObject queryObject(Id objectId) {
    return queryObject(objectId, null);
  }

  global static List<SObject> queryObjectsByRelationship(
      Schema.SobjectType objectType, String relationshipFieldName,
        Id objectId) {
    return queryObjectsByRelationship(objectType, relationshipFieldName,
      objectId, null);
  }

  global static List<SObject> queryObjectsByRelationship(
      Schema.SobjectType objectType, String relationshipFieldName, Id objectId,
        Set<String> additionalFields) {
    return queryObjectsByRelationship(objectType, relationshipFieldName,
      objectId, additionalFields, null, null);
  }

  global static List<SObject> queryObjectsByRelationship(
      Schema.SobjectType objectType, String relationshipFieldName, Id objectId,
        Set<String> additionalFields, String orderByField,
          String orderByDirection) {
    if (objectType == null || String.isBlank(relationshipFieldName) ||
        String.isBlank(objectId)) {
      return null;
    }

    return queryObjectsByRelationship(objectType,
      relationshipFieldName, new Set<Id> { objectId }, additionalFields,
        orderByField, orderByDirection);
  }

  global static List<SObject> queryObjectsByRelationshipAndFieldSets(
      Schema.SObjectType objectType, String relationshipFieldName,
        Id objectId, String orderByField, String orderByDirection,
          List<String> fieldSetNames) {
    if (String.isBlank(objectId)) {
      return null;
    }

    return queryObjectsByRelationshipAndFieldSets(objectType,
      relationshipFieldName, new Set<Id> { objectId }, orderbyField,
        orderByDirection, fieldSetNames);
  }

  global static List<SObject> queryObjectsByRelationshipAndFieldSets(
      Schema.SObjectType objectType, String relationshipFieldName,
        Set<Id> objectIds, String orderByField, String orderByDirection,
          List<String> fieldSetNames) {
    if (objectType == null || String.isBlank(relationshipFieldName) ||
        objectIds == null || objectIds.isEmpty() ||
          fieldSetNames == null || fieldSetNames.isEmpty()) {
      return null;
    }

    String fieldNames = getFieldNamesFromFieldSets(objectType, fieldSetNames);

    if (String.isBlank(fieldNames)) {
      return null;
    }

    String query = generateQuery(fieldNames,
      objectType, relationshipFieldName, orderByField, orderByDirection);

    return Database.query(query);
  }

  global static SObject queryObjectFromFieldSets(Id objectId,
      List<String> fieldSetNames) {
    if (String.isBlank(objectId) || fieldSetNames == null ||
        fieldSetNames.isEmpty()) {
      return null;
    }

    List<SObject> results = queryObjectsFromFieldSets(
      new Set<Id> { objectId }, fieldSetNames);

    return (results.isEmpty()) ? null : results[0];
  }

  global static List<SObject> queryObjectsFromFieldSets(Set<Id> objectIds,
      List<String> fieldSetNames) {
    if (objectIds == null || objectIds.isEmpty() || fieldSetNames == null ||
        fieldSetNames.isEmpty()) {
      return null;
    }

    Schema.SObjectType objectType = new List<Id>(objectIds)[0].getSObjectType();
    String fieldNames = getFieldNamesFromFieldSets(objectType, fieldSetNames);

    if (String.isBlank(fieldNames)) {
      return null;
    }

    return Database.query(generateQuery(fieldNames, objectType, ID_FIELD));
  }

  global static List<SObject> queryObjectsWithOrder(Set<Id> objectIds,
      Set<String> additionalFields, String orderByField,
        String orderByDirection) {
    if (objectIds == null || objectIds.isEmpty()) {
      return null;
    }

    Schema.SObjectType objectType = new List<Id>(objectIds)[0].getSObjectType();

    String query = generateQuery(
      getFieldNames(objectType, additionalFields), objectType, ID_FIELD,
        orderByField, orderByDirection);

    return Database.query(query);
  }

  global static SObject queryObject(Id objectId, Set<String> additionalFields) {
    if (String.isBlank(objectId)) {
      return null;
    }

    List<SObject> results = queryObjects(new Set<Id> { objectId },
      additionalFields);

    return (results.isEmpty()) ? null : results[0];
  }

  global static List<SObject> queryObjects(Set<Id> objectIds) {
    return queryObjects(objectIds, null);
  }

  global static SObject queryObjectWithSpecificFields(Id objectId,
      Set<String> fieldsToQuery) {
    if (String.isBlank(objectId) || fieldsToQuery == null ||
        fieldsToQuery.isEmpty()) {
      return null;
    }

    List<SObject> results = queryObjectsWithSpecificFields(
      new Set<Id> { objectId }, fieldsToQuery);

    return (results.isEmpty()) ? null : results[0];
  }

  global static List<SObject> queryObjectsWithSpecificFields(Set<Id> objectIds,
      Set<String> fieldsToQuery) {
    if (objectIds == null || objectIds.isEmpty() || fieldsToQuery == null ||
        fieldsToQuery.isEmpty()) {
      return null;
    }

    Schema.SObjectType objectType = new List<Id>(objectIds)[0].getSObjectType();

    String query = generateQuery(getFieldStringFromSet(fieldsToQuery),
      objectType, ID_FIELD);

    return Database.query(query);
  }

  global static List<SObject> queryObjects(Set<Id> objectIds,
      Set<String> additionalFields) {
    if (objectIds == null || objectIds.isEmpty()) {
      return null;
    }

    Schema.SObjectType objectType = new List<Id>(objectIds)[0].getSObjectType();

    String query = generateQuery(
      getFieldNames(objectType, additionalFields), objectType, ID_FIELD);

    return Database.query(query);
  }

  global static List<SObject> queryObjectsByRelationship(
      Schema.SObjectType objectType, String relationshipFieldName,
        Set<Id> objectIds) {
    return queryObjectsByRelationship(objectType, relationshipFieldName,
      objectIds, null, null, null);
  }

  global static List<SObject> queryObjectsByRelationship(
      Schema.SObjectType objectType, String relationshipFieldName,
        Set<Id> objectIds, Set<String> additionalFields) {
    return queryObjectsByRelationship(objectType, relationshipFieldName,
      objectIds, additionalFields, null, null);
  }

  global static List<SObject> queryObjectsByRelationship(
      Schema.SObjectType objectType, String relationshipFieldName,
        Set<Id> objectIds, Set<String> additionalFields, String orderByField,
          String orderByDirection) {
    if (objectType == null || String.isBlank(relationshipFieldName) ||
        objectIds == null || objectIds.isEmpty()) {
      return null;
    }

    String query = generateQuery(getFieldNames(objectType, additionalFields),
      objectType, relationshipFieldName, orderByField, orderByDirection);

    return Database.query(query);
  }

  global static List<String> getFieldListByObjectType(Schema.SObjectType ot) {
    if (ot == null) {
      return null;
    }

    Set<String> allFields = new Set<String>(
      ot.getDescribe().fields.getMap().keySet());

    return new List<String>(allFields);
  }

  private static String getFieldNamesFromFieldSets(
      Schema.SObjectType objectType, List<String> fieldSetNames) {
    Schema.FieldSet fs;
    Set<String> fieldNames = new Set<String>();
    List<Schema.FieldSetMember> currentMembers;
    Map<String, Schema.FieldSet> fsMap =
      objectType.getDescribe().fieldSets.getMap();

    for (String fsn : fieldSetNames) {
      fs = getFieldSetByName(fsn, fsMap);

      if (fs == null) {
        continue;
      }

      currentMembers = fs.getFields();

      for (Schema.FieldSetMember m : currentMembers) {
        fieldNames.add(m.getFieldPath());
      }
    }

    if (fieldNames.isEmpty()) {
      return null;
    }

    return String.join(new List<String>(fieldNames), FIELD_SEPARATOR);
  }

  private static String getFieldNames(
      Schema.SObjectType objectType, Set<String> additionalFields) {
    Set<String> allFields = new Set<String>(
      objectType.getDescribe().fields.getMap().keySet());

    if (additionalFields != null) {
      allFields.addAll(additionalFields);
    }

    allFields = setToLowerCase(allFields);

    return String.join(new List<String> (allFields), FIELD_SEPARATOR);
  }

  private static String generateQuery(String fieldNames,
      Schema.SObjectType objectType, String comparisonField) {
    return generateQuery(fieldNames, objectType, comparisonField, null, null);
  }

  private static String generateQuery(String fieldNames,
      Schema.SObjectType objectType, String comparisonField,
        String orderByField, String orderByDirection) {
    return String.format(QUERY_TEMPLATE, new List<String> { fieldNames,
      objectType.getDescribe().getName(), comparisonField,
        generateOrderByString(orderByField, orderByDirection) });
  }

  private static Schema.FieldSet getFieldSetByName(String fsName,
      Map<String, Schema.FieldSet> fsMap) {
    if (fsMap.containsKey(fsName)) {
      return fsMap.get(fsName);
    }

    for (Schema.FieldSet fs : fsMap.values()) {
      if (fsName == fs.getName()) {
        return fs;
      }
    }

    return null;
  }

  private static String generateOrderByString(String orderbyField,
      String orderByDirection) {
    if (String.isBlank(orderByField)) {
      return '';
    }

    String obd = (String.isBlank(orderByDirection)) ?
      ORDER_BY_ASC : orderByDirection;

    return String.format(ORDER_BY_TEMPLATE, new List<String> {
      orderByField, obd });
  }

  private static String generateComparisonString(Map<String, String> cMap) {
    Integer counter = 0;
    String cc;
    List<String> comparisonStrings = new List<String>();

    for (String fn : cMap.keySet()) {
      cc = String.format(COMPARISON_TEMPLATE,
        new List<String> { fn, cMap.get(fn) });

      comparisonStrings.add(
        (counter == 0) ?
          cc : String.format(AND_TEMPLATE, new List<String> { cc }));

      counter++;
    }

    return String.join(comparisonStrings, SPACE);
  }

  private static String getFieldStringFromSet(Set<String> fields) {
    List<String> fList = new List<String>(fields);

    return String.join(fList, FIELD_SEPARATOR);
  }

  private static Set<String> setToLowerCase(Set<String> input) {
    Set<String> output = new Set<String>();

    for (String s : input) {
      output.add(s.toLowerCase());
    }

    return output;
  }
}