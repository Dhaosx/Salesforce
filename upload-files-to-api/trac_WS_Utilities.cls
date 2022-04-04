/**
 * Created by ahorqque on 2018-07-23.
 */

public with sharing class trac_WS_Utilities {

    /**
    *  @description Parses an XML Response and returns the value of @param tag
    *  @author      Andrea Horqque, Traction on Demand.
    *  @date        2018-07-16
    */

    public static String parseResponse(String response, String tag){
        Dom.Document docx = new Dom.Document();
        docx.load(response);
        dom.XmlNode xroot = docx.getrootelement();
        String sessionId;

        dom.XmlNode [] xrec = xroot.getchildelements() ; //Get all Record Elements

        for(Dom.XMLNode child : xrec) //Loop Through Records
        {
            for (dom.XmlNode awr : child.getchildren() ) {
                if (awr.getname() == tag) {
                    sessionId = awr.gettext();
                }

            }
        }
        return sessionId;
    }


    public static void sendEmail(String subject, String body, List<String> toEmail, List<String> toCC){
        //create new email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toEmail);
        mail.setCcAddresses(toCC);
        mail.subject = subject;
        mail.plainTextBody = body;
        mail.setSaveAsActivity(false);

        //send email
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        } catch(Exception e){
            System.debug('Error : ' + e);
        }
    }

    /**
     *  @description Encode spaces in the name
     *  @author      Andrea Horqque, Traction on Demand.
     *  @date        2018-10-18
     */
    public static string encodeSpecialCharacters(String name){
        if(name==null){
            return null;
        }
        else{
            return EncodingUtil.urlEncode(name, 'UTF-8').replace('+', '%20');
        }
    }

    public static List<String> getCCEmails(){
        List<String> toReturn = new List<String>();
        Group toSendEmail = trac_GroupSelector.getGroupMembersByGroupName(trac_Constants.CC_EMAIL_GROUP_NAME)[0];
        List<id> memberIds= new List<Id>();

        for(GroupMember member : toSendEmail.GroupMembers){
            memberIds.add(member.userOrGroupId);
        }

        List<User> users = [SELECT email FROM User WHERE Id IN :memberIds];
        for(User userToSend : users){
            toReturn.add(userToSend.email);
        }

        return toReturn;
    }

    public static Object createRecordFolderBoxApi(Id recordId, Box_API_Settings__c boxSettings, String parentFolder) {
        Object folderId;
        String objectName = recordId.getSobjectType().getDescribe().getName();
        String body = '{"name":"' + objectName + ' - ' + recordId + '", "parent": {"id":"' + parentFolder + '"}}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        req.setEndpoint('https://api.box.com/2.0/folders');
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + boxSettings.Access_Token__c);

        String jsonString = Json.serialize(body);

        jsonString = jsonString.replace('\\','');
        jsonString = jsonString.replaceFirst('"','');
        jsonString = jsonString.reverse();
        jsonString = jsonString.replaceFirst('"','');
        jsonString = jsonString.reverse();
        req.setBody(jsonString);
        res = http.send(req);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String contextInfo;

        if (results.get('context_info') != null) {
            contextInfo = String.valueOf(results.get('context_info'));
            contextInfo = contextInfo.substring(contextInfo.indexOf('id'));
            contextInfo = contextInfo.substring(0,contextInfo.indexOf(','));
            contextInfo = contextInfo.substring(3);
            folderId = contextInfo;
        } else {
            folderId = results.get('id');
        }

        return folderId;
    }

    public static Object uploadFiles(String boundary, Blob bodyBlob, Object folderId){
        Box_API_Settings__c defaultBoxSettings = trac_BoxSettingsSelector.getOrgDefaults();

        String sUrl = 'https://upload.box.com/api/2.0/files/content?parent_id=' + folderId;
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setMethod('POST');
        req.setEndpoint(sUrl);
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(60000);
        req.setHeader('Authorization', 'Bearer ' + defaultBoxSettings.Access_Token__c);
        req.setHeader('Content-Length', String.valueOf(req.getBodyAsBlob().size()));
        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('TractionDebug res.getBody() ------>' + res.getBody());
        System.debug('TractionDebug res ------>' + res);

        return res;
    }

    public static void deleteAttachments (List<Attachment> attachments) {
        Map<Id,List<Attachment>> attachmentByParentId = new Map<Id, List<Attachment>>();
        Set<Id> parentIds = new Set<Id>();
        String objectName;

        for (Attachment file : attachments) {
            // Sort attachments by the record that they are related to
            objectName = file.ParentId.getSobjectType().getDescribe().getName();
            parentIds.add(file.ParentId);
            if (attachmentByParentId.get(file.ParentId) != null) {
                attachmentByParentId.get(file.ParentId).add(file);
            } else {
                attachmentByParentId.put(file.ParentId, new List<Attachment>{file});
            }
        }

        String query = 'SELECT Attachment__c FROM ' + objectName + ' WHERE Id IN :parentIds';

        List<sObject> lstOfRecords = Database.query(query);
        Set<Id> attachmentsToKeep = new Set<Id>();

        for (sObject obj: lstOfRecords) {
            attachmentsToKeep.add((Id) obj.get('Attachment__c'));
        }

        List<Attachment> attachmentsToDelete = new List<Attachment>();
        if (!attachmentByParentId.isEmpty()) {
            for (Id key : attachmentByParentId.keySet()) {
                if (attachmentByParentId.get(key).size() > 1) {
                    for (Integer i = 0; i < attachmentByParentId.get(key).size(); i++) {
                        if (!attachmentsToKeep.contains(attachmentByParentId.get(key)[i].Id)) {
                            attachmentsToDelete.add(attachmentByParentId.get(key)[i]);
                        }
                    }
                }
            }
            delete attachmentsToDelete;
        }
    }
}