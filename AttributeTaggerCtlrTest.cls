/**
 * AttributeTaggerCtlrTest - "Metatagging" project
 * Tests for AttributeTaggerCtlr.cls
 * @author Grant Adamson, Traction on Demand
 * @date 2016-07-07
 */
@IsTest
private class AttributeTaggerCtlrTest {
    private static Id accountId;
    private static Attribute__c attr;
    private static Attribute__c attr2;
    private static Attribute_Assignment__c aa;

    static {
        accountId = fflib_IDGenerator.generate(Account.SObjectType);
        attr = new Attribute__c(
                Id = fflib_IDGenerator.generate(Attribute__c.SObjectType),
                Category__c = 'AAA'
        );
        attr2 = new Attribute__c(
                Id = fflib_IDGenerator.generate(Attribute__c.SObjectType),
                Category__c = 'ZZZ'
        );

        aa = new Attribute_Assignment__c(
                Id = fflib_IDGenerator.generate(Attribute_Assignment__c.SObjectType),
                Attribute__c = attr.Id,
                Account__c = accountId
        );
    }

    @IsTest
    private static void getAvailableAndSelectedItemsForAttributeIds() {
        List<Attribute_Assignment__c> testAAs = new List<Attribute_Assignment__c>{
                aa
        };
        List<Attribute__c> testAttrs = new List<Attribute__c>{
                attr2
        };

        TLUniversalMocker taggerMock = new TLUniversalMocker(AttributeTaggerService.class, new Map<String, Object>{
                'loadSelectedAttributes' => testAAs,
                'loadAttributesExcludingSelected' => testAttrs
        });
        AttributeTaggerCtlr.attributeTaggerServiceInstance = (AttributeTaggerService) taggerMock.stub;

        List<Id> attributeIds = new List<Id>{
                attr.Id
        };

        Test.startTest();

        Map<String, Object> results = AttributeTaggerCtlr.getAvailableAndSelectedItemsForAttributeIds(attributeIds);

        Test.stopTest();

        List<List<Object>> loadSelectedAttributesHistory = taggerMock.history.get('loadSelectedAttributes');
        System.assertNotEquals(null, loadSelectedAttributesHistory, 'The loadSelectedAttributes method was called');
        System.assertEquals(1, loadSelectedAttributesHistory.size(), 'It was called one time');
        System.assertEquals(new Set<Id>(attributeIds), (Set<Id>) loadSelectedAttributesHistory[0][0],
                'It was called with the attributeIds provided');

        List<List<Object>> loadAttributesExcludingSelected = taggerMock.history.get('loadAttributesExcludingSelected');
        System.assertNotEquals(null, loadAttributesExcludingSelected,
                'The loadAttributesExcludingSelected method was called');
        System.assertEquals(1, loadAttributesExcludingSelected.size(), 'It was called one time');
        System.assertEquals(testAAs, (List<Attribute_Assignment__c>) loadAttributesExcludingSelected[0][0],
                'It was called with expected list of attribute assignments');

        List<Attribute_Assignment__c> selectedAttributes = (List<Attribute_Assignment__c>) results.get('selected');
        List<AttributeTaggerCtlr.AttributeCategory> availableAttributeCategories =
                (List<AttributeTaggerCtlr.AttributeCategory>) results.get('available');

        System.assertEquals(1, selectedAttributes.size(), 'There should be one entry in the selected list');
        System.assertEquals(aa.Id, selectedAttributes[0].Id, 'It should be the test attribute assignment record');

        System.assertEquals(1, availableAttributeCategories.size(), 'There should be one entry in the available list');

        AttributeTaggerCtlr.AttributeCategory category = availableAttributeCategories[0];
        System.assertEquals(attr2.Category__c, category.name, 'The category should have the correct name');
        System.assertEquals(1, category.attributes.size(), 'The category should contain one attribute');
        System.assertEquals(attr2.Id, category.attributes[0].Id,
                'It should be the test attribute not associated to the opp');
    }

