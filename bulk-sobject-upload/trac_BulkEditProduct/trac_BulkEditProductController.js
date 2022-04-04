/**
 * Created by ssalvatore on 11/12/2020.
 */
({
    init: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Product Name', fieldName: 'Name', type: 'text', editable: false, typeAttributes: {required: true}},
            {
                label: 'Product Codes',
                fieldName: 'Product_Codes__c',
                type: 'text',
                editable: false,
                typeAttributes: {required: true}
            },
            {
                label: 'Business Unit/Group',
                fieldName: 'Group__c',
                type: 'text',
                editable: false,
                typeAttributes: {required: true}
            },
            {
                label: 'Product Specialist',
                fieldName: 'ProductSpecialist',
                type: 'text',
                editable: false,
                typeAttributes: {required: true}
            },
            {label: 'Product Manager', fieldName: 'ProductManager', type: 'text', editable: false},
            {label: 'Supplier Name', fieldName: 'SupplierName', type: 'text', editable: false},
            {label: 'Supplier JD Edwards Id', fieldName: 'JDEdwardsId', type: 'text', editable: false},
            {label: 'Commodity Code', fieldName: 'CommodityCode', type: 'text', editable: false},
            {label: 'Commodity Family', fieldName: 'CommodityFamily', type: 'text', editable: false}
        ]);

        helper.getMaxRows(component);
    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isLoading", true);
        event.preventDefault();
        let fields = {};
        let inputs = component.find('inputDiv').find({instancesOf: "lightning:inputField"});
        const length = inputs.length;
        for (let index = 0; index < length; ++index) {
            let fieldName = inputs[index].get('v.fieldName');
            let value = inputs[index].get('v.value');
            if (inputs[index].get('v.value') != null || inputs[index].get('v.value') != undefined) {
                fields[fieldName] = value;
            }
        }

        if (fields) {
            component.set('v.searchFields', fields);
            helper.getProductFromSearchApex(component, event, helper);
        }
    },

    handleSave: function (component, event, helper) {
        component.set("v.isLoading", true);
        const toBeSaved = component.get('v.toBeSaved');
        console.log('savingggg');

        helper.saveRecordsApex(component, event, helper, toBeSaved);
    },

    handleCancel: function (component, event, helper) {
        component.set('v.draftValues', '');
        component.set('v.toBeSaved', '');
    },

    handleUpdate: function (component, event, helper) {
        const selectedOptionValue = component.get('v.selectedOption');
        const records = component.get('v.selectedRows').length ? component.get('v.selectedRows') : component.get('v.data');
        const selectedUserId = component.get('v.selectedUser.Id');
        const selectedUserName = component.get('v.selectedUser.Name');
        if (records) {
            let draftValues = component.get('v.draftValues');
            let toBeSaved = [];
            if (!draftValues) {
                draftValues = [];
            }
            if (selectedOptionValue === 'Product Specialist') {
                for (let i = 0; i < records.length; i++) {
                    let existing;
                    for (let j = 0; j < draftValues.length; j++) {
                        if (draftValues[j].Id === records[i].Id) {
                            existing = draftValues[j];
                        }
                    }

                    if (existing) {
                        existing.ProductSpecialist = selectedUserName;
                    } else {
                        draftValues.push({Id: records[i].Id, ProductSpecialist: selectedUserName});
                    }
                    toBeSaved.push({Id: records[i].Id, Product_Coordinator__c: selectedUserId});
                }
            }

            if (selectedOptionValue === 'Product Manager') {
                for (let i = 0; i < records.length; i++) {
                    let existing;
                    for (let j = 0; j < draftValues.length; j++) {
                        if (draftValues[j].Id === records[i].Id) {
                            existing = draftValues[j];
                        }
                    }

                    if (existing) {
                        existing.ProductManager = selectedUserName;
                    } else {
                        draftValues.push({Id: records[i].Id, ProductManager: selectedUserName});
                    }
                    toBeSaved.push({Id: records[i].Id, Product_Manager__c: selectedUserId});
                }
            }

            component.set('v.toBeSaved', toBeSaved);
            component.set('v.draftValues', draftValues);
        }
    },

    handleSelect: function (component, event, helper) {
        let selectedRows = event.getParam('selectedRows');
        let setRows = [];
        for (let i = 0; i < selectedRows.length; i++) {
            setRows.push(selectedRows[i]);
        }

        if (selectedRows.length >= component.get('v.maxRowSelection')) {
            alert('We cannot update more than ' + component.get('v.maxRowSelection') + ' records at a time. At present ' + selectedRows.length  + ' are selected');
        }

        component.set("v.selectedRows", setRows);
    }
});