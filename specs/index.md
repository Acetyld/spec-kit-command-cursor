# SDD Features Index

## Navigation

- [Project Overview](00-overview.md)
- [Agent Manual](../plugins/spec-kit-command-cursor/docs/agent-manual.md)

## Feature Status Dashboard

### Active Features (In Development)

| Task ID | Feature | Status | Created |
|---------|---------|--------|---------|
| *none* | — | — | — |

### Completed Features

| Task ID | Feature | Completed |
|---------|---------|-----------|
| cursor-runtime-2026 | Align spec-kit with current Cursor runtime (plugins, subagents, Aug 2026 features) | 2026-09-01 |

### Backlog Features

| Task ID | Feature | Priority |
|---------|---------|----------|
| *none* | — | — |

## Quick Actions

- Create new feature: `/sdd-brief [task-id] [description]`
- Full project roadmap: `/sdd-full-plan [project-id] [description]`
- View active specs: `specs/active/`
- View roadmaps: `specs/todo-roadmap/`

## How Specs Are Created

Each command writes to `specs/active/[task-id]/`:

| Command | Creates |
|---------|---------|
| `/sdd-brief` | `feature-brief.md` |
| `/sdd-research` | `research.md` |
| `/sdd-specify` | `spec.md` |
| `/sdd-plan` | `plan.md` |
| `/sdd-tasks` | `tasks.md` |
| `/sdd-implement` | `todo-list.md` + code |
| `/sdd-evolve` | Updates existing spec files |
| `/sdd-audit` | Audit report (in chat, not saved) |

Project roadmaps go to `specs/todo-roadmap/[project-id]/`.

---
**Version:** SDD 6.0
