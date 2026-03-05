---
paths:
  - "customers/**"
---

# ClickHouse Analysis Workflow

**Voice reminder**: All customer-facing analysis outputs should reflect the principal SA's voice — direct, methodology-grounded, casual-professional. See CLAUDE.md for voice guide.

## Priority Order

1. **Run `/clickhouse-best-practices`** — Check applicable rules FIRST. ClickHouse-specific behaviors (columnar storage, sparse indexes, merge tree mechanics) mean general DB intuition is often wrong.
2. **Corroborate with docs** — Use `/researching-documentation` for thorough multi-pass research. Use raw `mcp__clickhouse-docs__search_clickhouse_knowledge_sources` only for quick single-fact lookups.
3. **General knowledge** — Connect concepts, handle edge cases not covered by rules.
4. **Web search** — Only for very recent features or gaps in other sources.

## Standard Questions (ask/verify before analysis)

- **ClickHouse version** — Affects available features and syntax
- **Cloud vs self-managed** — Affects recommendations and available settings
- **Data volume and growth rate** — Informs partitioning and retention strategies
- **Query latency requirements** — SLA targets for optimization decisions
- **Current bottleneck** — CPU, memory, disk I/O, or network

## Problem-Type Quick Reference

| Problem Type | Rules to Check | Key Questions |
|---|---|---|
| Schema Design | `schema-pk-*`, `schema-types-*`, `schema-partition-*` | Query patterns? Cardinality? |
| Query Performance | `query-join-*`, `query-index-*`, `query-mv-*` | EXPLAIN output? Data volume? |
| Insert/Update | `insert-batch-*`, `insert-mutation-*`, `insert-async-*` | Rate? Batch size? Update frequency? |
| Incidents | Buffer, merge, replication rules | Timeline? Metrics? What changed? |
