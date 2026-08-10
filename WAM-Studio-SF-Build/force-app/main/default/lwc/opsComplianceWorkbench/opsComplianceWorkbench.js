import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAccountOptions from "@salesforce/apex/WealthAIAdvisorUseCaseService.getAccountOptions";
import getWorkbenchSnapshot from "@salesforce/apex/WealthAIDistributionComplianceOpsService.getWorkbenchSnapshot";
import getDistributionItems from "@salesforce/apex/WealthAIDistributionComplianceOpsService.getDistributionItems";
import getComplianceItems from "@salesforce/apex/WealthAIDistributionComplianceOpsService.getComplianceItems";
import getOperationsItems from "@salesforce/apex/WealthAIDistributionComplianceOpsService.getOperationsItems";
import runLeadScoring from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runLeadScoring";
import runLeadPrioritization from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runLeadPrioritization";
import runProspectResearch from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runProspectResearch";
import runKYCCopilot from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runKYCCopilot";
import runAMLScreening from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runAMLScreening";
import runRegulatoryMonitoring from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runRegulatoryMonitoring";
import runOnboardingAssistant from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runOnboardingAssistant";
import runDocumentExtraction from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runDocumentExtraction";
import runWorkflowAutomation from "@salesforce/apex/WealthAIDistributionComplianceOpsService.runWorkflowAutomation";

function listUrl(objectApiName) {
  return `/lightning/o/${objectApiName}/list?filterName=Recent`;
}

export default class OpsComplianceWorkbench extends LightningElement {
  @api recordId;
  selectedAccountId;
  accountOptions = [];
  snapshot;
  distributionItems = [];
  complianceItems = [];
  operationsItems = [];
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
        key: "dist",
        label: "Referral Predictions",
        display: String(this.snapshot.referralPredictions),
        tone: this.snapshot.referralPredictions > 0 ? "warning" : "neutral",
        recordUrl: listUrl("Referral_Prediction__c")
      },
      {
        key: "comp",
        label: "Open Findings",
        display: String(this.snapshot.openFindings),
        tone: this.snapshot.openFindings > 0 ? "critical" : "success",
        recordUrl: listUrl("Compliance_Finding__c")
      },
      {
        key: "ops",
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

  handleLeadScoring() {
    this.handleAction(
      runLeadScoring,
      "Lead scoring completed.",
      "Referral_Prediction__c",
      (result) =>
        result.tone === "critical"
          ? "Prioritize outreach to this lead this week."
          : "Add this lead to the standard nurture queue."
    );
  }

  handleLeadPrioritization() {
    this.handleAction(
      runLeadPrioritization,
      "Lead prioritization completed.",
      "Referral_Prediction__c",
      (result) =>
        result.tone === "critical"
          ? "Prioritize outreach to this lead this week."
          : "Add this lead to the standard nurture queue."
    );
  }

  handleProspectResearch() {
    this.handleAction(
      runProspectResearch,
      "Prospect research completed.",
      "AI_Insight__c",
      "Review the prospect research and decide whether to proceed with outreach."
    );
  }

  handleKYC() {
    this.handleAction(
      runKYCCopilot,
      "KYC copilot completed.",
      "Compliance_Finding__c",
      "Complete the KYC checklist and resolve before account activity resumes."
    );
  }

  handleAML() {
    this.handleAction(
      runAMLScreening,
      "AML screening completed.",
      "Compliance_Finding__c",
      "Await analyst review before proceeding with any transactions."
    );
  }

  handleRegulatory() {
    this.handleAction(
      runRegulatoryMonitoring,
      "Regulatory monitoring completed.",
      "Compliance_Finding__c",
      "Review the regulatory policy delta with compliance before your next filing."
    );
  }

  handleOnboarding() {
    this.handleAction(
      runOnboardingAssistant,
      "Onboarding assistant completed.",
      "Workflow_Execution__c",
      "Confirm the assigned onboarding checklist is completed by the client."
    );
  }

  handleDocumentExtraction() {
    this.handleAction(
      runDocumentExtraction,
      "Document extraction completed.",
      "Workflow_Execution__c",
      "Verify extracted document data before filing into the client record."
    );
  }

  handleWorkflowAutomation() {
    this.handleAction(
      runWorkflowAutomation,
      "Workflow automation completed.",
      "Workflow_Execution__c",
      "Confirm the automated workflow completed as expected."
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
      const [snapshot, distribution, compliance, operations] =
        await Promise.all([
          getWorkbenchSnapshot({ accountId: this.activeAccountId }),
          getDistributionItems({ accountId: this.activeAccountId }),
          getComplianceItems({ accountId: this.activeAccountId }),
          getOperationsItems({ accountId: this.activeAccountId })
        ]);
      this.snapshot = snapshot;
      this.distributionItems = distribution;
      this.complianceItems = compliance;
      this.operationsItems = operations;
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
