@isTest
private class ObjectDescribeUtilsTest {
	
  static testMethod void testObjectDescribe() {

    System.assertEquals(null, ObjectDescribeUtils.getDescribeInfoForObject(
      Account.SObjectType.getDescribe().getName()));

    FSF_Settings__c settings = TestUtils.createFSFSettings('test');
    insert settings;

    Test.startTest();

    System.assertEquals(null,
      ObjectDescribeUtils.getDescribeInfoForObject(null));

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('AccountDescribe');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/json');

    Test.setMock(HttpCalloutMock.class, mock);

    SObjectDescribe sod = ObjectDescribeUtils.getDescribeInfoForObject(
      Account.SObjectType.getDescribe().getName());
    System.assertNotEquals(null, sod);

    for (SObjectDescribe.Field f : sod.fields) {
      System.assertNotEquals(null, f.name);
      System.assertNotEquals(null, f.label);

      for (SObjectDescribe.PicklistValue plv : f.picklistValues) {
        System.assertNotEquals(null, plv.value);
        System.assertNotEquals(null, plv.label);
        System.debug(plv.validFor);
      }
    }



    Test.stopTest();
  }
}