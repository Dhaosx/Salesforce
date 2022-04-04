/**
 * @description Unit test class for the Code Coverage Batch
 * @author Simon Salvatore, Traction on Demand
 * @date December 1, 2020
 */
@IsTest
private class trac_CodeCoverageBatchTest {
    @TestSetup
    static void setup() {
        BatchClassConfiguration__c batchConfig = new BatchClassConfiguration__c();
        batchConfig.Receiver_Email__c = 'test@example.com';
        insert batchConfig;

        Product_Code_Settings__c productCodeSettings = Product_Code_Settings__c.getOrgDefaults();
        insert productCodeSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User pm_one = trac_TestUtils.createUser(1, p.Id, false)[0];
        pm_one.Email = 'csr2@example.com';
        pm_one.JDE_Address_Book_Number__c = '777777';
        insert pm_one;

        Account supplier = new Account(Name = 'Supplier', RecordTypeId = trac_Constants.ACCOUNT_RECORD_TYPE_IDS.get('Supplier'), Company__c = '100');
        insert supplier;

        trac_TestUtils.createPriceBooksForTests();

        Code_Request__c primaryCodeRequest = new Code_Request__c();
        primaryCodeRequest.Code_Type__c = 'Primary';
        primaryCodeRequest.Code_Prefix__c = 'A';
        primaryCodeRequest.Guidance__c = 'Test';
        primaryCodeRequest.GLCLASS_Prefix__c = 'CRP0';
        insert primaryCodeRequest;

        Product2 commercialProduct = trac_TestUtils.createProductsFromRecordType(1, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Profile'), false)[0];
        commercialProduct.Company__c = '100';
        commercialProduct.Primary_Code_Request__c = primaryCodeRequest.Id;
        commercialProduct.Product_Manager__c = pm_one.Id;
        commercialProduct.Product_Coordinator__c = pm_one.Id;
        commercialProduct.Supplier__c = supplier.Id;
        insert commercialProduct;
    }

    @IsTest
    static void testRunBatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_MockHttpResponseGenerator());
        trac_CodeCoverageBatch batchJob = new trac_CodeCoverageBatch();
        String jobId = Database.executeBatch(batchJob,1);
        Test.stopTest();

        System.assert(jobId.length() > 0);
    }

    @IsTest
    static void testScheduleCodeCoverageBatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_MockHttpResponseGenerator());
        trac_CodeCoverageBatch codeCoverageBatch = new trac_CodeCoverageBatch();
        String sch = '0 0 * * * ? *';
        String jobId = System.schedule('Test Code Coverage Batch', sch, codeCoverageBatch);
        Test.stopTest();

        System.assert(jobId.length() > 0);
    }
}