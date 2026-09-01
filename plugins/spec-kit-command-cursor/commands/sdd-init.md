---
name: sdd-init
description: Scaffold .sdd/ and specs/ in the current project so SDD commands have somewhere to write.
---

# /sdd-init Command

First-run setup for a project that installed the SDD plugin. Creates `.sdd/` (config + templates) and `specs/` in **this workspace**, not in the plugin.

**See also:** `docs/agent-manual.md` for full agent protocol.

---

## Role

Scaffold the project-side SDD folders that the plugin does not install (commands, skills, and agents already come from the plugin).

**I WILL:** create `.sdd/` and `specs/` if missing, copy bundled templates when readable, and report what exists.
**I WILL NOT:** overwrite existing specs, change application code, or force-replace a present `.sdd/config.json` unless `--force` is passed.

**Output:** `.sdd/config.json`, `.sdd/templates/`, `specs/{active,completed,backlog,todo-roadmap}/`

---

## Usage

```
/sdd-init
/sdd-init --force
```

---

## Instructions

### 1. Detect the project root

Use the active workspace root. Do not write into the plugin cache or into this toolkit repo unless that *is* the open project.

### 2. Skip when already initialized

If `.sdd/config.json` exists and `--force` was not passed:

```
SDD already initialized at .sdd/config.json
specs/active exists: yes/no
Next: /brief <id> <description>
```

Stop there.

### 3. Create directories

```
specs/active
specs/completed
specs/backlog
specs/todo-roadmap
.sdd/templates
.sdd/templates/rules
```

### 4. Write `.sdd/config.json`

If missing (or `--force`), write this starter and fill `project.name` / `project.description` from the repo when obvious:

```json
{
  "version": "6.0.1",
  "cursorMinVersion": "3.8",
  "project": {
    "name": "PROJECT_NAME",
    "description": "",
    "created": "YYYY-MM-DD"
  },
  "settings": {
    "defaultFeaturePrefix": "feat-",
    "autoNumberFeatures": true,
    "requireReviews": true,
    "collaborationMode": true,
    "defaultWorkflow": "brief",
    "planningTimeLimit": 30,
    "maxParallelImplementers": 4,
    "templates": {
      "brief": ".sdd/templates/feature-brief-v2.md",
      "spec": ".sdd/templates/spec-compact.md",
      "plan": ".sdd/templates/plan-compact.md",
      "tasks": ".sdd/templates/tasks-compact.md",
      "research": ".sdd/templates/research-compact.md",
      "todo": ".sdd/templates/todo-compact.md"
    }
  },
  "memory": {
    "provider": "standard",
    "enabled": false,
    "scope": ["decisions", "conventions", "gotchas", "architecture"],
    "providers": {
      "standard": {
        "description": "Rules-only. No persistent agent memory beyond .cursor/rules and specs/. Zero dependencies (default).",
        "store": null
      },
      "cursor-native": {
        "description": "Cursor 3.8 built-in Memories. Free, zero-setup, managed in the Cursor UI.",
        "store": "cursor-memories"
      },
      "mem0": {
        "description": "mem0 open-source semantic memory. Free self-host via the mem0 MCP server or local API.",
        "store": "mem0",
        "mcpServer": "mem0",
        "config": {
          "apiBaseEnv": "MEM0_API_BASE",
          "apiKeyEnv": "MEM0_API_KEY",
          "userId": "sdd",
          "local": true
        }
      }
    }
  },
  "directories": {
    "specs": "specs",
    "active": "specs/active",
    "completed": "specs/completed",
    "backlog": "specs/backlog"
  },
  "workflow": {
    "phases": ["specify", "plan", "tasks", "implement", "review", "complete"],
    "requiredFiles": ["spec.md", "plan.md", "tasks.md"],
    "optionalFiles": ["progress.md", "reviews.md", "notes.md"]
  }
}
```

### 5. Copy bundled templates

Search in this order and copy the `templates/` tree into `.sdd/templates/` (do not overwrite existing files unless `--force`):

1. `plugins/spec-kit-command-cursor/sdd/templates/` (this repo)
2. Any readable `sdd/templates/` next to the installed plugin (under `~/.cursor/plugins/cache/`)
3. If neither is readable, skip copy — command output formats in `/brief`, `/specify`, `/sdd-plan` are enough to proceed

Also copy `guidelines.md` and `ROADMAP_FORMAT_SPEC.md` into `.sdd/` when found.

### 6. Optional project Cursor files

Only if the file does **not** already exist:

- `.cursor/worktrees.json` — create `specs/active`, `specs/completed`, `specs/todo-roadmap` on worktree setup
- `.cursor/environment.json` — no-op install stub; tell the user to point `install` at their real app bootstrap

Do **not** write `.cursor/sandbox.json` unless asked (too opinionated for other apps).
Do **not** write `.cursor/hooks.json` — SDD hooks ship in the plugin (`hooks/`) and load with the plugin.
Do **not** copy plugin `commands/`, `agents/`, `skills/`, or `rules/` into the project — Cursor already loads those from the plugin.

### 7. Confirm

List created/skipped paths. Then:

```
Ready. Everyday flow: /brief <id> <description>  →  /implement <id>
Complex: /research → /specify → /sdd-plan → /tasks → /implement
Whole app: /sdd-full-plan <id>  →  /execute-parallel <id> --until-finish
Pin sdd-implementation as a Custom Mode (Option+Enter) and use /goal on /implement when available.
Plugin hooks (subagentStop, stop) are optional and already in the plugin — not copied here.
```
