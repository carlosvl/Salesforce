public with sharing class SObjectDescribe {
  
  @AuraEnabled
  public List<Field> fields { get; set; }

  public class Field {
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public List<PicklistValue> picklistValues { get; set; }
  }

  public class PicklistValue {
    @AuraEnabled
    public String validFor { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }
  }
}