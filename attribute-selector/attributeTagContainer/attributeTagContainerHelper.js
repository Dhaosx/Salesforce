/**
 * attributeTagContainerHelper.js
 * @author Jordan Lin, Traction on Demand
 * @date 4/18/2019
 */
({
    displayErrors: function (component, data) {
        let labelArray = component.find('attributeLabel');
        for (let i = 0; i < data.length; i++) {
            const datum = data[i];
            for (let j = 0; j < labelArray.length; j++) {
                let label = labelArray[j];
                let elements = label.getElements();
                let element = elements[0];
                if(datum.attribute === element.dataset.type) {
                    component.set('v.hasErrors', true);
                    element.classList.add('slds-text-color_error');
                    element.innerHTML = datum.errorMsg;
                }
            }
        }
    },
    clearErrors : function (component) {
        let labelArray = component.find('attributeLabel');
        component.set('v.hasErrors', false);

        for (let i = 0; i < labelArray.length; i++) {
            labelArray[i].getElements()[0].innerHTML = '';
        }
    },
});