/**
 * @description Membership Card Controller test class to test Membership Card Controller class
 * @author Simon Salvatore, Salesforce
 * @date July 8, 2022
 */
@IsTest
private class MembershipCardControllerTest {
    @TestSetup
    static void setup() {
        List<Contact> contacts = TestUtilities.createContacts(1, false);
        contacts[0].Birthdate = Date.today();
        contacts[0].Gender__c = 'Male';
        insert contacts;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Name';
        cv.PathOnClient = '/' + 'Test Name';
        cv.FirstPublishLocationId = contacts[0].Id;
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
    }

    @IsTest
    static void testGetProfilePicture() {
        List<Contact> contacts = [SELECT Id FROM Contact];
        ContentVersion content;

        System.assertEquals(null, content, 'Content Version should be null before retrieving');

        Test.startTest();
        content = MembershipCardController.getProfilePicture(contacts[0].Id);
        Test.stopTest();

        System.assertNotEquals(null, content, 'Content Version should not be null after retrieving');
    }

    @IsTest
    static void testNullGetProfilePicture() {
        ContentVersion content;

        System.assertEquals(null, content, 'Content Version should be null before retrieving');

        Test.startTest();
        content = MembershipCardController.getProfilePicture('0068D00000AwhNzQAJ');
        Test.stopTest();

        System.assertEquals(null, content, 'Content Version should still be null after retrieving');
    }

    @IsTest
    static void testSaveAttachment() {
        List<Contact> contacts = [SELECT Id FROM Contact];
        Id contentVersionId;

        System.assertEquals(null, contentVersionId, 'Content Version Id should be null before retrieving');

        Test.startTest();
        contentVersionId = MembershipCardController.saveAttachment(contacts[0].Id, 'TestFile', 'Test Attachment Content');
        Test.stopTest();

        System.assertNotEquals(null, contentVersionId, 'Content Version Id should not be null after retrieving');
    }

    @IsTest
    static void testNullSaveAttachment() {
        Id contentVersionId;

        System.assertEquals(null, contentVersionId, 'Content Version Id should be null before retrieving');

        Test.startTest();
        contentVersionId = MembershipCardController.saveAttachment('0068D00000AwhNzQAJ', 'TestFile', 'Test Attachment Content');
        Test.stopTest();

        System.assertEquals(null, contentVersionId, 'Content Version Id should still be null after retrieving');
    }

    @IsTest
    static void testGetContactFields() {
        List<Contact> contacts = [SELECT Id FROM Contact];
        Map<String, String> contactMapByField;

        System.assertEquals(null, contactMapByField, 'Contact Map Id should be null before retrieving');

        Test.startTest();
        contactMapByField = MembershipCardController.getContactFields(contacts[0].Id);
        Test.stopTest();

        System.assertNotEquals(null, contactMapByField, 'Contact Map should not be null after retrieving');
    }
}