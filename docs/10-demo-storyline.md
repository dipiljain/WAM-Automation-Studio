# Deliverable 10 — Demo Storyline (20 minutes)

A tight, value-led demo that takes a wealth firm from "AI is interesting" to "AI runs my book." It follows one advisor (Alex) through a realistic day, then zooms out to the firm. Every scene ties to a use case ([D2](02-ai-use-case-catalog.md)), an agent ([D6](06-agentforce-design.md)), a screen ([D7](07-ux-design-specs.md)), and grounded FSC data ([D5](05-fsc-data-model.md)).

## Narrative arc
**"From inbox to insight to action, with trust built in."** Alex starts the day buried in prep, lets Agentforce do the heavy lifting (briefing → meeting prep → portfolio fix → compliant follow-up), grows the book with AI-found opportunities, and the COO sees firm-wide value, all on native Salesforce.

## Audience & framing
- **Primary:** CWO/Head of Wealth, COO, Head of Advisory (value + risk).
- **Secondary:** CIO/Salesforce platform owner (architecture + trust).
- **Frame:** 30 seconds of business pain per scene, then show the product solving it.

## Timing overview (20:00)

| Scene | Time | Persona | Screen | Agent | Use case |
|---|---|---|---|---|---|
| 0. Hook | 0:00-1:30 | — | Title / problem | — | — |
| 1. Daily briefing | 1:30-4:30 | Advisor | D7-01 Advisor Home | Advisor | UC1-2 |
| 2. Meeting prep | 4:30-7:30 | Advisor | D7-04 Meeting Center / D7-02 Client 360 | Advisor | UC3-5 |
| 3. Portfolio fix | 7:30-11:00 | PM/Advisor | D7-03 Portfolio Intelligence | Portfolio | UC6-9 |
| 4. Compliant follow-up | 11:00-13:30 | Advisor + Compliance | D7-10 Proposals / D7-07 Compliance | Advisor + Compliance | UC10, UC30 |
| 5. Grow the book | 13:30-16:00 | Distribution | D7-05 Lead & Opportunity | Distribution | UC11-13 |
| 6. Run the firm | 16:00-18:30 | COO/Ops | D7-14 Executive / D7-12 Operations | Executive + Operations | UC36-40 |
| 7. Trust & close | 18:30-20:00 | CIO + exec | D7-15 Agent Studio / trust layer | Orchestrator | governance |

## Scene-by-scene script

### Scene 0 — Hook (0:00-1:30)
- **Pain:** "A senior advisor spends ~40% of the week on prep, admin, and research, not clients. Risk and compliance add drag. AUM growth depends on hours nobody has."
- **Promise:** "Today you'll see an AI-native wealth studio, built on Salesforce, FSC, and Agentforce, that gives those hours back and grows the book, with trust built in."

### Scene 1 — The daily briefing (1:30-4:30)
- **Screen:** D7-01 Advisor Home (live in Figma).
- **Beat:** Alex logs in to a prioritized briefing: book AUM, clients at risk, meetings, and 6 ranked next best actions.
- **Action:** Click an AI insight ("Sharma portfolio drifted 6%") → see grounded rationale + source chips.
- **Wow:** The briefing was generated overnight from FSC + Data Cloud and logged to `AI_Agent_Run__c`. "No dashboards to build, the work comes to the advisor."
- **Value line:** "Start the day in 2 minutes, not 45."

### Scene 2 — Meeting prep in one click (4:30-7:30)
- **Screen:** D7-04 Meeting Center → D7-02 Client 360.
- **Beat:** 9:30 with the Sharma household. Click **Prep me**.
- **Action:** Advisor Agent returns a briefing: snapshot, changes since last meeting, talking points, NBAs, open items, all cited. Open Client 360 to show the grounding (members, accounts, goals, interactions, risk/consent).
- **Wow:** "Ask Agentforce" → "What changed since January?" answered conversationally with sources.
- **Value line:** "Walk into every meeting fully prepared, every time."

