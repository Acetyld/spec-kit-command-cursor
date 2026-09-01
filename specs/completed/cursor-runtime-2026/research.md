# Research: Cursor Runtime Alignment for Spec-Kit (2026)

## Summary

Cursor 2.5–3.x already ships the primitives spec-kit wraps in prompts: plugins, async/nested subagents, skills, hooks, worktrees, cloud VMs, native review, automations, custom modes, `/goal`, `/loop`, `/autopilot`, and isolated per-subagent environments. Spec-kit 6.0.5 is a strong **workflow layer** (specs, DAG, verify-after-implement) but it is **one Cursor generation behind** on naming, APIs, and hard platform limits. The highest-leverage fix is to stop reinventing a second runtime and bind SDD to the current Task / plugin / hook surface.

**Research mode:** Deep  
**Confidence:** High  
**Last verified:** 2026-09-01

---

## Codebase Analysis

### Existing Patterns

| Pattern | Location | Relevance |
|---------|----------|-----------|
| Cursor Plugin (convention discovery) | `plugins/spec-kit-command-cursor/.cursor-plugin/plugin.json` | Identity-only manifest; no `logo`, `homepage`, `hooks`, `variables` |
| Custom subagents | `plugins/spec-kit-command-cursor/agents/*.md` | 6 agents; `model: inherit`; implementer + orchestrator `is_background: true` |
| Slash commands | `plugins/spec-kit-command-cursor/commands/*.md` | 19 commands; only 2 have YAML frontmatter |
| Skills | `plugins/spec-kit-command-cursor/skills/*/SKILL.md` | Progressive loading is good; missing `icon`/`color`/`paths` |
| Always-on rule | `plugins/spec-kit-command-cursor/rules/sdd-system.mdc` | Correct plugin placement; still says `/babysit` |
| Cloud / worktree stubs | `environment.json`, `worktrees.json` | Toolkit-repo no-ops; not generated from app stack |
| Marketplace | `.cursor-plugin/marketplace.json` | Valid multi-plugin repo; marketplace version `0.0.6` vs plugin `6.0.5` |
| Memory wrapper | `skills/sdd-memory/` | `CallMcpTool` is stale; current runtime is `CallDynamicTool` |

### Reusable Components

- **DAG + `touchedFiles` + checkpoint** in `/execute-parallel` — keep. This is the product. Cursor does not ship roadmap state.
- **Verifier vs reviewer split** — keep. Maps cleanly onto Cursor's own "verification agent" example plus native Bugbot/Security Review.
- **AskQuestion-first protocol** — keep for user decisions. Do not move those turns into background subagents.
- **Skill `references/` + `scripts/`** — already matches Agent Skills progressive loading.

### What the plugin actually is

Prompt-only Marketplace package. No MCP, no hooks, no runtime code. Cursor discovers `agents/`, `commands/`, `skills/`, `rules/` by folder convention. `/sdd-init` only scaffolds project `.sdd/` + `specs/` and optional `.cursor/worktrees.json` + `.cursor/environment.json`.

---

## How Cursor plugins work (official, 2026)

