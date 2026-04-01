---
name: drafting-poc-plan
description: Generate a POC plan with milestones, success criteria, and timeline. Use when a customer wants an implementation plan, when scoping a proof of concept, when defining success criteria for an evaluation, or when building a phased rollout plan for ClickHouse adoption.
arguments: customer-name
model: sonnet
---

# ClickHouse POC Plan

Generate a POC plan for customer: **$ARGUMENTS**

## Instructions

1. Understand the customer's evaluation goals
2. Define clear, measurable success criteria
3. Break into phases with specific milestones
4. Include technical validation steps
5. Create file at `/customers/$ARGUMENTS/poc-plan.md`

## POC Plan Template

```markdown
# POC Plan: $ARGUMENTS

**Created**: [Date]
**POC Duration**: [X weeks]
**ClickHouse Version**: [Target version]
**Deployment**: Cloud / Self-managed

---

## Executive Summary

[2-3 sentences: What problem are we solving? What will success look like?]

---

## Success Criteria

### Must Have (POC Blockers)
| Criterion | Metric | Target | How to Measure |
|-----------|--------|--------|----------------|
| Query latency | p99 response time | < X ms | Query log analysis |
| Throughput | Rows ingested/sec | > X rows/sec | Insert benchmarks |
| Data accuracy | Aggregation match | 100% vs source | Validation queries |

### Nice to Have
| Criterion | Metric | Target | Notes |
|-----------|--------|--------|-------|
| [Feature] | [Metric] | [Target] | [Notes] |

---

## POC Scope

### In Scope
- [Specific use case or feature to validate]
- [Specific use case or feature to validate]

### Out of Scope
- [Explicitly excluded items]
- [Items deferred to production phase]

### Assumptions
- [Key assumption about data, access, resources]
- [Key assumption]

---

## Technical Approach

### Schema Design
```sql
-- Proposed table structure
CREATE TABLE ...
```

**Design Rationale**:
- Primary key order: [Explanation, cite rule]
- Partitioning: [Explanation, cite rule]
- Table engine: [Explanation]

### Data Pipeline
- Source: [Where data comes from]
- Format: [JSON, CSV, Parquet, etc.]
- Ingestion method: [Kafka, HTTP, file import]
- Frequency: [Real-time, batch, hybrid]

### Key Queries
```sql
-- Primary use case query
SELECT ...
```

---

## Milestones

### Phase 1: Setup & Data Load (Week 1)
- [ ] Provision ClickHouse environment
- [ ] Create tables with proposed schema
- [ ] Load sample dataset ([X GB / X rows])
- [ ] Validate data integrity

**Exit Criteria**: Data loaded, basic queries return expected results

### Phase 2: Query Validation (Week 2)
- [ ] Execute benchmark queries
- [ ] Measure latency against success criteria
- [ ] Tune queries/schema if needed
- [ ] Document query performance

**Exit Criteria**: Query latency meets targets

### Phase 3: Ingestion Testing (Week 2-3)
- [ ] Test insert throughput
- [ ] Validate near-real-time pipeline
- [ ] Measure insert latency
- [ ] Test concurrent read/write

**Exit Criteria**: Ingestion rate meets targets

### Phase 4: Production Readiness (Week 3-4)
- [ ] Test failure scenarios (if self-managed)
- [ ] Validate backup/restore
- [ ] Document operational runbook
- [ ] Final performance benchmarks

**Exit Criteria**: Ready for production planning

---

## Resource Requirements

### ClickHouse Environment
- **Cloud tier**: [Development / Production]
- **Compute**: [X vCPUs, X GB RAM]
- **Storage**: [X GB estimated]

### Data
- Sample dataset: [Description, size]
- Production data access: [Required / Not required]

### Customer Resources
- [POC lead / technical contact]
- [Data engineering support if needed]
- [Estimated hours/week commitment]

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| [Risk description] | High/Med/Low | High/Med/Low | [Mitigation plan] |

---

## Timeline

| Week | Phase | Activities | Deliverables |
|------|-------|------------|--------------|
| 1 | Setup | Environment, schema, data load | Data loaded, queries working |
| 2 | Validation | Query benchmarks, tuning | Performance report |
| 3 | Ingestion | Pipeline testing | Throughput validation |
| 4 | Wrap-up | Final testing, documentation | POC summary, go/no-go |

---

## Next Steps

1. [ ] Review POC plan with customer
2. [ ] Confirm success criteria and timeline
3. [ ] Provision environment
4. [ ] Schedule kickoff call
```

## Checklist

- [ ] Success criteria are specific and measurable
- [ ] Schema design follows best practices
- [ ] Timeline is realistic
- [ ] Risks are identified with mitigations
- [ ] Customer resource requirements are clear
