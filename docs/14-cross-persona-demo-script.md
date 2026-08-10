# Deliverable 14 — Live Cross-Persona Demo Script (As-Built, In-Org)

D10 ([demo storyline](10-demo-storyline.md)) sold the vision against Figma screens. This script is different on purpose: every click, button label, tab name, and number below exists **today** in the deployed Wealth AI Studio org, running on real seeded data. Use this when you want to hand someone a laptop and let them believe it.

**Runtime:** ~22 minutes. **App:** Wealth AI Studio (App Launcher). **Data:** `seed_10_accounts_uc1_uc40.apex` (10 households, UC1-40 pre-loaded against the flagship household).

## 0. Before you start (2 min, do this off-camera)

1. Run `WAM-Studio-SF-Build/scripts/apex/seed_10_accounts_uc1_uc40.apex` (Execute Anonymous) if the org hasn't been seeded recently — it's idempotent, safe to re-run.
2. Assign the demo user all three role permission sets so every persona surface lights up in one login: **Wealth AI Studio** (base), **WAM Role Advisor**, **WAM Role Compliance**, **WAM Role Executive**. (In a real rollout, a user gets only the one role that matches their job.)
3. Open the **Wealth AI Studio** app from the App Launcher. Confirm the nav bar shows: Home, Advisor Home, Compliance Home, Executive Home, plus the object tabs (Account, AI Recommendation, AI Insight, AI Agent Run, etc.).

## Cast of accounts

The seed script creates 10 households with linearly increasing Engagement/Health scores, so the story arc is built into the data itself — no fudging required.

| Account                                 | Engagement | Health | Role in the story                                                                                                                         |
| --------------------------------------- | ---------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **Sharma Family Office**                | 48         | 42     | Flagship household — carries the full UC1-40 run history, including 4 pending autonomous approvals. The "hero" account for Acts I and VI. |
| **Rao Global Family Trust**             | 58         | 52     | Health below the 65 "growth opportunity" threshold — Act III's $350K proposal moment.                                                     |
| **Patel Legacy Partners**               | 53         | 47     | Second household with its own AI-generated recommendation, finding, and alert — proves this isn't a one-account demo.                     |
| **Desai Premier Advisory**              | 93         | 87     | Healthiest household in the book — used in Act V to show AI value scales even for top-tier clients.                                       |
| Singh, Mehta, Kapoor, Iyer, Verma, Nair | 63–88      | 57–82  | Fill out the book for firm-wide tiles in Act V (avg client health, pipeline value, agent adoption).                                       |

## Timing overview (~22:00)

| Act                                        | Time        | Persona                         | Tab / Component                                                  | Use cases              |
| ------------------------------------------ | ----------- | ------------------------------- | ---------------------------------------------------------------- | ---------------------- |
| 0. Cold open                               | 0:00–1:30   | —                               | Home                                                             | —                      |
| I. The advisor's morning                   | 1:30–6:30   | Advisor                         | Advisor Home → Advisor Action Center                             | UC1, UC4, UC5, UC11-12 |
| II. Portfolio Manager catches risk         | 6:30–10:00  | Portfolio Manager               | Home → Portfolio Copilot                                         | UC6, UC9               |
| III. Growing the book                      | 10:00–13:30 | Advisor                         | Advisor Home → Growth & Service Command Center                   | UC24, UC25             |
| IV. One workbench, three back-office roles | 13:30–17:30 | Distribution / Compliance / Ops | Compliance Home → Distribution, Compliance, Operations Workbench | UC13, UC16, UC19       |
| V. The executive pulse                     | 17:30–19:30 | Branch Manager / Executive      | Executive Home                                                   | UC22-23                |
| VI. Autonomy with a human in the loop      | 19:30–22:00 | Executive / Compliance          | Executive Home → Autonomy Control Tower → AI Agent Run record    | UC33, UC36-37, UC40    |

---

## Act 0 — Cold open (1:30)

**Screen:** Home tab.

1. Land on **Home**. Scroll slowly past all three persona cards stacked on the left: **Advisor Cockpit**, **Compliance Command Center**, **Executive Pulse** — each already populated with live tiles (e.g. _High-Priority Recommendations_, _Open Findings_, _AI Pipeline Value_).
2. **Line:** "One login, one app. Every role's AI cockpit is on this same screen — nobody built a dashboard, nobody wrote a report. This is native Salesforce, Apex, and Lightning Web Components, running against real Financial Services Cloud data."
3. **Line:** "Let's walk it the way a firm actually runs — starting with the advisor's morning."

## Act I — The advisor's morning (5:00) — _Sharma Family Office_

**Screen:** Advisor Home tab → Advisor Action Center.

1. Click the **Advisor Home** tab.
2. Point at the **Advisor Cockpit** card at the top — _High-Priority Recommendations_, _New AI Insights_, _Briefings Today_, _At-Risk Clients_ — plus the **Top Recommendations** and **Latest Insights** lists below it.
3. In **Advisor Action Center**, use the **Client / Household** picklist to select **Sharma Family Office**.
4. Call out the metric tiles: **Client Health Score 42**, **Engagement Score 48**. _"This household is at risk before we've clicked a single button — the AI already knows."_
5. Click **Generate Advisor Briefing**. Watch the action summary panel populate with the generated title, detail, and priority. A new `Advisor_Briefing__c` and `AI_Insight__c` were just created and logged against an `AI_Agent_Run__c`.
6. Click **Generate Relationship Insight** — a fresh insight referencing the household's open recommendations and findings appears instantly.
7. Click **Generate Next Best Action** — a new `AI_Recommendation__c` is created with a priority computed live from the account's score.
8. Click **Refresh Scores** and watch the **Client Health Score** / **Engagement Score** tiles recompute in place — the score engine rewards new insights and penalizes open findings/alerts, live, on screen.
9. Open the new recommendation from the **Top Recommendations** list and click **Open record**. _"Notice this doesn't open the recommendation record — it takes the advisor straight to the Sharma Family Office account. The insight is a means to an end; the client is the destination."_

