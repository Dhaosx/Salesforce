({
	selectPressed : function(component) {
		var item = component.get('v.item');
		var isSelected = component.get('v.isSelected');

		var attributeSelectedEvent = $A.get("e.c:attributeSelected");
        attributeSelectedEvent.setParams({
            'item' : item,
            'isSelected': isSelected
        });
        attributeSelectedEvent.fire();
	},


	navigateToAttribute : function(component) {
		var attributeId = component.get('v.item.Id');
		if(!attributeId) { // record is actually an Attribute Record (clicked on an "available attribute")
			attributeId = component.get('v.item.Id');
		}

		var sobjEvent = $A.get("e.force:navigateToSObject");
		if(sobjEvent) { // we are in lightning
			sobjEvent.setParams({
				"recordId" : attributeId,
				"slideDevName" : "related" // open with the related list showing
			});
			sobjEvent.fire();
		} else {
			window.open("/" + attributeId, "_blank");
		}
	}
});