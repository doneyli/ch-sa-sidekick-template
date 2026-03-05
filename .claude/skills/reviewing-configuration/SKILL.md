---
name: reviewing-configuration
description: Audit ClickHouse configuration settings against best practices
arguments: customer-name
---

# ClickHouse Configuration Review

Generate a structured configuration audit for: **$ARGUMENTS**

## Voice

This is a **customer-facing deliverable**. Follow `@sa-persona.md` — deliverable voice. Be direct about misconfiguration, validate good choices, make every setting change copy-paste ready.

## Instructions

1. **Load config files from `/customers/$ARGUMENTS/`** — Look for:
   - `*.xml` — ClickHouse server config files (`config.xml`, `users.xml`, profiles)
   - `*.yml` / `*.yaml` — ClickHouse Keeper or orchestration configs
   - `config.md` or config excerpts embedded in assessment files
   - System settings output (`SELECT * FROM system.settings WHERE changed`)
   - MergeTree settings on tables (`SHOW CREATE TABLE` output with `SETTINGS`)

2. **Invoke `/clickhouse-best-practices`** — Check settings-related rules:
   - `insert-async-*` rules for async insert settings
   - `insert-batch-*` rules for batch size and frequency settings
   - `schema-partition-*` rules for partition-related settings
   - Any rules mentioning `max_threads`, `max_memory_usage`, `max_bytes_before_external_*`, etc.

3. **Invoke `/researching-documentation`** — For any settings that need version verification or where the default changed between versions.

4. **Produce the audit** — Write to `/customers/$ARGUMENTS/YYYY-MM-DD-config-review.md` using today's date.

## Output Template

```markdown
# Configuration Review: $ARGUMENTS

**Date:** YYYY-MM-DD
**Status:** Active
**Issue:** ClickHouse configuration audit

## Status Updates
- **YYYY-MM-DD** — Original creation

---

## Environment

| Field | Value |
|-------|-------|
| ClickHouse Version | [Version] |
| Deployment | Cloud / Self-managed |
| Node Count | [N nodes / N shards × N replicas] |
| Cloud Tier | [If Cloud: Development / Production / Dedicated] |
| OS | [If self-managed and known] |

---

## Settings Audit

| Setting | Current Value | Default | Recommendation | Source |
|---------|--------------|---------|----------------|--------|
| `setting_name` | `current` | `default` | Keep / Change to X | Per rule `rule-name` |
| `setting_name` | `current` | `default` | Keep / Change to X | Per docs [link] |

---

## Findings

### Critical — Fix Immediately

#### [Setting/Issue Title]
- **Current**: [What's configured]
- **Problem**: [Why this is dangerous or wrong]
- **Fix**:
```xml
<!-- For server config -->
<setting_name>new_value</setting_name>
```
```sql
-- For session/profile settings
SET setting_name = new_value;
-- Or permanent via profiles:
ALTER SETTINGS PROFILE default SETTINGS setting_name = new_value;
```
- **Source**: Per rule `rule-name` / Per docs [link]

### Should Change — High Impact

#### [Setting/Issue Title]
- **Current**: [What's configured]
- **Recommendation**: [What to change and why]
- **Fix**: [Copy-paste config or SQL]
- **Source**: [Citation]

### Acceptable — No Action Needed

- `setting_name = value` — [Brief note on why this is fine]
- `setting_name = value` — [Brief note]

---

## Cloud-Specific Notes

[If ClickHouse Cloud — note which settings are managed by the platform vs. user-controllable. Flag any settings the customer is trying to change that Cloud manages.]

- **Managed by Cloud**: [list — e.g., replication, backups, Keeper]
- **User-controllable**: [list — e.g., query-level settings, profiles, quotas]
- **Requires support ticket**: [list — e.g., certain server-level overrides]

---

## Keeper / ZooKeeper Configuration

[If Keeper/ZooKeeper config was provided]

| Setting | Current | Recommendation | Notes |
|---------|---------|----------------|-------|
| `session_timeout_ms` | [value] | [recommendation] | [notes] |
| `snapshot_distance` | [value] | [recommendation] | [notes] |

---

## MergeTree Table Settings

[Settings found in table DDL via `SETTINGS` clause]

| Table | Setting | Value | Recommendation | Notes |
|-------|---------|-------|----------------|-------|
| `table_name` | `index_granularity` | [value] | [recommendation] | [notes] |
| `table_name` | `merge_with_ttl_timeout` | [value] | [recommendation] | [notes] |

---

## Recommendations Summary

Prioritized list of all changes:

1. **[Critical]** [Action] — [one-line why]
2. **[Critical]** [Action] — [one-line why]
3. **[High]** [Action] — [one-line why]
4. **[Medium]** [Action] — [one-line why]

---

## Missing Information

[Settings or configs we'd want to review but weren't provided]

- [ ] [Missing config — e.g., "No users.xml provided — can't audit profiles/quotas"]
- [ ] [Missing info — e.g., "ClickHouse version not confirmed"]
- [ ] [Missing context — e.g., "No query_log sample to correlate settings with workload"]
```

## Checklist

- [ ] `/clickhouse-best-practices` was invoked for settings-related rules
- [ ] `/researching-documentation` was invoked for version-dependent settings
- [ ] All provided config files were reviewed
- [ ] Settings audit table is complete (every non-default setting listed)
- [ ] Findings are grouped by severity (Critical / Should Change / Acceptable)
- [ ] Every recommendation includes copy-paste ready config or SQL
- [ ] Cloud vs. self-managed distinction is noted
- [ ] Missing information section lists what we'd still want to see
