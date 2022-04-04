/**
 * @description Create Custom Label class used by Flow to create a Custom Labels using the Metadata API
 * @author Simon Salvatore, Traction on Demand
 * @date March 28, 2022
 */
public with sharing class CreateCustomLabels {
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
}