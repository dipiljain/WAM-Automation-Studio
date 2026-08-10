import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import hasExecutiveRole from "@salesforce/customPermission/WAM_Executive";
import getExecutiveMetrics from "@salesforce/apex/WealthAIHomeController.getExecutiveMetrics";
import getExecutiveApprovalQueue from "@salesforce/apex/WealthAIHomeController.getExecutiveApprovalQueue";
import resetExecutiveData from "@salesforce/apex/WealthAIDashboardResetService.resetExecutiveData";

export default class ExecutiveHomeCard extends LightningElement {
  metricTiles = [];
  priorityItems = [];
  metricsLoaded = false;
  priorityLoaded = false;
  metricError;
  priorityError;
  resetting = false;

  wiredMetricsResult;
  wiredPriorityResult;

  get showCard() {
    return hasExecutiveRole === true;
  }

  get metricsLoading() {
    return !this.metricsLoaded;
  }

  get priorityLoading() {
    return !this.priorityLoaded;
  }

  get focusHeadline() {
    if (!this.priorityLoaded) {
      return undefined;
    }
    if ((this.priorityItems || []).length > 0) {
      return `${this.priorityItems.length} autonomous agent action${
        this.priorityItems.length > 1 ? "s" : ""
      } awaiting your approval.`;
    }
    return "No autonomous actions awaiting approval right now.";
  }

  @wire(getExecutiveMetrics)
  wiredMetrics(result) {
    this.wiredMetricsResult = result;
    const { data, error } = result;
    this.metricsLoaded = true;
    if (data) {
      this.metricTiles = data.map((m) => ({
        key: m.label,
        label: m.label,
        display: m.display,
        tone: m.tone
      }));
      this.metricError = undefined;
    } else if (error) {
      this.metricTiles = [];
      this.metricError = this.normalizeError(error);
    }
  }

  @wire(getExecutiveApprovalQueue)
  wiredPriority(result) {
    this.wiredPriorityResult = result;
    const { data, error } = result;
    this.priorityLoaded = true;
    if (data) {
      this.priorityItems = data;
      this.priorityError = undefined;
    } else if (error) {
      this.priorityItems = [];
      this.priorityError = this.normalizeError(error);
    }
  }

  async handleReset() {
    if (this.resetting) {
      return;
    }
    // eslint-disable-next-line no-alert
    const confirmed = window.confirm(
      "Reset the executive dashboard? This deletes current pending approvals, then restores a clean baseline."
    );
    if (!confirmed) {
      return;
    }
    this.resetting = true;
    try {
      const result = await resetExecutiveData();
      await Promise.all([
        refreshApex(this.wiredMetricsResult),
        refreshApex(this.wiredPriorityResult)
      ]);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Dashboard reset",
          message: result.detail,
          variant: "success"
        })
      );
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Reset failed",
          message: this.normalizeError(error),
          variant: "error"
        })
      );
    } finally {
      this.resetting = false;
    }
  }

  normalizeError(error) {
    if (!error) {
      return undefined;
    }
    if (Array.isArray(error.body)) {
      return error.body.map((e) => e.message).join(", ");
    }
    if (error.body && error.body.message) {
      return error.body.message;
    }
    return "Unexpected error.";
  }
}
