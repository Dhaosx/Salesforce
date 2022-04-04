/**
 * Selector class for Attribute Assignments object
 * @author Grant Adamson, Traction on Demand
 * @date   2017-04-21
 */
public class AttributeAssignmentsSelector extends fflib_SObjectSelector {
    public static final String INVALID_OBJECT_TYPE = 'The Attribute Assignment SObject does not support this type of parent record';

    private static final String SELECT_BY_PARENT_QUERY_TEMPLATE =
            'SELECT Id, Name, Contact__c, Attribute__c' +
                    ' FROM Attribute_Assignment__c' +
                    ' WHERE {0} = :parentId' +
                    ' ORDER BY Name';

    private static final String DUPE_COUNT_QUERY_TEMPLATE =
            'SELECT COUNT()' +
                    ' FROM Attribute_Assignment__c' +
                    ' WHERE {0} = :parentId' +
                    ' AND Attribute__c = :name';

    private static final Integer MAXIMUM_RESULT_COUNT = 100;

    private static final String LIKE_ASSIGNMENTS_QUERY_TEMPLATE =
            'SELECT Name, {0}, Attribute__c' +
                    ' FROM Attribute_Assignment__c' +
                    ' WHERE Attribute__c IN :attributeIds' +
                    ' AND {0} != null' +
                    ' LIMIT ' + MAXIMUM_RESULT_COUNT;

    private static final String LIKE_ASSIGNMENTS_EXCLUDE_PARENT_QUERY_TEMPLATE =
            'SELECT Name, {0}, Attribute__c' +
                    ' FROM Attribute_Assignment__c' +
                    ' WHERE Attribute__c IN :attributeIds' +
                    ' AND {0} != null' +
                    ' AND {1} != :parentId' +
                    ' LIMIT ' + MAXIMUM_RESULT_COUNT;


    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Attribute_Assignment__c.Id,
                Attribute_Assignment__c.Contact__c,
                Attribute_Assignment__c.Account__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Attribute_Assignment__c.SObjectType;
    }


    public List<Attribute_Assignment__c> selectById(Set<Id> ids) {
        return (List<Attribute_Assignment__c>) selectSObjectsById(ids);
    }


    /**
     * Given a parent record Id, load all the attribute assignment junction records related to it
     * As the object supports multiple types of parent records, the correct lookup must be dynamically determined from the
     * SObjectType of the record Id
     * @param  parentId parent record id
     * @return List of Attribute_Assignment__c records
     */
    public List<Attribute_Assignment__c> selectByParentId(Id parentId) {
        String queryString = String.format(SELECT_BY_PARENT_QUERY_TEMPLATE,
                new String[]{
                        getLookupFieldFromIdType(parentId)
                });

        //remove duplicates in query result (for merging duplicate contacts)
        List<Attribute_Assignment__c> selectedAttributeAssignments = Database.query(queryString);

        Set<Attribute_Assignment__c> uniqueAttributeAssignments = new Set<Attribute_Assignment__c>();
        Set<Id> uniqueAttributeIds = new Set<Id>();
        List<Attribute_Assignment__c> duplicateAssignmentAttributes = new List<Attribute_Assignment__c>();

        for (Attribute_Assignment__c aa : selectedAttributeAssignments) {

            if (uniqueAttributeIds.contains(aa.Id) && aa.Contact__c == parentId) {
                duplicateAssignmentAttributes.add(aa);
            } else {
                uniqueAttributeIds.add(aa.Id);
                uniqueAttributeAssignments.add(aa);
            }
        }

        if (!duplicateAssignmentAttributes.isEmpty()) {
            delete duplicateAssignmentAttributes;
        }
        return new List<Attribute_Assignment__c>(uniqueAttributeAssignments); // convert set to list
    }


    /**
     * Given a parent record Id and an attribute Id, return a count of records matching these
     * Used for duplicate prevention
     * As the object supports multiple types of parent records, the correct lookup must be dynamically determined from the
     * SObjectType of the record Id
     * @param  parentId    parent record id
     * @param  attributeId attribute record id
     * @return             Count of matching records
     */
    public Integer selectCountByParentIdAndAttributeId(Id parentId, String name) {
        String queryString = String.format(DUPE_COUNT_QUERY_TEMPLATE,
                new String[]{
                        getLookupFieldFromIdType(parentId)
                });

        return Database.countQuery(queryString);
    }


    public List<Attribute_Assignment__c> selectByAttributeIdAndSObjectType(Set<Id> attributeIds, SObjectType sObjType) {
        String searchLookupField = getLookupFieldFromType(sObjType);

        String query = String.format(LIKE_ASSIGNMENTS_QUERY_TEMPLATE, new String[]{
                searchLookupField
        });

        return Database.query(query);
    }

    public List<Attribute_Assignment__c> selectByAttributeIdAndSObjectTypeExcludingParentId(Set<Id> attributeIds,
            SObjectType sObjType, Id parentId) {
        String currentRecordLookupField = getLookupFieldFromIdType(parentId);
        String searchLookupField = getLookupFieldFromType(sObjType);

        String query = String.format(LIKE_ASSIGNMENTS_EXCLUDE_PARENT_QUERY_TEMPLATE,
                new String[]{
                        searchLookupField, currentRecordLookupField
                });

        return Database.query(query);
    }

    public List<Attribute_Assignment__c> selectByAccountIdAndCategory(Set<Id> accountIds, Set<String> categories) {
        fflib_QueryFactory qf = newQueryFactory(false, false, true)
                .selectFields(getSObjectFieldList())
                .setCondition('Account__c IN :accountIds');

        return Database.query(qf.toSOQL());
    }

    public List<Attribute_Assignment__c> selectByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory qf = newQueryFactory(false, false, true)
                .selectFields(getSObjectFieldList())
                .setCondition('Account__c IN :accountIds ');

        return Database.query(qf.toSOQL());
    }


    /**
     * Given a record Id, return the name of the lookup for the object type that the Id is associated with
     * @param  recordId record Id
     * @return String containing the name of the lookup corresponding with the id type
     */
    public static String getLookupFieldFromIdType(Id recordId) {
        SObjectType sObjectType = recordId.getSobjectType();

        return getLookupFieldFromType(sObjectType);
    }


    /**
     * Given a record Id, return the name of the lookup for the object type that the Id is associated with
     * @param  recordId record Id
     * @return String containing the name of the lookup corresponding with the id type
     */
    public static String getLookupFieldFromType(SObjectType sObjType) {

        if (sObjType == Account.SObjectType) {
            return 'Account__c';
        }

        if (sObjType == Contact.SObjectType) {
            return 'Contact__c';
        }

        throw new UnsupportedSObjectTypeException(INVALID_OBJECT_TYPE);
    }


    public class UnsupportedSObjectTypeException extends Exception {
    }
}