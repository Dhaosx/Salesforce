public class AttributeTaggerService {
    public static final String DUPLICATE_ATTRIBUTE_ERROR_MSG =
            'Duplicate Attribute Assignment. A record with the provided Parent Id and Attribute Id already exists';

    @TestVisible
    private static AttributesSelector attributesSelectorInstance = new AttributesSelector();
    @TestVisible
    private static AttributeAssignmentsSelector attributeAssignmentsSelectorInstance =
            new AttributeAssignmentsSelector();

    /**
     * Load a list of selected attributes for a given record Id
     * @param  recordId Record Id to load attributes for
     * @return          List of Attribute Assignment junction records
     */
    public List<Attribute_Assignment__c> loadSelectedAttributes(Id recordId) {
        return attributeAssignmentsSelectorInstance.selectByParentId(recordId);
    }


    /**
     * Load a list of selected attributes for a set of Attribute Ids
     * This will create new Attribute Assignment objects (but not insert them)
     * @param  recordId Record Id to load attributes for
     * @return          List of Attribute Assignment junction records
     */
    public List<Attribute_Assignment__c> loadSelectedAttributes(Set<Id> attributeIds) {
        if (attributeIds == null || attributeIds.isEmpty()) {
            return new List<Attribute_Assignment__c>();
        }

        List<Attribute__c> attributes = attributesSelectorInstance.selectById(attributeIds);

        List<Attribute_Assignment__c> assignments = new List<Attribute_Assignment__c>();
        for (Attribute__c attr : attributes) {
            assignments.add(new Attribute_Assignment__c(
                    Attribute__c = attr.Attribute__c
            ));
        }

        return assignments;
    }


    /**
     * Load a list of all available Attribute records, excluding any already referenced in selected
     * @param select    List of existing attribute assignments, whose attributes should be excluded from query results
     * @return          List of available attribute records
     */
    public List<Attribute__c> loadAttributesExcludingSelected(List<Attribute_Assignment__c> selected) {
        Set<String> attributeIdsToExclude = new Set<String>();

        for (Attribute_Assignment__c aa : selected) {
            attributeIdsToExclude.add(aa.Attribute__c);
        }

        return attributesSelectorInstance.selectAllExcludingAttributes(attributeIdsToExclude);
    }

    /**
     * Create a new Attribute Assignment record junction
     * @param parentId    Id of the parent record
     * @param attributeId Id of the attribute
     * @param name        Name of the attribute (to save a query determining what it is)
     * @return            Id of the Attribute Assignment record that was created
     */
    public Attribute_Assignment__c addAttributeAssignment(Id parentId, Id attributeId, String name) {
        // if a duplicate exists (another user is tagging at the same time?), prevent inserting the new junction record
        if (isDuplicateAttribute(parentId, name)) {
            throw new DuplicateAttributeAssignmentException(DUPLICATE_ATTRIBUTE_ERROR_MSG);
        }

        Attribute_Assignment__c aa = new Attribute_Assignment__c(
                Attribute__c = name
        );
        aa.put(AttributeAssignmentsSelector.getLookupFieldFromIdType(parentId), parentId);

        insert aa;
        return aa;
    }

    private static Boolean isDuplicateAttribute(Id parentId, String name) {
        return attributeAssignmentsSelectorInstance.selectCountByParentIdAndAttributeId(parentId, name) > 0;
    }

    /**
     * Delete the attribute assignment with the corresponding Id
     * @param attributeAssignmentId Id of record to delete
     * @param attributeId           Id of the attribute that the assignment was related to.
     *                              Returned so the client-side ctlr has a unique id to reference for this delete action
     * @return                      value passed in the attribute Id parameter
     */
    public void deleteAttributeAssignment(Id attributeAssignmentId) {
        Attribute_Assignment__c recordToDelete = new Attribute_Assignment__c(Id = attributeAssignmentId);

        delete recordToDelete;
        Database.emptyRecycleBin(recordToDelete);
    }

    public class DuplicateAttributeAssignmentException extends Exception {
    }
}