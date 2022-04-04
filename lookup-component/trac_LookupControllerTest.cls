/**
 * @description Unit test class for the Lookup Controller
 * @author Simon Salvatore, Traction on Demand
 * @date June 23, 2020
 */
@IsTest
public class trac_LookupControllerTest {

    @TestSetup
    static void setup(){
        List<Account> accounts = trac_TestUtils.createAccounts(1, trac_Constants.ACCOUNT_RECORD_TYPE_IDS.get('Customer'), false);
        insert accounts;
    }

    @IsTest
    static void test_fetchLookupValues() {
        Account aAccount = [SELECT Id, Name FROM Account LIMIT 1];

        Test.startTest();
        List<sObject> accountResults = trac_LookupController.getLookUpValues(aAccount.Name,'Account','','');
        Test.stopTest();

        System.assertEquals(1,accountResults.size(),'An Account should have been returned from the lookup');

    }
}