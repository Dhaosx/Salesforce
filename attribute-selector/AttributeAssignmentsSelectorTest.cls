/**
 * Test class for Attribute Assignment Selector class
 * @author Grant Adamson, Traction on Demand
 * @date   2017-04-21
 */
@IsTest
private class AttributeAssignmentsSelectorTest {
    public static final String TEST_CATEGORY = 'Complexity';

    @IsTest
    private static void selectById() {
        Attribute__c attr = new Attribute__c(
                Attribute__c = 'Test Attribute'
        );

        Account acct = trac_TestUtils.getAccount();
        insert (new SObject[]{
                attr, acct
        });

        Attribute_Assignment__c aa = new Attribute_Assignment__c(Attribute__c = attr.Id, Account__c = acct.Id);
        insert aa;

        Test.startTest();

        List<Attribute_Assignment__c> results = new AttributeAssignmentsSelector().selectById(new Set<Id>{
                aa.Id
        });

        Test.stopTest();

        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(aa.Id, results[0].Id, 'It should be the test Attribute Assignment record');
    }

    @IsTest
    private static void selectByParentIdAcc() {
        Attribute__c attr = new Attribute__c(
                Attribute__c = 'Test Attribute',
                Active__c = true
        );

        Account acct = trac_TestUtils.getAccount();
        insert new SObject[]{
                attr, acct
        };

        Attribute_Assignment__c aa = new Attribute_Assignment__c(Attribute__c = attr.Id, Account__c = acct.Id);
        insert aa;

        Test.startTest();

        List<Attribute_Assignment__c> results = new AttributeAssignmentsSelector().selectByParentId(acct.Id);

        Test.stopTest();

        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(aa.Id, results[0].Id, 'It should be the attribute assignment related to the opp');
    }

    @IsTest
    private static void selectByParentIdProject() {
        Attribute__c attr = new Attribute__c(
                Attribute__c = 'Test Attribute',
                Active__c = true
        );

        Contact con = trac_TestUtils.getContact();
        insert new SObject[]{
                attr, con
        };

        Attribute_Assignment__c aa = new Attribute_Assignment__c(Attribute__c = attr.Id, Contact__c = con.Id);
        insert aa;

        Test.startTest();

        List<Attribute_Assignment__c> results = new AttributeAssignmentsSelector().selectByParentId(con.Id);

        Test.stopTest();

        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(aa.Id, results[0].Id, 'It should be the attribute assignment related to the project');
    }

    @IsTest
    private static void selectCountByIdAndParentIdNoAttributes() {
        Attribute__c attr = new Attribute__c(
                Attribute__c = 'Test Attribute'
        );

        Account acct = trac_TestUtils.getAccount();
        insert new SObject[]{
                attr, acct
        };

        Test.startTest();

        Integer result = new AttributeAssignmentsSelector().selectCountByParentIdAndAttributeId(acct.Id, attr.Id);

        Test.stopTest();

        System.assertEquals(0, result, 'A count of zero should be returned');
    }

    @IsTest
    private static void selectCountByIdAndParentIdDifferentAttributes() {
        Attribute__c attr1 = new Attribute__c(
                Attribute__c = 'Test Attribute'
        );
        Attribute__c attr2 = new Attribute__c(
                Attribute__c = 'Second Test Attribute'
        );

        Account acct = trac_TestUtils.getAccount();
        insert new SObject[]{
                attr1, attr2, acct
        };

        Attribute_Assignment__c aa = new Attribute_Assignment__c(Attribute__c = attr1.Id, Account__c = acct.Id);
        insert aa;

        Test.startTest();

        Integer result = new AttributeAssignmentsSelector().selectCountByParentIdAndAttributeId(acct.Id, attr2.Id);

        Test.stopTest();

        System.assertEquals(0, result, 'A count of zero should be returned');
    }

    @IsTest
    private static void selectCountByIdAndParentIdMatchingAttributes() {
        Attribute__c attr = new Attribute__c(
                Attribute__c = 'Test Attribute'
        );

        Account acct = trac_TestUtils.getAccount();
        insert new SObject[]{
                attr, acct
        };

        Attribute_Assignment__c aa = new Attribute_Assignment__c(Attribute__c = attr.Id, Account__c = acct.Id);
        insert aa;

        Test.startTest();

        Integer result = new AttributeAssignmentsSelector().selectCountByParentIdAndAttributeId(acct.Id, attr.Id);

        Test.stopTest();

        System.assertEquals(1, result, 'A count of one should be returned');
    }

