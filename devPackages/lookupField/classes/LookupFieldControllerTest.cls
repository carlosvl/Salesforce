@isTest
private class LookupFieldControllerTest {
	
  static testMethod void testLookupFieldController() {
    Account a = TestUtils.createAccount();
    insert a;

    Contact c = TestUtils.createContact(a.Id);
    insert c;

    Test.startTest();

    System.assertEquals(null, LookupFieldController.getReferenceObject(null));

    Account testAccount = (Account)
      LookupFieldController.getReferenceObject(c.AccountId);

    System.assertEquals(a.Id, testAccount.Id);

    System.assertEquals(null,
      LookupFieldController.getLookupSearchResults(null, null));

    List<Account> aList = LookupFieldController.getLookupSearchResults(
      'Test', Account.SObjectType.getDescribe().getName());

    System.assertEquals(1, aList.size());

    Test.stopTest();
  }
}