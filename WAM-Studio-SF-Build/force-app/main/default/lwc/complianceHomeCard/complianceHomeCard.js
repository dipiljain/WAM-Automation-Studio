import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import hasComplianceRole from "@salesforce/customPermission/WAM_Compliance";
import getComplianceMetrics from "@salesforce/apex/WealthAIHomeController.getComplianceMetrics";
import getComplianceQueue from "@salesforce/apex/WealthAIHomeController.getComplianceQueue";
import resetComplianceData from "@salesforce/apex/WealthAIDashboardResetService.resetComplianceData";

export default class ComplianceHomeCard extends LightningElement {
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
    return hasComplianceRole === true;
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
    const escalatedCount = (this.priorityItems || []).filter(
      (item) => item.tone === "critical"
    ).length;
    if (escalatedCount > 0) {
      return `${escalatedCount} escalated finding${
        escalatedCount > 1 ? "s" : ""
      } need action today.`;
    }
    if ((this.priorityItems || []).length > 0) {
      return `${this.priorityItems.length} open finding${
        this.priorityItems.length > 1 ? "s" : ""
      } to review today.`;
    }
    return "No open compliance findings — the queue is clear.";
  }

  @wire(getComplianceMetrics)
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

  @wire(getComplianceQueue)
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
      "Reset the compliance dashboard? This deletes current open/escalated findings, then restores a clean baseline."
    );
    if (!confirmed) {
      return;
    }
    this.resetting = true;
    try {
      const result = await resetComplianceData();
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
