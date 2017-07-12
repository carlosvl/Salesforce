@isTest
public with sharing class TestUtils {

  private static Integer uniqueNumber = 0;

  public static Account createAccount() {
    return new Account(
      Name = 'Test' + getUnique());
  }


  public static FSF_Settings__c createFSFSettings(String cName) {
    return new FSF_Settings__c(
      Credential_Name__c = cName);
  }

   public static Application_Display_Field_Logic__c
      createApplicationDisplayLogic(
        String objectName, String controllingField, String dependedField,
          String values) {
    return new Application_Display_Field_Logic__c(
      ControllingField_Object__c = objectName,
      ControllingField_API__c = controllingField,
      DependentField_API__c = dependedField,
      ControllingField_Value__c = values,
      Controlling_Field_Match_Type__c = 'Equals',
      Controlling_Field_Type__c = 'Text/Picklist');
  }

  public static String getUnique() {
    return String.valueOf(uniqueNumber++) + '_' + System.now().millisecond();
  }
}