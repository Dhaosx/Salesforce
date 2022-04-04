/**
 * @description Unit test class for the Bulk DPL Upload Controller
 * @author Simon Salvatore, Traction on Demand
 * @date September 30, 2020
 */
@IsTest
private class trac_BulkDPLUploadCtlrTest {
    @IsTest
    static void testCreateRecordsFromData() {
        String tabDelimitedInput = 'Product__c\tBranch_lookup__c\tIndustry__c\tLead_Time__c\tUOM__c\tQuantity__c\tPricing__c\tPrice_Currency__c\tStocked__c\tEffective_Date__c\tExpiry_Date__c\n' +
                '01t5A000008dgF9QAI\ta0S0t000001L5DhEAK\tBM\t20 days\tKG\t100\t0.01\tCAD\tY\t2020-08-25\t2021-08-25';
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Value Map for the Response should be empty before loading the records');

        Test.startTest();
        response = trac_BulkDPLUploadCtlr.createRecordsFromData(tabDelimitedInput);
        Test.stopTest();

        System.assertNotEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Value Map for the Response should not be empty after loading the records');
    }

    @IsTest
    static void testCreateDPLRecords() {
        String dplRecord = '[{"Branch_Name__c":"a0S0t000001L5DhEAK","Pricing__c":0.01,"Effective_Date__c":"2020-08-25","Product_Name__c":"01t5A000008dgF9QAI","Lead_Time__c":"20 days","Industry__c":"BM","Quantity__c":100,"Price_Currency__c":"CAD","UOM__c":"KG","Product__c":"01t5A000008dgF9QAI","Stocked__c":"Y","Expiry_Date__c":"2021-08-25","Branch_lookup__c":"a0S0t000001L5DhEAK"}]';
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Value Map for the Response should be empty before creating the records');

        Test.startTest();
        response = trac_BulkDPLUploadCtlr.createDPLRecords(dplRecord);
        Test.stopTest();

        System.assertNotEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Value Map for the Response should not be empty after creating the records');
    }

    @IsTest
    static void testCreateDPLRecordsWithError() {
        String dplRecord = '[{"Branch_Name__c":"x","Pricing__c":0.01,"Effective_Date__c":"2020-08-25","Product_Name__c":"x","Lead_Time__c":"20 days","Industry__c":"BM","Quantity__c":100,"Price_Currency__c":"CAD","UOM__c":"KG","Product__c":"x","Stocked__c":"Y","Expiry_Date__c":"2021-08-25","Branch_lookup__c":"a0S0t000001L5DhEAK"}]';
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals('', response.message, 'The Message for the Response should be empty before creating the records');

        Test.startTest();
        response = trac_BulkDPLUploadCtlr.createDPLRecords(dplRecord);
        Test.stopTest();

        System.assertEquals('There was en error saving the records, please review the rows', response.message, 'The Message for the Response should not be empty after creating the records');
    }
}