### Scene 3 — Fix the portfolio, explained (7:30-11:00)
- **Screen:** D7-03 Portfolio Intelligence.
- **Beat:** Drift +6%, $180K idle cash, concentration alert.
- **Action:** Portfolio Agent proposes a tax-aware rebalance + cash deployment with plain-language commentary; run a quick scenario.
- **Wow:** Performance/figures are pulled from data, never estimated; suitability-aware language; one click creates the rebalance task + `Portfolio_Alert__c`.
- **Value line:** "Institutional-grade portfolio insight for every client, not just the top 10%."

### Scene 4 — Compliant follow-up (11:00-13:30)
- **Screen:** D7-10 Proposals & Reviews → D7-07 Compliance & Risk.
- **Beat:** Generate a client-ready proposal/review pack from the meeting.
- **Action:** Advisor Agent drafts the narrative; **Run compliance check** routes language through the Compliance Agent + Trust Layer; a human-in-the-loop approval appears for the Tier-3 action.
- **Wow:** Show the Compliance console catching and explaining a flagged phrase; approve with full audit trail.
- **Value line:** "Move fast and stay compliant, automatically documented."

### Scene 5 — Grow the book (13:30-16:00)
- **Screen:** D7-05 Lead & Opportunity.
- **Beat:** Pipeline ranked by AI propensity; referral predictions surface a warm intro from the Sharma relationship.
- **Action:** Distribution Agent drafts personalized outreach; advance an opportunity.
- **Wow:** "$3.2M opportunity the advisor didn't know to ask for", found by `Referral_Prediction__c` + `Engagement_Score__c`.
- **Value line:** "Turn relationships into referrals and net new assets."

### Scene 6 — Run the firm (16:00-18:30)
- **Screen:** D7-14 Executive Dashboard → D7-12 Operations Command.
- **Beat:** COO view: AUM, net new assets, at-risk AUM, NPS, and **AI value** (hours saved, NBAs acted, conversion lift).
- **Action:** Executive Agent narrates the quarter and flags an anomaly; Operations Command shows agent runs, throughput, and exceptions with auto-remediation.
- **Wow:** AI adoption and impact are measured natively via `AI_Agent_Run__c` and health scores.
- **Value line:** "See AI's ROI in the same place you run the business."

### Scene 7 — Trust & close (18:30-20:00)
- **Screen:** D7-15 Agent Studio + Einstein Trust Layer ([D4](04-enterprise-architecture.md)).
- **Beat:** Show the seven agents, guardrails, grounding, masking, and zero-retention; every action audited.
- **Close:** "Native. Grounded. Governed. This is wealth management with an AI workforce, and it deploys as a package onto your org. Here's the 90-day path." → hand to [D11](11-implementation-roadmap.md).

## "Wow" moments (use at least 3)
1. Overnight daily briefing that prioritizes the advisor's day.
2. One-click, fully-cited meeting prep.
3. AI-found referral/opportunity with dollar value.
4. Compliance catch + human approval + automatic audit trail.
5. Executive view of AI's measurable ROI.

## Demo data setup (org: `wm-studio-org`)
- 3 hero households: **Sharma** (drift/rebalance), **Chen** (idle cash), **Okafor** (off-track 529).
- 1 prospect/referral: **Liang** family ($3.2M).
- Seeded `AI_Insight__c`, `AI_Recommendation__c`, `Advisor_Briefing__c`, `Portfolio_Alert__c`, `Meeting_Summary__c`, and `AI_Agent_Run__c` records.
- FSC: Households + members, FinancialAccounts/Goals, Interactions, `PartyProfileRisk`/`PartyConsent`.
- Assign the `Wealth_AI_Studio` permission set to the demo user.

## Logistics & fallbacks
- **Environment:** live org preferred; keep screenshots/recording of each scene as fallback.
- **Roles:** 1 driver + 1 narrator works best; solo is fine with rehearsed clicks.
- **Reset script:** re-seed demo records and clear generated artifacts between runs.
- **Risk control:** pre-generate AI outputs where latency is a concern; never demo with real client PII.

## Tailoring
- **RIA / smaller firm:** emphasize Scenes 1-3 (advisor productivity).
- **Large enterprise:** emphasize Scenes 4, 6, 7 (compliance, firm value, trust/architecture).
- **Platform/CIO audience:** extend Scene 7 with [D4](04-enterprise-architecture.md) and [D12](12-packaging-strategy.md).
