({
	toggleAvailableAttributesVisibility: function(component) {
        var target = component.find("available-attributes");
        var isVisible = component.get("v.isAvailableListVisible");
        
        if(isVisible) {
            $A.util.removeClass(target, "slds-transition-show");
            $A.util.addClass(target, "slds-hide");
        } else {
            $A.util.removeClass(target, "slds-hide");
        	$A.util.addClass(target, "slds-transition-show");
        }
        
        component.set("v.isAvailableListVisible", !isVisible);
    },

    handleEvent : function(component, event, helper){
	    let serializedData = event.getParam('serializedData');
	    let data = JSON.parse(serializedData);
	    if(data.Record_Id__c === component.get('v.recordId')) {
	        if(data.Passed__c) {
                helper.clearErrors(component);
                component.set('v.hasErrors', false);
            } else {
                helper.clearErrors(component);
                helper.displayErrors(component, JSON.parse(data.Attribute_Error_Data__c).errors);
            }
        }
    }
});