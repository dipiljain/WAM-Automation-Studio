## Designer Output — Iteration 1

### Artifact

**Before:** The current page gives nearly every section equal visual weight, places secondary metrics before client work, repeats bright status pills, and exposes long unstructured lists.

**After:** A calm, task-first command center with this hierarchy:

1. Greeting and concise day summary
2. Urgent client work
3. Top recommendations
4. Portfolio metrics
5. Supporting intelligence and workflow
6. Advisor tools and command center

**Desktop wireframe**

```text
┌──────────────────────────────────────────────────────────────────┐
│ Advisor Home                                  Refreshed 9:42 AM  │
│ Good morning, Jordan                                             │
│ 3 clients need attention today · 5 recommendations are ready     │
├───────────────────────────────────────┬──────────────────────────┤
│ Needs Your Attention                  │ Top Recommendations      │
│ 5 of 8 prioritized items              │ 4 of 18 recommendations │
│ [Severity] Client · issue    [Review] │ [Priority] Client        │
│ [Severity] Client · issue    [Review] │ Rationale       [Review] │
│ [Severity] Client · issue    [Review] │ ...                      │
│ [View all urgent work]                │ [More Recommendations]   │
├───────────────────────────────────────┴──────────────────────────┤
│ Portfolio at a Glance: 18 Recommendations | 55 Insights | ...   │
├───────────────────────────────────────┬──────────────────────────┤
│ Latest Insights                      │ Suggested Next Workflow  │
│ Three concise insight rows           │ Summary · steps · time   │
│ [View all insights]                  │ [Start workflow]         │
├───────────────────────────────────────┴──────────────────────────┤
│ ▸ Advisor Tools: client context and Advisor Action Center        │
│ ▸ Growth and Service Command Center                              │
└──────────────────────────────────────────────────────────────────┘
```

**Desktop specifications**

- Root container: `slds-container_x-large slds-container_center`.
- Page padding: `slds-p-around_medium`; section separation: `slds-m-bottom_large`.
- Primary work grid: 12 columns with `slds-gutters_medium`.
  - Needs Your Attention: `slds-large-size_7-of-12`.
  - Top Recommendations: `slds-large-size_5-of-12`.
- Show a maximum of five attention items and four recommendations before footer navigation.
- Supporting intelligence grid:
  - Latest Insights: `8-of-12`.
  - Suggested Next Workflow: `4-of-12`.
- Use white SLDS cards on the standard neutral page surface. Avoid custom shadows, gradients, saturated banners, and decorative borders.
- Reserve error/warning colors for genuine status. Use the Salesforce brand color only for links, selected states, and primary actions.

**Card anatomy**

- Header: semantic heading, total count, optional utility action.
- Row:
  - Status icon and text such as “Overdue” or “Due today.”
  - Client or household name as the primary link.
  - One-line task or recommendation title.
  - One supporting metadata line: deadline, source, or expected outcome.
  - One consistent primary action: **Review**.
- Expanded explanations such as “Why this matters” use a disclosure control rather than permanent body text.
- Card footer uses a full-width or clearly aligned route:
  - **View all urgent work**
  - **More Recommendations (18)**
- Rows are separated with standard SLDS borders and spacing, not individual floating cards.

### Target Context

- **Platform:** Salesforce Lightning Experience and Salesforce Mobile App.
- **Desktop:** Full advisor command center at widths of 1024px and above.
- **Tablet:** Single-column presentation from 768–1023px.
- **Mobile:** Focused daily briefing from 320–767px.
- **Design system:** SLDS/SLDS2, Lightning Base Components, semantic global styling hooks, and standard spacing utilities.
- Existing Lightning global navigation and Salesforce Mobile App chrome remain unchanged.

### Component Hierarchy

```text
c-advisor-home
├── page-header
│   ├── lightning-formatted-date-time
│   └── lightning-button-icon (Refresh)
├── day-summary
│   ├── greeting heading
│   ├── urgent count
│   └── recommendation count
├── primary-work-layout (lightning-layout)
│   ├── attention-card (SLDS card)
│   │   ├── attention-row × 5 desktop / × 3 mobile
│   │   │   ├── lightning-icon
│   │   │   ├── record/task link
│   │   │   ├── status text
│   │   │   └── lightning-button (desktop only)
│   │   └── lightning-button variant="base" (View all)
│   └── recommendations-card (SLDS card)
│       ├── recommendation-row × 4 desktop / × 3 mobile
│       │   ├── lightning-badge
│       │   ├── recommendation link
│       │   ├── rationale and client metadata
│       │   └── lightning-button (desktop only)
│       └── lightning-button (More Recommendations)
├── portfolio-at-a-glance (desktop only)
│   └── metric-link × 4
├── supporting-intelligence-layout (desktop only)
│   ├── latest-insights-card
│   └── suggested-workflow-card
├── lightning-accordion (desktop only)
│   ├── Advisor Tools
│   │   ├── lightning-record-picker for Account/Household
│   │   └── advisor-action-center
│   └── Growth and Service Command Center
└── section-state
    ├── lightning-spinner/loading blueprint
    ├── empty state
    └── SLDS alert with Retry
```

