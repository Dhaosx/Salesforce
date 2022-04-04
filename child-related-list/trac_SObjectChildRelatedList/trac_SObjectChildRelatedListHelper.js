/**
 * Created by ssalvatore on 2/12/2020.
 * Edited by aguillemette on 6/04/2020
 */
({
    getRecords: function (component) {
        var id = component.get('v.recordId');
        var objectName = component.get('v.objectName');
        var queryFilter = component.get('v.queryFilter');
        var fieldList = ''; // component.get("v.fieldList");
        var searchKey = component.get('v.searchKey');
        var secondSearch = component.get('v.secondSearch');
        var limitRecords = component.get('v.limitRecords');

        var action = component.get('c.getRelatedChildren');

        // Extracts field api name from provided list.
        // Possible inputs: "myfield__c|url" or "myfield__c"
        var fieldArray = component.get('v.fieldList').split(',');
        for (var i = 0; i < fieldArray.length; i++) {
            if (fieldArray[i].includes('|')) {
                fieldArray[i] = fieldArray[i]
                    .substring(0, fieldArray[i].indexOf('|'))
                    .trim();
            }
        }
        fieldList = fieldArray.join();

        action.setParams({
            recordId: id,
            sObjectName: objectName,
            queryFilter: queryFilter,
            fieldList: fieldList,
            searchKey: searchKey,
            secondSearch: secondSearch
        });

        action.setCallback(this, function (response) {
            var records = response.getReturnValue();

            if (records != null) {
                records.forEach(function (record) {
                    record.linkName = '/' + record.Id;
                });

                records.forEach((row) => {
                    for (const col in row) {
                        const curCol = row[col];
                        if (typeof curCol === 'object') {
                            const newVal = curCol.Id ? '/' + curCol.Id : null;
                            this.flattenStructure(row, col + '.', curCol);
                            if (newVal === null) {
                                delete row[col];
                            } else {
                                row[col] = newVal;
                            }
                        }
                    }
                });

                var recordList = [];
                if (limitRecords && records.length > 10) {
                    for (var i = 0; i < 10; i++) {
                        recordList.push(records[i]);
                    }
                } else {
                    recordList = records;
                }

                component.set('v.recordCount', records.length);
                component.set('v.recordList', recordList);
            }
        });
        $A.enqueueAction(action);
    },

    deleteRecord: function (component, row) {
        var action = component.get('c.deleteRelatedRecord');
        action.setParams({
            recordId: row.Id,
        });
        action.setCallback(this, function (response) {
            var isSaved = response.getReturnValue();
            // record is saved successfully
            var resultsToast = $A.get('e.force:showToast');
            if (isSaved) {
                resultsToast.setParams({
                    title: 'Deleted',
                    type: 'success',
                    message: 'The record was deleted.',
                });
                component.set('v.deleteRecord', false);
                resultsToast.fire();
            } else {
                resultsToast.setParams({
                    title: 'Error',
                    type: 'error',
                    message: 'There was an issue deleting the record.',
                });
                resultsToast.fire();
            }
            // Refetch records
            this.getRecords(component);
        });
        $A.enqueueAction(action);
    },

    flattenStructure: function (topObject, prefix, toBeFlattened) {
        for (const prop in toBeFlattened) {
            const curVal = toBeFlattened[prop];
            if (typeof curVal === 'object') {
                this.flattenStructure(topObject, prefix + prop + '.', curVal);
            } else {
                topObject[prefix + prop] = curVal;
            }
        }
    },

    // Used to sort the 'Age' column
    sortBy: function (component, fieldName, sortDirection) {
        var data = component.get("v.recordList");
        var type;
        //function to return the value stored in the field
        var key = function (a) {
            type = typeof a[fieldName];
            return a[fieldName];
        }
        var reverse = sortDirection == 'asc' ? 1 : -1;
        
        if (type === 'number' || type === undefined) {
            data.sort(function (a, b) {
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a > b) - (b > a));
            });
        } else {
            data.sort(function (a, b) {
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a > b) - (b > a));
            });
        }
        //set sorted data to accountData attribute
        component.set("v.recordList", data);
    }
})
;