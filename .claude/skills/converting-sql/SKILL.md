---
name: converting-sql
description: Convert SQL from another database dialect (Snowflake, Postgres, MySQL, BigQuery) to ClickHouse. Use when a customer is migrating from another database, when reviewing non-ClickHouse SQL, when doing dialect comparison, or when you see Snowflake/Postgres/MySQL/BigQuery syntax that needs a ClickHouse equivalent.
arguments: customer-name
model: sonnet
---

# SQL Conversion — Source DB to ClickHouse

Generate a conversion package for: **$ARGUMENTS**

## Voice

This is a **customer-facing deliverable**. Follow `@sa-persona.md` — deliverable voice. Every converted query must be copy-paste ready. Be explicit about incompatibilities — no surprises during migration.

## Instructions

1. **Load source SQL files from `/customers/$ARGUMENTS/`** — Look for:
   - `snowflake-queries/`, `postgres-queries/`, `mysql-queries/`, `bigquery-queries/` subfolders
   - Any `.sql` files with non-ClickHouse syntax
   - DDL files showing source schema
   - Migration notes or README files describing the conversion scope

2. **Identify source database dialect** — Read `references/dialect-mappings.md` for identification markers, type mappings, and common syntax conversion patterns. Determine dialect from syntax clues.

3. **Invoke `/clickhouse-best-practices`** — Converted DDL should follow ClickHouse best practices:
   - ORDER BY key design (`schema-pk-*` rules)
   - Type mapping (`schema-types-*` rules)
   - Partition strategy (`schema-partition-*` rules)

4. **Produce the conversion package** — Two outputs:
   - `YYYY-MM-DD-sql-conversion.md` — README with mapping tables and notes
   - `clickhouse-queries/` subfolder — One converted `.sql` file per source query

## Output: README Template

Write to `/customers/$ARGUMENTS/YYYY-MM-DD-sql-conversion.md`:

```markdown
# SQL Conversion: $ARGUMENTS

**Date:** YYYY-MM-DD
**Status:** Active
**Issue:** [Source dialect] to ClickHouse SQL conversion

## Status Updates
- **YYYY-MM-DD** — Original creation

---

## Source → Target Summary

| Field | Value |
|-------|-------|
| Source Dialect | [Snowflake / Postgres / MySQL / BigQuery] |
| Source Tables | [N tables referenced] |
| Queries Converted | [N queries] |
| DDL Converted | [Yes / No / Partial] |
| Target ClickHouse Version | [Min version needed] |

---

## Function Mapping

| Source Function | ClickHouse Equivalent | Notes |
|----------------|----------------------|-------|
| `source_func()` | `ch_func()` | [Direct equivalent / Behavioral difference] |

---

## Type Mapping

| Source Type | ClickHouse Type | Notes |
|-------------|----------------|-------|
| `VARCHAR(N)` | `String` | ClickHouse String is unbounded |
| `TIMESTAMP_LTZ` | `DateTime64(3)` | [Timezone handling notes] |
| `VARIANT` / `JSONB` | `JSON` or `String` + JSON functions | [Approach chosen and why] |
| `BOOLEAN` | `Bool` or `UInt8` | [Version note: Bool type requires 21.12+] |
| `DECIMAL(p,s)` | `Decimal(p,s)` | [Precision limits] |

---

## Syntax Differences

### [Category — e.g., Window Functions]
- **Source**: [How it works in source DB]
- **ClickHouse**: [How to achieve the same in ClickHouse]
- **Example**:
```sql
-- Source
[source SQL]

-- ClickHouse
[converted SQL]
```

### [Category — e.g., NULL Handling]
- **Source**: [Behavior]
- **ClickHouse**: [Behavior — note differences]

### [Category — e.g., QUALIFY / Row Filtering]
- **Source**: `QUALIFY ROW_NUMBER() OVER (...) = 1`
- **ClickHouse**: Wrap in subquery: `SELECT * FROM (SELECT *, ROW_NUMBER() OVER (...) AS rn FROM t) WHERE rn = 1`

---

## Converted Queries

| File | Original | Purpose | Status | Notes |
|------|----------|---------|--------|-------|
| `clickhouse-queries/query_name.sql` | `source_file.sql` | [Description] | Done / Partial / Blocked | [Notes] |

---

## Lookup / Reference Tables Required

[Tables that need to be migrated alongside queries — JOINed reference data, dictionaries, etc.]

```sql
-- DDL for required lookup tables
CREATE TABLE ...
```

---

## Known Incompatibilities

[Features in source queries that have no direct ClickHouse equivalent]

| Feature | Source Usage | Workaround | Limitation |
|---------|-------------|------------|------------|
| [Feature] | [How it's used] | [ClickHouse alternative] | [What's lost] |

---

## Performance Notes

[ClickHouse-specific optimizations applied during conversion]

1. **[Optimization]**: [What was changed and why — e.g., "Replaced correlated subquery with JOIN for ClickHouse's hash join engine"]
2. **[Optimization]**: [What was changed and why]

---

## DDL Conversion

[If source DDL was provided, show the converted ClickHouse DDL]

```sql
-- Source DDL
[original]

-- ClickHouse DDL (follows best practices per schema-pk-* rules)
[converted]
```
```

## Output: Converted Query Files

Write each converted query to `/customers/$ARGUMENTS/clickhouse-queries/`:
- One file per source query
- File naming: `descriptive_name.sql` (not `q1.sql` — use meaningful names)
- Each file should include a header comment:

```sql
-- Converted from: [source_file.sql]
-- Source dialect: [Snowflake/Postgres/etc.]
-- Date: YYYY-MM-DD
-- Notes: [Any conversion-specific notes]

[converted SQL]
```

## Checklist

- [ ] `/clickhouse-best-practices` was invoked for DDL design rules
- [ ] Source dialect correctly identified
- [ ] Function mapping table is complete (every source function has a ClickHouse equivalent)
- [ ] Type mapping table is complete
- [ ] Every source query has a converted version in `clickhouse-queries/`
- [ ] Converted DDL follows `schema-pk-*` rules (ORDER BY, partitioning, types)
- [ ] All SQL is copy-paste ready (not fragments or pseudocode)
- [ ] Known incompatibilities are explicitly listed
- [ ] Lookup/reference tables identified and DDL provided
- [ ] Performance notes document ClickHouse-specific optimizations applied
