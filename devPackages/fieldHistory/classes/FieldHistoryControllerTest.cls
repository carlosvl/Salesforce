@isTest(seeAllData=true)
private class FieldHistoryControllerTest {
	
  static testMethod void testFieldHistoryController() {

    Test_Settings__c settings = Test_Settings__c.getInstance();
    Id accountId = settings.Test_Account_Id__c;

    Test.startTest();

    FieldHistoryController.getHistoryForId(accountId);

    Test.stopTest();
  }
}