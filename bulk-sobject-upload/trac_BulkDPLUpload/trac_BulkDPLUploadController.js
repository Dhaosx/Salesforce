/**
 * Created by Jeremy on 8/24/2020.
 */

({
    init: function (component, event, helper) {
        component.set('v.columns', [
            {
                label: 'Product',
                fieldName: 'Product_Name__c',
                type: 'text',
                editable: false,
                typeAttributes: {required: true}
            },
            {label: 'Branch', fieldName: 'Branch_Name__c', type: 'text', editable: false},
            {label: 'Industry', fieldName: 'Industry__c', type: 'text', editable: false},
            {
                label: 'Pricing',
                fieldName: 'Pricing__c',
                type: 'number',
                editable: false,
                typeAttributes: {required: true}
            },
            {
                label: 'Price Currency',
                fieldName: 'Price_Currency__c',
                type: 'text',
                editable: false,
                typeAttributes: {required: true}
            },
            {label: 'UOM', fieldName: 'UOM__c', type: 'text', editable: false},
            {label: 'Quantity', fieldName: 'Quantity__c', type: 'text', editable: false},
            {label: 'Stocked', fieldName: 'Stocked__c', type: 'text', editable: false},
            {label: 'Lead Time', fieldName: 'Lead_Time__c', type: 'text', editable: false},
            {label: 'Effective Date', fieldName: 'Effective_Date__c', type: 'date-local', editable: false},
            {label: 'Expiry Date', fieldName: 'Expiry_Date__c', type: 'date-local', editable: false},
            {label: 'Comment', fieldName: 'Comment__c', type: 'text', editable: false}
        ]);

        helper.getExternalLinks(component, event, helper);
    },

    handleLoad: function (component, event, helper) {
        component.set("v.isLoading", true);
        component.set('v.errors', []);
        helper.createRecordsFromDataApex(component, event, helper);
    },

    handleSave: function (component, event, helper) {
        component.set("v.isLoading", true);
        helper.saveRecordsApex(component, event, helper);
    }
});