/**
 * @description Unit Test Class to test Upload Order files
 * @author Simon Salvatore, Traction on Demand
 * @date 16/01/2019
 */

@IsTest
private class trac_UploadOrderFilesBoxTest {
    private static final String FOLDER_ENDPOINT = 'https://api.box.com/2.0/folders';
    private static final String FILE_RESOURCE = 'trac_UploadFiles';
    private static final String FOLDER_RESOURCE = 'trac_CreateFolder';

    @TestSetup
    static void setup() {
        trac_TestUtils.setBoxConfigSettings();

        List<Opportunity> opportunities = trac_TestUtils.createOpportunities(1,true);

        Order order = trac_TestUtils.createOrder(opportunities[0],'Maroline');
        insert order;
        OrderItem orderItem = trac_TestUtils.createOrderItemsForOrder(order, 1)[0];
        insert orderItem;

        List<Attachment> attachments = trac_TestUtils.createAttachments(order.Id,5,true);

        order.Attachment__c = attachments[0].Id;
        order.Status = 'Completed Delivered';
        order.GP_Order_ID__c = '34234234';
        Test.setCreatedDate(order.Id,Date.today().addMonths(-4));
        update order;
    }

    @IsTest
    static void testExecuteFileUpload() {
        trac_UploadOrderFilesBox uploadOrderFilesBox = new trac_UploadOrderFilesBox();

        Database.executeBatch(uploadOrderFilesBox);
    }

    @IsTest
    static void testScheduleFileUpload() {
        trac_UploadOrderFilesBox uploadOrderFilesBox = new trac_UploadOrderFilesBox();

        String sch = '0 01 * * * ? *';
        String jobId = System.schedule('Upload Order Files to Box', sch, uploadOrderFilesBox);
    }

    @IsTest
    static void testCreateRecordFolderBoxApi () {
        List<Order> aOrder = [SELECT Id FROM Order];
        Box_API_Settings__c defaultBoxSettings = [
                SELECT Access_Token__c, ClientID__c, ClientSecret__c, Refresh_Token__c, Order_Folder_ID__c, Quote_Folder_ID__c
                FROM Box_API_Settings__c];

        if (aOrder != null) {
            Test.startTest();
            MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
            myMock.setStaticResource(FOLDER_ENDPOINT, FOLDER_RESOURCE);
            myMock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, myMock);
            System.assertNotEquals(null, trac_WS_Utilities.createRecordFolderBoxApi(aOrder[0].Id,defaultBoxSettings,defaultBoxSettings.Quote_Folder_ID__c), 'Box API Folder for Order Attachments was successfully created');
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
            System.assertNotEquals(null, trac_WS_Utilities.uploadFiles(boundary,Blob.valueOf('Unit Test Attachment'),defaultBoxSettings.Quote_Folder_ID__c), 'Order File was successfully uploaded to Box API');
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

    @IsTest
    static void testParse () {
        String body = '<xml>test</xml>';
        String tag = 'OUTCODE';

        Test.startTest();
        trac_WS_Utilities.parseResponse(body,tag);
        Test.stopTest();
    }


    @IsTest
    static void testGetCCEmails () {
        List<String> emails;

        Test.startTest();
        emails = trac_WS_Utilities.getCCEmails();
        Test.stopTest();

        System.assert(emails != null, 'List of CC Emails should be returned');
    }

    @IsTest
    static void testSendEmail () {
        Test.startTest();
        trac_WS_Utilities.sendEmail('Subject','Body',new List<String>{'test@mail.com'},new List<String>{'testcc@mail.com'});
        Test.stopTest();
    }

}