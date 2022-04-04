({
    doInit: function (component, event, helper) {
        if (component.get('v.description') != null) {
            let field = component.get('v.description');
            let key = 'v.oRecord.' + field;
            let value = component.get(key);
            component.set('v.passThroughValue', value);
        }
    },

    selectRecord: function (component, event, helper) {
        // get the selected record from list
        let getSelectRecord = component.get("v.oRecord");
        let compEvent = component.getEvent("oSelectedRecordEvent");
        component.set('v.recordSelected', true);
        compEvent.setParams({"recordByEvent": getSelectRecord});
        compEvent.fire();
    }
});