---
name: sdd-converge
description: Append-only gap check vs spec/plan/tasks. Adds Phase N Convergence tasks or reports converged. Official Spec Kit converge.
---

# /sdd-converge Command

Port of official `/speckit.converge`. Run **after** `/sdd-implement` has run on the current `tasks.md`.

**Only write:** append `## Phase N: Convergence` + new `T0xx` lines on `tasks.md` (and mirror those lines on `todo-list.md`). Never edit spec, plan, or application code. If clean, leave `tasks.md` **byte-for-byte unchanged**.

Distinct from `/sdd-audit` (comments) and `/sdd-analyze` (pre-code, read-only).

---

## Usage

```
/sdd-converge [task-id]
```

---

## Instructions

Skip extension hooks. Require `spec.md`, `plan.md`, `tasks.md`. Load `.sdd/memory/constitution.md` if it is not an unfilled template.

Intent inventory: FR / buildable SC / story acceptance / plan decisions / constitution MUST.

Classify gaps: `missing` · `partial` · `contradicts` · `unrequested` (awareness only — do not delete code).

Severity: CRITICAL (constitution MUST or P1 baseline missing) · HIGH · MEDIUM · LOW.

Present findings table **before** writing. Then:

- **Findings:** next task ID after max existing `T###`; next phase `N`; append one task per actionable finding, CRITICAL/HIGH first:
  `- [ ] T042 <imperative> per <FR-003> (missing)`
- **No findings:** do not touch `tasks.md`. Report `✅ Converged`.

If you appended, copy the new checkboxes onto `todo-list.md`. Next: `/sdd-implement [task-id]`. If converged: `/sdd-complete [task-id]`.

---

## Output

```
✅ Converged — implementation satisfies spec, plan, and tasks.
Next: /sdd-complete [task-id]
```

or

```
⏸ Convergence appended [n] tasks under Phase [N]
Next: /sdd-implement [task-id]
```
