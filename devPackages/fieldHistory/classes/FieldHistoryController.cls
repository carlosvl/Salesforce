public with sharing class FieldHistoryController {

  private static final String STANDARD_HISTORY_TEMPLATE = '{0}History';
  private static final String CUSTOM_HISTORY_SUFFIX = '__History';
  private static final String PARENT_ID_TEMPLATE = '{0}Id';
  private static final String U_C = '__c';
  private static final String PARENT_ID = 'ParentId';
  private static final String CREATED_BY_NAME = 'CreatedBy.Name';
  private static final String CREATED_DATE = 'CreatedDate';
  private static final String ORDER_DIRECTION_DESC = 'desc';
  private static final String ACTION_TEMPLATE = 'Changed {0}{1}.';
  private static final String CREATED_ACTION = 'Created.';
  private static final String FIELD_CREATED = 'created';

  @AuraEnabled
  public static List<FieldHistory> getHistoryForId(Id recordId) {
    if (String.isBlank(recordId)) {
      return null;
    }

    Schema.DescribeSObjectResult od = recordId.getSobjectType().getDescribe();
    String historyName = (od.isCustom()) ? getCustomHistoryName(od.getName()) :
      String.format(STANDARD_HISTORY_TEMPLATE,
        new List<String> { od.getName() });
    String relationshipName = (od.isCustom()) ? PARENT_ID :
      String.format(PARENT_ID_TEMPLATE, new List<String> { od.getName() });
    List<SObject> histories;
    List<FieldHistory> fHistories = new List<FieldHistory>();

    histories = qutils.QueryUtils.queryObjectsByRelationship(
      getSObjectTypeByName(historyName), relationshipName, recordId,
        new Set<String> { CREATED_BY_NAME }, CREATED_DATE,
          ORDER_DIRECTION_DESC);

    for (SObject h : histories) {
      fHistories.add(new FieldHistory(h, od));
    }

    return fHistories;
  }

  private static String getCustomHistoryName(String objectName) {
    return objectName.replace(U_C, CUSTOM_HISTORY_SUFFIX);
  }

  private static Schema.SObjectType getSObjectTypeByName(String objectName) {
    return Schema.getGlobalDescribe().get(objectName);
  }
}