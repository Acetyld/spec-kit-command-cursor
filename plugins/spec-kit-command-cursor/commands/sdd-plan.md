---
name: sdd-plan
description: Official Spec Kit plan flow — constitution check, Phase 0 research.md, Phase 1 data-model/contracts/quickstart. Writes plan.md. Not Cursor Plan mode.
---

# /sdd-plan Command

Port of official Spec Kit `/speckit.plan`. `FEATURE_DIR` = `specs/active/[task-id]/`. Constitution = `.sdd/memory/constitution.md`. Main writes files. Fan-out `sdd-planner` siblings only for a clean split (they return text). AskQuestion on main.

**See also:** `docs/agent-manual.md`. Template: `sdd/templates/plan-template.md`.

Do **not** SwitchMode to Cursor Plan mode. Do **not** create a Cursor Plan (the UI with **Build**). Next is `/sdd-checklist` or `/sdd-tasks`, never “press Build”.

This is **plan-time** `research.md` (Phase 0). `/sdd-research` is the *pre-spec* investigation command — do not confuse them.

---

## Role

Design artifacts only. Do not write application source.

**I WILL:** fill `plan.md`, then `research.md`, then `data-model.md` / `contracts/` / `quickstart.md`.
**I WILL NOT:** implement code or generate `tasks.md`.

---

## Usage

```
/sdd-plan [task-id] [optional focus]
```

---

## Instructions

Skip `.specify/extensions.yml` hooks (not used). Skip official setup scripts.

1. Require `specs/active/[task-id]/spec.md` (or `feature-brief.md`). Missing → tell the user to run `/sdd-specify` or `/sdd-brief`.
2. Load `.sdd/memory/constitution.md` if it exists and is not an unfilled template.
3. Copy `sdd/templates/plan-template.md` → `FEATURE_DIR/plan.md` if missing. Fill Technical Context from the spec + repo. Mark unknowns `NEEDS CLARIFICATION`.
4. **Constitution Check** (gate): map each MUST principle to the design. ERROR if a violation is unjustified — stop and AskQuestion rather than proceeding.
5. Present a short architecture preview in chat. AskQuestion: “Write plan artifacts?” → Write / Adjust / Cancel. Wait for the answer.

### Phase 0: Outline & Research

For each `NEEDS CLARIFICATION`, each new dependency, and each integration, research until the marker is gone. Write `FEATURE_DIR/research.md`:

```text
Decision: [what was chosen]
Rationale: [why]
Alternatives considered: [what else]
```

Do not leave `NEEDS CLARIFICATION` in `plan.md` after Phase 0.

### Phase 1: Design & Contracts

Prerequisites: `research.md` complete.

1. `data-model.md` — entities, fields, relationships, validation, state transitions.
2. `contracts/` — public APIs, CLI schemas, endpoints, UI contracts. Skip if the work is purely internal.
3. `quickstart.md` — runnable validation scenarios (prereqs, commands, expected outcomes). No full implementation code.

Re-run Constitution Check after design. ERROR on unjustified MUST violations.

Command ends after Phase 1. Next: `/sdd-checklist [task-id]` (optional extra lists) or `/sdd-tasks [task-id]`.

---

## Output

```
✅ Plan: `specs/active/[task-id]/plan.md`
✅ Research: `specs/active/[task-id]/research.md`
✅ Data model: `specs/active/[task-id]/data-model.md`
Contracts: `specs/active/[task-id]/contracts/` (or skipped)
✅ Quickstart: `specs/active/[task-id]/quickstart.md`

Next: /sdd-checklist [task-id]   or   /sdd-tasks [task-id]
```
