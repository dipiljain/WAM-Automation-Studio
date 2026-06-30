# Deliverable 2 — Prioritized AI Use Case Catalog

40 use cases across Advisor, Portfolio, Client, Distribution, Compliance, Operations, and Executive intelligence, prioritized with a weighted scoring model and organized into three delivery tiers.

*Diagrams: [impact vs feasibility quadrant](../diagrams/02-usecase-quadrant.mmd), [domain mindmap](../diagrams/02-usecase-domain-mindmap.mmd).*

## Scoring methodology

Each use case is scored **1-5** on five dimensions; the weighted sum is normalized to a **0-100 Priority Score**.

| Dimension | Weight | What it measures |
|---|---|---|
| Strategic Value | 30% | Revenue growth, AUM growth, retention, acquisition |
| Operational Value | 25% | Hours saved, productivity, automation |
| AI Readiness | 15% | Data availability, model readiness |
| Salesforce Fit | 15% | FSC, Agentforce, Data Cloud native fit |
| Demo Impact | 15% | Executive value, visualization, innovation |

`Priority Score = (Strategic*0.30 + Operational*0.25 + AIReadiness*0.15 + SFFit*0.15 + DemoImpact*0.15) * 20`

**Tiering:** Tier 1 (MVP) ≈ score ≥ 80 and high demo value; Tier 2 (Scale) ≈ 68-83; Tier 3 (Agentic Future) ≈ lower readiness today / higher autonomy.

## Master scored catalog

Scores are Strategic (St), Operational (Op), AI Readiness (Rd), Salesforce Fit (Ft), Demo (Dm), each 1-5.

| # | Use Case | Domain | Primary Persona | St | Op | Rd | Ft | Dm | Score | Tier |
|---|---|---|---|----|----|----|----|----|------|------|
| 1 | AI Advisor Briefing | Advisor | Wealth Advisor | 5 | 5 | 4 | 5 | 5 | **97** | 1 |
| 2 | Meeting Preparation Copilot | Advisor | Wealth Advisor | 5 | 5 | 4 | 5 | 5 | **97** | 1 |
| 3 | AI Follow-up Generator | Advisor | Wealth Advisor | 4 | 5 | 5 | 5 | 4 | **91** | 1 |
| 4 | Relationship Intelligence | Advisor | Wealth Advisor | 5 | 4 | 4 | 5 | 5 | **92** | 1 |
| 5 | Next Best Action Engine | Advisor | Wealth Advisor | 5 | 4 | 4 | 5 | 5 | **92** | 1 |
| 6 | Portfolio Health Analyzer | Portfolio | Portfolio Manager | 5 | 4 | 4 | 4 | 5 | **89** | 1 |
| 7 | Portfolio Review Copilot | Portfolio | Wealth Advisor | 4 | 5 | 4 | 5 | 5 | **91** | 1 |
| 8 | Portfolio Commentary Generator | Portfolio | Portfolio Manager | 4 | 5 | 5 | 5 | 5 | **94** | 1 |
| 9 | Risk Exposure Detection | Portfolio | Portfolio Manager | 5 | 4 | 4 | 4 | 4 | **86** | 1 |
| 10 | Client 360 Intelligence | Client | Wealth Advisor | 5 | 4 | 5 | 5 | 5 | **95** | 1 |
| 11 | Engagement Scoring | Client | Client Service Assoc. | 4 | 4 | 4 | 5 | 4 | **83** | 1 |
| 12 | Client Health Score | Client | Wealth Advisor | 5 | 4 | 4 | 5 | 4 | **89** | 1 |
| 13 | Lead Scoring | Distribution | Distribution Spec. | 5 | 4 | 5 | 5 | 4 | **92** | 1 |
| 14 | Lead Prioritization | Distribution | Distribution Spec. | 5 | 4 | 5 | 5 | 4 | **92** | 1 |
| 15 | Prospect Research Agent | Distribution | Distribution Spec. | 4 | 5 | 3 | 4 | 5 | **85** | 1 |
| 16 | KYC Copilot | Compliance | Compliance Officer | 4 | 5 | 4 | 4 | 5 | **88** | 1 |
| 17 | AML Screening Assistant | Compliance | Compliance Officer | 4 | 5 | 4 | 4 | 4 | **85** | 1 |
| 18 | Regulatory Monitoring Agent | Compliance | Compliance Officer | 4 | 4 | 3 | 4 | 5 | **80** | 1 |
| 19 | Onboarding Assistant | Operations | Operations Analyst | 4 | 5 | 4 | 5 | 5 | **91** | 1 |
| 20 | Document Extraction Agent | Operations | Operations Analyst | 3 | 5 | 4 | 4 | 5 | **82** | 1 |
| 21 | Workflow Automation Agent | Operations | Operations Analyst | 3 | 5 | 4 | 5 | 4 | **82** | 1 |
| 22 | Advisor Productivity Dashboard | Executive | Branch Manager | 4 | 4 | 5 | 5 | 5 | **89** | 1 |
| 23 | Revenue Intelligence Dashboard | Executive | Branch Manager | 5 | 3 | 5 | 5 | 5 | **90** | 1 |
| 24 | Proposal Copilot | Advisor | Wealth Advisor | 5 | 4 | 3 | 4 | 5 | **86** | 2 |
| 25 | Referral Intelligence | Distribution | Distribution Spec. | 4 | 3 | 3 | 4 | 4 | **72** | 2 |
| 26 | Cross-Sell Intelligence | Client | Wealth Advisor | 5 | 3 | 4 | 5 | 4 | **84** | 2 |
| 27 | Scenario Analysis Agent | Portfolio | Portfolio Manager | 4 | 4 | 3 | 3 | 5 | **77** | 2 |
| 28 | Service Resolution Copilot | Service | Client Service Assoc. | 3 | 5 | 4 | 5 | 4 | **82** | 2 |
| 29 | Predictive Attrition | Client | Wealth Advisor | 5 | 3 | 4 | 5 | 4 | **84** | 2 |
| 30 | Compliance Surveillance | Compliance | Compliance Officer | 4 | 4 | 3 | 4 | 4 | **77** | 2 |
| 31 | Reconciliation Assistant | Operations | Operations Analyst | 3 | 5 | 3 | 3 | 4 | **73** | 2 |
| 32 | Cash Movement Intelligence | Operations | Operations Analyst | 3 | 4 | 3 | 4 | 4 | **71** | 2 |
| 33 | Autonomous Advisor Agent | Advisor | Wealth Advisor | 5 | 5 | 2 | 4 | 5 | **88** | 3 |
| 34 | Autonomous Service Agent | Service | Client Service Assoc. | 4 | 5 | 3 | 5 | 5 | **88** | 3 |
| 35 | Autonomous Operations Agent | Operations | Operations Analyst | 4 | 5 | 2 | 4 | 4 | **79** | 3 |
| 36 | Autonomous Compliance Agent | Compliance | Compliance Officer | 4 | 4 | 2 | 4 | 4 | **74** | 3 |
| 37 | Autonomous Prospecting Agent | Distribution | Distribution Spec. | 4 | 4 | 2 | 4 | 4 | **74** | 3 |
| 38 | AI Branch Manager | Executive | Branch Manager | 4 | 3 | 2 | 4 | 5 | **72** | 3 |
| 39 | Autonomous Portfolio Monitoring | Portfolio | Portfolio Manager | 4 | 4 | 3 | 4 | 5 | **80** | 3 |
| 40 | Hyper-Personalized Engagement | Client | End Client | 5 | 3 | 2 | 4 | 5 | **78** | 3 |

