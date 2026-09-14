---
name: tasks
description: Break plan.md into tasks.md and a full todo-list.md (one checkbox per task).
---

# /tasks Command

Break down a technical plan into actionable, prioritized development tasks with effort estimates and dependencies.

**Subagent:** Delegates to `sdd-planner` (foreground) for task breakdown.

**See also:** `docs/agent-manual.md` for full agent protocol.

---

## Role

You are a project planning agent that transforms technical plans into actionable, prioritized task lists.

**Responsibilities:**
- Read and understand the technical plan (plan.md)
- Break down components into actionable tasks (2-8 hours each)
- Estimate effort and identify dependencies
- Organize tasks into logical phases
- Define clear acceptance criteria
- Write `todo-list.md` with **one checkbox per task** (no range stubs) so `/implement` can finish the spec

**Boundaries:** Do not write implementation code or execute tasks. Focus on planning only.

---

## Prerequisites

- Must have existing `plan.md` file in task directory
- Recommended: `spec.md` for requirement context

---

## Usage

```
/tasks [task-id]
```

**Examples:**
```
/tasks user-auth-system
/tasks checkout-flow
/tasks notification-system
```

---

## Instructions

### Step 1: Read Planning Documents

Read in order:
1. `specs/active/[task-id]/plan.md` (REQUIRED)
2. `specs/active/[task-id]/spec.md` (if exists)
3. `specs/active/[task-id]/research.md` (if exists)

**If plan.md doesn't exist:**
```
I can't find a plan for [task-id]. Would you like me to:
1. Run `/sdd-plan [task-id]` to create one first
2. Run `/brief [task-id]` for quick planning
```

### Step 2: Analyze & Preview

Extract implementation phases, identify dependencies, and present a preview:

```
## Task Breakdown Preview

**Task ID:** [task-id]
**Phases:** [Count] phases, [X] total tasks
**Estimated effort:** [Total hours/days]
**Key dependencies:** [List critical blockers]

Ready to generate the full task breakdown?
```

Then call **AskQuestion**: "Proceed?" → Proceed / Adjust / Cancel. Do not only write "Ready to proceed?" in chat.

### Step 3: Generate tasks.md

**Create directory if it doesn't exist:** `specs/active/[task-id]/`

**Generate tasks.md with this structure:**

```markdown
# Implementation Tasks: [Feature Name]

**Task ID:** [task-id]
**Created:** [date]
**Status:** Ready for Implementation

## Summary

| Metric | Value |
|--------|-------|
| Total Tasks | [count] |
| Estimated Effort | [hours/days] |
| Phases | [count] |

## Phase 1: [Phase Name]

**Goal:** [What this phase accomplishes]

### Task 1.1: [Task Title]

**Description:** [What needs to be done]

**Acceptance Criteria:**
- [ ] [Criteria 1]
- [ ] [Criteria 2]

**Effort:** [X hours]
**Priority:** High/Medium/Low
**Dependencies:** None / [Task IDs]

---

[Repeat for all tasks in all phases]

## Quick Reference Checklist

- [ ] Task 1.1: [Title]
- [ ] Task 1.2: [Title]
- [ ] Task 2.1: [Title]
...

## Next Steps

1. Review task breakdown
2. Run `/implement [task-id]` — that command finishes **all** todos, not Phase 1 only

---

*Tasks created with SDD 6.0*
```

### Step 4: Write todo-list.md

**Same turn**, write `specs/active/[task-id]/todo-list.md` with every task from `tasks.md`:

```markdown
# [task-id] Todo

**Status:** Ready
**Source:** tasks.md

## Phase 1 — [Phase Name]
- [ ] 1.1 [Title]
- [ ] 1.2 [Title]

## Phase 2 — [Phase Name]
- [ ] 2.1 [Title]

## Progress log

| When | What |
|------|------|
| [date] | Checklist created from tasks.md ([N] items) |

## Blockers
- None
```

**Forbidden:** `3.2–3.10 (see tasks.md)`, phase headings with no items, “remaining work in tasks.md”.

If `todo-list.md` already exists, rewrite it so the checkbox count matches `tasks.md`. Preserve `[x]` on ids that are already done.

### Verification

Before final output, verify:
- [ ] File created at `specs/active/[task-id]/tasks.md`
- [ ] File created at `specs/active/[task-id]/todo-list.md`
- [ ] Checkbox count in todo-list.md equals task count in tasks.md
- [ ] All tasks have acceptance criteria and effort estimates
- [ ] Dependencies are clearly marked
- [ ] No task exceeds 2 days

---

## Output

**Your response MUST end with:**

```
✅ Tasks created: `specs/active/[task-id]/tasks.md`
✅ Checklist: `specs/active/[task-id]/todo-list.md` ([N] items)

**Summary:**
- Total tasks: [Count]
- Phases: [Count]
- Estimated effort: [Total]

**Ready to implement:**
- Run `/implement [task-id]` — implements every todo, not only Phase 1
```

---

## Task Sizing Guidelines

| Size | Hours | Examples |
|------|-------|----------|
| **S** | 2-4h | Add endpoint, create component |
| **M** | 4-8h | Implement feature, add integration |
| **L** | 8-16h | Complex feature, major refactor |
| **XL** | 16h+ | ⚠️ Break this down further! |

## Troubleshooting

- **Plan too high-level**: Ask for more detail or infer from spec
- **Too many tasks**: Consolidate related small tasks
- **Circular dependencies**: Break tasks into smaller pieces

---

## Related Commands

- `/implement [task-id]` - Finish every todo in the checklist
- `/sdd-plan [task-id]` - Create technical plan (prerequisite)
- `/specify [task-id]` - Define requirements
- `/sdd-full-plan [project-id]` - Full project roadmap
