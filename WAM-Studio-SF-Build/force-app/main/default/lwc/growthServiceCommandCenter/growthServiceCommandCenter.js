import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import WAM_CLIENT_SELECTION_CHANNEL from "@salesforce/messageChannel/WAM_ClientSelection__c";
import getScaleSnapshot from "@salesforce/apex/WealthAIGrowthScaleService.getScaleSnapshot";
import getGrowthItems from "@salesforce/apex/WealthAIGrowthScaleService.getGrowthItems";
import getServiceItems from "@salesforce/apex/WealthAIGrowthScaleService.getServiceItems";
import getControlItems from "@salesforce/apex/WealthAIGrowthScaleService.getControlItems";
import runProposalCopilot from "@salesforce/apex/WealthAIGrowthScaleService.runProposalCopilot";
import runReferralIntelligence from "@salesforce/apex/WealthAIGrowthScaleService.runReferralIntelligence";
import runCrossSellIntelligence from "@salesforce/apex/WealthAIGrowthScaleService.runCrossSellIntelligence";
import runScenarioAnalysis from "@salesforce/apex/WealthAIGrowthScaleService.runScenarioAnalysis";
import runServiceResolutionCopilot from "@salesforce/apex/WealthAIGrowthScaleService.runServiceResolutionCopilot";
import runPredictiveAttrition from "@salesforce/apex/WealthAIGrowthScaleService.runPredictiveAttrition";
import runComplianceSurveillance from "@salesforce/apex/WealthAIGrowthScaleService.runComplianceSurveillance";
import runReconciliationAssistant from "@salesforce/apex/WealthAIGrowthScaleService.runReconciliationAssistant";
import runCashMovementIntelligence from "@salesforce/apex/WealthAIGrowthScaleService.runCashMovementIntelligence";

function listUrl(objectApiName) {
  return `/lightning/o/${objectApiName}/list?filterName=Recent`;
}