## Tier 1 — MVP (highest ROI + demo value)

### UC-1 · AI Advisor Briefing
- **Problem Statement:** Advisors start the day without a consolidated, prioritized view of what matters across their book.
- **Business Value:** Saves 30-60 min/day; ensures no high-value client/event is missed; lifts retention.
- **Persona:** Wealth Advisor
- **Data Inputs:** Calendar, emails, portfolio moves, life events, tasks, prior interactions
- **FSC Objects:** Account, Contact, Household, Financial Account, Interaction Summary, Task, Opportunity
- **Data Cloud Dependencies:** Unified Individual profile, engagement events, market/portfolio data streams
- **Agentforce Components:** Advisor Agent topic "Daily Briefing"; actions: summarize book, rank priorities
- **AI Models:** LLM summarization + Einstein ranking; RAG grounding on FSC + Data Cloud
- **Expected ROI:** 2.5-5 hrs/advisor/week
- **Complexity:** Medium
- **Priority Score:** 97

### UC-2 · Meeting Preparation Copilot
- **Problem Statement:** Preparing for client meetings requires manual data gathering across many systems (1-3 hrs/meeting).
- **Business Value:** Cuts prep time ~80%; higher-quality, personalized meetings.
- **Persona:** Wealth Advisor
- **Data Inputs:** Client profile, goals, holdings, recent activity, prior meeting notes, market context
- **FSC Objects:** Account, Household, Financial Goal, Financial Account, Interaction Summary, Event
- **Data Cloud Dependencies:** Unified profile, interaction history, document insights
- **Agentforce Components:** Advisor Agent topic "Meeting Prep"; action: generate briefing + agenda
- **AI Models:** LLM generation (Prompt Builder template) + retrieval grounding
- **Expected ROI:** 3-6 hrs/advisor/week
- **Complexity:** Medium
- **Priority Score:** 97

