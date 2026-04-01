---
name: drafting-migration-guide
description: Generate step-by-step migration guide for schema changes or version upgrades. Use when a customer needs to migrate schema, upgrade ClickHouse versions, move data between tables, or when any schema change requires a rollback plan and phased execution steps.
arguments: customer-name
model: opus
---

# ClickHouse Migration Guide

Generate migration guide for: **$ARGUMENTS**

## Instructions

1. Understand the migration scope (schema change, version upgrade, data migration)
2. Document step-by-step process with rollback options
3. Create file at `/customers/$ARGUMENTS/migration-guide.md`

## Migration Guide Template

```markdown
# Migration Guide: $ARGUMENTS

**Date**: [Date]
**Migration Type**: [Schema change / Version upgrade / Data migration / Platform migration]
**Current State**: [Version, schema, platform]
**Target State**: [Version, schema, platform]

---

## Executive Summary

[What is being migrated and why]

**Risk Level**: [Low / Medium / High]
**Estimated Duration**: [X hours/days]
**Downtime Required**: [None / Brief / Extended]

---

## Pre-Migration Checklist

### Environment
- [ ] ClickHouse version confirmed: [current] → [target]
- [ ] Disk space available: [X GB needed, X GB available]
- [ ] Memory available: [X GB needed, X GB available]
- [ ] Backup verified: [Date of last backup]

### Dependencies
- [ ] Downstream consumers notified
- [ ] Ingestion pipeline can be paused
- [ ] Monitoring alerts adjusted

### Testing
- [ ] Migration tested in staging/dev
- [ ] Rollback procedure tested
- [ ] Validation queries prepared

---

## Migration Steps

### Phase 1: Preparation

#### Step 1.1: Create Backup
```sql
-- Backup existing table
CREATE TABLE [table_name]_backup AS [table_name];

-- Or for large tables, use BACKUP command (23.3+)
BACKUP TABLE [table_name] TO Disk('backups', '[backup_name]');
```

**Verification**:
```sql
SELECT count() FROM [table_name];
SELECT count() FROM [table_name]_backup;
-- Counts should match
```

#### Step 1.2: Pause Ingestion
[Instructions for pausing ingestion pipeline]

**Verification**:
- Check ingestion logs stopped
- Verify no new inserts in `system.query_log`

### Phase 2: Migration

#### Step 2.1: Create New Table
```sql
-- New table with updated schema
CREATE TABLE [table_name]_new
(
    -- New schema definition
)
ENGINE = MergeTree()
ORDER BY (...)
PARTITION BY ...
SETTINGS ...;
```

#### Step 2.2: Migrate Data
```sql
-- Option A: INSERT SELECT (for moderate data volumes)
INSERT INTO [table_name]_new
SELECT
    -- Column mappings, transformations
FROM [table_name];

-- Option B: Use clickhouse-copier for large tables
-- Option C: Use ATTACH PARTITION for compatible schemas
```

**Verification**:
```sql
-- Row count match
SELECT count() FROM [table_name];
SELECT count() FROM [table_name]_new;

-- Data integrity check
SELECT sum(checksum) FROM (
    SELECT cityHash64(*) as checksum FROM [table_name]
);
SELECT sum(checksum) FROM (
    SELECT cityHash64(*) as checksum FROM [table_name]_new
);
```

#### Step 2.3: Swap Tables
```sql
-- Rename in single transaction
RENAME TABLE
    [table_name] TO [table_name]_old,
    [table_name]_new TO [table_name];
```

### Phase 3: Validation

#### Step 3.1: Verify Schema
```sql
SHOW CREATE TABLE [table_name];
-- Confirm new schema is correct
```

#### Step 3.2: Test Queries
```sql
-- Run key queries and verify results
EXPLAIN indexes = 1
SELECT ... FROM [table_name] WHERE ...;

-- Compare query performance
SELECT query, query_duration_ms
FROM system.query_log
WHERE query LIKE '%[table_name]%'
ORDER BY event_time DESC
LIMIT 10;
```

#### Step 3.3: Resume Ingestion
[Instructions for resuming ingestion pipeline]

**Verification**:
```sql
-- Verify inserts are working
SELECT count() FROM [table_name] WHERE [timestamp_col] > now() - INTERVAL 5 MINUTE;
```

### Phase 4: Cleanup

#### Step 4.1: Monitor (24-48 hours)
- [ ] Query latency normal
- [ ] Insert rate normal
- [ ] No errors in logs
- [ ] Disk usage as expected

#### Step 4.2: Remove Old Tables
```sql
-- Only after verification period!
DROP TABLE [table_name]_old;
DROP TABLE [table_name]_backup;
```

---

## Rollback Procedure

### Immediate Rollback (during migration)
```sql
-- If new table creation fails, no action needed
-- If data migration fails:
DROP TABLE IF EXISTS [table_name]_new;
-- Resume ingestion to original table
```

### Post-Migration Rollback
```sql
-- Swap back to old table
RENAME TABLE
    [table_name] TO [table_name]_failed,
    [table_name]_old TO [table_name];

-- Resume ingestion
-- Note: Data inserted after migration will be lost
```

### Recovery from Backup
```sql
-- If old table was dropped:
RENAME TABLE [table_name]_backup TO [table_name];
-- Or restore from BACKUP
RESTORE TABLE [table_name] FROM Disk('backups', '[backup_name]');
```

---

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Data loss | High | Low | Backup before migration |
| Extended downtime | Medium | Medium | Test migration timing in staging |
| Query performance regression | Medium | Medium | Test queries before swap |
| Ingestion failures | High | Low | Coordinate with pipeline team |

---

## Version-Specific Notes

[If version upgrade, include:]
- Breaking changes in target version
- Deprecated features being used
- New features to leverage
- Settings changes required

---

## Timing Estimates

| Step | Estimated Duration | Notes |
|------|-------------------|-------|
| Backup | [X min/hours] | Depends on table size |
| Data migration | [X min/hours] | [X rows, X GB] |
| Validation | [X min] | Fixed overhead |
| **Total** | [X hours] | |

---

## Communication Plan

### Before Migration
- [ ] Notify: [List of stakeholders]
- [ ] Schedule: [Maintenance window if needed]

### During Migration
- [ ] Status updates every: [X minutes]
- [ ] Escalation contact: [Name/channel]

### After Migration
- [ ] Completion notification
- [ ] Updated documentation

---

## Post-Migration Tasks

- [ ] Update documentation with new schema
- [ ] Update dashboards/queries if needed
- [ ] Archive migration scripts
- [ ] Schedule cleanup of backup tables
- [ ] Review and document lessons learned
```

## Migration Patterns

### Schema Change (add column)
- Use `ALTER TABLE ADD COLUMN` for simple additions
- No data migration needed for default values

### Schema Change (modify column/PK)
- Requires new table and data migration
- Use INSERT SELECT or clickhouse-copier

### Version Upgrade
- Review changelog for breaking changes
- Test in staging first
- Plan for settings changes

### Platform Migration (self-managed → Cloud)
- Use ClickHouse Cloud migration tools
- Consider network transfer time
- Plan for DNS/endpoint changes

## Checklist

- [ ] Backup strategy defined
- [ ] Rollback procedure documented
- [ ] Steps are copy-paste ready
- [ ] Verification queries included
- [ ] Timing estimates provided
- [ ] Risks identified
