import { LightningElement, api } from "lwc";

const THEME_CLASS = {
  advisor: "briefing-header briefing-header_advisor",
  compliance: "briefing-header briefing-header_compliance",
  executive: "briefing-header briefing-header_executive",
  institutional: "briefing-header briefing-header_institutional",
  partner: "briefing-header briefing-header_partner"
};

export default class WamBriefingHeader extends LightningElement {
  @api personaLabel = "there";
  @api subtitle;
  @api iconName = "utility:info";
  @api theme = "advisor";
  @api focusHeadline;
  @api showReset = false;
  @api resetLabel = "Reset dashboard";

  get themeClass() {
    return THEME_CLASS[this.theme] || THEME_CLASS.advisor;
  }

  handleResetClick() {
    this.dispatchEvent(new CustomEvent("reset"));
  }

  get greeting() {
    const hour = new Date().getHours();
    if (hour < 12) {
      return "Good morning";
    }
    if (hour < 17) {
      return "Good afternoon";
    }
    return "Good evening";
  }

  get formattedDate() {
    return new Date().toLocaleDateString(undefined, {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric"
    });
  }
}
