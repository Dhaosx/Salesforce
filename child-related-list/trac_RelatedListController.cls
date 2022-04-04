/**
* @description  Class handling SOBject Child Related Lists
* @author       Simon Salvatore, Traction on Demand
* @date         2020-02-12
**/

public without sharing class trac_RelatedListController {

    @AuraEnabled
    public static List<SObject> getRelatedChildren(Id recordId, String sObjectName, String queryFilter, String fieldList, String searchKey, String secondSearch) {
        Set<Id> accountIds = getRelatedChildIds(recordId);

        if(fieldList.contains('Industry_picklist__c')) {
            fieldList = fieldList.replace('Industry_picklist__c','toLabel(Industry_picklist__c)');
        }

        String sQuery = 'SELECT Id,' + fieldList + ' FROM ' + sObjectName + ' WHERE ' + searchKey + ' IN: accountIds' + (queryFilter.trim() == '' ? '' : ' AND (' + queryFilter + ')');

        if (!String.isEmpty(secondSearch)) {
            sQuery += ' OR ' + secondSearch + ' IN: accountIds';
        }

        List<SObject> childAccountRelatedRecords = Database.query(sQuery);

        return childAccountRelatedRecords;
    }

    @AuraEnabled
    public static Boolean deleteRelatedRecord(Id recordId) {
        SObject sobj = recordId.getSobjectType().newSObject(recordId);
        // got record, now delete
        try {
            delete sobj;
        } catch (DmlException e) {
            return false;
        }

        return true;
    }

    private static Set<Id> getRelatedChildIds(Id parentId) {
        List<Account> childAccounts = new List<Account>();

        childAccounts = [SELECT Id FROM Account WHERE ParentId = :parentId];

        Set<Id> accountIds = trac_Utils.extractIdFromList(childAccounts, Account.Id);

        return accountIds;
    }
}