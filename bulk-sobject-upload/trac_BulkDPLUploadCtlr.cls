/**
 *  @description Apex controller for trac_BulkDPLUpload Aura Component
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        8/20/2020
 */
public with sharing class trac_BulkDPLUploadCtlr {

    private static final String ROW_DELIMITER = '\n';
    private static final String CELL_DELIMITER = '\t';

    @AuraEnabled
    public static TLAuraResponse createRecordsFromData(String tabDelimitedInput) {
        System.debug('TRAC=======================> CHECK0');
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            List<Base_Price__c> dplList = new List<Base_Price__c>();

            System.debug('TRAC=======================> CHECK1');
            if (tabDelimitedInput != null) {
                List<Map<String, String>> dplRecordMappings = getDplRecordMappingsFromInput(tabDelimitedInput);
                dplList = getDPLRecordsFromMap(dplRecordMappings);
            }

            response.returnValuesMap.put('dplList', dplList);
        } catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    @AuraEnabled
    public static TLAuraResponse createDPLRecords(String dplRecords) {
        TLAuraResponse response = new TLAuraResponse(true);
        Boolean hasError = false;
        Integer value = 0;

        if (dplRecords != null) {
            List<Base_Price__c> dplRecordsToUpdate = (List<Base_Price__c>) JSON.deserialize(dplRecords, List<Base_Price__c>.class);

            Savepoint sp = Database.setSavepoint();
            List<Database.SaveResult> saveResult = Database.insert(dplRecordsToUpdate, false);
            for (Database.SaveResult sr : saveResult) {
                if (sr != null) {
                    if (!sr.isSuccess()) {
                        hasError = true;
                        response.returnValuesMap.put(value, true);
                    } else {
                        response.returnValuesMap.put(value, false);
                    }
                    value++;
                }
            }

            if (hasError) {
                response.isSuccess = false;
                response.message = 'There was en error saving the records, please review the rows';
                Database.rollback(sp);
            } else {
                response.returnValuesMap.put('recordCount', saveResult.size());
            }
        }

        return response;
    }

    @AuraEnabled
    public static External_Links__c getCustomExternalSetting() {
        return External_Links__c.getInstance();
    }

    private static List<Map<String, String>> getDplRecordMappingsFromInput(String tabDelimitedInput) {
        System.debug('TRAC=======================> CHECK2');
        List<Map<String, String>> dplRecordMappings = new List<Map<String, String>>();

        if (tabDelimitedInput != null) {
            List<String> rows = tabDelimitedInput.split(ROW_DELIMITER);
            if (rows != null && !rows.isEmpty()) {
                List<String> columns = rows[0].split(CELL_DELIMITER);
                for (Integer i = 1; i < rows.size(); i++) {
                    Map<String, String> dplMapping = new Map<String, String>();
                    List<String> cells = rows[i].split(CELL_DELIMITER);
                    for (Integer j = 0; j < cells.size(); j++) {
                        dplMapping.put(columns[j], cells[j]);
                    }
                    dplRecordMappings.add(dplMapping);
                }
            }
        }

        return dplRecordMappings;
    }

    private static List<Base_Price__c> getDPLRecordsFromMap(List<Map<String, String>> dplRecordMappings) {
        System.debug('TRAC=======================> CHECK3');
        List<Base_Price__c> dplRecords = new List<Base_Price__c>();

        System.debug(JSON.serializePretty(dplRecordMappings));

        List<DPL_Bulk_Upload_Mapping__mdt> bulkUploadMappings = getBulkUploadHeaderMappings();
        Map<String, String> headerValuesToApiNames = getHeaderValuesToApiNames(bulkUploadMappings);

        Map<String, String> industryPicklistValuesByLabel = getPicklistValuesByLabel('Base_Price__c', 'Industry__c');
        Map<String, String> stockedPicklistValuesByLabel = getPicklistValuesByLabel('Base_Price__c', 'Stocked__c');

        Set<String> productCodes = new Set<String>();
        Set<String> branchIds = new Set<String>();

        Map<String, Product2> productsByCode = new Map<String, Product2>();
        Map<String, Branches__c> branchByBranchId = new Map<String, Branches__c>();

        for (Map<String, String> dplMapping : dplRecordMappings) {
            for (String header : dplMapping.keySet()) {
                if (headerValuesToApiNames.containsKey(header)) {
                    dplMapping.put(headerValuesToApiNames.get(header), dplMapping.get(header));
                }
            }

            for (String header : dplMapping.keySet()) {//TODO: move this to a method and pass in a list of fields if the number of fields grows?
                if (header == 'Industry__c' && industryPicklistValuesByLabel.containsKey(dplMapping.get(header))) {
                    dplMapping.put('Industry__c', industryPicklistValuesByLabel.get(dplMapping.get(header)));
                }
                if (header == 'Stocked__c' && stockedPicklistValuesByLabel.containsKey(dplMapping.get(header))) {
                    dplMapping.put('Stocked__c', stockedPicklistValuesByLabel.get(dplMapping.get(header)));
                }
                if (header == 'Product__c') {
                    productCodes.add(dplMapping.get(header));
                }
                if (header == 'Branch_lookup__c') {
                    branchIds.add(dplMapping.get(header));
                }
            }
        }

        List<Product2> products = getProductsByCodes(productCodes);
        for (Product2 product : products) {
            productsByCode.put(product.Product_Codes__c, product);
        }
        List<Branches__c> branches = getBranchesByBranchIds(branchIds);
        for (Branches__c branche : branches) {
            branchByBranchId.put(branche.Branch_Id__c, branche);
        }

        for (Map<String, String> dplMapping : dplRecordMappings) {
            for (String header : dplMapping.keySet()) {
                if (header == 'Product__c') {
                    if (productsByCode.containsKey(dplMapping.get(header))) {
                        dplMapping.put('Product_Name__c', productsByCode.get(dplMapping.get(header)).Name.left(40));
                        dplMapping.put('Product__c', productsByCode.get(dplMapping.get(header)).Id);
                    } else {
                        dplMapping.put('Product_Name__c', dplMapping.get(header).left(40));
                    }
                }
                if (header == 'Branch_lookup__c') {
                    if (branchByBranchId.containsKey(dplMapping.get(header))) {
                        dplMapping.put('Branch_Name__c', branchByBranchId.get(dplMapping.get(header)).Name);
                        dplMapping.put('Branch_lookup__c', branchByBranchId.get(dplMapping.get(header)).Id);
                    } else {
                        dplMapping.put('Branch_Name__c', dplMapping.get(header));
                    }
                }
            }
            dplRecords.add((Base_Price__c) JSON.deserialize(JSON.serialize(dplMapping), Base_Price__c.class));
        }


        return dplRecords;
    }

    private static List<DPL_Bulk_Upload_Mapping__mdt> getBulkUploadHeaderMappings() {
        List<DPL_Bulk_Upload_Mapping__mdt> bulkUploadMappings = [
                SELECT Id, Type__c, Spreadsheet_Value__c, Salesforce_Value__c, Field__c
                FROM DPL_Bulk_Upload_Mapping__mdt
                WHERE Type__c = 'Header'
        ];

        return bulkUploadMappings;
    }

    private static Map<String, String> getHeaderValuesToApiNames(List<DPL_Bulk_Upload_Mapping__mdt> bulkUploadMappings) {
        Map<String, String> headerValuesToApiNames = new Map<String, String>();

        for (DPL_Bulk_Upload_Mapping__mdt dplBulkUploadMapping : bulkUploadMappings) {
            headerValuesToApiNames.put(dplBulkUploadMapping.Spreadsheet_Value__c, dplBulkUploadMapping.Field__c);
        }

        return headerValuesToApiNames;
    }

    private static Map<String, String> getPicklistValuesByLabel(String sObjectApiName, String fieldApiName) {
        Map<String, String> picklistValuesByLabel = new Map<String, String>();

        List<Schema.PicklistEntry> picklistEntries = getPicklistEntries(sObjectApiName, fieldApiName);

        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            picklistValuesByLabel.put(picklistEntry.getLabel(), picklistEntry.getValue());
        }

        return picklistValuesByLabel;
    }

    private static List<Schema.PicklistEntry> getPicklistEntries(String sObjectApiName, String fieldApiName) {
        List<Schema.PicklistEntry> picklistEntries = new List<Schema.PicklistEntry>();

        try {
            Map<String, Schema.SObjectField> fieldsByName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();

            Schema.DescribeFieldResult fieldResult = fieldsByName.get(fieldApiName).getDescribe();
            picklistEntries = fieldResult.getPicklistValues();
        } catch (Exception e) {
            System.debug('Error in get picklist values: line' + e.getLineNumber() + ', ' + e.getMessage());
        }

        return picklistEntries;
    }

    private static List<Product2> getProductsByCodes(Set<String> productCodes) {
        List<Product2> products = [
                SELECT Id, Product_Codes__c, Name
                FROM Product2
                WHERE Product_Codes__c IN :productCodes
        ];

        return products;
    }

    private static List<Branches__c> getBranchesByBranchIds(Set<String> branchIds) {
        List<Branches__c> products = [
                SELECT Id, Branch_Id__c, Name
                FROM Branches__c
                WHERE Branch_Id__c IN :branchIds
        ];

        return products;
    }
}