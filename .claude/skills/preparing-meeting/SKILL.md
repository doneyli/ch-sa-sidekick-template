---
name: preparing-meeting
description: Prepare questions and agenda for any customer meeting — discovery, follow-up, architecture review, POC check-in, or escalation
arguments: customer-name
---

# ClickHouse Meeting Prep

Prepare for a customer meeting with: **$ARGUMENTS**

## Voice

This is an **internal deliverable** (sidekick → SA). Follow `@sa-persona.md` — internal voice. Present options, flag unknowns, prep the SA to walk in ready.

## Instructions

1. **Read ALL files in `/customers/$ARGUMENTS/`** to build full engagement context
2. **Determine meeting type** from context — look for clues in recent files, Slack threads, or calendar notes:
   - **Discovery** — First call, no prior engagement history
   - **Follow-Up** — Prior assessment/review exists, customer has follow-up questions
   - **Architecture Review** — Deep-dive on schema design, scaling, or system architecture
   - **POC Check-In** — Active POC with milestones to track
   - **Escalation** — Performance incident, production issue, or urgent concern
3. **Generate the Customer History Summary** at the top (scan all customer files for engagement timeline)
4. **Include meeting-type-specific sections** (see conditional sections below)
5. Create file at `/customers/$ARGUMENTS/YYYY-MM-DD-meeting-prep.md` using today's date

## Meeting Prep Template

```markdown
# Meeting Prep: $ARGUMENTS

**Date:** YYYY-MM-DD
**Status:** Active
**Issue:** [Meeting type] prep — [one-line topic]

## Status Updates
- **YYYY-MM-DD** — Original creation

---

## Customer History Summary

[Scan all files in customer folder and produce a timeline]

| Date | File | Summary |
|------|------|---------|
| YYYY-MM-DD | [filename] | [One-line summary of what was covered] |

**Engagement pattern**: [First contact / Ongoing optimization / Active POC / Escalation]
**Total interactions**: [N files spanning X weeks/months]

---

## Meeting Type: [Discovery / Follow-Up / Architecture Review / POC Check-In / Escalation]

**Call Date**: [Scheduled date]
**Attendees**: [Names/roles if known]
**Call Duration**: [30/60 min]

---

## Pre-Call Context

### Known Information
- Company/Product: [What we know]
- Current state: [Existing database, pain points]
- Interest: [Why they're evaluating ClickHouse]

### Open Questions
- [What we don't know but should ask]

---

## Discovery Agenda

1. **Introductions** (5 min)
2. **Current State** (10-15 min)
3. **Requirements & Goals** (15-20 min)
4. **ClickHouse Fit Discussion** (10-15 min)
5. **Next Steps** (5 min)

---

## Questions by Category

### Current State
- What database(s) are you currently using for this use case?
- What's working well? What are the pain points?
- What's driving the evaluation of alternatives?

### Data Characteristics
- What's your current data volume? (GB/TB)
- What's your daily/monthly data growth rate?
- How long do you need to retain data?
- What does a typical record look like? (columns, types)

### Query Patterns
- What are your most important queries? (top 3)
- What's your latency requirement? (p50, p99)
- Who runs these queries? (analysts, dashboards, applications)
- What's your peak query concurrency?

### Ingestion Requirements
- How is data currently ingested? (batch, streaming, CDC)
- What's your target ingestion rate? (rows/sec, events/sec)
- What's your acceptable ingestion latency?
- Do you need exactly-once semantics or is at-least-once acceptable?

### Operational Requirements
- Cloud preference? (AWS, GCP, Azure, self-managed)
- Who will manage the system? (dedicated DBA, shared ops, managed service)
- What's your availability requirement? (SLA targets)
- Do you have compliance requirements? (SOC2, HIPAA, data residency)

### Timeline & Resources
- What's driving your timeline? (end of contract, scaling issue, new project)
- Who's on the evaluation team?
- What does success look like for this evaluation?

---

## Technical Deep-Dive Questions (if applicable)

### Schema Design
- Can you walk me through your main tables?
- What are your primary key / index columns?
- Do you have time-series data? What's the timestamp granularity?

### Query Details
- Can you share an example of a slow query?
- What aggregations do you typically run? (COUNT, SUM, AVG, percentiles)
- Do you need JOINs? What tables and how large?

### Integration
- What's your data pipeline stack? (Kafka, Airflow, Spark, etc.)
- Do you need SQL access, API access, or both?
- What BI tools do you use? (Grafana, Tableau, Superset, etc.)

---

## Red Flags to Listen For

- Heavy UPDATE/DELETE workloads (may need different approach)
- Complex multi-table JOINs (may need denormalization)
- Sub-millisecond latency requirements (may not be realistic)
- Strong transactional requirements (not ClickHouse's strength)

---

## Potential ClickHouse Features to Highlight

Based on what we know, be ready to discuss:
- [ ] [Feature relevant to their use case]
- [ ] [Feature relevant to their use case]
- [ ] [Feature relevant to their use case]

---

## Notes (fill during call)

### Current State
[Notes]

### Requirements
[Notes]

### Technical Details
[Notes]

### Next Steps Agreed
[Notes]

---

## Post-Call Actions
- [ ] Send follow-up email with summary
- [ ] Create assessment if detailed questions received
- [ ] Schedule technical deep-dive if needed
- [ ] Share relevant documentation or examples
```

