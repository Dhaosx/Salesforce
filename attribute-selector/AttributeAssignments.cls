/**
 * Attribute Assignment object domain class
 * @author Grant Adamson, Traction on Demand
 * @date 2017-04-04
 */
public with sharing class AttributeAssignments extends fflib_SObjectDomain {

    public AttributeAssignments(List<Attribute_Assignment__c> sObjectList) {
        super(sObjectList);

        Configuration.disableTriggerCRUDSecurity();
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable2 {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AttributeAssignments(sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType) {
            return new AttributeAssignments(sObjectList);
        }
    }

    public override void onBeforeInsert() {
    }

}