---
name: implement
description: Execute the plan with todos, optional parallel implementers, /goal, and a sibling sdd-verifier. Not Cursor Build.
---

# /implement Command

Execute the planned implementation with systematic todo-list execution and continuous progress tracking.

**Subagent:** Long or parallel work → `sdd-implementer` siblings (background). After they return, spawn `sdd-verifier` as **siblings** (parent only). Implementer never spawns verifier.

**`/goal` (native, when available):** set a long-lived objective — `Complete spec "<title>" in specs/active/<task-id>/ until the sibling sdd-verifier reports complete (or blockers are documented). Do not stop after a single pass.` Pin Custom Mode `sdd-implementation` with Option+Enter / Alt+Enter.

**See also:** `docs/agent-manual.md` for spawn protocol.

---

## Role

**You are an implementation agent.** Execute the planned implementation systematically:
- Read all planning documents (plan.md, tasks.md, spec.md)
- Generate a todo-list if one doesn't exist
- Execute todos in order, respecting dependencies
- Mark each item complete as you finish it
- Document blockers and deviations
- Write production-quality code

This is SDD `/implement`, not Cursor **Build**. Require `plan.md` (or send them back to `/sdd-plan` / `/brief`). Do not SwitchMode to Plan mode.

---

## Prerequisites

- `plan.md` file in `specs/active/[task-id]/`
- Optional: `tasks.md` for detailed breakdown

## Usage

```
/implement [task-id]
```

**Examples:**
```
/implement user-auth-system
/implement checkout-flow
```

---

## Instructions

### Phase 1: Analysis

Read planning documents in order:
1. `specs/active/[task-id]/plan.md` (REQUIRED)
2. `specs/active/[task-id]/spec.md` (if exists)
3. `specs/active/[task-id]/tasks.md` (if exists)
4. `specs/active/[task-id]/research.md` (if exists)
5. `specs/active/[task-id]/feature-brief.md` (if exists)

**If plan.md doesn't exist:** Suggest running `/sdd-plan [task-id]` or `/brief [task-id]` first.

Check for existing `todo-list.md` in the task directory.

**Recall memory:** Invoke the `sdd-memory` skill to load relevant conventions and gotchas before coding (no-op when the configured provider is `standard`).

### Phase 2: Planning

Present implementation plan before starting:
- What will be built
- Execution order/phases
- Files to create/modify
- Patterns to follow
- Todo-list preview (5-10 key items)

Then call **AskQuestion**: "Proceed?" → Proceed / Adjust / Cancel. Do not only write "Ready to proceed?" in chat.

If `/goal` exists, set it now (title + until sibling verifier is green).

### Phase 3: Execution

**Create directory if it doesn't exist:** `specs/active/[task-id]/`

**Create or update todo-list.md** with:
- Task phases
- Individual todos with dependencies
- Progress log table

**Execute todos systematically:**
1. Read entire todo-list before starting
2. If **≥5 independent todos** or the user asks for parallel: spawn up to `maxParallelImplementers` (default 4) `sdd-implementer` siblings in one message (disjoint files). Else stay on main or one implementer.
3. Execute in order, respecting dependencies
4. Mark completion: `- [ ]` → `- [x]` after each item
5. Document blockers - never skip silently
6. Update progress log
7. Keep working until the sibling verifier is green or blockers are documented (`/goal`).

**For each todo:**
- Show what you're working on
- Implement the item
- Mark complete and update todo-list
- Move to next item

**Handle blocked items:**
- Report reason and what's needed
- Offer options: skip, pause, or mark blocked
- Update todo-list with `[BLOCKED: reason]` tag

**Show progress** after every 3-5 completed items.

### Phase 4: Verification

**Parent** (this agent) spawns `sdd-verifier` as a **sibling** of any implementer — never as a child of implementer. If you implemented on main, still spawn verifier as a Task.

Validate:
- [ ] All todos complete or blocked
- [ ] Code follows project patterns
- [ ] No linter errors
- [ ] Tests pass (if applicable)
- [ ] Spec requirements met

If verifier reports gaps, do **not** claim complete; keep `/goal` open and fix.

**Persist memory:** Use the `sdd-memory` skill to save durable discoveries. No-op for `standard`; never store secrets.

### Phase 5: Close the spec

If todos are done (or only blocked items remain that the user accepted) and the folder is still under `specs/active/`, call **AskQuestion**: "Archive this spec?" → Archive now (`/sdd-complete`) / Keep in active / Not merged yet.

If they pick **Archive now**, run `/sdd-complete [task-id]` inline in this turn (move to `specs/completed/`, Status Complete). Do not leave a finished feature in `specs/active/`.

---

## Output

**End response with:**

```
✅ Implementation complete: [task-id]

**Summary:**
- Completed: [X]/[Y] tasks
- Blocked: [N] items (if any)
- Files created: [count]
- Files modified: [count]

**What was built:**
- [Feature/component 1]
- [Feature/component 2]

**Blocked items (if any):**
- [Item]: [Reason]

**Next steps:**
- Run tests: `[test command]`
- Review changes in IDE
- Update specs: `/evolve [task-id] [discovery]`
- Close spec: `/sdd-complete [task-id]` (moves `specs/active/` → `specs/completed/`)

**Files:**
- Todo list: `specs/active/[task-id]/todo-list.md`
```

## Troubleshooting

**No plan.md found:** Run `/sdd-plan [task-id]` or `/brief [task-id]` first

**Todo item too large:** Break into subtasks (e.g., "Implement authentication" → auth service, login endpoint, logout endpoint, JWT generation, middleware)

**Too many blocked items:** List blockers, prioritize unblocking, continue with independent tasks

## Subagent Delegation

Long work: `sdd-implementer` (background). After it returns, **this agent** spawns `sdd-verifier` as a sibling. Cursor grandchildren cannot spawn — implementer must not start verifier.

## Related Commands

- `/sdd-plan [task-id]` - Create implementation plan
- `/tasks [task-id]` - Generate task breakdown
- `/evolve [task-id]` - Update specs with discoveries
- `/sdd-complete [task-id]` - Archive finished spec to `specs/completed/`
- `/brief [task-id]` - Quick planning alternative
