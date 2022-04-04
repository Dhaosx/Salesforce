/**
 * @description Apex class to handle logic for the customer lookup component
 * @author Simon Salvatore, Traction on Demand
 * @date July 29, 2019
 */
public without sharing class trac_LookupController {
    @AuraEnabled
    public static List<SObject> getLookUpValues(String searchKeyWord, String ObjectName, String recordType, String description) {
        String searchKey = searchKeyWord + '%';

        List<SObject> returnList = new List<SObject>();

        if (!String.isEmpty(description)) {
            description = ',' + description;
        }

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String query;

        if (ObjectName == 'User') {
            query = 'SELECT Id, Name' + description + ' FROM ' + ObjectName + ' WHERE Name LIKE :searchKey AND JDE_Address_Book_Number__c != NULL';
        } else {
            query = 'SELECT Id, Name' + description + ' FROM ' + ObjectName + ' WHERE Name LIKE :searchKey';
        }

        if (recordType != null && recordType != '') {
            query += ' AND RecordType.Name =: recordType';
        }

        query += ' ORDER BY createdDate DESC LIMIT 5';

        List<SObject> lstOfRecords = Database.query(query);

        for (SObject obj : lstOfRecords) {
            returnList.add(obj);
        }

        return returnList;
    }
}