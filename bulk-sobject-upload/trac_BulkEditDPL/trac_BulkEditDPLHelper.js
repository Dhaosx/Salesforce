/**
 * Created by Jeremy on 8/17/2020.
 */

({
    getDPLFromSearchApex: function(component, event, helper){
        let apexAction = component.get("c.getDPLFromSearch");

        const fields = component.get('v.searchFields');

        apexAction.setParams({
            "searchFields": JSON.stringify(fields)
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
                        for (let i = 0; i < dplList.length; i++) {
                            if (dplList[i].Product__c) {
                                dplList[i].ProductName = dplList[i].Product__r.Name;
                            }
                            if (dplList[i].Branch_lookup__c) {
                                dplList[i].BranchName = dplList[i].Branch_lookup__r.Name;
                            }
                        }
                        component.set("v.data", dplList);
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

    saveRecordsApex: function(component, event, helper, values){
        let apexAction = component.get("c.updateDPLRecords");

        apexAction.setParams({
            "dplRecords": JSON.stringify(values)
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
                        component.set('v.draftValues', []);
                        helper.getDPLFromSearchApex(component, event, helper);
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
    }
});