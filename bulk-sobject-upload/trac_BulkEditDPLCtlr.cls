/**
 *  @description Apex controller for trac_BulkEditDPL Aura Component
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        8/20/2020
 */
public with sharing class trac_BulkEditDPLCtlr {

    private static Set<String> ADMIN_PROFILE_NAMES = new Set<String>{
            'System Administrator'
    };

    @AuraEnabled
    public static TLAuraResponse getDPLFromSearch(String searchFields) {
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            if (searchFields != null) {
                Base_Price__c searchDPL = (Base_Price__c) JSON.deserialize(searchFields, Base_Price__c.class);

                List<Base_Price__c> dplList = Database.query(getQueryStringFromSearchDPL(searchDPL));
                response.returnValuesMap.put('dplList', dplList);
            }
        } catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    private static String getQueryStringFromSearchDPL(Base_Price__c searchDPL) {
        String resultString;

        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Base_Price__c');
        queryBuilder.setFields(new List<String>{
                'Id', 'Name', 'Product__c', 'Product__r.Name', 'CodeLU__c', 'Company__c', 'Pricing__c', 'Price_Currency__c', 'Branch_lookup__c', 'Branch_lookup__r.Name',
                'Effective_Date__c', 'Expiry_Date__c', 'Industry__c', 'Stocked__c', 'Comment__c', 'Lead_Time__c', 'UOM__c', 'Quantity__c'
        });
        queryBuilder.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);

        if (searchDPL.Product__c != null && !String.isEmpty(searchDPL.Product__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Product__c', TLQueryBuilder.EQUALS_OPERATOR, searchDPL.Product__c));
        }
        if (searchDPL.Product_Name__c != null && !String.isEmpty(searchDPL.Product_Name__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Product__r.Name', TLQueryBuilder.LIKE_OPERATOR, '%' + searchDPL.Product_Name__c + '%'));
        }
        if (searchDPL.Supplier__c != null && !String.isEmpty(searchDPL.Supplier__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Product__r.Supplier__c', TLQueryBuilder.EQUALS_OPERATOR, searchDPL.Supplier__c));
        }
        if (searchDPL.Product_Profile__c != null && !String.isEmpty(searchDPL.Product_Profile__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Product__r.Commercial_Product__c', TLQueryBuilder.EQUALS_OPERATOR, searchDPL.Product_Profile__c));
        }
        if (searchDPL.Company_Picklist__c != null && !String.isEmpty(searchDPL.Company_Picklist__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Company__c', TLQueryBuilder.EQUALS_OPERATOR, searchDPL.Company_Picklist__c));
        }
        if (searchDPL.Branch_lookup__c != null && !String.isEmpty(searchDPL.Branch_lookup__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Branch_lookup__c', TLQueryBuilder.EQUALS_OPERATOR, searchDPL.Branch_lookup__c));
        }
        if (searchDPL.Expiry_Date__c != null) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Expiry_Date__c', TLQueryBuilder.EQUALS_OPERATOR, String.valueOf(searchDPL.Expiry_Date__c), 'TypeNumber'));
        }
        if (!isAdminUser()) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Current_User_is_PM_or_PC__c', TLQueryBuilder.EQUALS_OPERATOR, 'true', 'TypeBoolean'));
        }
        queryBuilder.setLimit(1000);

        resultString = queryBuilder.build();

        return resultString;
    }

    private static Boolean isAdminUser() {
        Boolean isAdmin = false;

        Id profileId = UserInfo.getProfileId();

        List<Profile> userProfiles = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
        if (userProfiles.size() == 1) {
            isAdmin = ADMIN_PROFILE_NAMES.contains(userProfiles[0].Name);
        }

        return isAdmin;
    }

    @AuraEnabled
    public static TLAuraResponse updateDPLRecords(String dplRecords) {
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            if (dplRecords != null) {
                List<Base_Price__c> dplRecordsToUpdate = (List<Base_Price__c>) JSON.deserialize(dplRecords, List<Base_Price__c>.class);

                List<Database.SaveResult> saveResult = Database.update(dplRecordsToUpdate, true);

                response.returnValuesMap.put('recordCount', saveResult.size());
            }
        } catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }
}