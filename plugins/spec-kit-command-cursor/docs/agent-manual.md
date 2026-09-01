# SDD Agent Manual (v6.1)

Consolidated agent protocol for SDD workflows. **Requires Cursor 3.8+.** Aug 2026 primitives (`/goal`, Custom Modes, Task `environment: "cloud"`, Await) are used when present.

**This file is the spawn/nest/cloud source of truth.** Commands, agents, and `rules/sdd-system.mdc` must not invent a second tree.

---

## Core Principles

1. **Plan-approve-execute** — show plans before creating files
2. **Save outputs to `specs/`** — all specs go in the specs directory
3. **Verify file operations** — confirm files were created
4. **Ask when uncertain** — don't guess, clarify
5. **Delegate appropriately** — use subagents for context isolation
6. **Ask via AskQuestion** — never dump A/B/C or numbered questions in chat as a substitute for Cursor's question UI
7. **Never Cursor Plan mode** — SDD `/sdd-plan` writes `specs/active/[task-id]/plan.md`. Do not SwitchMode to `plan`, do not create a Cursor Plan, do not ask the user to press **Build**. Implementation is `/implement`.
8. **Two-level nest only** — main (or orchestrator at depth 1) spawns siblings. Implementer **never** spawns verifier.
9. **Fan-out in one message** — multiple Task calls together. Cap: `.sdd/config.json` `settings.maxParallelImplementers` (default 4).
10. **Children return text** — only the main agent writes `research.md` / `feature-brief.md` / `spec.md` / `plan.md`.

When you need a decision, clarification, or plan approval, call the **AskQuestion** tool in that same turn. One call can hold several questions; each needs at least two options. Chat may introduce *why* you are asking (1–2 sentences). The choices go in the tool. After it returns, continue — do not re-ask in markdown. AskQuestion runs only on the **main** agent.

---

## File System Structure

Two layers:

**Plugin** (Cursor loads these; they are not in the app repo):

```
plugins/spec-kit-command-cursor/
├── agents/ commands/ skills/ rules/ hooks/
├── docs/agent-manual.md
└── sdd/                       # Bundled templates; /sdd-init copies into the project
```

**Project** (created by `/sdd-init` in the app you are working on):

```
specs/
├── 00-overview.md
├── index.md
├── active/[task-id]/
│   ├── feature-brief.md
│   ├── research.md
│   ├── spec.md
│   ├── plan.md
│   ├── tasks.md
│   ├── todo-list.md
│   └── progress.md
├── todo-roadmap/[project-id]/
├── completed/
└── backlog/

.sdd/
├── config.json
└── templates/

.cursor/
├── rules/                     # App conventions from /generate-rules
├── environment.json           # Optional cloud agent setup
└── worktrees.json             # Optional worktree setup
```

If `.sdd/config.json` is missing, run `/sdd-init` (or let `/brief` do it) before writing specs.

Plugin hooks live in `hooks/` and load with the plugin. `/sdd-init` does **not** copy them into `.cursor/hooks.json`.

---

## Subagents

Subagents run in **isolated context**. Use them for operations that would bloat the main conversation.

### Available Subagents

| Subagent | Purpose | Model | Mode |
|----------|---------|-------|------|
| `sdd-explorer` | SDD research report (codebase + specs + memory recall) | inherit | foreground, readonly |
| `sdd-planner` | Architecture / spec slice (returns text) | inherit | foreground |
| `sdd-implementer` | Code generation | inherit | **background** |
| `sdd-verifier` | Validation | inherit | foreground |
| `sdd-reviewer` | Pre-merge code review | inherit | foreground, readonly |
| `sdd-orchestrator` | Coordination | inherit | **background** |

Built-in Cursor **Explore** may be used *inside* `sdd-explorer` for raw search. Do not delete `sdd-explorer`.

### Foreground vs Background

- **Foreground**: Blocks until complete. Use when the parent needs the result now (exploration, planning, verification).
- **Background** (`is_background: true` on the agent, or Task `run_in_background: true`): Returns immediately. Use for long implementations and orchestration.

### Nest limit (Cursor hard rule)

The main agent and its **direct** children can spawn. A grandchild **cannot**.

**Illegal:**

```
main → orchestrator → implementer → verifier
```

**Legal (required):**

```
main  (or orchestrator at depth 1)
├── sdd-implementer  (task 1)
├── sdd-implementer  (task 2)
├── sdd-verifier     (task 1)   ← sibling, after implementer returns
└── sdd-verifier     (task 2)
```

Implementer **never** spawns verifier. The parent that spawned the implementer always spawns the verifier.

### Fan-out

When there are distinct areas (research slices, plan slices, independent todos):

