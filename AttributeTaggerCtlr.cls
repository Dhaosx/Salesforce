/**
 * AttributeTaggerCtlr.cls - MetaTagging Project
 * Server-side controller for attributeSelector Lightning component, performs CRD (no update) operations on
 * Attribute_Assignment__c junction object records to link or unlink Attributes from Opps and Projects.
 * @author Grant Adamson, Traction on Demand
 * @date 2016-06-22
 */
public with sharing class AttributeTaggerCtlr {
    public static final String DEFAULT_CATEGORY_NAME = 'Other';

    @TestVisible
    private static AttributeTaggerService attributeTaggerServiceInstance = new AttributeTaggerService();


    /**
     * Return a map of available and selected Attribute records for a given parent object record Id
     * @param  recordId             id of the parent record, currently opportunity and project are supported
     * @return Map<String, Object>  Map containing 'available' and 'selected' lists of Attribute__c
     */
    @AuraEnabled
    public static Map<String, Object> getAvailableAndSelectedItemsForRecordId(Id recordId) {
        List<Attribute_Assignment__c> selectedAttributes =
                attributeTaggerServiceInstance.loadSelectedAttributes(recordId);

        List<Attribute__c> availableAttributes =
                attributeTaggerServiceInstance.loadAttributesExcludingSelected(selectedAttributes);

        List<AttributeCategory> availableAttributesCategoryList = buildSortedCategoryList(availableAttributes);

        return new Map<String, List<Object>>{
                'available' => availableAttributesCategoryList,
                'selected' => selectedAttributes
        };
    }

    /**
     * Return a map of available and selected Attribute records for a given list of Attribute Ids
     * This generates uninserted Attribute Assignment records for the corresponding attribute ids
     * @param  recordId             id of the parent record, currently opportunity and project are supported
     * @return Map<String, Object>  Map containing 'available' and 'selected' lists of Attribute__c
     */
    @AuraEnabled
    public static Map<String, Object> getAvailableAndSelectedItemsForAttributeIds(List<Id> attributeIds) {
        List<Attribute_Assignment__c> selectedAttributes =
                attributeTaggerServiceInstance.loadSelectedAttributes(new Set<Id>(attributeIds));

        List<Attribute__c> availableAttributes =
                attributeTaggerServiceInstance.loadAttributesExcludingSelected(selectedAttributes);

        List<AttributeCategory> availableAttributesCategoryList = buildSortedCategoryList(availableAttributes);

        return new Map<String, List<Object>>{
                'available' => availableAttributesCategoryList,
                'selected' => selectedAttributes
        };
    }

    /**
     * Given a parent record Id and an attribute Id and name, link them
     * @param recordId     id of the parent record
     * @param attributeId  id of attribute
     * @return             the newly created Attribute Assignment record
     */
    @AuraEnabled
    public static Attribute_Assignment__c addAttribute(Id recordId, Id attributeId, String name) {
        try {
            return attributeTaggerServiceInstance.addAttributeAssignment(recordId, attributeId, name);
            // Prevent duplicates, but no need to alert the user
        } catch (AttributeTaggerService.DuplicateAttributeAssignmentException e) {
            return null;
        }
    }

    /**
     * Delete an Attribute Assignment junction record by Id
     * @param attributeAssignmentId   id of Attribute Assignment record to delete
     * @param attributeId             Id of the attribute record the assignment was related to,
     *                                used as unique id for the client-side controller
     * @return                        Id provided in the attributeId parameter
     */
    @AuraEnabled
    public static void removeAttribute(Id attributeAssignmentId) {
        attributeTaggerServiceInstance.deleteAttributeAssignment(attributeAssignmentId);
    }

    /**
     * Given a list of attributes, assemble them into the necessary data structure to pass to the front-end controller
     * for display by category
     * @param availableAttributes   List<Attribute__c>      List of attribute records
     * @return                      List<AttributeCategory> List of AttributeCategory objects, sorted by Category
     */
    private static List<AttributeCategory> buildSortedCategoryList(List<Attribute__c> availableAttributes) {
        Map<String, AttributeCategory> categoryMap = new Map<String, AttributeCategory>();

        String categoryName;
        for (Attribute__c attr : availableAttributes) {
            categoryName = attr.Category__c != null ? attr.Category__c : DEFAULT_CATEGORY_NAME;

            if (!categoryMap.containsKey(categoryName)) {
                categoryMap.put(categoryName, new AttributeCategory(categoryName));
            }

            categoryMap.get(categoryName).attributes.add(attr);
        }

        List<AttributeCategory> categoryList = categoryMap.values();
        categoryList.sort();

        return categoryList;
    }

    /**
     * Custom Data-Transfer Object to get around the fact that Lightning doesn't support using maps in iterations. Also
     * implements custom sort logic
     */
    public class AttributeCategory implements Comparable {
        @AuraEnabled public String name { get; private set; }
        @AuraEnabled public List<Attribute__c> attributes { get; private set; }


        public AttributeCategory(String name) {
            this.name = name;
            this.attributes = new List<Attribute__c>();
        }


        public Integer compareTo(Object compareTo) {
            AttributeCategory concreteCompareTo = (AttributeCategory) compareTo;
            if (name == DEFAULT_CATEGORY_NAME && concreteCompareTo.name != DEFAULT_CATEGORY_NAME) {
                return 1;
            }

            if (name != DEFAULT_CATEGORY_NAME && concreteCompareTo.name == DEFAULT_CATEGORY_NAME) {
                return -1;
            }

            return name.compareTo(concreteCompareTo.name);
        }
    }
}