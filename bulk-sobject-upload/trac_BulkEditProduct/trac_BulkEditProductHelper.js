/**
 * Created by ssalvatore on 11/12/2020.
 */
({
    getProductFromSearchApex: function(component, event, helper){
        let apexAction = component.get("c.getProductFromSearch");

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
                        let productList = result.returnValuesMap['productList'];
                        for (let i = 0; i < productList.length; i++) {
                            if (productList[i].Product__c) {
                                productList[i].ProductName = productList[i].Name;
                            }
                            try{
                                productList[i].SupplierName = productList[i].Supplier__r.Name;
                                productList[i].JDEdwardsId = productList[i].Supplier__r.JD_Edwards_Id__c;
                            }catch(err){
                                //nothing to do
                            }

                            if (productList[i].Product_Coordinator__c) {
                                productList[i].ProductSpecialist = productList[i].Product_Coordinator__r.Name;
                            }
                            if (productList[i].Product_Manager__c) {
                                productList[i].ProductManager = productList[i].Product_Manager__r.Name;
                            }
                            if (productList[i].Commodity_Code2__c) {
                                productList[i].CommodityCode = productList[i].Commodity_Code2__r.Name
                            }
                            if (productList[i].Commodity_Family2__c) {
                                productList[i].CommodityFamily = productList[i].Commodity_Family2__r.Name
                            }
                        }
                        component.set("v.data", productList);
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
        try{
            let apexAction = component.get("c.updateProductRecords");

            apexAction.setParams({
                "productRecords": JSON.stringify(values)
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
                            component.set('v.toBeSaved', []);
                            helper.getProductFromSearchApex(component, event, helper);
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
        }catch (err){
            console.log('error ' +  err);
        }
    },

    getMaxRows: function(component, event, helper, values){
        let apexAction = component.get("c.getMaxRowSelection");

        apexAction.setCallback(this, function (response) {
            let result = response.getReturnValue();

            component.set('v.maxRowSelection',result);
        });

        $A.enqueueAction(apexAction);
    }
});