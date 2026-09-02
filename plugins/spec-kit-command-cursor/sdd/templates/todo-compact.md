# {{TASK_ID}} Todo

## Pre-flight
- [ ] Review research + spec + plan
- [ ] Create branch `{{TASK_ID}}`
- [ ] Setup dev env

## Implementation
{{#each TODOS}}
- [ ] **{{this.id}}**: {{this.desc}}
  - Time: {{this.estimate}} | Deps: {{this.deps}}
  - Pattern: {{this.pattern}} | Files: {{this.files}}
{{/each}}

## Pattern Reuse
{{#each REUSE}}
- **{{this.component}}** → {{this.usage}}
{{/each}}

## Execution Rules
1. One checkbox per `tasks.md` task — never `3.2–3.10 (see tasks.md)`
2. Execute in dependency order; later phases may start when their deps are done
3. After a phase, continue — do not wait for the user
4. Maximum flow - batch questions at end
5. Reuse patterns where possible
6. Update progress continuously
7. Forced pause: last line is `Reply continue` or `/implement {{TASK_ID}}`

## Progress
### Done
- [ ] Track completed items here

### Blockers
- [ ] Document blockers + resolutions

### Questions (Batch at end)
- [ ] List ambiguous items here

## DoD
All todos complete + tests pass + review + deploy

---
Start: {{START_DATE}} | Target: {{TARGET_DATE}} | {{TOTAL_ESTIMATE}}
