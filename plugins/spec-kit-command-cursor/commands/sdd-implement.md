---
name: implement
description: Finish the spec — expand every tasks.md item into todo-list.md, keep going until all todos are done or blocked, sibling verifier on the whole list. Not Cursor Build.
---

# /implement Command

Execute the planned implementation until the spec is finished.

**`/implement` means finish the spec.** Copy every task from `tasks.md` into `todo-list.md` (one checkbox each). Keep coding after each phase. Do not stop at Phase 1. Do not print “Implementation complete” while unchecked items remain.

**Subagent:** Long or parallel work → `sdd-implementer` siblings (background). After they return, spawn `sdd-verifier` as **siblings** (parent only). Implementer never spawns verifier.

**`/goal` (native, when available):** set a long-lived objective — `Complete spec "<title>" in specs/active/<task-id>/ until every todo is [x] or [BLOCKED] and the sibling sdd-verifier reports the whole list complete. Do not stop after a single phase.` Pin Custom Mode `sdd-implementation` with Option+Enter / Alt+Enter.

**See also:** `docs/agent-manual.md` for spawn protocol.

---

## Role

**You are an implementation agent.** Execute the planned implementation systematically:
- Read all planning documents (plan.md, tasks.md, spec.md)
- Expand **every** task into `todo-list.md` before coding
- Execute todos in order, respecting dependencies
- After a phase finishes, start the next ready todos in the **same run**
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

A later `/implement [task-id]` or the user saying `continue` **resumes** the same todo-list. It does not start a new slice-and-stop.

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
- What will be built (all phases, not only the first)
- Total task count from `tasks.md` (e.g. 32 tasks / 6 phases)
- Execution order and which todos are independently ready now
- Patterns to follow

Then call **AskQuestion**: "Proceed? This will implement **all** todos, not only Phase 1." → Proceed / Adjust / Cancel. Do not only write "Ready to proceed?" in chat.

If `/goal` / `CreateGoal` exists, set it now (whole spec, not one phase).

### Phase 3: Execution

**Create directory if it doesn't exist:** `specs/active/[task-id]/`

**Create or rewrite `todo-list.md` before any code:**
- One checkbox per task in `tasks.md` (`1.1`, `1.2`, `3.2`, …) with the task title
- Never collapse remaining work into ranges (`3.2–3.10 (see tasks.md)` is forbidden)
- If `todo-list.md` already has range stubs, expand them from `tasks.md` before coding
- Keep a progress log table

**Execute until the list is finished:**
1. Read the entire todo-list before starting
2. If **≥5 independent todos** or the user asks for parallel: spawn up to `maxParallelImplementers` (default 4) `sdd-implementer` siblings in one message (disjoint files). Else stay on main or one implementer.
3. Execute in dependency order. Ready todos in different phases may run in parallel (e.g. Phase 3 and Phase 4 after Phase 1).
4. Mark completion: `- [ ]` → `- [x]` after each item
5. Document blockers — never skip silently
6. Update the progress log
7. **When a phase ends, start the next ready todos in the same turn.** Do not wait for the user.
8. Keep working until every todo is `[x]` or `[BLOCKED: reason]`.

**For each todo:**
- Show what you're working on
- Implement the item
- Mark complete and update todo-list
- Move to next item

**Handle blocked items:**
- Report reason and what's needed
- Mark `[BLOCKED: reason]` and continue with independent todos
- Only pause the run if nothing remaining is unblocked

**Show progress** after every 3-5 completed items — then keep going. Progress is not permission to stop.

**Forced pause** (context exhausted, hard blocker on every remaining todo): write progress to `todo-list.md`, then use the **Paused** output below. The last line must be the next action: `Reply continue` or `/implement [task-id]`. Listing leftover phase names without that line is not allowed.

### Phase 4: Verification

**Checkpoint** (a phase or batch just landed, todos still open): parent may spawn `sdd-verifier` as a sibling with scope = work just done. A checkpoint PASS is **not** spec-complete. After it returns, continue the next ready todos immediately.

**Spec-complete** (every todo `[x]` or `[BLOCKED]`): parent spawns `sdd-verifier` as a sibling for the **whole** `todo-list.md`. Implementer never spawns verifier. If you implemented on main, still spawn verifier as a Task.

Validate on spec-complete:
- [ ] All todos complete or blocked
- [ ] Code follows project patterns
- [ ] No linter errors
- [ ] Tests pass (if applicable)
- [ ] Spec requirements met

If verifier reports gaps, do **not** claim complete; keep `/goal` open and fix.

**Persist memory:** Use the `sdd-memory` skill to save durable discoveries. No-op for `standard`; never store secrets.

### Phase 5: Close the spec

Only after spec-complete verification. If the folder is still under `specs/active/`, call **AskQuestion**: "Archive this spec?" → Archive now (`/sdd-complete`) / Keep in active / Not merged yet.

If they pick **Archive now**, run `/sdd-complete [task-id]` inline in this turn (move to `specs/completed/`, Status Complete). Do not leave a finished feature in `specs/active/`.

---

## Output

Use **exactly one** of these. Never the complete template while unchecked todos remain.

**Spec complete** (all todos `[x]` or `[BLOCKED]`, sibling verifier ran on the whole list):

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

**Paused** (forced stop only):

```
⏸ Implementation paused: [task-id] — [X]/[Y] tasks done

**Done this run:**
- [items]

**Still open:**
- [id]: [title]
- [id]: [title]

**Next:** reply `continue` or run `/implement [task-id]`
```

---

## Troubleshooting

**No plan.md found:** Run `/sdd-plan [task-id]` or `/brief [task-id]` first

**Todo item too large:** Break into subtasks (e.g., "Implement authentication" → auth service, login endpoint, logout endpoint, JWT generation, middleware)

**Too many blocked items:** List blockers, continue with independent tasks

**Range stubs in todo-list.md:** Expand from `tasks.md` immediately. Do not implement against a collapsed list.

## Subagent Delegation

Long work: `sdd-implementer` (background). After it returns, **this agent** spawns `sdd-verifier` as a sibling. Cursor grandchildren cannot spawn — implementer must not start verifier.

## Related Commands

- `/sdd-plan [task-id]` - Create implementation plan
- `/tasks [task-id]` - Generate task breakdown + full `todo-list.md`
- `/evolve [task-id]` - Update specs with discoveries
- `/sdd-complete [task-id]` - Archive finished spec to `specs/completed/`
- `/brief [task-id]` - Quick planning alternative
