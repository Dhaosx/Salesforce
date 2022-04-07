/**
 * @description  BackupMergedContactHandler_TDTM - Backup external ID of deleted record on merge operation
 * @author Vinti Ajmera
 * @date - 6-12-2021
 *
 * @modified Simon Salvatore - Modified static field names for dynamic fields in custom metadata
 */
global class BackupMergedContactHandler_TDTM extends npsp.TDTM_Runnable {

    global override npsp.TDTM_Runnable.DmlWrapper run(
            List<SObject> newList,
            List<SObject> oldList,
            npsp.TDTM_Runnable.Action triggerAction,
            Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Contact> oldConList = (List<Contact>) oldList;
        List<Merge_Keys__c> mergedKeyList = new List<Merge_Keys__c>();
        List<ContactMergeKeyFields__mdt> contactMergeKeyMeta = [SELECT ContactFieldName__c, MergeKeyFieldName__c FROM ContactMergeKeyFields__mdt];
        List<MasterContactMergeKeyFields__mdt> masterContactMergeKeyMeta = [SELECT ContactFieldName__c, MergeKeyFieldName__c FROM MasterContactMergeKeyFields__mdt];

        Id masterRecordId;

        //After Delete Trigger Action
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterDelete) {
            //code snippet executes in case of Merge of duplicate records
            for (Contact con : oldConList) {
                if (String.isNotBlank(con.MasterRecordId)) {
                    Merge_Keys__c newMergeKey = new Merge_Keys__c();
                    masterRecordId = con.MasterRecordId;
                    for (ContactMergeKeyFields__mdt metaDataItem : contactMergeKeyMeta) {
                        //Add the field mapping to Merge_Keys__c object to backup deleted record Id
                        newMergeKey.put(metaDataItem.MergeKeyFieldName__c, con.get(metaDataItem.ContactFieldName__c));
                    }
                    mergedKeyList.add(newMergeKey);
                }
            }

            Contact masterContact = new Contact();
            if (masterRecordId != null) {
                masterContact = [SELECT Id, Constituent_ID__c, Legacy_ID__c FROM Contact WHERE Id = :masterRecordId LIMIT 1];

                for (Merge_Keys__c mergeKey : mergedKeyList) {
                    for (MasterContactMergeKeyFields__mdt metaDataItem : masterContactMergeKeyMeta) {
                        //Add the field mapping to Merge_Keys__c object to backup deleted record Id
                        mergeKey.put(metaDataItem.MergeKeyFieldName__c, masterContact.get(metaDataItem.ContactFieldName__c));
                    }
                }
            }

            if (mergedKeyList.size() > 0) {
                dmlWrapper.objectsToInsert.addAll((List<SObject>) mergedKeyList);
            }

        }
        return dmlWrapper;
    }
}