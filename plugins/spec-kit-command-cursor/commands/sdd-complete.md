---
name: sdd-complete
description: Close an SDD feature — mark specs Complete and move specs/active/[task-id] to specs/completed/.
---

# /sdd-complete Command

Archive a finished feature. Work can be live and still leave a spec "open" in `specs/active/` — this command closes that.

**See also:** `docs/agent-manual.md` for full agent protocol.

---

## Role

Move the feature out of active work. Do **not** write application code.

**I WILL:** set Status to Complete, tick leftover next-action boxes that are done, `mv` the folder to `specs/completed/`, update `specs/index.md` if it exists.
**I WILL NOT:** revert code, deploy, or archive a spec that still has real unfinished work unless the user confirms.

---

## Usage

```
/sdd-complete [task-id]
```

**Examples:**
```
/sdd-complete feat-crm-ingest-open-retry
/sdd-complete user-auth
```

---

## Instructions

### 1. Find the spec

Look in this order:
1. `specs/active/[task-id]/`
2. Fuzzy match under `specs/active/` if the id is slightly off
3. If it is already under `specs/completed/[task-id]/`, say so and stop

If nothing is found, stop.

### 2. Check leftover work

Read `feature-brief.md`, `spec.md`, `todo-list.md`, `tasks.md` if they exist.

- Unchecked Next Actions / todos that **are** done in the repo or were shipped: mark `[x]` and note why.
- Real unfinished work: call **AskQuestion** — "Archive anyway?" → Archive / Keep in active / Split leftover into a new brief.

Do not leave `[ ]` on work that already shipped.

### 3. Mark complete

In `spec.md` and/or `feature-brief.md`:
- Set **Status** to `Complete` (or `Completed`)
- Add **Completed:** today's date if missing

Optional: copy a short note into `changelog.md` if that file exists.

### 4. Move

```
mv specs/active/[task-id] specs/completed/[task-id]
```

Create `specs/completed/` if needed. Do not copy-then-leave the original in `active/`.

### 5. Index

If `specs/index.md` exists, move the row from Active to Completed (or remove from Active and add to Completed).

### 6. Confirm

```
✅ Spec archived: specs/completed/[task-id]/

**Was:** specs/active/[task-id]/
**Status:** Complete
**Index updated:** yes/no
```

Never SwitchMode. Never Cursor Plan / **Build**.