### UC-3 · AI Follow-up Generator
- **Problem Statement:** Post-meeting follow-ups are delayed or skipped, stalling deals and weakening relationships.
- **Business Value:** Faster, consistent follow-up; higher close + satisfaction.
- **Persona:** Wealth Advisor
- **Data Inputs:** Meeting notes/transcript, action items, client context
- **FSC Objects:** Interaction Summary, Task, Opportunity, Contact
- **Data Cloud Dependencies:** Interaction events (optional)
- **Agentforce Components:** Advisor Agent action "Draft Follow-up"; Prompt template
- **AI Models:** LLM generation grounded in meeting summary
- **Expected ROI:** 1.5-3 hrs/advisor/week
- **Complexity:** Low
- **Priority Score:** 91

### UC-4 · Relationship Intelligence
- **Problem Statement:** Relationship context is scattered; advisors miss signals and connections across households.
- **Business Value:** Deeper relationships, fewer dropped balls, more wallet share.
- **Persona:** Wealth Advisor
- **Data Inputs:** Interactions, relationships, life events, sentiment, referrals
- **FSC Objects:** Account, Contact, Household, Relationship, Interaction Summary
- **Data Cloud Dependencies:** Unified profile, engagement + sentiment signals
- **Agentforce Components:** Advisor Agent topic "Relationship Insights"
- **AI Models:** Einstein relationship/signal detection + LLM summarization
- **Expected ROI:** 1-2 hrs/advisor/week + retention lift
- **Complexity:** Medium
- **Priority Score:** 92

### UC-5 · Next Best Action Engine
- **Problem Statement:** Advisors lack consistent, data-driven guidance on the best next action per client.
- **Business Value:** Higher conversion, wallet share, retention; consistent playbook execution.
- **Persona:** Wealth Advisor
- **Data Inputs:** Profile, goals, holdings, life events, engagement, propensity signals
- **FSC Objects:** Account, Household, Financial Goal, Opportunity, Action Plan/Care Plan
- **Data Cloud Dependencies:** Calculated insights, propensity scores, segmentation
- **Agentforce Components:** Advisor Agent action "Recommend NBA"; Einstein Next Best Action
- **AI Models:** Einstein recommendations + propensity models
- **Expected ROI:** Revenue lift + 1-2 hrs/week
- **Complexity:** Medium
- **Priority Score:** 92

### UC-6 · Portfolio Health Analyzer
- **Problem Statement:** Portfolio drift, concentration, and risk go undetected between periodic reviews.
- **Business Value:** Proactive risk management, better performance, fewer surprises.
- **Persona:** Portfolio Manager
- **Data Inputs:** Holdings, allocations, benchmarks, risk metrics, market data
- **FSC Objects:** Financial Account, Asset, Financial Holding, Financial Goal
- **Data Cloud Dependencies:** Portfolio/market data streams, calculated risk insights
- **Agentforce Components:** Portfolio Agent topic "Health Check"; Portfolio Alert generation
- **AI Models:** Anomaly/risk models + LLM explanation
- **Expected ROI:** 2-4 hrs/PM/week + risk avoidance
- **Complexity:** High
- **Priority Score:** 89

### UC-7 · Portfolio Review Copilot
- **Problem Statement:** Assembling portfolio review packs is manual and time-consuming.
- **Business Value:** Faster, consistent, higher-quality reviews.
- **Persona:** Wealth Advisor
- **Data Inputs:** Holdings, performance, goals progress, market context
- **FSC Objects:** Financial Account, Asset, Financial Goal, Interaction Summary
- **Data Cloud Dependencies:** Portfolio + performance data
- **Agentforce Components:** Portfolio Agent topic "Review Prep"; generates review pack
- **AI Models:** LLM generation + retrieval grounding
- **Expected ROI:** 2-4 hrs/advisor/week
- **Complexity:** Medium
- **Priority Score:** 91

### UC-8 · Portfolio Commentary Generator
- **Problem Statement:** Writing client-ready portfolio commentary at scale is slow and inconsistent.
- **Business Value:** Scale personalized commentary; consistency; compliance-aligned tone.
- **Persona:** Portfolio Manager
- **Data Inputs:** Performance, attribution, market events, client risk profile
- **FSC Objects:** Financial Account, Asset, Financial Goal
- **Data Cloud Dependencies:** Performance + market data
- **Agentforce Components:** Portfolio Agent action "Generate Commentary"; Prompt template
- **AI Models:** LLM generation grounded in performance data + guardrails
- **Expected ROI:** 3-5 hrs/PM/week
- **Complexity:** Medium
- **Priority Score:** 94