export default class GrowthServiceCommandCenter extends LightningElement {
  @api recordId;
  selectedAccountId;
  snapshot;
  growthItems = [];
  serviceItems = [];
  controlItems = [];
  loading = false;
  errorMessage;
  lastAction;
  subscription;
  activeSectionName = "growth";

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    if (this.recordId) {
      this.loadData();
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      WAM_CLIENT_SELECTION_CHANNEL,
      (message) => {
        this.selectedAccountId = message.accountId;
        this.loadData();
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

  get actionDisabled() {
    return !this.activeAccountId || this.loading;
  }

  get growthMetricTiles() {
    if (!this.snapshot) {
      return [];
    }
    return [
      {
        key: "proposal",
        label: "Proposal Drafts",
        display: String(this.snapshot.proposalDrafts),
        tone: this.snapshot.proposalDrafts > 0 ? "warning" : "neutral",
        recordUrl: listUrl("AI_Recommendation__c")
      },
      {
        key: "referral",
        label: "Referral Queue",
        display: String(this.snapshot.referralQueue),
        tone: this.snapshot.referralQueue > 0 ? "warning" : "success",
        recordUrl: listUrl("Referral_Prediction__c")
      },
      {
        key: "crosssell",
        label: "Cross-Sell Signals",
        display: String(this.snapshot.crossSellRecommendations),
        tone:
          this.snapshot.crossSellRecommendations > 0 ? "warning" : "success",
        recordUrl: listUrl("AI_Recommendation__c")
      }
    ];
  }

  get serviceMetricTiles() {
    if (!this.snapshot) {
      return [];
    }
    return [
      {
        key: "service",
        label: "Service Workflows",
        display: String(this.snapshot.serviceWorkflows),
        tone: this.snapshot.serviceWorkflows > 0 ? "warning" : "success",
        recordUrl: listUrl("Workflow_Execution__c")
      },
      {
        key: "attrition",
        label: "Attrition Signals",
        display: String(this.snapshot.attritionSignals),
        tone: this.snapshot.attritionSignals > 0 ? "critical" : "success",
        recordUrl: listUrl("Risk_Signal__c")
      }
    ];
  }

  get controlMetricTiles() {
    if (!this.snapshot) {
      return [];
    }
    return [
      {
        key: "surveillance",
        label: "Surveillance Findings",
        display: String(this.snapshot.surveillanceFindings),
        tone: this.snapshot.surveillanceFindings > 0 ? "critical" : "success",
        recordUrl: listUrl("Compliance_Finding__c")
      }
    ];
  }

  get serviceAlertsLabel() {
    const count = this.serviceMetricTiles.filter(
      (tile) => tile.tone !== "success"
    ).length;
    return count === 1 ? "1 alert" : `${count} alerts`;
  }

  get controlOpenLabel() {
    const count = this.snapshot ? this.snapshot.surveillanceFindings : 0;
    return count === 1 ? "1 open finding" : `${count} open findings`;
  }

  handleSectionToggle(event) {
    this.activeSectionName = event.detail.openSections;
  }

  async handleAction(actionFn, successMessage, objectApiName, nextStep) {
    if (!this.activeAccountId) {
      return;
    }
    this.loading = true;
    this.errorMessage = undefined;
    try {
      const result = await actionFn({ accountId: this.activeAccountId });
      this.lastAction = {
        ...result,
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
      await this.loadData();
    }
  }

  handleProposalCopilot() {
    this.handleAction(
      runProposalCopilot,
      "Proposal copilot completed.",
      "AI_Recommendation__c",
      (result) =>
        result.tone === "critical"
          ? "Finalize and send this proposal this week — the client's health score signals urgency."
          : "Review the draft proposal and schedule time to walk through it with the client."
    );
  }

  handleReferralIntelligence() {
    this.handleAction(
      runReferralIntelligence,
      "Referral intelligence completed.",
      "Referral_Prediction__c",
      (result) =>
        result.tone === "critical"
          ? "High-scoring referral — activate the advisor this week."
          : "Add this referral to the advisor activation queue."
    );
  }

  handleCrossSell() {
    this.handleAction(
      runCrossSellIntelligence,
      "Cross-sell intelligence completed.",
      "AI_Recommendation__c",
      "Present the recommended products at the client's next scheduled meeting."
    );
  }

  handleScenarioAnalysis() {
    this.handleAction(
      runScenarioAnalysis,
      "Scenario analysis completed.",
      "AI_Insight__c",
      "Share the scenario summary with the client as part of your next portfolio review."
    );
  }

  handleServiceResolution() {
    this.handleAction(
      runServiceResolutionCopilot,
      "Service resolution completed.",
      "Workflow_Execution__c",
      "Confirm the drafted resolution addresses the client's request, then send it."
    );
  }

  handlePredictiveAttrition() {
    this.handleAction(
      runPredictiveAttrition,
      "Predictive attrition run completed.",
      "Risk_Signal__c",
      (result) =>
        result.tone === "critical"
          ? "Launch the retention play this week — attrition risk is high."
          : "Monitor the account and follow up on the retention play within the month."
    );
  }

  handleSurveillance() {
    this.handleAction(
      runComplianceSurveillance,
      "Compliance surveillance completed.",
      "Compliance_Finding__c",
      "Route this finding to a compliance analyst for review."
    );
  }

  handleReconciliation() {
    this.handleAction(
      runReconciliationAssistant,
      "Reconciliation assistant completed.",
      "Workflow_Execution__c",
      "Review the exception summary and resolve any flagged transactions."
    );
  }

  handleCashMovement() {
    this.handleAction(
      runCashMovementIntelligence,
      "Cash movement intelligence completed.",
      "Risk_Signal__c",
      "Escalate to operations immediately — this anomaly exceeds historical thresholds."
    );
  }

  async loadData() {
    if (!this.activeAccountId) {
      this.snapshot = undefined;
      return;
    }
    this.loading = true;
    this.errorMessage = undefined;
    try {
      const [snapshot, growth, service, control] = await Promise.all([
        getScaleSnapshot({ accountId: this.activeAccountId }),
        getGrowthItems({ accountId: this.activeAccountId }),
        getServiceItems({ accountId: this.activeAccountId }),
        getControlItems({ accountId: this.activeAccountId })
      ]);
      this.snapshot = snapshot;
      this.growthItems = growth;
      this.serviceItems = service;
      this.controlItems = control;
    } catch (error) {
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
}
