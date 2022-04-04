/**
 * @description Apex Class to batch upload files from Quote__c to Box from Salesforce
 * @author Simon Salvatore, Traction on Demand
 * @date 16/01/2019
 */

global with sharing class trac_UploadQuoteFilesBox implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts{
    private static Integer CREATED_DATE = 3;
    private static String OBJECT_NAME = 'Quote__c';

    global Database.QueryLocator start(Database.BatchableContext BC){
        Date recordCreatedDate = System.today().addMonths(-CREATED_DATE);
        List<Quote__c> quotes = [SELECT Id FROM Quote__c WHERE FilesBackedUp__c = FALSE LIMIT 500];
        Set<Id> quoteIds = new Set<Id>();

        for (Quote__c quote : quotes) {
            quoteIds.add(quote.Id);
            quote.FilesBackedUp__c = true;
        }

        update quotes;

        return Database.getQueryLocator('SELECT Id, Body, Name, ParentId FROM Attachment WHERE CreatedDate < :recordCreatedDate AND Parent.Type =: OBJECT_NAME AND ParentId IN :quoteIds');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new trac_UploadQuoteFilesBox(), 10);
    }

    public void execute(Database.BatchableContext BC, List<Attachment> scope) {
        trac_UploadQuoteFilesBox.prepareUpload(scope);
        trac_WS_Utilities.deleteAttachments(scope);
    }

    private static void prepareUpload(List<Attachment> scope){
        Box_API_Settings__c defaultBoxSettings = trac_BoxSettingsSelector.getOrgDefaults();

        Map<Id,List<Attachment>> attachmentByParentId = new Map<Id, List<Attachment>>();
        for (Attachment file : scope) {
            // Sort attachments by the record that they are related to
            if (attachmentByParentId.get(file.ParentId) != null) {
                attachmentByParentId.get(file.ParentId).add(file);
            } else {
                attachmentByParentId.put(file.ParentId,new List<Attachment>{file});
            }

            String boundary = '----------------------------741e90d31eff';
            String header = '--' + boundary + '\nContent-Disposition: form-data; name="file"; filename="' + file.Name + '";\nContent-Type: application/octet-stream';
            // GW: Do not prepend footer with \r\n, you'll see why in a moment
            // String footer = '\r\n--'+boundary+'--';
            String footer = '--' + boundary + '--';
            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
            while (headerEncoded.endsWith('=')) {
                header += ' ';
                headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
            }

            String bodyEncoded = EncodingUtil.base64Encode(file.Body);
            // GW: Do not encode footer yet
            // String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));

            Blob bodyBlob = null;
            String last4Bytes = bodyEncoded.substring(bodyEncoded.length() - 4, bodyEncoded.length());
            // GW: replacement section to get rid of padding without corrupting data
            if (last4Bytes.endsWith('==')) {
                // The '==' sequence indicates that the last group contained only one 8 bit byte
                // 8 digit binary representation of CR is 00001101
                // 8 digit binary representation of LF is 00001010
                // Stitch them together and then from the right split them into 6 bit chunks
                // 0000110100001010 becomes 0000 110100 001010
                // Note the first 4 bits 0000 are identical to the padding used to encode the
                // second original 6 bit chunk, this is handy it means we can hard code the response in
                // The decimal values of 110100 001010 are 52 10
                // The base64 mapping values of 52 10 are 0 K
                // See http://en.wikipedia.org/wiki/Base64 for base64 mapping table
                // Therefore, we replace == with 0K
                // Note: if using \n\n instead of \r\n replace == with 'oK'
                last4Bytes = last4Bytes.substring(0, 2) + '0K';
                bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                // We have appended the \r\n to the Blob, so leave footer as it is.
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
            } else if (last4Bytes.endsWith('=')) {
                // '=' indicates that encoded data already contained two out of 3x 8 bit bytes
                // We replace final 8 bit byte with a CR e.g. \r
                // 8 digit binary representation of CR is 00001101
                // Ignore the first 2 bits of 00 001101 they have already been used up as padding
                // for the existing data.
                // The Decimal value of 001101 is 13
                // The base64 value of 13 is N
                // Therefore, we replace = with N
                // Note: if using \n instead of \r replace = with 'K'
                last4Bytes = last4Bytes.substring(0, 3) + 'N';
                bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
                footer = '\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
            } else {
                // Prepend the CR LF to the footer
                footer = '\r\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
            }

            if (!Test.isRunningTest()) {
                Object folderId = trac_WS_Utilities.createRecordFolderBoxApi(file.ParentId, defaultBoxSettings, defaultBoxSettings.Quote_Folder_ID__c);
                trac_WS_Utilities.uploadFiles(boundary, bodyBlob, folderId);
            }
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}