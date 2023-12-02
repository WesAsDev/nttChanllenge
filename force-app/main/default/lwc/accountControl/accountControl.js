import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AccountControl extends LightningElement {
    @api recordId;

    errorHandler(e){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erro!',
                message: e.detail.detail,
                variant: 'Error'
            })
        );
    }

    successHandler(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Sucesso',
                message: 'Conta atualizada com sucesso',
                variant: 'Success'
            })
        );

    }
}