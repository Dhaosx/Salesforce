/**
 * Created by SimonSalvatore on 2021-10-08.
 */

({
    getData: function (component) {
        let action = component.get("c.getTractionites");

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set('v.tractionites', result);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
});