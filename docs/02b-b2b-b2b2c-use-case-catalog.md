# Deliverable 2b — B2B / B2B2C Use Case Catalog (UC41-56)

Additive extension to [Deliverable 2](02-ai-use-case-catalog.md)'s 40 B2C use cases. UC41-48 serve **Institutional Relationship Managers** (B2B — pension funds, endowments, foundations); UC49-56 serve **Partner Program Managers** (B2B2C — retirement platforms and advisory networks that white-label services to their own participant base). Zero existing B2C use cases, objects, or Apex services were modified to build this catalog — see [Deliverable 14](14-cross-persona-demo-script.md) for the untouched B2C script.

## Segmentation model

Wealth AI Studio already ships two unused Financial Services Cloud primitives that this extension activates:

- **`Account.RecordType`** — `Household` / `PersonAccount` (B2C, unchanged) vs. **`Business`** (new B2B/B2B2C surface).
- **`Account.ParentId`** — a `Business` account with **no children** is an **Institutional** account; a `Business` account **with Household children** is a **Partner** program, and its children are **Participants**.

No new fields were added to `Account`. All existing B2C account pickers (`WealthAIAdvisorUseCaseService.getAccountOptions`, etc.) now filter to `Household`/`PersonAccount` only, so Business accounts never leak into advisor/portfolio/compliance workbenches, and vice versa.

## Scoring methodology

Same weighted model as Deliverable 2 (`Priority Score = (St*0.30 + Op*0.25 + Rd*0.15 + Ft*0.15 + Dm*0.15) * 20`).

| #   | Use Case                                    | Domain        | Primary Persona     | St  | Op  | Rd  | Ft  | Dm  | Score  | Tier |
| --- | ------------------------------------------- | ------------- | ------------------- | --- | --- | --- | --- | --- | ------ | ---- |
| 41  | Institutional Account 360                   | Institutional | Institutional RM    | 5   | 4   | 5   | 5   | 4   | **92** | 2    |
| 42  | Institutional Stakeholder Intelligence      | Institutional | Institutional RM    | 4   | 3   | 4   | 5   | 4   | **80** | 2    |
| 43  | Mandate Compliance Copilot                  | Institutional | Institutional RM    | 5   | 4   | 4   | 5   | 4   | **88** | 2    |
| 44  | Institutional Proposal Copilot              | Institutional | Institutional RM    | 5   | 4   | 3   | 4   | 5   | **86** | 2    |
| 45  | Investment Committee Reporting              | Institutional | Institutional RM    | 4   | 5   | 4   | 4   | 4   | **83** | 2    |
| 46  | Institutional KYB Onboarding                | Institutional | Institutional RM    | 4   | 5   | 4   | 4   | 3   | **80** | 2    |
| 47  | Institutional Risk & Liquidity Surveillance | Institutional | Institutional RM    | 4   | 4   | 3   | 4   | 4   | **77** | 2    |
| 48  | Autonomous Institutional Monitoring         | Institutional | Institutional RM    | 4   | 4   | 2   | 4   | 5   | **77** | 3    |
| 49  | Partner Program Rollup                      | Partner       | Partner Program Mgr | 5   | 4   | 5   | 5   | 5   | **95** | 2    |
| 50  | At-Risk Participant Detection               | Partner       | Partner Program Mgr | 5   | 4   | 5   | 5   | 4   | **92** | 2    |
| 51  | White-Label Advisor Enablement              | Partner       | Partner Program Mgr | 5   | 4   | 4   | 5   | 5   | **90** | 2    |
| 52  | Partner Onboarding Batch Automation         | Partner       | Partner Program Mgr | 4   | 5   | 4   | 4   | 3   | **81** | 2    |
| 53  | Cross-Program Referral Intelligence         | Partner       | Partner Program Mgr | 4   | 3   | 4   | 4   | 4   | **77** | 2    |
| 54  | Participant Engagement Campaigns            | Partner       | Partner Program Mgr | 5   | 3   | 3   | 4   | 4   | **80** | 2    |
| 55  | Partner Compliance Rollup                   | Partner       | Partner Program Mgr | 4   | 4   | 4   | 4   | 3   | **78** | 2    |
| 56  | Autonomous Partner Growth Agent             | Partner       | Partner Program Mgr | 4   | 4   | 2   | 4   | 5   | **77** | 3    |

## Institutional (B2B) — UC41-48

### UC-41 · Institutional Account 360

- **Problem Statement:** Institutional RMs need one screen that rolls up mandates, breaches, proposals, findings, risk signals, and workflows for a pension/endowment relationship instead of five separate object tabs.
- **Persona:** Institutional Relationship Manager
- **FSC/Data Model:** `Account` (Business RecordType, no children), `Institutional_Mandate__c`, `AI_Recommendation__c`, `Compliance_Finding__c`, `Risk_Signal__c`, `Workflow_Execution__c`
- **Built as:** `WealthAIInstitutionalUseCaseService.getInstitutionalSnapshot` → `institutionalRelationshipWorkbench` LWC metric tiles; also grounds the agent via `WealthAIInstitutionalDataProvider` → `Institutional_Mandate_Briefing` prompt template.
- **Priority Score:** 92 (Tier 2)

