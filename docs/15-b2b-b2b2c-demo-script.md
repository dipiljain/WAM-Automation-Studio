# Deliverable 15 — Live B2B / B2B2C Demo Script (As-Built, In-Org)

Companion to [Deliverable 14](14-cross-persona-demo-script.md). That script proves the 40-use-case B2C book (Household/PersonAccount) end to end. This one proves the additive B2B (Institutional) and B2B2C (Partner) extension — [Deliverable 2b](02b-b2b-b2b2c-use-case-catalog.md)'s UC41-56 — runs on the **same org, same agent, same trust layer**, without touching a single B2C tab, tile, or record.

**Runtime:** ~12 minutes. **App:** Wealth AI Studio (App Launcher). **Data:** `seed_b2b_b2b2c_demo_data.apex` (2 institutional accounts, 2 partner programs with 3 participants each).

## 0. Before you start (2 min, do this off-camera)

1. Run `WAM-Studio-SF-Build/scripts/apex/seed_b2b_b2b2c_demo_data.apex` (Execute Anonymous) — it's idempotent, safe to re-run, and additive to the B2C seed script (run both if you want the full org story).
2. Assign the demo user the two new role permission sets: **WAM Role - Institutional** and **WAM Role - Partner** (alongside whatever B2C role permission sets are already assigned — they coexist without conflict).
3. Open the **Wealth AI Studio** app from the App Launcher. Confirm the nav bar now also shows **Institutional Home**, **Partner Home**, and **Institutional Mandate** — appended after the existing B2C tabs, which are all still exactly where they were.

## Cast of accounts

| Account                         | Type                                     | Role in the story                                                                                             |
| ------------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Alpine Endowment Foundation** | Institutional (Business, no children)    | Carries a mandate **breach** and a high-severity concentration signal — the "hero" institutional account.     |
| **Meridian Pension Trust**      | Institutional (Business, no children)    | Compliant mandate, open KYB finding, an open $2.5M proposal — the "healthy but active" contrast account.      |
| **Horizon Retirement Platform** | Partner (Business, 3 Household children) | Contains **Chen Retirement Participant** (health score 42, at-risk) — the white-label enablement moment.      |
| **Summit Advisory Network**     | Partner (Business, 3 Household children) | Contains **Alvarez Advisory Client** (health score 38, escalated KYC finding) — the compliance rollup moment. |

## Timing overview (~12:00)

| Act                                       | Time        | Persona             | Tab / Component                                           | Use cases           |
| ----------------------------------------- | ----------- | ------------------- | --------------------------------------------------------- | ------------------- |
| 0. Bridge from B2C                        | 0:00–1:00   | —                   | Home → app nav bar                                        | —                   |
| I. The institutional relationship manager | 1:00–5:30   | Institutional RM    | Institutional Home → Institutional Relationship Workbench | UC41-44, UC47-48    |
| II. The partner program manager           | 5:30–10:00  | Partner Program Mgr | Partner Home → Partner Command Center                     | UC49-51, UC53, UC56 |
| III. One agent, three business models     | 10:00–12:00 | —                   | Wealth Advisor Agent (utility bar / Agentforce)           | Agent extension     |

---

## Act 0 — Bridge from B2C (1:00)

**Screen:** Home tab, then the app nav bar.

1. **Line:** "Everything you just saw was Household and Person Accounts — direct retail relationships. Institutional pension funds and white-label partner platforms are a completely different shape of relationship, but they should live in the exact same app, on the exact same trust layer. Watch what changes — and just as importantly, what doesn't."
2. Point at the nav bar: every B2C tab (Advisor Home, Compliance Home, Executive Home, Advisor Briefing, etc.) is untouched. Two new tabs — **Institutional Home** and **Partner Home** — are simply appended.
3. **Line:** "No B2C use case, no existing Apex class, no existing component was modified to add this. It's a pure extension."

## Act I — The institutional relationship manager (4:30) — _Alpine Endowment Foundation_

**Screen:** Institutional Home tab → Institutional Relationship Workbench.

