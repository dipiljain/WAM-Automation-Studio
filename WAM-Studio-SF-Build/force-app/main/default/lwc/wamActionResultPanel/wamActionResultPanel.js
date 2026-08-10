import { LightningElement, api } from "lwc";

const TONE_ICON = {
  success: "utility:success",
  warning: "utility:warning",
  critical: "utility:error",
  neutral: "utility:info_alt"
};

const TONE_VARIANT = {
  success: "success",
  warning: "warning",
  critical: "error",
  neutral: ""
};

export default class WamActionResultPanel extends LightningElement {
  @api title;
  @api detail;
  @api tone = "neutral";
  @api nextStep;
  @api recordUrl;
  @api recordLabel = "View record";
  @api metaLabel;
  @api metaValue;

  get panelClass() {
    const tone = TONE_ICON[this.tone] ? this.tone : "neutral";
    return `panel panel_${tone}`;
  }

  get toneIconName() {
    return TONE_ICON[this.tone] || TONE_ICON.neutral;
  }

  get toneVariant() {
    return TONE_VARIANT[this.tone] ?? TONE_VARIANT.neutral;
  }
}
