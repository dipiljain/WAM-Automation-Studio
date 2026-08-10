import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getInstitutionalAccountOptions from "@salesforce/apex/WealthAIInstitutionalUseCaseService.getInstitutionalAccountOptions";
import getInstitutionalSnapshot from "@salesforce/apex/WealthAIInstitutionalUseCaseService.getInstitutionalSnapshot";
import getInstitutionalStakeholders from "@salesforce/apex/WealthAIInstitutionalUseCaseService.getInstitutionalStakeholders";
import runMandateComplianceCheck from "@salesforce/apex/WealthAIInstitutionalUseCaseService.runMandateComplianceCheck";
import runInstitutionalProposalCopilot from "@salesforce/apex/WealthAIInstitutionalUseCaseService.runInstitutionalProposalCopilot";
import generateCommitteeReport from "@salesforce/apex/WealthAIInstitutionalUseCaseService.generateCommitteeReport";
import runInstitutionalKYBOnboarding from "@salesforce/apex/WealthAIInstitutionalUseCaseService.runInstitutionalKYBOnboarding";
import runInstitutionalRiskSurveillance from "@salesforce/apex/WealthAIInstitutionalUseCaseService.runInstitutionalRiskSurveillance";
import runInstitutionalLiquidityForecast from "@salesforce/apex/WealthAIInstitutionalUseCaseService.runInstitutionalLiquidityForecast";
import runAutonomousInstitutionalMonitoring from "@salesforce/apex/WealthAIInstitutionalUseCaseService.runAutonomousInstitutionalMonitoring";

function listUrl(objectApiName) {
  return `/lightning/o/${objectApiName}/list?filterName=Recent`;
}

export default class InstitutionalRelationshipWorkbench extends LightningElement {
  @api recordId;
  selectedAccountId;
  accountOptions = [];
  snapshot;
  stakeholderItems = [];
  loading = false;
  errorMessage;
  lastAction;

  @wire(getInstitutionalAccountOptions)
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

  get selectedAccountLabel() {
    const match = this.accountOptions.find(
      (option) => option.value === this.activeAccountId
    );
    return match ? match.label : undefined;
  }

  get hasActivity() {
    if (!this.snapshot) {
      return false;
    }
    return (
      this.snapshot.mandateCount > 0 ||
      this.snapshot.mandateBreaches > 0 ||
      this.snapshot.openProposals > 0 ||
      this.snapshot.openFindings > 0 ||
      this.snapshot.openRiskSignals > 0 ||
      this.snapshot.activeWorkflows > 0
    );
  }

  get metricTiles() {
    if (!this.snapshot) {
      return [];
    }
    return [
      {
        key: "mandates",
        label: "Mandates Tracked",
        display: String(this.snapshot.mandateCount),
        tone: "neutral",
        recordUrl: listUrl("Institutional_Mandate__c")
      },
      {
        key: "breaches",
        label: "Mandate Breaches",
        display: String(this.snapshot.mandateBreaches),
        tone: this.snapshot.mandateBreaches > 0 ? "critical" : "success",
        recordUrl: listUrl("Institutional_Mandate__c")
      },
      {
        key: "proposals",
        label: "Open Proposals",
        display: String(this.snapshot.openProposals),
        tone: this.snapshot.openProposals > 0 ? "warning" : "neutral",
        recordUrl: listUrl("AI_Recommendation__c")
      },
      {
        key: "findings",
        label: "Open Findings",
        display: String(this.snapshot.openFindings),
        tone: this.snapshot.openFindings > 0 ? "critical" : "success",
        recordUrl: listUrl("Compliance_Finding__c")
      },
      {
        key: "risk",
        label: "Risk Signals",
        display: String(this.snapshot.openRiskSignals),
        tone: this.snapshot.openRiskSignals > 0 ? "warning" : "success",
        recordUrl: listUrl("Risk_Signal__c")
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

  handleMandateCheck() {
    this.handleAction(
      runMandateComplianceCheck,
      "Mandate compliance check completed.",
      "Institutional_Mandate__c",
      (result) =>
        result.tone === "critical"
          ? "Escalate to compliance and schedule a mandate review with the client committee before the next reporting cycle."
          : "No action needed — the mandate is within policy. Next review is due per your standard cadence."
    );
  }

  handleProposalCopilot() {
    this.handleAction(
      runInstitutionalProposalCopilot,
      "Institutional proposal drafted.",
      "AI_Recommendation__c",
      "Review the drafted proposal, then share it with the client's investment committee for sign-off."
    );
  }

  handleCommitteeReport() {
    this.handleAction(
      generateCommitteeReport,
      "Committee report generated.",
      "Advisor_Briefing__c",
      (result) =>
        result.tone === "warning"
          ? "Distribute this report ahead of the next committee meeting and flag the breach(es) for discussion."
          : "Distribute this report to the committee as part of the regular review cycle."
    );
  }

  handleKYBOnboarding() {
    this.handleAction(
      runInstitutionalKYBOnboarding,
      "KYB onboarding checklist created.",
      "Compliance_Finding__c",
      "Complete the KYC/KYB checklist and collect verification documents before proceeding with onboarding."
    );
  }

  handleRiskSurveillance() {
    this.handleAction(
      runInstitutionalRiskSurveillance,
      "Risk surveillance completed.",
      "Risk_Signal__c",
      "Review the flagged signal with the portfolio manager and confirm it's within policy tolerance."
    );
  }

  handleLiquidityForecast() {
    this.handleAction(
      runInstitutionalLiquidityForecast,
      "Liquidity forecast completed.",
      "Risk_Signal__c",
      "No action required this quarter. Share the outlook with treasury/ops only if a cash need is identified."
    );
  }

  handleAutonomousMonitoring() {
    this.handleAction(
      runAutonomousInstitutionalMonitoring,
      "Autonomous institutional monitoring run completed.",
      "Risk_Signal__c",
      "Review and approve or reject the autonomous agent's escalation on the risk signal record."
    );
  }

  async loadData() {
    if (!this.activeAccountId) {
      this.snapshot = undefined;
      this.stakeholderItems = [];
      return;
    }
    this.loading = true;
    this.errorMessage = undefined;
    try {
      const [snapshot, stakeholders] = await Promise.all([
        getInstitutionalSnapshot({ accountId: this.activeAccountId }),
        getInstitutionalStakeholders({ accountId: this.activeAccountId })
      ]);
      this.snapshot = snapshot;
      this.stakeholderItems = stakeholders;
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
