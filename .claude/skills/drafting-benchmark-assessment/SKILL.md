---
name: drafting-benchmark-assessment
description: Generate a query optimization assessment (MD + HTML) from benchmark results. Use after running benchmarks, when benchmark CSV/TSV data is ready for writeup, when you need to produce a customer-facing optimization report, or when summarizing query performance improvements.
arguments: customer-name
model: opus
---

# ClickHouse Benchmark Assessment

Generate a customer-facing query optimization assessment for: **$ARGUMENTS**

## Voice

This is a **customer-facing deliverable**. Follow `@sa-persona.md` — deliverable voice. Lead with the headline number, make every SQL block copy-paste ready.

## Instructions

### Step 1: Gather Context

1. **Read benchmark results** — Look in `/customers/$ARGUMENTS/` for:
   - `benchmark_results_*.csv` — Structured CSV from the benchmark script
   - `benchmark_summary_*.txt` — Human-readable summary
   - `benchmark_server_metrics_*.tsv` — Server-side metrics from system.query_log
   - Any manual benchmark notes or logs

2. **Read existing analysis** — Look for any prior assessment drafts, query files, or notes in the customer folder

3. **Identify all query variants tested** — Original, optimized, dict-based, MV reads, etc.

### Step 2: Run Best Practices Check

Invoke `/clickhouse-best-practices` with the customer's core optimization question to ensure all applicable rules are cited in recommendations.

### Step 3: Compute Key Metrics

From the benchmark data, compute:
- **Single-query latency**: Average across runs for each variant (after cache drop)
- **Best live improvement**: % change from original to best non-MV variant
- **MV read latency**: Average for MV reads (if applicable)
- **Concurrent throughput**: Wall-clock time for N parallel queries
- **Thread tuning impact**: Improvement from max_threads=1/2 at high concurrency
- **Server-side metrics**: read_rows, read_bytes, memory_usage from query_log (if available)

### Step 4: Generate Assessment

Write **two files** in `/customers/$ARGUMENTS/`:

#### File 1: `YYYY-MM-DD-query-optimization-assessment.md`

Use the markdown template below. Use today's date.

#### File 2: `YYYY-MM-DD-query-optimization-assessment.html`

Use the HTML template at `/templates/benchmark-assessment-email.html` as the structural base. Replace all `{{PLACEHOLDER}}` variables with actual data. The HTML must be:
- Email-safe (inline CSS only, no external resources)
- Self-contained (opens correctly in any browser)
- Green-highlighted cells (`.highlight` class) for best results
- Color-coded tier badges (tier-1 green, tier-2 blue, tier-3 orange)
- Syntax-highlighted SQL blocks (dark theme with `.keyword` and `.comment` spans)

## Markdown Template

```markdown
# {{CUSTOMER_NAME}} Query Optimization Assessment

**Date:** YYYY-MM-DD
**Status:** Active
**Issue:** [One-line summary of the optimization goal]

## Status Updates
- **YYYY-MM-DD** — Original creation, benchmarks complete

---

## TL;DR

[Lead with the headline result. One strong sentence. Then break down: what's achievable with MVs, what's achievable live, and the key tradeoff.]

---

## What We Found

### Single-Query Latency

| Query | Before | Best Live | MV Read | Live Improvement |
|-------|--------|-----------|---------|------------------|
| Q1 — [desc] | Xs | Xs | **Xs** | -X% (variant) |

### [N] Concurrent Queries

| Query | Before | Best Live (mt=1) | MV Read |
|-------|--------|------------------|---------|
| Q1 | Xs | Xs | **Xs** |

---

## Recommendations

### Tier 1: [Quick wins — biggest impact, lowest effort]

[Description. What's already deployed. How to use it. Copy-paste SQL.]

```sql
-- Copy-paste ready queries
```

**Tradeoff:** [Be explicit about the tradeoff.]

### Tier 2: [Configuration / settings changes — no code changes]

```sql
-- Settings change
```

[Description of impact, when to use, when not to.]

### Tier 3: [Query rewrites — no staleness, no infra changes]

**Q1** — [What was changed and why it helps.]
**Q2** — [What was changed and why it helps.]

[Where to find the optimized SQL files.]

---

## What We Didn't Test / Considerations

**[Topic 1]** — [What wasn't tested and why it might matter.]

**[Topic 2]** — [What wasn't tested and why it might matter.]

---

## Objects Deployed on Your Service

### [database_name]
| Object | Type | Notes |
|--------|------|-------|
| `object_name` | Dictionary (HASHED) | Size/entries |

To remove everything if needed:
```sql
-- Cleanup SQL — copy-paste ready
DROP VIEW IF EXISTS ...;
DROP TABLE IF EXISTS ...;
DROP DICTIONARY IF EXISTS ...;
```

---

## Key Technical Lessons

[Optional section. Include if there's a notable technical finding — e.g., why a particular optimization approach didn't work, cascading AVG-of-AVG semantics, CTE inlining behavior, etc. This educates the customer and demonstrates depth.]

---

[Closing line. Offer to dig deeper, hop on a call, or discuss tradeoffs. No formal sign-off.]
```

## Checklist Before Completing

- [ ] Both .md and .html files written to `/customers/$ARGUMENTS/`
- [ ] TL;DR leads with the headline metric
- [ ] All benchmark numbers sourced from actual CSV/summary data (not fabricated)
- [ ] Recommendations are tiered (Tier 1 = biggest bang, Tier 3 = most effort)
- [ ] Every tier includes copy-paste ready SQL
- [ ] Tradeoffs stated explicitly for each recommendation
- [ ] Considerations section covers untested vectors
- [ ] Objects deployed section lists everything created on the service
- [ ] Cleanup SQL is complete and correct (DROP in dependency order: views before tables)
- [ ] HTML renders correctly in browser (check inline CSS, no broken tags)
- [ ] Voice matches `@sa-persona.md` deliverable voice
- [ ] Best practices rules cited where applicable
- [ ] File headers follow `customer-file-header.md` template
