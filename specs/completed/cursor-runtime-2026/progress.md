# Progress: cursor-runtime-2026

Implementation of Cursor runtime alignment (spec + plan). Sibling verifier next.

## Done
- Canonical spawn protocol in `docs/agent-manual.md` (two-level nest, fan-out, Task fields, `/goal`, Custom Modes)
- Agents: implementer never spawns verifier; orchestrator siblings + Await + cloud Task + `/autopilot`
- Commands fan-out + `/sdd-implement` `/goal` + all 19 have YAML `name`/`description`
- Plugin hooks `subagentStop` / `stop` (fail-open)
- Skill badges; hygiene (`/autopilot`, sddVersion 6.0)
