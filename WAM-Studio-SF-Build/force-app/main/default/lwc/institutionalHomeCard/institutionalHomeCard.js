import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import hasInstitutionalRole from "@salesforce/customPermission/WAM_Institutional";
import getInstitutionalBookSnapshot from "@salesforce/apex/WealthAIInstitutionalUseCaseService.getInstitutionalBookSnapshot";
import getInstitutionalPriorityQueue from "@salesforce/apex/WealthAIInstitutionalUseCaseService.getInstitutionalPriorityQueue";
import resetInstitutionalData from "@salesforce/apex/WealthAIDashboardResetService.resetInstitutionalData";

export default class InstitutionalHomeCard extends LightningElement {
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
    return hasInstitutionalRole === true;
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
      return `${this.priorityItems.length} mandate breach${
        this.priorityItems.length > 1 ? "es" : ""
      } need committee review today.`;
    }
    return "No mandate breaches across your book — all institutions in compliance.";
  }

  @wire(getInstitutionalBookSnapshot)
  wiredMetrics(result) {
    this.wiredMetricsResult = result;
    const { data, error } = result;
    this.metricsLoaded = true;
    if (data) {
      this.metricTiles = [
        {
          key: "institutions",
          label: "Institutions Tracked",
          display: String(data.institutionCount),
          tone: "neutral"
        },
        {
          key: "breaches",
          label: "Mandate Breaches",
          display: String(data.mandateBreaches),
          tone: data.mandateBreaches > 0 ? "critical" : "success"
        },
        {
          key: "findings",
          label: "Open Findings",
          display: String(data.openFindings),
          tone: data.openFindings > 0 ? "warning" : "success"
        },
        {
          key: "workflows",
          label: "Active Workflows",
          display: String(data.activeWorkflows),
          tone: "neutral"
        }
      ];
      this.metricError = undefined;
    } else if (error) {
      this.metricTiles = [];
      this.metricError = this.normalizeError(error);
    }
  }

  @wire(getInstitutionalPriorityQueue)
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
      "Reset the institutional dashboard? This deletes current mandate breaches, then restores a clean baseline."
    );
    if (!confirmed) {
      return;
    }
    this.resetting = true;
    try {
      const result = await resetInstitutionalData();
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