1. Click the **Institutional Home** tab.
2. Use the **Institutional Account** picklist to select **Alpine Endowment Foundation**. _(Notice the picklist only lists Business accounts with no children — Households and Partner programs never show up here.)_
3. Call out the metric tiles: **Mandate Breaches: 1**, **Risk Signals** non-zero. _"This endowment already has an Investment Policy Statement breach on file before we click anything — the mandate data is real, seeded, and live."_
4. Click **Run Mandate Compliance Check**. Watch a new `Institutional_Mandate__c` compliance check run live and the action summary panel report the fresh status.
5. Click **Run Institutional Risk Surveillance** and then **Run Institutional Liquidity Forecast** — two new `Risk_Signal__c` records (Concentration, Cash Movement) appear.
6. Switch the account selector to **Meridian Pension Trust**. Click **Run Institutional Proposal Copilot** — a new **High**-priority, **$2.5M** proposal `AI_Recommendation__c` is created live. Call out the dollar figure explicitly.
7. Click **Generate Committee Report** — a new `Advisor_Briefing__c` is created, summarizing mandates, breaches, proposals, and findings in one paragraph, ready for the investment committee.
8. Click **Run Autonomous Institutional Monitoring** — a new `AI_Agent_Run__c` is created with `Autonomous_Mode__c = true` and `HITL_Status__c = Pending`, plus an escalated risk signal awaiting RM sign-off. _"Same human-in-the-loop governance pattern you saw in the B2C autonomy tower — autonomy never means unsupervised, no matter the business model."_
9. Scroll to **Key Stakeholders** and click **Open record** on one. _"Same 'open record' pattern as B2C — this takes you to the account, not to internal plumbing."_

**Value line:** "Mandate compliance, committee reporting, and autonomous surveillance for a pension fund — running on the same score engine, the same HITL gate, and the same Apex service pattern as the advisor's morning briefing you saw a few minutes ago."

## Act II — The partner program manager (4:30) — _Horizon Retirement Platform_

**Screen:** Partner Home tab → Partner Command Center.

1. Click the **Partner Home** tab.
2. The **Partner Program** picklist defaults to **Horizon Retirement Platform**. _(This picklist only lists Business accounts that have Household children — the institutional accounts from Act I never show up here.)_
3. Call out the metric tiles: **Participant Households: 3**, **At-Risk Participants: 1**. _"One of this platform's three retirement plan participants is already flagged at-risk, rolled up automatically from their individual health scores."_
4. Scroll to **At-Risk Participants** and see **Chen Retirement Participant** listed with health score 42.
5. In the **White-Label Advisor Enablement** panel, select **Chen Retirement Participant** from the participant picklist and click **Run White-Label Advisor Action**. _"This didn't write new advisor logic — it just validated that Chen belongs to Horizon's program, then called the exact same Next Best Action engine the advisor used in Act I of the B2C demo. One intelligence layer, two front doors."_ Watch the resulting recommendation appear in the action summary.
6. Click **Run Cross-Program Referral** — a new `Referral_Prediction__c` is created for the platform.
7. Click **Run Autonomous Partner Growth Agent** — a new autonomous `AI_Agent_Run__c` (Pending HITL) plus a fresh referral opportunity are created live.
8. Switch to **Summit Advisory Network** and scroll to **Participant Compliance Rollup** — see the escalated KYC finding for **Alvarez Advisory Client** rolled up automatically without opening a single participant record.

**Value line:** "A partner program manager gets the same at-risk detection, referral intelligence, and compliance rollup a wealth firm gets internally — and when they need advisor-grade action, they're one click away from the same engine, white-labeled under their own program."

## Act III — One agent, three business models (2:00)

**Screen:** Wealth Advisor Agent (Agentforce utility item, or Agent Builder preview).

1. **Line:** "One agent — not three, not seven — now understands B2C households, institutional mandates, and partner rollups. Two new specialist subagents were added, and nothing about the advisor, compliance, or executive subagents changed."
2. If the agent is embedded/activated in this org, open it and ask: _"Give me a mandate compliance briefing for Alpine Endowment Foundation."_ Point out the response is grounded on the same `Institutional_Mandate__c` data just created, via the `institutional_relationship` subagent.
3. Ask: _"What's the growth outlook for Horizon Retirement Platform?"_ and point out the `partner_rollup` subagent grounds its answer on the live participant rollup from Act II.

**Value line:** "Every business model — direct retail, institutional, and white-label partner — is one conversation away from the same governed, grounded AI agent."

---

## Close (20 sec)

"In twelve minutes, the same app, the same agent, and the same score engine that ran the entire B2C book just ran a pension fund's mandate compliance and a retirement platform's participant rollup — with zero duplicated logic and zero changes to a single existing use case. That's what an additive AI platform looks like."
