public with sharing class ObjectDescribeUtils {
  
  public static final Integer BATCH_SIZE = 1;

  private static final String METHOD_GET = 'GET';
  private static final String LAYOUT_ENDPOINT_TEMPLATE =
    'callout:{0}/services/data/v28.0/sobjects/{1}/describe';
  private static final Integer STATUS_CODE_OK = 200;

  public static SObjectDescribe getDescribeInfoForObject(String objectName) {
    if (String.isBlank(objectName)) {
      return null;
    }

    JSONParser parser;
    FSF_Settings__c settings = FSF_Settings__c.getInstance();
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    HttpResponse response;

    if (String.isBlank(settings.Credential_Name__c)) {
      return null;
    }

    request.setEndpoint(String.format(LAYOUT_ENDPOINT_TEMPLATE,
      new List<String> { settings.Credential_Name__c, objectName }));
    request.setMethod(METHOD_GET);

    response = http.send(request);

    if (response.getStatusCode() != STATUS_CODE_OK) {
      return null;
    }

    System.debug(response.getBody());

    parser = JSON.createParser(response.getBody());

    return (SObjectDescribe) parser.readValueAs(SObjectDescribe.class);
  }
}