    @IsTest
    private static void availableItemsCategorySorting() {
        Attribute__c attr3 = new Attribute__c(
                Id = fflib_IDGenerator.generate(Attribute__c.SObjectType)
        );
        List<Attribute__c> testAttrs = new List<Attribute__c>{
                attr2, attr3, attr
        };

        TLUniversalMocker taggerMock = new TLUniversalMocker(AttributeTaggerService.class, new Map<String, Object>{
                'loadSelectedAttributes' => new List<Attribute_Assignment__c>(),
                'loadAttributesExcludingSelected' => testAttrs
        });
        AttributeTaggerCtlr.attributeTaggerServiceInstance = (AttributeTaggerService) taggerMock.stub;

        Test.startTest();

        Map<String, Object> results = AttributeTaggerCtlr.getAvailableAndSelectedItemsForRecordId(accountId);

        Test.stopTest();

        List<AttributeTaggerCtlr.AttributeCategory> availableAttributeCategories =
                (List<AttributeTaggerCtlr.AttributeCategory>) results.get('available');

        System.assertEquals(3, availableAttributeCategories.size(), 'There should be one entry in the available list');
        System.assertEquals(attr.Category__c, availableAttributeCategories[0].name,
                'The categories should be sorted alphabetically');
        System.assertEquals(attr2.Category__c, availableAttributeCategories[1].name,
                'The categories should be sorted alphabetically');
        System.assertEquals(AttributeTaggerCtlr.DEFAULT_CATEGORY_NAME, availableAttributeCategories[2].name,
                'The categories should be sorted alphabetically, but with the default at the end');
    }


    @IsTest
    private static void addAttribute() {
        TLUniversalMocker taggerMock = new TLUniversalMocker(AttributeTaggerService.class, aa);
        AttributeTaggerCtlr.attributeTaggerServiceInstance = (AttributeTaggerService) taggerMock.stub;

        Test.startTest();

        Attribute_Assignment__c result = AttributeTaggerCtlr.addAttribute(accountId, attr2.Id, attr2.Name);

        Test.stopTest();

        List<List<Object>> addAttributeAssignment = taggerMock.history.get('addAttributeAssignment');
        System.assertNotEquals(null, addAttributeAssignment, 'The addAttributeAssignment method was called');
        System.assertEquals(1, addAttributeAssignment.size(), 'It was called one time');
        System.assertEquals(accountId, (Id) addAttributeAssignment[0][0], 'It was called with the provided opp Id');
        System.assertEquals(attr2.Id, (Id) addAttributeAssignment[0][1],
                'It was called with the provided attribute Id');
        System.assertEquals(attr2.Name, (String) addAttributeAssignment[0][2],
                'It was called with the provided attribute name');

        System.assertEquals(aa, result, 'The new Attribute Assignment record was returned');
    }


    @IsTest
    private static void addAttributeDuplicate() {
        TLUniversalMocker taggerMock = new TLUniversalMocker(AttributeTaggerService.class,
                new AttributeTaggerService.DuplicateAttributeAssignmentException('OH NO DUPES'));
        AttributeTaggerCtlr.attributeTaggerServiceInstance = (AttributeTaggerService) taggerMock.stub;

        Test.startTest();

        Attribute_Assignment__c result = AttributeTaggerCtlr.addAttribute(accountId, attr2.Id, attr2.Name);

        Test.stopTest();

        List<List<Object>> addAttributeAssignment = taggerMock.history.get('addAttributeAssignment');
        System.assertNotEquals(null, addAttributeAssignment, 'The addAttributeAssignment method was called');
        System.assertEquals(1, addAttributeAssignment.size(), 'It was called one time');
        System.assertEquals(accountId, (Id) addAttributeAssignment[0][0], 'It was called with the provided opp Id');
        System.assertEquals(attr2.Id, (Id) addAttributeAssignment[0][1],
                'It was called with the provided attribute Id');
        System.assertEquals(attr2.Name, (String) addAttributeAssignment[0][2],
                'It was called with the provided attribute name');

        System.assertEquals(null, result, 'No record was returned');
    }

    @IsTest
    private static void removeAttribute() {
        TLUniversalMocker taggerMock = new TLUniversalMocker(AttributeTaggerService.class);
        AttributeTaggerCtlr.attributeTaggerServiceInstance = (AttributeTaggerService) taggerMock.stub;

        Test.startTest();

        AttributeTaggerCtlr.removeAttribute(aa.Id);

        Test.stopTest();

        List<List<Object>> deleteAttributeAssignment = taggerMock.history.get('deleteAttributeAssignment');
        System.assertNotEquals(null, deleteAttributeAssignment, 'The deleteAttributeAssignment method was called');
        System.assertEquals(1, deleteAttributeAssignment.size(), 'It was called one time');
        System.assertEquals(aa.Id, (Id) deleteAttributeAssignment[0][0],
                'It was called with the provided attribute assignment Id');
    }
}