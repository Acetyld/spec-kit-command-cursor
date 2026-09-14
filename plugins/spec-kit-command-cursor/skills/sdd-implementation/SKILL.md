---
name: sdd-implementation
description: Finish the planned spec — expand every tasks.md item into todo-list.md and keep coding until all todos are done or blocked.
icon: rocket
color: green
---

# SDD Implementation Skill

Build what has been planned. `/implement` finishes the spec, not the first phase.

## When to Use

- Executing planned implementations
- Code generation from specifications
- Building features according to plan

## Protocol

### Step 1: Load the Plan
Read: `plan.md` → `spec.md` → `tasks.md` → `todo-list.md`

### Step 2: Expand the checklist
If `tasks.md` exists, `todo-list.md` must have **one checkbox per task** (`1.1`, `3.2`, `4.1`, …) with the task title.

Forbidden:
- `3.2–3.10 (see tasks.md)`
- Phase headings with no individual tasks
- Implementing against a collapsed remainder

If the list is stubbed or missing later phases, rewrite it from `tasks.md` before coding.

### Step 3: Execute until finished
1. **Read entire list** before starting
2. **Execute in dependency order** — ready todos in later phases may run as soon as their deps are done (do not wait for “Phase 2” to finish if Phase 4 is already unblocked)
3. **When a phase ends, start the next ready todos in the same run**
4. **Mark completion** — `- [ ]` → `- [x]` immediately
5. **Document blockers** — never skip silently, use `[BLOCKED: reason]`
6. **Do not stop** after a phase, a verifier checkpoint, or “show progress”

Stop only when every todo is `[x]` or `[BLOCKED]`, or the run is forced to pause (context / nothing left unblocked). On a forced pause the last line is: `Reply continue` or `/implement [task-id]`.

### Step 4: Follow Patterns
Reference `references/patterns.md` for project conventions and implementation patterns.

### Step 5: Track Progress
Use `scripts/progress.sh` to visualize completion status.

### Step 6: Report

**Complete** (all todos closed, sibling verifier ran on the whole list):

```markdown
## Implementation Summary

### Completed
- [x] Task 1: description

### Files Created/Modified
- `path/to/file.ts`: [purpose]

### Blockers Encountered
- [blocker and resolution]

### Discoveries
- [anything that should update specs]
```

**Paused** (forced stop): X/Y done, list still-open ids, last line = `Reply continue` or `/implement [task-id]`. Never “Implementation complete” while boxes are open.

## Anti-Patterns

- Skipping tasks without explanation
- Marking items done without completing them
- Implementing differently than planned without noting why
- Ignoring blockers instead of documenting them
- Collapsing remaining phases into a range
- Stopping after Phase 1 and asking the user what to do
- Treating a phase-scoped verifier PASS as spec-complete

## Integration

- After a **batch**, the **parent** may spawn a checkpoint `sdd-verifier`, then **continues**
- After **all todos** are closed, the **parent** spawns `sdd-verifier` for the whole list (implementer never spawns verifier)
- Recall/persist project knowledge via the `sdd-memory` skill (no-op when the memory provider is `standard`)
- Discoveries trigger `sdd-evolve` skill for spec updates
- Use the ask question tool for ambiguous requirements
