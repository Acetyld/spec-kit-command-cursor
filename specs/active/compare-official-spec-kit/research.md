# Research: Official Spec Kit vs this Cursor plugin

**Task ID:** compare-official-spec-kit
**Date:** 2026-09-02
**Status:** Complete
**Research mode:** Deep
**Last verified:** 2026-09-02

---

## Executive Summary

The official product is **GitHub Spec Kit** (`github/spec-kit`), not Google. It shipped **1.0.0 on 2026-08-21** (~133k stars). Google shows up only as **supported agents** (Gemini CLI, Jules). Install is `specify-cli` (`uv tool install specify-cli`); it drops commands/skills into whichever agent you pick, including Cursor.

This repo is **the same family, not the same product**. We share the original spine — specify → plan → tasks → implement — and the idea that Markdown artifacts drive the agent. Official Spec Kit has grown into a **multi-agent process harness** (constitution, clarify, checklist, analyze, converge, extensions, presets, `.specify/`). We grew into a **Cursor-only marketplace plugin** (`/sdd-brief`, `/sdd-research`, `/sdd-complete`, `/goal`, DAG orchestrator, memory).

**Closeness:** same process DNA, drifted far on packaging and quality gates. We look like a 2025 four-step kit plus Cursor extras. Official 1.0 looks like that kit plus a year of product around it.

**Recommendation:** do **not** replace this plugin with a blind `specify init --integration cursor-agent`. Decide per gap whether to adopt official commands (especially constitution / analyze / converge) or keep our Cursor-native path. Official `/speckit.implement` still allows **phased** runs for large features; we just made `/sdd-implement` mean finish the whole spec.

---

## Codebase Analysis

### Existing Patterns

#### Happy-path commands

**Location:** `plugins/spec-kit-command-cursor/commands/` (19 command files)

**How it works:** Cursor Marketplace plugin. User runs slash commands. Main agent writes files under `specs/active/[task-id]/`.

**Everyday path (README):** `/sdd-init` → `/sdd-brief` → `/sdd-implement` → `/sdd-complete`

**Complex path:** `/sdd-research` → `/sdd-specify` → `/sdd-plan` → `/sdd-tasks` → `/sdd-implement` → `/sdd-complete`

**Reusability:** This is the product to compare. Command names do not use the `speckit.` prefix.

#### Artifacts we produce

**Location:** `specs/active/[task-id]/` plus project `.sdd/`

| Artifact | Command |
|----------|---------|
| `research.md` | `/sdd-research` |
| `feature-brief.md` | `/sdd-brief` |
| `spec.md` | `/sdd-specify` |
| `plan.md` | `/sdd-plan` (not Cursor Plan mode) |
| `tasks.md` + full `todo-list.md` | `/sdd-tasks` |
| code + checkbox updates | `/sdd-implement` (6.0.6: finish the spec) |
| `specs/completed/` | `/sdd-complete` |
| `roadmap.json` | `/sdd-full-plan` |

**Missing here (official has them):** `constitution.md`, `.specify/feature.json`, `checklists/requirements.md`, `/clarify`, `/analyze`, `/converge`.

#### `/sdd-implement` after 6.0.6

**Location:** `plugins/spec-kit-command-cursor/commands/sdd-implement.md`

**How it works:** Expand every `tasks.md` item into `todo-list.md`. Keep going after each phase. “Complete” only when the whole list is closed. Forced pause must say `Reply continue` or `/sdd-implement [id]`.

**Reusability:** Opposite of official’s documented large-feature advice (scope one phase per run). Same intent as official’s small-feature “run once to build everything.”

#### Cursor-only runtime layer

**Location:** `docs/agent-manual.md`, `rules/sdd-system.mdc`, `agents/`

**How it works:** Two-level nest, sibling `sdd-verifier`, `/goal`, Custom Modes, `maxParallelImplementers`, optional memory, `/sdd-execute-parallel`.

