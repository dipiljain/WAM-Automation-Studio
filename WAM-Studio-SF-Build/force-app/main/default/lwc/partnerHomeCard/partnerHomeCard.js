import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import hasPartnerRole from "@salesforce/customPermission/WAM_Partner";
import getPartnerBookSnapshot from "@salesforce/apex/WealthAIPartnerUseCaseService.getPartnerBookSnapshot";
import getPartnerPriorityQueue from "@salesforce/apex/WealthAIPartnerUseCaseService.getPartnerPriorityQueue";
import resetPartnerData from "@salesforce/apex/WealthAIDashboardResetService.resetPartnerData";

export default class PartnerHomeCard extends LightningElement {
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
    return hasPartnerRole === true;
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
      return `${this.priorityItems.length} participant household${
        this.priorityItems.length > 1 ? "s" : ""
      } at risk across your partner programs.`;
    }
    return "No at-risk participants across your partner programs today.";
  }

  @wire(getPartnerBookSnapshot)
  wiredMetrics(result) {
    this.wiredMetricsResult = result;
    const { data, error } = result;
    this.metricsLoaded = true;
    if (data) {
      this.metricTiles = [
        {
          key: "programs",
          label: "Partner Programs",
          display: String(data.partnerProgramCount),
          tone: "neutral"
        },
        {
          key: "participants",
          label: "Participant Households",
          display: String(data.participantCount),
          tone: "neutral"
        },
        {
          key: "atRisk",
          label: "At-Risk Participants",
          display: String(data.atRiskParticipants),
          tone: data.atRiskParticipants > 0 ? "critical" : "success"
        },
        {
          key: "referrals",
          label: "Open Referrals",
          display: String(data.openReferrals),
          tone: "neutral"
        }
      ];
      this.metricError = undefined;
    } else if (error) {
      this.metricTiles = [];
      this.metricError = this.normalizeError(error);
    }
  }

  @wire(getPartnerPriorityQueue)
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
      "Reset the partner dashboard? This deletes current at-risk participant scores, then restores a clean baseline."
    );
    if (!confirmed) {
      return;
    }
    this.resetting = true;
    try {
      const result = await resetPartnerData();
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
