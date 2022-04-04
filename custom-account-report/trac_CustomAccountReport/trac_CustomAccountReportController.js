({
    doInit: function (component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var accountId = myPageRef.state.c__AccountId;
        var productId = myPageRef.state.c__ProductId;

        component.set('v.AccountId', accountId);
        component.set('v.ProductId', productId);

        helper.fetchReportData(component);
    }
});