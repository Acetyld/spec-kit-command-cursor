# Feature Specification: Cursor Runtime Alignment (2026)

## Overview

Align spec-kit with the current Cursor plugin and agent runtime. Spec-kit stays a spec + DAG + memory workflow. Cursor owns isolation, parallel `Task` spawn, review, cloud handoff, worktrees, and long-lived goals. This release makes advertised subagent behavior real (fan-out siblings), respects the two-level nest limit, fixes stale Cursor names/APIs, adds Custom Modes and `/goal` on `/sdd-implement`, and ships a tiny optional hook pack.

**Depends on:** [research.md](./sdd-research.md) (deep research, 2026-09-01).

## Problem Statement

### What problem are we solving?

- Commands and docs claim a three-level tree (`orchestrator → implementer → verifier`) that Cursor **cannot** run. Grandchildren cannot spawn.
- `/sdd-research`, `/sdd-brief`, `/sdd-specify`, `/sdd-plan` say they spawn explorer/planner; the main agent writes the files. Parallel work that Cursor already supports is unused.
- Docs still say `/babysit`, `CallMcpTool`, `sddVersion: "5.1"`, and "type `/in-cloud`" instead of Task `environment: "cloud"`.
- Skills cannot be pinned as Custom Modes (no `icon`/`color`). `/sdd-implement` is a single pass; users already wrap it with `/goal` themselves.
- Hooks were removed, so there is no reliable structured write on `subagentStop` / session `stop`.

### Who are the affected users?

- Developers using the marketplace plugin in Cursor 3.8+ (especially 3.x / Aug 2026 runtimes).
- Plugin authors and contributors who copy `docs/agent-manual.md` and agent frontmatter.
- Teams running `/sdd-execute-parallel` who expect verify-after-implement to actually fire.

### Why is this important?

- Broken nest + fake spawn means parallel SDD is a story, not a runtime.
- Stale names (`/babysit`) fail against current Cursor docs (`/autopilot`).
- `/goal` + Custom Modes are how Cursor now keeps an agent on a playbook until done.

## Requirements

### Functional Requirements

- **FR-001**: Two-level nest only
  - **Acceptance Criteria**:
    - Agent manual, `sdd-system.mdc`, `sdd-implementer`, `sdd-orchestrator`, `/sdd-execute-parallel`, `/sdd-implement` describe at most: main (or orchestrator at depth 1) → siblings.
    - Implementer **must not** be instructed to spawn `sdd-verifier` when it is already a child of orchestrator.
    - Verifier is spawned by **main or orchestrator** as a sibling after the matching implementer returns.
    - Any diagram that shows `implementer → verifier` as a grandchild is removed or rewritten.

- **FR-002**: Fan-out spawn for explore / research / plan
  - **Acceptance Criteria**:
    - `/sdd-research` and `/sdd-brief` spawn **one or more** `sdd-explorer` Tasks in a **single message** when there are distinct areas (codebase slices, existing specs, optional deep/external).
    - `/sdd-specify` and `/sdd-plan` spawn **one or more** `sdd-planner` Tasks in a single message when the work splits cleanly (e.g. API vs UI); otherwise one planner is enough.
    - Main agent synthesizes `research.md` / `feature-brief.md` / `spec.md` / `plan.md`.
    - AskQuestion runs only on the **main** agent, never inside a background child.
    - `sdd-explorer` is kept. Built-in Explore may be used *inside* explorer for raw search; explorer is not deleted.

- **FR-003**: Fan-out spawn for build
  - **Acceptance Criteria**:
    - `/sdd-implement` on a large todo-list (default: 5+ independent todos, or user says "in parallel") spawns multiple `sdd-implementer` siblings in one message, then sibling `sdd-verifier`s after each returns (or after the batch).
    - `/sdd-execute-parallel` already fans out; it must use the sibling-verifier rule and **Await** for background implementers instead of prose "wait loops."
    - Small / sequential work may stay on main or a single implementer.

- **FR-004**: `/goal` on `/sdd-implement`
  - **Acceptance Criteria**:
    - `/sdd-implement` instructs the agent to set a long-lived `/goal` whose success is: todos done, sibling verifier green, blockers documented — not "one pass then stop."
    - Goal text is derived from the active spec title + "until verifier reports complete."
    - Document pairing `/goal` with Custom Mode `sdd-implementation` in README-technical and agent-manual.

