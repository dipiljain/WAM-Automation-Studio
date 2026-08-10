import { LightningElement, api } from "lwc";
import generateActionableFix from "@salesforce/apex/WealthAIStudioService.generateActionableFix";

const TONE_CLASS = {
  success: "status-badge status-badge_success",
  warning: "status-badge status-badge_warning",
  critical: "status-badge status-badge_critical",
  neutral: "status-badge status-badge_neutral"
};

const TONE_LABEL = {
  success: "On track",
  warning: "Review",
  critical: "High priority",
  neutral: "Info"
};

const TONE_ICON = {
  success: "utility:success",
  warning: "utility:warning",
  critical: "utility:error",
  neutral: "utility:info_alt"
};

const CTA_VARIANT = {
  success: "success",
  warning: "brand",
  critical: "destructive",
  neutral: "neutral"
};

export default class WamRecommendationList extends LightningElement {
  @api title = "Top Recommendations";
  @api iconName = "standard:recommendation";
  @api items = [];
  @api loading = false;
  @api errorMessage;
  @api emptyMessage = "Recommendations will appear once actions are generated.";

  expandedKeys = {};
  fixState = {};

  get hasError() {
    return Boolean(this.errorMessage);
  }

  get hasItems() {
    return Array.isArray(this.items) && this.items.length > 0;
  }

  get showEmpty() {
    return !this.loading && !this.hasError && !this.hasItems;
  }

  get normalizedItems() {
    return (this.items || []).map((item, index) => {
      const key = item.key || item.id || `rec-${index}`;
      const title = item.title || "Recommendation";
      const tone = item.tone || "neutral";
      const expanded = Boolean(this.expandedKeys[key]);
      const fix = this.fixState[key] || {};
      return {
        key,
        title,
        subtitle: item.subtitle,
        accountId: item.accountId,
        explanation: item.explanation || "No additional explanation is available for this item.",
        badgeClass: TONE_CLASS[tone] || TONE_CLASS.neutral,
        badgeLabel: TONE_LABEL[tone] || TONE_LABEL.neutral,
        badgeIconName: TONE_ICON[tone] || TONE_ICON.neutral,
        nextStep: this.toNextStep(title, tone),
        ctaVariant: CTA_VARIANT[tone] || CTA_VARIANT.neutral,
        recordUrl: this.toRecordUrl(item.accountId),
        ctaDisabled: !this.toRecordUrl(item.accountId),
        isExpanded: expanded,
        toggleLabel: expanded ? "Hide why" : "Why?",
        showFix: tone === "critical",
        fixLoading: Boolean(fix.loading),
        fixDisabled: Boolean(fix.loading) || Boolean(fix.result),
        fixResult: fix.result,
        fixError: fix.error
      };
    });
  }

  toRecordUrl(accountId) {
    if (!accountId) {
      return undefined;
    }
    return `/lightning/r/Account/${accountId}/view`;
  }

  toNextStep(title, tone) {
    if (tone === "critical") {
      return "Act today";
    }
    if (tone === "warning") {
      return "Review next";
    }
    if ((title || "").toLowerCase().includes("proposal")) {
      return "Open proposal";
    }
    return "Open details";
  }

  handleToggleWhy(event) {
    const key = event.currentTarget.dataset.key;
    const isOpen = Boolean(this.expandedKeys[key]);
    this.expandedKeys = { ...this.expandedKeys, [key]: !isOpen };
  }

  handleOpenRecord(event) {
    const url = event.currentTarget.dataset.recordUrl;
    if (url) {
      window.open(url, "_blank");
    }
  }

  async handleGenerateFix(event) {
    const { key, accountId, title, subtitle } = event.currentTarget.dataset;
    this.fixState = { ...this.fixState, [key]: { loading: true } };
    try {
      const result = await generateActionableFix({
        accountId,
        issueTitle: title,
        issueDetail: subtitle
      });
      this.fixState = {
        ...this.fixState,
        [key]: {
          loading: false,
          result: {
            recordUrl: `/lightning/r/Workflow_Execution__c/${result.recordId}/view`,
            nextStep: result.nextStep
          }
        }
      };
    } catch (error) {
      this.fixState = {
        ...this.fixState,
        [key]: { loading: false, error: this.normalizeError(error) }
      };
    }
  }

  normalizeError(error) {
    if (!error) {
      return "Unexpected error.";
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
