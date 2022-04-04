/**
 * @description Unit test class for the Bulk Edit DPL Controller
 * @author Simon Salvatore, Traction on Demand
 * @date September 30, 2020
 */
@IsTest
private class trac_BulkEditDPLCtlrTest {
    @TestSetup
    static void setup() {
        Product_Code_Settings__c productCodeSettings = Product_Code_Settings__c.getOrgDefaults();
        insert productCodeSettings;

        Account supplier = trac_TestUtils.createAccounts(1, trac_Constants.ACCOUNT_RECORD_TYPE_IDS.get('Supplier'), false)[0];
        insert supplier;

        Code_Request__c codeRequest = trac_TestUtils.createCodeRequest(1, 'Primary', false)[0];
        insert codeRequest;

        Test.startTest();
        Product2 commercialProduct = trac_TestUtils.createProductsFromRecordType(1, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Profile'), false)[0];
        commercialProduct.Primary_Code_Request__c = codeRequest.Id;
        insert commercialProduct;

        Product2 product = trac_TestUtils.createProductsFromRecordType(1, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Package'), false)[0];
        product.Commercial_Product__c = commercialProduct.Id;
        insert product;

        Branches__c branches = trac_TestUtils.createBranches(1, false)[0];
        insert branches;

        Base_Price__c dpl = trac_TestUtils.createDPLs(1, false, product.Id, branches.Id)[0];
        insert dpl;

        Base_Price__c secondDpl = trac_TestUtils.createDPLs(1, false, product.Id, branches.Id)[0];
        secondDpl.Price__c = 17.99;
        secondDpl.Pricing__c = 24.99;

        insert secondDpl;
        Test.stopTest();
    }
    @IsTest
    static void testGetDPLFromSearch() {
        Product2 product = [SELECT Id FROM Product2 WHERE RecordTypeId = :trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Package')];
        String searchFields = '{"Product_Name__c":"' + product.Id + '","Supplier__c":null,"Product_Profile__c":null,"Company_Picklist__c":null,"Branch_lookup__c":null,"Expiry_Date__c":null}';
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty before searching for DPLs');

        Test.startTest();
        response = trac_BulkEditDPLCtlr.getDPLFromSearch(searchFields);
        Test.stopTest();

        System.assertNotEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should not be empty after searching for DPLs');
    }

    @IsTest
    static void testGetDPLFromSearchError() {
        Product2 product = [SELECT Id FROM Product2 WHERE RecordTypeId = :trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Profile')];
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty before searching for DPLs');

        Test.startTest();
        response = trac_BulkEditDPLCtlr.getDPLFromSearch(product.Id);
        Test.stopTest();

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty since DPLs are relate to Package Products not Profile');
    }

    @IsTest
    static void testUpdateDPLRecords() {
        List<Base_Price__c> dplRecordsToUpdate = [SELECT Id FROM Base_Price__c];
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty before before update');

        Test.startTest();
        response = trac_BulkEditDPLCtlr.updateDPLRecords(dplRecordsToUpdate[0] + '');
        Test.stopTest();

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty after update');
    }
}