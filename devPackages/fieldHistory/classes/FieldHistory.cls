public with sharing class FieldHistory {

  private static final String FIELD_FIELD = 'Field';
  private static final String FIELD_CREATED = 'created';
  private static final String NEW_VALUE_FIELD = 'NewValue';
  private static final String OLD_VALUE_FIELD = 'OldValue';
  private static final String CREATED_ACTION = 'Created.';
  private static final String STANDARD_RELATIONSHIP_TEMPLATE = '{0}Id';
  private static final String NEW_ONLY_ACTION =
    'Changed <strong>{0}</strong> to <strong>{1}</strong>.';
  private static final String BOTH_ACTION =
    'Changed <strong>{0}</strong> from {1} to <strong>{2}</strong>.';
  private static final String NEITHER_ACTION = 'Changed <strong>{0}</strong>.';
  private static final String DELETED_ACTION =
    'Deleted {1} in <strong>{0}</strong>.';
  private static final String PERCENT_TEMPLATE = '{0}%';
  private static final String CURRENCY_TEMPLATE = '${0}';
	
  @AuraEnabled
  public String fieldLabel { get; set; }

  @AuraEnabled
  public SObject history { get; set; }

  @AuraEnabled
  public String actionString { get; set; }

  public FieldHistory (SObject h, Schema.DescribeSObjectResult od) {
    if (h == null) {
      return;
    }

    String fieldName = (String) h.get(FIELD_FIELD);
    Schema.DescribeFieldResult fd;

    this.history = h;

    if (fieldName == FIELD_CREATED) {
      this.actionString = CREATED_ACTION;
      return;
    } 

    System.debug(JSON.serialize(od.fields.getMap().keySet()));
    fd = getFieldDescribe(fieldName, od);

    if (fd == null) {
      return;
    }

    this.fieldLabel = fd.getLabel();
    this.actionString = generateActionString(h, fd, fieldName, this.fieldLabel);
  }

  private Schema.DescribeFieldResult getFieldDescribe(String fieldName,
      Schema.DescribeSObjectResult od) {
    Map<String, Schema.SObjectField> fieldMap = od.fields.getMap();

    try {
      return fieldMap.get(fieldName).getDescribe();
    } catch (Exception e1) {
      try {
        return fieldMap.get(String.format(STANDARD_RELATIONSHIP_TEMPLATE,
          new List<String> { fieldName })).getDescribe();
      } catch (Exception e2) {
        return null;
      }
    }
  }

  private String generateActionString(SObject h,
      Schema.DescribeFieldResult fd, String field, String fl) {
    String newValue = getStringFieldValue(fd, h.get(NEW_VALUE_FIELD));
    String oldValue = getStringFieldValue(fd, h.get(OLD_VALUE_FIELD));

    if (newValue instanceof Id || oldValue instanceof Id) {
      return null;
    } else if (field == FIELD_CREATED) {
      return CREATED_ACTION;
    } else if (String.isBlank(oldValue) && String.isNotBlank(newValue)) {
      return String.format(NEW_ONLY_ACTION, new List<String> {
        fl, newValue });
    } else if (String.isNotBlank(oldValue) && String.isNotBlank(newValue)) {
      return String.format(BOTH_ACTION, new List<String> {
        fl, oldValue, newValue });
    } else if (String.isBlank(newValue) && String.isNotBlank(oldValue)) {
      return String.format(DELETED_ACTION, new List<String> { fl, oldValue });
    } else {
      return String.format(NEITHER_ACTION, new List<String> { fl });
    }
  }

  private String getStringFieldValue(Schema.DescribeFieldResult fd, Object o) {
    if (o == null) {
      return null;
    } else if (fd.getType() == Schema.DisplayType.DateTime) {
      return handleDatetime(o);
    } else if (fd.getType()  == Schema.DisplayType.Date) {
      return handleDate(o);
    } else if (fd.getType() == Schema.DisplayType.Percent) {
      return handlePercent(o);
    } else if (fd.getType() == Schema.DisplayType.Currency) {
      return handleCurrency(o);
    } else if (o instanceof Decimal) {
      return formatDecimal((Decimal) o);
    } else {
      return String.valueOf(o);
    }
  }

  private String handleCurrency(Object o) {
    return String.format(CURRENCY_TEMPLATE, new List<String> {
      formatDecimal(Decimal.valueOf((String) o)) });
  }

  private String handlePercent(Object o) {
    return String.format(PERCENT_TEMPLATE, new List<String> {
      formatDecimal((Decimal) o) });
  }

  private String handleDate(Object o) {
    Date d = (Date) o;

    return d.format();
  }

  private String handleDatetime(Object o) {
    Datetime dt = (Datetime) o;

    return dt.format();
  }

  private String formatDecimal(Decimal decimalToFormat) {
    Decimal d = decimalToFormat + 0.001;
    String dString = d.format();
    return dString.substring(0, dString.length() - 1);
  }
}