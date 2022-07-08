/**
 * Created by simon.salvatore on 7/6/2022.
 */
import {LightningElement, api, track, wire} from "lwc";
import getProfilePicture from "@salesforce/apex/MembershipCardController.getProfilePicture";
import saveAttachment from "@salesforce/apex/MembershipCardController.saveAttachment";
import getContactFields from "@salesforce/apex/MembershipCardController.getContactFields";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';

export default class membershipCard extends LightningElement {
    @api recordId;
    @track files;
    @api pictureSrc = "";
    @api message = "Drag profile picture here";
    @track contacts = [];
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] })
    contact;

    connectedCallback() {
        this.getProfilePicture();
        this.getContactFieldSetValues();
    }

    get name() {
        return getFieldValue(this.contact.data, NAME_FIELD);
    }

    getContactFieldSetValues() {
        getContactFields({
            recordId: this.recordId
        })
            .then(result => {
                for (let key in result) {
                    // Preventing unexpected data
                    if (result.hasOwnProperty(key)) { // Filtering the data in the loop
                        this.contacts.push({value: result[key], key: key});
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    getProfilePicture() {
        getProfilePicture({
            parentId: this.recordId
        })
            .then((result) => {
                if (result && result.Id) {
                    this.pictureSrc = "/sfc/servlet.shepherd/version/download/" + result.Id;
                }
            })
            .catch((error) => {
                console.log("error in get profile: ", error);
            });
    }

    onDragOver(event) {
        event.preventDefault();
    }

    onDrop(event) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = "copy";
        var files = event.dataTransfer.files;
        if (files.length > 1) {
            return alert("You can only upload one profile picture");
        }
        this.readFile(files[0]);
        this.files = files[0];
    }

    readFile(file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            return alert("Image file not supported");
        }
        let reader = new FileReader();
        reader.onload = this.showContent.bind(this, reader);
        reader.readAsDataURL(file);
    }

    showContent(reader) {
        let base64;
        this.error = "";
        this.pictureSrc = reader.result;
        base64 = reader.result.match(/,(.*)$/)[1];
        this.upload(this.files, base64);
    }

    upload(file, base64Data) {
        this.message = "Uploading....";
        saveAttachment({
            parentId: this.recordId,
            fileName: file.name,
            base64Data: base64Data,
        })
            .then((result) => {
                this.message = "Drag profile picture here";
            })
            .catch((error) => {
                console.log("error in save: ", error);
            });
    }
}