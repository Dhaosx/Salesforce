/**
 * Selector class for Attribute object
 * @author Grant Adamson, Traction on Demand
 * @date   2017-04-21
 */
public class AttributesSelector extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Attribute__c.Id,
                Attribute__c.Attribute__c,
                Attribute__c.Category__c
        };
    }


    public Schema.SObjectType getSObjectType() {
        return Attribute__c.SObjectType;
    }


    public List<Attribute__c> selectById(Set<Id> ids) {
        return (List<Attribute__c>) selectSObjectsById(ids);
    }


    public List<Attribute__c> selectAllExcludingAttributes(Set<String> excludedAttributes) {
        return [
                SELECT Name, Attribute__c, Category__c
                FROM Attribute__c
                WHERE Attribute__c NOT IN :excludedAttributes
                AND Active__c = TRUE
                ORDER BY Category__c, Attribute__c
        ];
    }
}