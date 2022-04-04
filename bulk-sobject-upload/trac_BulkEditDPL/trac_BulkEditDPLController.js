/**
 * Created by Jeremy on 8/17/2020.
 */

({
    init: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'DPL Number', fieldName: 'Name', type: 'text', editable: false, typeAttributes: {required: true}},
            {
                label: 'Product',
                fieldName: 'ProductName',
                type: 'text',
                editable: false,
                typeAttributes: {required: true}
            },
            // {label: 'Code', fieldName: 'CodeLU__c', type: 'text', editable: false, typeAttributes: { required: true }},
            // {label: 'Company', fieldName: 'Company__c', type: 'text', editable: false, typeAttributes: { required: true }},
            {
                label: 'Pricing',
                fieldName: 'Pricing__c',
                type: 'number',
                editable: true,
                typeAttributes: {required: true}
            },
            {
                label: 'Price Currency',
                fieldName: 'Price_Currency__c',
                type: 'text',
                editable: false,
                typeAttributes: {required: true}
            },
            {label: 'Branch', fieldName: 'BranchName', type: 'text', editable: false},
            {label: 'Industry', fieldName: 'Industry__c', type: 'text', editable: true},
            {label: 'Stocked', fieldName: 'Stocked__c', type: 'text', editable: true},
            {label: 'Comment', fieldName: 'Comment__c', type: 'text', editable: true},
            {label: 'Lead Time', fieldName: 'Lead_Time__c', type: 'text', editable: true},
            {label: 'UOM', fieldName: 'UOM__c', type: 'text', editable: true},
            {label: 'Quantity', fieldName: 'Quantity__c', type: 'text', editable: true},
            {label: 'Effective Date', fieldName: 'Effective_Date__c', type: 'date-local', editable: true},
            {label: 'Expiry Date', fieldName: 'Expiry_Date__c', type: 'date-local', editable: true}
        ]);

    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isLoading", true);
        event.preventDefault();
        const fields = event.getParam('fields');

        if (fields) {
            component.set('v.searchFields', fields);
            helper.getDPLFromSearchApex(component, event, helper);
        }
    },

    handleSave: function (component, event, helper) {
        const draftValues = event.getParam('draftValues');

        helper.saveRecordsApex(component, event, helper, draftValues);
    },

    handleUpdate: function (component, event, helper) {
        const selectedOptionValue = component.get('v.selectedOption');
        const records = component.get('v.data');
        if (records) {
            let draftValues = component.get('v.draftValues');
            if (!draftValues) {
                draftValues = [];
            }
            if (selectedOptionValue === 'Amount') {
                const selectedOptionAmount = component.get('v.amountChange');
                for (let i = 0; i < records.length; i++) {
                    let existing;
                    for (let j = 0; j < draftValues.length; j++) {
                        if (draftValues[j].Id === records[i].Id) {
                            existing = draftValues[j];
                        }
                    }

                    const amount = +records[i].Pricing__c + +selectedOptionAmount;
                    if (existing) {
                        existing.Pricing__c = amount;
                    } else {
                        draftValues.push({Id: records[i].Id, Pricing__c: amount});
                    }
                }
            }

            if (selectedOptionValue === 'Percent') {
                const selectedOptionPercent = component.get('v.percentChange');
                for (let i = 0; i < records.length; i++) {
                    let existing;
                    for (let j = 0; j < draftValues.length; j++) {
                        if (draftValues[j].Id === records[i].Id) {
                            existing = draftValues[j];
                            break;
                        }
                    }
                    const amount = records[i].Pricing__c * (1 + (parseFloat(selectedOptionPercent) / 100));

                    if (existing) {
                        existing.Pricing__c = amount;
                    } else {
                        draftValues.push({
                            Id: records[i].Id,
                            Pricing__c: amount
                        });
                    }
                }
            }
            component.set('v.draftValues', draftValues);
        }
    }
});