/**
 * Created by ssalvatore on 2/12/2020.
 * Edited by aguillemette on 6/04/2020
 */
({
    doInit: function (component, event, helper) {
        helper.getRecords(component);
        var actions = [
            {label: 'Edit', name: 'edit'},
            {label: 'Delete', name: 'delete'},
        ];

        var columns = [];

        if (component.get('v.fieldList') != undefined) {
            var fieldArray = component.get('v.fieldList').split(',');
            var displayName = component.get('v.fieldNames').split(',');

            for (var i = 0; i < fieldArray.length; i++) {
                if (i == 0) {
                    columns.push({
                        label: displayName[i],
                        fieldName: 'linkName',
                        sortable: true,
                        type: 'url',
                        cellAttributes: {alignment: 'left'},
                        typeAttributes: {
                            label: {fieldName: fieldArray[i]},
                            target: '_blank',
                        },
                    });
                } else {
                    var fieldAPIName = fieldArray[i];
                    var fieldType = 'text';

                    // Extracts field api name and type from provided list.
                    // Possible inputs: "myfield__c|url" or "myfield__c"
                    if (fieldArray[i].includes('|')) {
                        var charIndex = fieldArray[i].indexOf('|');
                        fieldAPIName = fieldArray[i]
                            .substring(0, charIndex)
                            .trim();
                        fieldType = fieldArray[i]
                            .substring(charIndex + 1)
                            .trim();
                    }

                    columns.push({
                        label: displayName[i],
                        fieldName: fieldAPIName,
                        sortable: true,
                        type: fieldType,
                        cellAttributes: {
                            alignment: 'left',
                        },
                    });
                }
            }

            columns.push({
                type: 'action',
                typeAttributes: {rowActions: actions},
            });
        }

        component.set('v.columns', columns);
    },

    cancelDelete: function (component) {
        component.set('v.deleteRecord', false);
    },

    removeRecord: function (component, event, helper) {
        var row = component.get('v.row');
        helper.deleteRecord(component, row);
    },

    handleRowAction: function (component, event) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set('v.row', row);

        switch (action.name) {
            case 'edit':
                var editRecordEvent = $A.get('e.force:editRecord');
                editRecordEvent.setParams({
                    recordId: row.Id,
                });
                editRecordEvent.fire();
                break;
            case 'delete':
                component.set('v.deleteRecord', true);
                break;
        }
    },

    openRelatedList: function (component, _event) {
        var relatedListEvent = $A.get('e.force:navigateToComponent');
        relatedListEvent.setParams({
            componentDef: 'c:trac_SObjectChildRelatedList',
            componentAttributes: {
                recordList: component.get('v.recordList'),
                recordId: component.get('v.recordId'),
                columns: component.get('v.columns'),
                recordCount: component.get('v.recordCount'),
                displayName: component.get('v.displayName'),
                objectName: component.get('v.objectName'),
                queryFilter: component.get('v.queryFilter'),
                iconName: component.get('v.iconName'),
                fieldList: component.get('v.fieldList'),
                fieldNames: component.get('v.fieldNames'),
                searchKey: component.get('v.searchKey'),
                secondSearch: component.get('v.secondSearch'),
                limitRecords: false,
            },
        });
        relatedListEvent.fire();
    },

    handleSort: function (component, event, helper) {
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortedBy", sortBy);
        component.set("v.sortDirection", sortDirection);
        // call sortData helper function
        helper.sortBy(component, sortBy, sortDirection);
    }
});