### UC-9 · Risk Exposure Detection
- **Problem Statement:** Concentration, suitability, and market-risk exposures surface too late.
- **Business Value:** Early risk mitigation, suitability assurance, fewer losses.
- **Persona:** Portfolio Manager
- **Data Inputs:** Holdings, risk profile, market data, exposure limits
- **FSC Objects:** Financial Account, Asset, Financial Holding
- **Data Cloud Dependencies:** Market data, calculated exposure insights
- **Agentforce Components:** Portfolio Agent topic "Risk Signals"; Risk Signal + Portfolio Alert objects
- **AI Models:** Anomaly detection + threshold/rule models + LLM explanation
- **Expected ROI:** Risk-loss avoidance + 1-2 hrs/week
- **Complexity:** High
- **Priority Score:** 86

### UC-10 · Client 360 Intelligence
- **Problem Statement:** No single, AI-summarized view of the client across relationships, goals, holdings, and engagement.
- **Business Value:** Faster context, better advice, stronger relationships.
- **Persona:** Wealth Advisor
- **Data Inputs:** All client data: profile, household, accounts, goals, interactions, cases
- **FSC Objects:** Account, Contact, Household, Financial Account, Financial Goal, Case, Interaction Summary
- **Data Cloud Dependencies:** Unified Individual + calculated insights (core dependency)
- **Agentforce Components:** Advisor Agent topic "Client 360"; summarize + Q&A grounding
- **AI Models:** RAG + LLM summarization
- **Expected ROI:** 1-3 hrs/advisor/week + experience lift
- **Complexity:** Medium
- **Priority Score:** 95

### UC-11 · Engagement Scoring
- **Problem Statement:** No unified signal of how engaged each client is across channels.
- **Business Value:** Proactive servicing; early disengagement detection.
- **Persona:** Client Service Associate
- **Data Inputs:** Email/portal/app activity, meeting cadence, response rates
- **FSC Objects:** Contact, Account, Interaction Summary, Case
- **Data Cloud Dependencies:** Engagement events, calculated engagement score
- **Agentforce Components:** Client Agent insight surfacing; Engagement Score object
- **AI Models:** Engagement scoring model (Einstein/Data Cloud CI)
- **Expected ROI:** Retention lift + targeted outreach efficiency
- **Complexity:** Medium
- **Priority Score:** 83

### UC-12 · Client Health Score
- **Problem Statement:** Advisors lack a composite indicator of relationship health/risk.
- **Business Value:** Prioritize at-risk + growth clients; reduce churn.
- **Persona:** Wealth Advisor
- **Data Inputs:** Engagement, performance, life events, sentiment, service history
- **FSC Objects:** Account, Household, Financial Account, Case, Interaction Summary
- **Data Cloud Dependencies:** Calculated insights combining engagement + portfolio + service
- **Agentforce Components:** Advisor/Client Agent surfacing; Client Health Score object
- **AI Models:** Composite scoring + Einstein prediction
- **Expected ROI:** Churn reduction (saved AUM)
- **Complexity:** Medium
- **Priority Score:** 89

### UC-13 · Lead Scoring
- **Problem Statement:** Lead scoring is inconsistent and subjective across the team.
- **Business Value:** Reps focus on best leads; higher conversion.
- **Persona:** Distribution Specialist
- **Data Inputs:** Lead source, firmographics, behavior, fit, estimated assets
- **FSC Objects:** Lead, Campaign, Contact, Account
- **Data Cloud Dependencies:** Behavioral + enrichment data
- **Agentforce Components:** Distribution Agent insight; Einstein Lead Scoring
- **AI Models:** Einstein Lead Scoring (propensity)
- **Expected ROI:** Conversion-rate lift; less wasted effort
- **Complexity:** Low
- **Priority Score:** 92

### UC-14 · Lead Prioritization
- **Problem Statement:** Reps lack a ranked, value-weighted work queue.
- **Business Value:** Maximize pipeline value per hour worked.
- **Persona:** Distribution Specialist
- **Data Inputs:** Lead score, estimated value, fit, recency
- **FSC Objects:** Lead, Opportunity, Account
- **Data Cloud Dependencies:** Propensity + value signals
- **Agentforce Components:** Distribution Agent action "Prioritized Queue"
- **AI Models:** Ranking model + Einstein scoring
- **Expected ROI:** Higher win rate; time savings
- **Complexity:** Low
- **Priority Score:** 92

