# Salesforce Wealth AI Studio

An enterprise-grade, portable, **FSC-native / Agentforce-ready / Data Cloud-enabled** AI accelerator for Wealth & Asset Management (WAM) firms. Built on standard Salesforce + Financial Services Cloud capabilities to minimize custom development and enable distribution as a managed/unlocked package.

> Target outcome: **return 10-15 hours per week** to advisors and operations teams through AI-driven automation, while accelerating client acquisition, servicing, portfolio management, compliance, and distribution.

## What this accelerator is for

| Use | Fit |
|---|---|
| Salesforce Accelerators | Reusable, portable assets |
| Industry Demonstrations | 20-minute executive demo storyline (D10) |
| Client Workshops | Live FigJam boards (D9) |
| Proof of Concepts | Deployable SFDX skeleton (`/sfdx`) |
| Production Deployments | FSC-native, governance-first design |
| Managed Package Distribution | Packaging strategy (D12) |

## Deliverables

| # | Deliverable | Document | Status |
|---|---|---|---|
| 0 | Executive Summary | [docs/00-executive-summary.md](docs/00-executive-summary.md) | Done |
| 1 | Industry Challenge Matrix (44) | [docs/01-industry-challenge-matrix.md](docs/01-industry-challenge-matrix.md) | Done |
| 2 | Prioritized AI Use Case Catalog (40) | [docs/02-ai-use-case-catalog.md](docs/02-ai-use-case-catalog.md) | Done |
| 3 | Capability Model (8 domains) | [docs/03-capability-model.md](docs/03-capability-model.md) | Done |
| 4 | Enterprise Architecture (7 layers) | [docs/04-enterprise-architecture.md](docs/04-enterprise-architecture.md) | Done |
| 5 | FSC Data Model (LDM/PDM/ERD) | [docs/05-fsc-data-model.md](docs/05-fsc-data-model.md) | Done + deployed |
| 6 | Agentforce Design (7 agents) | [docs/06-agentforce-design.md](docs/06-agentforce-design.md) | Done |
| 7 | UX Design Specifications | [docs/07-ux-design-specs.md](docs/07-ux-design-specs.md) | Specs done; 1 live screen |
| 8 | Figma Design Package | [docs/08-figma-design-package.md](docs/08-figma-design-package.md) | Specs done; design system live |
| 9 | Workshop Package (FigJam/Miro) | [docs/09-miro-workshop-package.md](docs/09-miro-workshop-package.md) | Done (Mermaid boards) |
| 10 | Demo Storyline (20 min) | [docs/10-demo-storyline.md](docs/10-demo-storyline.md) | Done |
| 11 | Implementation Roadmap | [docs/11-implementation-roadmap.md](docs/11-implementation-roadmap.md) | Done |
| 12 | Packaging Strategy | [docs/12-packaging-strategy.md](docs/12-packaging-strategy.md) | Done |
| 13 | ROI & Value Framework | [docs/13-roi-value-framework.md](docs/13-roi-value-framework.md) | Done |

## Repository structure

```
WAM-Automation-Studio/
├─ README.md                 # this file
├─ docs/                     # all design deliverables (D0-D13)
├─ diagrams/                 # 23 importable Mermaid (.mmd) diagrams (FigJam/Miro/draw.io) + index
└─ WAM-Studio-SF-Build/      # deployable Salesforce DX (Agentforce DX) project
   └─ force-app/main/default/
      ├─ objects/            # 18 custom AI objects + fields (deployed)
      ├─ permissionsets/     # Wealth_AI_Studio access model
      ├─ aiAuthoringBundles/ # Agentforce Agent Script bundles (e.g. Wealth_Advisor_Agent)
      ├─ genAiPromptTemplates/ # Prompt Builder templates (e.g. Meeting_Prep_Briefing)
      ├─ genAiPlannerBundles/ # Agentforce planner bundles
      ├─ flows/              # automation template stubs
      └─ classes/            # supporting Apex
```

## Salesforce technology footprint

Financial Services Cloud, Sales Cloud, Service Cloud, Experience Cloud, Marketing Cloud, **Agentforce** (Agent Builder, Prompt Builder, Einstein AI), **Data Cloud**, CRM Analytics, Flow, OmniStudio.

## Deploy the skeleton

```bash
# with a default org set (sf org login web --set-default)
cd WAM-Studio-SF-Build
sf project deploy start --source-dir force-app/main/default/objects \
  --source-dir force-app/main/default/permissionsets/Wealth_AI_Studio.permissionset-meta.xml \
  --target-org <alias>
sf org assign permset --name Wealth_AI_Studio --target-org <alias>
```

> The custom AI data model (18 objects, ~40 fields, permission set) has been deployed and smoke-tested against the target org `wm-studio-org` (FSC, API 67.0). See [D5](docs/05-fsc-data-model.md).

## Personas served

Wealth Advisor · Portfolio Manager · Client Service Associate · Distribution Specialist · Compliance Officer · Branch Manager · Operations Analyst · End Client.

---
*This is a design accelerator. The `/sfdx` package is a deployable skeleton (valid metadata + template stubs) intended for an FSC-enabled org; production business logic should be hardened before go-live.*
