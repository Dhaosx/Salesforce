/**
 * @description Helper class to get the Apex Code Coverage using the tooling API
 * @author Simon Salvatore, Traction on Demand
 * @date November 25, 2020
 */
public class trac_CodeCoverageHelper {
    private static BatchClassConfiguration__c batchClassConfiguration = BatchClassConfiguration__c.getInstance();

    @Future(Callout=true)
    public static void futureGetCodeCoverage() {
        getCodeCoverage();
    }

    public static void getCodeCoverage() {
        Map<String, Decimal> resultMap = new Map<String, Decimal>();

        String queryStr = 'SELECT+NumLinesCovered,ApexClassOrTriggerId,ApexClassOrTrigger.Name,NumLinesUncovered,Coverage+FROM+ApexCodeCoverageAggregate+ORDER+BY+ApexClassOrTrigger.Name';

        String ENDPOINT = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v40.0/tooling/';

        HttpRequest req = new HttpRequest();

        req.setEndpoint(ENDPOINT + 'query/?q=' + queryStr);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(80000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            trac_CodeCoverageWrapper codeCoverageWrapper = trac_CodeCoverageWrapper.parse(res.getBody());

            for (trac_CodeCoverageWrapper.Records records : codeCoverageWrapper.records) {

                String classOrTriggerName = records.ApexClassOrTrigger.Name;
                Decimal numLinesCovered = records.NumLinesCovered;
                Decimal numLinesUncovered = records.NumLinesUncovered;
                Decimal totalNumberOfLines = numLinesCovered + numLinesUncovered;

                if (totalNumberOfLines == 0) continue;

                Decimal coveragePercentage = (numLinesCovered / totalNumberOfLines) * 100;

                resultMap.put(classOrTriggerName, coveragePercentage.setScale(2));
            }
        }

        String body = '';

        for (String key : resultMap.keySet()) {
            if (resultMap.get(key) < 75) {
                body += 'Class: ' + key + '\n' + 'Coverage %: ' + resultMap.get(key) + '\n\n';
            }
        }

        try {
            if (batchClassConfiguration.Receiver_Email__c != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[]{
                        batchClassConfiguration.Receiver_Email__c
                };

                mail.setToAddresses(toAddresses);
                mail.setSubject('Insufficient Code Coverage Results');
                mail.setPlainTextBody(body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'trac_CodeCoverageBatch Error Message: ' + e.getMessage());
        }
    }
}