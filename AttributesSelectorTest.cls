/**
 * Test class for Attribute Selector class
 * @author Grant Adamson, Traction on Demand
 * @date   2017-04-21
 */
@IsTest
private class AttributesSelectorTest {
    private static Attribute__c attr;

    static {
        attr = new Attribute__c(
                Attribute__c = 'Test Attribute'
        );
        insert attr;
    }

    @IsTest
    private static void selectById() {
        Test.startTest();

        List<Attribute__c> results = new AttributesSelector().selectById(new Set<Id>{
                attr.Id
        });

        Test.stopTest();

        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(attr.Id, results[0].Id, 'It should be the test attribute record');
    }

    @IsTest
    private static void selectAllExcludingAttributes() {
        Attribute__c attr2 = new Attribute__c(
                Attribute__c = 'Second Test Attribute',
                Active__c = true
        );
        insert attr2;

        Test.startTest();

        List<Attribute__c> results = new AttributesSelector().selectAllExcludingAttributes(new Set<String>{
                attr.Attribute__c
        });

        Test.stopTest();

        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(attr2.Id, results[0].Id, 'It should be the second test attribute record');
    }
}