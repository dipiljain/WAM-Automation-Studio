import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAccountOptions from "@salesforce/apex/WealthAIAdvisorUseCaseService.getAccountOptions";
import getAutonomySnapshot from "@salesforce/apex/WealthAIAutonomyUseCaseService.getAutonomySnapshot";
import getRunQueue from "@salesforce/apex/WealthAIAutonomyUseCaseService.getRunQueue";
import getAutonomySignals from "@salesforce/apex/WealthAIAutonomyUseCaseService.getAutonomySignals";
import runAutonomousAdvisorAgent from "@salesforce/apex/WealthAIAutonomyUseCaseService.runAutonomousAdvisorAgent";
import runAutonomousServiceAgent from "@salesforce/apex/WealthAIAutonomyUseCaseService.runAutonomousServiceAgent";
import runAutonomousOperationsAgent from "@salesforce/apex/WealthAIAutonomyUseCaseService.runAutonomousOperationsAgent";
import runAutonomousComplianceAgent from "@salesforce/apex/WealthAIAutonomyUseCaseService.runAutonomousComplianceAgent";
import runAutonomousProspectingAgent from "@salesforce/apex/WealthAIAutonomyUseCaseService.runAutonomousProspectingAgent";
import runAIBranchManager from "@salesforce/apex/WealthAIAutonomyUseCaseService.runAIBranchManager";
import runAutonomousPortfolioMonitoring from "@salesforce/apex/WealthAIAutonomyUseCaseService.runAutonomousPortfolioMonitoring";
import runHyperPersonalizedEngagement from "@salesforce/apex/WealthAIAutonomyUseCaseService.runHyperPersonalizedEngagement";

function listUrl(objectApiName) {
  return `/lightning/o/${objectApiName}/list?filterName=Recent`;
}

export default class AutonomyControlTower extends LightningElement {
  @api recordId;
  selectedAccountId;
  accountOptions = [];
  snapshot;
  runItems = [];
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

  get actionDisabled() {
    return !this.activeAccountId || this.loading;
  }

  get metricTiles() {
    if (!this.snapshot) {
      return [];
    }
    return [
      {
        key: "runs",
        label: "Autonomous Runs",
        display: String(this.snapshot.autonomousRuns),
        tone: this.snapshot.autonomousRuns > 0 ? "warning" : "neutral",
        recordUrl: listUrl("AI_Agent_Run__c")
      },
      {
        key: "approvals",
        label: "Pending Approvals",
        display: String(this.snapshot.pendingApprovals),
        tone: this.snapshot.pendingApprovals > 0 ? "critical" : "success",
        recordUrl: listUrl("AI_Agent_Run__c")
      },
      {
        key: "escalated",
        label: "Escalated Runs",
        display: String(this.snapshot.escalatedRuns),
        tone: this.snapshot.escalatedRuns > 0 ? "critical" : "success",
        recordUrl: listUrl("AI_Agent_Run__c")
      },
      {
        key: "workflows",
        label: "Active Workflows",
        display: String(this.snapshot.activeWorkflows),
        tone: this.snapshot.activeWorkflows > 0 ? "warning" : "success",
        recordUrl: listUrl("Workflow_Execution__c")
      }
    ];
  }

  handleAccountChange(event) {
    this.selectedAccountId = event.detail.value;
    this.loadData();
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

  handleAdvisor() {
    this.handleAction(
      runAutonomousAdvisorAgent,
      "Autonomous advisor run completed.",
      "AI_Recommendation__c",
      "Approve or reject the queued outreach recommendation via human-in-the-loop review."
    );
  }

  handleService() {
    this.handleAction(
      runAutonomousServiceAgent,
      "Autonomous service run completed.",
      "Workflow_Execution__c",
      "No action needed — resolved autonomously without escalation."
    );
  }

  handleOperations() {
    this.handleAction(
      runAutonomousOperationsAgent,
      "Autonomous operations run completed.",
      "Workflow_Execution__c",
      "Monitor the workflow execution for exception routing."
    );
  }

  handleCompliance() {
    this.handleAction(
      runAutonomousComplianceAgent,
      "Autonomous compliance run completed.",
      "Compliance_Finding__c",
      "Approve or reject the escalated finding via human-in-the-loop review before it closes."
    );
  }

  handleProspecting() {
    this.handleAction(
      runAutonomousProspectingAgent,
      "Autonomous prospecting run completed.",
      "Referral_Prediction__c",
      "Approve or reject the new prospecting lead via human-in-the-loop review."
    );
  }

  handleBranchManager() {
    this.handleAction(
      runAIBranchManager,
      "AI branch manager run completed.",
      "AI_Insight__c",
      "Share the coaching insight with the branch leadership team."
    );
  }

  handlePortfolioMonitor() {
    this.handleAction(
      runAutonomousPortfolioMonitoring,
      "Autonomous portfolio monitoring run completed.",
      "Risk_Signal__c",
      "Review the risk signal and portfolio alert; escalate to the portfolio manager if drift persists."
    );
  }

  handlePersonalizedEngagement() {
    this.handleAction(
      runHyperPersonalizedEngagement,
      "Hyper-personalized engagement run completed.",
      "AI_Recommendation__c",
      "Approve the personalized outreach recommendation before it's sent to the client."
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
      const [snapshot, runs, signals] = await Promise.all([
        getAutonomySnapshot({ accountId: this.activeAccountId }),
        getRunQueue({ accountId: this.activeAccountId }),
        getAutonomySignals({ accountId: this.activeAccountId })
      ]);
      this.snapshot = snapshot;
      this.runItems = runs;
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
}
