---
name: sdd-implement
description: Official Spec Kit implement + Cursor layer. Finish every tasks.md item ([X]) unless $ARGUMENTS scopes a phase. /goal + sibling verifier. Next /sdd-converge.
---

# /sdd-implement Command

Port of official `/speckit.implement` plus this plugin’s Cursor packaging.

**`/sdd-implement` means finish the spec** unless `$ARGUMENTS` names a phase or task range (official allows that). Keep coding after each phase. Do not print “Implementation complete” while unchecked `T0xx` remain.

**Subagent:** Long or `[P]` work → `sdd-implementer` siblings (background, cap `settings.maxParallelImplementers`, default 4). After they return, spawn `sdd-verifier` as **siblings** (parent only). Implementer never spawns verifier.

**`/goal` (native, when available):** `Complete spec "<title>" in specs/active/<task-id>/ until every remaining task is [X] or [BLOCKED] and the sibling sdd-verifier reports the whole list complete. Do not stop after a single phase.` Pin Custom Mode `sdd-implementation` with Option+Enter / Alt+Enter.

**See also:** `docs/agent-manual.md`.

This is SDD `/sdd-implement`, not Cursor **Build**. Do not SwitchMode to Plan mode.

---

## Usage

```
/sdd-implement [task-id]
/sdd-implement [task-id] [phase or T0xx range]
```

A later `/sdd-implement [task-id]` or `continue` **resumes** the same list.

---

## Instructions

Skip `.specify/extensions.yml` hooks (not used). Skip official setup scripts. `FEATURE_DIR` = `specs/active/[task-id]/`.

Recall memory via `sdd-memory` before coding (no-op when provider is `standard`).

### 1. Checklist gate (read-only)

If `FEATURE_DIR/checklists/` exists:

- Scan every file. Count `- [ ]` vs `- [x]` / `- [X]`.
- `requirements.md` is owned by `/sdd-specify` and `/sdd-clarify`. Custom lists are reviewer-owned quality tests. `[x]` ≠ “code is done”.
- **Never edit checklist files or markers.**
- Table: Checklist | Total | Checked | Unchecked | Status.
- If any unchecked: AskQuestion — “Some checklists have unchecked items. Proceed with implementation?” → Proceed / Stop. Halt on Stop.
- If all checked: continue.

### 2. Load context

Required: `tasks.md`, `plan.md`. If `tasks.md` is missing, tell the user to run `/sdd-tasks`.

If present: `spec.md`, `data-model.md`, `contracts/`, `research.md`, `.sdd/memory/constitution.md`, `quickstart.md`, `todo-list.md`.

If `/goal` / `CreateGoal` exists, set it now (whole remaining list, or the `$ARGUMENTS` scope).

AskQuestion: “Proceed? This will implement **all remaining tasks** unless you scoped a phase.” → Proceed / Adjust / Cancel.

### 3. Ignore files (official)

If this is a git repo, verify/create ignore files for detected stack (`.gitignore`, and `.dockerignore` / eslint / prettier / etc. only when those tools exist). Append missing critical patterns; do not rewrite a healthy ignore file.

### 4. Execute

Parse `T001`… phases, `[P]`, file paths, `[US#]`.

- Execute **all** remaining tasks unless `$ARGUMENTS` scopes a phase or id range.
- Phase-by-phase. Sequential unless `[P]` and files are disjoint.
- Fan out `[P]` via `sdd-implementer` siblings up to `maxParallelImplementers`. Same-file tasks stay sequential.
- TDD: test tasks before corresponding implementation when present.
- Mark completed items `[X]` in **`tasks.md`**. Mirror the same mark on `todo-list.md`.
- If `todo-list.md` is missing or has range stubs, expand it 1:1 from `tasks.md` before coding.
- Halt a sequential chain on failure. For `[P]`, continue siblings that succeeded and report failures.
- After a phase, start the next ready tasks in the **same run**.
- Keep going until every in-scope task is `[X]` or `[BLOCKED: reason]`.
- Forced pause (context / total blocker): write progress, then the Paused output. Last line must be `Reply continue` or `/sdd-implement [task-id]`.

### 5. Verify

Checkpoint (batch landed, tasks still open): parent may spawn `sdd-verifier` for that batch, then continue.

Spec-complete (every in-scope task `[X]` or `[BLOCKED]`): parent spawns `sdd-verifier` for the **whole remaining list**. If gaps, do not claim complete; keep `/goal` open and fix.

Persist durable discoveries via `sdd-memory`. Never store secrets.

### 6. Next command

Do **not** archive. Next is `/sdd-converge [task-id]`.

---

## Output

Use **exactly one**. Never the complete template while unchecked `T0xx` remain.

**Complete** (in-scope tasks `[X]` or `[BLOCKED]`, sibling verifier ran):

```
✅ Implementation complete: [task-id]

Completed: [X]/[Y]   Blocked: [N]
What was built: […]

Next: /sdd-converge [task-id]
```

**Paused** (forced stop only):

```
⏸ Implementation paused: [task-id] — [X]/[Y] tasks done

Still open:
- T0xx: [title]

Next: reply `continue` or run `/sdd-implement [task-id]`
```
