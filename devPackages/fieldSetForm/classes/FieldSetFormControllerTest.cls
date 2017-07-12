@isTest
private class FieldSetFormControllerTest {
	static testMethod void testFieldSetFormController() {
    Application_Display_Field_Logic__c fv =
      TestUtils.createApplicationDisplayLogic(
        Account.SObjectType.getDescribe().getName(), 'FirstName', 'LastName',
          'Evan');
    insert fv;

    Test.startTest();

    System.assertEquals(null,
      FieldSetFormController.getDescribeInfoForObject(null));

    FieldSetFormController.getDescribeInfoForObject(new Account());

    System.assertEquals(null,
      FieldSetFormController.getFieldsForFieldSet(null, null));

    String result = FieldSetFormController.getFieldsForFieldSet(
      new Account(), 'qutils__Unit_Test');

    System.assertNotEquals(null, result);

    Test.stopTest();
  }
}