**Value line:** "45 minutes of prep, scoring, and briefing writing — done in under a minute, and every link lands you on the client, not on internal AI plumbing."

## Act II — Portfolio Manager catches risk (3:30) — _Rao Global Family Trust_

**Screen:** Home tab → Portfolio Copilot.

1. Scroll the **Home** tab down to **Portfolio Copilot**.
2. Select **Rao Global Family Trust**. _(Portfolio Manager doesn't have a dedicated app tab yet — the persona's workspace lives here today; that's a natural roadmap callout, not a gap in the demo.)_
3. Note the tiles: **Client Health 52**, **Open Portfolio Alerts**, **Open Risk Signals**. Health is already below the 65 threshold we'll exploit in Act III.
4. Click **Run Portfolio Health Analyzer** — a new `Portfolio_Alert__c` appears in **Latest Portfolio Alerts**.
5. Click **Detect Risk Exposure** — a new `Risk_Signal__c` appears in **Latest Risk Signals**.
6. Click **Open record** on the new alert. _"Same pattern — straight to Rao Global Family Trust's account, not the alert."_

**Value line:** "The same platform, same trust layer, same one-click pattern — whether you're watching relationship health or portfolio drift."

## Act III — Growing the book (3:30) — _Rao Global Family Trust_

**Screen:** Advisor Home tab → Growth and Service Command Center (also present on Home and Executive Home).

1. Set the **Client / Household** selector to **Rao Global Family Trust** again.
2. Click **Run Proposal Copilot**. Because Rao's health score (52) is below the engine's 65-point threshold, the copilot returns a **High**-priority proposal recommendation with an **expected value of $350,000** — call this number out explicitly.
3. Click **Run Referral Intelligence** to show the growth queue picking up a second, independent opportunity signal for the same household.
4. Glance at the **Growth Queue** list updating live with both new items.

**Value line:** "The AI didn't just flag a problem in Act II — it turned the same at-risk signal into a $350,000 proposal opportunity, automatically prioritized, in the same command center."

## Act IV — One workbench, three back-office roles (4:00) — _Patel Legacy Partners_

**Screen:** Compliance Home tab → Distribution, Compliance, Operations Workbench.

1. Click the **Compliance Home** tab.
2. Select **Patel Legacy Partners** in the workbench's Client/Household selector.
3. **Distribution:** click **Run Lead Scoring** — watch the **Distribution Queue** pick up a new item.
4. **Compliance:** click **Run KYC Copilot** — watch the **Compliance Queue** pick up a new finding-linked item.
5. **Operations:** click **Run Onboarding Assistant** — watch the **Operations Queue** pick up a workflow item.
6. **Line:** "Three different back-office roles — Distribution, Compliance, Operations — one workbench, one screen, zero swivel-chairing between systems."
7. Scroll down to the **Autonomy Control Tower** on the same page and point out its tiles (**Autonomous Runs**, **Pending Approvals**, **Escalated Runs**) already showing non-zero counts — a preview of Act VI.

**Value line:** "This is the back office that used to need three different tools and three different logins, consolidated into one AI-assisted workbench."

## Act V — The executive pulse (2:00) — _firm-wide_

**Screen:** Executive Home tab.

1. Click the **Executive Home** tab.
2. Point at the **Executive Pulse** card: **AI Pipeline Value** (sum of every open recommendation's expected value — including the $350K we just created for Rao), **Agent Runs (Success)**, **Avg Client Health** (blended across all 10 households, including Desai's 87), **Open Compliance Findings**.
3. Scroll to the **Growth and Service Command Center** repeated here — same component, same data, framed for a leader instead of an operator.

**Value line:** "Every action an advisor, portfolio manager, or compliance officer took in the last twenty minutes just rolled straight into this number, live, with no end-of-month reporting cycle."

## Act VI — Autonomy with a human in the loop (2:30) — _Sharma Family Office_

**Screen:** Executive Home (or Compliance Home) → Autonomy Control Tower → AI Agent Run record.

1. Select **Sharma Family Office** in the Autonomy Control Tower.
2. Note the **Pending Approvals** tile is already non-zero — the seed data includes four autonomous runs awaiting sign-off (Autonomous Advisor, Autonomous Compliance, Autonomous Prospecting, Hyper-Personalized Engagement).
3. Click **Run Autonomous Advisor**. A brand-new `AI_Agent_Run__c` is created live with `Autonomous_Mode__c = true` and `HITL_Status__c = Pending`, and the **Pending Approvals** tile increments in front of the audience.
4. Open that run from the **Autonomy Run Queue** list (or the **AI Agent Run** tab). On the record page — using the layout we just expanded to surface every field — show **HITL Status: Pending**, **Persona: Advisor**, **Autonomous Mode: checked**, and the full **Plan Summary** text the agent generated.
5. Edit **HITL Status** from **Pending** to **Approved** right on the record. _"That's the entire governance loop: the agent proposes, a human approves, and the audit trail is a standard Salesforce field history — no separate compliance tool required."_

**Value line:** "Autonomy doesn't mean unsupervised. Every self-directed run stops at a real approval gate, on a real record, before it touches a client."

---

## Close (30 sec)

"In twenty minutes you watched an advisor, a portfolio manager, three back-office specialists, a branch executive, and a compliance approver all work off the same accounts, the same AI runs, and the same trust layer — no swivel-chair, no separate reporting, and every autonomous action gated by a human. That's Wealth AI Studio."
