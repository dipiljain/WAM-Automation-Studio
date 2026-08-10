import { LightningElement, api } from "lwc";

export default class WamMetricTiles extends LightningElement {
  @api title;
  @api iconName;
  @api subtitle;
  @api tiles = [];
  @api loading = false;
  @api errorMessage;
  @api emptyMessage = "No metrics available right now.";

  get hasError() {
    return Boolean(this.errorMessage);
  }

  get hasTiles() {
    return Array.isArray(this.tiles) && this.tiles.length > 0;
  }

  get showEmpty() {
    return !this.loading && !this.hasError && !this.hasTiles;
  }
}
