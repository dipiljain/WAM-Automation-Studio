import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import hasAdvisorRole from "@salesforce/customPermission/WAM_Advisor";
import getAdvisorMetrics from "@salesforce/apex/WealthAIHomeController.getAdvisorMetrics";
import getAdvisorInsights from "@salesforce/apex/WealthAIHomeController.getAdvisorInsights";
import getAdvisorRecommendations from "@salesforce/apex/WealthAIHomeController.getAdvisorRecommendations";
import getAdvisorPriorityQueue from "@salesforce/apex/WealthAIHomeController.getAdvisorPriorityQueue";
import resetAdvisorData from "@salesforce/apex/WealthAIDashboardResetService.resetAdvisorData";

export default class AdvisorHomeCard extends LightningElement {
  metricTiles = [];
  insightItems = [];
  recommendationItems = [];
  priorityItems = [];
  metricsLoaded = false;
  insightsLoaded = false;
  recommendationsLoaded = false;
  priorityLoaded = false;
  metricError;
  insightError;
  recommendationError;
  priorityError;
  resetting = false;

  wiredMetricsResult;
  wiredInsightsResult;
  wiredRecommendationsResult;
  wiredPriorityResult;

  get showCard() {
    return hasAdvisorRole === true;
  }

  get metricsLoading() {
    return !this.metricsLoaded;
  }

  get insightsLoading() {
    return !this.insightsLoaded;
  }

  get recommendationsLoading() {
    return !this.recommendationsLoaded;
  }

  get priorityLoading() {
    return !this.priorityLoaded;
  }

  get focusHeadline() {
    if (!this.priorityLoaded) {
      return undefined;
    }
    const criticalCount = (this.priorityItems || []).filter(
      (item) => item.tone === "critical"
    ).length;
    if (criticalCount > 0) {
      return `${criticalCount} client${
        criticalCount > 1 ? "s" : ""
      } need urgent outreach today.`;
    }
    if ((this.priorityItems || []).length > 0) {
      return `${this.priorityItems.length} client${
        this.priorityItems.length > 1 ? "s" : ""
      } to check in on today.`;
    }
    return "Your book looks healthy today — no urgent follow-ups.";
  }

  @wire(getAdvisorMetrics)
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

  @wire(getAdvisorPriorityQueue)
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

  @wire(getAdvisorInsights)
  wiredInsights(result) {
    this.wiredInsightsResult = result;
    const { data, error } = result;
    this.insightsLoaded = true;
    if (data) {
      this.insightItems = data;
      this.insightError = undefined;
    } else if (error) {
      this.insightItems = [];
      this.insightError = this.normalizeError(error);
    }
  }

  @wire(getAdvisorRecommendations)
  wiredRecommendations(result) {
    this.wiredRecommendationsResult = result;
    const { data, error } = result;
    this.recommendationsLoaded = true;
    if (data) {
      this.recommendationItems = data;
      this.recommendationError = undefined;
    } else if (error) {
      this.recommendationItems = [];
      this.recommendationError = this.normalizeError(error);
    }
  }

  async handleReset() {
    if (this.resetting) {
      return;
    }
    // eslint-disable-next-line no-alert
    const confirmed = window.confirm(
      "Reset the advisor dashboard? This deletes current AI insights, recommendations, and at-risk client scores, then restores a clean baseline."
    );
    if (!confirmed) {
      return;
    }
    this.resetting = true;
    try {
      const result = await resetAdvisorData();
      await Promise.all([
        refreshApex(this.wiredMetricsResult),
        refreshApex(this.wiredPriorityResult),
        refreshApex(this.wiredInsightsResult),
        refreshApex(this.wiredRecommendationsResult)
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
