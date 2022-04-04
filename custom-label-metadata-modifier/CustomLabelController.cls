/**
 * @description Custom Label Controller used by Flow to get and return Custom Labels using the Tooling API
 * @author Simon Salvatore, Traction on Demand
 * @date March 17, 2022
 */
public with sharing class CustomLabelController {
    //variables to parse custom label json response
    public List<records> records;
    class records {
        public String Id;
        public String MasterLabel;
        public String Name;
        public String Category;
        public String Value;
    }

    /**
     * @description Invocable method called from a Flow to retrieve and then return specified custom labels
     * @param inputParameters Parameters sent in from the Flow
     *
     * @return customLabels - List of the custom labels
     */
    @InvocableMethod(Label='Get_CustomLabels' Description='Gets all Custom Labels with the provided developer names')
    public static List<List<String>> fetchAllCustomLabel(List<String> inputParameters) {
        String finalCSVString = '';
        String queryStr = buildQueryString(inputParameters);
        String masterLabel, name, value, category;

        CustomLabelController completeWrapper = calloutForCustomLabels(queryStr);

        List<String> customLabels = new List<String>();
        for (records rec : completeWrapper.records) {
            masterLabel = rec.MasterLabel;
            name = rec.Name;
            category = rec.Category;
            value = rec.Value;
            name = name.escapeCsv();
            if (value.contains('"') || value.contains('{') || value.contains('}')) {
                value = value.replaceAll('[^a-zA-Z0-9\\s+]', '');
                value = value.replaceAll('/"', '');
            }
            if (category != null) {
                category = category.escapeCsv();
            }
            finalCSVString = '{"Id": ' + '\"' + rec.Id + '\"' + ', "MasterLabel": ' + '\"' + masterLabel + '\"' + ', "Name": ' + '\"' + name + '\"' + ', "Category": ' + '\"' + category + '\"' + ', "Value": ' + '\"' + value + '\"' + '}';
            customLabels.add(finalCSVString);
        }

        return new List<List<String>>{
                customLabels
        };
    }

    /**
     * @description Method to build the query string to be used for retrieving custom labels
     * @param inputParameters Input parameters from the Flow
     *
     * @return queryStr - The build query string
     */
    private static String buildQueryString(List<String> inputParameters) {
        String developerName;
        String category;
        String queryStr = 'SELECT Id,MasterLabel,Name,Value,Category FROM CustomLabel';

        if (inputParameters != null && inputParameters[0] != '') {
            developerName = inputParameters[0].substring(0, inputParameters[0].indexOf(','));
            category = inputParameters[0].substring(inputParameters[0].indexOf(','));
            category = category.replaceFirst(',', '');

            if (developerName != '' && category != '') {
                queryStr = 'SELECT Id,MasterLabel,Name,Category,Value FROM CustomLabel WHERE Name LIKE \'%' + developerName + '%\' AND Category = \'' + category + '\'';
            } else if (developerName != '') {
                queryStr = 'SELECT Id,MasterLabel,Name,Category,Value FROM CustomLabel WHERE Name LIKE \'%' + developerName + '%\'';
            } else if (category != '') {
                queryStr = 'SELECT Id,MasterLabel,Name,Category,Value FROM CustomLabel WHERE Category = \'' + category + '\'';
            }
        }

        return queryStr;
    }

    /**
     * @description Method to callout using the Tooling API to retrieve the custom labels
     * @param queryStr The query string that was previously built
     *
     * @return completeWrapper - The complete wrapper containing the results from the custom label callout
     */
    private static CustomLabelController calloutForCustomLabels(String queryStr) {
        String ENDPOINT = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/data/v52.0/tooling/';

        HttpRequest req = new HttpRequest();

        req.setEndpoint(ENDPOINT + 'query/?q=' + EncodingUtil.urlEncode(queryStr, 'UTF-8'));
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(80000);

        Http http = new Http();
        HttpResponse res = http.send(req);
        String responseBody = res.getBody();


        CustomLabelController completeWrapper = (CustomLabelController) System.JSON.deserialize(responseBody, CustomLabelController.class);
        responseBody = null; //make this variable as null to free up heap memory allocation
        res = null;

        return completeWrapper;
    }
}