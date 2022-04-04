/**
 * Created by Jeremy on 9/12/2020.
 */

({
    createRecordsFromDataApex: function (component, event, helper) {
        let apexAction = component.get("c.createRecordsFromData");

        const inputValue = component.get('v.inputValue');

        apexAction.setParams({
            "tabDelimitedInput": inputValue
        });
        apexAction.setCallback(this, function (response) {
            let state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();

                if (result == null) {
                    component.set("v.isError", true);
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if (result.isSuccess) {
                        let dplList = result.returnValuesMap['dplList'];
                        let rowErrors = {rows: {}};
                        let numErrors = 0;

                        for (let i = 0; i < dplList.length; i++) {
                            dplList[i].RowId = i + 1;
                            if (dplList[i].Product__c == '' || dplList[i].Branch_Name__c == '' ||
                                dplList[i].Pricing__c == '' || dplList[i].Price_Currency__c == '' ||
                                dplList[i].Quantity__c == '' || dplList[i].UOM__c == '' ||
                                dplList[i].Expiry_Date__c == undefined) {
                                rowErrors.rows[i + 1] = {
                                    title: 'Error',
                                    messages: ['One or more columns in this row have invalid data']
                                };
                                numErrors += 1;
                            }
                        }

                        if (numErrors != 0) {
                            component.set("v.disableButton", true);
                        } else {
                            component.set("v.disableButton", false);
                        }

                        component.set("v.data", dplList);
                        component.set("v.errors", rowErrors);
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }

            component.set("v.isLoading", false);
        });

        $A.enqueueAction(apexAction);
    },

    saveRecordsApex: function (component, event, helper) {
        let apexAction = component.get("c.createDPLRecords");

        let values = component.get("v.data");

        apexAction.setParams({
            "dplRecords": JSON.stringify(values)
        });
        apexAction.setCallback(this, function (response) {
            let state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();
                let mapSize = 0;

                for (let count in result.returnValuesMap) {
                    mapSize++;
                }

                if (result == null) {
                    component.set("v.isError", true);
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if (result.isSuccess) {
                        let recordCount = result.returnValuesMap['recordCount'];
                        helper.showToast(recordCount + " records created", "success", 'Success');
                    } else {
                        let rowErrors = {rows: {}};

                        for (let i = 0; i < mapSize; i++) {
                            if (result.returnValuesMap[i]) {
                                rowErrors.rows[i + 1] = {
                                    title: 'Error',
                                    messages: ['One or more columns in this row have invalid data']
                                };
                            }
                        }

                        component.set("v.errors", rowErrors);
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                        component.set("v.isLoading", false);
                    }
                }
            } else {
                console.log("failed with state: " + state);
                console.log(response);
            }

            component.set("v.isLoading", false);
        });

        $A.enqueueAction(apexAction);
    },

    showToast: function (message, type, title) {
        let resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        resultsToast.fire();
    },

    getExternalLinks: function (component, event, helper) {
        let apexAction = component.get("c.getCustomExternalSetting");

        apexAction.setCallback(this, function (response) {
            let state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.externalLinks", result);
            }
        });

        $A.enqueueAction(apexAction);
    }
});