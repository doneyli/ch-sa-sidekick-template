---
name: drafting-technical-assessment
description: Generate a comprehensive technical assessment for a ClickHouse customer issue. Use when doing a deep-dive on a customer problem, when a formal written assessment is needed, when analyzing schema + queries + configuration together, or when a customer escalation needs documented analysis with recommendations.
arguments: customer-name
model: opus
---

# ClickHouse Technical Assessment

Generate a detailed technical assessment for customer: **$ARGUMENTS**

## Voice

This is a **customer-facing deliverable**. Follow `@sa-persona.md` — deliverable voice. Lead with findings, be blunt about problems, validate what the customer got right, and make every SQL block copy-paste ready.

## Instructions

1. **FIRST**: Invoke `/researching-documentation` with the customer's core question/issue
   - Review the research output for documented facts, inferences, and gaps
   - This ensures thorough multi-pass documentation search before analysis
2. **SECOND**: Invoke `/clickhouse-best-practices` skill to identify all applicable rules
3. Create assessment file at `/customers/$ARGUMENTS/assessment.md`
4. Follow the template structure below
5. Cite all sources (rules, docs, general knowledge)

## Assessment Template

```markdown
# Assessment: $ARGUMENTS

**Date**: [Current date]
**ClickHouse Version**: [Ask if unknown]
**Deployment**: Cloud / Self-managed

---

## Problem Statement

[Concise description of the customer's issue or question]

---

## Current Setup

### Schema (DDL)
```sql
-- Include relevant table definitions
```

### Query Patterns
```sql
-- Include problematic or relevant queries
```

### Workload Characteristics
- Insert rate: [X rows/sec or batches/min]
- Query volume: [X queries/sec]
- Data volume: [X GB/TB total, X GB/day growth]
- Retention: [X days/months]

---

## Rules Checked

| Rule | Status | Notes |
|------|--------|-------|
| `rule-name-1` | Compliant / Violation / N/A | Brief explanation |
| `rule-name-2` | Compliant / Violation / N/A | Brief explanation |

---

## Findings

### Violations

#### `rule-name`: Issue Title
- **Current**: What the customer is doing
- **Required**: What they should do
- **Impact**: Why this matters (performance, correctness, etc.)
- **Fix**: Specific correction with SQL example

### Compliant
- `rule-name`: Brief note on why current approach is correct

---

## Root Cause Analysis

[Detailed explanation of why the issue is occurring, citing rules and docs]

---

## Documentation References

- [Feature/Topic](URL) - Key insight
- [Feature/Topic](URL) - Key insight

---

## Recommendations

### Critical (Do First)
1. **[Action]** - [Brief description]
   - Per `rule-name`: [Citation]
   - Min version: [X.X if applicable]
   ```sql
   -- Example SQL
   ```

### High Priority
1. **[Action]** - [Brief description]

### Medium Priority
1. **[Action]** - [Brief description]

### Nice-to-Have
1. **[Action]** - [Brief description]

---

## Version Requirements

| Recommendation | Min Version | Notes |
|----------------|-------------|-------|
| [Feature/Setting] | X.X | [Why needed] |

---

## Validation Queries

```sql
-- Query to verify the fix is working
EXPLAIN ...

-- Query to measure improvement
SELECT ... FROM system.query_log ...
```

---

## Migration Risk

### Rollback Strategy
[How to revert if something goes wrong]

### Downtime Impact
[Expected downtime or performance impact during migration]

### Data Safety
[Backup recommendations, data validation steps]

---

## Questions for Customer

- [ ] [Question about requirements or constraints]
- [ ] [Question about current behavior]
- [ ] [Question about acceptable trade-offs]

---

## Follow-up Actions

- [ ] [Action item with owner/timeline if known]
- [ ] [Action item]
- [ ] Schedule follow-up to verify implementation
```

## Checklist Before Completing

- [ ] Docs-research skill was invoked first with the core question
- [ ] Documentation gaps were explicitly noted in the assessment
- [ ] Best practices skill was invoked
- [ ] All applicable rules were checked
- [ ] ClickHouse version is specified or noted as unknown
- [ ] All recommendations include source citations (documented vs inferred)
- [ ] SQL examples are copy-paste ready
- [ ] Rollback strategy is included for schema changes
- [ ] Validation queries are provided