### UC-42 · Institutional Stakeholder Intelligence

- **Problem Statement:** Institutional relationships span multiple signatories, trustees, and committee members; RMs need a quick view of who's active and in what role.
- **Persona:** Institutional Relationship Manager
- **FSC/Data Model:** `AccountContactRelation`, `Contact`
- **Built as:** `WealthAIInstitutionalUseCaseService.getInstitutionalStakeholders` → stakeholder list on the workbench (reuses `wamInsightList`, so "Open record" jumps straight to the stakeholder's account).
- **Priority Score:** 80 (Tier 2)

### UC-43 · Mandate Compliance Copilot

- **Problem Statement:** Investment Policy Statement (IPS) compliance checks are manual and reactive; breaches surface too late.
- **Persona:** Institutional Relationship Manager
- **FSC/Data Model:** `Institutional_Mandate__c` (new object), `Risk_Signal__c`, `AI_Agent_Run__c`
- **Built as:** `WealthAIInstitutionalUseCaseService.runMandateComplianceCheck` — creates/updates an `Institutional_Mandate__c` with a live `Compliant`/`Breach` status derived from open high/critical risk signals. Wired into the Wealth Advisor Agent's new `institutional_relationship` subagent as `run_mandate_compliance_check` (`WealthAIRunMandateComplianceAction`).
- **Priority Score:** 88 (Tier 2)

### UC-44 · Institutional Proposal Copilot

- **Problem Statement:** Drafting mandate-aligned institutional proposals (allocation, fee structure) is slow and inconsistent across RMs.
- **Persona:** Institutional Relationship Manager
- **FSC/Data Model:** `AI_Recommendation__c` (`Recommendation_Type__c = 'Proposal'`)
- **Built as:** `WealthAIInstitutionalUseCaseService.runInstitutionalProposalCopilot`.
- **Priority Score:** 86 (Tier 2)

### UC-45 · Investment Committee Reporting

- **Problem Statement:** Preparing committee-ready summaries of mandate health is a manual document-assembly exercise every quarter.
- **Persona:** Institutional Relationship Manager
- **FSC/Data Model:** `Advisor_Briefing__c` (reused object, new persona context)
- **Built as:** `WealthAIInstitutionalUseCaseService.generateCommitteeReport` — assembles the UC-41 snapshot into a briefing record with priority set from breach count.
- **Priority Score:** 83 (Tier 2)

### UC-46 · Institutional KYB Onboarding

- **Problem Statement:** Know-Your-Business documentation review for new institutional clients is a manual compliance checklist.
- **Persona:** Institutional Relationship Manager
- **FSC/Data Model:** `Compliance_Finding__c` (`Finding_Type__c = 'KYC'`, reused picklist value)
- **Built as:** `WealthAIInstitutionalUseCaseService.runInstitutionalKYBOnboarding`.
- **Priority Score:** 80 (Tier 2)

### UC-47 · Institutional Risk & Liquidity Surveillance

- **Problem Statement:** Concentration risk and liquidity/cash-flow forecasting for large mandates need continuous monitoring, not point-in-time review.
- **Persona:** Institutional Relationship Manager
- **FSC/Data Model:** `Risk_Signal__c` (`Signal_Type__c` = `Concentration` / `Cash Movement`, both reused picklist values)
- **Built as:** `WealthAIInstitutionalUseCaseService.runInstitutionalRiskSurveillance` + `runInstitutionalLiquidityForecast`.
- **Priority Score:** 77 (Tier 2)

### UC-48 · Autonomous Institutional Monitoring

- **Problem Statement:** RMs can't watch every mandate every day; autonomous monitoring with human sign-off closes the gap without removing oversight.
- **Persona:** Institutional Relationship Manager (approver)
- **FSC/Data Model:** `AI_Agent_Run__c` (`Autonomous_Mode__c = true`, `HITL_Status__c = 'Pending'`), `Risk_Signal__c`
- **Built as:** `WealthAIInstitutionalUseCaseService.runAutonomousInstitutionalMonitoring` — same HITL escalation pattern as the existing B2C autonomous use cases (UC33-40).
- **Priority Score:** 77 (Tier 3)

## Partner (B2B2C) — UC49-56

### UC-49 · Partner Program Rollup

- **Problem Statement:** Partner program managers running white-label platforms need one screen summarizing participant count, at-risk participants, referrals, workflows, and compliance findings across their entire book.
- **Persona:** Partner Program Manager
- **FSC/Data Model:** `Account` (Business with Household children = participants), `Referral_Prediction__c`, `Workflow_Execution__c`, `Compliance_Finding__c`
- **Built as:** `WealthAIPartnerUseCaseService.getPartnerRollupSnapshot` → `partnerCommandCenter` LWC metric tiles; also grounds the agent via `WealthAIPartnerRollupDataProvider` → `Partner_Rollup_Briefing` prompt template.
- **Priority Score:** 95 (Tier 2)

### UC-50 · At-Risk Participant Detection

- **Problem Statement:** Individual participant health scores are buried across dozens of household records; program managers need them surfaced and ranked.
- **Persona:** Partner Program Manager
- **FSC/Data Model:** `Client_Health_Score__c` (reused, filtered to score < 60 across participant children)
- **Built as:** `WealthAIPartnerUseCaseService.getAtRiskParticipants` → participant list on the command center (reuses `wamInsightList` for "Open record" navigation to the participant's account).
- **Priority Score:** 92 (Tier 2)

### UC-51 · White-Label Advisor Enablement

- **Problem Statement:** Partner programs need to trigger the same advisor-grade Next Best Action intelligence for a specific participant, under the partner's own brand, without duplicating advisor logic.
- **Persona:** Partner Program Manager
- **FSC/Data Model:** delegates to existing B2C `AI_Recommendation__c` pipeline
- **Built as:** `WealthAIPartnerUseCaseService.runWhiteLabelAdvisorAction` — validates the participant belongs to the partner (`ParentId` check), then **delegates to the existing, unmodified `WealthAIAdvisorUseCaseService.generateNextBestAction`**. This is the clearest proof point that B2C and B2B2C share one intelligence layer without code duplication.
- **Priority Score:** 90 (Tier 2)

### UC-52 · Partner Onboarding Batch Automation

- **Problem Statement:** Bulk-onboarding a new cohort of participant accounts into a partner program is a manual, error-prone workflow today.
- **Persona:** Partner Program Manager
- **FSC/Data Model:** `Workflow_Execution__c`, `Automation_Template__c` (reused `Onboarding` category)
- **Built as:** `WealthAIPartnerUseCaseService.runPartnerOnboardingBatch`.
- **Priority Score:** 81 (Tier 2)

### UC-53 · Cross-Program Referral Intelligence

- **Problem Statement:** Referral opportunities that span a partner's participant base go undetected without a program-level view.
- **Persona:** Partner Program Manager
- **FSC/Data Model:** `Referral_Prediction__c`
- **Built as:** `WealthAIPartnerUseCaseService.runCrossProgramReferral` — reuses `WamScoreEngine` scoring/priority logic from the B2C growth use cases.
- **Priority Score:** 77 (Tier 2)

### UC-54 · Participant Engagement Campaigns

- **Problem Statement:** At-risk participants (UC-50) need a coordinated outreach response, not just a flag.
- **Persona:** Partner Program Manager
- **FSC/Data Model:** `AI_Recommendation__c` (`Recommendation_Type__c = 'Outreach'`)
- **Built as:** `WealthAIPartnerUseCaseService.runParticipantEngagementCampaign` — sizes the campaign from the live UC-50 at-risk count.
- **Priority Score:** 80 (Tier 2)

### UC-55 · Partner Compliance Rollup

- **Problem Statement:** Compliance findings across dozens of participant accounts need a program-level rollup, not fifty individual record checks.
- **Persona:** Partner Program Manager
- **FSC/Data Model:** `Compliance_Finding__c` (rolled up across all participant children)
- **Built as:** `WealthAIPartnerUseCaseService.getPartnerComplianceRollup` → compliance list on the command center.
- **Priority Score:** 78 (Tier 2)

### UC-56 · Autonomous Partner Growth Agent

- **Problem Statement:** Identifying program-level growth opportunities across an entire participant base is beyond what a program manager can do manually every day.
- **Persona:** Partner Program Manager (approver)
- **FSC/Data Model:** `AI_Agent_Run__c` (`Autonomous_Mode__c = true`, `HITL_Status__c = 'Pending'`), `Referral_Prediction__c`
- **Built as:** `WealthAIPartnerUseCaseService.runAutonomousPartnerGrowthAgent` — same HITL escalation pattern as UC-48 and the B2C autonomous tier.
- **Priority Score:** 77 (Tier 3)

## Agentforce extension

The single `Wealth_Advisor_Agent` gained two new subagents rather than a second agent, per the [agent architecture decision](06-agentforce-design.md):

| Subagent                     | Grounded action                                                                            | Apex-backed action                                                    |
| ---------------------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------- |
| `institutional_relationship` | `Institutional_Mandate_Briefing` prompt (grounded via `WealthAIInstitutionalDataProvider`) | `run_mandate_compliance_check` → `WealthAIRunMandateComplianceAction` |
| `partner_rollup`             | `Partner_Rollup_Briefing` prompt (grounded via `WealthAIPartnerRollupDataProvider`)        | `run_partner_growth_agent` → `WealthAIRunPartnerGrowthAction`         |

## What stayed untouched

- All 40 B2C use cases, 6 existing Apex services, and 13 existing LWCs — zero modifications beyond the additive `RecordType` filter on shared account pickers.
- `Household`/`PersonAccount` accounts never appear in the Institutional or Partner pickers; `Business` accounts never appear in the Advisor/Portfolio/Compliance/Executive pickers.