### UC-15 · Prospect Research Agent
- **Problem Statement:** Researching prospects is manual and slow; data is fragmented.
- **Business Value:** Better-prepared outreach; higher engagement.
- **Persona:** Distribution Specialist
- **Data Inputs:** Public/firmographic data, news, existing CRM, enrichment
- **FSC Objects:** Lead, Account, Contact
- **Data Cloud Dependencies:** Enrichment + external research sources
- **Agentforce Components:** Distribution Agent topic "Prospect Research"; retrieval actions
- **AI Models:** LLM synthesis + RAG over research sources
- **Expected ROI:** 3-5 hrs/specialist/week
- **Complexity:** Medium
- **Priority Score:** 85

### UC-16 · KYC Copilot
- **Problem Statement:** KYC verification is manual, slow, and a compliance bottleneck.
- **Business Value:** Faster, auditable onboarding; lower risk.
- **Persona:** Compliance Officer
- **Data Inputs:** Identity docs, client data, watchlists, risk rating inputs
- **FSC Objects:** Account, Contact, Compliance/Case, Document
- **Data Cloud Dependencies:** Document insights; identity/risk data
- **Agentforce Components:** Compliance Agent topic "KYC"; Compliance Finding object
- **AI Models:** Document AI (OCR/extraction) + LLM checklist + rules
- **Expected ROI:** 3-6 hrs/case saved; faster activation
- **Complexity:** High
- **Priority Score:** 88

### UC-17 · AML Screening Assistant
- **Problem Statement:** AML/sanctions screening generates noisy alerts requiring manual triage.
- **Business Value:** Lower risk, fewer false positives, faster clearance.
- **Persona:** Compliance Officer
- **Data Inputs:** Transactions, watchlists, customer risk, prior dispositions
- **FSC Objects:** Account, Contact, Case, Compliance Finding (custom)
- **Data Cloud Dependencies:** Transaction + screening data
- **Agentforce Components:** Compliance Agent action "Triage Alert"
- **AI Models:** Classification/risk model + LLM rationale
- **Expected ROI:** Reduced manual review hours; risk reduction
- **Complexity:** High
- **Priority Score:** 85

### UC-18 · Regulatory Monitoring Agent
- **Problem Statement:** Keeping up with regulatory changes and their impact is reactive and manual.
- **Business Value:** Proactive compliance; reduced risk of breach.
- **Persona:** Compliance Officer
- **Data Inputs:** Regulatory feeds, internal policies, impacted entities
- **FSC Objects:** Case, Compliance Finding (custom), Account
- **Data Cloud Dependencies:** External regulatory feeds, knowledge base
- **Agentforce Components:** Compliance Agent topic "Reg Watch"; Knowledge grounding
- **AI Models:** RAG + LLM summarization + classification
- **Expected ROI:** Risk reduction; analyst hours saved
- **Complexity:** Medium
- **Priority Score:** 80

### UC-19 · Onboarding Assistant
- **Problem Statement:** Onboarding is slow, document-heavy, and error-prone.
- **Business Value:** Faster activation, fewer errors, better first impression.
- **Persona:** Operations Analyst
- **Data Inputs:** Client data, documents, account setup requirements, checklists
- **FSC Objects:** Account, Contact, Financial Account, Action Plan, Document, Case
- **Data Cloud Dependencies:** Document insights; profile unification
- **Agentforce Components:** Operations Agent topic "Onboarding"; Workflow Execution object; Flow orchestration
- **AI Models:** Document AI + LLM orchestration + rules
- **Expected ROI:** 4-8 hrs/onboarding saved
- **Complexity:** High
- **Priority Score:** 91

### UC-20 · Document Extraction Agent
- **Problem Statement:** Extracting structured data from client documents is manual and error-prone.
- **Business Value:** Hours saved; higher data accuracy.
- **Persona:** Operations Analyst
- **Data Inputs:** PDFs, IDs, statements, forms
- **FSC Objects:** Document, Account, Contact, Financial Account
- **Data Cloud Dependencies:** Document insights / unstructured ingestion
- **Agentforce Components:** Operations Agent action "Extract & Populate"
- **AI Models:** OCR + Document AI + LLM structuring
- **Expected ROI:** 2-5 hrs/day across ops team
- **Complexity:** Medium
- **Priority Score:** 82

### UC-21 · Workflow Automation Agent
- **Problem Statement:** Repetitive multi-system workflow steps consume ops capacity.
- **Business Value:** Throughput; fewer manual errors.
- **Persona:** Operations Analyst
- **Data Inputs:** Process definitions, case data, system states
- **FSC Objects:** Case, Action Plan, Workflow Execution (custom)
- **Data Cloud Dependencies:** Operational data (optional)
- **Agentforce Components:** Operations Agent + Flow actions; Automation Template object
- **AI Models:** LLM planning + deterministic Flow execution
- **Expected ROI:** 3-6 hrs/analyst/week
- **Complexity:** Medium
- **Priority Score:** 82

