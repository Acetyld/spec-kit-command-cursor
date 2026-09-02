---
name: sdd-specify
description: Write spec.md (WHAT/WHY) plus checklists/requirements.md. Official Spec Kit specify flow. AskQuestion for up to 3 clarifications.
---

# /sdd-specify Command

Port of official Spec Kit `/speckit.specify`. `FEATURE_DIR` = `specs/active/[task-id]/`. Main writes files. Fan-out `sdd-planner` only for a clean split; they return text. AskQuestion on main.

**See also:** `docs/agent-manual.md`. Template: `sdd/templates/spec-template.md`.

---

## Role

Write a stakeholder-facing specification. **WHAT and WHY only** — no tech stack, APIs, or file layout (that is `/sdd-plan`).

---

## Usage

```
/sdd-specify [task-id] [feature description]
```

If task-id is omitted, derive a 2–4 word kebab short name from the description (`user-auth`).

---

## Instructions

Skip extension hooks. If `.sdd/memory/constitution.md` exists, **load it** and honor MUST principles.

1. Require a feature description. Empty → error.
2. `FEATURE_DIR` = `specs/active/[task-id]/`. Create the directory. Copy spec-template → `spec.md`.
3. Extract actors, actions, data, constraints. Fill User Scenarios (P1, P2, … independently testable), Functional Requirements (FR-###), Success Criteria (SC-###, measurable, technology-agnostic), Key Entities, Assumptions.
4. Max **3** `[NEEDS CLARIFICATION: …]` markers. Prefer informed guesses + Assumptions. Priority: scope > security/privacy > UX > technical.
5. Write `FEATURE_DIR/checklists/requirements.md`:

```markdown
# Specification Quality Checklist: [FEATURE NAME]

**Purpose**: Validate specification completeness before planning
**Created**: [DATE]
**Feature**: [spec.md]

## Content Quality
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

## Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Success criteria are technology-agnostic
- [ ] All acceptance scenarios are defined
- [ ] Edge cases are identified
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

## Feature Readiness
- [ ] All functional requirements have clear acceptance criteria
- [ ] User scenarios cover primary flows
- [ ] Feature meets measurable outcomes defined in Success Criteria
- [ ] No implementation details leak into specification
```

6. Validate the spec against each item (up to 3 rewrite iterations). Tick `[x]` only when that quality item passes.
7. If `[NEEDS CLARIFICATION]` remain (max 3): **one AskQuestion call** with those items (each ≥2 options). After answers, replace markers, re-validate, update checklist.
8. Next: `/sdd-clarify [task-id]` (recommended) or `/sdd-plan [task-id]`.

Do **not** embed other checklists inside spec.md.

---

## Output

```
✅ Specification: `specs/active/[task-id]/spec.md`
Checklist: `specs/active/[task-id]/checklists/requirements.md` ([n]/[n] passing)

Next: /sdd-clarify [task-id]   or   /sdd-plan [task-id]
```
