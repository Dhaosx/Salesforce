/**
 * @description Custom Account Report Controller test class for the controller
 * @author Simon Salvatore
 * @date March 10, 2020
 */
@IsTest
private class trac_CustomAccountReportControllerTest {
    private static final Integer THIS_FISCAL_YEAR = System.today().year() - 1;

    @TestSetup
    static void setup() {
        Product_Code_Settings__c productCodeSettings = Product_Code_Settings__c.getOrgDefaults();
        insert productCodeSettings;

        trac_TestUtils.createPriceBooksForTests();

        Code_Request__c codeRequest = trac_TestUtils.createCodeRequest(1, 'Primary', false)[0];
        insert codeRequest;

        List<Product2> prodsToInsert = new List<Product2>();
        Product2 commercialProduct = trac_TestUtils.createProductsFromRecordType(1, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Profile'), false)[0];
        commercialProduct.Primary_Code_Request__c = codeRequest.Id;
        insert commercialProduct;

        Product2 packageProduct = trac_TestUtils.createProductsFromRecordType(1, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Package'), false)[0];
        packageProduct.Commercial_Product__c = commercialProduct.Id;
        prodsToInsert.add(packageProduct);

        Product2 emptyProduct = trac_TestUtils.createProductsFromRecordType(1, trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Generic'),false)[0];
        emptyProduct.Commercial_Product__c = commercialProduct.Id;
        prodsToInsert.add(emptyProduct);

        insert prodsToInsert;

        Test.startTest();
        List<Account> accountToInsert = new List<Account>();
        Account acc = trac_TestUtils.createAccounts(1, trac_Constants.ACCOUNT_RECORD_TYPE_IDS.get('Customer'), false)[0];
        acc.CurrencyIsoCode = 'USD';
        acc.Company__c = '220';
        acc.ERP_Currency__c = 'USD';
        accountToInsert.add(acc);

        Account secondAcc = trac_TestUtils.createAccounts(1, trac_Constants.ACCOUNT_RECORD_TYPE_IDS.get('Customer'), false)[0];
        secondAcc.CurrencyIsoCode = 'CAD';
        secondAcc.Company__c = '100';
        secondAcc.ERP_Currency__c = 'CAD';
        accountToInsert.add(secondAcc);

        insert accountToInsert;

        Junction_Account_Product__c jap = new Junction_Account_Product__c(Account__c = acc.Id, Product__c = packageProduct.Id, Account_Product_External_Id__c = 'UNI97686');
        insert jap;

        //Forecast record for this fiscal and the related forecast line items
        Forecast__c thisFiscalForecast = trac_TestUtils.createForecast(false, THIS_FISCAL_YEAR, 'This_Fiscal');
        insert thisFiscalForecast;

        List<Forecast_Line_Item__c> forecastLineItemList = new List<Forecast_Line_Item__c>();
        for (Integer i = 0; i < 2; i++) {
            Forecast_Line_Item__c forecastLineItem;
            if (i == 0) {
                forecastLineItem = new Forecast_Line_Item__c(
                        Product__c = packageProduct.Id,
                        Fiscal_Year_Number__c = THIS_FISCAL_YEAR,
                        Forecast_Line_Item_Key__c = 'Test Key' + i,
                        October_Revenue__c = 10,
                        October_Actual_Revenue__c = 10,
                        October_Cost__c = 10,
                        October_Actual_Cost__c = 10,
                        October_Actual_Quantity__c = 10,
                        October_Quantity__c = 10,
                        Forecast__c = thisFiscalForecast.Id,
                        Account__c = secondAcc.Id,
                        Account_Product__c = jap.Id
                );
            } else {
                forecastLineItem = new Forecast_Line_Item__c(
                        Product__c = packageProduct.Id,
                        Fiscal_Year_Number__c = THIS_FISCAL_YEAR,
                        Forecast_Line_Item_Key__c = 'Test Key' + i,
                        October_Revenue__c = 10,
                        October_Actual_Revenue__c = 10,
                        October_Cost__c = 10,
                        October_Actual_Cost__c = 10,
                        October_Actual_Quantity__c = 10,
                        October_Quantity__c = 10,
                        Forecast__c = thisFiscalForecast.Id,
                        Account__c = acc.Id,
                        Account_Product__c = jap.Id
                );
            }
            forecastLineItemList.add(forecastLineItem);
        }

        insert forecastLineItemList;
        Test.stopTest();
    }

    @IsTest
    static void testGetReportDataForUSCompany() {
        Map<String, Map<String, List<String>>> aggregateMap = new Map<String, Map<String, List<String>>>();
        List<Account> accounts = [SELECT Id FROM Account WHERE Company__c = '220'];



        System.assertEquals(aggregateMap.isEmpty(), true);

        Test.startTest();
        aggregateMap = trac_CustomAccountReportController.getReportData(accounts[0].Id, '');
        Test.stopTest();

        System.assertEquals(aggregateMap.isEmpty(), false);
    }

    @IsTest
    static void testGetReportDataForCDNCompany() {
        Map<String, Map<String, List<String>>> aggregateMap = new Map<String, Map<String, List<String>>>();
        List<Account> accounts = [SELECT Id FROM Account WHERE Company__c = '100'];

        System.assertEquals(aggregateMap.isEmpty(), true);

        Test.startTest();
        aggregateMap = trac_CustomAccountReportController.getReportData(accounts[0].Id, '');
        Test.stopTest();

        System.assertEquals(aggregateMap.isEmpty(), false);
    }

    @IsTest
    static void testGetReportDataForEmptyProductNoLineItem() {
        Map<String, Map<String, List<String>>> aggregateMap = new Map<String, Map<String, List<String>>>();
        List<Account> accounts = [SELECT Id FROM Account WHERE Company__c = '100'];
        List<Product2> products = [SELECT Id FROM Product2 WHERE RecordTypeId =: trac_Constants.PRODUCT_RECORD_TYPE_IDS.get('Generic')];

        System.assertEquals(aggregateMap.isEmpty(), true);

        Test.startTest();
        aggregateMap = trac_CustomAccountReportController.getReportData(accounts[0].Id, products[0].Id);
        Test.stopTest();

        System.assertEquals(aggregateMap.isEmpty(), false); }
}