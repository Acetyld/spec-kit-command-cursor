# Spec-Driven Development Guidelines v6.0

## Overview

This project follows **Agentic-First Spec-Driven Development (SDD)** methodology. All slash commands are direct agent instructions that you (the AI) execute using Cursor's native tools.

## Agentic-First Architecture

### Core Principles

1. **Slash commands are agent instructions** - Not descriptions, but direct instructions to you
2. **State assertions required** - Every command starts with declaring your mode and boundaries
3. **Self-correction protocol** - Built-in mistake detection and recovery
4. **Plan-approve-execute pattern** - Show plans before creating files

### Every Command Template Contains

| Component | Purpose |
|-----------|---------|
| **Role Declaration** | "You are a [role]. Your job is [purpose]." |
| **State Assertion** | Output mode, purpose, implementation status |
| **Mode Boundaries** | What you WILL and WILL NOT do |
| **Self-Correction** | Mistake detection and recovery protocol |
| **Checkpoints** | Verification gates before completion |
| **Literal Output** | Exact format for final output |

### Self-Correction Protocol

When you detect a mistake:

```
DETECT: If you find yourself doing [mistake type]...
STOP: Immediately halt the incorrect action
CORRECT: Output "I apologize - I was [mistake]. Let me return to [correct mode]."
RESUME: Return to the correct workflow
```

Common mistakes to detect:
- Writing implementation code in planning mode
- Skipping the plan presentation
- Not asking clarifying questions
- Making assumptions without informing user
- Claiming features don't exist without checking

## Subagent Architecture

### Subagent Mapping

| SDD Command | Primary Subagent | Mode |
|-------------|-----------------|------|
| `/sdd-research` | `sdd-explorer` | foreground, readonly |
| `/sdd-brief`, `/sdd-specify`, `/sdd-plan`, `/sdd-tasks` | `sdd-planner` | foreground, readonly |
| `/sdd-implement`, `/sdd-execute-task` | `sdd-implementer` | foreground |
| `/sdd-audit` | `sdd-reviewer` | foreground, readonly |
| `/sdd-execute-parallel` | `sdd-orchestrator` | background |

### Subagent Tree

Two-level nest only. Parent (main or orchestrator) spawns implementers, then **sibling** verifiers. Implementer never spawns verifier. See `docs/agent-manual.md`.

## Plan-approve-execute (not Cursor Plan mode)

SDD shows a preview and uses AskQuestion. Do **not** SwitchMode to Cursor Plan / Build.

### Universal Workflow Pattern

```
User Command → Analysis (Readonly) → Create Plan → User Approval → Execute → Document
```

### Four Phases

**Phase 1: Analysis (Readonly)**
- Read relevant files and context
- Ask clarifying questions if needed
- Analyze what needs to be done
- No file modifications

**Phase 2: Planning (Show Plan)**
- Present detailed plan
- Explain reasoning and approach
- Show structure and content preview
- Wait for user approval

**Phase 3: Execution (After Approval)**
- Create or modify files as planned
- Follow templates and guidelines
- Track progress continuously

**Phase 4: Verification**
- Verify files were created
- Update tracking files
- Present completion summary

## Workflow Phases

### Lightweight Path (80% of features)

#### `/sdd-brief` - 30-Minute Planning
- **Purpose**: Quick planning for rapid development
- **Output**: `feature-brief.md`
- **Use for**: Standard features, clear requirements

#### `/sdd-evolve` - Living Documentation
- **Purpose**: Update specs during development
- **Output**: Updated brief with changelog
- **Use for**: Discoveries, refinements

#### `/sdd-refine` - Interactive Refinement
- **Purpose**: Iterate on specs through discussion
- **Output**: Refined documentation
- **Use for**: Improving existing specs

### Full Planning Path (20% of features)

#### `/sdd-research` → `/sdd-specify` → `/sdd-plan` → `/sdd-tasks` → `/sdd-implement`

For complex, high-risk, or multi-team features:
- Multiple teams involved
- Architectural changes required
- High business risk/compliance needs
- 3+ week development timeline

### New Commands

#### `/sdd-generate-prd` - PRD Generation
Create Product Requirements Documents through Socratic questioning.
- **Output**: `full-prd.md` + `quick-prd.md`
- **Use for**: New products, major features

#### `/sdd-audit` - Spec-Driven Audit
Investigate issues by comparing code against specs.
- **Output**: Audit report with severity ratings
- **Use for**: Bug investigation, code review, spec compliance

#### `/sdd-generate-rules` - Coding Rules
Auto-generate Cursor rules based on tech stack detection.
- **Output**: `.cursor/rules/*.mdc` files
- **Use for**: New projects, establishing conventions

#### `/sdd-memory` - Configure Memory Backend
Choose how SDD remembers project knowledge across sessions.
- **Providers**: `standard` (rules-only, default), `cursor-native` (Cursor 3.8 Memories), `mem0` (free self-host semantic memory)
- **Output**: updated `.sdd/config.json` `memory` block
- **Use for**: Enabling long-term recall of decisions, conventions, and gotchas
- **Skill**: `sdd-memory` recalls before planning/sdd-implementing and persists durable discoveries after. Never stores secrets. No-op for `standard`.

### Native Review & Cloud (Cursor 3.8)

