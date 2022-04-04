/**
 * @description Unit Test Class to test Upload Quote__c files
 * @author Simon Salvatore, Traction on Demand
 * @date 16/01/2019
 */

@IsTest
private class trac_UploadQuoteFilesBoxTest {
    private static final String FOLDER_ENDPOINT = 'https://api.box.com/2.0/folders';
    private static final String FILE_RESOURCE = 'trac_UploadFiles';
    private static final String FOLDER_RESOURCE = 'trac_CreateFolder';

    @TestSetup
    static void setup() {
        trac_TestUtils.setBoxConfigSettings();

        List<Opportunity> opportunities = trac_TestUtils.createOpportunities(1,true);

        List<Quote__c> quotes = trac_TestUtils.createQuotes(opportunities[0].Id,1,true);

        List<Attachment> attachments = trac_TestUtils.createAttachments(quotes[0].Id,5,true);
        Test.setCreatedDate(attachments[0].Id,Date.today().addMonths(-4));
        update attachments;

        quotes[0].Attachment__c = attachments[0].Id;
        Test.setCreatedDate(quotes[0].Id,Date.today().addMonths(-4));
        update quotes;
    }

    @IsTest
    static void testExecuteFileUpload() {
        trac_UploadQuoteFilesBox uploadQuoteFilesBox = new trac_UploadQuoteFilesBox();

        Database.executeBatch(uploadQuoteFilesBox);
    }

    @IsTest
    static void testScheduleFileUpload() {
        trac_UploadQuoteFilesBox uploadQuoteFilesBox = new trac_UploadQuoteFilesBox();

        String sch = '0 01 * * * ? *';
        String jobId = System.schedule('Upload Quote Files to Box', sch, uploadQuoteFilesBox);
    }

    @IsTest
    static void testCreateRecordFolderBoxApi () {
        List<Quote__c> aQuote = [SELECT Id FROM Quote__c];
        Box_API_Settings__c defaultBoxSettings = [
                SELECT Access_Token__c, ClientID__c, ClientSecret__c, Refresh_Token__c, Order_Folder_ID__c, Quote_Folder_ID__c
                FROM Box_API_Settings__c];

        if (aQuote != null) {
            Test.startTest();
            MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
            myMock.setStaticResource(FOLDER_ENDPOINT, FOLDER_RESOURCE);
            myMock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, myMock);
            System.assertNotEquals(null, trac_WS_Utilities.createRecordFolderBoxApi(aQuote[0].Id,defaultBoxSettings,defaultBoxSettings.Quote_Folder_ID__c), 'Box API Folder for Quote Attachments was successfully created');
            Test.stopTest();
        }
    }

    @IsTest
    static void testUploadFiles () {
        String boundary = '----------------------------741e90d31eff';
        List<Attachment> qAttachment = [SELECT Id, ParentId FROM Attachment];
        Box_API_Settings__c defaultBoxSettings = [
                SELECT Access_Token__c, ClientID__c, ClientSecret__c, Refresh_Token__c, Order_Folder_ID__c, Quote_Folder_ID__c
                FROM Box_API_Settings__c];

        if (qAttachment != null) {
            Test.startTest();
            StaticResourceCalloutMock myMock = new StaticResourceCalloutMock ();
            myMock.setStaticResource(FILE_RESOURCE);
            myMock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, myMock);
            System.assertNotEquals(null, trac_WS_Utilities.uploadFiles(boundary,Blob.valueOf('Unit Test Attachment'),defaultBoxSettings.Quote_Folder_ID__c), 'Quote File was successfully uploaded to Box API');
            Test.stopTest();
        }
    }

    @IsTest
    static void testDeleteAttachments () {
        List<Attachment> qAttachment = [SELECT Id, ParentId FROM Attachment];

        if (qAttachment != null) {
            Test.startTest();
            trac_WS_Utilities.deleteAttachments(qAttachment);
            Test.stopTest();
        }
    }

}