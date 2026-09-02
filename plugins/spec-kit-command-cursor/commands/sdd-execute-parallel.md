---
name: execute-parallel
description: Run roadmap tasks as sibling implementers plus sibling verifiers. Await, checkpoints, optional Task cloud.
---

# /execute-parallel Command

Execute multiple tasks in parallel using async background subagents for coordination.

**Leverages:** Fan-out Task calls, Await, sibling `sdd-verifier`, `touchedFiles` batching, checkpoints. Cloud: Task `environment: "cloud"` (user alias `/in-cloud`). PR follow-up: native `/autopilot`. Native `/multitask` is for ad hoc work without a roadmap.

**See also:** `docs/agent-manual.md` for spawn protocol.

---

## Usage

```
/execute-parallel [project-id]
/execute-parallel [project-id] --epic [epic-id]
/execute-parallel [project-id] --until-finish
/execute-parallel [project-id] --resume
```

**Examples:**
```
/execute-parallel blog-platform
/execute-parallel saas-dashboard --epic epic-002
/execute-parallel my-project --until-finish
/execute-parallel my-project --resume
```

---

## Instructions

### Phase 1: Load and Analyze Roadmap

**Step 0: Resume mode (if `--resume` flag)**

When `--resume` is provided:
1. Read `specs/todo-roadmap/[project-id]/execution-checkpoint.json` if it exists
2. Use `nextReadyTasks` as the starting point; skip tasks already `done` in roadmap.json
3. If no checkpoint, fall back to normal flow (load from roadmap)

**Step 1: Read roadmap (progressive loading for large roadmaps)**

For heavy roadmaps (20+ tasks), load only what's needed:
- **Orchestrator:** Read `dag.roots`, `dag.parallelGroups`, `statistics`, and for the current batch only: `tasks.[task-id]` for ready tasks (including `sdd.touchedFiles`). Do NOT load full `tasks` object for all 40+ tasks.
- **Implementer prompts:** Pass only `task-id`, `task title`, `linkedSpec path`, `executeCommand`. The implementer reads `specs/todo-roadmap/[project-id]/tasks/[task-id].json` and spec files on demand. This keeps orchestrator context lean.

**Step 2: Identify ready tasks**

Tasks are ready when:
- Status is "todo"
- All dependencies have status "done"
- `canParallelize: true` for parallel execution

**Step 3: Plan execution batches**

Group tasks into parallel batches based on:
- Dependency satisfaction (all deps done)
- **File conflict detection:** For implementation tasks, check `sdd.touchedFiles` on each task. If two ready tasks have overlapping `touchedFiles` (e.g. both include `package.json` or `src/auth/**`), they must run in **separate batches** (sequential). Tasks with disjoint file sets can run in parallel.
- Estimated effort (prefer similar-sized tasks in same batch)

**Conflict detection rule:** Two tasks conflict if their `touchedFiles` arrays share any path or if one path is a prefix of another (e.g. `src/auth` and `src/auth/login.ts`). When in doubt, run sequentially.

**Step 4: Parallelism limits**

- **Max parallel implementers:** 3–5 (default: 4). Read from `.sdd/config.json` `settings.maxParallelImplementers` if present.
- When more tasks are ready than the limit, run in waves: batch 1 (first N tasks) → **Await** (if available) → sibling verifiers → batch 2.
- Do not spawn more than `maxParallelImplementers` in a single batch.

### Phase 2: Parallel Execution with Async Subagents

**For each parallel batch, spawn background subagents simultaneously using multiple Task tool calls in a single message.** Limit batch size to `maxParallelImplementers` (default 4).

**Task-to-Subagent Mapping:**

| Task Phase | Subagent | Model | Mode |
|------------|----------|-------|------|
| research | sdd-explorer | inherit | foreground |
| brief/specify/sdd-plan/tasks | sdd-planner | inherit | foreground |
| implement | sdd-implementer | inherit | **background** |
| review | sdd-reviewer | inherit | foreground |
| verify | sdd-verifier | inherit | foreground |

**Cursor 3.8 guidance:** Use built-in `/multitask` for quick independent prompts that do not need SDD state. Use `/execute-parallel` for roadmap-backed work because it enforces dependency order, file conflict checks, checkpoints, and verifier handoffs.

**Worktree guidance:** For risky or competing implementation approaches, launch the agent in an Agents Window worktree. `.cursor/worktrees.json` prepares the checkout before the SDD command runs.

**Cloud:** For long-running, risky, or environment-heavy tasks, set Task `environment: "cloud"` and optional `cloud_base_branch`. User alias `/in-cloud`. After a task lands, `/autopilot` can iterate on its PR. Commit `.cursor/environment.json` so cloud agents start faster.

