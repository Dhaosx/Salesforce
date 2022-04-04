({
    fetchReportData: function (component) {
        var action = component.get("c.getReportData");

        action.setParams({
            "accountId": component.get('v.AccountId'),
            "productId": component.get('v.ProductId')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var map = response.getReturnValue();
                var parsingWarpper = [];

                Object.keys(map).forEach(function (key) {

                    var individualElement = {};
                    individualElement.Id = key;
                    individualElement.Value = [];
                    var innerMapObject = map[key];

                    //Iterate over the key for Inner  Map
                    Object.keys(innerMapObject).forEach(function (key2) {
                        var innerIndividualElement = {};
                        innerIndividualElement.Key = key2;
                        innerIndividualElement.Value = innerMapObject[key2];

                        individualElement.Value.push(innerIndividualElement);
                    });
                    parsingWarpper.push(individualElement);
                });
                component.set("v.aggregateResults", parsingWarpper);
            }
        });

        $A.enqueueAction(action);
    }
});