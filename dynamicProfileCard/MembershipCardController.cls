/**
 * @description Membership Card Controller class to work with the LWC Membership Card
 * @author Simon Salvatore, Salesforce
 * @date July 6, 2022
 */
public with sharing class MembershipCardController {
    @AuraEnabled
    public static ContentVersion getProfilePicture(Id parentId) {
        // Attachment permissions are set in parent object (Contact)
        try {
            return [
                    SELECT Id, Title, LastModifiedDate
                    FROM ContentVersion
                    WHERE FirstPublishLocationId = :parentId
                    ORDER BY LastModifiedDate DESC
                    LIMIT 1
            ];
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = '/' + fileName;
            cv.FirstPublishLocationId = parentId;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            insert (cv);
            return cv.Id;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static Map<String, String> getContactFields(Id recordId) {
        String fields = '';

        List<Schema.FieldSetMember> listFieldSetFields =
                Contact.getSObjectType().getDescribe().fieldSets.getMap().get('MembershipCard_FieldSet').getFields();

        for (FieldSetMember fsm : listFieldSetFields) {
            fields += fsm.getFieldPath() + ', ';
        }

        fields = fields.substring(0, fields.lastIndexOf(','));

        String query = 'SELECT ' + fields + ' FROM Contact WHERE Id =: recordId';
        List<Contact> contacts = Database.query(query);
        Map<String, String> contactsByFields = new Map<String, String>();

        for (FieldSetMember fsm : listFieldSetFields) {
            if (contacts[0].get(fsm.getFieldPath()) instanceof Datetime) {
                Date dateField = (Date) contacts[0].get(fsm.getFieldPath());
                contactsByFields.put(fsm.getLabel(), dateField.format());
            } else {
                contactsByFields.put(fsm.getLabel(), contacts[0].get(fsm.getFieldPath()).toString());
            }
        }

        return contactsByFields;
    }
}