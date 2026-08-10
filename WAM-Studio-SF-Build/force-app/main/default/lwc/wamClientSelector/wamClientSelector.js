import { LightningElement, api, wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import getAccountOptions from "@salesforce/apex/WealthAIAdvisorUseCaseService.getAccountOptions";
import WAM_CLIENT_SELECTION_CHANNEL from "@salesforce/messageChannel/WAM_ClientSelection__c";

export default class WamClientSelector extends LightningElement {
  @api recordId;
  selectedAccountId;
  accountOptions = [];

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    if (this.recordId) {
      this.publishSelection(this.recordId);
    }
  }

  @wire(getAccountOptions)
  wiredAccounts({ data, error }) {
    if (data) {
      this.accountOptions = data.map((row) => ({
        label: row.label,
        value: row.value
      }));
      if (
        !this.recordId &&
        !this.selectedAccountId &&
        this.accountOptions.length > 0
      ) {
        this.selectedAccountId = this.accountOptions[0].value;
        this.publishSelection(this.selectedAccountId);
      }
    } else if (error) {
      this.accountOptions = [];
    }
  }

  handleChange(event) {
    this.selectedAccountId = event.detail.value;
    this.publishSelection(this.selectedAccountId);
  }

  publishSelection(accountId) {
    publish(this.messageContext, WAM_CLIENT_SELECTION_CHANNEL, { accountId });
  }
}
