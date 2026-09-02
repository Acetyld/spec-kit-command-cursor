# Tasks: [FEATURE NAME]

**Input**: `specs/active/[task-id]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/
**Tests**: Include test tasks only if the spec or user requested TDD.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallel (different files, no unfinished deps)
- **[Story]**: [US1], [US2], … on user-story phase tasks only
- Include exact file paths

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: MUST complete before any user story

- [ ] T004 Setup shared infrastructure required by all stories

**Checkpoint**: Foundation ready — user stories may start

---

## Phase 3: User Story 1 - [Title] (Priority: P1)

**Goal**: [What this story delivers]
**Independent Test**: [How to verify alone]

- [ ] T010 [P] [US1] [Work with file path]

**Checkpoint**: US1 independently testable

---

## Phase N: Polish & Cross-Cutting Concerns

- [ ] TXXX [P] Documentation updates
- [ ] TXXX Run quickstart.md validation

## Dependencies & Execution Order

- Setup → Foundational (blocks all stories) → User stories (P1 → P2 → …) → Polish
- `[P]` tasks may run in parallel (disjoint files)
