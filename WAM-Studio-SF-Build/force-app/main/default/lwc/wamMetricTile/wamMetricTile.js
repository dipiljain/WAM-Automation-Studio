import { LightningElement, api } from "lwc";

const TONE_CLASS = {
  success: "tile tile_success",
  warning: "tile tile_warning",
  critical: "tile tile_critical",
  neutral: "tile tile_neutral"
};

const TONE_ICON = {
  success: "utility:success",
  warning: "utility:warning",
  critical: "utility:error",
  neutral: "utility:info_alt"
};

const TONE_LABEL = {
  success: "On track",
  warning: "Needs attention",
  critical: "Critical",
  neutral: "Informational"
};

const TONE_VARIANT = {
  success: "success",
  warning: "warning",
  critical: "error",
  neutral: ""
};

export default class WamMetricTile extends LightningElement {
  @api label;
  @api value;
  @api tone = "neutral";
  @api recordUrl;
  @api context;

  get isClickable() {
    return Boolean(this.recordUrl);
  }

  get hasContext() {
    return Boolean(this.context);
  }

  get tileClass() {
    const base = TONE_CLASS[this.tone] || TONE_CLASS.neutral;
    return this.isClickable ? `${base} tile_clickable` : base;
  }

  get toneIconName() {
    return TONE_ICON[this.tone] || TONE_ICON.neutral;
  }

  get toneLabel() {
    return TONE_LABEL[this.tone] || TONE_LABEL.neutral;
  }

  get toneVariant() {
    return TONE_VARIANT[this.tone] ?? TONE_VARIANT.neutral;
  }
}
