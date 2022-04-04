({
    searchHelper: function (component, event, getInputkeyWord) {
        // call the apex class method
        let action = component.get("c.getLookUpValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName': component.get("v.objectAPIName"),
            'recordType': component.get("v.recordType"),
            'description': component.get("v.description")
        });

        // set a callBack
        action.setCallback(this, function (response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            let state = response.getState();
            if (state === "SUCCESS") {
                let storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length === 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        // enqueue the Action
        $A.enqueueAction(action);
    },
});