### UC-22 · Advisor Productivity Dashboard
- **Problem Statement:** Managers lack a real-time view of advisor activity and productivity.
- **Business Value:** Data-driven coaching; capacity optimization.
- **Persona:** Branch Manager
- **Data Inputs:** Activities, meetings, pipeline, AI-time-saved metrics
- **FSC Objects:** Task, Event, Opportunity, AI Agent Run (custom)
- **Data Cloud Dependencies:** Activity + usage analytics
- **Agentforce Components:** Executive Agent Q&A over analytics; CRM Analytics dashboard
- **AI Models:** Analytics + Einstein insights/narrative
- **Expected ROI:** Productivity uplift via coaching
- **Complexity:** Low
- **Priority Score:** 89

### UC-23 · Revenue Intelligence Dashboard
- **Problem Statement:** Revenue/AUM drivers and risks aren't visible in real time.
- **Business Value:** Predictable growth; faster intervention.
- **Persona:** Branch Manager
- **Data Inputs:** AUM, fees, pipeline, attrition risk, flows
- **FSC Objects:** Opportunity, Financial Account, Account
- **Data Cloud Dependencies:** Revenue + AUM data, calculated insights
- **Agentforce Components:** Executive Agent "Revenue Q&A"; CRM Analytics + Einstein Discovery
- **AI Models:** Forecasting + Einstein narrative
- **Expected ROI:** Revenue growth; better forecasting
- **Complexity:** Medium
- **Priority Score:** 90

## Tier 2 — Scale

### UC-24 · Proposal Copilot
- **Problem Statement:** Building tailored proposals is slow and inconsistent.
- **Business Value:** Faster turnaround; more proposals; higher win rate.
- **Persona:** Wealth Advisor
- **Data Inputs:** Plan, goals, model portfolios, fees, prior proposals
- **FSC Objects:** Opportunity, Financial Goal, Financial Account, Account
- **Data Cloud Dependencies:** Product/model + client data
- **Agentforce Components:** Advisor Agent action "Draft Proposal"; Prompt template + doc generation
- **AI Models:** LLM generation + retrieval; suitability rules
- **Expected ROI:** 2-4 hrs/proposal saved
- **Complexity:** High
- **Priority Score:** 86

### UC-25 · Referral Intelligence
- **Problem Statement:** Referral opportunities and COIs are under-identified and under-activated.
- **Business Value:** Organic pipeline growth.
- **Persona:** Distribution Specialist
- **Data Inputs:** Relationships, referrals history, network signals
- **FSC Objects:** Relationship, Contact, Account, Lead
- **Data Cloud Dependencies:** Relationship graph + engagement signals
- **Agentforce Components:** Distribution Agent topic "Referrals"; Referral Prediction object
- **AI Models:** Graph/propensity + LLM nudges
- **Expected ROI:** Referral pipeline uplift
- **Complexity:** Medium
- **Priority Score:** 72

### UC-26 · Cross-Sell Intelligence
- **Problem Statement:** Cross-sell/upsell moments are missed.
- **Business Value:** Higher wallet share.
- **Persona:** Wealth Advisor
- **Data Inputs:** Holdings, gaps, life events, propensity
- **FSC Objects:** Financial Account, Financial Goal, Opportunity, Household
- **Data Cloud Dependencies:** Propensity + product affinity
- **Agentforce Components:** Advisor Agent NBA "Cross-Sell"; Einstein recommendations
- **AI Models:** Product affinity/propensity + LLM framing
- **Expected ROI:** Wallet-share + revenue lift
- **Complexity:** Medium
- **Priority Score:** 84

### UC-27 · Scenario Analysis Agent
- **Problem Statement:** Modeling what-if scenarios (rebalancing, market shocks) is slow and manual.
- **Business Value:** Better decisions; faster client answers.
- **Persona:** Portfolio Manager
- **Data Inputs:** Holdings, assumptions, market scenarios, constraints
- **FSC Objects:** Financial Account, Asset, Financial Goal
- **Data Cloud Dependencies:** Market data + analytics
- **Agentforce Components:** Portfolio Agent topic "Scenarios"; calculation actions
- **AI Models:** Quant models + LLM explanation
- **Expected ROI:** Time saved; improved outcomes
- **Complexity:** High
- **Priority Score:** 77

### UC-28 · Service Resolution Copilot
- **Problem Statement:** Service resolutions are slow due to manual case research.
- **Business Value:** Lower handle time; higher CSAT.
- **Persona:** Client Service Associate
- **Data Inputs:** Case, client context, knowledge articles, prior cases
- **FSC Objects:** Case, Account, Contact, Knowledge Artifact (custom)
- **Data Cloud Dependencies:** Knowledge + interaction data
- **Agentforce Components:** Service Agent topic "Resolve"; Knowledge grounding; reply drafting
- **AI Models:** RAG + LLM drafting
- **Expected ROI:** 2-4 hrs/CSA/week; AHT reduction
- **Complexity:** Medium
- **Priority Score:** 82