**Sources:** [Plugins](https://cursor.com/docs/plugins), [Plugins reference](https://cursor.com/docs/reference/plugins), [Customize](https://cursor.com/docs/customize-cursor)

### Two formats

| Format | Manifest | Ships |
|--------|----------|-------|
| **Agent Plugins** (open standard) | `plugin.json` at plugin root | Skills + MCP only. Portable to other clients. |
| **Cursor Plugins** (what we are) | `.cursor-plugin/plugin.json` | Skills, MCP, **rules, agents, commands, hooks, variables** |

Stay on Cursor Plugins. Do not convert to Agent Plugins — we need agents, commands, and rules.

### Discovery

If the manifest omits path fields, Cursor scans:

| Component | Default |
|-----------|---------|
| Skills | `skills/*/SKILL.md` |
| Rules | `rules/*.{md,mdc,markdown}` |
| Agents | `agents/*.{md,mdc,markdown}` |
| Commands | `commands/*.{md,mdc,markdown,txt}` |
| Hooks | `hooks/hooks.json` |
| MCP | `mcp.json` |

Explicit `"skills": "./foo/"` **replaces** default discovery (does not merge). Our identity-only manifest is valid.

### Manifest fields we do not use

`logo`, `homepage`, `repository`, `license`, `hooks`, `mcpServers`, `variables` (JSON Schema for `${VAR}` secrets; users set values in Plugins → Configure).

### Team / marketplace

- Official Marketplace: public git repo + [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish), manual review, must be open source.
- Team marketplaces: Default Off / Default On / **Required**. Auto-refresh from GitHub (max every 10 min).
- Local test: `~/.cursor/plugins/local/<name>` or symlink. Enterprise local imports default **off**.
- **Plugin canvases**: prebuilt shared setup templates opened from Customize (Hex, Atlassian). We have none.
- `workspaceOpen` hook can return extra plugin paths per workspace.

### Commands vs skills (official guidance)

- **Command**: one-shot `/` prompt. Frontmatter `name` + `description` for the menu.
- **Skill**: auto-invoked by description, or `/skill-name`. Can be pinned as a **Custom Mode** (⌥⏎ / Alt+Enter) for the whole session.
- `/migrate-to-skills` converts slash commands into skills with `disable-model-invocation: true`.
- Official anti-pattern: **do not duplicate a slash command as a subagent** if the task is single-purpose and does not need a new context window.

---

## Subagents — what Cursor actually supports

**Source:** [Subagents](https://cursor.com/docs/subagents) (fetched 2026-09-01)

### Built-in (always on, no config)

| Subagent | Role | Why it exists |
|----------|------|----------------|
| **Explore** | Codebase search | Fast model, many parallel searches, dumps stay out of main context |
| **Bash** | Shell series | Verbose logs isolated |
| **Browser** | Browser MCP | DOM/screenshots filtered |

`sdd-explorer` overlaps Explore. Keep it only if the SDD output contract (patterns, specs/, memory recall) is worth the extra agent. Otherwise route research through built-in Explore + `sdd-research` skill.

### Custom agent schema (plugin `agents/*.md`)

| Field | Default | Notes |
|-------|---------|-------|
| `name` | filename | kebab-case |
| `description` | — | **Delegation signal.** Phrases like "use proactively" / "always use for" matter. |
| `model` | `inherit` | Or exact ID. Bracket params: `claude-opus-5[effort=high,context=300k]`, `composer-2.5[fast=false]` |
| `readonly` | `false` | No file edits, no state-changing shell |
| `is_background` | `false` | Non-blocking. Override per-call with Task `run_in_background` |

**There is no `tools:` allowlist.** Subagents inherit parent tools (including MCP), except `readonly` and team policy. Cloud subagents use **team** MCP at cursor.com/agents, not local MCP.

### Parallelism (native)

- Multiple `Task` calls in **one message** → concurrent subagents.
- Parent can keep working if children are background.
- **Await** tool (Cursor 3.0): wait for background shell **or** subagents; optional output match (`Ready`, `Error`).
- Background state: `~/.cursor/subagents/`. Parent can read progress. Resume by **agent ID**.
- Token cost: N parallel subagents ≈ N× tokens. Docs: don't use them for small edits.

### Isolated copies (Aug 19, 2026) — High confidence, unused by us

> "Run a swarm of subagents … each in its own environment"

Each subagent gets its **own worktree + branch** locally, or its **own cloud VM + clone**. Parent merges later. This is the native replacement for a large part of our hand-rolled `touchedFiles` serialization — keep `touchedFiles` for **same-checkout** batches; use isolation when tasks would collide.

### Cloud handoff (official names)

| Official | What it does | Spec-kit today |
|----------|--------------|----------------|
| `/in-cloud` | Next task runs as cloud subagent (own VM + branch) | Documented |
| `/autopilot` | Cloud agent drives a PR to merge-ready (CI, comments, conflicts) | We still say **`/babysit`** — **wrong name** |
| Task `environment: "cloud"` + `cloud_base_branch` | Programmatic cloud spawn | **Never documented in plugin** |
| Cloud Builds + `.cursor/environment.json` | Warm VMs (`install` at build time, `start`/`terminals` at boot) | Stub `echo` install |

Cloud MCP ≠ local MCP. Cloud hooks: command-based only, from **repo** `.cursor/hooks.json` (not `~/.cursor/hooks.json`).

### CRITICAL: nesting limit

Official FAQ (2026-09-01):

> The main agent and its **direct** subagents can launch subagents, but a subagent launched by another subagent **can't** launch further ones.

Depth:

```
main (0)  →  can spawn
  child (1)  →  can spawn
    grandchild (2)  →  CANNOT spawn
```

**Advertised SDD tree is illegal:**

```
main → sdd-orchestrator (1) → sdd-implementer (2) → sdd-verifier (3)  ✗
```

**Legal shapes:**

```
main → implementer (1) → verifier (2)                         ✓
main → orchestrator (1) → implementer (2)
      → orchestrator (1) → verifier (2)   [siblings]          ✓
main implements; no orchestrator Task                         ✓
```

Also: nested spawn needs Task tool in the current mode; hooks/policies can block it. Stopping the parent stops children (2.5).

---

## Skills, custom modes, hooks, review

### Skills frontmatter we ignore

| Field | Why it matters |
|-------|----------------|
| `paths` | Only surface skill when matching files are in play (e.g. `specs/**`) |
| `disable-model-invocation` | Slash-command-only (good for `/sdd-complete`-like skills) |
| `icon` + `color` | Custom Mode badge (beaker, shield, rocket, …) |
| `globs` | Legacy; use `paths` |

**Custom Modes (Aug 19, 2026):** any skill can stay pinned for the whole session. This is the right UX for `sdd-implementation`, `sdd-planning`, `sdd-audit` — "always-on playbook" instead of hoping auto-invoke fires every turn.

### Built-in skills we should call, not re-prompt

`/review`, `/review-bugbot`, `/review-security`, `/automate`, `/autopilot`, `/loop`, `/goal`, `/create-subagent`, `/create-skill`, `/create-hook`, `/create-rule`, `/worktree`, `/best-of-n`, `/apply-worktree`, `/split-to-prs`, `/canvas`, `/migrate-to-skills`.

Task types already in this runtime: `bugbot`, `security-review`, `best-of-n-runner`, `cursor-guide`, `ci-investigator`. `/audit` should **Task-spawn** `bugbot` + `security-review`, then fold into `sdd-reviewer`. Telling the agent to "type `/review`" is a wrapper around a tool it already has.

### Hooks (we deleted them)

Official events useful to SDD:

- `subagentStart` / `subagentStop` — gate Task spawn; persist structured results
- `stop` — session end: offer `/sdd-complete`, write progress
- `afterFileEdit` — format / staleness
- `beforeSubmitPrompt` — inject active spec path
- `workspaceOpen` — load extra plugins per app repo
- `preCompact` — flush todo/checkpoint before context wipe

Cloud agents run the same command hooks from `.cursor/hooks.json`. Docs explicitly: **"If you need subagents to produce structured output files, use hooks."**

We dropped `stop`/`subagentStop` on purpose. Re-adding a **small, optional** plugin hook pack (not always-on logging) is the native way to enforce verify-after-implement without a third-level spawn.

### Worktrees

- Agents Window: UI-native isolation; reads `.cursor/worktrees.json`.
- IDE: `/worktree`, `/best-of-n`, `/apply-worktree`, `/delete-worktree`.
- CLI: `--worktree`.
- Setup keys: `setup-worktree`, `setup-worktree-unix`, `setup-worktree-windows`. `$ROOT_WORKTREE_PATH` for copying `.env`.
- Cursor 3.5+: auto-cleanup (`cursor.worktreeMaxCount` default 25). `/best-of-n` does **not** merge; user picks a winner.

Our `worktrees.json` only `mkdir`s `specs/`. For app repos, `/sdd-init` should detect the package manager and write a real setup (docs warn: do **not** symlink `node_modules`).

---

## Timeline of what we claim vs what shipped

| When | Cursor feature | Spec-kit 6.0.5 |
|------|----------------|----------------|
| 2.5 (2026-02-17) | Plugins, async subagents, nested trees, sandbox.json | Adopted (prompts) |
| 3.0 (2026-04-02) | Agents Window, `/worktree`, `/best-of-n`, **Await**, Design Mode, cloud removed from Editor | Worktrees mentioned; Await unused; `/best-of-n` unused |
| 3.8 (2026-06-18) | Automations, `/automate`, GH/Slack triggers, computer use | "Requires 3.8+" badge; **no automations** |
| 2026-08-03 | Gmail / Drive / Calendar plugins | n/a |
| 2026-08-13 | Cloud **Builds** (warm `install`) | `environment.json` is `echo` |
| 2026-08-17 | Origin repos + in-Cursor PRs | n/a |
| 2026-08-19 | Skill **Custom Modes**, **VM-isolated subagents**, `/goal`, PR **subscriptions**, `/autopilot` | Still `/babysit`; no `/goal`; no isolation swarm |
| 2026-08-27 | Origin without GitHub, live preview, Vercel publish | n/a |

"Requires Cursor 3.8+" is the **floor**, not the current platform. Aug 2026 is where parallelism and always-on agents actually landed.

---

## Comparison: SDD vs native Cursor

| Job | Cursor native (use this) | Spec-kit should own |
|-----|--------------------------|---------------------|
| Isolated parallel edits | Worktree / cloud VM per subagent | DAG + `touchedFiles` when sharing one checkout |
| Wait for background work | Await tool | Checkpoint JSON (keep) |
| PR to merge-ready | `/autopilot` + PR subscriptions | Roadmap status updates |
| Mechanical review | Task `bugbot` / `security-review` | Spec-compliance verdict |
| Long-running objective | `/goal` + `/loop` + Custom Mode | `--until-finish` loop (can pair) |
| Always-on playbook | Skill as Custom Mode | Skill body |
| Event-driven work | `/automate` (PR comment, CI fail, Slack) | Optional templates that *call* SDD commands |
| Explore codebase | Built-in Explore | SDD-shaped report (optional) |
| Best-of-N approaches | `/best-of-n` / `best-of-n-runner` | Pick winner → write into spec |
| Structured subagent output | `subagentStop` hook | `progress.md` / checkpoint |
| User decisions | AskQuestion | Keep in **main** agent |
| Spec / DAG / memory of *this feature* | — | **Only SDD** |

---

## Decisions (2026-09-01)

Locked with the user after research. These override earlier "debatable" options.

| Topic | Decision |
|-------|----------|
| `sdd-explorer` | **Keep.** SDD report + `specs/` + memory recall stays a first-class agent. Built-in Explore can still run *under* it for raw search, but we do not delete explorer. |
| Hooks | **Small optional pack** (`subagentStop`, `stop`). Structured verify/checkpoint output only — no noisy logging. |
| Spawn | **Really spawn, and fan out.** Explore / research / plan should launch *multiple* subagents in one message instead of blocking on main. Build: parallel by default on large work (or when asked). AskQuestion stays on **main**. |
| Nest limit | Fan-out is **siblings from main** (or from orchestrator as depth-1). Verifier is a **sibling** of implementer, never a grandchild. |
| This round | Hygiene (names, nest flatten, Task docs, command frontmatter) + **Custom Modes** + **`/goal` on `/implement`** (user already uses `/goal` so implement keeps going until done). Isolated VM swarms and `/automate` recipes: later. |

### Fan-out spawn model (agreed)

```
/research or /brief (main, AskQuestion)
├── sdd-explorer  (area A, readonly)
├── sdd-explorer  (area B, readonly)
└── sdd-explorer  (external / deep, optional)
        → main synthesizes research.md / feature-brief.md

/sdd-plan or /specify (main, AskQuestion)
├── sdd-planner  (API / backend slice)
└── sdd-planner  (UI / data slice)
        → main merges plan.md / spec.md, asks user on conflicts

/implement or /execute-parallel (main or orchestrator @ depth 1)
├── sdd-implementer  (task 1, background)
├── sdd-implementer  (task 2, background)
├── sdd-verifier     (task 1)     ← sibling, after implementer returns
└── sdd-verifier     (task 2)
```

`/implement` should set a **`/goal`** (or instruct the agent to) so the session keeps working until verifier is green — not a single pass that stops at "looks done."

---

## Recommendation

Treat spec-kit as a **spec + DAG + memory workflow on top of Cursor**, not a second agent runtime.

### P0 — correctness (broken or misleading)

1. **Flatten the subagent tree** to respect the 2-level nest limit. Orchestrator (or main) spawns implementer **and** verifier as siblings. Stop telling implementers to spawn verifiers when they are already grandchildren.
2. **Rename `/babysit` → `/autopilot`** everywhere (rules, agents, commands, README).
3. **Document Task primitives** in agent-manual: `environment: "cloud"`, `run_in_background`, `resume`, `bugbot`, `security-review`, `best-of-n-runner`. Stop "type /in-cloud" as the only cloud path.
4. **Really spawn, fan-out.** `/research`, `/brief`, `/specify`, `/sdd-plan` launch multiple sibling subagents in one message; main only synthesizes and AskQuestions. `/implement` fans out on large work and pairs with `/goal`. See Decisions.

### P1 — use the platform (high leverage)

5. **Wire `/audit` to native reviewers** — Task `bugbot` + `security-review`, then `sdd-reviewer` for spec gap analysis.
6. **Skill Custom Modes** — add `icon` + `color` to planning / implementation / audit skills; document pinning with Option+Enter (Mac) / Alt+Enter (Windows).
7. **Isolated swarms in `/execute-parallel`** — when `touchedFiles` overlap or `--isolate`, ask for "each in its own environment" (worktree or `environment: cloud`) instead of serializing the batch.
8. **Await** background implementers instead of busy-loop prose.
9. **Optional plugin hooks** (`subagentStop`, `stop`) to write structured verify results and flush checkpoints on compact/stop.
10. **Command frontmatter** on all 19 commands (`name` + `description`).
11. **Fix memory recipe** (`CallDynamicTool`); mention automation Memories vs Cursor Memories vs rules vs `specs/`.

### P2 — product upgrades (new SDD surface)

12. **`/sdd-init` generates real `environment.json` + `worktrees.json`** from detected stack (install vs start vs terminals; no `echo`).
13. **Automation recipes** via `/automate`: "on PR review comment, run `/audit`"; "on CI fail, `/implement` the failing task"; "on Slack emoji, `/brief`".
14. **`/goal` + Custom Mode** as the blessed `--until-finish` UX: pin `sdd-implementation`, goal = "close this spec until verifier is green".
15. **`/best-of-n` for `/sdd-plan`** competing architectures, then AskQuestion to pick.
16. **Resume subagents** in `/execute-parallel --resume` (agent IDs in checkpoint, not just task status).
17. **Pin explorer model** to a fast ID (or delete `sdd-explorer` and use built-in Explore). Pin planner to high-effort when user asks.
18. **Manifest hygiene:** `logo`, `homepage`, `repository`, bump marketplace version with plugin version; drop `sddVersion: "5.1"` / `planMode: true` from roadmap templates.
19. **Plugin canvas** for first-run (`/sdd-init` walkthrough) if/when canvases are authorable for community plugins.
20. **Do not fight Plan mode** in the product — keep the naming (`/sdd-plan` ≠ `/plan`) but stop shipping PLAN Mode leftovers in `sdd/guidelines.md` and roadmap JSON.

### What not to do

- Do not add 10 more generic subagents. Official anti-pattern. We already have 6; consider **dropping or merging** explorer vs built-in Explore.
- Do not ship an MCP just to look modern. Specs are files; files are the API.
- Do not re-enable noisy always-on hooks. Optional, structured, fail-open.
- Do not wrap `/multitask` as an SDD command. It is native. Point at it.

---

## Risks & Unknowns

| Risk | Confidence | Mitigation |
|------|------------|------------|
| Nesting limit is 2 levels and we document 3 | High (official FAQ) | Flatten tree; add a one-line test in verifier protocol |
| `/babysit` may still work as alias | Low | Grep + try `/autopilot`; keep alias one release if needed |
| AskQuestion availability inside custom subagents | Medium | Keep user Qs on main agent |
| `environment: cloud` from plugin Task vs `/in-cloud` | Medium | Document both; prefer Task param in orchestrator |
| Custom Mode `icon` names are a fixed set | High | Use documented names only |
| Plugin canvases may be first-party-only | Low | Spike after P0 |
| Built-in Explore vs `sdd-explorer` auto-delegate fights | Medium | Tighten descriptions; "always use sdd-explorer for SDD research reports" |
| Cloud MCP gap (local mem0 won't exist in cloud) | High | Cloud path = `standard` or cursor-native only |

**Suggested spike (2–4h):** one `/execute-parallel` batch of 2 implementers + sibling verifiers; confirm grandchild spawn fails; confirm Await + isolate-environment works.

---

## Sources

| # | URL | Type | Reliability | Key finding |
|---|-----|------|-------------|-------------|
| 1 | https://cursor.com/docs/subagents | Official docs | High | Schema, built-ins, parallel, isolation, **nesting limit**, resume, `/in-cloud`, `/autopilot` |
| 2 | https://cursor.com/docs/reference/plugins | Official docs | High | Cursor vs Agent Plugins, discovery, hooks, variables, marketplace |
| 3 | https://cursor.com/docs/plugins | Official docs | High | Team marketplace modes, local test, canvases |
| 4 | https://cursor.com/docs/skills | Official docs | High | Frontmatter (`paths`, `icon`, `color`), Custom Modes, built-in skills |
| 5 | https://cursor.com/docs/hooks | Official docs | High | Event list, cloud support, `subagentStart/Stop`, structured output |
| 6 | https://cursor.com/docs/configuration/worktrees | Official docs | High | `worktrees.json`, `/worktree`, `/best-of-n`, cleanup |
| 7 | https://cursor.com/docs/cloud-agent | Official docs | High | VMs, MCP team config, hooks, artifacts |
| 8 | https://cursor.com/docs/cloud-agent/setup | Official docs | High | `environment.json` `install`/`start`/`terminals`, Builds |
| 9 | https://cursor.com/docs/cloud-agent/automations | Official docs | High | `/automate`, GH/Slack triggers, automation Memories |
| 10 | https://cursor.com/changelog/2-5 | Changelog | High | Plugins + async/nested subagents (2026-02-17) |
| 11 | https://cursor.com/changelog/3-0 | Changelog | High | Agents Window, Await, `/worktree`, `/best-of-n` (2026-04-02) |
| 12 | https://cursor.com/changelog/06-18-26 | Changelog | High | 3.8 Automations (2026-06-18) |
| 13 | https://cursor.com/changelog/08-19-26 | Changelog | High | Custom Modes, VM subagents, `/goal`, subscriptions |
| 14 | https://cursor.com/changelog | Changelog index | High | Origin, Builds, Workspace plugins (Aug 2026) |
| 15 | https://cursor.com/blog/cursor-3 | Blog | High | Agents Window + marketplace positioning |
| 16 | https://cursor.com/docs/customize-cursor | Official docs | High | Single Customize surface for plugins/skills/agents/hooks |
| 17 | Plugin tree via [Explore spec-kit](70c9977f-57a2-4ed1-8ff7-781eee41b3c4) | Codebase | High | 6.0.5 inventory, stale claims, unused Task APIs |

## Confidence Assessment

**Overall confidence:** High  

Official docs + changelog + plugin inventory agree on the platform surface and on the nest-limit / `/autopilot` / unused-API gaps. Remaining unknowns are product choices (keep explorer? re-add hooks?) and a short runtime spike for grandchild spawn + isolate-environment.

**Gaps:** Whether `/babysit` still aliases; whether community plugins can ship canvases; exact Task `environment: cloud` UX from a plugin command.

**Suggested spike:** Flatten one parallel batch and prove verifier-as-sibling + Await + isolate.
