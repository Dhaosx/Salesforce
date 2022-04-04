/**
 * @description Create Custom Label class used by Flow to create a Custom Labels using the Metadata API
 * @author Simon Salvatore, Traction on Demand
 * @date March 28, 2022
 */
public with sharing class CustomLabelsModifier implements Metadata.DeployCallback {
    @InvocableMethod(Label='Create_CustomLabels' Description='Create a Custom Label with the provided fields')
    public static void createCustomLabels(List<String> inputParameters) {
        String shortDescription = '';
        String fullName = '';
        String categories = '';
        String value = '';

        if (inputParameters != null && inputParameters[0] != '') {
            String temp = inputParameters[0];
            shortDescription = temp.substring(0, temp.indexOf(','));
            temp = temp.substring(temp.indexOf(',') + 1);
            fullName = temp.substring(0, temp.indexOf(','));
            temp = temp.substring(temp.indexOf(',') + 1);
            categories = temp.substring(0, temp.indexOf(','));
            value = temp.substring(temp.indexOf(',') + 1);
        }

        SafetyCloud.MetadataService.MetadataPort service = SafetyCloud.MetadataServiceExample.createService();
        SafetyCloud.MetadataService.CustomLabel customLabel = new SafetyCloud.MetadataService.CustomLabel();

        customLabel.shortDescription = shortDescription;
        customLabel.fullName = fullName;
        customLabel.categories = categories;
        customLabel.value = value;
        customLabel.language = 'en_US';
        customLabel.protected_x = true;
        List<SafetyCloud.MetadataService.SaveResult> results =
                service.createMetadata(
                        new SafetyCloud.MetadataService.Metadata[]{
                                customLabel
                        });
        SafetyCloud.MetadataServiceExample.handleSaveResults(results[0]);
    }

    @AuraEnabled
    public static String updateCustomLabels(Object data) {
        data = String.valueOf(data).replace('(', '');
        data = String.valueOf(data).replace(')', '');
        List<String> result = String.valueOf(data).split(',');

        SafetyCloud.MetadataService.MetadataPort service = SafetyCloud.MetadataServiceExample.createService();

        Map<String, List<String>> labelValuesByRecord = new Map<String, List<String>>();
        Integer recordNum = 0;
        Boolean increment = false;

        SafetyCloud.MetadataService.Metadata[] customLabels = new SafetyCloud.MetadataService.Metadata[]{
        };
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
                    SafetyCloud.MetadataService.CustomLabel customLabel = new SafetyCloud.MetadataService.CustomLabel();
                    switch on (val.substring(0, val.indexOf('=')).trim()) {
                        when 'MasterLabel' {
                            //customLabel.shortDescription = val.substring(val.indexOf('=') + 1);
                            customLabel.shortDescription = 'TestJEff';
                        }
                        when 'Category' {
                            customLabel.categories = val.substring(val.indexOf('=') + 1);
                        }
                        when 'Value' {
                            customLabel.value = val.substring(val.indexOf('=') + 1);
                        }
                    }
                    customLabel.fullName = 'SafetyCloud_CannotChangeStatus';
                    customLabel.language = 'en_US';
                    customLabel.protected_x = true;

                    customLabels.add(customLabel);
                }
            }
            List<SafetyCloud.MetadataService.SaveResult> results = service.updateMetadata(customLabels);
            SafetyCloud.MetadataServiceExample.handleSaveResults(results[0]);

            /**Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customLabel);
            CustomLabelsModifier callback = new CustomLabelsModifier();
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);**/

            return 'Success: Custom Labels updated successfully';
        } catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('TRAC=======================> SUCCESS: ' + result);
        } else {
            System.debug('TRAC=======================> FAIL: ' + result);
        }
    }
    /**List<Contact> contactsForUpdate = (List<Contact>) JSON.deserialize(
            JSON.serialize(data),
            List<Contact>.class
    );
    try {
        update contactsForUpdate;
        return 'Success: contacts updated successfully';
    } catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }
}**/
}