    @IsTest
    private static void selectByAttributeIdAndSObjectType() {
        Attribute__c attr = new Attribute__c(
                Attribute__c = '...'
        );

        Account acct = trac_TestUtils.getAccount();
        insert new SObject[]{
                attr, acct
        };

        Attribute_Assignment__c aa = new Attribute_Assignment__c(Attribute__c = attr.Id, Account__c = acct.Id);
        insert aa;

        Test.startTest();

        List<SObject> results =
                new AttributeAssignmentsSelector().selectByAttributeIdAndSObjectType(new Set<Id>{
                        attr.Id
                }, Account.SObjectType);

        Test.stopTest();

        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(aa.Id, results[0].Id, 'It should be the attribute assignment linked to the test account record');
    }

    @IsTest
    private static void selectByAttributeIdAndSObjectTypeExcludingParentId() {
        Attribute__c attr = new Attribute__c(
                Attribute__c = 'Test Attribute'
        );

        Account acct = trac_TestUtils.getAccount();
        Account acct2 = acct.clone();
        insert new SObject[]{
                attr, acct, acct2
        };

        Attribute_Assignment__c aa = new Attribute_Assignment__c(Attribute__c = attr.Id, Account__c = acct.Id);
        Attribute_Assignment__c aa2 = new Attribute_Assignment__c(Attribute__c = attr.Id, Account__c = acct2.Id);
        insert new Attribute_Assignment__c[]{
                aa, aa2
        };

        Test.startTest();

        List<SObject> results = new AttributeAssignmentsSelector().selectByAttributeIdAndSObjectTypeExcludingParentId(
                new Set<Id>{
                        attr.Id
                }, Account.SObjectType, acct.Id);

        Test.stopTest();

        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(aa2.Id, results[0].Id,
                'It should be the attribute assignment linked to the 2nd test opportunity record');
    }

    @IsTest
    private static void getLookupFieldFromIdTypeAcc() {
        Id accId = fflib_IDGenerator.generate(Account.SObjectType);

        Test.startTest();

        String result = AttributeAssignmentsSelector.getLookupFieldFromIdType(accId);

        Test.stopTest();

        System.assertEquals('Account__c', result, 'The method should return the correct lookup name for Accounts');
    }

    @IsTest
    private static void getLookupFieldFromIdTypeProject() {
        Id conId = fflib_IDGenerator.generate(Contact.SObjectType);

        Test.startTest();

        String result = AttributeAssignmentsSelector.getLookupFieldFromIdType(conId);

        Test.stopTest();

        System.assertEquals('Contact__c', result, 'The method should return the correct lookup name for Contacts');
    }

    @IsTest
    private static void getLookupFieldFromIdTypeInvalidId() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Boolean caughtException = false;

        Test.startTest();

        try {
            String result = AttributeAssignmentsSelector.getLookupFieldFromIdType(oppId);
        } catch (Exception e) {
            caughtException = true;
            System.assertEquals(AttributeAssignmentsSelector.INVALID_OBJECT_TYPE, e.getMessage(),
                    'The correct error message should be used');
        }

        Test.stopTest();

        System.assert(caughtException, 'An exception should have been thrown');
    }

    @IsTest
    private static void selectByAccountIdAndCategory() {
        Attribute__c attr = new Attribute__c(
                Attribute__c = 'Test Attribute',
                Category__c = TEST_CATEGORY
        );

        Account acct = trac_TestUtils.getAccount();
        System.debug('MK DEBUG: account: ' + acct);
        insert new SObject[]{
                attr, acct
        };

        Attribute_Assignment__c aa = new Attribute_Assignment__c(Attribute__c = attr.Id, Account__c = acct.Id);
        insert aa;

        Test.startTest();

        List<Attribute_Assignment__c> results = new AttributeAssignmentsSelector().selectByAccountIdAndCategory(new Set<Id>{
                acct.Id
        }, new Set<String>{
                TEST_CATEGORY
        });

        Test.stopTest();


        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(aa.Id, results[0].Id, 'It should be the test Attribute Assignment record');

    }
}