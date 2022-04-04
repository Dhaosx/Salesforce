/**
 * Tests for AttributeTaggerService
 * @author Grant Adamson, Traction on Demand
 * @date   2017-04-19
 */
@IsTest
private class AttributeTaggerServiceTest {
    private static Id accountId;
    private static Attribute__c attr;
    private static Attribute__c attr2;
    private static Attribute_Assignment__c aa;

    static {
        accountId = fflib_IDGenerator.generate(Account.SObjectType);
        attr = new Attribute__c(
                Id = fflib_IDGenerator.generate(Attribute__c.SObjectType),
                Category__c = 'AAA',
                Attribute__c = '...'
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
    private static void loadSelectedAttributesRecordId() {
        List<Attribute_Assignment__c> existingAAs = new List<Attribute_Assignment__c>{
                aa
        };
        TLUniversalMocker aaSelectorMock = new TLUniversalMocker(AttributeAssignmentsSelector.class, existingAAs);
        AttributeTaggerService.attributeAssignmentsSelectorInstance = (AttributeAssignmentsSelector) aaSelectorMock.stub;


        Test.startTest();

        List<Attribute_Assignment__c> results = new AttributeTaggerService().loadSelectedAttributes(accountId);

        Test.stopTest();


        List<List<Object>> selectByParentId = aaSelectorMock.history.get('selectByParentId');
        System.assertNotEquals(null, selectByParentId, 'The selectByParentId method was called');
        System.assertEquals(1, selectByParentId.size(), 'It was called one time');
        System.assertEquals(accountId, (Id) selectByParentId[0][0], 'It was called with the provided account Id');

        System.assertEquals(1, results.size(), 'One record should have been returned');
        System.assertEquals(aa.Id, results[0].Id, 'The record should be the test Attribute Assignment');
    }


    @IsTest
    private static void loadSelectedAttributesAttributeIds() {
        List<Attribute__c> existingAttributes = new List<Attribute__c>{
                attr
        };
        TLUniversalMocker aSelectorMock = new TLUniversalMocker(AttributesSelector.class, existingAttributes);
        AttributeTaggerService.attributesSelectorInstance = (AttributesSelector) aSelectorMock.stub;

        Set<Id> attributeIds = new Set<Id>{
                attr.Id
        };

        Test.startTest();

        List<Attribute_Assignment__c> results = new AttributeTaggerService().loadSelectedAttributes(attributeIds);

        Test.stopTest();

        List<List<Object>> selectById = aSelectorMock.history.get('selectById');
        System.assertNotEquals(null, selectById, 'The selectById method was called');
        System.assertEquals(1, selectById.size(), 'It was called one time');
        System.assertEquals(attributeIds, (Set<Id>) selectById[0][0], 'It was called with the provided attribute Ids');

        System.assertEquals(1, results.size(), 'One record should have been returned');
        System.assertEquals(attr.Attribute__c, results[0].Attribute__c, 'The record should have the expected Attribute Id');
    }


    @IsTest
    private static void loadSelectedAttributesAttributeIdsEmpty() {
        Test.startTest();

        List<Attribute_Assignment__c> results = new AttributeTaggerService().loadSelectedAttributes(new Set<Id>{
        });

        Test.stopTest();


        System.assertEquals(0, results.size(), 'Any empty list should be returned');
    }


    @IsTest
    private static void loadAttributesExcludingSelected() {
        List<Attribute_Assignment__c> existingAAs = new List<Attribute_Assignment__c>{
                aa
        };
        List<Attribute__c> availableAttributes = new List<Attribute__c>{
                attr2
        };

        TLUniversalMocker aSelectorMock = new TLUniversalMocker(AttributesSelector.class, availableAttributes);
        AttributeTaggerService.attributesSelectorInstance = (AttributesSelector) aSelectorMock.stub;

        Test.startTest();

        List<Attribute__c> results = new AttributeTaggerService().loadAttributesExcludingSelected(existingAAs);

        Test.stopTest();

        List<List<Object>> selectAllExcludingAttributes = aSelectorMock.history.get('selectAllExcludingAttributes');
        System.assertNotEquals(null, selectAllExcludingAttributes, 'The selectAllExcludingAttributes method should have been called');
        System.assertEquals(1, selectAllExcludingAttributes.size(), 'It should have been called once');


        System.assertEquals(new Set<String>{
                aa.Attribute__c
        }, (Set<String>) selectAllExcludingAttributes[0][0],
                'It should have been called with the expected set of Attributes');

        System.assertEquals(1, results.size(), 'One record should have been returned');
        System.assertEquals(attr2.Id, results[0].Id, 'It should be the second test attribute');
    }


    @IsTest
    private static void addAttributeAssignment() {
        Attribute__c realAttr = new Attribute__c(
                Attribute__c = 'Test Attribute'
        );
        Contact r = new Contact(FirstName = 'test', LastName = 'Contact');
        insert new SObject[]{
                realAttr, r
        };

        // Force duplicate count query method to return 0
        TLUniversalMocker aaSelectorMock = new TLUniversalMocker(AttributeAssignmentsSelector.class, 0);
        AttributeTaggerService.attributeAssignmentsSelectorInstance =
                (AttributeAssignmentsSelector) aaSelectorMock.stub;


        Test.startTest();

        Attribute_Assignment__c newRecord =
                new AttributeTaggerService().addAttributeAssignment(r.Id, realAttr.Id, 'Test Attribute');
        Test.stopTest();


        List<List<Object>> selectCountByParentIdAndAttributeId =
                aaSelectorMock.history.get('selectCountByParentIdAndAttributeId');

        System.assertNotEquals(null, selectCountByParentIdAndAttributeId,
                'The selectCountByParentIdAndAttributeId method should have been called');
        System.assertEquals(1, selectCountByParentIdAndAttributeId.size(), 'The method should have been called once');
        System.assertEquals(r.Id, (Id) selectCountByParentIdAndAttributeId[0][0],
                'The method should have been called with the expect parent Id');

        List<Attribute_Assignment__c> results = [SELECT Attribute__c, Contact__c FROM Attribute_Assignment__c];
        System.assertEquals(1, results.size(), 'One Attribute Assignment record should have been created');
        System.assertEquals(results[0].Id, newRecord.Id,
                'The Id returned from the method call should match the newly created record');
        System.assertEquals(r.Id, results[0].Contact__c, 'It should be related to the Contact__c record specified');
        System.assertEquals(realAttr.Attribute__c, results[0].Attribute__c,
                'It should be related to the Attribute record specified');
    }


    @IsTest
    private static void addAttributeAssignmentDupe() {
        // Force duplicate count query method to return 1
        TLUniversalMocker aaSelectorMock = new TLUniversalMocker(AttributeAssignmentsSelector.class, 1);
        AttributeTaggerService.attributeAssignmentsSelectorInstance =
                (AttributeAssignmentsSelector) aaSelectorMock.stub;

        Boolean caughtException = false;

        Test.startTest();

        try {
            new AttributeTaggerService().addAttributeAssignment(accountId, attr.Id, attr.Name);
        } catch (Exception e) {
            caughtException = true;
            System.assertEquals(AttributeTaggerService.DUPLICATE_ATTRIBUTE_ERROR_MSG, e.getMessage(),
                    'The correct error message should be used');
        }

        Test.stopTest();

        System.assert(caughtException, 'An exception should have been thrown');
    }


    @IsTest
    private static void deleteAttributeAssignment() {
        Attribute__c realAttr = new Attribute__c(
                Attribute__c = 'Test Attribute'
        );
        Contact r = new Contact(FirstName = 'test', LastName = 'Contact');
        insert new SObject[]{
                realAttr, r
        };

        Attribute_Assignment__c realAA = new Attribute_Assignment__c(
                Attribute__c = realAttr.Attribute__c,
                Contact__c = r.Id
        );
        insert realAA;

        Test.startTest();

        new AttributeTaggerService().deleteAttributeAssignment(realAA.Id);

        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Attribute_Assignment__c],
                'The Attribute Assignment record should have been deleted');
    }
}