- **`/review`** (or `/review-bugbot` / `/review-security`) — run Bugbot + Security Review before pushing; `sdd-reviewer` and `/sdd-audit` fold the findings in and add the spec-compliance verdict.
- **`/in-cloud`** — run long-running or risky tasks on an isolated cloud VM + branch; **`/autopilot`** drives a PR to merge-ready remotely. `.cursor/environment.json` speeds cloud startup.

### Project Planning

#### `/sdd-full-plan` (or `/sdd-full-plan`)
Create comprehensive A-to-Z project roadmap.
- **Output**: Kanban board in `specs/todo-roadmap/`
- **Use for**: Full applications, major systems

#### `/sdd-execute-task`
Execute specific task from roadmap.
- **Output**: Varies by task type
- **Use for**: Roadmap task execution

## Directory Structure

```
specs/
├── 00-overview.md              # Project-wide specifications
├── active/                     # Features in development
│   └── [task-id]/
│       ├── feature-brief.md    # Lightweight brief
│       ├── research.md         # Full planning: research
│       ├── spec.md             # Full planning: specification
│       ├── plan.md             # Full planning: technical plan
│       ├── tasks.md            # Full planning: task breakdown
│       ├── todo-list.md        # Implementation checklist
│       └── progress.md         # Development tracking
├── todo-roadmap/               # Project roadmaps
│   └── [project-id]/
│       ├── roadmap.json        # Kanban board data
│       ├── roadmap.md          # Human-readable view
│       ├── tasks/              # Individual task files
│       └── execution-log.md    # Execution tracking
├── completed/                  # Delivered features
└── backlog/                    # Future features

Plugin (Cursor loads these — not under the app repo `.cursor/`):

plugins/spec-kit-command-cursor/
├── agents/                     # sdd-explorer, planner, implementer, verifier, reviewer, orchestrator
├── commands/                   # slash commands (brief, research, specify, sdd-plan, implement, …)
├── skills/                     # sdd-research, planning, implementation, audit, evolve, memory
├── rules/sdd-system.mdc
├── hooks/                      # optional fail-open subagentStop + stop
└── docs/agent-manual.md        # spawn protocol (source of truth)

App repo `.cursor/` only has optional worktrees.json, environment.json, and /sdd-generate-rules output.
├── environment.json            # Cloud agent environment setup (3.7+)
└── sandbox.json                # Network access controls
```

## Task ID Convention

- **Use semantic slugs**: `user-auth-system`, `payment-integration`, `dashboard-redesign`
- **Avoid generic numbering**: `feat-001` (legacy approach)
- **Focus on meaningful, searchable identifiers**

## Quality Standards

### Specifications Should Include
- Clear user stories with acceptance criteria
- Business requirements and constraints
- Success metrics
- Edge cases and error scenarios
- Out of scope items

### Plans Should Include
- Architecture diagrams
- Technology stack with rationale
- Data models and API contracts
- Security and performance considerations
- Risk assessment

### Tasks Should Include
- Clear, actionable descriptions
- Estimated effort
- Dependencies
- Acceptance criteria

## Implementation Rules

**CRITICAL FOR AI ASSISTANTS:**
Todo-lists are NOT suggestions - they are executable checklists that MUST be followed systematically.

### Todo Execution Rules
1. **Read entire list** before starting
2. **Execute in order** - respect dependencies
3. **Mark completion**: `- [ ]` → `- [x]`
4. **Document blockers** - never skip silently
5. **Update progress** continuously

### Anti-Patterns to Avoid
- Skipping tasks without explanation
- Marking items done without completing them
- Implementing differently than planned without noting it
- Not updating checkboxes after completing work

## Best Practices

1. **Choose the right starting point:**
   - `/sdd-brief` - For 80% of features
   - `/sdd-full-plan` - For full applications
   - `/sdd-research` + `/sdd-specify` - For complex features

2. **Heavy App Path** (new apps with 20+ tasks, enterprise complexity):
   - Start with `/sdd-full-plan [project-id] [description]`
   - For 40+ tasks: Use **Option C: Phased Creation** — create epics one at a time, approve each, optionally execute or continue
   - Execute with `/sdd-execute-parallel [project-id] --until-finish`
   - Resume after interruption: `/sdd-execute-parallel [project-id] --resume`

3. **Keep specs updated with `/sdd-evolve`**

4. **Use `/sdd-refine` for iterative improvements**

5. **Upgrade when complexity emerges with `/sdd-upgrade`**

6. **Use `/sdd-audit` to investigate issues systematically**

7. **Generate coding rules for new projects with `/sdd-generate-rules`**

## Spec Archival Workflow

When a feature is fully implemented, verified, and merged (or already live):

Run **`/sdd-complete [task-id]`**. That command:

1. Marks Status Complete and ticks shipped Next Actions
2. Moves `specs/active/[task-id]` → `specs/completed/[task-id]`
3. Updates `specs/index.md` if present

Do not leave a shipped feature in `specs/active/`. `/sdd-implement` must AskQuestion to archive when todos are done.

**When to archive:**
- All acceptance criteria met
- Code merged to main branch
- No pending review items

**Do not archive if:**
- Feature is partially complete (keep in `active/`)
- Follow-up work is planned (keep in `active/`, create new tasks)

## References

- **System Rules**: plugin `rules/sdd-system.mdc`
- **Agent Manual**: plugin `docs/agent-manual.md`
- **Roadmap Spec**: `.sdd/ROADMAP_FORMAT_SPEC.md`