## Meeting-Type Conditional Sections

Include these sections ONLY for the corresponding meeting type. They go after the Discovery Agenda and before the Technical Deep-Dive Questions.

### If Follow-Up Meeting

```markdown
## Outstanding Items from Prior Interactions

[Scan customer folder for assessments, reviews, follow-ups — list anything unresolved]

| Item | Source File | Date | Status |
|------|------------|------|--------|
| [Recommendation/action] | [filename] | YYYY-MM-DD | Open / In Progress / Done |

## Follow-Up Questions

- What happened when you tried [recommendation from prior assessment]?
- Did the [specific optimization] improve things? Can you share before/after query_log data?
- Any new issues since our last interaction?
```

### If Architecture Review

```markdown
## Architecture Questions

### Schema Evolution
- How has the schema changed since initial deployment?
- Are there new query patterns that the current schema doesn't serve well?
- What's the next 6-month growth projection?

### Scaling
- Current cluster topology? (nodes, shards, replicas)
- Where are the bottlenecks? (CPU, memory, disk, network)
- Are you hitting any resource limits?

### Multi-Tenancy (if applicable)
- How is tenant isolation implemented? (separate databases, column filter, row-level)
- Noisy neighbor problems?
- Tenant-level performance SLAs?

### Data Architecture
- Data pipeline topology? (sources → ingestion → ClickHouse → consumers)
- Materialized View dependency graph?
- Backup and disaster recovery strategy?
```

### If POC Check-In

```markdown
## POC Progress Checklist

[Scan customer folder for POC plan, milestones, or implementation phases]

| Milestone | Target Date | Status | Notes |
|-----------|-------------|--------|-------|
| [Milestone from POC plan] | YYYY-MM-DD | Not Started / In Progress / Done / Blocked | [Notes] |

## POC Check-In Questions

- What's working well so far?
- What's been harder than expected?
- Any blockers we can help unblock?
- Timeline still on track?
- What would make this a "yes" decision?
```

### If Escalation

```markdown
## Escalation Context

- **Severity**: [P1 Critical / P2 High / P3 Medium]
- **Impact**: [What's broken — production down, data loss risk, performance degradation]
- **Timeline**: [When it started, any recent changes]
- **Who's involved**: [Customer team, our team, support tickets]

## Escalation Prep

- [ ] Review recent system.query_log / system.errors if available
- [ ] Check if any recent schema changes or deployments correlate
- [ ] Prepare rollback options
- [ ] Identify what information we need from the customer to diagnose
```

## Question Selection Tips

- Start broad, drill down based on answers
- Listen for pain points — they indicate priorities
- Don't overwhelm — pick 8-10 key questions
- Leave time for their questions
- **For follow-ups**: Lead with outstanding items, then new questions
- **For architecture reviews**: Go deep on one area rather than shallow on all
- **For POC check-ins**: Focus on blockers and timeline risk
- **For escalations**: Focus on timeline, recent changes, and immediate mitigation

## Checklist

- [ ] All customer files in `/customers/$ARGUMENTS/` were read
- [ ] Meeting type correctly identified
- [ ] Customer history summary generated from engagement timeline
- [ ] Meeting-type-specific sections included
- [ ] Questions tailored to known use case and meeting type
- [ ] Agenda fits allocated time
- [ ] Note-taking sections ready
- [ ] Outstanding items from prior interactions listed (if follow-up/review)