**Subagent Tree Pattern (siblings only):**

Parent (orchestrator or main) spawns implementers, **Awaits**, then spawns `sdd-verifier` siblings. Implementer never spawns verifier.

```
orchestrator (depth 1)
├── sdd-implementer (task 1)
├── sdd-implementer (task 2)
├── sdd-verifier (task 1)
└── sdd-verifier (task 2)
```

**Spawning subagents (prompt economy):**

Pass minimal context — implementer loads full details on demand:

```
Task 1: {
  subagent_type: "sdd-implementer",
  prompt: "Execute task-001: [title]. Read task details from specs/todo-roadmap/[project-id]/tasks/task-001.json and linked spec at [linkedSpec path]. Run [executeCommand].",
  model: "inherit"
}
```

**Each subagent receives:** `task-id`, `task title`, `linkedSpec path`, `executeCommand`. Implementer fetches full task JSON and spec files itself. Do NOT inline full roadmap or task objects into the prompt.

### Phase 3: Progress Tracking

**After each batch completes:**

1. **Await** background implementers if the tool exists; else collect Task results
2. Spawn `sdd-verifier` **siblings** for each implementer that claimed done
3. **Update roadmap.json** statuses: `todo` → `in-progress` → `review` → `done` only if verifier is green
4. **Write execution-checkpoint.json** in `specs/todo-roadmap/[project-id]/`:
   - `lastCompletedBatch`, `failedTaskId`, `nextReadyTasks`, `timestamp`, `batchNumber`
   - `agentIds`: `{ [taskId]: { implementer?, verifier? } }` when Task returns IDs
5. On `--resume`, pass Task `resume` when an ID exists; still skip `done` tasks
6. **Identify next ready tasks** based on completed dependencies

**Progress Report Format:**

```markdown
## Batch 1 Complete

| Task | Status | Notes |
|------|--------|-------|
| task-001 | done | Files: src/auth.ts |
| task-003 | done | Files: src/api.ts |

## Next Batch Ready
- task-002 (deps satisfied: task-001)
- task-004 (deps satisfied: task-003)
```

### Phase 4: Completion

**When all tasks done:**

1. **Final roadmap.json update** — all statuses "done", update statistics
2. **Generate completion report:**

```markdown
## Parallel Execution Complete

**Project:** [project-id]
**Tasks Executed:** [N]
**Parallel Batches:** [M]

### Execution Timeline
| Batch | Tasks | Parallelism |
|-------|-------|-------------|
| 1 | task-001, task-003, task-005 | 3x |
| 2 | task-002, task-004 | 2x |

### Verification Summary
- All implementations verified via sibling sdd-verifier: YES
- Spec compliance: 100%

### Next Steps
- Review changes in IDE
- Run full test suite
- Deploy to staging
```

---

## Flags

| Flag | Description | Behavior |
|------|-------------|----------|
| `--epic [id]` | Scope to one epic | Only execute tasks within the specified epic |
| `--until-finish` | Loop until done | Repeat batch cycle until all tasks complete or all remaining are blocked |
| `--resume` | Resume after error | Read `execution-checkpoint.json`, skip `done` tasks, restart from `nextReadyTasks` or last incomplete batch |
| `--dry-run` | Preview only | Show execution plan and batch groupings without running |

### `--until-finish` Behavior

Without `--until-finish`: executes one batch of ready tasks and reports.
With `--until-finish`: continuously identifies ready tasks, spawns batches, collects results, and repeats until the entire roadmap is complete or all remaining tasks are blocked.

This is the **parallel** equivalent of `/execute-task --until-finish` (which runs sequentially).

---

## Error Handling

**If subagent fails:**
1. Task marked as `blocked` in roadmap
2. Error details captured
3. Dependent tasks remain blocked
4. Continue with independent tasks in same batch
5. Report all failures at end of batch

**File Conflict Prevention:** Use `sdd.touchedFiles` when present. Tasks with overlapping `touchedFiles` must run in separate batches (sequential). When `touchedFiles` is missing, infer from task description or run sequentially if uncertain. Never run two implementation tasks in parallel that may edit the same files.

**Recovery:**
```
/execute-parallel [project] --resume
```
1. Read `specs/todo-roadmap/[project-id]/execution-checkpoint.json` if present
2. Skip all tasks with status `done`
3. Use `nextReadyTasks` from checkpoint, or recompute from roadmap
4. Continue execution from the next batch

Checkpoint is written after each batch during `--until-finish` runs.

---

## Related

- `/sdd-full-plan` — Create roadmap with DAG
- `/execute-task` — Execute single task sequentially
- `sdd-orchestrator` subagent — Detailed orchestration logic
- `docs/agent-manual.md` — Full agent protocol
