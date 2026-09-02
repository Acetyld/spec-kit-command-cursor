---
name: sdd-constitution
description: Create or update .sdd/memory/constitution.md — project principles every later SDD command is checked against.
---

# /sdd-constitution Command

Port of official Spec Kit `/speckit.constitution`. Cursor packaging only: AskQuestion on main, write `.sdd/memory/constitution.md` (not `.specify/memory/`).

**See also:** `docs/agent-manual.md`. Template: `sdd/templates/constitution-template.md`.

---

## Role

Update **only** the project constitution. Do not write application code.

**I WILL:** create or amend `.sdd/memory/constitution.md` from the official-shaped template.
**I WILL NOT:** create features, edit `specs/`, or run `/sdd-specify` unless the user asked and you list it under Next Actions without invoking it.

---

## Usage

```
/sdd-constitution [principles…]
```

---

## Instructions

`FEATURE` paths stay under `specs/active/` for other commands. This command writes **one file**: `.sdd/memory/constitution.md`.

Skip `.specify/extensions.yml` hooks (not used in this plugin).

1. If `.sdd/config.json` is missing, run `/sdd-init` first (or tell the user to).
2. Load `sdd/templates/constitution-template.md` (plugin or project `.sdd/templates/`).
3. If `.sdd/memory/constitution.md` exists, load it and preserve still-valid principles.
4. Fill `[ALL_CAPS]` placeholders from user input, then repo README/docs. Dates ISO `YYYY-MM-DD`.
5. Version: MAJOR (removed/redefined principle), MINOR (new principle), PATCH (wording). State the bump rationale.
6. Each principle: name, MUST/SHOULD rules, short rationale. Governance: how to amend, compliance review.
7. Prepend an HTML comment **Sync Impact Report**: old → new version, added/removed/renamed principles, deferred TODOs.
8. No unexplained bracket tokens. Write the file. Suggest a commit message. List deferred non-governance intents as Next Actions (`/sdd-specify`, etc.) without running them.

If ratification date is unknown, `TODO(RATIFICATION_DATE): …` and list it in the report.

---

## Output

```
✅ Constitution: `.sdd/memory/constitution.md` (vX.Y.Z)

Next: /sdd-specify [task-id] [what to build]
```
