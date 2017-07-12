@isTest
private class LookupFieldControllerTest {
	static testMethod void testLookupFieldController() {
    Account a = TestUtils.createAccount();
    insert a;

    Test.startTest();

    System.assertEquals(null, LookupFieldController.getLookupSearchResults(
      null, null));

    List<SObject> results = LookupFieldController.getLookupSearchResults(
      a.Name, Account.SObjectType.getDescribe().getName());

    System.assertEquals(1, results.size());

    System.assertEquals(null, LookupFieldController.getLookupObjectById(null));

    String o = LookupFieldController.getLookupObjectById(a.Id);

    System.assertNotEquals(null, o);

    Test.stopTest();
  }
}