# Deliverable 9 — Workshop Package (FigJam / Miro)

A facilitator-ready discovery and alignment workshop, delivered as **importable Mermaid boards** ([diagrams/](../diagrams/)) plus this blueprint. Each board renders on GitHub and imports into FigJam, Miro, or draw.io (see [diagrams/README](../diagrams/README.md)). Use it to align stakeholders on pains, personas, capabilities, priorities, target architecture, and roadmap before/at the start of delivery ([D11](11-implementation-roadmap.md)).

## Suggested agenda (half-day)

| Time | Session | Board |
|---|---|---|
| 0:00 | Frame the day, outcomes | — |
| 0:15 | Challenges & pains | Challenge mindmap ([D1](01-industry-challenge-matrix.md)) |
| 0:45 | Personas & jobs-to-be-done | Persona map |
| 1:15 | Client journey (current vs target) | Client journey |
| 1:45 | Capability map | Capability map ([D3](03-capability-model.md)) |
| 2:15 | Prioritize use cases (value vs effort) | Prioritization quadrant ([D2](02-ai-use-case-catalog.md)) |
| 2:45 | Value stream & operating model | Value stream + Operating model |
| 3:15 | Architecture vision & trust | Architecture vision ([D4](04-enterprise-architecture.md)) |
| 3:45 | Roadmap & next steps | Roadmap timeline ([D11](11-implementation-roadmap.md)) |

## Boards

### 1. Client journey (`09-client-journey.mmd`)
```mermaid
journey
  title Wealth client journey - experience scores
  section Discover
    Research firm: 3: Prospect
    First contact: 3: Prospect, Advisor
  section Onboard
    Paperwork and KYC: 2: Client, Onboarding
    Account funding: 3: Client
  section Engage
    Annual review: 3: Client, Advisor
    Ongoing updates: 2: Client
  section Grow
    New goals: 3: Client, Advisor
    Referrals: 2: Client
  section Service
    Inquiries: 2: Client, Service
    Issue resolution: 3: Service
```

### 2. Persona map (`09-persona-map.mmd`)
```mermaid
mindmap
  root((Personas))
    Wealth Advisor
      Goals grow book and save time
      Pains prep and admin
    Portfolio Manager
      Goals performance and scale
      Pains manual commentary
    Compliance Officer
      Goals coverage and speed
      Pains sampling and audit
    Service Associate
      Goals fast resolution
      Pains context switching
    Operations Manager
      Goals throughput
      Pains exceptions
    Executive
      Goals growth and ROI
      Pains visibility
    Client
      Goals outcomes and trust
      Pains slow generic service
```

### 3. Capability map (`09-capability-map.mmd`)
```mermaid
flowchart TB
  subgraph L1[Client and Advisor]
    A1[Client Intelligence]
    A2[Advisor Enablement]
  end
  subgraph L2[Investment and Growth]
    B1[Portfolio Intelligence]
    B2[Engagement and Growth]
  end
  subgraph L3[Service and Control]
    C1[Service and Support]
    C2[Risk and Compliance]
  end
  subgraph L4[Foundation]
    D1[Automation and Orchestration]
    D2[Data and Trust]
  end
  L1 --> L2
  L2 --> L3
  L3 --> L4
```

### 4. Value stream (`09-value-stream.mmd`)
```mermaid
flowchart LR
  A[Lead or Referral] --> B[Onboard]
  B --> C[Plan goals]
  C --> D[Invest and allocate]
  D --> E[Monitor portfolio]
  E --> F[Review meetings]
  F --> G[Service]
  G --> H[Grow wallet share]
  H --> C
```

### 5. Operating model (`09-operating-model.mmd`)
```mermaid
flowchart TB
  subgraph PEOPLE[People]
    ADVP[Advisors]
    SPEC[Specialists]
    OPSP[Operations]
  end
  subgraph AIW[AI Workforce]
    AGT[Seven Agentforce agents]
  end
  subgraph PLAT[Platform]
    SF[Salesforce FSC]
    DCP[Data Cloud]
    TLP[Trust Layer]
  end
  subgraph GOVN[Governance]
    GOV[Model risk and compliance]
  end
  PEOPLE <--> AIW
  AIW --> PLAT
  PLAT --> GOVN
  GOVN --> AIW
```

### 6. Prioritization quadrant (`09-prioritization-quadrant.mmd`)
```mermaid
quadrantChart
  title Use-case prioritization - Value vs Effort
  x-axis High Effort --> Low Effort
  y-axis Low Value --> High Value
  quadrant-1 Do now
  quadrant-2 Plan
  quadrant-3 Avoid
  quadrant-4 Maybe
  Meeting Prep: [0.80, 0.90]
  Daily Briefing: [0.78, 0.85]
  Next Best Action: [0.70, 0.85]
  Compliance Surveillance: [0.40, 0.82]
  Rebalancing: [0.50, 0.80]
  Service Summaries: [0.78, 0.70]
  Referral Prediction: [0.60, 0.72]
  Onboarding KYC: [0.45, 0.68]
  Executive Insights: [0.50, 0.62]
```

### 7. Architecture vision (`09-architecture-vision.mmd`)
```mermaid
flowchart LR
  U[Advisors and Clients] --> X[Agentforce]
  X --> G[Einstein Trust Layer]
  X --> D[Data Cloud]
  D --> F[Financial Services Cloud]
  D --> E[External market and custodian data]
  X --> A[Audit and Governance]
  X --> AUTO[Flows and Automation]
```

### 8. Roadmap timeline (`09-roadmap-timeline.mmd`)
```mermaid
timeline
  title Wealth AI Studio roadmap
  section Phase 1 Crawl
    Weeks 1-12 : FSC AI data model : Advisor Agent : Advisor Home : Pilot pod
  section Phase 2 Walk
    Weeks 13-26 : Portfolio agent : Service agent : Compliance agent : Onboarding : Region rollout
  section Phase 3 Run
    Weeks 27-52 : Distribution : Operations : Executive : Autonomy with HITL : Firm-wide adoption
  section Phase 4 Optimize
    Ongoing : Model tuning : New use cases : Value realization
```

## Facilitation notes
- **Inputs:** pre-read [D0](00-executive-summary.md)-[D3](03-capability-model.md); bring real client examples (anonymized).
- **Method:** import each board into FigJam/Miro, then add sticky notes and dot-voting over the Mermaid base.
- **Outputs:** prioritized use-case shortlist, agreed personas/journey pains, target operating model, and a draft roadmap feeding [D11](11-implementation-roadmap.md).
- **Live boards:** can also be generated directly in FigJam via the Figma MCP once the tool-call limit resets.
