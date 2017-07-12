public with sharing class TestUtils {
  
  private static Integer uniqueNumber = 0;

  public static Account createAccount() {
    return new Account(
      Name = 'Test' + getUnique());
  }

  public static Contact createContact(Id accountId) {
    return new Contact(
      FirstName = 'Test' + getUnique(),
      LastName = 'Test' + getUnique(),
      AccountId = accountId);
  }

  public static String getUnique() {
    return String.valueOf(uniqueNumber++) + '_' + System.now().millisecond();
  }
}