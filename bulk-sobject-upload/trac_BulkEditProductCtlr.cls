/**
 * @description Apex controller for trac_BulkEditProduct Aura Component
 * @author Simon Salvatore, Traction on Demand
 * @date November 12, 2020
 */
public with sharing class trac_BulkEditProductCtlr {

    private static final Product_Code_Settings__c productCodeSettings = Product_Code_Settings__c.getOrgDefaults();
    private static Set<String> ADMIN_PROFILE_NAMES = new Set<String>{
            'System Administrator'
    };

    @AuraEnabled
    public static TLAuraResponse getProductFromSearch(String searchFields) {
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            if (searchFields != null) {
                Product2 searchProduct = (Product2) JSON.deserialize(searchFields, Product2.class);

                List<Product2> productList = Database.query(getQueryStringFromSearchProduct(searchProduct));
                response.returnValuesMap.put('productList', productList);
            }
        } catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    private static String getQueryStringFromSearchProduct(Product2 searchProduct) {
        String resultString;

        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Product2');
        queryBuilder.setFields(new List<String>{
                'Id', 'Name', 'Product_Codes__c', 'Group__c', 'Product_Coordinator__c', 'Product_Coordinator__r.Name',
                'Product_Manager__c', 'Product_Manager__r.Name', 'Supplier__c', 'Supplier__r.Name', 'Supplier__r.JD_Edwards_Id__c',
                'Commodity_Code2__c', 'Commodity_Code2__r.Name', 'Commodity_Family2__c', 'Commodity_Family2__r.Name',
                'Product_Coordinator__r.JDE_Address_Book_Number__c', 'Product_Manager__r.JDE_Address_Book_Number__c, Product__c'
        });
        queryBuilder.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);

        if (searchProduct.Product_Codes_Name__c != null && !String.isEmpty(searchProduct.Product_Codes_Name__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Product_Codes__c', TLQueryBuilder.LIKE_OPERATOR, '%' + searchProduct.Product_Codes_Name__c + '%'));
        }
        if (searchProduct.Commodity_Code2__c != null && !String.isEmpty(searchProduct.Commodity_Code2__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Commodity_Code2__c', TLQueryBuilder.EQUALS_OPERATOR, searchProduct.Commodity_Code2__c));
        }
        if (searchProduct.Commodity_Family2__c != null && !String.isEmpty(searchProduct.Commodity_Family2__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Commodity_Family2__c', TLQueryBuilder.EQUALS_OPERATOR, searchProduct.Commodity_Family2__c));
        }
        if (searchProduct.Product__c != null && !String.isEmpty(searchProduct.Product__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Name', TLQueryBuilder.LIKE_OPERATOR, '%' + searchProduct.Product__c + '%'));
        }
        if (searchProduct.Product_Coordinator__c != null && !String.isEmpty(searchProduct.Product_Coordinator__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Product_Coordinator__c', TLQueryBuilder.EQUALS_OPERATOR, searchProduct.Product_Coordinator__c));
        }
        if (searchProduct.Product_Manager__c != null && !String.isEmpty(searchProduct.Product_Manager__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Product_Manager__c', TLQueryBuilder.EQUALS_OPERATOR, searchProduct.Product_Manager__c));
        }
        if (searchProduct.Supplier_Name__c != null && !String.isEmpty(searchProduct.Supplier_Name__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Supplier__r.Name', TLQueryBuilder.LIKE_OPERATOR, '%' + searchProduct.Supplier_Name__c + '%'));
        }
        if (searchProduct.JD_Edwards_Id__c != null && !String.isEmpty(searchProduct.JD_Edwards_Id__c)) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Supplier__r.JD_Edwards_Id__c', TLQueryBuilder.LIKE_OPERATOR, '%' + searchProduct.JD_Edwards_Id__c + '%'));
        }

        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('RecordTypeId', TLQueryBuilder.EQUALS_OPERATOR, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Profile')));
        queryBuilder.setLimit(1000);

        resultString = queryBuilder.build();

        return resultString;
    }

    @AuraEnabled
    public static TLAuraResponse updateProductRecords(String productRecords) {
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            if (productRecords != null) {
                List<Product2> productRecordsToUpdate = (List<Product2>) JSON.deserialize(productRecords, List<Product2>.class);

                List<Database.SaveResult> saveResult = Database.update(productRecordsToUpdate, true);

                response.returnValuesMap.put('recordCount', saveResult.size());
            }
        } catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    @AuraEnabled
    public static Integer getMaxRowSelection() {
        Integer maxRowSelection = productCodeSettings.MaxRowSelection__c.intValue();

        return maxRowSelection;
    }
}