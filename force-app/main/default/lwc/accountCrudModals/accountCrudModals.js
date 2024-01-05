import { LightningElement, track } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountCrudModalsController.searchAccounts';
import searchAccountById from '@salesforce/apex/AccountCrudModalsController.searchAccountById';
import saveRecords from '@salesforce/apex/AccountCrudModalsController.saveRecords';
import deleteRecord from '@salesforce/apex/AccountCrudModalsController.deleteRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
//import generateData from './generateData';

const columnsValues = [
    { label : 'Account Name', fieldName : 'Name', type : 'text', editable : false },
    { label : 'Account Type', fieldName : 'Type', type : 'text', editable : false },
    { label : 'Account Phone', fieldName : 'Phone', type : 'Phone', editable : false },
    { label : 'Account Website', fieldName : 'Website', type : 'URL', editable : false}
];

export default class AccountCrudModals extends LightningElement {
    @track isTableModalOpen = false;
    @track isUpdateModalOpen = false;
    @track isCreateModalOpen = false;
    @track columns = columnsValues;

    @track data = [];
    @track dataUpdate;
    @track accName;
    @track accType;
    @track accPhone;
    @track accWebsite;
    
    @track recordId;
    @track rowSelectionId;
    rowOffset = 0;
    //accNameTeste = 'Burlington Textiles Corp of America';

    typeOptions = [
        { label : 'Prospect', value : 'Prospect'},
        { label : 'Customer - Direct', value : 'Customer - Direct'},
        { label : 'Customer - Channel', value : 'Customer - Channel'},
        { label : 'Channel Partner / Reseller', value : 'Channel Partner / Reseller'},
        { label : 'Installation Partner', value : 'Installation Partner'},
        { label : 'Technology Partner', value : 'Technology Partner'},
        { label : 'Other', value : 'Other'},
    ];
    
    /*
        connectedCallback() {
            this.data2 = generateData({ amountOfRecords: 10 });
        }
    */
    //HANDLERS
    changeHandler(event){
        const options = event.target.label;

        switch(options){
            case 'AccountName':
                this.accName = event.target.value;
                break;
        }
    }

    getIdSelectedRecord(event){
        this.recordId = event.detail.config.value;
    }

    handlerUpdate(event){
        const option = event.target.label;

        switch(option){
            case 'AccountName':
                this.accName = event.target.value;
                break;
            case 'AccountType':
                this.accType = event.target.value;
                break;
            case 'AccountPhone':
                this.accPhone = event.target.value;
                break;
            case 'AccountWebsite':
                this.accWebsite = event.target.value;
                break;
        }
    }

    //DML
    saveRecordAccount(){
        const accountObj = {
            nome    : this.accName,
            type    : this.accType,
            phone   : this.accPhone,
            website : this.accWebsite
        };
        
        const accountJSON = JSON.stringify(accountObj);
        
        saveRecords({ accountJSON : accountJSON })
            .then(result => {
                if(result === 'Record Updated.'){
                    this.showToast(
                        'Success',
                        'Record Created with success. ',
                        'success',
                        'sticky'
                    );
                    this.closeModal();
                }
            }).catch(error => {
                this.showToast(
                    'Error',
                    `Something got wrong. ${error}`,
                    'error',
                    'sticky'
                );
            });
    }

    updateRecordAccount(){
        const accountObj = {
            accId   : this.dataUpdate.Id,
            nome    : this.accName === null || this.accName === undefined ? this.dataUpdate.Name : this.accName,
            type    : this.accType === null || this.accType === undefined ? this.dataUpdate.Type : this.accType,
            phone   : this.accPhone === null || this.accPhone === undefined ? this.dataUpdate.Phone : this.accPhone,
            website : this.accWebsite === null || this.accWebsite === undefined ? this.dataUpdate.Website : this.accWebsite
        };
        
        const accountJSON = JSON.stringify(accountObj);
        
        saveRecords({ accountJSON : accountJSON })
            .then(result => {
                if(result === 'Record Updated.'){
                    this.showToast(
                        'Success',
                        'Record retrieved with success. ',
                        'success',
                        'sticky'
                    );
                    this.closeModal();
                }
            }).catch(error => {
                this.showToast(
                    'Error',
                    `Something got wrong. ${error}`,
                    'error',
                    'sticky'
                );
            });
    }

    searchAccount(){
        searchAccounts({accountName : this.accName})
            .then(result => {
                this.data = result;
                this.isTableModalOpen = true;
                
                this.showToast(
                    'Success',
                    'Record retrieved with success. ',
                    'success',
                    'sticky'
                );
                this.cleanFields();
            }).catch(error =>{
                this.showToast(
                    'Error',
                    `Something got wrong. ${error}`,
                    'error',
                    'sticky'
                );
            });
    }

    modalCreateRecord(){
        this.isCreateModalOpen = true;
    }

    modalUpdateRecord(){
        searchAccountById({accountId : this.recordId})
            .then(result =>{
                this.dataUpdate = result;
                this.closeModal();
                this.isUpdateModalOpen = true;
                this.showToast(
                    'Success',
                    'Record retrieved with success. ',
                    'success',
                    'sticky'
                );
            }).catch(error =>{
                this.showToast(
                    'Error',
                    `Something got wrong. ${error}`,
                    'error',
                    'sticky'
                );
            })
    }

    async deleteRecord(){
        const response = await this.handleDelete('Delete Record', 'Delete Record?');
        
        if(response){
            deleteRecord({recordId : this.recordId})
            .then(result => {
                this.showToast(
                    'Success',
                    'Record deleted with success. ',
                    'success',
                    'sticky'
                );
                this.closeModal();
            }).catch(error => {
                this.showToast(
                    'Error',
                    `Something got wrong. ${error}`,
                    'error',
                    'sticky'
                );
            })
        }
    }

    //UTILS
    async handleDelete(labelText, messageText){
        const response = await LightningConfirm.open({
            label   : labelText,
            message : messageText,
            theme   : 'default',
            variant : 'header'
        })
        return response;
    }

    closeModal(){
        this.isTableModalOpen = false;
        this.isUpdateModalOpen = false;
        this.isCreateModalOpen = false;
    }

    showToast = (titulo, mensagem, variante, modo) => {
        const toastEvent = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante, // Pode ser 'success', 'warning', 'error' ou 'info'
            mode: modo // Pode ser 'dismissible': until close or 3 seg, 'peste': visible 3 seg, 'sticky' : visible until closed
        });
        this.dispatchEvent(toastEvent);
    }

    cleanFields(){
        this.accName = null;
    }
}