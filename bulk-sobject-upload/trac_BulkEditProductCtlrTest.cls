/**
 * @description Unit test class for the Bulk Edit Product Controller
 * @author Simon Salvatore, Traction on Demand
 * @date November 12, 2020
 */
@IsTest
private class trac_BulkEditProductCtlrTest {
    @TestSetup
    static void setup() {
        Product_Code_Settings__c productCodeSettings = Product_Code_Settings__c.getOrgDefaults();
        productCodeSettings.MaxRowSelection__c = 100;
        insert productCodeSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        List<User> users = new List<User>();
        User pm_one = trac_TestUtils.createUser(1, p.Id, false)[0];
        pm_one.JDE_Address_Book_Number__c = '777777';
        User pm_two = trac_TestUtils.createUser(1, p.Id, false)[0];
        pm_two.JDE_Address_Book_Number__c = '666666';
        users.add(pm_one);
        users.add(pm_two);
        insert users;

        Account supplier = trac_TestUtils.createAccounts(1, trac_Constants.ACCOUNT_RECORD_TYPE_IDS.get('Supplier'), false)[0];
        insert supplier;

        trac_TestUtils.createPriceBooksForTests();

        Test.startTest();
        Code_Request__c primaryCodeRequest = new Code_Request__c();
        primaryCodeRequest.Code_Type__c = 'Primary';
        primaryCodeRequest.Code_Prefix__c = 'A';
        primaryCodeRequest.Guidance__c = 'Test';
        primaryCodeRequest.GLCLASS_Prefix__c = 'CRP0';
        insert primaryCodeRequest;

        Product2 commercialProduct = trac_TestUtils.createProductsFromRecordType(1, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Profile'), false)[0];
        commercialProduct.Primary_Code_Request__c = primaryCodeRequest.Id;
        insert commercialProduct;
        Product2 packageProduct =  trac_TestUtils.createProductsFromRecordType(1, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Package'), false)[0];
        packageProduct.Product_Manager__c = pm_one.Id;
        packageProduct.Product_Coordinator__c = pm_one.Id;
        packageProduct.Supplier__c = supplier.Id;
        insert packageProduct;
        Test.stopTest();
    }
    @IsTest
    static void testGetProductFromSearch() {
        Product2 product = [SELECT Id, Name FROM Product2 WHERE RecordTypeId = :trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Package')];
        String searchFields = '{"Name":"' + product.Name + '","Product_Codes__c":null,"Commodity_Code2__c":null,"Commodity_Family2__c":null,"Product_Coordinator__c":null,"Product_Manager__c":null}';
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty before searching for Products');

        Test.startTest();
        response = trac_BulkEditProductCtlr.getProductFromSearch(searchFields);
        Test.stopTest();

        System.assertNotEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should not be empty after searching for Products');
    }

    @IsTest
    static void testGetProductFromSearchError() {
        Product2 product = [SELECT Id FROM Product2 WHERE RecordTypeId = :trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Profile')];
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty before searching for Products');

        Test.startTest();
        response = trac_BulkEditProductCtlr.getProductFromSearch(product.Id);
        Test.stopTest();

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty');
    }

    @IsTest
    static void testUpdateProductRecords() {
        List<Product2> productsRecordsToUpdate = [SELECT Id FROM Product2];
        TLAuraResponse response = new TLAuraResponse(true);

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty before before update');

        Test.startTest();
        response = trac_BulkEditProductCtlr.updateProductRecords(productsRecordsToUpdate[0] + '');
        Test.stopTest();

        System.assertEquals(new Map<Object, Object>(), response.returnValuesMap, 'The Return Values Map should be empty after update');
    }

    @IsTest
    static void testGetMaxRowSelection() {
        Integer maxRows = 0;

        Test.startTest();
        maxRows = trac_BulkEditProductCtlr.getMaxRowSelection();
        Test.stopTest();

        System.assertNotEquals(0,maxRows,'Max Rows should be greater than 0');
    }
}