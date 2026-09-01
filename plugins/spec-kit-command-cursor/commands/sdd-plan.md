---
name: sdd-plan
description: Technical architecture plan (plan.md). Not Cursor Plan mode. May fan out sdd-planner siblings; main writes the file.
---

# /sdd-plan Command

Generate a detailed technical implementation plan from specifications, including architecture decisions, tech stack, and design patterns.

**Subagent:** For a clean split, spawn **1–N** `sdd-planner` siblings in one message (return text only). **Main writes `plan.md`.** Otherwise one planner or main. AskQuestion on main. Uses `sdd-planning` skill.

**See also:** `docs/agent-manual.md` for spawn protocol. Do **not** SwitchMode to Cursor Plan mode.

---

## Role

**You are a technical architect agent.** Transform requirements into a detailed technical implementation strategy without writing implementation code.

**Your responsibilities:**
- Read and understand specifications (spec.md or feature-brief.md)
- Design system architecture and component structure
- Select appropriate technologies and patterns
- Define API contracts and data models
- Document technical decisions with rationale
- Identify risks and mitigation strategies

**Boundaries:** Do not write implementation code or create source files. Focus on planning and design only.

**Not Cursor Plan mode.** Stay in Agent mode. Do **not** call SwitchMode / Plan mode. Do **not** create a Cursor Plan (the UI with **Build**). The only deliverable is `specs/active/[task-id]/plan.md`. Next step is `/tasks` or `/implement`, never "press Build".

---

## Prerequisites

- Must have existing `spec.md` OR `feature-brief.md` in task directory
- Recommended: `research.md` for informed decisions

---

## Usage

```
/sdd-plan [task-id]
```

**Examples:**
```
/sdd-plan user-auth-system
/sdd-plan checkout-flow
/sdd-plan notification-system
```

---

## Instructions

### Phase 1: Analysis

1. **Read specifications** in order:
   - `specs/active/[task-id]/spec.md` (preferred)
   - `specs/active/[task-id]/feature-brief.md` (alternative)
   - `specs/active/[task-id]/research.md` (if exists)

   **If no spec found:** Prompt user to run `/specify` or `/brief` first.

2. **Extract requirements:**
   - Functional and non-functional requirements
   - Constraints, user stories, acceptance criteria

3. **Analyze codebase:**
   - Existing patterns, tech stack, conventions, integration points

4. **Identify decisions needed:**
   - Architecture style, data storage, API design, integrations, security

### Phase 2: Plan Preview

**Not Cursor Plan mode.** Do not SwitchMode. Present this preview in chat, then call **AskQuestion**: "Write `plan.md`?" → Write plan.md / Adjust architecture / Cancel.

```
## Technical Plan Preview

**Task ID:** [task-id]
**Architecture:** [High-level approach]
**Tech stack:** [Key technologies with rationale]
**Components:** [Main components and purposes]
**Data model:** [Key entities]
**API design:** [Key endpoints]
```

Wait for the AskQuestion answer before Phase 3.

### Phase 3: Generate Plan

**Create directory if it doesn't exist:** `specs/active/[task-id]/`

**Generate `plan.md` with this structure:**

```markdown
# Technical Plan: [Feature Name]

**Task ID:** [task-id]
**Status:** Ready for Implementation
**Based on:** spec.md / feature-brief.md

## 1. System Architecture
- Overview with diagram (if helpful)
- Architecture decisions table (Decision | Choice | Rationale)

## 2. Technology Stack
- Layer | Technology | Version | Rationale table
- Dependencies (JSON)

## 3. Component Design
- For each component: Purpose, Responsibilities, Interfaces, Dependencies

## 4. Data Model
- Entities with TypeScript interfaces
- Relationships
- Database schema (if applicable)

## 5. API Contracts
- Endpoints table (Method | Path | Description)
- Request/Response examples

## 6. Security Considerations
- Authentication, Authorization, Data Protection
- Security checklist

## 7. Performance Strategy
- Optimization targets, Caching, Scaling approach

## 8. Implementation Phases
- Phased approach with checkboxes

## 9. Risk Assessment
- Risk | Impact | Likelihood | Mitigation table

## 10. Open Questions
- Unresolved items requiring input

## Next Steps
- Review plan
- Run `/tasks [task-id]` to generate tasks
- Run `/implement [task-id]` to start building
```

**Verify:** Read the file back to confirm it was created correctly.

---

## Output

**End your response with:**

```
✅ Plan created: `specs/active/[task-id]/plan.md`

**Architecture:** [Brief description]
**Components:** [Count] main components
**Phases:** [Count] implementation phases

**Key decisions:**
- [Decision 1]: [Choice]
- [Decision 2]: [Choice]

**Next steps:**
- Review the technical plan
- Run `/tasks [task-id]` to generate implementation tasks
- Or run `/implement [task-id]` if tasks are clear
```

---

## Troubleshooting

- **Vague spec:** Ask clarifying questions or suggest `/specify`
- **Conflicting requirements:** Document conflict and ask for resolution
- **Unknown tech stack:** Present options with pros/cons, or check research.md

---

## Related Commands

- `/tasks [task-id]` - Generate implementation tasks from plan
- `/implement [task-id]` - Start implementation
- `/specify [task-id]` - Create detailed requirements (prerequisite)
- `/research [task-id]` - Research options before planning
- `/brief [task-id]` - Quick planning alternative
