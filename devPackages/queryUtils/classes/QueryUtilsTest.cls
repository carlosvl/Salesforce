@isTest
private class QueryUtilsTest {

  private static Map<Id, Account> accounts;

  static testMethod void testQueryUtils() {
    initTestData();

    Test.startTest();

    System.assertEquals(null, QueryUtils.queryObject(null));
    System.assertEquals(null, QueryUtils.queryObjects(null));
    System.assertEquals(null, QueryUtils.queryObjects(new Set<Id>()));
    System.assertEquals(null, QueryUtils.queryObjectFromFieldSets(null, null));
    System.assertEquals(null, QueryUtils.queryObjectsFromFieldSets(null, null));
    System.assertEquals(null, QueryUtils.queryObjectsWithOrder(
      null, null, null, null));

    Account a = accounts.values()[0];

    System.assertEquals(null, QueryUtils.queryObjectFromFieldSets(
      a.Id, new List<String>()));
    System.assertEquals(null, QueryUtils.queryObjectsFromFieldSets(
      accounts.keySet(), new List<String>()));

    Account testAccount = (Account) QueryUtils.queryObject(a.Id);

    System.assertEquals(a.Id, testAccount.Id);

    List<Account> testAccountList = QueryUtils.queryObjects(accounts.keySet());

    System.assertEquals(accounts.size(), testAccountList.size());

    for (Account acc : testAccountList) {
      System.assertEquals(true, accounts.containsKey(acc.Id));
    }

    testAccountList = QueryUtils.queryObjectsWithOrder(accounts.keySet(), null,
      'Name', 'asc');

    System.assertEquals(accounts.size(), testAccountList.size());

    for (Account acc : testAccountList) {
      System.assertEquals(true, accounts.containsKey(acc.Id));
    }

    System.assertEquals(null, QueryUtils.queryObjectsWithSpecificFields(
      accounts.keySet(), new Set<String>()));
    System.assertEquals(null, QueryUtils.queryObjectWithSpecificFields(
      a.Id, new Set<String>()));

    testAccount = (Account) QueryUtils.queryObjectWithSpecificFields(
      a.Id, new Set<String> { 'Id', 'Name' });

    System.assertEquals(a.Id, testAccount.Id);

    testAccount = (Account) QueryUtils.queryObjectFromFieldSets(a.Id,
      new List<String> { 'Unit_Test', 'Random' + Datetime.now().getTime() });

    System.assertEquals(a.Id, testAccount.Id);

    System.assertEquals(null, QueryUtils.getFieldListByObjectType(null));
    List<String> fields = QueryUtils.getFieldListByObjectType(
      Account.SObjectType);

    System.assertNotEquals(true, fields.isEmpty());

    System.assertEquals(null, QueryUtils.queryObjectsByRelationship(
      Contact.SObjectType, 'AccountId', new Set<Id>()));

    List<Contact> contacts = QueryUtils.queryObjectsByRelationship(
      Contact.SObjectType, 'AccountId', accounts.keySet(),
        new Set<String> { 'Account.Name' }, 'CreatedDate', 'desc');

    System.assertEquals(100, contacts.size());

    Id testId;

    System.assertEquals(null, QueryUtils.queryObjectsByRelationship(
      Contact.SObjectType, 'AccountId', testId));

    contacts = QueryUtils.queryObjectsByRelationship(Contact.SObjectType,
      'AccountId', a.Id);

    System.assertEquals(10, contacts.size());

    System.assertEquals(null, QueryUtils.queryObjectsByRelationshipAndFieldSets(
      null, null, testId, null, null, null));
    System.assertEquals(null, QueryUtils.queryObjectsByRelationshipAndFieldSets(
      null, null, new Set<Id>(), null, null, null));

    contacts = QueryUtils.queryObjectsByRelationshipAndFieldSets(
      Contact.SObjectType, 'AccountId', a.Id, null, null,
        new List<String> { 'Unit_Test' });

    System.assertEquals(10, contacts.size());

    Map<String, String> searchMap =
      new Map<String, String> { 'Name' => 'Test' };

    testAccountList = (List<Account>) QueryUtils.searchObject(
      Account.SObjectType, 'Name', 'asc', searchmap, null);

    System.assertEquals(null, QueryUtils.searchObject(
      null, null, null, null, null));

    System.assertEquals(accounts.size(), testAccountList.size());

    System.assertEquals(null, QueryUtils.queryAll(null, null, null, null));
    testAccountList = QueryUtils.queryAll(Account.SObjectType, null,
      'Name', 'asc');

    System.assertEquals(accounts.size(), testAccountList.size());

    Test.stopTest();
  }

  private static void initTestData() {
    List<Account> aList = new List<Account>();

    for (Integer i = 0; i < 10; i++) {
      aList.add(TestUtils.createAccount());
    }

    insert aList;

    accounts = new Map<Id, Account>(aList);

    List<Contact> contacts = new List<Contact>();

    for (Account a : aList) {
      for (Integer i = 0; i < 10; i++) {
        contacts.add(TestUtils.createContact(a.Id));
      }
    }

    insert contacts;
  }
}