- **FR-005**: Official Cursor names and Task APIs
  - **Acceptance Criteria**:
    - Every `/babysit` occurrence in plugin commands, agents, rules, docs, README becomes `/autopilot` (one-line "formerly babysit" note allowed in changelog only).
    - Agent-manual documents Task fields: `environment: "cloud"`, `cloud_base_branch`, `run_in_background`, `resume`, and types `bugbot`, `security-review`, `best-of-n-runner`.
    - Cloud guidance prefers Task `environment: "cloud"` in orchestrator/sdd-implement prompts; `/in-cloud` remains as the user-facing slash alias.

- **FR-006**: Custom Modes on SDD skills
  - **Acceptance Criteria**:
    - `sdd-planning`, `sdd-implementation`, `sdd-audit`, `sdd-research` SKILL.md frontmatter include `icon` and `color` from Cursor's documented set.
    - Agent-manual and README-technical tell users to pin a skill with Option+Enter (Mac) / Alt+Enter (Windows).
    - Suggested badges: planning `book-open`/`blue`, implementation `rocket`/`green`, audit `shield`/`orange`, research `beaker`/`purple`.

- **FR-007**: Optional hook pack
  - **Acceptance Criteria**:
    - Plugin ships `hooks/hooks.json` + scripts for `subagentStop` and `stop` only.
    - `subagentStop`: if the child is `sdd-verifier` (or prompt contains a task-id), append/write a small structured result under `specs/` (progress or checkpoint fragment). Fail-open (non-zero except exit 2 does not block).
    - `stop`: flush/remind checkpoint; do not auto-`/sdd-complete`.
    - No analytics, no prompt logging, no `afterFileEdit` formatters in this pack.
    - `/sdd-init` documents hooks as optional; does not force-copy if the user already has `.cursor/hooks.json`.

- **FR-008**: Command frontmatter and version hygiene
  - **Acceptance Criteria**:
    - All plugin `commands/*.md` have YAML `name` + `description`.
    - Roadmap templates and `/sdd-full-plan` write `sddVersion: "6.0"` (or current plugin major.minor), not `"5.1"`. `planMode` is removed or set false and not described as Cursor Plan mode.
    - `sdd-memory` references use `CallDynamicTool`, not `CallMcpTool`.
    - `sdd/guidelines.md` no longer documents `.cursor/commands/` or PLAN Mode as current layout.
    - Marketplace / plugin version notes stay consistent in the files this release touches (no silent leftover 5.1 in templates).

- **FR-009**: Honest command headers
  - **Acceptance Criteria**:
    - Each command's "Subagent:" / "Leverages:" line matches what the body actually does after this spec.
    - Native Cursor commands (`/multitask`, `/review`, `/goal`, `/autopilot`) are labeled native, not listed as plugin commands in the SDD command table.

### Non-Functional Requirements

- **Compatibility**: Prompt/markdown-only plugin. No new MCP server. Works on Cursor 3.8+; documents Aug 2026 primitives as available-when-present.
- **Least surprise**: AskQuestion and user-visible decisions stay on the main conversation.
- **Cost**: Fan-out is capped (default max 4 parallel explorers/planners/sdd-implementers; same `settings.maxParallelImplementers` if present). Docs state N subagents ≈ N× tokens.
- **Fail-open hooks**: Hook failure must not block implement/verify.
- **Maintainability**: One nest/spawn protocol in `docs/agent-manual.md`; commands link to it instead of restating a conflicting tree.

## User Stories

### US-001: Parallel research without blocking chat
**As a** developer  
**I want** `/sdd-research` to run several `sdd-explorer` agents at once  
**So that** I get an SDD research report without the main chat doing all the grep itself

**Acceptance Criteria:**
- Distinct areas become parallel explorer Tasks in one turn
- Main writes `research.md` from their summaries
- User questions use AskQuestion on main

**Priority:** High  
**Effort:** Medium

### US-002: Implement until it is actually done
**As a** developer  
**I want** `/sdd-implement` to use `/goal` and keep going until verifier is green  
**So that** I do not have to remember to wrap implement with `/goal` myself

**Acceptance Criteria:**
- `/sdd-implement` sets or instructs `/goal` with a verifier-complete success condition
- Large independent todos run as parallel implementer siblings
- Verifier is not a child of implementer when orchestrator already used a nest slot

**Priority:** High  
**Effort:** Medium

### US-003: Parallel roadmap execution that can verify
**As a** developer  
**I want** `/sdd-execute-parallel` to verify each task  
**So that** "done" means a sibling verifier ran, not a grandchild that never started

**Acceptance Criteria:**
- Checkpoint records implementer and verifier agent IDs when available
- Await is used for background implementers
- Roadmap status does not become `done` if verifier reports gaps

