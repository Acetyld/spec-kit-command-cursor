---
name: sdd-tasks
description: Official Spec Kit tasks.md (T001 [P] [US1] + file path). Also write todo-list.md as a 1:1 checkbox copy. Next /sdd-analyze.
---

# /sdd-tasks Command

Port of official `/speckit.tasks`. `FEATURE_DIR` = `specs/active/[task-id]/`. Main writes files. `sdd-planner` may return a breakdown as text.

**See also:** `docs/agent-manual.md`. Template: `sdd/templates/tasks-template.md`.

---

## Role

Actionable, dependency-ordered tasks. Do not write application code.

**I WILL:** write `tasks.md` in official checklist format and a 1:1 `todo-list.md`.
**I WILL NOT:** implement, collapse remaining work into ranges, or skip `/sdd-analyze` as the next gate.

---

## Usage

```
/sdd-tasks [task-id]
```

---

## Instructions

Skip extension hooks and official setup scripts.

1. Require `plan.md` and `spec.md`. Missing plan → tell the user to run `/sdd-plan` (or `/sdd-brief`).
2. Load if present: `data-model.md`, `contracts/`, `research.md`, `quickstart.md`, `.sdd/memory/constitution.md`.
3. Extract tech stack + structure from plan; user stories (P1, P2, …) from spec; map entities and contracts onto stories.
4. AskQuestion: “Write tasks.md?” → Write / Adjust / Cancel.

### Checklist format (REQUIRED)

Every task:

```text
- [ ] T001 Create project structure per implementation plan
- [ ] T005 [P] Implement auth middleware in src/middleware/auth.py
- [ ] T012 [P] [US1] Create User model in src/models/user.py
```

Rules:

- Checkbox + sequential `T001`, `T002`, …
- `[P]` only when files are disjoint and the task does not depend on incomplete work
- `[US1]` / `[US2]` **only** on user-story phases (not Setup, Foundational, or Polish)
- Description must include an exact file path
- Tests only if the spec or user asked for TDD

Wrong: missing ID, missing checkbox, missing path, story label on Setup.

### Phases

1. **Setup** — project init (no story label)
2. **Foundational** — blocking shared work; must finish before stories
3. **One phase per user story** (P1, P2, …) — independently testable increment. Within a story: tests (if requested) → models → services → endpoints → integration
4. **Polish** — cross-cutting (no story label)

Include a Dependencies section (story order), parallel examples per story, and MVP = typically User Story 1.

Copy `sdd/templates/tasks-template.md` structure when filling `tasks.md`.

### todo-list.md (finish-the-spec rule)

**Same turn**, write `todo-list.md` as a **1:1 copy of those checkboxes** (same `T001` ids and titles). Forbidden: `3.2–3.10 (see tasks.md)`, empty phase headings, “remaining work in tasks.md”.

If `todo-list.md` exists, rewrite so checkbox count matches `tasks.md`. Preserve `[x]` / `[X]` on ids already done.

Next: `/sdd-analyze [task-id]`.

---

## Output

```
✅ Tasks: `specs/active/[task-id]/tasks.md` ([N] tasks)
✅ Checklist: `specs/active/[task-id]/todo-list.md` ([N] items)

Per story: US1 [n] · US2 [n] …
MVP: User Story 1
Format: all lines are `- [ ] T0xx … path`

Next: /sdd-analyze [task-id]
```
