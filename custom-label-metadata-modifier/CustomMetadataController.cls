/**
 * @description Custom Metadata Controller used by Flow to get and return Custom Metadata records
 * @author Simon Salvatore, Traction on Demand
 * @date March 22, 2022
 */
public with sharing class CustomMetadataController {
    @AuraEnabled(Cacheable=true)
    public static DataTableResponse getWrapperOfSObjectFieldColumnActionValues(String TableName) {
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        List<SObject> lstDataTableData = new List<SObject>();
        List<String> columnList = new List<String>();
        List<String> fieldAPINameList = new List<String>();

        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(TableName).getDescribe().fields.getMap();
        String fields = '';

        if (fieldMap.values() != null) {
            for (String key : fieldMap.keySet()) {
                if (String.valueOf(fieldMap.get(key)) != 'Id' &&
                        String.valueOf(fieldMap.get(key)) != 'Language' &&
                        String.valueOf(fieldMap.get(key)) != 'NamespacePrefix' &&
                        String.valueOf(fieldMap.get(key)) != 'QualifiedApiName') {
                    columnList.add('' + fieldMap.get(key));
                    fieldAPINameList.add(fieldMap.get(key) + ':text');
                    fields += fieldMap.get(key) + ',';
                }
            }
        }

        for (Integer i = 0; i < columnList.size(); i++) {
            Boolean editable = true;
            if (fieldAPINameList[i].substringBefore(':').trim() == 'MasterLabel') {
                editable = false;
            } else {
                editable = true;
            }
            DataTableColumns dataColumns = new DataTableColumns(columnList[i].trim(),
                    fieldAPINameList[i].substringBefore(':').trim(),
                    fieldAPINameList[i].substringAfter(':').trim(),
                    editable);

            lstDataColumns.add(dataColumns);
        }

        fields = fields.removeEnd(',');
        String query = 'SELECT ' + fields + ' FROM ' + TableName;
        for (SObject SObjectItem : Database.query(query)) {
            lstDataTableData.add(SObjectItem);
        }

        DataTableResponse finalWrapper = new DataTableResponse();
        finalWrapper.lstDataTableColumns = lstDataColumns;
        finalWrapper.lstDataTableData = lstDataTableData;
        return finalWrapper;
    }

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('SUCCESS: ' + result);
        } else {
            System.debug('FAIL: ' + result);
        }
    }

    @AuraEnabled
    public static String updateCustomMetadata(String customerMetadataType, Object data) {
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = customerMetadataType + '.' + 'Update';
        customMetadata.label = 'Update';
        data = String.valueOf(data).replace('(', '');
        data = String.valueOf(data).replace(')', '');
        List<String> result = String.valueOf(data).split(',');


        Map<String, List<String>> labelValuesByRecord = new Map<String, List<String>>();
        Integer recordNum = 0;
        Boolean increment = false;

        for (String entry : result) {
            if (labelValuesByRecord.get('Record' + recordNum) != null) {
                if (entry.endsWith('}')) {
                    entry = entry.replace('}', '');
                    increment = true;
                }

                labelValuesByRecord.get('Record' + recordNum).add(entry);

                if (increment) {
                    recordNum++;
                    increment = false;
                }
            } else {
                entry = entry.replace('{', '');
                labelValuesByRecord.put('Record' + recordNum, new List<String>{
                        entry
                });
            }
        }

        try {
            for (String key : labelValuesByRecord.keySet()) {
                for (String val : labelValuesByRecord.get(key)) {
                    Metadata.CustomMetadataValue customMetadataValue = new Metadata.CustomMetadataValue();
                    customMetadataValue.field = val.substring(0, val.indexOf('=')).trim();
                    customMetadataValue.value = val.substring(val.indexOf('=') + 1);
                    customMetadata.values.add(customMetadataValue);
                }
            }

            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            CustomLabelsModifier callback = new CustomLabelsModifier();
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

            return 'Success: Custom Labels updated successfully';
        } catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    public class DataTableColumns {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public Boolean editable { get; set; }

        public DataTableColumns(String label, String fieldName, String type, Boolean editable) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.editable = editable;
        }
    }

    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns { get; set; }
        @AuraEnabled
        public List<SObject> lstDataTableData { get; set; }
    }
}