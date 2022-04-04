({
	loadRecords : function(component) {
        //$A.util.removeClass(component.find("spinner"), "slds-hide");

	    var recordId = component.get("v.recordId");
        var attributeIds = component.get("v.attributeIds");

        var action;

        if(!$A.util.isEmpty(recordId)) {
            action = component.get("c.getAvailableAndSelectedItemsForRecordId");
            action.setParams({ "recordId": recordId });
        } else {
            action = component.get("c.getAvailableAndSelectedItemsForAttributeIds");
            action.setParams({ "attributeIds" : attributeIds });
        }

        action.setCallback(this, function(response){
            if(!component.isValid()) {
                return;
            }

            var state = response.getState();
            if(state === "SUCCESS") {
                var responseData = response.getReturnValue();
                component.set("v.availableItems", responseData.available);

                // if records weren't loaded for a "real" parent, the attribute assignments won't have any ids
                // Set the ids to the corresponding attribute Id instead. Unable to do this server-side as Apex checks the id type
                var recordId = component.get("v.recordId");
                if($A.util.isEmpty(recordId)) {
                    for(var i = 0; i < responseData.selected.length; i++) {
                        responseData.selected[i].Id = responseData.selected[i].Attribute__c;
                    }
                }

                component.set("v.selectedItems", responseData.selected);
            } else {
                component.find("toaster").displayToast(
                    "An unknown error occurred initializing the Attribute Selector component.", "error");
            }

            //$A.util.addClass(component.find("spinner"), "slds-hide");
        });

        $A.enqueueAction(action);
	},


	removeItem : function(component, item) {
        this.moveItemFromSelectedToAvailable(component, item);

        var recordId = component.get("v.recordId");
        if(!$A.util.isEmpty(recordId)) {
            this.removeAttributeAssignment(component, item);
        } else {
            this.fireAttributesChanged(component);
        }
    },


    moveItemFromSelectedToAvailable : function(component, item) {
        var selectedItems = component.get("v.selectedItems");
        var availableItems = component.get("v.availableItems");

        for(var i = 0; i < selectedItems.length; i++) {
            if(selectedItems[i].Attribute__c === item.Attribute__c) {
                selectedItems.splice(i, 1);
                //break;
            }
        }

        for(var j = 0; j < availableItems.length; j++) {
            if(availableItems[j].attributes.Attribute__c === item.Attribute__c) {
                availableItems[j].attributes.push(item.Attribute__c);
                break;
            }
        }

        component.set("v.selectedItems", selectedItems);
        component.set("v.availableItems", availableItems);
    },


    attributeSort : function(a,b){
        if(a.Name < b.Name) {
            return -1;
        }
        if(a.Name > b.Name) {
            return 1;
        }
        return 0;
    },


    removeAttributeAssignment : function(component, item) {
        var action = component.get("c.removeAttribute");

        action.setParams({ "attributeAssignmentId" : item.Id });

        action.setCallback(this, function(response){
            if(!component.isValid()) {
                return;
            }

            var state = response.getState();
            if(state !== "SUCCESS") {
                component.find("toaster").displayToast("An unknown error occurred updating attributes", "error");
                this.loadRecords(component);
            }
        });

        $A.enqueueAction(action);
    },


    addItem : function(component, item) {
        var recordId = component.get("v.recordId");

        this.moveItemFromAvailableToSelected(component, item, recordId);

        if(!$A.util.isEmpty(recordId)) {
            this.createAttributeAssignment(component, item, recordId);
        } else {
            this.fireAttributesChanged(component);
        }
    },


    moveItemFromAvailableToSelected : function(component, item, recordId) {
        var selectedItems = component.get("v.selectedItems");
        var availableItems = component.get("v.availableItems");

        var attributeAssignment = {
             'sObjectType' : 'Attribute_Assignment__c',
             'Attribute__c' : item.Attribute__c,
             'Name' : item.Attribute__c
        };

        // If no record Id is available, we are in search mode. Use the attribute Id as a replacement for the attribute assignment
        // Id, as we will not be creating actual Attribute Assignment records
        if($A.util.isEmpty(recordId)) {
            attributeAssignment.Id = item.Id
        }

        var isSelected = false;

        for(var i = 0; i < selectedItems.length; i++) {
            if(selectedItems[i].Attribute__c === item.Attribute__c) {
                //selectedItems.splice(i, 1);
                isSelected = true;
                break;
            }
        }
        // selectedItems.push(attributeAssignment);

        if (!isSelected) {
            selectedItems.push(attributeAssignment);

            for(var i = 0; i < availableItems.length; i++) {
                if(availableItems[i].attributes.Attribute__c === item.Attribute__c) {
                    var attributes = availableItems[i].attributes;
                    for(var j = 0; j < attributes.length; j++) {
                        if(attributes[j].Id === item.Id) {
                            attributes.splice(j, 1);
                            break;
                        }
                    }
                }
            }
        }

        component.set("v.selectedItems", selectedItems);
        component.set("v.availableItems", availableItems);
    },


    createAttributeAssignment : function(component, item, recordId) {
        var action = component.get("c.addAttribute");

        action.setParams({
            "recordId" : recordId,
            "attributeId" : item.Id,
            "name" : item.Attribute__c
        });

        action.setCallback(this, function(response){
            if(!component.isValid()) {
                return;
            }
            var state = response.getState();
            if(state === "SUCCESS") {
                var aa = response.getReturnValue();
                if(!$A.util.isEmpty(aa)) {
                    var selectedItems = component.get("v.selectedItems");
                    for(var i = 0; i < selectedItems.length; i++) {
                        if(selectedItems[i].Attribute__c === aa.Attribute__c) {
                            selectedItems[i].Id = aa.Id;
                            component.set("v.selectedItems", selectedItems);
                            this.loadRecords(component);
                            return;
                        }
                    }
                }
            } else {
                component.find("toaster").displayToast("An unknown error occurred updating attributes", "error");
            }

            // If there was an error, or the matching selected attribute could not be found, just force a full refresh
            this.loadRecords(component);
        });
        $A.enqueueAction(action);
    },


    fireAttributesChanged : function(component) {
        var attributeIds = this.getSelectedAttributeIds(component);

        var attributesChangedEvent = $A.get("e.c:attributesChanged");
        attributesChangedEvent.setParams({ 'ids' : attributeIds });
        attributesChangedEvent.fire();

    },


    getSelectedAttributeIds : function(component) {
        var attributeIds = [];
        var selectedAttributes = component.get("v.selectedItems");
        for(var i = 0; i < selectedAttributes.length; i++) {
            attributeIds.push(selectedAttributes[i].Attribute__c);
        }

        return attributeIds;
    }
});