/**
 * Created by SimonSalvatore on 2022-03-17.
 */

import {LightningElement, track, wire, api} from 'lwc';
import getDynamicTableDataList
    from '@salesforce/apex/CustomMetadataController.getWrapperOfSObjectFieldColumnActionValues';
import updateCustomMetadata
    from '@salesforce/apex/CustomMetadataController.updateCustomMetadata';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {refreshApex} from "@salesforce/apex";

export default class CustomMetadataModifier extends LightningElement {
    @api CustomMetadataType;
    @track DataTableResponseWrapper = [];
    @track finalSObjectDataList = [];

    @wire(getDynamicTableDataList, {TableName: '$CustomMetadataType'})
    wiredContacts({error, data}) {
        if (data) {
            let sObjectRelatedFieldListValues = [];

            for (let row of data.lstDataTableData) {
                const finalSobjectRow = {}
                let rowIndexes = Object.keys(row);
                rowIndexes.forEach((rowIndex) => {
                    const relatedFieldValue = row[rowIndex];
                    if (relatedFieldValue.constructor === Object) {
                        this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)
                    } else {
                        finalSobjectRow[rowIndex] = relatedFieldValue;
                    }
                });
                sObjectRelatedFieldListValues.push(finalSobjectRow);
            }
            this.DataTableResponseWrapper = data;
            this.finalSObjectDataList = sObjectRelatedFieldListValues;
        } else if (error) {
            this.error = error;
        }
    }

    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => {
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => {
            let finalKey = fieldName + '.' + key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log(this.DataTableResponseWrapper)

        const notifyChangeIds = updatedFields.map(row => {
            return {"recordId": row.Id}
        });

        try {
            // Pass edited fields to the updateContacts Apex controller
            const result = updateCustomMetadata({customMetadataType: $CustomMetadataType, data: updatedFields});
            console.log(JSON.stringify("Apex update result: " + result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Custom Metadata updated',
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