1. Cap at `settings.maxParallelImplementers` (default 4). Same cap for explorers and planners.
2. Send multiple Task calls in **one message**.
3. Do not invent fake slices. One area → one explorer/planner.
4. N parallel subagents ≈ N× tokens.

`/research` and `/brief`: one or more `sdd-explorer` siblings → main writes the file.  
`/specify` and `/sdd-plan`: one or more `sdd-planner` siblings when the split is obvious → main writes the file.  
`/implement`: if ≥5 independent todos or the user asks for parallel → implementer siblings, then verifier siblings. Else one implementer (or main), then one sibling verifier.

### Task fields

| Field | Use |
|-------|-----|
| `subagent_type` | `sdd-explorer`, `sdd-planner`, `sdd-implementer`, `sdd-verifier`, `sdd-reviewer`, `sdd-orchestrator` |
| `prompt` | Slice-specific; tell children **not** to write spec files |
| `model` | omit for inherit |
| `run_in_background` | Override agent default for this call |
| `resume` | Resume a prior agent ID from checkpoint `agentIds` |
| `environment` | `"cloud"` for isolated VM + branch |
| `cloud_base_branch` | Branch the cloud clone starts from |

Built-in Task types (not SDD agents): `bugbot`, `security-review`, `best-of-n-runner`, `explore`. Prefer Task params over telling the user to type a slash command.

**Await:** After background implementers, use the Await tool (if present) instead of a prose wait loop. If Await is missing, collect Task results as they return.

### Delegation Guidelines

**Delegate to subagent when:**
- Deep codebase exploration (`sdd-explorer`)
- Long implementation (`sdd-implementer`)
- Independent tasks in parallel (multiple Tasks)
- Verification (`sdd-verifier`, spawned by **parent**)
- Code review (`sdd-reviewer`)

**Keep in main context when:**
- Simple, quick operations
- AskQuestion / user interaction
- Synthesizing slice results into a spec file

### Native vs plugin commands

| Name | Kind |
|------|------|
| `/sdd-init`, `/brief`, `/research`, `/specify`, `/sdd-plan`, `/tasks`, `/implement`, `/sdd-complete`, `/audit`, `/evolve`, `/refine`, `/sdd-full-plan`, `/execute-task`, `/execute-parallel`, `/sdd-memory` | **Plugin** |
| `/multitask`, `/review`, `/review-bugbot`, `/review-security`, `/goal`, `/autopilot`, `/in-cloud`, `/worktree`, `/best-of-n` | **Native Cursor** — do not list as SDD plugin commands |

`/in-cloud` is the user-facing alias. Orchestrator/implement prompts should set Task `environment: "cloud"` when offloading. `/autopilot` (formerly babysit) drives a PR to merge-ready.

### `/goal` on `/implement`

When `/goal` exists, `/implement` sets a long-lived objective:

```
Complete spec "<title>" in specs/active/<task-id>/ until the sibling sdd-verifier reports complete (or blockers are documented). Do not stop after a single pass.
```

Pair with Custom Mode `sdd-implementation` (Option+Enter / Alt+Enter). If `/goal` is missing, still run todos + sibling verifier.

### Custom Modes

Skills `sdd-planning`, `sdd-implementation`, `sdd-audit`, `sdd-research` have `icon` + `color`. Pin from `/` with Option+Enter (Mac) or Alt+Enter (Windows) so the playbook stays in context for the session.

### Reviewer vs Verifier

| Aspect | `sdd-reviewer` | `sdd-verifier` |
|--------|----------------|----------------|
| **When** | Before merging / `/audit` | After every implementation |
| **Perspective** | Quality, security, performance | Completeness vs spec |
| **Spawned by** | Main or user | **Parent** (main or orchestrator), as a sibling of implementer |
| **Mode** | Readonly | Foreground |

Verifier answers "is it done?", Reviewer answers "is it good?"

---

## Skills

Skills are auto-invoked based on context or manually via `/skill-name`. Pin as a Custom Mode to keep them on.

| Skill | Auto-Invoke When | Custom Mode |
|-------|------------------|-------------|
| `sdd-research` | Technical approach unclear | beaker / purple |
| `sdd-planning` | Spec exists, need plan | book-open / blue |
| `sdd-implementation` | Plan ready for execution | rocket / green |
| `sdd-audit` | Code review requested | shield / orange |
| `sdd-evolve` | Discoveries during dev | — |
| `sdd-memory` | Start/finish of planning or implementation | — |

---

## Memory

SDD long-term memory is **optional and pluggable**, configured in `.sdd/config.json` → `memory` and managed with `/sdd-memory`:

