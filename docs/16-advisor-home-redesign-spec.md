# Deliverable 16 — Advisor Home Dashboard Redesign (Final Spec)

Design-only pass on the Wealth AI Studio **Advisor Home** morning dashboard (`advisorHomeCard` + children), fixing screen-space utilization and visual hierarchy issues found in prior review rounds. No metadata was changed — this is the implementation-ready spec for a follow-up LWC change.

**Final mockup:** [`advisor-home-redesign-mockup.html`](./advisor-home-redesign-mockup.html) — open directly in a browser. It is annotated section-by-section against the components below.

Scope note: the bottom section (`wamClientSelector`, `advisorActionCenter`, `growthServiceCommandCenter`) is **structurally unchanged** — only spacing rhythm was tightened, per constraint.

## 1. Iteration log

Run as an internal designer ⇄ reviewer loop against the textual brief (no reference image was available). Two rounds converged to approval; no `salesforce-ux-designer`/`design-reviewer` subagent tooling was available in this execution context, so the loop was performed directly by this orchestrator, applying the same design → critique → fix → re-critique discipline.

| # | Verdict | Key findings raised | Resolution |
|---|---|---|---|
| 1 (draft) | needs_changes | (a) Header still had unconstrained flex-grow on the text block, so the focus pill floated with dead space on wide viewports; (b) KPI tiles kept small numbers with excess tile padding; (c) 3 equal-width panels gave "Needs Your Attention" no visual priority; (d) Recommendation/Insight rows repeated boilerplate action text; (e) plain text links instead of action buttons; (f) badges were color-only chips with no icon; (g) list rows had a full boxed border nested inside the card border (chrome-on-chrome) | Rebuilt header as a single non-growing flex row (icon + greeting/date + subtitle + divider + focus, all `flex: 0 …`, no `flex:1` stretch) so trailing space sits at the row's outer edge instead of *between* elements; KPI tiles rebuilt value-first (1.9rem bold + tone icon on top, label + context line below); panels split 50/50 with "Needs Your Attention" as one full-height dominant column and Top Recommendations/Latest Insights stacked in the other column; removed generated boilerplate copy, rows now render the existing record-specific `subtitle` plus a real `<lightning-button>` next-step CTA; badges paired with a leading tone icon; row chrome flattened to a hairline bottom divider instead of a bordered box |
| 2 (final) | **approved** | Re-checked all 7 items from round 1 against the revised mockup: header row-packs left with no isolated gap ✅; KPI value is now the dominant visual element with icon + context ✅; left panel is visually dominant (5 rows vs. 3+3 stacked) ✅; no repeated boilerplate string anywhere in the mockup ✅; every row has a real button, not a bare link ✅; every badge carries icon + label, not color alone ✅; rows use single hairline divider, no nested boxed border ✅. Section-to-section vertical gaps normalized to one spacing step (`slds-m-bottom_small`-equivalent) throughout, closing the large dead gaps above the workflow tip and around the KPI strip. Micro-visualizations (score rings, confidence bars) added as optional accents, kept low-contrast so they don't compete with text. | None outstanding — 0 blocking / 0 major findings |

**Open items (non-blocking, optional):** the confidence bar under recommendation rows and the score ring under priority rows are nice-to-have micro-visualizations; they can ship in a later pass without blocking this redesign, and can be omitted on narrow/mobile widths if list density becomes an issue.

## 2. Layout regions & sizing (desktop, 1280–1440px reference)

| Region | Component | Sizing |
|---|---|---|
| 1. Header | `wamBriefingHeader` | Single row, `padding: 0.6rem 1rem` (was `1.25rem 1.5rem`), target height **~52–60px** (was ~110–120px). No `flex: 1` growth on any child — icon/text/divider/focus all `flex: 0 …` so the row left-packs; any leftover width sits as trailing background only, never as a gap *between* the subtitle and the focus pill. |
| 2. KPI strip | `wamMetricTiles` → `wamMetricTile` × 4 | `slds-grid` 4 equal columns (`slds-size_1-of-2 slds-large-size_1-of-4`, unchanged breakpoints). Tile min-height ~4rem, value font bumped to `1.9rem`/`800` weight as the dominant element. |
| 3. List panels | `wamInsightList` (priority), `wamRecommendationList`, `wamInsightList` (latest) | **50/50 grid**, not 33/33/33: left column `slds-size_1-of-1 slds-large-size_1-of-2` = "Needs Your Attention" (dominant, full column height). Right column `slds-large-size_1-of-2` contains a nested vertical stack (`slds-grid slds-grid_vertical` or two stacked `slds-col`s) with "Top Recommendations" above "Latest Insights", each roughly half the left column's height. |
| 4. Workflow tip | existing `flexipage:richText` strip | Unchanged content; top margin reduced to the same single spacing step used between all other sections (no more oversized gap above it). |
| 5. Bottom section | `wamClientSelector`, `advisorActionCenter`, `growthServiceCommandCenter` | Structurally unchanged. Only change: consistent `slds-m-top_small`-equivalent rhythm inherited from the rest of the page instead of default larger card margins. |

