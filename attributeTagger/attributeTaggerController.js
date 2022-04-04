({
	doInit: function(component, event, helper) {
        helper.loadRecords(component);
    },


    handleAttributeSelected : function(component, event, helper) {
        var item = event.getParam('item');
        var isSelected = event.getParam('isSelected');

        if(isSelected) {
            helper.removeItem(component, item);
        } else {
            helper.addItem(component, item);
        }
    },
});