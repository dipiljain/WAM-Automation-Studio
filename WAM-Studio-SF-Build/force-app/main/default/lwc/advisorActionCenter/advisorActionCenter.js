import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import getClient360 from "@salesforce/apex/WealthAIAdvisorUseCaseService.getClient360";
import generateAdvisorBriefing from "@salesforce/apex/WealthAIAdvisorUseCaseService.generateAdvisorBriefing";
import generateRelationshipInsight from "@salesforce/apex/WealthAIAdvisorUseCaseService.generateRelationshipInsight";
import generateNextBestAction from "@salesforce/apex/WealthAIAdvisorUseCaseService.generateNextBestAction";
import refreshScores from "@salesforce/apex/WealthAIAdvisorUseCaseService.refreshScores";
import WAM_CLIENT_SELECTION_CHANNEL from "@salesforce/messageChannel/WAM_ClientSelection__c";

function listUrl(objectApiName) {
  return `/lightning/o/${objectApiName}/list?filterName=Recent`;
}

function priorityToTone(priority) {
  if (priority === "High") {
    return "critical";
  }
  if (priority === "Medium") {
    return "warning";
  }
  if (priority === "Low") {
    return "success";
  }
  return "neutral";
}

export default class AdvisorActionCenter extends LightningElement {
  @api recordId;
  selectedAccountId;
  snapshot;
  lastAction;
  loading = false;
  errorMessage;
  subscription;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    if (this.recordId) {
      this.loadSnapshot();
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      WAM_CLIENT_SELECTION_CHANNEL,
      (message) => {
        this.selectedAccountId = message.accountId;
        this.loadSnapshot();
      }
    );
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = undefined;
  }

  get activeAccountId() {
    return this.recordId || this.selectedAccountId;
  }

  get hasAccount() {
    return Boolean(this.activeAccountId);
  }

  get actionDisabled() {
    return !this.hasAccount || this.loading;
  }

  get metricTiles() {
    if (!this.snapshot) {
      return [];
    }
    return [
      {
        key: "engagement",
        label: "Engagement Score",
        display: this.displayNumber(this.snapshot.engagementScore),
        tone: this.snapshot.engagementScore >= 70 ? "success" : "warning",
        recordUrl: listUrl("Engagement_Score__c")
      },
      {
        key: "health",
        label: "Client Health Score",
        display: this.displayNumber(this.snapshot.healthScore),
        tone: this.snapshot.healthScore >= 70 ? "success" : "warning",
        recordUrl: listUrl("Client_Health_Score__c")
      },
      {
        key: "recs",
        label: "Open Recommendations",
        display: String(this.snapshot.openRecommendations),
        tone: this.snapshot.openRecommendations > 0 ? "warning" : "neutral",
        recordUrl: listUrl("AI_Recommendation__c")
      },
      {
        key: "findings",
        label: "Open Compliance Findings",
        display: String(this.snapshot.openFindings),
        tone: this.snapshot.openFindings > 0 ? "critical" : "success",
        recordUrl: listUrl("Compliance_Finding__c")
      }
    ];
  }

  get showNoAccountState() {
    return !this.loading && !this.hasAccount;
  }

  get priorityMetaLabel() {
    return this.lastAction && this.lastAction.priority
      ? "Priority"
      : undefined;
  }

  async handleRefreshScores() {
    await this.executeAction(
      async (params) => {
        const scores = await refreshScores(params);
        return {
          title: "Scores refreshed",
          detail:
            "Engagement " +
            Math.round(scores.engagementScore) +
            ", Health " +
            Math.round(scores.healthScore) +
            ".",
          tone: scores.healthScore >= 70 ? "success" : "warning"
        };
      },
      "Scores refreshed.",
      undefined,
      "Review the KPI tiles above for the latest engagement and health signal."
    );
    await this.loadSnapshot();
  }

  async handleGenerateBriefing() {
    await this.executeAction(
      generateAdvisorBriefing,
      "Advisor briefing generated.",
      "Advisor_Briefing__c",
      (result) =>
        result.priority === "High"
          ? "Prioritize this client for outreach this week — review the briefing and schedule time on the calendar."
          : result.priority === "Medium"
            ? "Review the briefing before your next scheduled touchpoint."
            : "No urgent action — file the briefing for reference at the next meeting."
    );
    await this.loadSnapshot();
  }

  async handleGenerateRelationshipInsight() {
    await this.executeAction(
      generateRelationshipInsight,
      "Relationship insight generated.",
      "AI_Insight__c",
      "Review the insight and decide if it warrants a follow-up touchpoint."
    );
    await this.loadSnapshot();
  }

  async handleGenerateNba() {
    await this.executeAction(
      generateNextBestAction,
      "Next best action generated.",
      "AI_Recommendation__c",
      (result) =>
        result.priority === "High"
          ? "Reach out this week — this is flagged as a retention risk."
          : "Add to your outreach queue for the next client touchpoint."
    );
    await this.loadSnapshot();
  }

  async executeAction(actionFn, successMessage, objectApiName, nextStep) {
    if (!this.hasAccount) {
      return;
    }
    this.loading = true;
    this.errorMessage = undefined;
    try {
      const result = await actionFn({ accountId: this.activeAccountId });
      this.lastAction = {
        ...result,
        tone: result.tone || priorityToTone(result.priority),
        recordUrl:
          result && result.recordId && objectApiName
            ? `/lightning/r/${objectApiName}/${result.recordId}/view`
            : undefined,
        nextStep: typeof nextStep === "function" ? nextStep(result) : nextStep
      };
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: successMessage,
          variant: "success"
        })
      );
    } catch (error) {
      this.errorMessage = this.normalizeError(error);
    } finally {
      this.loading = false;
    }
  }

  async loadSnapshot() {
    if (!this.hasAccount) {
      this.snapshot = undefined;
      return;
    }
    this.loading = true;
    this.errorMessage = undefined;
    try {
      this.snapshot = await getClient360({ accountId: this.activeAccountId });
    } catch (error) {
      this.snapshot = undefined;
      this.errorMessage = this.normalizeError(error);
    } finally {
      this.loading = false;
    }
  }

  normalizeError(error) {
    if (!error) {
      return "Unexpected error.";
    }
    if (Array.isArray(error.body)) {
      return error.body.map((item) => item.message).join(", ");
    }
    if (error.body && error.body.message) {
      return error.body.message;
    }
    return "Unexpected error.";
  }

  displayNumber(value) {
    return value === null || value === undefined
      ? "-"
      : String(Math.round(value));
  }
}