## 3. Component-level changes

### `wamBriefingHeader`
- **HTML**: keep icon / greeting+date / subtitle / focus, but wrap greeting+date on one line (`<span class="header-greeting">…</span><span class="header-date">…</span>`) and add a thin vertical divider (`<div class="briefing-divider"></div>`) between the subtitle and the focus block.
- **CSS**:
  - `.briefing-header` padding `1.25rem 1.5rem` → `0.6rem 1rem`.
  - `.briefing-icon` `3rem` → `2.1rem`.
  - `.briefing-greeting` `1.375rem` → `1.05rem`; `.briefing-subtitle` truncate to one line (`overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width: 26rem`).
  - `.briefing-text { flex: 1 1 auto; }` → `flex: 0 1 auto;` (remove the growth that was stretching the row and isolating the focus pill).
  - `.briefing-focus { flex: 0 0 auto; margin-left: 0; }` — remove implicit right-pinning; it now follows immediately after the divider in normal flow.
- **Behavior/JS**: no change to inputs (`personaLabel`, `subtitle`, `focusHeadline`, `theme`, `iconName`).

### `wamMetricTile` / `wamMetricTiles`
- **Visual priority**: `.value` font-size `1.25rem` → `1.9rem`, `font-weight: 700` → `800`; keep tone-colored left border accent (already correct pattern) and keep the tone icon on the value row (already present) — just make it visually paired with the now-larger number.
- **New optional line**: add a `context` slot/field under `.label` (e.g. "+4 vs. yesterday", "Score below 50") rendered at `0.68rem`, muted color. Populate from a new lightweight computed string in `advisorHomeCard.js` (e.g. delta vs. prior day count, or a static qualifier per metric) — no new Apex query required if a static qualifier per metric label is acceptable; otherwise extend `WealthAIHomeController.Metric` with an optional `context` string.
- **Chrome**: keep the existing single-border tile (already minimal); no change needed to `wamMetricTiles.html`'s wrapping `lightning-card` beyond trimming its own subtitle/padding to match the tighter rhythm.

