import { createElement } from 'lwc';
import AccountControl from 'c/accountControl';

describe('c-account-control', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Combobox do tipo deve preencher o lightning input field', () => {
        const element = createElement('c-account-control', {
            is: AccountControl
        });

        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const combobox = element.shadowRoot.querySelector("lightning-combobox");
            combobox.dispatchEvent(new CustomEvent("change", {
                    detail: {
                        value: "CNPJ"
                    }
                }));
            return Promise.resolve().then(() => {

                const outputElement = element.shadowRoot.querySelector('[data-id="accountTypeInputField"');
                expect(outputElement.value).toBe('CNPJ');
            });
        });
    });

});