### UC-29 · Predictive Attrition
- **Problem Statement:** Client attrition is detected too late to intervene.
- **Business Value:** Churn reduction; saved AUM.
- **Persona:** Wealth Advisor
- **Data Inputs:** Engagement, performance, life events, service issues
- **FSC Objects:** Account, Household, Financial Account, Case
- **Data Cloud Dependencies:** Calculated attrition features
- **Agentforce Components:** Advisor Agent alert + NBA "Retention Play"
- **AI Models:** Einstein churn prediction
- **Expected ROI:** Retained AUM (high $ impact)
- **Complexity:** Medium
- **Priority Score:** 84

### UC-30 · Compliance Surveillance
- **Problem Statement:** Surveillance of trades/communications relies on sampling, leaving gaps.
- **Business Value:** Broader coverage; risk reduction.
- **Persona:** Compliance Officer
- **Data Inputs:** Communications, trades, policies
- **FSC Objects:** Case, Compliance Finding (custom), Account
- **Data Cloud Dependencies:** Comms/trade ingestion
- **Agentforce Components:** Compliance Agent surveillance topic; anomaly flags
- **AI Models:** Anomaly/NLP classification + LLM rationale
- **Expected ROI:** Risk reduction; coverage uplift
- **Complexity:** High
- **Priority Score:** 77

### UC-31 · Reconciliation Assistant
- **Problem Statement:** Trade/position breaks require slow manual investigation.
- **Business Value:** Faster resolution; fewer breaks.
- **Persona:** Operations Analyst
- **Data Inputs:** Internal + custodian records, trade data
- **FSC Objects:** Financial Account, Asset, Case
- **Data Cloud Dependencies:** Multi-source reconciliation data
- **Agentforce Components:** Operations Agent topic "Reconcile"; match + explain actions
- **AI Models:** Matching + anomaly detection + LLM explanation
- **Expected ROI:** 3-6 hrs/analyst/week
- **Complexity:** High
- **Priority Score:** 73

### UC-32 · Cash Movement Intelligence
- **Problem Statement:** Cash/money-movement anomalies and risks are caught late.
- **Business Value:** Fewer exceptions; risk reduction.
- **Persona:** Operations Analyst
- **Data Inputs:** Transactions, patterns, limits
- **FSC Objects:** Financial Account, Case
- **Data Cloud Dependencies:** Transaction streams
- **Agentforce Components:** Operations Agent anomaly flags; Risk Signal object
- **AI Models:** Anomaly detection + rules
- **Expected ROI:** Exception reduction; risk avoidance
- **Complexity:** Medium
- **Priority Score:** 71

## Tier 3 — Agentic Future

### UC-33 · Autonomous Advisor Agent
- **Problem Statement:** Routine advisory tasks still require advisor initiation end-to-end.
- **Business Value:** Massive capacity gain; always-on relationship management.
- **Persona:** Wealth Advisor (supervisory)
- **Data Inputs:** Full client + portfolio + engagement context
- **FSC Objects:** Account, Household, Financial Account, Financial Goal, Task, Opportunity
- **Data Cloud Dependencies:** Real-time unified profile + insights
- **Agentforce Components:** Autonomous Advisor Agent with multi-topic plans + human-in-the-loop approvals
- **AI Models:** LLM planning/reasoning + tool use + guardrails
- **Expected ROI:** 5-10 hrs/advisor/week (at maturity)
- **Complexity:** Very High
- **Priority Score:** 88

### UC-34 · Autonomous Service Agent
- **Problem Statement:** Many service requests still need human handling end-to-end.
- **Business Value:** Deflection; 24/7 resolution; lower cost-to-serve.
- **Persona:** Client Service Associate (supervisory) / End Client
- **Data Inputs:** Case, knowledge, client context, entitlements
- **FSC Objects:** Case, Account, Contact, Knowledge Artifact (custom)
- **Data Cloud Dependencies:** Knowledge + interaction data
- **Agentforce Components:** Service Agent (Agentforce Service) with autonomous resolution + escalation
- **AI Models:** RAG + LLM + action execution + guardrails
- **Expected ROI:** Deflection rate; AHT elimination for routine cases
- **Complexity:** High
- **Priority Score:** 88

