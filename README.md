# SDD Cursor Commands

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/madebyaris/spec-kit-command-cursor?style=social)](https://github.com/madebyaris/spec-kit-command-cursor/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![Cursor 3.8+](https://img.shields.io/badge/Cursor-3.8%2B-blue)](https://cursor.com)

**Spec-Driven Development for Cursor IDE** — plan before you code, then let agents execute.

[Quick Start](#quick-start) • [Everyday Commands](#everyday-commands) • [Pick a Workflow](#pick-a-workflow) • [Technical Docs »](README-technical.md)

</div>

---

## Quick Start

Install the plugin from this repo (Cursor → Plugins → add git marketplace), then in **your app repo**:

```
/sdd-init
/brief user-auth JWT authentication with login/logout
```

`/sdd-init` creates `.sdd/` and `specs/` in the current project. `/brief` does that automatically if they are missing. For bigger work, see [Pick a Workflow](#pick-a-workflow).

---

## Everyday Commands

The ones you'll actually use day to day:

| Command | What it does |
|---------|--------------|
| `/sdd-init` | First-time: create `.sdd/` + `specs/` in this project |
| `/brief` | Quick 30-min plan for a feature (start here for most things) |
| `/sdd-plan` | Technical architecture (`plan.md`). Not Cursor's `/plan` (Plan mode) |
| `/implement` | Build it, with progress tracking |
| `/sdd-complete` | Close the spec: move `specs/active/` → `specs/completed/` |
| `/audit` | Review the code against the spec |
| `/evolve` | Update the spec when things change mid-build |

> Full command list, flags, and outputs are in the [technical docs](README-technical.md#commands).

---

## Pick a Workflow

**Just building a feature?** (most of the time)
```
/brief my-feature  →  /implement my-feature  →  /sdd-complete my-feature
```

**Complex or high-risk feature?**
```
/research  →  /specify  →  /sdd-plan  →  /tasks  →  /implement  →  /sdd-complete
```

Cursor's built-in `/plan` is Plan mode (the **Build** button). SDD technical architecture is **`/sdd-plan`**.

**Whole app or big project?**
```
/sdd-full-plan my-app  →  /execute-parallel my-app --until-finish
```

That's the 90% case. Everything else — deep research, parallel/cloud execution, heavy apps — is in the [technical docs](README-technical.md#workflows).

---

## Memory (optional)

By default SDD is stateless and zero-setup. If you want agents to remember decisions and conventions across sessions, turn on memory:

```
/sdd-memory                 # pick a backend, or leave it off
```

Three choices: `standard` (default, nothing to set up), `cursor-native` (free Cursor Memories), or `mem0` (free self-host). Details and trade-offs: [technical docs](README-technical.md#memory).

---

## Learn More

- **[Technical documentation »](README-technical.md)** — every command, subagents, skills, memory backends, cloud execution, architecture, and project layout
- **[Contributing](CONTRIBUTING.md)** — add commands, subagents, skills, and templates
- [Report a bug](https://github.com/madebyaris/spec-kit-command-cursor/issues) · [Suggest a feature](https://github.com/madebyaris/spec-kit-command-cursor/discussions)

## Acknowledgments

Thanks to [ClavixDev](https://github.com/ClavixDev) for valuable ideas and suggestions!

## License

MIT License — see [LICENSE](LICENSE)

---

<div align="center">

**Made with ❤️ by [Aris](https://github.com/madebyaris)**

Try it: `/brief hello-world Create a simple hello world feature`

</div>
