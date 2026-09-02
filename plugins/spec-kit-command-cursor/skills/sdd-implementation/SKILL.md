---
name: sdd-implementation
description: Finish remaining T0xx tasks ([X] in tasks.md). /goal + sibling verifier. Next /sdd-converge.
icon: rocket
color: green
---

# SDD Implementation Skill

Build what has been planned. `/sdd-implement` finishes remaining `T0xx` tasks unless `$ARGUMENTS` scopes a phase. Next is `/sdd-converge`, not archive.

## When to Use

- Executing planned implementations
- Code generation from specifications
- Building features according to plan

## Protocol

### Step 1: Load the Plan
Read: `tasks.md` → `plan.md` → `spec.md` → `data-model.md` → `contracts/` → `research.md` → `.sdd/memory/constitution.md` → `quickstart.md` → `todo-list.md`. Treat `checklists/` as a read-only gate (AskQuestion if unchecked; never tick them).

### Step 2: Expand the checklist
If `tasks.md` exists, `todo-list.md` must be a **1:1 copy** of those `T001` checkboxes.

Forbidden:
- `3.2–3.10 (see tasks.md)`
- Phase headings with no individual tasks
- Implementing against a collapsed remainder

If the list is stubbed or missing later phases, rewrite it from `tasks.md` before coding.

### Step 3: Execute until finished
1. **Read entire list** before starting
2. **Execute in dependency order** — `[P]` may fan out; same-file tasks stay sequential
3. **When a phase ends, start the next ready tasks in the same run**
4. **Mark completion** — `[X]` in `tasks.md` and the matching `todo-list.md` line
5. **Document blockers** — never skip silently, use `[BLOCKED: reason]`
6. **Do not stop** after a phase, a verifier checkpoint, or “show progress”

Stop only when every in-scope task is `[X]` or `[BLOCKED]`, or the run is forced to pause. On a forced pause the last line is: `Reply continue` or `/sdd-implement [task-id]`. Then `/sdd-converge`.

### Step 4: Follow Patterns
Reference `references/patterns.md` for project conventions and implementation patterns.

### Step 5: Track Progress
Use `scripts/progress.sh` to visualize completion status.

### Step 6: Report

**Complete** (in-scope `T0xx` closed, sibling verifier ran on the whole list):

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

**Paused** (forced stop): X/Y done, list still-open ids, last line = `Reply continue` or `/sdd-implement [task-id]`. Never “Implementation complete” while boxes are open.

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
- After **all in-scope tasks** are closed, the **parent** spawns `sdd-verifier` for the whole list (implementer never spawns verifier). Next: `/sdd-converge`.
- Recall/persist project knowledge via the `sdd-memory` skill (no-op when the memory provider is `standard`)
- Discoveries trigger `sdd-evolve` skill for spec updates
- Use the ask question tool for ambiguous requirements
