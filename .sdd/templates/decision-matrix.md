# SDD Workflow Decision Matrix

## Quick Decision Guide

### Use `/brief` (Lightweight Path) When:
- ✅ **Single team** feature
- ✅ **Familiar technology** stack
- ✅ **Clear requirements** from stakeholders
- ✅ **Low business risk** feature
- ✅ **<2 week** development timeline
- ✅ **Existing patterns** can be reused
- ✅ **Independent** feature (minimal integration)

**Time Investment**: 30 minutes → Start coding

### Use Full Planning Path When:
- ⚠️ **Multiple teams** coordination needed
- ⚠️ **New/unfamiliar technology** required
- ⚠️ **Complex stakeholder** alignment needed
- ⚠️ **High business risk** or compliance requirements
- ⚠️ **3+ week** development timeline
- ⚠️ **Architectural changes** required
- ⚠️ **Complex integrations** with multiple systems

**Time Investment**: 4-6 hours → Comprehensive planning

## Decision Tree

```
Feature Idea
    ├─ Is it complex/high-risk? ────── YES ──► Full Planning
    │                                         /research → /specify → /sdd-plan → /tasks → /implement
    └─ NO
       │
       ├─ Use /brief (30 min planning)
       │
       ├─ Start coding
       │
       ├─ During development:
       │   ├─ Complexity discovered? ── YES ──► /upgrade to Full SDD
       │   └─ Requirements change? ──── YES ──► /evolve brief
       │
       └─ Ship feature
```

## Complexity Indicators

| Factor | Brief | Full SDD |
|--------|-------|----------|
| **Team Size** | 1-2 devs | 3+ devs |
| **Stakeholders** | 1-2 people | 3+ people |
| **Timeline** | <2 weeks | 3+ weeks |
| **Tech Risk** | Low | High |
| **Business Risk** | Low | Medium/High |
| **Integration Points** | 0-2 systems | 3+ systems |
| **Compliance** | None | Required |

## Examples

### ✅ Perfect for `/brief`:
- Add user avatar upload
- Create admin dashboard filter
- Build email notification system  
- Add product search functionality
- Implement user preferences page

### 🏗️ Needs Full SDD:
- Payment processing system
- Multi-tenant architecture changes
- Third-party API integration platform
- Security audit compliance features
- Cross-team data synchronization

## Escalation Signals

**Upgrade from brief to full SDD if you discover:**
- Regulatory/compliance requirements
- Need for architectural changes  
- Multiple team coordination required
- Technical approach is uncertain
- Stakeholder alignment issues emerge
- Timeline extends beyond initial estimate

## Best Practices

1. **Default to brief** - start lightweight
2. **Time-box planning** - if brief takes >30min, consider upgrade
3. **Monitor complexity** - upgrade when needed
4. **Keep evolving** - use `/evolve` for living documentation
5. **Learn from escalations** - improve future decision making