**Priority:** High  
**Effort:** Medium

### US-004: Pin SDD as a Custom Mode
**As a** developer  
**I want** to pin `sdd-implementation` (or planning/sdd-audit) as a Custom Mode  
**So that** the playbook stays in context for the whole session

**Acceptance Criteria:**
- Skills have `icon` + `color`
- Docs show Option+Enter / Alt+Enter

**Priority:** Medium  
**Effort:** Small

### US-005: Current Cursor vocabulary
**As a** developer  
**I want** docs to say `/autopilot` and Task cloud params  
**So that** copy-paste matches Cursor 2026

**Acceptance Criteria:**
- No remaining `/babysit` in plugin runtime files
- Agent-manual lists Task cloud + review types

**Priority:** High  
**Effort:** Small

### US-006: Structured verify output without a third nest
**As a** team using SDD  
**I want** optional `subagentStop`/`stop` hooks  
**So that** verifier results land on disk even if the parent context is tight

**Acceptance Criteria:**
- Plugin hook pack exists and is fail-open
- No extra hook events in this release

**Priority:** Medium  
**Effort:** Medium

## Success Metrics

- Zero documented three-level spawn paths in plugin agents/commands/rules/docs.
- `/sdd-research` and `/sdd-implement` command bodies contain explicit multi-`Task` + sibling-verifier instructions.
- `/babysit` count in `plugins/spec-kit-command-cursor/**` is 0 (except optional changelog "formerly").
- All `commands/*.md` have `name` + `description` frontmatter.
- Four skills listed in FR-006 have `icon` and `color`.
- A reviewer can follow agent-manual and produce a legal nest (no grandchild spawn) without reading research.md.

## Edge Cases & Error Scenarios

- **Only one research area**: spawn a single explorer; do not invent fake parallelism.
- **Plan slices conflict**: main AskQuestions; do not let two planners overwrite `plan.md` blindly — write slice files or return text; main merges.
- **AskQuestion needed mid-implement**: implementer reports blocker; main asks; do not AskQuestion inside background implementer if the UI is unavailable.
- **Verifier fails**: task stays `blocked` or incomplete; `/goal` remains open; do not mark roadmap `done`.
- **Hooks missing or denied**: workflow still completes via agent-written `progress.md`.
- **User on older Cursor without `/goal` or Custom Modes**: treat as available-when-present; implement still runs todos + verifier.
- **File overlap on parallel implement**: keep existing `touchedFiles` serialization (isolated VM swarms are out of scope).
- **Explorer + built-in Explore both fire**: explorer description stays specific ("SDD research report"); do not also create a competing generic "explore" agent.

## Dependencies

- Cursor 3.8+ plugin loader (`agents/`, `commands/`, `skills/`, `rules/`, `hooks/`).
- Task tool: parallel calls, `run_in_background`, optional `environment: "cloud"`.
- `/goal` and Custom Modes (Aug 2026) — degrade gracefully.
- Existing SDD paths: `specs/`, `.sdd/config.json`, roadmap checkpoint format.

## Assumptions

- Plugin remains prompt/markdown; no compiled runtime.
- User decisions stay on the main agent (AskQuestion).
- Max parallel default 4 unless `.sdd/config.json` says otherwise.
- `/babysit` is fully replaced by `/autopilot` (no required alias).
- `sdd-explorer` output contract from the current agent file stays the report shape.

## Out of Scope

- Isolated per-subagent worktree/cloud VM swarms (`each in its own environment`) as the default parallel strategy.
- `/automate` recipes (PR comment → `/sdd-audit`, CI fail → fix).
- Generating real app-stack `environment.json` / `worktrees.json` (detect npm vs pnpm, etc.).
- Plugin marketplace canvas.
- Wiring `/sdd-audit` to Task `bugbot` + `security-review` (listed as later in research; not this slice).
- Adding or removing subagents beyond protocol changes to the existing six.
- Agent Plugins (`plugin.json` at root) dual-format.
- MCP server for specs.

## Review Checklist

- [x] Requirements are clear and testable
- [x] User stories follow INVEST criteria
- [x] Acceptance criteria are specific and measurable
- [x] Edge cases are identified and addressed
- [x] Dependencies are documented
- [x] Success metrics are defined
- [ ] Stakeholder review completed

---
**Created:** 2026-09-01  
**Last Updated:** 2026-09-01  
**Status:** Complete  
**Completed:** 2026-09-01  
**Task ID:** cursor-runtime-2026  
**Source:** [research.md](./sdd-research.md)
