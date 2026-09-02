---
name: sdd-brief
description: Quick 30-minute feature brief. May fan out sdd-explorer siblings; main writes feature-brief.md.
---

# /sdd-brief Command

Create a lightweight feature brief in ~30 minutes, then start coding.

**Skill:** `sdd-planning`. **Subagent:** spawn **1–N** `sdd-explorer` siblings when there are distinct areas (code vs existing specs). Explorers return text. **Main writes `feature-brief.md`.** AskQuestion on main.

**See also:** `docs/agent-manual.md` for spawn protocol.

---

## Role

Create focused feature briefs through analysis and strategic questioning.

**What you do:**
- Analyze feature description and extract requirements
- Ask clarifying questions when information is missing
- Search codebase for existing patterns
- Present plan before creating files

**Output:** `specs/active/[task-id]/feature-brief.md`

---

## Usage

```
/sdd-brief [task-id] [feature-description]
```

**Examples:**
```
/sdd-brief user-auth JWT authentication with login/logout
/sdd-brief checkout-flow Streamlined one-page checkout with guest option
/sdd-brief notification-system Real-time push notifications for mobile
```

---

## Instructions

### Phase 0: Project bootstrap

If `.sdd/config.json` is missing, run `/sdd-init` inline first (create `.sdd/` + `specs/` in this project). Do not write specs into the plugin cache.

### Phase 1: Analysis (Readonly)

**Step 1: Parse the request**
- Extract task-id from input: `{{input}}`
- Extract feature description
- Identify key requirements and intent

**Step 2: Check existing patterns (fan-out)**
- If code vs `specs/active/` are distinct, spawn two `sdd-explorer` Tasks in one message (return text, do not write files).
- Otherwise search yourself or spawn one explorer.
- Note reusable patterns and conventions. Main synthesizes into the brief later.

**Step 3: Assess information completeness**

If ANY of these are unclear, call **AskQuestion in this turn** (do not print a numbered list in chat):
- What problem does this solve?
- Who are the primary users?
- Must-have vs nice-to-have
- Technical constraints or preferences
- What does success look like?

Give each question at least two concrete options. Batch them in one AskQuestion call. Wait for the answers before Phase 2.

**Step 4: Evaluate complexity**

| Indicator | Stay with Brief | Upgrade to Full SDD |
|-----------|-----------------|---------------------|
| Timeline | < 3 weeks | > 3 weeks |
| Team size | 1-2 developers | Multiple teams |
| Risk level | Low-medium | High (payments, security) |
| Architecture | Existing patterns | New patterns needed |
| Dependencies | Few/none | Multiple external |

If complexity suggests Full SDD, call **AskQuestion**: "Planning depth?" → Quick brief / Official (`/sdd-specify` → `/sdd-clarify` → `/sdd-plan`).

### Phase 2: Planning (Create Plan)

**Present a plan before creating any files:**

```
## Brief Creation Plan

**Task ID:** [task-id]
**Feature:** [feature name]

**What I'll create:**
- File: `specs/active/[task-id]/feature-brief.md`
- Structure: Problem → Users → Requirements → Approach → Next Actions

**Research scope (15 min):**
- [What I'll search for in codebase]
- [Patterns I'll look for]

**Brief will include:**
- Problem statement and target users
- Core requirements (must-haves only)
- Quick technical approach
- 3-5 immediate next actions
- Success criteria

**Estimated time:** 30 minutes total
```

Then call **AskQuestion**: "Proceed with this brief plan?" → Proceed / Adjust scope / Cancel. Do not only write "Ready to proceed?" in chat. Wait for the answer before creating files.

### Phase 3: Execution (After Approval)

**Step 1: Create directory**
```
specs/active/[task-id]/
```

**Step 2: Conduct quick research (15 min)**
- Search for similar patterns in codebase
- Document key findings
- Note reusable components

**Step 3: Generate feature-brief.md**

Use this structure:

```markdown
# Feature Brief: [Feature Name]

**Task ID:** [task-id]
**Created:** [date]
**Status:** Ready for Development

---

## Problem Statement

[What problem does this solve? 2-3 sentences]

## Target Users

[Who will use this? Be specific]

## Core Requirements

### Must Have
- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]

### Nice to Have
- [ ] [Optional 1]
- [ ] [Optional 2]

## Technical Approach

[High-level approach, 3-5 sentences]

**Patterns to Follow:**
- [Existing pattern 1 from codebase]
- [Existing pattern 2 from codebase]

**Key Decisions:**
- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]

## Next Actions

1. [ ] [First concrete step]
2. [ ] [Second step]
3. [ ] [Third step]

## Success Criteria

- [ ] [How we know it's done 1]
- [ ] [How we know it's done 2]

## Open Questions

- [Any unresolved questions]

---

*Brief created with SDD 6.0 - Ready to code!*
```

### Phase 4: Verification

Verify file created and contains: problem statement, 3+ requirements, actionable next steps.

---

## Output

```
✅ Brief created: `specs/active/[task-id]/feature-brief.md`

**Summary:**
- Problem: [One sentence]
- Core requirements: [Count] must-haves
- Next actions: [Count] items

**Next:** Start coding or run `/sdd-upgrade [task-id]` for full SDD planning
```

---

## Troubleshooting

### Issue: Feature is too vague
**Cause**: User provided minimal description like "build a dashboard"
**Solution**: Ask probing questions:
- "What specific problem does this dashboard solve?"
- "Who will use it and what decisions will they make?"
- "What data needs to be displayed?"

### Issue: Feature is too complex for brief
**Cause**: Multi-team, high-risk, or architecturally significant feature
**Solution**: Suggest Full SDD planning:
- "This looks complex. Would you prefer full planning with `/sdd-research` → `/sdd-specify` → `/sdd-plan`?"

### Issue: Can't find existing patterns
**Cause**: New project or greenfield feature
**Solution**: Note it explicitly:
- "No existing patterns found - this will establish new conventions"

---

## Related Commands

- `/sdd-evolve [task-id]` - Update brief as you discover things
- `/sdd-upgrade [task-id]` - Expand to full SDD 6.0 if needed
- `/sdd-implement [task-id]` - Start implementation (requires plan.md)
- `/sdd-refine [task-id]` - Refine the brief through discussion
- `/sdd-research [task-id]` - Deep pattern research (Full SDD planning)
