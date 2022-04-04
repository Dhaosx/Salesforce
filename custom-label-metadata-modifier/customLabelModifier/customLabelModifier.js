/**
 * Created by SimonSalvatore on 2022-03-17.
 */

import {LightningElement, api} from 'lwc';
import updateCustomLabels from '@salesforce/apex/CustomLabelsModifier.updateCustomLabels';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomLabelModifier extends LightningElement {
    @api CustomLabels = [];
    @api records = [];
    @api fieldColumns = [
        {label: 'Description', fieldName: 'MasterLabel', type: 'text', editable: true},
        {label: 'Name', fieldName: 'Name', type: 'text', editable: false},
        {label: 'Category', fieldName: 'Category', type: 'text', editable: true},
        {label: 'Value', fieldName: 'Value', type: 'text', editable: true}
    ];
    draftValues = [];

    connectedCallback() {
        let currentData = [];

        this.CustomLabels.forEach((row) => {
            let rowData = {};
            let parsedRow = JSON.parse(row);

            rowData.Id = parsedRow.Id;
            rowData.MasterLabel = parsedRow.MasterLabel;
            rowData.Name = parsedRow.Name;
            rowData.Category = parsedRow.Category;
            rowData.Value = parsedRow.Value;

            currentData.push(rowData);
        });

        this.records = currentData;

    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;

        const notifyChangeIds = updatedFields.map(row => {
            return {"recordId": row.Id}
        });

        try {
            // Pass edited fields to the updateContacts Apex controller
            const result = updateCustomLabels({data: updatedFields});
            console.log(JSON.stringify("Apex update result: " + result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Custom Label(s) updated',
                    variant: 'success'
                })
            );

            // Refresh LDS cache and wires
            //getRecordNotifyChange(notifyChangeIds);

            // Display fresh data in the datatable
            refreshApex(this.records).then(() => {
                // Clear all draft values in the datatable
                this.draftValues = [];
            });
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}