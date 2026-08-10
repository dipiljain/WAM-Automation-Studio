import { LightningElement, api } from "lwc";

export default class WamStatePanel extends LightningElement {
  @api state = "empty";
  @api title = "Nothing to show";
  @api message = "";

  get isLoading() {
    return this.state === "loading";
  }

  get isError() {
    return this.state === "error";
  }

  get isEmpty() {
    return this.state === "empty";
  }
}
