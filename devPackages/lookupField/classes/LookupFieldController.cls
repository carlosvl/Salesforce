public with sharing class LookupFieldController {

  private static final String QUERY_TEMPLATE =
    'select Id, Name from {0} where Name like :likeTerm order by Name asc limit 100';
  private static final String LIKE_TEMPLATE = '%{0}%';
  private static final String REFERENCE_QUERY_TEMPLATE =
    'select Id, Name from {0} where Id = :referenceId';

  @AuraEnabled
  public static SObject getReferenceObject(Id referenceId) {
    if (String.isBlank(referenceId)) {
      return null;
    }

    String query = String.format(REFERENCE_QUERY_TEMPLATE, new List<String> {
      referenceId.getSobjectType().getDescribe().getName() });

    return Database.query(query);
  }

  @AuraEnabled
  public static List<SObject> getLookupSearchResults(String searchTerm,
      String objectType) {
    if (String.isBlank(searchTerm) || String.isBlank(objectType)) {
      return null;
    }

    String likeTerm = String.format(LIKE_TEMPLATE,
      new List<String> { searchTerm });
    String query = String.format(QUERY_TEMPLATE,
      new List<String> { objectType });

    return Database.query(query);
  }

  @AuraEnabled
  public static String getIconName(Id referenceId) {
    if (String.isBlank(referenceId)) {
      return null;
    }

    List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();

    return null;
  }
}