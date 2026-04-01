---
name: executing-benchmark
description: Execute query optimization benchmarks against a ClickHouse Cloud service. Use when running performance tests, when comparing query latency before and after optimization, when testing concurrent throughput, or when a customer engagement needs hard numbers on query performance.
arguments: customer-name
allowed-tools: Bash, Read
model: sonnet
---

# Execute Query Optimization Benchmark

Run a structured benchmark for: **$ARGUMENTS**

## Voice

This is an **internal skill** (sidekick → SA). Report results factually, flag anomalies, suggest next steps.

## Prerequisites

Before running this skill, the customer folder must have:
1. A `benchmark.manifest` file with query definitions
2. SQL query files referenced by the manifest
3. A `.env` file with ClickHouse credentials

## Instructions

### Step 0: Validate Customer Folder

Check that `/customers/$ARGUMENTS/` exists and contains the required files:

```
customers/$ARGUMENTS/
├── .env                    # Credentials (DO NOT read this file)
├── benchmark.manifest      # Query manifest
└── queries/                # SQL files referenced by manifest
    ├── query1.sql
    ├── optimized/
    │   └── query1_optimized.sql
    └── ...
```

1. **Confirm `.env` exists** — Run `ls -la customers/$ARGUMENTS/.env` (do NOT read it)
2. **Read the manifest** — Read `customers/$ARGUMENTS/benchmark.manifest` to understand what will be tested
3. **Verify SQL files** — Check that every SQL file referenced in the manifest exists
4. **Read query files** — Briefly scan each SQL file to confirm they look correct (no syntax issues, proper FORMAT usage)

If anything is missing, **STOP and tell the SA what needs to be set up first**. Provide the template commands:

```bash
# Copy the .env template
cp templates/customer.env.example customers/$ARGUMENTS/.env
# Then edit with actual credentials

# Copy the manifest template
cp templates/benchmark.manifest.example customers/$ARGUMENTS/benchmark.manifest
# Then edit with actual queries
```

### Step 1: Pre-flight Connectivity Check

Test that the credentials work without reading them. Run:

```bash
source customers/$ARGUMENTS/.env && \
clickhouse client \
  --host "$CH_HOST" \
  --user "${CH_USER:-default}" \
  --password "$CH_PASSWORD" \
  ${CH_SECURE:+--secure} \
  --query "SELECT version(), currentDatabase()" \
  --format TSV
```

**If this fails**, tell the SA:
- Connection refused → Check host/port, VPN, IP allowlist
- Authentication failed → Check user/password in .env
- Database not found → Check CH_DATABASE in .env

Record the ClickHouse version from the output — it goes in the assessment later.

### Step 2: Pre-flight Validation

Run a dry validation pass:

1. **Row counts** — For each SQL query in the manifest, run a quick `SELECT count()` wrapped version to confirm the query returns data
2. **Object existence** — For MV entries in the manifest, verify the table/view exists:
   ```bash
   source customers/$ARGUMENTS/.env && \
   clickhouse client --host "$CH_HOST" --user "${CH_USER:-default}" \
     --password "$CH_PASSWORD" ${CH_SECURE:+--secure} \
     --database "<db>" \
     --query "EXISTS TABLE <mv_table_name>"
   ```

If any queries error, **STOP and report** — don't waste time running a broken benchmark.

### Step 3: Execute Benchmark

Run the benchmark script. **This is a long-running operation** — use `run_in_background: true`:

```bash
templates/benchmark-query-optimization.sh \
  --env-file customers/$ARGUMENTS/.env \
  --manifest customers/$ARGUMENTS/benchmark.manifest \
  --output-dir customers/$ARGUMENTS/ \
  --runs 3 \
  --concurrency 25
```

**Default parameters** (override by asking the SA):
- `--runs 3` — 3 runs per query for statistical stability
- `--concurrency 25` — 25 parallel queries for concurrent load test

**If the benchmark takes too long or hangs**, the SA can cancel it. The script is safe to interrupt — partial results will still be in the output files.

### Step 4: Collect & Report Results

After the benchmark completes:

1. **Read the output files**:
   - `customers/$ARGUMENTS/benchmark_results_*.csv` — Raw timing data
   - `customers/$ARGUMENTS/benchmark_summary_*.txt` — Human-readable summary
   - `customers/$ARGUMENTS/benchmark_server_metrics_*.tsv` — Server-side metrics

2. **Report to the SA** with this structure:

```
## Benchmark Complete — $ARGUMENTS

**Host:** [from .env, shown in script banner]
**ClickHouse Version:** [from Step 1]
**Queries Tested:** [count from manifest]
**Runs per Query:** 3
**Concurrency:** 25

### Quick Summary

| Query | Original (avg) | Best Live (avg) | MV Read (avg) | Improvement |
|-------|----------------|-----------------|---------------|-------------|
| Q1    | Xs             | Xs              | Xs            | -X%         |

### Anomalies / Flags
- [Any ERROR results]
- [Any suspiciously fast/slow runs (>2x variance between runs)]
- [Any queries that returned 0 rows]

### Output Files
- CSV: customers/$ARGUMENTS/benchmark_results_TIMESTAMP.csv
- Summary: customers/$ARGUMENTS/benchmark_summary_TIMESTAMP.txt
- Server metrics: customers/$ARGUMENTS/benchmark_server_metrics_TIMESTAMP.tsv

### Suggested Next Steps
- [ ] Review results and run `/drafting-benchmark-assessment $ARGUMENTS`
- [ ] Re-run specific queries with different parameters if needed
- [ ] Test additional optimization variants
```

3. **Flag anomalies**:
   - If any run shows `ERROR`, report the query and likely cause
   - If variance between runs for the same query is >2x, flag it as unstable (could indicate background merges, noisy neighbor, or cache effects)
   - If any MV read is slower than the optimized query, flag it — something is wrong

### Step 5: Save Benchmark Metadata

Append a status update to any existing assessment or create a note:

```markdown
- **YYYY-MM-DD** — Benchmark executed: [N] queries, [runs] runs, [concurrency] concurrent.
  Output: benchmark_results_TIMESTAMP.csv
```

## Credential Safety Rules

- **NEVER** read `.env` files directly — only `source` them in Bash commands
- **NEVER** echo, cat, or log credential values
- **NEVER** include credentials in output, summaries, or file contents
- If a command fails and the error contains credentials, redact them before reporting
- The `.env` file stays in the customer folder (gitignored) and is only accessed by `source`

## Checklist Before Completing

- [ ] Customer folder validated (manifest, .env, SQL files all present)
- [ ] Connectivity confirmed (version retrieved)
- [ ] Pre-flight validation passed (queries return data, objects exist)
- [ ] Benchmark executed successfully (or partial results + error report)
- [ ] Results read and summarized for the SA
- [ ] Anomalies flagged (errors, high variance, unexpected results)
- [ ] Output file paths reported
- [ ] No credentials leaked in any output
