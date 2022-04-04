/**
* @description  Class for unit testing actions from the Related List Controller
* @author       Simon Salvatore, Traction on Demand
* @date         2020-02-19
**/
@IsTest
private class trac_RelatedListControllerTest {

    @TestSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        List<User> users = trac_TestUtils.createUser(20, p.Id, false);
        insert users;

        List<Account> superAccounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            superAccounts.add(new Account(Name = 'Super Account ' + i, RecordTypeId = trac_Constants.ACCOUNT_RECORD_TYPE_IDS.get('Customer'), OwnerId = users[i].Id, Profile_Type__c = 'Parent'));
        }
        insert superAccounts;
        List<User> childOwners = new List<User>();
        User childOwner1 = new User(Alias = 'standt23', Email = 'standarduser@example.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', Username = 'standarduserchild@example.com');
        User childOwner2 = new User(Alias = 'standt23', Email = 'standarduser@example.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', Username = 'standarduserchild2@example.com');

        childOwners.add(childOwner1);
        childOwners.add(childOwner2);
        insert childOwners;
        List<Account> childrenAccounts = new List<Account>();
        for (Account superAcc : superAccounts) {
            for (Integer i = 0; i < 2; i++) {
                childrenAccounts.add(new Account(
                        Name = superAcc.Name + ' Child ' + i,
                        RecordTypeId = trac_Constants.ACCOUNT_RECORD_TYPE_IDS.get('Customer'),
                        ParentId = superAcc.Id, OwnerId = childOwners[i].Id
                ));
            }
        }
        insert childrenAccounts;

        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = trac_TestUtils.createOpportunities(1, true, childrenAccounts[0].Id);

        List<Case> cases = new List<Case>();
        cases = trac_TestUtils.createCases(1, true);

        cases[0].AccountId = childrenAccounts[0].Id;
        update cases;
    }

    @IsTest
    static void testGetRelatedChildren() {
        List<Account> pAccount = [SELECT Id FROM Account WHERE ParentId = NULL];
        List<SObject> childAccountRelatedRecords = new List<SObject>();

        Test.startTest();
        childAccountRelatedRecords = trac_RelatedListController.getRelatedChildren(pAccount[0].Id, 'Opportunity', 'RECORDTYPE.DEVELOPERNAME = \'Opportunity\'', 'Name,StageName,CloseDate', 'AccountId', '');
        Test.stopTest();

        System.assertEquals(childAccountRelatedRecords.isEmpty(), false);
    }

    @IsTest
    static void testGetRelatedChildrenWithSecondSearch() {
        List<Account> pAccount = [SELECT Id FROM Account WHERE ParentId = NULL];
        List<SObject> childAccountRelatedRecords = new List<SObject>();

        Test.startTest();
        childAccountRelatedRecords = trac_RelatedListController.getRelatedChildren(pAccount[0].Id, 'Case', '', 'CaseNumber,Account.Name,Account.Key_Information__c', 'AccountId', 'Related_Product__r.Supplier__c');
        Test.stopTest();

        System.assertEquals(childAccountRelatedRecords.isEmpty(), false);
    }

    @IsTest
    static void testDeleteRelatedRecord() {
        List<Opportunity> rOpportunities = [SELECT Id FROM Opportunity];

        Test.startTest();
        trac_RelatedListController.deleteRelatedRecord(rOpportunities[0].Id);
        Test.stopTest();

        List<Opportunity> dOpportunities = [SELECT Id FROM Opportunity];

        System.assertEquals(dOpportunities.isEmpty(), true);
    }

    @IsTest
    static void testDeleteRelatedRecordDMLException() {
        // This Id needs to be hardcoded to simulate a DML Exception
        Test.startTest();
        trac_RelatedListController.deleteRelatedRecord('00E5A000001dLrXUAU');
        Test.stopTest();
    }
}