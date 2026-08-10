# Build Prompt: Post-Meeting Transcript Processing Agent (Salesforce / Agentforce)

> **How to use this file:** Paste everything below the `--- PROMPT START ---` marker as the task for a
> coding agent running **Claude Sonnet 4.6** in the target Salesforce DX project. It is self-contained
> and org-agnostic: it tells the model which Salesforce agent skills to activate and lets those skills
> supply the correct, current metadata formats and conventions. Do not assume any pre-existing custom
> metadata in the org beyond standard objects (Account, Contact, Task, User).

--- PROMPT START ---

## Role

You are a senior Salesforce engineer building production-grade, deployable Salesforce metadata and Apex
in a Salesforce DX project. You MUST use the installed Salesforce agent skills — they encode the current
conventions and correct metadata formats for every metadata type you touch. Activate the relevant skill
before doing that piece of work, and follow its guidance instead of guessing at XML shapes, Agent Script
syntax, or Apex patterns.

## Objective

Build and deploy an **Agentforce agent** that ingests a **post-sales-meeting transcript** (produced from a
wealth advisor's dictation), splits it into the individual meetings it contains, formats each meeting into
professional B2B asset-management call notes, and — after the user confirms — creates one **Call Report**
record per meeting plus optional follow-up reminder **Tasks**.

Persona: a B2B sales advisor at a Fortune 500 Asset Management firm. Output tone and structure must match
that context: institutional, compliant, concise, and skimmable.

## Mandatory Skills (activate the matching skill before doing that work)

- `agentforce-generate` — author, preview, test, and deploy the agent (`.agent` / aiAuthoringBundle,
  Agent Script), its subagents and actions.
- `platform-custom-object-generate` — create the `Call_Report__c` object.
- `platform-custom-field-generate` — create its fields (lookups, long text, datetime, picklists, checkbox).
- `platform-apex-generate` — write the invocable Apex actions and the name-resolution helper.
- `platform-apex-test-generate` — write Apex tests (target 90%+; hard minimum 75% coverage).
- `platform-metadata-api-context-get` — confirm the `GenAiPromptTemplate` (flex prompt template) XML shape.
- `platform-permission-set-generate` — create a permission set granting object/field/Apex access.
- `platform-metadata-deploy` — deploy to the org and resolve deploy errors.
- `platform-apex-test-run` — run tests and verify coverage after deploy.

Do not invoke skills that are irrelevant to this task.

## Discover the environment first

Before building, confirm the target org and CLI setup (e.g., `sf org display` / the `dx-org-switch` or
`dx-org-manage` skill if the default org is unset). If no default/target org is configured, STOP and ask.
Do not assume any custom objects, fields, Apex, agents, prompt templates, or permission sets already
exist. Create everything this prompt specifies. Follow whatever naming, folder, and formatting conventions
the activated skills prescribe.

## Functional Requirements → Implementation

### 1. Multi-meeting segmentation
One transcript may contain notes for several meetings. Segment it by detecting contact names, time-of-day
cues ("this morning", "3pm", "after lunch"), account/company names, and topic boundaries. Assign each
transcript span to exactly one meeting. Preserve every substantive detail; do not drop content.

- Implement segmentation + formatting in a **flex `GenAiPromptTemplate`** named
  `Post_Meeting_Transcript_Processor` that takes the raw transcript as input and returns **structured
  JSON** (one object per detected meeting).
- Each meeting object MUST include: `contact_name`, `account_or_company` (if stated), `meeting_datetime_hint`
  (raw phrase + best ISO guess or null), `formatted_notes` (see #2), `detected_follow_ups` (array of
  `{description, due_date_hint, owner_hint}`), and `confidence` (high/medium/low for the segmentation).
- Instruct the model to return ONLY the valid JSON array (no prose), so the Apex action can parse it
  deterministically.
- If the transcript clearly describes only one meeting, return a single-element array.

### 2. Professional formatting (B2B asset management)
Each meeting's `formatted_notes` must be structured, institutional, and compliant. Use these sections:
`Attendees & Context`, `Discussion Summary`, `Client Objectives / Mandate Signals`,
`Products / Strategies Discussed (as discussion topics, pending suitability review)`,
`Risks / Concerns`, `Agreed Action Items`, `Open Questions`.
Guardrails baked into the prompt template:
- Use ONLY facts present in the transcript. NEVER invent AUM, holdings, performance figures, allocations,
  fees, or personal details.
- Frame any product/strategy idea strictly as a discussion topic subject to suitability/mandate review.
- Neutral, professional, skimmable tone. No promises of returns.

### 3. Display, confirm, then create Call Reports (backend)
The agent flow (implement as a dedicated subagent/topic, e.g. `call_report_processor`):
1. Accept the transcript from the advisor (paste or reference).
2. Call the prompt action to segment + format; **display each formatted meeting** to the user clearly,
   numbered, including which contact/time each maps to.
3. **Explicitly ask for confirmation** before writing anything ("Shall I create the call reports?"). Do
   NOT create records until the user confirms.
4. On confirmation, call an Apex invocable action that creates **one `Call_Report__c` per meeting** in the
   backend, resolving the Contact (and its Account) by name. Return created Ids and a per-meeting status
   (created vs. unresolved-contact). Records are created via backend DML regardless of any UI page.

### 4. Offer follow-up reminder Tasks
If any meeting has `detected_follow_ups`, after Call Reports are created, present the follow-ups and ask
whether to create reminder **Tasks**. On confirmation, call an Apex action that creates standard `Task`
records (`Subject`, `ActivityDate` from due-date hint or default +7 days, `WhoId` = resolved Contact,
`WhatId` = created `Call_Report__c`, `Status`='Not Started', `Priority`='Normal'). Return created Task Ids.
Never auto-create tasks without confirmation.

## Metadata to Create

### Object: `Call_Report__c`
- Label: `Call Report`, Plural: `Call Reports`. Deployment status `Deployed`. Sharing `ReadWrite`.
- Name field: auto-number (e.g., `Call Report {0000}`) or text — follow `platform-custom-object-generate`.

### Fields on `Call_Report__c`
- `Contact__c` — Lookup(Contact). Meeting contact.
- `Account__c` — Lookup(Account). Contact's account (institution).
- `Meeting_DateTime__c` — DateTime. Best-effort parsed meeting time (nullable).
- `Meeting_DateTime_Hint__c` — Text(255). Raw time phrase from transcript.
- `Formatted_Notes__c` — Long Text Area (32768). The professional formatted notes.
- `Raw_Transcript_Segment__c` — Long Text Area (32768). Source span for traceability.
- `Action_Items__c` — Long Text Area (4096). Extracted action items.
- `Follow_Up_Required__c` — Checkbox. True if follow-ups detected.
- `Segmentation_Confidence__c` — Picklist: High, Medium, Low.
- `Advisor__c` — Lookup(User). The advisor (default to running user in Apex).
- `Status__c` — Picklist: Draft, Confirmed. Default `Confirmed` on creation.
- `Source_Batch_Id__c` — Text(64). Correlates all reports created from one transcript run.

### Apex (via `platform-apex-generate`)
Follow the invocable-action pattern the skill prescribes (an inner `Request` with
`@InvocableVariable`, an inner `Result`, and a single `@InvocableMethod run(List<Request>)`), and use
`with sharing`. Create:
- A **Contact resolver** (helper or invocable) that resolves a Contact by name (case-insensitive `LIKE`
  match) and returns Contact Id + Account Id; null-safe (no exception when unmatched).
- `CreateCallReportsAction` — invocable. Input: JSON array of formatted meetings (+ optional raw
  transcript). Parses JSON, resolves contacts, inserts `Call_Report__c` records, sets `Advisor__c` =
  `UserInfo.getUserId()`, stamps a shared `Source_Batch_Id__c`. Output: created Ids + per-meeting status +
  `errorMessage`. Never throw for "contact not found" — return a populated `errorMessage`/status instead.
- `CreateFollowUpTasksAction` — invocable. Input: follow-ups JSON + parent `Call_Report__c` Id (+ contact
  Id). Inserts `Task` records. Output: created Task Ids + `errorMessage`.
- Matching test classes for each (via `platform-apex-test-generate`) covering: single meeting,
  multi-meeting, unresolved contact, empty/blank transcript, malformed JSON (graceful `errorMessage`), and
  follow-up task creation. Assert DML results and error paths. Keep methods bulk-safe.

### Prompt template
- `Post_Meeting_Transcript_Processor` flex `GenAiPromptTemplate` as specified in #1/#2. Input: `Transcript`
  (String, required). Use the skill to confirm the exact XML (type, model, inputs, versioning).

### Agent (via `agentforce-generate`)
- Create the agent (or, if one already exists in the org and extension is clearly appropriate, add to it).
- Add a subagent/topic `call_report_processor` whose reasoning instructions describe the
  segment → display → confirm → create-reports → offer-tasks flow, with hard rules: never write records
  before explicit user confirmation, and never invent financial figures.
- Declare the three actions with typed inputs/outputs:
  `process_transcript` → `prompt://Post_Meeting_Transcript_Processor`,
  `create_call_reports` → `apex://<CreateCallReportsAction>`,
  `create_follow_up_tasks` → `apex://<CreateFollowUpTasksAction>`.
- Wire routing so the agent reaches this subagent when the advisor pastes/refers to a meeting transcript.
- Preview/test the agent per the skill before finishing.

### Permissions
- Create a permission set (via `platform-permission-set-generate`) granting `Call_Report__c` CRUD, all its
  field permissions, and Apex class access for the new classes. Assign it to the running/test user.

## Execution Order (recommended)
1. `Call_Report__c` object + fields → deploy.
2. Contact resolver + the two invocable actions + tests → deploy → run tests.
3. `Post_Meeting_Transcript_Processor` prompt template → deploy.
4. Create/wire the agent and `call_report_processor` subagent → deploy → preview/test.
5. Permission set → deploy → assign.
6. Full delta deploy and `sf apex run test` for coverage.

## Constraints & Guardrails
- Additive changes only; do not delete or restructure unrelated existing metadata.
- Confirmation gates are mandatory: no record or task creation before an explicit user "yes".
- All record creation is backend DML in Apex; the agent narrates results, it does not fabricate Ids.
- Compliance: never invent financial figures; frame products as discussion topics pending suitability review.
- Follow the conventions and formats supplied by the activated skills exactly.
- If the target org, an ambiguous field type, or a name collision blocks you, STOP and ask rather than guessing.

## Acceptance Criteria (self-verify before declaring done)
1. A transcript containing 2+ meetings yields 2+ correctly segmented, contact-attributed meetings.
2. Each meeting is formatted with all required sections in institutional B2B tone, no invented figures.
3. Formatted meetings are displayed and the agent waits for confirmation before any write.
4. On confirmation, one `Call_Report__c` per meeting is created, linked to Contact/Account, sharing a
   `Source_Batch_Id__c`, with `Advisor__c` = running user.
5. Detected follow-ups are offered; on confirmation, `Task` records are created and linked to the right
   Call Report and Contact.
6. Unresolvable contacts are reported gracefully (report still created or clearly flagged; no unhandled exception).
7. All new Apex has tests; org-wide coverage stays >= 75% and all tests pass.
8. Full delta deploys cleanly to the target org and the agent passes a preview/test run.

--- PROMPT END ---
