import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAccountOptions from "@salesforce/apex/WealthAIAdvisorUseCaseService.getAccountOptions";
import getPortfolioSnapshot from "@salesforce/apex/WealthAIPortfolioUseCaseService.getPortfolioSnapshot";
import getLatestPortfolioAlerts from "@salesforce/apex/WealthAIPortfolioUseCaseService.getLatestPortfolioAlerts";
import getLatestRiskSignals from "@salesforce/apex/WealthAIPortfolioUseCaseService.getLatestRiskSignals";
import runPortfolioHealthAnalyzer from "@salesforce/apex/WealthAIPortfolioUseCaseService.runPortfolioHealthAnalyzer";
import runPortfolioReviewCopilot from "@salesforce/apex/WealthAIPortfolioUseCaseService.runPortfolioReviewCopilot";
import runPortfolioCommentaryGenerator from "@salesforce/apex/WealthAIPortfolioUseCaseService.runPortfolioCommentaryGenerator";
import runRiskExposureDetection from "@salesforce/apex/WealthAIPortfolioUseCaseService.runRiskExposureDetection";

function listUrl(objectApiName) {
  return `/lightning/o/${objectApiName}/list?filterName=Recent`;
}

function severityToTone(severity) {
  if (severity === "Critical" || severity === "High") {
    return "critical";
  }
  if (severity === "Medium") {
    return "warning";
  }
  return "neutral";
}

export default class PortfolioCopilotPanel extends LightningElement {
  @api recordId;
  selectedAccountId;
  accountOptions = [];
  snapshot;
  alertItems = [];
  signalItems = [];
  loading = false;
  errorMessage;
  lastAction;

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
        this.loadData();
      }
    } else if (error) {
      this.errorMessage = this.normalizeError(error);
    }
  }

  connectedCallback() {
    this.loadData();
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
        key: "health",
        label: "Client Health",
        display: this.displayNumber(this.snapshot.healthScore),
        tone: this.snapshot.healthScore >= 70 ? "success" : "warning",
        recordUrl: listUrl("Client_Health_Score__c")
      },
      {
        key: "alerts",
        label: "Open Portfolio Alerts",
        display: String(this.snapshot.openAlerts),
        tone: this.snapshot.openAlerts > 1 ? "critical" : "warning",
        recordUrl: listUrl("Portfolio_Alert__c")
      },
      {
        key: "signals",
        label: "Open Risk Signals",
        display: String(this.snapshot.openRiskSignals),
        tone: this.snapshot.openRiskSignals > 0 ? "warning" : "neutral",
        recordUrl: listUrl("Risk_Signal__c")
      }
    ];
  }

  handleAccountChange(event) {
    this.selectedAccountId = event.detail.value;
    this.loadData();
  }

  async handleHealthAnalyzer() {
    await this.executeAction(
      runPortfolioHealthAnalyzer,
      "Portfolio health analyzer completed.",
      "Portfolio_Alert__c",
      (result) =>
        result.severity === "Critical" || result.severity === "High"
          ? "Escalate to the portfolio manager and review the drift alert today."
          : "Review the drift alert at your next portfolio check-in."
    );
  }

  async handleReviewCopilot() {
    await this.executeAction(
      runPortfolioReviewCopilot,
      "Portfolio review generated.",
      "AI_Insight__c",
      "Share this review summary with the client or portfolio manager as appropriate."
    );
  }

  async handleCommentary() {
    await this.executeAction(
      runPortfolioCommentaryGenerator,
      "Portfolio commentary generated.",
      "AI_Insight__c",
      "Use this commentary in client-facing communications or the next portfolio review."
    );
  }

  async handleRiskDetection() {
    await this.executeAction(
      runRiskExposureDetection,
      "Risk exposure detection completed.",
      "Risk_Signal__c",
      (result) =>
        result.severity === "Critical"
          ? "Escalate immediately — concentration risk exceeds policy tolerance."
          : "Review the exposure signal and confirm mitigation steps with the client."
    );
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
        tone: severityToTone(result.severity),
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

  async loadData() {
    if (!this.hasAccount) {
      this.snapshot = undefined;
      this.alertItems = [];
      this.signalItems = [];
      return;
    }

    this.loading = true;
    this.errorMessage = undefined;
    try {
      const [snapshot, alerts, signals] = await Promise.all([
        getPortfolioSnapshot({ accountId: this.activeAccountId }),
        getLatestPortfolioAlerts({ accountId: this.activeAccountId }),
        getLatestRiskSignals({ accountId: this.activeAccountId })
      ]);
      this.snapshot = snapshot;
      this.alertItems = alerts;
      this.signalItems = signals;
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

  displayNumber(value) {
    return value === null || value === undefined
      ? "-"
      : String(Math.round(value));
  }
}
