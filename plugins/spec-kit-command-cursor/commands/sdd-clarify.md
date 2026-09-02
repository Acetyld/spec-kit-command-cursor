---
name: sdd-clarify
description: Ask up to 5 targeted questions and write answers into spec.md. Official Spec Kit clarify. One AskQuestion at a time.
---

# /sdd-clarify Command

Port of official `/speckit.clarify`. Run **before** `/sdd-plan`. `FEATURE_DIR` = `specs/active/[task-id]/`.

---

## Usage

```
/sdd-clarify [task-id] [optional focus]
```

---

## Instructions

Skip extension hooks. Load `.sdd/memory/constitution.md` if it exists. If `spec.md` is missing, tell the user to run `/sdd-specify` first.

Scan the spec with this taxonomy (Clear / Partial / Missing): Functional scope, Domain & data, Interaction & UX, NFRs, Integrations, Edge cases, Constraints, Terminology, Completion signals, Placeholders.

Queue at most **5** high-impact questions (Impact × Uncertainty). Each must be multiple-choice (2–5 options) or ≤5 words.

**Ask one question per AskQuestion call.** Recommended option first. After each answer:

1. Ensure `## Clarifications` then `### Session YYYY-MM-DD`.
2. Append `- Q: … → A: …`.
3. Patch the matching spec section (FR, stories, entities, SC, edge cases, terms). Replace contradictions; do not duplicate.
4. Save `spec.md` after each answer.

Stop when critical gaps are gone, the user says done, or 5 questions are asked.

**Re-validate** `checklists/requirements.md` if it exists: toggle only `[ ]`/`[x]` markers whose pass/fail changed. Do not rewrite the rest of that file.

If nothing material is unclear: say so and suggest `/sdd-plan`.

---

## Output

```
✅ Clarifications written to `specs/active/[task-id]/spec.md`
Questions: [n]/5
Checklist: [before] → [after] passing

Next: /sdd-plan [task-id]
```
