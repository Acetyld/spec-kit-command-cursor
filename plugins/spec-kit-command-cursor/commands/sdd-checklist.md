---
name: sdd-checklist
description: Generate a reviewer-owned requirements-quality checklist (unit tests for English). Not an implementation todo list.
---

# /sdd-checklist Command

Port of official `/speckit.checklist`. Custom lists under `specs/active/[task-id]/checklists/`. Distinct from specify’s built-in `requirements.md`.

---

## Checklist purpose

These are **unit tests for requirements writing** — completeness, clarity, consistency, coverage, edge cases.

**Not:** “button clicks”, “API returns 200”, “implementation matches spec”.

`[x]` = reviewer judged the *requirement* good. **Never** mark generated items `[x]`. `/sdd-implement` must not tick these.

---

## Usage

```
/sdd-checklist [task-id] [optional domain focus]
```

---

## Instructions

Skip extension hooks. Require `spec.md`. Load constitution if present.

1. Read spec (and plan if it exists) for the focus domain.
2. Write `specs/active/[task-id]/checklists/[slug].md` from `sdd/templates/checklist-template.md`.
3. Items are questions about whether the **spec** defines the behavior (quantified, consistent, edge-cased).
4. Leave every box `[ ]`.
5. Do not overwrite `checklists/requirements.md` (owned by `/sdd-specify` and `/sdd-clarify`).

Next: `/sdd-tasks [task-id]` if plan exists, else `/sdd-plan [task-id]`.

---

## Output

```
✅ Checklist: `specs/active/[task-id]/checklists/[slug].md` ([n] unchecked items)

Reviewer marks [x] when requirements quality is satisfied.
Next: /sdd-tasks [task-id]
```
