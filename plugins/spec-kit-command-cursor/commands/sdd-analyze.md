---
name: sdd-analyze
description: Read-only consistency analysis of spec.md, plan.md, and tasks.md before implement. Official Spec Kit analyze.
---

# /sdd-analyze Command

Port of official `/speckit.analyze`. **STRICTLY READ-ONLY.** Run only after `/sdd-tasks` produced `tasks.md`. Distinct from `/sdd-audit` (post-code review).

---

## Usage

```
/sdd-analyze [task-id]
```

---

## Instructions

Skip extension hooks. `FEATURE_DIR` = `specs/active/[task-id]/`. Abort if `spec.md`, `plan.md`, or `tasks.md` is missing.

Load constitution from `.sdd/memory/constitution.md`. Constitution MUST conflicts are **CRITICAL** — never dilute a principle here.

Build inventories: FR-### / SC-### (buildable SCs only), user stories, task IDs + `[P]` + paths.

Detection passes (max 50 findings):

- **A Duplication** — near-duplicate requirements
- **B Ambiguity** — vague adjectives, TODO/??? placeholders
- **C Underspec** — verb without object/metric; tasks referencing undefined files
- **D Constitution** — MUST violations
- **E Coverage** — FR with zero tasks; tasks with no FR/story; buildable SC with no task
- **F Inconsistency** — terminology drift, entity mismatch, order contradictions

Severity: CRITICAL (constitution MUST / zero-coverage baseline) · HIGH · MEDIUM · LOW.

Output a report in chat (do not write files unless the user asks). Include coverage % and next actions. If CRITICAL: do not recommend `/sdd-implement` yet.

AskQuestion: “Suggest remediations for the top issues?” → Yes / No. Do **not** apply edits unless they say yes in a later turn.

---

## Output

```
Specification Analysis Report
[table of findings]

Coverage: [n]%   Critical: [n]

Next: /sdd-implement [task-id]   (only if no CRITICAL)
```
