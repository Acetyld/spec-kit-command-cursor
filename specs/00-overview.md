# Project Overview: SDD Cursor Commands

## Description

A Spec-Driven Development toolkit for Cursor IDE (v3.8+) that provides structured commands, subagents, skills, pluggable memory, and parallel/cloud execution for feature specification, planning, and delivery.

## Core Philosophy

Create specifications **before** code. Plan-approve-execute for all operations.

## Architecture

```
User Request → Main Agent → Subagents (parallel/async) → Skills (auto-invoked)
                    ↓                    ↓
              Verification ←── Subagent Tree (nested spawning)
```

### Components

| Component | Location | Purpose |
|-----------|----------|---------|
| Plugin (commands, agents, skills, SDD rule) | `plugins/spec-kit-command-cursor/` | Loaded by Cursor from the marketplace plugin |
| Project templates + config | `.sdd/` | Created in the app repo by `/sdd-init` |
| Specs | `specs/` | Feature briefs, plans, roadmaps |
| Project rules | `.cursor/rules/` | App conventions from `/sdd-generate-rules` |
| Cloud / worktrees | `.cursor/environment.json`, `.cursor/worktrees.json` | Optional project-level Cursor files |
| Memory | `.sdd/config.json` `memory` | Pluggable backend: standard / cursor-native / mem0 |

## Workflows

| Flow | Commands | Use When |
|------|----------|----------|
| **Everyday feature** | `/sdd-brief` → `/sdd-implement` | Most work |
| **Complex / high-risk** | `/sdd-research` → `/sdd-specify` → `/sdd-plan` → `/sdd-tasks` → `/sdd-implement` | New architecture, auth, payments |
| **Whole app** | `/sdd-full-plan` → `/sdd-execute-parallel --until-finish` | New project or 20+ tasks |

## Spec Directory Structure

```
specs/
├── 00-overview.md              # This file
├── index.md                    # Navigation and status
├── active/[task-id]/           # Features in development
│   ├── feature-brief.md        # Quick Planning output
│   ├── research.md             # /sdd-research output
│   ├── spec.md                 # /sdd-specify output
│   ├── plan.md                 # /sdd-plan output
│   ├── tasks.md                # /sdd-tasks output
│   ├── todo-list.md            # /sdd-implement creates this
│   └── progress.md             # Development tracking
├── todo-roadmap/[project-id]/  # /sdd-full-plan output
│   ├── roadmap.json            # DAG-based task graph
│   ├── roadmap.md              # Human-readable view
│   └── tasks/                  # Individual task files
├── completed/                  # Delivered features (moved from active/)
└── backlog/                    # Future features
```

## Links

- [Feature Index](index.md)
- [Agent Manual](../plugins/spec-kit-command-cursor/docs/agent-manual.md)
- [System Rule](../plugins/spec-kit-command-cursor/rules/sdd-system.mdc)

---
**Version:** SDD 6.0 | **Requires:** Cursor 3.8+
