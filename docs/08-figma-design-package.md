# Deliverable 8 — Figma Design Package

The design package is delivered as a **live Figma file** plus this specification. It is **Cosmos / SLDS-aligned** so screens map cleanly to Lightning components and FSC record pages. The package defines the design tokens, type and color systems, grid, elevation, the component library, light/dark theming, and the file structure used to build the [D7](07-ux-design-specs.md) screens.

Live file: **[FS-Automation-Studio](https://www.figma.com/design/G6hyOQT78XLfwDrWpiaq6g/FS-Automation-Studio)**
- Page **Wealth AI Studio** → frame **00 Design System Foundation** (tokens, color, type ramp) and **Advisor Home — Daily Briefing** (reference screen).

## 1. Design tokens

### Color (light)
| Token | Hex | Usage |
|---|---|---|
| Brand/Cloud Blue 60 | `#0176D3` | Primary actions, links, focus |
| Brand/Cloud Blue 50 | `#1B96FF` | Hover/active accents |
| Brand/Cloud Blue 30 | `#90D0FE` | Selected nav, subtle accents |
| Brand/Navy 100 | `#032D60` | Nav rail, headers |
| Brand/Navy 80 | `#014486` | Nav hover |
| Neutral/White | `#FFFFFF` | Surfaces/cards |
| Neutral/Background | `#F3F3F3` | App background |
| Neutral/Border | `#E5E5E5` | Card/divider borders |
| Neutral/Border Strong | `#C9C9C9` | Inputs, secondary buttons |
| Text/Primary | `#181818` | Headings/body |
| Text/Secondary | `#444444` | Supporting text |
| Text/Tertiary | `#747474` | Meta/labels |
| Feedback/Success | `#2E844A` | Positive, on-track |
| Feedback/Warning | `#FE9339` | Caution, review |
| Feedback/Error | `#EA001E` | Critical, act-now |
| Feedback/Info | `#0176D3` | Informational |

Feedback "soft" backgrounds (for badges/banners): Success `#EBF7EE`, Warning `#FEF1E6`, Error `#FEE9EA`, Info `#EAF5FE`.

### Color (dark)
| Token | Hex |
|---|---|
| Dark/Background | `#0B0B0B` |
| Dark/Surface | `#1A1A1A` |
| Dark/Border | `#2E2E2E` |
| Text/Inverse | `#FFFFFF` |

Brand and feedback hues are reused in dark mode at adjusted luminance; maintain >= 4.5:1 contrast.

### Typography
Type family: **Salesforce Sans** (proxied by **Inter** in the Figma file). Ramp:

| Style | Size / Weight |
|---|---|
| Display/Large | 28 / Bold |
| Heading/Large | 20 / Semi Bold |
| Heading/Medium | 16 / Semi Bold |
| Body/Regular | 13 / Regular |
| Body/Medium | 13 / Medium |
| Body/Small | 12 / Regular |
| Label/Caps | 11 / Semi Bold (uppercase, tracked) |

### Spacing, radius, elevation
- **Spacing scale:** 4, 8, 12, 16, 24, 32, 40 (4px base).
- **Radius:** 6 (controls), 8 (buttons/pills), 12 (cards), 16-18 (search/input pills).
- **Elevation:** flat surfaces with 1px borders by default; modal/popover use a soft shadow (y2 blur8 8% black). Avoid heavy shadows to match SLDS.

### Grid
12-column, 1440px desktop reference, 24px gutters/margins. App shell: 64px nav rail + 1376px content. Mobile: 390px, 16px margins, 4-col.

## 2. Component library

| Component | Spec |
|---|---|
| Nav rail | 64px, Navy 100; logo (34px) + icon items (22px); active = Cloud Blue 30 |
| Top bar | 56px white, bottom border; title, search pill (300x34), Ask Agentforce button, avatar (34px) |
| Page header | Title (Heading/Large) + context (Body) + action buttons (primary/secondary) |
| KPI card | 12px radius, label (Label/Caps), value (Display-ish 24/Bold), delta (success/error) |
| Card | White, 12px radius, 1px border, 16px padding, 12px internal gap; optional title |
| List row | 52px, title (Body/Medium) + meta (Body/Small) + status badge; bottom divider |
| Badge | Pill, 10px radius, soft feedback background + feedback text color |
| Button | Primary (Cloud Blue 60 / white text), Secondary (white / border / primary text); 8px radius |
| Search/Input pill | Background `#F3F3F3`, 16-18px radius, placeholder Text/Tertiary |
| AI assistant panel | Card with chat bubbles (user = Cloud Blue 60/white, agent = `#EEF4FB`/primary) + pinned input + send |
| Chat bubble | 12px radius, max width to panel, wraps text; source chips for citations |
| Empty/Loading/Error states | Skeleton blocks, guided empty CTA, inline error + retry |

## 3. Figma file structure & conventions

```
FS-Automation-Studio (file)
└─ Page: Wealth AI Studio
   ├─ 00 Design System Foundation   (tokens, color, type ramp)
   ├─ Advisor Home — Daily Briefing (desktop, reference build)
   ├─ [D7-02 … D7-16]  desktop screens (queued)
   └─ [D7-M1 … D7-M8]  mobile screens (queued)
```

- **Local styles:** color paint styles (`Brand/…`, `Neutral/…`, `Text/…`, `Feedback/…`, `Dark/…`) and text styles (`Display/…`, `Heading/…`, `Body/…`, `Label/…`) are created in the file.
- **Naming:** frames named by screen (`Advisor Home — Daily Briefing`); sections by role (`Nav`, `TopBar`, `Content`, `Card …`, `KPI`, `item`, `badge`, `bubble`).
- **Layout:** auto-layout for content stacks/rows; fixed app-shell chrome; 24px content padding.

## 4. Developer handoff → Salesforce

| Figma element | Salesforce realization |
|---|---|
| App shell | Lightning app + utility bar; left nav via App Navigation |
| KPI strip | CRM Analytics widgets / LWC KPI cards |
| Cards & lists | Lightning record/related-list components, LWC datatables |
| AI assistant panel | Agentforce in Lightning (Einstein Copilot/Agent) + custom LWC |
| Badges/feedback | SLDS badges, themes, and toasts |
| Tokens | Map to SLDS design tokens / styling hooks; custom values via CSS custom properties |

Charts shown as placeholders in Figma map to CRM Analytics or LWC chart components; never hard-code figures, bind to live data ([D5](05-fsc-data-model.md)).

## 5. Build status & method

- **Built live (validated):** Design System Foundation + Advisor Home — Daily Briefing, via the Figma MCP (`use_figma`) using a reusable Cosmos app-shell generator (deterministic widths/heights, explicit auto-layout sizing).
- **Queued:** the remaining 15 desktop + 8 mobile screens are fully specified in [D7](07-ux-design-specs.md) and reuse the same generator; live creation paused by the **Figma MCP Starter-plan tool-call limit** and will resume when the limit resets or the plan is upgraded.
- **Reproducibility:** screens are generated programmatically, so the full set can be rebuilt deterministically from the specs and tokens above.
