import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPartnerAccountOptions from "@salesforce/apex/WealthAIPartnerUseCaseService.getPartnerAccountOptions";
import getPartnerRollupSnapshot from "@salesforce/apex/WealthAIPartnerUseCaseService.getPartnerRollupSnapshot";
import getAtRiskParticipants from "@salesforce/apex/WealthAIPartnerUseCaseService.getAtRiskParticipants";
import getPartnerComplianceRollup from "@salesforce/apex/WealthAIPartnerUseCaseService.getPartnerComplianceRollup";
import runWhiteLabelAdvisorAction from "@salesforce/apex/WealthAIPartnerUseCaseService.runWhiteLabelAdvisorAction";
import runPartnerOnboardingBatch from "@salesforce/apex/WealthAIPartnerUseCaseService.runPartnerOnboardingBatch";
import runCrossProgramReferral from "@salesforce/apex/WealthAIPartnerUseCaseService.runCrossProgramReferral";
import runParticipantEngagementCampaign from "@salesforce/apex/WealthAIPartnerUseCaseService.runParticipantEngagementCampaign";
import runAutonomousPartnerGrowthAgent from "@salesforce/apex/WealthAIPartnerUseCaseService.runAutonomousPartnerGrowthAgent";

function listUrl(objectApiName) {
  return `/lightning/o/${objectApiName}/list?filterName=Recent`;
}

export default class PartnerCommandCenter extends LightningElement {
  @api recordId;
  selectedAccountId;
  selectedParticipantId;
  accountOptions = [];
  snapshot;
  atRiskItems = [];
  complianceItems = [];
  loading = false;
  errorMessage;
  lastAction;

  @wire(getPartnerAccountOptions)
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

  get participantOptions() {
    return this.atRiskItems.map((item) => ({
      label: item.title,
      value: item.accountId
    }));
  }

  get whiteLabelDisabled() {
    return this.actionDisabled || !this.selectedParticipantId;
  }

  get metricTiles() {
    if (!this.snapshot) {
      return [];
    }
    return [
      {
        key: "participants",
        label: "Participant Households",
        display: String(this.snapshot.participantCount),
        tone: "neutral",
        recordUrl: listUrl("Account")
      },
      {
        key: "atRisk",
        label: "At-Risk Participants",
        display: String(this.snapshot.atRiskParticipants),
        tone: this.snapshot.atRiskParticipants > 0 ? "critical" : "success",
        recordUrl: listUrl("Account")
      },
      {
        key: "referrals",
        label: "Open Referrals",
        display: String(this.snapshot.openReferrals),
        tone: this.snapshot.openReferrals > 0 ? "warning" : "neutral",
        recordUrl: listUrl("Referral_Prediction__c")
      },
      {
        key: "workflows",
        label: "Active Workflows",
        display: String(this.snapshot.activeWorkflows),
        tone: this.snapshot.activeWorkflows > 0 ? "warning" : "success",
        recordUrl: listUrl("Workflow_Execution__c")
      },
      {
        key: "findings",
        label: "Compliance Findings",
        display: String(this.snapshot.complianceFindings),
        tone: this.snapshot.complianceFindings > 0 ? "critical" : "success",
        recordUrl: listUrl("Compliance_Finding__c")
      }
    ];
  }

  handleAccountChange(event) {
    this.selectedAccountId = event.detail.value;
    this.selectedParticipantId = undefined;
    this.loadData();
  }

  handleParticipantChange(event) {
    this.selectedParticipantId = event.detail.value;
  }

  async handleAction(
    actionFn,
    successMessage,
    extraParams,
    objectApiName,
    nextStep
  ) {
    if (!this.activeAccountId) {
      return;
    }
    this.loading = true;
    this.errorMessage = undefined;
    try {
      const result = await actionFn({
        accountId: this.activeAccountId,
        ...extraParams
      });
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

  handleOnboardingBatch() {
    this.handleAction(
      runPartnerOnboardingBatch,
      "Partner onboarding batch started.",
      undefined,
      "Workflow_Execution__c",
      "Monitor the workflow execution and confirm each new participant account completes onboarding."
    );
  }

  handleCrossProgramReferral() {
    this.handleAction(
      runCrossProgramReferral,
      "Cross-program referral identified.",
      undefined,
      "Referral_Prediction__c",
      (result) =>
        result.tone === "critical"
          ? "High-priority referral — route to the receiving program's advisor this week."
          : "Add this referral to the partner program's outreach queue."
    );
  }

  handleEngagementCampaign() {
    this.handleAction(
      runParticipantEngagementCampaign,
      "Participant engagement campaign queued.",
      undefined,
      "AI_Recommendation__c",
      (result) =>
        result.tone === "warning"
          ? "Review the queued campaign and prioritize outreach to at-risk participants."
          : "No at-risk participants right now — campaign queued for standard nurture cadence."
    );
  }

  handleAutonomousGrowth() {
    this.handleAction(
      runAutonomousPartnerGrowthAgent,
      "Autonomous partner growth run completed.",
      undefined,
      "Referral_Prediction__c",
      "Review and approve or reject the autonomous agent's referral opportunity."
    );
  }

  async handleWhiteLabelAction() {
    if (!this.activeAccountId || !this.selectedParticipantId) {
      return;
    }
    this.loading = true;
    this.errorMessage = undefined;
    try {
      const result = await runWhiteLabelAdvisorAction({
        partnerAccountId: this.activeAccountId,
        participantAccountId: this.selectedParticipantId
      });
      this.lastAction = {
        ...result,
        recordUrl: result.recordId
          ? `/lightning/r/AI_Recommendation__c/${result.recordId}/view`
          : undefined,
        nextStep:
          result.tone === "critical"
            ? "Deliver this white-label advisor action to the participant this week."
            : "Share this white-label advisor action at the next scheduled touchpoint."
      };
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "White-label advisor action generated.",
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
    if (!this.activeAccountId) {
      this.snapshot = undefined;
      this.atRiskItems = [];
      this.complianceItems = [];
      return;
    }
    this.loading = true;
    this.errorMessage = undefined;
    try {
      const [snapshot, atRisk, compliance] = await Promise.all([
        getPartnerRollupSnapshot({ accountId: this.activeAccountId }),
        getAtRiskParticipants({ accountId: this.activeAccountId }),
        getPartnerComplianceRollup({ accountId: this.activeAccountId })
      ]);
      this.snapshot = snapshot;
      this.atRiskItems = atRisk;
      this.complianceItems = compliance;
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