The Advisor Tools and Command Center accordion sections are collapsed by default.

### Responsive Behavior

**Desktop**

- Greeting is compact, not a full-width promotional banner.
- Needs Your Attention appears first and receives the wider column.
- Metric cells form one compact horizontal band below primary work.
- Insight descriptions are limited to two lines.
- Primary cards may grow independently; do not force artificial equal heights.
- At widths above 1024px, actions remain aligned at the trailing edge of each row.

**Tablet**

- Primary cards stack in this order: attention, recommendations.
- Metrics use a two-by-two grid.
- Supporting intelligence stacks beneath metrics.
- Advisor Tools remains collapsed.
- No horizontal scrolling.

**Mobile**

Display only:

1. “Good morning, {first name}”
2. Date and summary: “3 clients need attention · 5 recommendations ready”
3. Up to three urgent items
4. **View all urgent work**
5. Up to three recommendations
6. Prominent full-width **More Recommendations** button

Do not render on the mobile home:

- Portfolio metric strip
- Latest Insights
- Detailed household selector
- Suggested workflow
- Advisor Action Center
- Growth and Service Command Center
- Secondary analytics

These remain reachable through Salesforce Mobile navigation or destination pages.

Mobile rows become single interactive links with a trailing chevron; nested row buttons are removed. Each row is at least 56px high, and every interactive target is at least 44×44px. Supporting text is limited to two lines.

### Interaction Rules

- Sort attention items by overdue status, due-today status, severity, then due time.
- Sort recommendations by priority, action deadline, then generated time.
- Selecting a client name opens the relevant record page.
- Selecting an attention item opens its detail or task page.
- Selecting **Review** opens recommendation detail; no recommendation executes directly from the home page.
- **More Recommendations** navigates to the AI Recommendations tab/list while preserving the current app context.
- “Why this matters” disclosure buttons expose supporting rationale with `aria-expanded` and `aria-controls`.
- Refresh updates sections independently and announces completion through a polite live region.
- Destructive, external, or client-facing actions require confirmation on their destination screen.

**States**

- **Loading:** Preserve card dimensions, mark the region `aria-busy="true"`, and show three loading rows or a `lightning-spinner` with accessible loading text.
- **Empty attention:** “You’re caught up. No client work requires immediate attention.”
- **Empty recommendations:** “No recommendations are ready right now,” while retaining the route to the recommendations page.
- **Partial error:** Keep successful cards available and show an inline SLDS alert with **Retry** inside the failed section.
- **Page error:** Show a concise alert below the greeting; do not rely on a toast alone.
- **Mobile offline:** Show cached content with “Last updated {time}.” Keep primed detail routes available and explain when a network-dependent action cannot run.

### Accessibility and SLDS Notes

- Meet WCAG 2.2 AA: 4.5:1 text contrast and 3:1 contrast for controls and meaningful graphics.
- Use one `h1` for the greeting/page title, `h2` for sections, and semantic list markup for card rows.
- Status must always include text or an accessible icon label; color alone is insufficient.
- Preserve standard SLDS focus indicators and logical keyboard order.
- Do not make a complete desktop row clickable when it also contains buttons; use a specific title link and action button.
- Decorative icons receive empty alternative text. Meaningful icons receive explicit assistive text.
- Truncated content remains available on the detail page; do not depend on hover tooltips.
- Use `lightning-button`, `lightning-button-icon`, `lightning-icon`, `lightning-badge`, `lightning-layout`, `lightning-record-picker`, and `lightning-accordion` before custom equivalents.
- Use SLDS semantic styling hooks and spacing utilities rather than custom hexadecimal colors, radii, shadows, or overrides of internal base-component classes.
- All mobile controls meet the 44px minimum target and work without hover.

### Changelog

- Reordered the experience around urgent client work and recommendations.
- Replaced the oversized greeting banner with a compact day summary.
- Reduced visible list counts and added explicit routes to full work queues.
- Moved metrics, insights, workflows, selectors, and command-center controls below primary work.
- Defined a deliberately reduced Salesforce Mobile experience.
- Standardized card anatomy, action naming, navigation, and state handling.
- Added keyboard, offline, error, empty, loading, and WCAG requirements.

### Resolved Reviewer Findings

No prior reviewer findings