### `wamInsightList` and `wamRecommendationList` (shared pattern)
- **Remove boilerplate content**: delete `wamRecommendationList.js#toActionLabel()` and its rendering (`item.actionLabel` / `<p class="action-label">`). The existing Apex-sourced `subtitle` (already contains account name + the real `Recommended_Action__c` / `Summary__c` text, abbreviated) is the single description line — it is already specific per record and should not be duplicated by a generated generic sentence.
- **Badges**: replace the custom `<span class={item.badgeClass}>{item.badgeLabel}</span>` with an icon-paired badge — either `<lightning-badge label={item.badgeLabel}>` preceded by a small `<lightning-icon icon-name={item.toneIconName} variant={item.toneVariant} size="xx-small">`, or keep the existing custom badge span but prepend the icon glyph/icon-name so tone is never conveyed by color alone (mockup uses `✖ Risk`, `⚠ Review`, `ℹ Info`, `✓ On track` as the pattern).
- **Action affordance**: replace the plain `<a href=…>Open record</a>` + `<span class="next-step">` text with a single `<lightning-button variant={item.ctaVariant} label={item.nextStep} onclick={handleOpenRecord}></lightning-button>`, where `ctaVariant` is `"destructive"`/`"brand"` for `critical`/`warning` tone (matching `nextStep` labels like "Act today"/"Contact"/"Review") and `"neutral"` otherwise. Keep the record navigation logic (`toRecordUrl`) but trigger it from the button's click handler (`window.open` or `NavigationMixin`) instead of an `<a>`.
- **Row chrome**: change `.insight-item` / `.recommendation-item` from a fully bordered, radius'd box (`border: 1px solid …; border-radius: …`) to a hairline bottom divider between rows (`border-bottom: 1px solid var(--slds-g-color-border-base-4, #f0efed)`, last child `border-bottom: none`), removing the boxed-card-inside-a-card look while preserving row separation.
- **Dominant left panel**: in `advisorHomeCard.html`, change the "Needs Your Attention" column from `slds-large-size_1-of-3` to `slds-large-size_1-of-2`, and wrap "Top Recommendations" + "Latest Insights" in a nested stacked container also at `slds-large-size_1-of-2` (each ~50% of that column's height, e.g. via `slds-grid slds-grid_vertical` with two `slds-col`s, or simply two sibling `div`s in document order since they already stack at `slds-size_1-of-1`).
- **Optional micro-visualization** (nice-to-have, non-blocking): a thin `conf-bar`/`conf-fill` under recommendation rows sized to a confidence/priority-derived percentage, and a small colored "ring" showing the numeric health score on priority-queue rows. Keep low-contrast/small so they remain secondary to the text and button.

### Page-level spacing (`advisorHomeCard.html` / shared CSS)
- Normalize the vertical margin between the header, KPI strip, panels row, and the workflow tip strip to a single consistent spacing step (SLDS `slds-m-bottom_small` / `~0.75rem`), removing the currently oversized gaps (notably above the workflow tip and around the KPI strip's own card chrome).
- Bottom section (`wamClientSelector`, `advisorActionCenter`, `growthServiceCommandCenter`) inherits the same spacing step between it and the tip strip and between its own sub-cards — no structural change to those three components.

## 4. Content rules

1. **No generated boilerplate action sentences.** The client-side `toActionLabel()`/generic "Recommended action: review and tailor the generated proposal." string is removed entirely; it duplicated and diluted the already-specific Apex-sourced `subtitle`.
2. **Every row shows record-specific context**, sourced from existing controller fields — no new Apex needed:
   - Priority queue rows: `Account__r.Name` + `"Health score " + Score__c + " — " + <reason>` (already returned by `getAdvisorPriorityQueue`).
   - Recommendation rows: `Account__r.Name + ": " + Recommended_Action__c` (already returned by `getAdvisorRecommendations`), tone from `Priority__c`.
   - Insight rows: `Insight_Type__c + " insight"` + abbreviated `Summary__c` (already returned by `getAdvisorInsights`).
3. **Every row ends in one real action control**, not a bare text link: a `lightning-button` whose label is the existing `nextStep` value (`"Act today"`, `"Contact"`, `"Review"`, `"Open details"`, etc.) and whose tone/variant matches the row's severity tone.
4. **Tone is always conveyed by color + icon + text label together**, never color alone — applies to KPI tiles (already icon+color+number), badges (add icon), and score rings (numeric value inside the tone-colored circle).
5. **KPI tiles lead with the number.** Value is the largest, boldest element in the tile; label and optional context line are secondary, smaller text underneath — reversing the current "number tucked in a corner" hierarchy.
6. **One spacing scale for the whole page.** All inter-section vertical gaps use the same step so no section reads as having an accidental oversized gap; the bottom (out-of-scope) section only inherits this same rhythm, nothing else about it changes.

## 5. Handoff checklist for implementation

- [ ] `wamBriefingHeader.html` / `.css`: single-row compact header, no `flex:1` stretch, divider between subtitle and focus.
- [ ] `wamMetricTile.css`: value font-size/weight bump; optional `context` line.
- [ ] `wamMetricTiles`/`advisorHomeCard.js`: optional `context` string per metric (client-computed or new Apex field — non-blocking if omitted).
- [ ] `wamRecommendationList.js`/`.html`/`.css`: remove `toActionLabel()`, add icon-paired badge, swap link+span for `lightning-button`, flatten row border to divider.
- [ ] `wamInsightList.js`/`.html`/`.css`: same badge/button/divider changes as above.
- [ ] `advisorHomeCard.html`: change panel grid from 3×`1-of-3` to dominant `1-of-2` (Needs Your Attention) + stacked `1-of-2` (Top Recommendations / Latest Insights).
- [ ] Shared spacing: normalize inter-section margins to one step across header → KPI strip → panels → tip strip → bottom section.
- [ ] Verify no visual regression to the bottom section beyond spacing (client selector / action center / growth-service command center remain structurally as-is).