| Provider | Setup | Notes |
|----------|-------|-------|
| `standard` *(default)* | none | Rules-only; relies on `.cursor/rules/` + `specs/`. No persistent store. |
| `cursor-native` | toggle on | Cursor Memories. Needs Privacy Mode off + "Generate Memories" enabled. |
| `mem0` | mem0 MCP / local API | Free self-host. Use `CallDynamicTool` (not `CallMcpTool`). Cloud agents do not see local MCP. |

When `standard`, memory is a no-op. **Never store secrets in memory.**

---

## Native Review

Prefer Cursor's first-party reviewers for mechanical checks, then let SDD agents own spec compliance:

- `/review`, `/review-bugbot`, `/review-security` — or Task `bugbot` / `security-review`
- `sdd-reviewer` and `/audit` add the spec-compliance verdict

---

## Sandbox

Network access controls: `.cursor/sandbox.json` (repo) or `~/.cursor/sandbox.json` (user).

---

## DAG-Based Execution

- **EPIC 0**: Prerequisites
- **dependencies**: Task IDs that must complete first
- **canParallelize** / **parallelGroups**
- **touchedFiles**: overlapping paths → separate batches (isolated VM swarms are out of scope)

### Parallel Execution Pattern

1. Load `roadmap.json` (heavy: only `dag`, `statistics`, current batch)
2. Spawn background implementers in one message (disjoint `touchedFiles`)
3. Await (if available); collect results
4. Parent spawns `sdd-verifier` **siblings** (one per implementer that claimed done)
5. Do not mark roadmap `done` if verifier reports gaps
6. Write `execution-checkpoint.json` including optional `agentIds`
7. Repeat

```
Batch 1 (one message):
├── sdd-implementer (task-001)
├── sdd-implementer (task-003)
└── sdd-explorer (task-005)

After implementers return (siblings):
├── sdd-verifier (task-001)
└── sdd-verifier (task-003)
```

Only the orchestrator writes `roadmap.json`.

Checkpoint:

```ts
{
  lastCompletedBatch, failedTaskId, nextReadyTasks, timestamp, batchNumber,
  agentIds?: { [taskId]: { implementer?: string, verifier?: string } }
}
```

`--resume` may pass Task `resume` when an ID exists; still skip `done` tasks.

---

## Problem Handling

| Problem Type | Action |
|--------------|--------|
| Folder missing | Create it automatically |
| Task not found | Show available options |
| Permission denied | Explain simply, suggest fix |
| Subagent blocked | Report blocker, continue others |
| Verification failed | Report gaps, don't mark done; keep `/goal` open |
| Implementation breaks build | Revert with `git checkout -- [files]`, document blocker |
| Verification fails critically | Revert, status `blocked`, report to parent |
| Context window exhaustion | Save progress to spec files, summarize, new session |
| Concurrent file conflict | Only orchestrator writes `roadmap.json` |
| Hook failure | Fail-open; agent still writes `progress.md` |

**Golden Rules:** Fix small issues yourself. Ask when uncertain. Never leave user stuck. Always verify. When in doubt, revert and retry.

---

## Command-to-Subagent Mapping

| Command | Spawns (when needed) | Skill | Who writes the spec file |
|---------|----------------------|-------|--------------------------|
| `/research` | 1–N `sdd-explorer` | sdd-research | **main** (`research.md`) |
| `/brief` | 1–N `sdd-explorer` | sdd-planning | **main** (`feature-brief.md`) |
| `/specify` | 0–N `sdd-planner` | sdd-planning | **main** (`spec.md`) |
| `/sdd-plan` | 0–N `sdd-planner` | sdd-planning | **main** (`plan.md`) |
| `/tasks` | 0–1 `sdd-planner` | — | **main** (`tasks.md`) |
| `/implement` | implementer(s) then **sibling** verifier(s); `/goal` | sdd-implementation | main (`todo-list.md`) |
| `/sdd-complete` | — | — | — |
| `/audit` | `sdd-reviewer` | sdd-audit | — |
| `/evolve` | — | sdd-evolve | main |
| `/execute-task` | implementer then sibling verifier | varies | — |
| `/execute-parallel` | `sdd-orchestrator` or main as orchestrator | varies | checkpoint |

---

## Best Practices

- Main conversation: decisions and synthesis. Subagents: search and build.
- Multiple Tasks in one message. Cap 4 unless config says otherwise.
- Await background work. Resume by agent ID when checkpoint has it.
- Don't trust "done" without a sibling verifier.
- Recall/persist via `sdd-memory` (no-op for `standard`). Never persist secrets.

---

*SDD Agent Manual v6.1 — two-level nest, fan-out siblings, `/goal`, Custom Modes, Task cloud APIs*
