---
name: reviewing-architecture
description: Evaluate system architecture and design decisions for ClickHouse deployment
arguments: customer-name
---

# ClickHouse Architecture Review

Generate architecture review for: **$ARGUMENTS**

## Instructions

1. **FIRST**: Invoke `/researching-documentation` with key architecture questions:
   - Focus on design patterns, scalability features, and operational concerns relevant to the review
   - Review the research output for documented best practices and known gaps
2. Invoke `/clickhouse-best-practices` for applicable rules
3. Evaluate architecture against ClickHouse design principles
4. Create file at `/customers/$ARGUMENTS/architecture-review.md`

## Architecture Review Template

```markdown
# Architecture Review: $ARGUMENTS

**Date**: [Date]
**ClickHouse Version**: [Version]
**Deployment**: Cloud / Self-managed
**Review Scope**: [What aspects are being reviewed]

---

## Executive Summary

[3-5 sentences: Overall assessment, key strengths, critical issues]

**Overall Score**: [Green / Yellow / Red]

---

## System Overview

### Architecture Diagram
[Description or ASCII diagram of the system]

### Components
| Component | Technology | Purpose |
|-----------|------------|---------|
| Data source | [Kafka, S3, etc.] | [Purpose] |
| Ingestion | [Method] | [Purpose] |
| Storage | ClickHouse [version] | [Purpose] |
| Query layer | [Direct, proxy, etc.] | [Purpose] |
| Consumers | [Dashboards, apps, etc.] | [Purpose] |

### Scale
- Data volume: [X TB total]
- Daily growth: [X GB/day]
- Query rate: [X queries/sec]
- Concurrent users: [X users]

---

## Schema Review

### Tables Evaluated
| Table | Engine | Rows | Size | Purpose |
|-------|--------|------|------|---------|
| [table_name] | [MergeTree variant] | [X M/B] | [X GB] | [Purpose] |

### Schema Assessment

#### Table: [table_name]

**DDL**:
```sql
CREATE TABLE ...
```

**Assessment**:

| Aspect | Status | Notes |
|--------|--------|-------|
| Primary key order | [Good/Needs work] | [Per rule X] |
| Partitioning | [Good/Needs work] | [Per rule X] |
| Column types | [Good/Needs work] | [Per rule X] |
| Compression | [Good/Needs work] | [Per rule X] |

**Recommendations**:
- [Specific recommendation with SQL]

---

## Query Patterns Review

### Query Types
| Query Type | Frequency | Avg Latency | Status |
|------------|-----------|-------------|--------|
| [Dashboard aggregation] | [X/min] | [X ms] | [Good/Needs work] |
| [Ad-hoc analytics] | [X/day] | [X sec] | [Good/Needs work] |

### Problematic Queries

#### Query 1: [Description]
```sql
-- Current query
```

**Issues**:
- [Issue 1]
- [Issue 2]

**Recommended**:
```sql
-- Optimized query
```

---

## Ingestion Review

### Current Pipeline
[Description of ingestion architecture]

### Assessment
| Aspect | Status | Notes |
|--------|--------|-------|
| Batch size | [Good/Needs work] | [Per rule X] |
| Insert frequency | [Good/Needs work] | [Per rule X] |
| Async inserts | [Using/Not using] | [Recommendation] |
| Error handling | [Good/Needs work] | [Notes] |

### Recommendations
- [Specific recommendation]

---

## Operational Review

### Monitoring
| Metric | Monitored? | Alerting? | Notes |
|--------|------------|-----------|-------|
| Disk usage | [Yes/No] | [Yes/No] | [Notes] |
| Memory usage | [Yes/No] | [Yes/No] | [Notes] |
| Query latency | [Yes/No] | [Yes/No] | [Notes] |
| Merge health | [Yes/No] | [Yes/No] | [Notes] |
| Replication lag | [Yes/No] | [Yes/No] | [Notes] |

### Backup & Recovery
- Backup method: [Description]
- Backup frequency: [Daily/Weekly/etc.]
- Recovery tested: [Yes/No/Unknown]
- RTO target: [X hours]
- RPO target: [X hours]

### High Availability
- Cluster topology: [Single node / Replicated / Sharded]
- Failover: [Automatic/Manual/None]
- Disaster recovery: [Description]

---

## Security Review

| Aspect | Status | Notes |
|--------|--------|-------|
| Authentication | [Configured/Not configured] | [Method] |
| Authorization | [RBAC/Basic/None] | [Notes] |
| Encryption at rest | [Enabled/Disabled] | [Notes] |
| Encryption in transit | [TLS/Plaintext] | [Notes] |
| Audit logging | [Enabled/Disabled] | [Notes] |

---

## Rules Compliance Summary

| Rule Category | Checked | Violations | Notes |
|---------------|---------|------------|-------|
| Schema (`schema-*`) | [X rules] | [X violations] | [Summary] |
| Query (`query-*`) | [X rules] | [X violations] | [Summary] |
| Insert (`insert-*`) | [X rules] | [X violations] | [Summary] |

### Critical Violations
- **`rule-name`**: [Description and impact]

### Compliant Areas
- [Area]: Following best practices for [aspect]

---

## Recommendations Summary

### Critical (Address Immediately)
1. **[Issue]**: [Brief description]
   - Impact: [What's at risk]
   - Fix: [High-level action]
   - Effort: [Low/Medium/High]

### High Priority (Address Soon)
1. **[Issue]**: [Brief description]

### Medium Priority (Plan For)
1. **[Issue]**: [Brief description]

### Nice to Have (Future Improvements)
1. **[Issue]**: [Brief description]

---

## Architecture Recommendations

### Current State
[Description of current architecture]

### Recommended State
[Description of target architecture]

### Migration Path
1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## Next Steps

1. [ ] [Immediate action]
2. [ ] [Short-term action]
3. [ ] Schedule deep-dive on [specific area]
4. [ ] Follow-up review in [timeframe]
```

## Review Focus Areas

Depending on the review scope, emphasize:

- **Performance review**: Query patterns, schema design, resource utilization
- **Security review**: Authentication, authorization, encryption, audit
- **Scalability review**: Growth projections, sharding strategy, resource limits
- **Operational review**: Monitoring, alerting, backup, disaster recovery

## Checklist

- [ ] Docs-research skill invoked for architecture questions
- [ ] Documentation gaps noted in review
- [ ] Best practices skill invoked
- [ ] All tables reviewed
- [ ] Query patterns analyzed
- [ ] Ingestion assessed
- [ ] Operational aspects covered
- [ ] Recommendations prioritized (citing documented vs inferred guidance)
- [ ] Next steps defined