### UC-35 · Autonomous Operations Agent
- **Problem Statement:** Operational workflows require human orchestration across steps.
- **Business Value:** Straight-through processing; capacity gain.
- **Persona:** Operations Analyst (supervisory)
- **Data Inputs:** Process states, documents, system data
- **FSC Objects:** Case, Action Plan, Workflow Execution (custom)
- **Data Cloud Dependencies:** Operational data
- **Agentforce Components:** Operations Agent with autonomous Flow orchestration + exception handling
- **AI Models:** LLM planning + deterministic execution + anomaly detection
- **Expected ROI:** 6-10 hrs/analyst/week (at maturity)
- **Complexity:** Very High
- **Priority Score:** 79

### UC-36 · Autonomous Compliance Agent
- **Problem Statement:** Compliance monitoring + evidence assembly remains heavily manual.
- **Business Value:** Continuous compliance; audit-ready; lower risk.
- **Persona:** Compliance Officer (supervisory)
- **Data Inputs:** Comms, trades, policies, regulatory feeds
- **FSC Objects:** Case, Compliance Finding (custom), Account
- **Data Cloud Dependencies:** Comms/trade/regulatory data
- **Agentforce Components:** Compliance Agent with autonomous surveillance + finding generation
- **AI Models:** Anomaly/NLP + LLM + guardrails
- **Expected ROI:** Risk reduction; analyst capacity
- **Complexity:** Very High
- **Priority Score:** 74

### UC-37 · Autonomous Prospecting Agent
- **Problem Statement:** Prospecting requires constant manual research + outreach.
- **Business Value:** Always-on pipeline generation.
- **Persona:** Distribution Specialist (supervisory)
- **Data Inputs:** Market data, enrichment, engagement signals
- **FSC Objects:** Lead, Campaign, Contact, Account
- **Data Cloud Dependencies:** Enrichment + behavioral data
- **Agentforce Components:** Distribution Agent autonomous research + personalized outreach (with approvals)
- **AI Models:** LLM + propensity + content generation
- **Expected ROI:** Pipeline volume uplift
- **Complexity:** High
- **Priority Score:** 74

### UC-38 · AI Branch Manager
- **Problem Statement:** Branch oversight + coaching is periodic and reactive.
- **Business Value:** Continuous performance optimization; targeted coaching.
- **Persona:** Branch Manager
- **Data Inputs:** Team activity, pipeline, productivity, outcomes
- **FSC Objects:** Opportunity, Task, Event, AI Agent Run (custom)
- **Data Cloud Dependencies:** Team + performance analytics
- **Agentforce Components:** Executive Agent with coaching insights + alerts
- **AI Models:** Analytics + Einstein insights + LLM narrative
- **Expected ROI:** Team productivity + revenue uplift
- **Complexity:** High
- **Priority Score:** 72

### UC-39 · Autonomous Portfolio Monitoring
- **Problem Statement:** Continuous portfolio monitoring is impractical manually.
- **Business Value:** 24/7 drift/risk detection + proactive alerts.
- **Persona:** Portfolio Manager (supervisory)
- **Data Inputs:** Real-time holdings, market data, risk limits
- **FSC Objects:** Financial Account, Asset, Financial Holding
- **Data Cloud Dependencies:** Real-time market + portfolio streams
- **Agentforce Components:** Portfolio Agent autonomous monitor; Portfolio Alert + Risk Signal generation
- **AI Models:** Streaming anomaly detection + LLM explanation
- **Expected ROI:** Risk avoidance; PM capacity
- **Complexity:** Very High
- **Priority Score:** 80

### UC-40 · Hyper-Personalized Client Engagement
- **Problem Statement:** Client communications are generic, reducing engagement and trust.
- **Business Value:** Differentiated experience; retention + growth.
- **Persona:** End Client (advisor-supervised)
- **Data Inputs:** Profile, preferences, goals, behavior, life events
- **FSC Objects:** Account, Contact, Household, Financial Goal, Interaction Summary
- **Data Cloud Dependencies:** Unified profile + real-time signals + segmentation
- **Agentforce Components:** Client engagement orchestration across channels; Prompt templates per moment
- **AI Models:** Personalization + LLM content generation + next-best-channel
- **Expected ROI:** Engagement + retention + NPS uplift
- **Complexity:** Very High
- **Priority Score:** 78

## Tier distribution

| Tier | Use cases | Count | Avg score |
|---|---|---|---|
| Tier 1 (MVP) | UC 1-23 | 23 | ~89 |
| Tier 2 (Scale) | UC 24-32 | 9 | ~79 |
| Tier 3 (Agentic Future) | UC 33-40 | 8 | ~79 |

Use cases map into capability domains in [D3](03-capability-model.md), are realized by the agents in [D6](06-agentforce-design.md), and are sequenced in the [roadmap (D11)](11-implementation-roadmap.md).

