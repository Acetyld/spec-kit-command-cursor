# Contributing to SDD Cursor Commands

Thanks for your interest in contributing! This guide covers how to add commands, subagents, skills, and templates.

## Project Structure

```
.cursor-plugin/marketplace.json          # Git-link marketplace manifest
plugins/spec-kit-command-cursor/
├── .cursor-plugin/plugin.json           # Plugin identity (must match marketplace entry name)
├── agents/                              # Subagent definitions (.md)
├── commands/                            # Slash commands (.md)
├── skills/                              # Agent skills (SKILL.md + references/ + scripts/)
├── rules/                               # Always-applied plugin rules (.mdc)
├── docs/agent-manual.md                 # Shared agent protocol (not a slash command)
├── sdd/                                 # Bundled templates copied into apps by /sdd-init
├── environment.json                     # Starter for consuming projects
├── sandbox.json
└── worktrees.json

.cursor/                                 # This repo's own Cursor project files
├── environment.json
├── sandbox.json
└── worktrees.json

.sdd/                                    # This repo's own SDD config + templates
specs/                                   # This repo's own specs
```

Do not put commands, agents, skills, or the SDD system rule back under `.cursor/` — Cursor loads those from the plugin package.

## Adding a New Command

1. Create `plugins/spec-kit-command-cursor/commands/your-command.md`
2. Follow the structure of existing commands (role, usage, phases, output)
3. Add YAML frontmatter (`name`, `description`) so it shows cleanly in the `/` menu
4. Add the command to the reference table in `plugins/spec-kit-command-cursor/rules/sdd-system.mdc`
5. If the command uses a subagent, map it in `plugins/spec-kit-command-cursor/docs/agent-manual.md`

Keep shared protocol in `docs/`, not under `commands/` — every `.md` in `commands/` becomes a slash command.

## Adding a New Subagent

1. Create `plugins/spec-kit-command-cursor/agents/your-agent.md` with YAML frontmatter:
   ```yaml
   ---
   name: your-agent
   description: What it does
   model: inherit
   is_background: true | false
   ---
   ```
2. Use `inherit` by default. If a specific model is required, use an exact Cursor-supported model ID rather than an alias.
3. Add to the subagent table in `docs/agent-manual.md` and `rules/sdd-system.mdc`
4. Document when to delegate to it in the Delegation Guidelines

## Adding a New Skill

1. Create `plugins/spec-kit-command-cursor/skills/your-skill/SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: your-skill
   description: When to use it
   ---
   ```
2. Add `references/` for on-demand knowledge, `scripts/` for executable helpers, `assets/` for templates
3. Add to the skills table in `docs/agent-manual.md` and `rules/sdd-system.mdc`

## Adding a Template

1. Create the file in both `.sdd/templates/` (this repo) and `plugins/spec-kit-command-cursor/sdd/templates/` (what `/sdd-init` copies into apps)
2. Use `{{VARIABLE}}` placeholders for values agents fill in
3. If the template is for a command, add the path to `.sdd/config.json` and the bundled `sdd/config.json` under `settings.templates`

## Testing Changes

- Run any shell scripts to verify they work: `bash plugins/spec-kit-command-cursor/skills/sdd-audit/scripts/validate.sh`
- Check that markdown renders correctly
- Verify cross-references between files are accurate
- Confirm `plugin.json` `name` matches the marketplace entry `name`

## Guidelines

- Keep agent prompts concise — focused instructions work best
- Follow the plan-approve-execute pattern for all commands
- Use progressive loading for skills (keep SKILL.md small, put details in references/)
- Update `README-technical.md` (full command/subagent/skill tables) when adding features; only touch `README.md` if it changes the everyday-use story

## Reporting Issues

- [GitHub Issues](https://github.com/madebyaris/spec-kit-command-cursor/issues) for bugs
- [GitHub Discussions](https://github.com/madebyaris/spec-kit-command-cursor/discussions) for feature ideas