**Reusability:** Official Spec Kit does not own this. Their Cursor integration is `specify init --integration cursor-agent` installing **skills** under `.cursor/skills/speckit-*/SKILL.md` (PR #2156), not a marketplace plugin.

### Reusable Components

- Command/skill/agent layout in `plugins/spec-kit-command-cursor/` — keep if we stay Cursor-plugin
- `specs/` + `.sdd/config.json` — our project scaffold; official uses `.specify/`
- `/sdd-audit` + `sdd-verifier` — closest to official `/speckit.converge` + `/speckit.analyze`
- `/sdd-refine` + AskQuestion in `/sdd-specify` — closest to `/speckit.clarify`
- `/sdd-init` — closest to `specify init` but Cursor-plugin-only

### Conventions to Follow

- We renamed `/plan` → `/sdd-plan` to avoid Cursor Plan mode. Official still says `/speckit.plan`.
- Main writes spec files; children return text (v6.1 nest rule). Official does not specify Cursor nest.
- No `constitution.md` in this plugin. Principles live in `.cursor/rules/` and `.sdd/` templates.

### Lineage

This repo (`madebyaris/spec-kit-command-cursor`, fork `Acetyld/...`) is a **Cursor command port of the SDD idea**, not a git fork of `github/spec-kit`. README never says “fork of GitHub Spec Kit.” Shared vocabulary (`/sdd-specify`, `/sdd-tasks`, `/sdd-implement`, `spec.md` / `plan.md` / `tasks.md`) is the overlap.

---

## External Solutions

### Option 1: GitHub Spec Kit (official)

**What it is:** MIT toolkit + `specify-cli`. Agent-agnostic harness. Core SDD plus extensions/presets/workflows/bundles. v1.0.0 on 2026-08-21. Docs last updated 2026-08-21.

**Pros:**
- Same core loop we already teach
- `/speckit.implement` is documented as “build everything” (small) or scoped phases (large)
- `/speckit.converge` appends missing tasks until the codebase matches the spec
- Constitution + clarify + checklist + analyze are real quality gates
- Cursor is a first-class integration (skills under `.cursor/skills`)
- 38 agents, 157 extensions, 33 presets — not Cursor-locked

**Cons:**
- Different on-disk layout (`.specify/`, numbered feature dirs, `feature.json`)
- Command prefix `/speckit.*` — would collide or confuse next to our `/sdd-specify`
- Official implement **encourages stopping per phase** on large work (the bug we just fixed on our side)
- Not a marketplace plugin; `specify init` mutates the app repo
- No `/sdd-brief`, `/sdd-research`, `/sdd-complete` archive, or our DAG orchestrator

**Fit:** High as the **reference process**. Medium as a drop-in replacement for this plugin.

**Source:** https://github.com/github/spec-kit · https://github.github.com/spec-kit/ · https://github.github.com/spec-kit/quickstart.html

### Option 2: Stay on this Cursor plugin (current)

**What it is:** Marketplace plugin, SDD 6.0.6, Cursor 3.8 nest/`/goal`/review.

**Pros:**
- Already installed in our workflow
- Cursor-safe names (`/sdd-plan`)
- `/sdd-implement` now means finish the spec
- Extra planning (`/sdd-research`, `/sdd-brief`) and close (`/sdd-complete`)

**Cons:**
- No constitution, analyze, converge, official checklists
- Cursor-only; no `specify-cli` upgrade path
- Drifted from the 133k-star kit users will google
- We re-invent gates official already shipped

**Fit:** High for “keep shipping Cursor SDD.” Low if the goal is “be official Spec Kit.”

### Option 3: Hybrid — keep plugin, steal official gates

**What it is:** Stay a Cursor plugin. Add the official commands we lack (constitution, analyze, converge; maybe clarify/checklist). Optionally document mapping to `/speckit.*`. Do not adopt `.specify/` or the CLI unless we want dual install.

**Pros:**
- Closes the real process gap without throwing away `/goal` / nest / marketplace
- Users who know official Spec Kit recognize the steps
- `/sdd-complete` + `/speckit.converge`-style loop can coexist

**Cons:**
- Two dialects (`/sdd-plan` vs `/speckit.plan`) unless we alias
- Maintenance: we still are not upstream
- Risk of cloning official prompts poorly

**Fit:** High if we want to stay close without becoming a `specify` skin.

---

## Comparison Matrix

| Criteria | Official Spec Kit 1.0 | This plugin 6.0.6 | Hybrid (steal gates) |
|----------|----------------------|-------------------|----------------------|
| Core Spec → Plan → Tasks → Implement | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Quality gates (clarify / checklist / analyze / converge) | ⭐⭐⭐ | ⭐ | ⭐⭐⭐ |
| Finish-all implement default | ⭐⭐ (small yes; large = scoped) | ⭐⭐⭐ (6.0.6) | ⭐⭐⭐ |
| Cursor-native (marketplace, `/sdd-plan`, nest, `/goal`) | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Multi-agent / CLI / extensions | ⭐⭐⭐ | ⭐ | ⭐ |
| Project principles (constitution) | ⭐⭐⭐ | ⭐ (rules only) | ⭐⭐⭐ |
| Research / brief / archive | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Team familiarity (this repo) | ⭐ | ⭐⭐⭐ | ⭐⭐ |
| Maintenance cost | ⭐⭐⭐ (upstream) | ⭐⭐ (we own it) | ⭐ |

---

## Official command map (2026-08-21)

Full path: constitution → specify → clarify → plan → checklist → tasks → analyze → implement → converge.

Shorter path: specify → plan → tasks → implement → converge.

| Official | Ours | Notes |
|----------|------|-------|
| `specify init` | `/sdd-init` | CLI vs plugin scaffold; `.specify/` vs `.sdd/` + `specs/` |
| `/speckit.constitution` | **MISSING** | Principles file every later step is checked against |
| `/speckit.specify` | `/sdd-specify` | Same job |
| `/speckit.clarify` | partial (`/sdd-specify` + `/sdd-refine` questions) | Official is a dedicated re-entry that writes back into `spec.md` |
| `/speckit.plan` | `/sdd-plan` | Renamed for Cursor Plan mode |
| `/speckit.checklist` | **MISSING** (we have implement `todo-list.md`) | Official = requirements quality, not impl todos |
| `/speckit.tasks` | `/sdd-tasks` | Official phases: Setup / Foundational / per user story / Polish |
| `/speckit.analyze` | partial (`/sdd-audit` is post-code) | Official is **pre-implement**, read-only across spec/plan/sdd-tasks |
| `/speckit.implement` | `/sdd-implement` | Official: all tasks **or** one phase. Ours: all todos unless forced pause |
| `/speckit.converge` | partial (`/sdd-audit` + re-`/sdd-implement`) | Official appends gap tasks; loop until converged |
| `/speckit.taskstoissues` | **MISSING** | GitHub issues |
| — | `/sdd-research`, `/sdd-brief`, `/sdd-complete`, `/sdd-memory`, `/sdd-execute-parallel`, `/goal` | Our extras |

---

## Recommendations

### Primary Recommendation

Treat official Spec Kit as the **process reference**, not a wholesale replace. We are close on the four-step core and far on gates + packaging.

If the next change is “get closer,” add in this order:

1. **`/analyze`** (read-only spec/plan/sdd-tasks consistency) — official’s cheapest missing gate
2. **`/converge`** (after implement: append missing tasks, then implement again) — matches how we wanted `/sdd-implement` to finish
3. **`/constitution`** (project principles) — official’s Phase 0
4. Optional: `/clarify` + requirements checklist, or keep `/sdd-specify` + `/sdd-refine`

Keep `/sdd-plan`, `/sdd-brief`, `/sdd-research`, `/sdd-complete`, and the Cursor nest/`/goal` layer. Do not `specify init` into this plugin repo as the product.

### Alternative Approach

Drop the plugin and tell users to run `specify init --integration cursor-agent` in each app repo. Only if we want to stop maintaining commands and accept official’s phased implement + `.specify/` layout.

---

## Open Questions

- Do we want users to recognize `/speckit.*` names, or keep `/sdd-*` to avoid Cursor Plan mode?
- Is a `constitution.md` in `.sdd/` enough, or do we adopt `.specify/`?
- Should `/sdd-implement` stay “finish all” even though official documents phased implement for large features?
- `/converge` vs stretching `/sdd-audit` — new command or evolve `/sdd-audit`?
- Compete with official Cursor skills, or document “use official Spec Kit in the app, this plugin is Cursor SDD”?

---

## Sources

| # | URL | Type | Reliability | Key Finding |
|---|-----|------|-------------|-------------|
| 1 | https://github.com/github/spec-kit | Official repo | High | GitHub Spec Kit, MIT, ~133k stars, 1.0.0 |
| 2 | https://github.github.com/spec-kit/ | Official docs | High | Spec → Plan → Tasks → Implement; 38 integrations; extensions |
| 3 | https://github.github.com/spec-kit/quickstart.html | Official docs | High | Full 9-step path; implement all vs scoped; converge |
| 4 | https://raw.githubusercontent.com/github/spec-kit/main/docs/reference/agentic-sdd.md | Official reference | High | Per-command contracts; implement may be phased |
| 5 | https://github.com/github/spec-kit/releases/tag/v1.0.0 | Release | High | 1.0.0 on 2026-08-21 |
| 6 | https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/ | GitHub Blog | High | Original public launch; Copilot / Claude / Gemini |
| 7 | https://github.com/github/spec-kit/pull/2156 | PR | High | Cursor integration moved to `.cursor/skills` |
| 8 | https://www.manorrock.com/blog/2026/08/21/spec_kit_turns_one.html | Maintainer post | Medium | 1.0.0 meaning |

---

## Confidence Assessment

**Overall confidence:** High on identity, commands, and closeness. Medium on whether we should adopt CLI vs steal gates (product call).

**Reasoning:** Official docs and 1.0.0 release were fetched today. Our command set was listed from this repo. No live `specify init` was run.

**Gaps:** Did not diff official Cursor skill prompt text vs our `commands/*.md` line by line. Did not install `specify-cli`.

**Suggested spike:** 2–4h — `specify init` in a throwaway repo with `--integration cursor-agent`, list installed skills, compare one official `speckit-implement` SKILL.md to our `implement.md`.

---

## Next Steps

1. Review this comparison
2. Decide replace vs hybrid vs ignore
3. `/sdd-specify compare-official-spec-kit` if we want requirements for the hybrid gates

---

*Research completed with SDD 6.0*
