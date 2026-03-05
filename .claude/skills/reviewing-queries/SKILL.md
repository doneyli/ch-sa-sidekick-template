---
name: reviewing-queries
description: Lightweight query optimization review — quick wins without a full assessment
arguments: customer-name
---

# ClickHouse Query Review

Generate a focused query optimization review for: **$ARGUMENTS**

## Voice

This is a **customer-facing deliverable**. Follow `@sa-persona.md` — deliverable voice. Lead with the verdict, cite rules, make SQL copy-paste ready. This is NOT a full assessment — it's a quick, actionable review.

## Instructions

1. **Load customer context** — Read all files in `/customers/$ARGUMENTS/` to find:
   - DDL (`SHOW CREATE TABLE` output, schema files, `.sql` files)
   - Queries to review (Slack threads, query files, assessment notes)
   - Any prior assessments or reviews (avoid repeating what's already been said)

2. **Invoke `/clickhouse-best-practices`** — Check all applicable rules against the query + schema. Focus on:
   - ORDER BY key alignment with query filters (`schema-pk-*` rules)
   - Type usage (`schema-types-*` rules)
   - Query anti-patterns (`query-*` rules)
   - Partitioning (`schema-partition-*` rules)

3. **Optionally invoke `/researching-documentation`** — Only if the query involves features that need version verification (e.g., `QUALIFY`, `INTERPOLATE`, newer aggregate functions, settings).

4. **Produce the review** — Write to `/customers/$ARGUMENTS/YYYY-MM-DD-query-review.md` using today's date.

## Output Template

```markdown
# Query Review: $ARGUMENTS

**Date:** YYYY-MM-DD
**Status:** Active
**Issue:** Query optimization review — [one-line description of what's being reviewed]

## Status Updates
- **YYYY-MM-DD** — Original creation

---

## TL;DR

[One-line verdict. Be direct: "The main bottleneck is X. Fix Y for the biggest win."]

---

## Schema Check

| Check | Status | Notes |
|-------|--------|-------|
| ORDER BY alignment with filters | Pass / Fail | Per `schema-pk-prioritize-filters` — [detail] |
| Cardinality order | Pass / Fail | Per `schema-pk-cardinality-order` — [detail] |
| Column types | Pass / Fail | Per `schema-types-*` — [detail] |
| Partition key | Pass / Fail | Per `schema-partition-*` — [detail] |
| Primary key granularity | Pass / Fail | [detail] |

---

## Query Anti-Patterns Found

### [Anti-pattern title]
- **What**: [What the query is doing wrong]
- **Why bad**: [Technical explanation — granules, scans, memory, etc.]
- **Rule**: `rule-name`
- **Fix**:
```sql
-- Before (current)
[problematic SQL]

-- After (fixed)
[optimized SQL]
```

---

## Quick Wins

Ranked by impact (biggest first):

### 1. [Win title]
```sql
-- Copy-paste ready fix
```
**Expected impact**: [What improves and roughly by how much]

### 2. [Win title]
```sql
-- Copy-paste ready fix
```
**Expected impact**: [What improves and roughly by how much]

---

## Needs Full Benchmark?

**[Yes / No]** — [Reasoning. E.g., "No — the fixes are straightforward ORDER BY alignment. A benchmark would confirm the numbers but the direction is clear." or "Yes — the query involves complex JOINs and the optimization path depends on data distribution we haven't profiled."]

---

## Version Requirements

| Recommendation | Min Version | Notes |
|----------------|-------------|-------|
| [Feature/Setting] | X.X | [Why needed] |

---

## Verify the Fixes

```sql
-- Run EXPLAIN to confirm index usage
EXPLAIN indexes=1
SELECT ...

-- Check query_log for before/after comparison
SELECT
    query,
    read_rows,
    read_bytes,
    memory_usage,
    query_duration_ms
FROM system.query_log
WHERE ...
```
```

## Key Difference from `/drafting-technical-assessment`

This is a **focused review**, not a full assessment. Specifically:
- No root cause analysis section
- No migration risk / rollback strategy
- No workload characteristics profiling
- No comprehensive findings table

If the review reveals structural issues that need deeper analysis, recommend invoking `/drafting-technical-assessment` as a next step.

## Checklist

- [ ] `/clickhouse-best-practices` was invoked
- [ ] All applicable `schema-pk-*` rules checked
- [ ] All applicable `query-*` rules checked
- [ ] TL;DR leads with the verdict, not preamble
- [ ] Every anti-pattern has a rule citation
- [ ] SQL examples are copy-paste ready (not fragments)
- [ ] Version requirements noted for version-dependent recommendations
- [ ] "Needs Full Benchmark?" section has clear yes/no with reasoning
