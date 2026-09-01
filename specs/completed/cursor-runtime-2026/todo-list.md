# Todo list: cursor-runtime-2026

**Goal:** Complete spec "Cursor Runtime Alignment" until sibling `sdd-verifier` reports complete.

## Phase 0 — Protocol lock
- [x] Rewrite `docs/agent-manual.md`
- [x] Update `rules/sdd-system.mdc`

## Phase 1 — Agents + spawn commands
- [x] `sdd-implementer` — never spawn verifier
- [x] `sdd-orchestrator` — sibling verifier, Await, cloud Task, `/autopilot`, agentIds
- [x] `sdd-explorer` + `sdd-planner` — return text only
- [x] `sdd-reviewer` babysit → autopilot if any (no babysit in reviewer)
- [x] Fan-out: research, brief, specify, sdd-plan
- [x] implement + execute-parallel + execute-task

## Phase 2 — Hooks, skills, frontmatter
- [x] Plugin hooks pack
- [x] Skill icon/color
- [x] Command YAML frontmatter
- [x] sdd-init hook mention

## Phase 3 — Hygiene
- [x] `/babysit` → `/autopilot` sweep (plugin leftover: "formerly babysit" in agent-manual only)
- [x] sddVersion 6.0 + drop PLAN Mode leftovers
- [x] CallDynamicTool + README/guidelines
- [x] Grep gates

## Progress log

| When | Note |
|------|------|
| 2026-09-01 | Started after Proceed |
| 2026-09-01 | Protocol, agents, commands, hooks, skills, hygiene done. Awaiting sibling verifier. |
| 2026-09-01 | Sibling verifier FAIL — leftover grandchild docs. Fixed. Re-verify PASS. |
