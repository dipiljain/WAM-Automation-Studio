# Deliverable 12 — Packaging & Portability Strategy

The studio is built to be **portable**: deploy the same accelerator onto any Financial Services Cloud org with minimal change. This deliverable defines what is packaged, how it is distributed, the dependency and configuration model, and the deployment workflow, grounded in the working SFDX project (`WAM-Studio-SF-Build/`, API 67.0) that has already been deployed to `wm-studio-org` ([D5](05-fsc-data-model.md)).

## Packaging principles
1. **FSC-native first.** Reuse standard FSC objects; add custom `*__c` only where FSC has no equivalent ([D5](05-fsc-data-model.md)).
2. **Source-driven.** Everything lives as version-controlled metadata (SFDX), reproducible and reviewable.
3. **Layered package.** Separate the data model, security, automation, agents, and UX so customers adopt incrementally.
4. **Config over code.** Prompts, agent topics, automation templates, and tokens are configuration, not hard-coded.
5. **Trust portable.** Trust Layer, permission sets, and audit (`AI_Agent_Run__c`) travel with the package.

## Distribution options

| Option | Best for | Pros | Cons |
|---|---|---|---|
| **Unlocked package** (recommended) | Repeatable, versioned delivery to many orgs | Versioning, dependencies, upgradeable, namespace optional | Requires Dev Hub + package setup |
| Source deploy (SFDX) | Pilots, single org, this repo today | Simplest, fully transparent, already working | Manual versioning, no install link |
| Managed package | ISV/AppExchange distribution | IP protection, AppExchange | Heavier process, less customer editability |
| Metadata + scratch-org config | Demos, enablement | Fast spin-up, repeatable orgs | Not for production |

**Recommendation:** ship as an **unlocked package** for customers, while keeping the SFDX source deploy (this repo) for pilots/demos.

## Package layers

| Layer | Contents | Package |
|---|---|---|
| L1 Data model | 18 custom objects + ~40 fields | `WealthAIStudio-Core` |
| L2 Security | `Wealth_AI_Studio` permission set; sharing | `WealthAIStudio-Core` |
| L3 Automation | Flows, automation templates, platform events | `WealthAIStudio-Automation` |
| L4 Agents | Agent Script bundles, prompt templates, planner | `WealthAIStudio-Agents` |
| L5 Experience | Lightning app, pages, LWCs, Figma-derived UI | `WealthAIStudio-UX` |

Layered packages let a customer install Core first, then add Automation/Agents/UX as they mature.

## What's in the box (current repo)

```
WAM-Studio-SF-Build/                      # SFDX (Agentforce DX) project, API 67.0
└─ force-app/main/default/
   ├─ objects/            # 18 custom AI objects + fields (deployed)
   ├─ permissionsets/     # Wealth_AI_Studio (object + field FLS)
   ├─ aiAuthoringBundles/ # Wealth_Advisor_Agent (Agent Script)
   ├─ genAiPromptTemplates/ # Meeting_Prep_Briefing
   ├─ genAiPlannerBundles/ # Agentforce planner
   ├─ flows/ + classes/   # automation + supporting Apex
docs/                     # D0-D13 design deliverables
diagrams/                 # Mermaid sources
```

## Dependencies & prerequisites

| Dependency | Required for | Notes |
|---|---|---|
| Financial Services Cloud | Core data model grounding | Modern FSC confirmed on target org |
| Agentforce | Agents + prompts | Agent Script bundles, planner |
| Data Cloud | Grounding, unified profile, RAG | Knowledge Artifacts, streams |
| Einstein Trust Layer | Guardrails, masking, audit | Portable config |
| API version 67.0 | Metadata compatibility | Set in `sfdx-project.json` |

## Configuration & customization model
- **Tokens/branding:** design tokens ([D8](08-figma-design-package.md)) map to SLDS styling hooks; firm theming via custom properties.
- **Prompts:** `genAiPromptTemplates/` and `Prompt_Library__c` records are editable per firm.
- **Agents:** topics/actions/guardrails configured in Agent Studio ([D7-15](07-ux-design-specs.md)); default agent user set per org.
- **Automation:** `Automation_Template__c` blueprints adapted to firm processes.
- **Field extension:** add firm-specific fields without modifying packaged objects (extensible by design).

## Deployment workflow

```bash
# Pilot / source deploy (current, proven)
cd WAM-Studio-SF-Build
sf project deploy start \
  --source-dir force-app/main/default/objects \
  --source-dir force-app/main/default/permissionsets/Wealth_AI_Studio.permissionset-meta.xml \
  --target-org <alias>
sf org assign permset --name Wealth_AI_Studio --target-org <alias>

# Customer / unlocked package (target state)
sf package create --name "WealthAIStudio-Core" --package-type Unlocked --path force-app
sf package version create --package "WealthAIStudio-Core" --installation-key-bypass --wait 20
sf package install --package <version-id> --target-org <customerOrg> --wait 20
```

## Environment & release strategy
- **Branches → orgs:** feature → scratch, `main` → integration/UAT, tagged release → production.
- **Versioning:** semantic package versions; release notes per layer; upgrade path tested in a staging org.
- **CI/CD:** validate deploy + run Apex tests on PR; promote on tag.
- **Rollback:** packages are versioned; keep last-known-good; data model changes are additive.

## Portability checklist (per new org)
1. Confirm FSC + Agentforce + Data Cloud + Trust Layer entitlements.
2. Install/deploy Core (objects + permission set); assign permission set.
3. Configure Data Cloud grounding + Knowledge Artifacts.
4. Set default agent user; review prompts/guardrails.
5. Add Automation/Agents/UX layers; smoke-test ([D5](05-fsc-data-model.md) method).
6. Seed demo/reference data if needed ([D10](10-demo-storyline.md)).
